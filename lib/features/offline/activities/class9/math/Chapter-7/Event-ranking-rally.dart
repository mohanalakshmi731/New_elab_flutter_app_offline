// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: EventRankingRallyApp(),
  ));
}

class EventRankingRallyApp extends StatefulWidget {
  const EventRankingRallyApp({super.key});

  @override
  State<EventRankingRallyApp> createState() => _EventRankingRallyAppState();
}

class GameCard {
  final String id;
  final int targetZone;
  final String emoji;
  final Map<String, String> text;

  const GameCard({
    required this.id,
    required this.targetZone,
    required this.emoji,
    required this.text,
  });
}

class Scenario {
  final Map<String, String> title;
  final List<GameCard> cards;
  const Scenario({required this.title, required this.cards});
}

class _EventRankingRallyAppState extends State<EventRankingRallyApp> with SingleTickerProviderStateMixin {
  // === State Variables ===
  bool _hasStarted = false;
  bool _isSidebarOpen = true;
  String _language = 'en';
  
  int _activeScenario = 0;
  int _hintIdx = 0;
  
  // State for the 3 scenarios
  List<Map<String, int>> _placements = [{}, {}, {}];
  List<bool> _passed = [false, false, false];

  // Modals & Feedback
  bool _flashSuccess = false;
  String _flashTitle = '';
  String _flashDesc = '';
  String _flashFeedback = '';
  bool _showReport = false;

  // Animation for Shutter
  late AnimationController _shutterController;
  late Animation<Offset> _shutterAnimation;

  // === Audio Players ===
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer1 = AudioPlayer();
  final AudioPlayer _sfxPlayer2 = AudioPlayer();

  final String sfxClick = 'audio/class9/click.mp3';
  final String sfxShutter = 'audio/class9/shutter.mp3';
  final String sfxSuccess = 'audio/class9/success.mp3';
  final String sfxError = 'audio/class9/error.mp3';

  // === Data ===
  final List<Scenario> _scenarios = [
    const Scenario(
      title: {'en': 'Everyday Basics', 'hi': 'रोज़मर्रा की बातें'},
      cards: [
        GameCard(id: 's1c0', targetZone: 0, emoji: '🎲', text: {'en': 'You roll an 8 on a standard six-sided die', 'hi': 'आप एक मानक छह-पक्षीय पासे पर 8 घुमाते हैं'}),
        GameCard(id: 's1c1', targetZone: 1, emoji: '🃏', text: {'en': 'You draw the King of Hearts on your first pick from a full deck', 'hi': 'आप पूरी गड्डी से अपनी पहली पसंद पर पान का राजा निकालते हैं'}),
        GameCard(id: 's1c2', targetZone: 2, emoji: '🪙', text: {'en': 'A fair coin lands on Heads', 'hi': 'एक निष्पक्ष सिक्का चित पर गिरता है'}),
        GameCard(id: 's1c3', targetZone: 3, emoji: '🎯', text: {'en': 'A spinner that is mostly orange stops on orange', 'hi': 'एक स्पिनर जो ज्यादातर नारंगी है, नारंगी पर रुकता है'}),
        GameCard(id: 's1c4', targetZone: 4, emoji: '🌅', text: {'en': 'The sun rises in the east tomorrow morning', 'hi': 'कल सुबह सूरज पूर्व में उगेगा'}),
      ]
    ),
    const Scenario(
      title: {'en': 'Real-Life Rally', 'hi': 'वास्तविक जीवन रैली'},
      cards: [
        GameCard(id: 's2c0', targetZone: 0, emoji: '🐟', text: {'en': 'A fish climbs a tree all by itself', 'hi': 'एक मछली खुद ही पेड़ पर चढ़ जाती है'}),
        GameCard(id: 's2c1', targetZone: 1, emoji: '🎟️', text: {'en': 'You win first prize holding 1 ticket out of 100', 'hi': 'आप 100 में से 1 टिकट लेकर प्रथम पुरस्कार जीतते हैं'}),
        GameCard(id: 's2c2', targetZone: 2, emoji: '👶', text: {'en': 'A newborn baby is a girl rather than a boy', 'hi': 'नवजात शिशु लड़के के बजाय लड़की होती है'}),
        GameCard(id: 's2c3', targetZone: 3, emoji: '☀️', text: {'en': 'A day in the dry season turns out sunny', 'hi': 'शुष्क मौसम का एक दिन धूप वाला होता है'}),
        GameCard(id: 's2c4', targetZone: 4, emoji: '💧', text: {'en': 'Water feels wet when you touch it', 'hi': 'छूने पर पानी गीला लगता है'}),
      ]
    ),
    const Scenario(
      title: {'en': 'Textbook Challenge', 'hi': 'पाठ्यपुस्तक चुनौती'},
      cards: [
        GameCard(id: 's3c0', targetZone: 0, emoji: '📅', text: {'en': 'The day straight after Monday is Sunday', 'hi': 'सोमवार के ठीक बाद का दिन रविवार है'}),
        GameCard(id: 's3c1', targetZone: 1, emoji: '🎲', text: {'en': 'Rolling two standard dice gives a total of 12', 'hi': 'दो मानक पासे घुमाने पर कुल 12 मिलता है'}),
        GameCard(id: 's3c2', targetZone: 2, emoji: '🎾', text: {'en': 'Drawing a green ball from a bag of 5 green and 5 red balls', 'hi': '5 हरी और 5 लाल गेंदों के थैले से एक हरी गेंद निकालना'}),
        GameCard(id: 's3c3', targetZone: 3, emoji: '🎲', text: {'en': 'Rolling a number greater than 2 on a six-sided die', 'hi': 'छह-पक्षीय पासे पर 2 से बड़ी संख्या घुमाना'}),
        GameCard(id: 's3c4', targetZone: 4, emoji: '📅', text: {'en': 'The day straight after Monday is Tuesday', 'hi': 'सोमवार के ठीक बाद का दिन मंगलवार है'}),
      ]
    ),
  ];

