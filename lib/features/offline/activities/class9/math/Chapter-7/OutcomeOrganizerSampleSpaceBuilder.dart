// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OutcomeOrganizerSampleSpaceBuilder(),
    ),
  );
}

class OutcomeOrganizerSampleSpaceBuilder extends StatefulWidget {
  const OutcomeOrganizerSampleSpaceBuilder({super.key});

  @override
  State<OutcomeOrganizerSampleSpaceBuilder> createState() =>
      _OutcomeOrganizerSampleSpaceBuilderState();
}

class _OutcomeOrganizerSampleSpaceBuilderState
    extends State<OutcomeOrganizerSampleSpaceBuilder>
    with TickerProviderStateMixin {
  // === State Variables ===
  bool _hasStarted = false;
  bool _isSidebarOpen = true;
  String _language = 'en';

  int _activePhase = 0; // 0: 1 coin SS, 1: 2 coin SS, 2: Event Subset

  // Drag and drop state
  final List<String> _pool1 = ['H', 'T', 'Edge'];
  final List<String> _pool2 = ['HH', 'HT', 'TH', 'TT', 'HHH', 'T'];

  List<String?> _slots1 = [null, null]; // 2 slots for 1 coin
  List<String?> _slots2 = [null, null, null, null]; // 4 slots for 2 coins

  final Set<int> _eventSubsetSelection = {}; // Selected indices from _slots2

  // Modals
  bool _showReport = false;
  bool _flashSuccess = false;
  String _flashTitle = '';
  String _flashDesc = '';
  String _flashFeedback = '';

  // Audio Players
  final AudioPlayer _sfxPlayer1 = AudioPlayer();
  final AudioPlayer _sfxPlayer2 = AudioPlayer();
  final String sfxClick =
      'audio/class9/click.mp3';
  final String sfxShutter =
      'audio/class9/shutter.mp3';
  final String sfxSuccess =
      'audio/class9/success.mp3';
  final String sfxError =
      'audio/class9/error.mp3';

  late AnimationController _shutterController;
  late Animation<Offset> _shutterAnimation;

  final Map<String, Map<String, String>> _text = {
    'en': {
      'app_title': "Outcome Organizer: Sample Space Builder",
      'tagline':
          "Class 9 • The Mathematics of Maybe — Introduction to Probability",
      'init_btn': "START MISSION",
      'board_title': "Teacher Guide",
      'obj_label': "Mission Objective",
      'scenario_label': "Scenario",
      'notation_label': "Set Notation",
      'steps_label': "Instruction Sequence",
      'hint_label': "Hint / Evidence",
      'conc_label': "Learnt Conclusion",
      'scen_0': "Scenario 1 · One-Coin Sample Space",
      'scen_1': "Scenario 2 · Two Coins & Event Subset",
      'lbl_placed': "Outcomes placed:",
      'event_title': "Event Subset",
      'btn_hint': "Hint",
      'btn_submit_ss': "Submit Sample Space",
      'btn_submit_ev': "Submit Event",
      'btn_report': "Report",
      'btn_close_report': "Close Report",
      'btn_restart_exp': "Restart Exploration",
      'reset': "Reset",
      'obj_desc':
          "List complete sample spaces for simple experiments, then identify an event as a subset of the sample space using set notation.",
      'conc_desc':
          "The sample space S is the foundational set containing every possible outcome of an experiment, with no duplicates and no missing elements. An event is defined as any valid subset of S. For a two-coin experiment, the complete sample space is S = {HH, HT, TH, TT}. When we define an event such as 'getting at least one head', we extract the specific outcomes that satisfy this condition, resulting in the subset E = {HH, HT, TH}. This relationship is formally written as E ⊆ S, demonstrating how probability relies on set theory.",
      'hint_desc':
          "Ask students to name every possible outcome before dragging. A sample space must have no missing outcome and no repeats.",
      'ph0_t': "One-Coin Sample Space",
      'ph1_t': "Two-Coin Sample Space",
      'ph2_t': "Event: At Least One Head",
      'ph0_st': "Available Outcomes · One Coin",
      'ph1_st': "Available Outcomes · Two Coins",
      'ph0_sd':
          "Drag the outcomes of a single coin toss into the sample space. Avoid repeats and impossible outcomes.",
      'ph1_sd':
          "Drag every ordered outcome of two coins into the 2×2 grid. Reject repeats and impossible outcomes.",
      'ph0_m':
          "S is the set of every outcome of one coin toss — no missing, no repeats.",
      'ph1_m':
          "S is the set of all ordered outcomes of two coins arranged in a 2×2 grid.",
      's0_1': "Read the one-coin experiment.",
      's0_2': "Drag Heads into the sample space.",
      's0_3': "Drag Tails into the sample space.",
      's0_4':
          "Submit to check the sample space (no missing, no repeats, no impossible outcome).",
      's1_1': "Study the two-coin experiment.",
      's1_2': "Drag every ordered outcome HH, HT, TH, TT into the grid.",
      's1_3': "Avoid repeats and impossible outcomes such as HHH.",
      's1_4': "Submit to check the full sample space.",
      's2_1': "Recall S = {HH, HT, TH, TT}.",
      's2_2': "Tap each outcome that has at least one head.",
      's2_3': "Leave out TT — it has no head.",
      's2_4': "Submit to check the event subset E ⊆ S.",
      'msg_c0':
          "Correct sample space for one coin toss! Sample space listed with no repeats.",
      'msg_c1':
          "Correct! S = {HH, HT, TH, TT} is the complete two-coin sample space.",
      'h_0':
          "A single coin can only land two ways. Drag exactly Heads and Tails — nothing else, and no repeats. \"Edge\" is not a real outcome here.",
      'h_1':
          "Two coins give ordered pairs: first coin, then second coin. The four outcomes are HH, HT, TH and TT.",
      'h_2':
          "\"At least one head\" means one or more H letters. HH, HT and TH all contain an H. TT has no head, so it stays out of the event.",
      'diag_observation': "Observation",
      'diag_pass':
          "You built complete sample spaces and defined an event as a subset.",
      'diag_fail':
          "Some outcomes or the event subset still need work — your tiles are kept, adjust and resubmit.",
      'prev': "Prev",
      'next': "Next",
      'pool_title': "Available Outcomes",
      'pool_sub': "Drag each outcome tile into the sample space on the right.",
      'space_title': "Sample Space",
      'space_sub':
          "The sample space S is the set of every possible outcome — no missing, no repeats.",
      'event_lock':
          "Unlocks in Scenario 2. First build the two-coin sample space, then define an event as a subset of it.",
      'event_sub_desc':
          "An event is a subset of the sample space. Select the outcomes of event E below.",
      'event_def': "Event E: at least one head.",
      'err_inc': "Incomplete or incorrect sample space.",
      'err_ev': "Incorrect event subset selection.",
    },
    'hi': {
      'app_title': "परिणाम आयोजक: नमूना स्थान निर्माता",
      'tagline': "कक्षा 9 • अध्याय 7: संभावनाओं का गणित — प्रायिकता का परिचय",
      'init_btn': "मिशन शुरू करें",
      'board_title': "शिक्षक मार्गदर्शिका",
      'obj_label': "मिशन का उद्देश्य",
      'scenario_label': "परिदृश्य",
      'notation_label': "सेट नोटेशन",
      'steps_label': "निर्देश अनुक्रम",
      'hint_label': "संकेत / साक्ष्य",
      'conc_label': "निष्कर्ष",
      'scen_0': "परिदृश्य 1 · एक सिक्के का नमूना स्थान",
      'scen_1': "परिदृश्य 2 · दो सिक्के और घटना उपसमुच्चय",
      'lbl_placed': "रखे गए परिणाम:",
      'event_title': "घटना उपसमुच्चय",
      'btn_hint': "संकेत",
      'btn_submit_ss': "नमूना स्थान सबमिट करें",
      'btn_submit_ev': "घटना सबमिट करें",
      'btn_report': "रिपोर्ट",
      'btn_close_report': "रिपोर्ट बंद करें",
      'btn_restart_exp': "पुनः अन्वेषण करें",
      'reset': "रीसेट",
      'obj_desc':
          "सरल प्रयोगों के लिए पूर्ण नमूना स्थान सूचीबद्ध करें, फिर सेट नोटेशन का उपयोग करके घटना को उपसमुच्चय के रूप में पहचानें।",
      'conc_desc':
          "नमूना स्थान S एक प्रयोग के सभी संभावित परिणामों वाला एक मूलभूत सेट है, जिसमें कोई दोहराव और कोई भी तत्व गायब नहीं होता है। एक घटना को S के किसी भी वैध उपसमुच्चय के रूप में परिभाषित किया जाता है। दो सिक्कों के प्रयोग के लिए, पूर्ण नमूना स्थान S = {HH, HT, TH, TT} है। जब हम 'कम से कम एक चित' जैसी घटना को परिभाषित करते हैं, तो हम उन विशिष्ट परिणामों को निकालते हैं जो इस शर्त को पूरा करते हैं, जिसके परिणामस्वरूप उपसमुच्चय E = {HH, HT, TH} बनता है। यह संबंध औपचारिक रूप से E ⊆ S के रूप में लिखा जाता है, जो दर्शाता है कि प्रायिकता सेट सिद्धांत पर कैसे निर्भर करती है।",
      'hint_desc':
          "खींचने से पहले छात्रों को हर संभव परिणाम बताने के लिए कहें। नमूना स्थान में कोई भी परिणाम छूटना या दोहराया नहीं जाना चाहिए।",
      'ph0_t': "एक सिक्के का नमूना स्थान",
      'ph1_t': "दो सिक्कों का नमूना स्थान",
      'ph2_t': "घटना: कम से कम एक चित",
      'ph0_st': "उपलब्ध परिणाम · एक सिक्का",
      'ph1_st': "उपलब्ध परिणाम · दो सिक्के",
      'ph0_sd':
          "एक सिक्के के उछाल के परिणामों को नमूना स्थान में खींचें। दोहराव और असंभव परिणामों से बचें।",
      'ph1_sd':
          "दो सिक्कों के हर क्रमित परिणाम को 2×2 ग्रिड में खींचें। दोहराव और असंभव परिणामों को अस्वीकार करें।",
      'ph0_m':
          "S एक सिक्के के उछाल के प्रत्येक परिणाम का सेट है — कोई गायब नहीं, कोई दोहराव नहीं।",
      'ph1_m':
          "S 2×2 ग्रिड में व्यवस्थित दो सिक्कों के सभी क्रमित परिणामों का सेट है।",
      's0_1': "एक-सिक्का प्रयोग पढ़ें।",
      's0_2': "चित (Heads) को नमूना स्थान में खींचें।",
      's0_3': "पट (Tails) को नमूना स्थान में खींचें।",
      's0_4':
          "नमूना स्थान की जांच के लिए सबमिट करें (कोई गायब नहीं, कोई दोहराव नहीं, कोई असंभव परिणाम नहीं)।",
      's1_1': "दो-सिक्के प्रयोग का अध्ययन करें।",
      's1_2': "प्रत्येक क्रमित परिणाम HH, HT, TH, TT को ग्रिड में खींचें।",
      's1_3': "दोहराव और HHH जैसे असंभव परिणामों से बचें।",
      's1_4': "पूर्ण नमूना स्थान की जांच के लिए सबमिट करें।",
      's2_1': "S = {HH, HT, TH, TT} को याद करें।",
      's2_2': "कम से कम एक चित (Heads) वाले प्रत्येक परिणाम पर टैप करें।",
      's2_3': "TT को छोड़ दें — इसमें कोई चित नहीं है।",
      's2_4': "घटना उपसमुच्चय E ⊆ S की जांच के लिए सबमिट करें।",
      'msg_c0':
          "एक सिक्के के उछाल के लिए सही नमूना स्थान! नमूना स्थान बिना किसी दोहराव के सूचीबद्ध है।",
      'msg_c1': "सही! S = {HH, HT, TH, TT} पूर्ण दो-सिक्कों का नमूना स्थान है।",
      'h_0':
          "एक सिक्का केवल दो तरह से गिर सकता है। ठीक चित और पट खींचें — और कुछ नहीं, और कोई दोहराव नहीं। \"Edge\" यहाँ कोई वास्तविक परिणाम नहीं है।",
      'h_1':
          "दो सिक्के क्रमित जोड़े देते हैं: पहला सिक्का, फिर दूसरा सिक्का। चार परिणाम HH, HT, TH और TT हैं।",
      'h_2':
          "'कम से कम एक चित' का अर्थ है एक या अधिक H अक्षर। HH, HT और TH सभी में एक H होता है। TT में कोई चित नहीं है, इसलिए यह घटना से बाहर रहता है।",
      'diag_observation': "अवलोकन",
      'diag_pass':
          "आपने पूर्ण नमूना स्थान बनाए और घटना को एक उपसमुच्चय के रूप में परिभाषित किया।",
      'diag_fail':
          "कुछ परिणामों या घटना उपसमुच्चय पर अभी भी काम करने की आवश्यकता है — आपकी टाइलें सुरक्षित हैं, समायोजित करें और पुनः सबमिट करें।",
      'prev': "पिछला",
      'next': "अगला",
      'pool_title': "उपलब्ध परिणाम",
      'pool_sub': "प्रत्येक परिणाम टाइल को दाईं ओर नमूना स्थान में खींचें।",
      'space_title': "नमूना स्थान",
      'space_sub':
          "नमूना स्थान S हर संभव परिणाम का सेट है — कोई गायब नहीं, कोई दोहराव नहीं।",
      'event_lock':
          "परिदृश्य 2 में अनलॉक होता है। पहले दो-सिक्के का नमूना स्थान बनाएं, फिर एक घटना को इसके उपसमुच्चय के रूप में परिभाषित करें।",
      'event_sub_desc':
          "एक घटना नमूना स्थान का उपसमुच्चय है। नीचे घटना E के परिणामों का चयन करें।",
      'event_def': "घटना E: कम से कम एक चित।",
      'err_inc': "अपूर्ण या गलत नमूना स्थान।",
      'err_ev': "गलत घटना उपसमुच्चय चयन।",
    },
  };

  String t(String key) => _text[_language]?[key] ?? _text['en']?[key] ?? key;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });

    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _shutterAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(
      CurvedAnimation(parent: _shutterController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _sfxPlayer1.dispose();
    _sfxPlayer2.dispose();
    _shutterController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playClick() {
    _sfxPlayer1.play(AssetSource(sfxClick), volume: 1.0);
  }

  void _playSuccess() {
    _sfxPlayer2.play(AssetSource(sfxSuccess), volume: 1.0);
  }

  void _playError() {
    _sfxPlayer2.play(AssetSource(sfxError), volume: 1.0);
  }

  void _startMission() {
    _sfxPlayer1.play(AssetSource(sfxShutter), volume: 1.0);
    _playSuccess();
    _shutterController.forward().then((_) {
      setState(() => _hasStarted = true);
    });
  }

  void _doReset() {
    _playClick();
    setState(() {
      _language = 'en';
      _hasStarted = false;
      _slots1 = [null, null];
      _slots2 = [null, null, null, null];
      _eventSubsetSelection.clear();
      _activePhase = 0;
      _showReport = false;
    });
    _shutterController.reverse();
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _submitPhase() {
    if (_activePhase == 0) {
      // 1 Coin SS Check
      if (_slots1.contains(null) ||
          !_slots1.contains('H') ||
          !_slots1.contains('T')) {
        _playError();
        _showSnack(t('err_inc'), Colors.redAccent);
      } else {
        _playSuccess();
        _showSnack(t('msg_c0'), Colors.green);
        setState(() {
          _activePhase = 1;
        });
      }
    } else if (_activePhase == 1) {
      // 2 Coin SS Check
      List<String> required = ['HH', 'HT', 'TH', 'TT'];
      bool hasAll = true;
      for (String r in required) {
        if (!_slots2.contains(r)) hasAll = false;
      }
      if (_slots2.contains(null) || !hasAll) {
        _playError();
        _showSnack(t('err_inc'), Colors.redAccent);
      } else {
        _playSuccess();
        _showSnack(t('msg_c1'), Colors.green);
        setState(() {
          _activePhase = 2;
        });
      }
    } else if (_activePhase == 2) {
      // Event Subset Check (At least one Head: HH, HT, TH)
      List<String> selected =
          _eventSubsetSelection.map((i) => _slots2[i]!).toList();

      bool correct =
          selected.length == 3 &&
          selected.contains('HH') &&
          selected.contains('HT') &&
          selected.contains('TH');

      if (correct) {
        _playSuccess();
        setState(() {
          _flashSuccess = true;
          _flashTitle = t('diag_pass');
          _flashDesc = t('diag_observation');
          _flashFeedback =
              "S = {HH, HT, TH, TT} and E = {HH, HT, TH} where E ⊆ S";
          _showReport = true;
        });
      } else {
        _playError();
        _showSnack(t('err_ev'), Colors.orangeAccent);
      }
    }
  }

  Widget _buildTile(
    String label, {
    bool isDragging = false,
    bool isSelected = false,
  }) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isSelected
                  ? [const Color(0xFFE2761F), const Color(0xFFB8560F)]
                  : [const Color(0xFF123A72), const Color(0xFF0D2A56)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isSelected ? Colors.orangeAccent : Colors.white24,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDragging ? Colors.black54 : Colors.black26,
            blurRadius: isDragging ? 15 : 5,
            spreadRadius: isDragging ? 2 : 0,
            offset: Offset(0, isDragging ? 8 : 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildHUD() {
    String btnLabel = t('btn_submit_ss');
    if (_activePhase == 2) btnLabel = t('btn_submit_ev');

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
              Text(
                t('prev'),
                style: const TextStyle(color: Colors.transparent),
              ),
              const SizedBox(width: 8),
              Text(
                "Phase ${_activePhase + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        t('h_$_activePhase'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.blueAccent,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
                icon: const Icon(Icons.lightbulb, color: Colors.yellowAccent),
                label: Text(
                  t('btn_hint'),
                  style: const TextStyle(color: Colors.yellowAccent),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.yellowAccent),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _submitPhase,
                icon: const Icon(Icons.check),
                label: Text(
                  btnLabel.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
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
              padding: const EdgeInsets.only(
                left: 64,
                top: 16,
                bottom: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12)),
                color: Colors.black26,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.amber],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.list_alt,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('app_title').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          t('tagline').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
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
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.language, size: 16),
                          color: Colors.white,
                          onPressed: () {
                            _playClick();
                            setState(
                              () => _language = _language == 'en' ? 'hi' : 'en',
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Text(
                            _language.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _doReset,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(
                      t('reset'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Teacher Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Teacher Guide Title
                  Row(
                    children: [
                      const Icon(Icons.school, color: Colors.white54, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        t('board_title').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 32),

                  _buildContentCard(
                    Icons.my_location,
                    t('obj_label'),
                    t('obj_desc'),
                    Colors.orange,
                  ),
                  const SizedBox(height: 16),

                  // Set Notation SVG replacement (CustomPainter)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('notation_label').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: CustomPaint(painter: SetNotationPainter()),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Steps
                  Text(
                    t('steps_label'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_activePhase == 0) ...[
                    _buildStep(0, t('s0_1')),
                    _buildStep(1, t('s0_2')),
                    _buildStep(2, t('s0_3')),
                    _buildStep(3, t('s0_4')),
                  ] else if (_activePhase == 1) ...[
                    _buildStep(0, t('s1_1')),
                    _buildStep(1, t('s1_2')),
                    _buildStep(2, t('s1_3')),
                    _buildStep(3, t('s1_4')),
                  ] else ...[
                    _buildStep(0, t('s2_1')),
                    _buildStep(1, t('s2_2')),
                    _buildStep(2, t('s2_3')),
                    _buildStep(3, t('s2_4')),
                  ],

                  const SizedBox(height: 16),
                  _buildContentCard(
                    Icons.lightbulb,
                    t('hint_label'),
                    t('hint_desc'),
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildContentCard(
                    Icons.school,
                    t('conc_label'),
                    t('conc_desc'),
                    Colors.purple,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xD80F172A),
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: const Text(
                '© ZEROSCIENCELAB | Fall in Love with Math and Science',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
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
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(
    IconData icon,
    String title,
    String body,
    MaterialColor color,
  ) {
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
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: color.shade400,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
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
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 48,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shape_line,
                    size: 80,
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t('app_title').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t('tagline'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _startMission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 10,
                    ),
                    child: Text(
                      t('init_btn').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportOverlay() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        width: 350,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xD80F172A),
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _flashSuccess ? Icons.check_circle : Icons.warning_rounded,
                color: _flashSuccess ? Colors.greenAccent : Colors.orangeAccent,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _flashTitle.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _flashDesc,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _flashSuccess ? Icons.check : Icons.close,
                      color:
                          _flashSuccess
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _flashFeedback,
                        style: TextStyle(
                          color:
                              _flashSuccess
                                  ? Colors.greenAccent
                                  : Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    t('btn_close_report'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (_flashSuccess)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _doReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          t('btn_restart_exp').toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPool() {
    List<String> pool = _activePhase == 0 ? _pool1 : _pool2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('pool_title'),
          style: const TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t('pool_sub'),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              pool.map((item) {
                return Draggable<String>(
                  data: item,
                  feedback: _buildTile(item, isDragging: true),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _buildTile(item),
                  ),
                  child: _buildTile(item),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSampleSpace() {
    List<String?> slots = _activePhase == 0 ? _slots1 : _slots2;
    int placed = slots.where((s) => s != null).length;
    int total = slots.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('space_title'),
          style: const TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t('space_sub'),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            const Text(
              'S = ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              '{',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 40,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(slots.length, (index) {
                  return DragTarget<String>(
                    onWillAcceptWithDetails: (data) => true,
                    onAcceptWithDetails: (details) {
                      _playClick();
                      setState(() {
                        if (_activePhase == 0) {
                          _slots1[index] = details.data;
                        } else {
                          _slots2[index] = details.data;
                        }
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      bool isHovered = candidateData.isNotEmpty;
                      String? content = slots[index];

                      return Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color:
                              isHovered
                                  ? Colors.orange.withOpacity(0.2)
                                  : (content != null
                                      ? Colors.transparent
                                      : Colors.orange.withOpacity(0.05)),
                          border: Border.all(
                            color:
                                isHovered
                                    ? Colors.orange
                                    : (content != null
                                        ? Colors.transparent
                                        : Colors.orange.withOpacity(0.5)),
                            width: 2,
                            style:
                                content != null
                                    ? BorderStyle.none
                                    : BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child:
                            content != null
                                ? Stack(
                                  children: [
                                    _buildTile(content),
                                    Positioned(
                                      top: -8,
                                      right: -8,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.cancel,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (_activePhase == 0) {
                                              _slots1[index] = null;
                                            } else {
                                              _slots2[index] = null;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                )
                                : const SizedBox.shrink(),
                      );
                    },
                  );
                }),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '}',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 40,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            "${t('lbl_placed')} $placed / $total",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventSubset() {
    if (_activePhase < 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          t('event_lock'),
          style: const TextStyle(color: Colors.white54, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }

    String subsetString = _eventSubsetSelection
        .map((i) => _slots2[i]!)
        .join(', ');
    if (subsetString.isEmpty) subsetString = '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('event_title'),
          style: const TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t('event_sub_desc'),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          t('event_def'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(_slots2.length, (index) {
            String label = _slots2[index]!;
            bool isSelected = _eventSubsetSelection.contains(index);
            return GestureDetector(
              onTap: () {
                _playClick();
                setState(() {
                  if (isSelected) {
                    _eventSubsetSelection.remove(index);
                  } else {
                    _eventSubsetSelection.add(index);
                  }
                });
              },
              child: _buildTile(label, isSelected: isSelected),
            );
          }),
        ),

        const Spacer(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              const Text(
                'E = { ',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  subsetString,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Text(
                ' }',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCanvas() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Col A: Pool (hide in phase 2)
                if (_activePhase < 2)
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xD80F172A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: _buildPool(),
                    ),
                  ),
                if (_activePhase < 2) const SizedBox(width: 16),

                // Col B: Sample Space (Always visible)
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xD80F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: _buildSampleSpace(),
                  ),
                ),

                // Col C: Event Subset (Phase 1 & 2)
                if (_activePhase >= 1) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xD80F172A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: _buildEventSubset(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          if (_hasStarted)
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width:
                      _isSidebarOpen
                          ? MediaQuery.of(context).size.width * 0.38
                          : 0,
                  child:
                      _isSidebarOpen
                          ? _buildSidebar()
                          : const SizedBox.shrink(),
                ),
                Expanded(child: _buildCanvas()),
              ],
            ),

          if (_hasStarted && !_showReport)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: 40,
              left:
                  (_isSidebarOpen
                      ? MediaQuery.of(context).size.width * 0.38
                      : 0) +
                  32,
              right: 32,
              child: _buildHUD(),
            ),

          if (_hasStarted)
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xD81E293B),
                onPressed: () {
                  _playClick();
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                },
                child: Icon(
                  _isSidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),

          if (_showReport) _buildReportOverlay(),

          if (!_hasStarted)
            SlideTransition(
              position: _shutterAnimation,
              child: _buildShutterScreen(),
            ),
        ],
      ),
    );
  }
}

class SetNotationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // S Ellipse
    final paintS =
        Paint()
          ..color = Colors.orangeAccent.withOpacity(0.1)
          ..style = PaintingStyle.fill;
    final borderS =
        Paint()
          ..color = Colors.orangeAccent
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // E Ellipse
    final paintE =
        Paint()
          ..color = Colors.yellowAccent.withOpacity(0.14)
          ..style = PaintingStyle.fill;
    final borderE =
        Paint()
          ..color = Colors.yellowAccent
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Draw S
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.9,
        height: size.height * 0.8,
      ),
      paintS,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.9,
        height: size.height * 0.8,
      ),
      borderS,
    );

    // Draw S Text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'S',
        style: TextStyle(
          color: Colors.orangeAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.05 + 5, size.height * 0.1));

    // Draw E
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.4, size.height * 0.5),
        width: size.width * 0.5,
        height: size.height * 0.5,
      ),
      paintE,
    );
    // Dashed border is tricky in vanilla canvas, we'll draw solid for now
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.4, size.height * 0.5),
        width: size.width * 0.5,
        height: size.height * 0.5,
      ),
      borderE,
    );

    // Draw E Text
    final textPainterE = TextPainter(
      text: const TextSpan(
        text: 'E',
        style: TextStyle(
          color: Colors.yellowAccent,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterE.layout();
    textPainterE.paint(
      canvas,
      Offset(size.width * 0.15 + 5, size.height * 0.35),
    );

    // Draw points (mocking HH, HT, TH, TT)
    final pointPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.5),
      4,
      pointPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.45, size.height * 0.4),
      4,
      pointPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.45, size.height * 0.6),
      4,
      pointPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.5),
      4,
      pointPaint,
    ); // Outside E

    // Label E subset S
    final textPainterSubset = TextPainter(
      text: const TextSpan(
        text: 'E ⊆ S',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterSubset.layout();
    textPainterSubset.paint(
      canvas,
      Offset(size.width * 0.55, size.height * 0.8),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