  final Map<String, Map<String, String>> _text = {
    'en': {
      'title': "Event Ranking Rally", 'sub': "Class 9 • The Mathematics of Maybe — Introduction to Probability",
      'start': "Start Mission", 'prev': "Prev", 'next': "Next", 'hint': "Hint", 'submit': "Submit",
      'scale_title': "Probability Scale · 0 = Impossible → 1 = Certain",
      'z0': "Impossible", 'z1': "Unlikely", 'z2': "Even Chance", 'z3': "Likely", 'z4': "Certain",
      'board_title': "Teacher Board", 'mission': "Mission Objective",
      'mission_txt': "Interpret and classify probability values by linking real-world events to positions on a 0-to-1 scale, from impossible to certain.",
      'steps': "Instruction Sequence",
      'hint_title': "Hint / Evidence", 
      'learnt_title': "Learnt Conclusion", 'learnt_txt': "Every event has a probability between 0 and 1. Impossible = 0, certain = 1, and everything else — unlikely, even chance, likely — sits in between. The more likely an event, the further right it belongs.",
      'tray_empty': "All cards placed on the scale ↓",
      'st_0': "Read each event card in the panel.", 'st_1': "Drag every card to its likelihood zone on the 0-to-1 scale.", 'st_2': "Press Submit to check your ranking for this round.",
      'panel_title': "Round {n}: {title} · Drag each card onto the scale",
      'err_place_all': "Place all 5 event cards on the scale before validating.",
      'pass_title': "Round Cleared!", 'pass_sub': "All events in this round are ranked correctly. Advance to the next round!",
      'win_title': "Rally Champion!", 'win_sub': "You ranked every event correctly across all three rounds.",
      'fail_title': "Keep Ranking", 'fail_sub': "Some events need reconsideration — your placements are kept, adjust and validate again.",
      'close_rep': "Close Report", 'restart_exp': "Restart Exploration", 'reset': 'Reset'
    },
    'hi': {
      'title': "इवेंट रैंकिंग रैली", 'sub': "कक्षा 9 • शायद का गणित — प्रायिकता का परिचय",
      'start': "मिशन शुरू करें", 'prev': "पिछला", 'next': "अगला", 'hint': "संकेत", 'submit': "जमा करें",
      'scale_title': "प्रायिकता पैमाना · 0 = असंभव → 1 = निश्चित",
      'z0': "असंभव", 'z1': "असंभाव्य", 'z2': "समान अवसर", 'z3': "संभाव्य", 'z4': "निश्चित",
      'board_title': "शिक्षक बोर्ड", 'mission': "मिशन का उद्देश्य",
      'mission_txt': "वास्तविक दुनिया की घटनाओं को 0-से-1 पैमाने पर असंभव से निश्चित तक जोड़कर संभावना मानों की व्याख्या और वर्गीकरण करें।",
      'steps': "अनुदेश अनुक्रम",
      'hint_title': "संकेत / साक्ष्य", 
      'learnt_title': "सीखा हुआ निष्कर्ष", 'learnt_txt': "प्रत्येक घटना की संभावना 0 और 1 के बीच होती है। असंभव = 0, निश्चित = 1, और बाकी सब कुछ बीच में बैठता है। घटना जितनी अधिक संभाव्य होगी, वह उतनी ही दाईं ओर होगी।",
      'tray_empty': "सभी कार्ड पैमाने पर रखे गए हैं ↓",
      'st_0': "पैनल में प्रत्येक इवेंट कार्ड पढ़ें।", 'st_1': "प्रत्येक कार्ड को 0-से-1 पैमाने पर उसके संभावना क्षेत्र में खींचें।", 'st_2': "इस राउंड के लिए अपनी रैंकिंग जांचने के लिए सबमिट दबाएं।",
      'panel_title': "राउंड {n}: {title} · प्रत्येक कार्ड को पैमाने पर खींचें",
      'err_place_all': "सत्यापित करने से पहले पैमाने पर सभी 5 कार्ड रखें।",
      'pass_title': "राउंड साफ़!", 'pass_sub': "इस राउंड में सभी घटनाओं को सही ढंग से रैंक किया गया है। अगले राउंड में आगे बढ़ें!",
      'win_title': "रैली चैंपियन!", 'win_sub': "आपने तीनों राउंड में प्रत्येक घटना को सही ढंग से रैंक किया।",
      'fail_title': "रैंकिंग जारी रखें", 'fail_sub': "कुछ घटनाओं पर पुनर्विचार की आवश्यकता है - आपके स्थान रखे गए हैं, समायोजित करें और पुनः प्रयास करें।",
      'close_rep': "रिपोर्ट बंद करें", 'restart_exp': "पुनः अन्वेषण शुरू करें", 'reset': 'रीसेट'
    }
  };

  final List<List<String>> _hintsEn = [
    ["Anchor the extremes first: the impossible event goes to 0 (far left), the certain event to 1 (far right).", "A rolled 8 cannot happen on a six-sided die — that is impossible (0).", "A fair coin has an even chance of Heads — it belongs on 0.5 in the middle."],
    ["A fish climbing a tree by itself never happens — that is impossible (0).", "Winning with 1 ticket out of 100 is possible but unlikely (near 0.25).", "Something that always happens, like water feeling wet, is certain (1)."],
    ["Textbook rule: impossible = 0, certain = 1. Sort those two first.", "A total of 12 needs both dice to show 6 — only 1 way out of 36, so it is unlikely.", "Rolling a number greater than 2 means 3,4,5 or 6 — that is 4 of 6, so it is likely (0.75)."]
  ];

  final List<List<String>> _hintsHi = [
    ["पहले चरम सीमाओं को लंगर डालें: असंभव घटना 0 (सबसे बाईं ओर) पर जाती है, निश्चित घटना 1 (सबसे दाईं ओर)।", "छह-तरफा पासे पर 8 आना असंभव है (0)।", "एक निष्पक्ष सिक्के में चित आने का समान अवसर है - यह बीच में 0.5 पर है।"],
    ["मछली का अपने आप पेड़ पर चढ़ना कभी नहीं होता - यह असंभव है (0)।", "100 में से 1 टिकट के साथ जीतना संभव है लेकिन असंभाव्य है (0.25 के करीब)।", "कुछ ऐसा जो हमेशा होता है, जैसे पानी का गीला लगना, निश्चित है (1)।"],
    ["पाठ्यपुस्तक नियम: असंभव = 0, निश्चित = 1। पहले उन दोनों को क्रमबद्ध करें।", "कुल 12 के लिए दोनों पासों पर 6 आना चाहिए - 36 में से केवल 1 तरीका, इसलिए यह असंभाव्य है।", "पासे पर 2 से बड़ी संख्या का मतलब 3,4,5 या 6 है - यह 6 में से 4 है, इसलिए यह संभाव्य है (0.75)।"]
  ];

  String t(String key) => _text[_language]?[key] ?? _text['en']?[key] ?? key;
  
  String getHint() {
    List<List<String>> src = _language == 'hi' ? _hintsHi : _hintsEn;
    return src[_activeScenario][_hintIdx % src[_activeScenario].length];
  }

  @override
  void initState() {
    super.initState();
    // Force Landscape Layout for the activity
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });

    _shutterController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _shutterAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1)).animate(
      CurvedAnimation(parent: _shutterController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer1.dispose();
    _sfxPlayer2.dispose();
    _shutterController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playClick() { _sfxPlayer1.play(AssetSource(sfxClick), volume: 1.0); }
  void _playSnap() { _sfxPlayer1.play(AssetSource(sfxClick), volume: 1.0); }
  void _playSuccess() { _sfxPlayer2.play(AssetSource(sfxSuccess), volume: 1.0); }
  void _playError() { _sfxPlayer2.play(AssetSource(sfxError), volume: 1.0); }

  void _startMission() {
    _sfxPlayer1.play(AssetSource(sfxShutter), volume: 1.0);
    _playSuccess(); // Audio when entering the lab
    _shutterController.forward().then((_) {
      setState(() => _hasStarted = true);
    });
  }

  void _doReset() {
    _playClick();
    setState(() {
      _language = 'en';
      _activeScenario = 0;
      _hintIdx = 0;
      _placements = [{}, {}, {}];
      _passed = [false, false, false];
      _showReport = false;
      _hasStarted = false;
    });
    _shutterController.reset();
  }

  void _loadScenario(int index) {
    if (index < 0 || index >= _scenarios.length) return;
    _playClick();
    setState(() {
      _activeScenario = index;
      _hintIdx = 0;
    });
  }

  void _validateInvestigation() {
    _playClick();
    final st = _placements[_activeScenario];
    final def = _scenarios[_activeScenario];
    
    if (st.length < 5) {
      _playError();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t('err_place_all'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ));
      return;
    }

    int correct = 0;
    for (var c in def.cards) {
      if (st[c.id] == c.targetZone) correct++;
    }

    setState(() {
      if (correct == 5) {
        _passed[_activeScenario] = true;
        bool allPassed = _passed.every((p) => p);
        
        _flashSuccess = true;
        _flashTitle = allPassed ? t('win_title') : t('pass_title');
        _flashDesc = allPassed ? t('win_sub') : t('pass_sub');
        _flashFeedback = "5/5 Placements Correct";
        _showReport = true;
        _playSuccess();
      } else {
        _flashSuccess = false;
        _flashTitle = t('fail_title');
        _flashDesc = t('fail_sub');
        _flashFeedback = "$correct/5 Placements Correct. Review your reasoning.";
        _showReport = true;
        _playError();
      }
    });
  }

  void _onCardDropped(GameCard card, int zoneIndex) {
    _playSnap();
    setState(() {
      _placements[_activeScenario][card.id] = zoneIndex;
    });
  }

  void _onCardRemoved(GameCard card) {
    _playSnap();
    setState(() {
      _placements[_activeScenario].remove(card.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background grid
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: GridPainter(),
              ),
            ),
          ),
          
          if (_hasStarted)
            Row(
              children: [
                // Sidebar (38%)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isSidebarOpen ? MediaQuery.of(context).size.width * 0.38 : 0,
                  child: _isSidebarOpen ? _buildSidebar() : const SizedBox.shrink(),
                ),
                
                // Main Canvas (62%)
                Expanded(
                  child: _buildCanvas(),
                ),
              ],
            ),
            
          // Control Toolbar / HUD (Bottom Center of Canvas)
          if (_hasStarted && !_showReport)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: 40,
              left: (_isSidebarOpen ? MediaQuery.of(context).size.width * 0.38 : 0) + 32,
              right: 32,
              child: _buildHUD(),
            ),

          // Floating Menu Button (Top Left)
          if (_hasStarted)
            Positioned(
              top: 16, left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xD81E293B),
                onPressed: () {
                  _playClick();
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                },
                child: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu, color: Colors.white),
              ),
            ),

          // Flash Feedback Overlay
          if (_showReport) _buildReportOverlay(),

          // Shutter Screen
          if (!_hasStarted)
            SlideTransition(
              position: _shutterAnimation,
              child: _buildShutterScreen(),
            ),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    bool canNext = _passed[_activeScenario] && _activeScenario < _scenarios.length - 1;
    bool canPrev = _activeScenario > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xD81E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Opacity(
                opacity: canPrev ? 1.0 : 0.5,
                child: TextButton.icon(
                  onPressed: canPrev ? () => _loadScenario(_activeScenario - 1) : null,
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  label: Text(t('prev'), style: const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: canNext ? 1.0 : 0.5,
                child: TextButton.icon(
                  onPressed: canNext ? () => _loadScenario(_activeScenario + 1) : null,
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  label: Text(t('next'), style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  _playClick();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(getHint(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.blueAccent,
                    duration: const Duration(seconds: 4),
                  ));
                  setState(() => _hintIdx++);
                },
                icon: const Icon(Icons.lightbulb, color: Colors.yellowAccent),
                label: Text(t('hint'), style: const TextStyle(color: Colors.yellowAccent)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.yellowAccent)),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _validateInvestigation,
                icon: const Icon(Icons.check),
                label: Text(t('submit').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShutterScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF020617), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.leaderboard, size: 80, color: Colors.orangeAccent),
            const SizedBox(height: 24),
            Text(
              t('title').toUpperCase(),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              t('sub'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _startMission,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                elevation: 10,
              ),
              child: Text(t('start').toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xD80F172A),
        border: Border(right: BorderSide(color: Colors.white12)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(left: 64, top: 16, bottom: 16, right: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12)),
                color: Colors.black26,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.orange, Colors.amber]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.leaderboard, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('title').toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text(t('sub').toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.language, size: 16), color: Colors.white,
                          onPressed: () {
                            _playClick();
                            setState(() => _language = _language == 'en' ? 'hi' : 'en');
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Text(_language.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _doReset,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(t('reset'), style: const TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Scenario Select
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _activeScenario,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E293B),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    onChanged: (val) {
                      if (val != null) _loadScenario(val);
                    },
                    items: List.generate(_scenarios.length, (i) {
                      String rTitle = _scenarios[i].title[_language] ?? _scenarios[i].title['en']!;
                      return DropdownMenuItem(
                        value: i,
                        child: Text("Round ${i+1}: $rTitle", overflow: TextOverflow.ellipsis),
                      );
                    }),
                  ),
                ),
              ),
            ),
            
            // Teacher Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildContentCard(Icons.my_location, t('mission'), t('mission_txt'), Colors.orange),
                  const SizedBox(height: 16),
                  
                  // Steps
                  Text(t('steps'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                  const SizedBox(height: 8),
                  _buildStep(0, t('st_0')),
                  _buildStep(1, t('st_1')),
                  _buildStep(2, t('st_2')),
                  
                  const SizedBox(height: 16),
                  _buildContentCard(Icons.lightbulb, t('hint_title'), getHint(), Colors.blue),
                  const SizedBox(height: 16),
                  _buildContentCard(Icons.school, t('learnt_title'), t('learnt_txt'), Colors.purple),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int index, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2, right: 8),
            width: 20, height: 20,
            decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildContentCard(IconData icon, String title, String body, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color.shade400),
              const SizedBox(width: 8),
              Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color.shade400, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    final scenario = _scenarios[_activeScenario];
    final titleRaw = scenario.title[_language] ?? scenario.title['en']!;
    final panelTitle = t('panel_title').replaceAll('{n}', '${_activeScenario+1}').replaceAll('{title}', titleRaw);

    // Filter unplaced cards
    List<GameCard> unplacedCards = scenario.cards.where((c) => !_placements[_activeScenario].containsKey(c.id)).toList();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Top Cards Panel
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xD80F172A),
                    border: Border.all(color: Colors.white12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(panelTitle, style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 12),
                      
                      DragTarget<GameCard>(
                        onWillAccept: (data) => data != null,
                        onAccept: (data) => _onCardRemoved(data),
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            constraints: const BoxConstraints(minHeight: 80),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: candidateData.isNotEmpty ? Colors.orangeAccent : Colors.transparent, style: BorderStyle.solid, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: unplacedCards.isEmpty
                                ? Center(child: Text(t('tray_empty'), style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)))
                                : Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: unplacedCards.map((c) => _buildDraggableCard(c)).toList(),
                                  ),
                          );
                        }
                      ),
                    ],
                  ),
                ),

                // Probability Scale Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(t('scale_title'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Scale Bar Visual
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF475569), Color(0xFF64748B), Color(0xFFF59E0B), Color(0xFFFB923C), Color(0xFFF97316)]),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildTick(0.0), _buildTick(0.25), _buildTick(0.5), _buildTick(0.75), _buildTick(1.0),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Drop Zones
                      SizedBox(
                        height: 250,
                        child: Row(
                          children: [
                            _buildDropZone(0, '0', t('z0')),
                            _buildDropZone(1, '0.25', t('z1')),
                            _buildDropZone(2, '0.5', t('z2')),
                            _buildDropZone(3, '0.75', t('z3')),
                            _buildDropZone(4, '1', t('z4')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100), // Space for HUD
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Footer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xD80F172A),
            border: Border(top: BorderSide(color: Colors.white12))
          ),
          child: const Text(
            '© ZEROSCIENCELAB | Fall in Love with Math and Science',
            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildTick(double alignX) {
    // alignX: 0.0 to 1.0 -> Alignment(-1.0, 0.0) to Alignment(1.0, 0.0)
    final double mappedAlign = (alignX * 2) - 1;
    return Align(
      alignment: Alignment(mappedAlign, 0),
      child: Container(
        width: 14, height: 14,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF0F172A), width: 3),
        ),
      ),
    );
  }

  Widget _buildDropZone(int zoneIndex, String valLabel, String textLabel) {
    final scenario = _scenarios[_activeScenario];
    
    // Find cards placed in this zone
    List<GameCard> placedCards = scenario.cards.where((c) => _placements[_activeScenario][c.id] == zoneIndex).toList();

    return Expanded(
      child: DragTarget<GameCard>(
        onWillAccept: (data) => data != null,
        onAccept: (data) => _onCardDropped(data, zoneIndex),
        builder: (context, candidateData, rejectedData) {
          bool isHovered = candidateData.isNotEmpty;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHovered ? Colors.orange.withOpacity(0.15) : const Color(0xCC1E293B),
              border: Border.all(
                color: isHovered ? Colors.white : Colors.white24,
                width: 2,
                style: isHovered ? BorderStyle.solid : BorderStyle.none,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(valLabel, style: const TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.w900, fontSize: 13)),
                      ),
                      const SizedBox(height: 4),
                      Text(textLabel.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: placedCards.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: _buildDraggableCard(c, isPlaced: true),
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDraggableCard(GameCard card, {bool isPlaced = false}) {
    String cardText = card.text[_language] ?? card.text['en']!;
    
    Widget cardVisual = Container(
      width: isPlaced ? double.infinity : 220,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPlaced ? [const Color(0xFF334155), const Color(0xFF1E293B)] : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        border: Border.all(color: isPlaced ? Colors.white30 : Colors.orangeAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(card.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(child: Text(cardText, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, height: 1.2))),
        ],
      ),
    );

    return Draggable<GameCard>(
      data: card,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.rotate(
          angle: -0.05,
          child: Opacity(opacity: 0.9, child: cardVisual),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: cardVisual),
      onDragStarted: () => _sfxPlayer1.play(AssetSource('audio/class9/click.mp3')), // tiny lift sound
      child: cardVisual,
    );
  }

  Widget _buildReportOverlay() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xD80F172A),
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_flashSuccess ? Icons.check_circle : Icons.warning_rounded, color: _flashSuccess ? Colors.greenAccent : Colors.orangeAccent, size: 64),
            const SizedBox(height: 16),
            Text(_flashTitle.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(_flashDesc, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white12)),
              child: Row(
                children: [
                  Icon(_flashSuccess ? Icons.check : Icons.close, color: _flashSuccess ? Colors.greenAccent : Colors.orangeAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_flashFeedback, style: TextStyle(color: _flashSuccess ? Colors.greenAccent : Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12))),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _playClick();
                  setState(() => _showReport = false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(t('close_rep'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            if (_flashSuccess && _passed.every((p) => p))
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _doReset,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(t('restart_exp').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Background Grid Pattern
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;
    
    double step = 30;
    for (double i = 0; i < size.width; i += step) {
      for (double j = 0; j < size.height; j += step) {
        canvas.drawCircle(Offset(i, j), 1, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
