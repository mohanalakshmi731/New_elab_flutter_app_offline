// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrialTesterApp(),
    ),
  );
}

class TrialTesterApp extends StatefulWidget {
  const TrialTesterApp({super.key});

  @override
  State<TrialTesterApp> createState() => _TrialTesterAppState();
}

class _TrialTesterAppState extends State<TrialTesterApp>
    with TickerProviderStateMixin {
  // === State Variables ===
  bool _hasStarted = false;
  bool _isSidebarOpen = true;
  String _language = 'en';

  int _activeScenario = 0; // 0: Dice, 1: Coin
  int _activePhase =
      0; // 0: Dice roll, 1: Exp P(4), 2: Theo P(4), 3: Coin toss, 4: Exp P(H)

  // Data
  final Random _rnd = Random();
  final List<int> _rolls = [];
  final List<String> _tosses = [];
  final int _targetRolls = 50;
  final int _targetTosses = 20;

  int _pendingRoll = 1;
  bool _isRolling = false;
  bool _isFlipping = false;

  String _calcInput = "";

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
  late AnimationController _coinAnimController;
  late Animation<double> _coinRotation;

  final Map<String, Map<String, String>> _text = {
    'en': {
      'app_title': "Trial Tester: Dice and Coin Quest",
      'tagline':
          "Class 9 • Chapter 7: The Mathematics of Maybe — Introduction to Probability",
      'init_btn': "START MISSION",
      'board_title': "Teacher Guide",
      'obj_label': "Mission Objective",
      'scenario_label': "Scenario",
      'steps_label': "Instruction Sequence",
      'hint_label': "Hint / Evidence",
      'conc_label': "Learnt Conclusion",
      'scen_0': "Scenario 1 · Die: Experimental vs Theoretical",
      'scen_1': "Scenario 2 · Coin Toss Experimental Probability",
      'sim_dice_title': "Scenario 1 · Virtual Dice Roller",
      'stat_rolls': "Rolls",
      'stat_target': "Target",
      'stat_fours': "Fours",
      'btn_roll': "Roll Die",
      'btn_record': "Record",
      'btn_batch': "Roll & Record ×10",
      'dice_instruction':
          "Press Roll Die, then Record to log the result. Reach 50 recorded rolls (use ×10 to go faster).",
      'sim_coin_title': "Scenario 2 · Virtual Coin Tosser",
      'stat_tosses': "Tosses",
      'stat_heads': "Heads",
      'stat_tails': "Tails",
      'btn_toss': "Toss Coin",
      'coin_instruction':
          "Tap the coin or press Toss Coin until you have recorded 20 outcomes.",
      'ev_title': "Frequency Table · Die",
      'ev_coin_title': "Frequency Table · Coin",
      'ev_face': "Face",
      'ev_count': "Count",
      'ev_rel': "Rel. Freq",
      'ev_side': "Side",
      'ev_heads': "Heads",
      'ev_tails': "Tails",
      'btn_hint': "Hint",
      'btn_submit_rolls': "Submit Rolls",
      'btn_submit_toss': "Submit Tosses",
      'btn_submit_ans': "Submit Answer",
      'btn_report': "Report",
      'btn_close_report': "Close Report",
      'btn_restart_exp': "Restart Exploration",
      'reset': "Reset",
      'obj_desc':
          "Collect experimental data from many random trials, compute experimental probability, and compare it with the theoretical probability of the same event.",
      'conc_desc':
          "Experimental probability comes from actual trial data (favourable ÷ total). Theoretical probability comes from equally likely outcomes (1/6 for a die face, 1/2 for a coin). With more trials, experimental values drift toward the theoretical value — the Law of Large Numbers.",
      'hint_desc':
          "Ask students to predict how many 4s they expect in 50 rolls before they start. Focus on the growing frequency table as evidence.",
      'ph0_t': "Roll the Die 50 Times",
      'ph1_t': "Experimental P(4)",
      'ph2_t': "Theoretical P(4)",
      'ph3_t': "Toss the Coin 20 Times",
      'ph4_t': "Experimental P(Heads)",
      's0_1': "Roll the die and record each result until you reach 50 rolls.",
      's0_2':
          "Calculate the experimental probability of rolling a 4 (count of 4s ÷ 50).",
      's0_3': "Calculate the theoretical probability of a 4 (1 ÷ 6 ≈ 0.17).",
      's1_1': "Toss the coin 20 times, recording heads and tails.",
      's1_2': "Calculate the experimental probability of heads (heads ÷ 20).",
      'calc_p1_title': "Experimental Probability of 4",
      'calc_p1_prompt':
          "P(4) = number of 4s ÷ 50 = {c} ÷ 50. Enter the decimal (0–1).",
      'calc_p2_title': "Theoretical Probability of 4",
      'calc_p2_prompt':
          "A fair die has 6 equally likely faces. Enter the theoretical P(4) as a decimal.",
      'calc_p4_title': "Experimental Probability of Heads",
      'calc_p4_prompt':
          "P(Heads) = heads ÷ 20 = {h} ÷ 20. Enter the decimal (0–1).",
      'calc_hint_line':
          "Enter a decimal between 0 and 1, then press Submit Answer.",
      'msg_dice_done':
          "50 rolls collected! You rolled a 4 exactly {c} times. Press Submit.",
      'msg_coin_done': "20 tosses collected! You got {h} heads. Press Submit.",
      'msg_err_dice': "Please complete all 50 rolls first.",
      'msg_err_coin': "Complete all 20 tosses first.",
      'msg_err_input': "Type a decimal between 0 and 1.",
      'msg_correct': "Correct!",
      'msg_wrong': "Not quite. Check your division and try again.",
      'h_0':
          "Press Roll Die, then Record. Or use 'Roll & Record ×10' to move quickly. Keep going until Rolls reaches 50.",
      'h_1':
          "Count the 4s from the Fours counter or the frequency table, then divide by 50. (Example: 8 ÷ 50 = 0.16).",
      'h_2':
          "A fair die has 6 faces, each equally likely. Theoretical probability = 1 ÷ 6 ≈ 0.17.",
      'h_3':
          "Tap the coin or press Toss Coin. Keep tossing until the Tosses counter reaches 20.",
      'h_4':
          "Read the Heads counter, then divide by 20. (Example: 11 ÷ 20 = 0.55). Compare to theoretical 0.5.",
      'diag_observation': "Observation",
      'diag_pass':
          "You collected trial data and compared experimental with theoretical probability.",
      'diag_fail':
          "Some requirements still need work — your data is preserved, adjust and resubmit.",
      'prev': "Prev",
      'next': "Next",
    },
    'hi': {
      'app_title': "परीक्षण परीक्षक: पासा और सिक्का क्वेस्ट",
      'tagline': "कक्षा 9 • अध्याय 7: संभावनाओं का गणित — प्रायिकता का परिचय",
      'init_btn': "मिशन शुरू करें",
      'board_title': "शिक्षक मार्गदर्शिका",
      'obj_label': "मिशन का उद्देश्य",
      'scenario_label': "परिदृश्य",
      'steps_label': "निर्देश अनुक्रम",
      'hint_label': "संकेत / साक्ष्य",
      'conc_label': "सीखा हुआ निष्कर्ष",
      'scen_0': "परिदृश्य 1 · पासा: प्रायोगिक बनाम सैद्धांतिक",
      'scen_1': "परिदृश्य 2 · सिक्का उछाल: प्रायोगिक प्रायिकता",
      'sim_dice_title': "परिदृश्य 1 · आभासी पासा",
      'stat_rolls': "रोल्स",
      'stat_target': "लक्ष्य",
      'stat_fours': "चार (4)",
      'btn_roll': "पासा फेंके",
      'btn_record': "रिकॉर्ड",
      'btn_batch': "रोल और रिकॉर्ड ×10",
      'dice_instruction':
          "पासा फेंके दबाएं, फिर परिणाम दर्ज करने के लिए रिकॉर्ड करें। 50 रोल्स तक पहुंचें (×10 का उपयोग करें)।",
      'sim_coin_title': "परिदृश्य 2 · आभासी सिक्का",
      'stat_tosses': "उछाल",
      'stat_heads': "चित (H)",
      'stat_tails': "पट (T)",
      'btn_toss': "सिक्का उछालें",
      'coin_instruction':
          "सिक्के पर टैप करें या सिक्का उछालें दबाएं जब तक कि 20 परिणाम दर्ज न हो जाएं।",
      'ev_title': "आवृत्ति तालिका · पासा",
      'ev_coin_title': "आवृत्ति तालिका · सिक्का",
      'ev_face': "फलक",
      'ev_count': "संख्या",
      'ev_rel': "सापेक्ष आवृत्ति",
      'ev_side': "पहलू",
      'ev_heads': "चित",
      'ev_tails': "पट",
      'btn_hint': "संकेत",
      'btn_submit_rolls': "रोल्स सबमिट करें",
      'btn_submit_toss': "उछाल सबमिट करें",
      'btn_submit_ans': "उत्तर सबमिट करें",
      'btn_report': "रिपोर्ट",
      'btn_close_report': "रिपोर्ट बंद करें",
      'btn_restart_exp': "पुनः अन्वेषण करें",
      'reset': "रीसेट",
      'obj_desc':
          "कई यादृच्छिक परीक्षणों से प्रायोगिक डेटा एकत्र करें, प्रायोगिक प्रायिकता की गणना करें, और इसकी तुलना उसी घटना की सैद्धांतिक प्रायिकता से करें।",
      'conc_desc':
          "प्रायोगिक प्रायिकता वास्तविक डेटा से आती है (अनुकूल ÷ कुल)। सैद्धांतिक प्रायिकता समान रूप से संभावित परिणामों से आती है (पासे के लिए 1/6, सिक्के के लिए 1/2)। अधिक परीक्षणों के साथ, प्रायोगिक मान सैद्धांतिक मान की ओर बढ़ते हैं।",
      'hint_desc':
          "शुरू करने से पहले छात्रों से यह अनुमान लगाने को कहें कि 50 रोल्स में कितने 4 की उम्मीद है। साक्ष्य के रूप में बढ़ती आवृत्ति तालिका पर ध्यान दें।",
      'ph0_t': "पासा 50 बार फेंके",
      'ph1_t': "प्रायोगिक P(4)",
      'ph2_t': "सैद्धांतिक P(4)",
      'ph3_t': "सिक्का 20 बार उछालें",
      'ph4_t': "प्रायोगिक P(Heads)",
      's0_1':
          "50 रोल्स तक पहुंचने तक पासा फेंकें और प्रत्येक परिणाम को रिकॉर्ड करें।",
      's0_2': "4 आने की प्रायोगिक प्रायिकता की गणना करें (4 की संख्या ÷ 50)।",
      's0_3': "4 की सैद्धांतिक प्रायिकता की गणना करें (1 ÷ 6 ≈ 0.17)।",
      's1_1': "सिक्के को 20 बार उछालें, चित और पट रिकॉर्ड करें।",
      's1_2': "चित की प्रायोगिक प्रायिकता की गणना करें (चित ÷ 20)।",
      'calc_p1_title': "4 की प्रायोगिक प्रायिकता",
      'calc_p1_prompt':
          "P(4) = 4 की संख्या ÷ 50 = {c} ÷ 50। दशमलव (0-1) दर्ज करें।",
      'calc_p2_title': "4 की सैद्धांतिक प्रायिकता",
      'calc_p2_prompt':
          "एक निष्पक्ष पासे में 6 फलक होते हैं। सैद्धांतिक P(4) दशमलव के रूप में दर्ज करें।",
      'calc_p4_title': "चित की प्रायोगिक प्रायिकता",
      'calc_p4_prompt':
          "P(Heads) = चित की संख्या ÷ 20 = {h} ÷ 20। दशमलव (0-1) दर्ज करें।",
      'calc_hint_line':
          "0 और 1 के बीच दशमलव दर्ज करें, फिर उत्तर सबमिट करें दबाएं।",
      'msg_dice_done':
          "50 रोल्स पूरे हुए! आपने {c} बार 4 प्राप्त किया। सबमिट दबाएं।",
      'msg_coin_done': "20 उछाल पूरे हुए! आपको {h} चित मिले। सबमिट दबाएं।",
      'msg_err_dice': "कृपया पहले सभी 50 रोल्स पूरे करें।",
      'msg_err_coin': "कृपया पहले सभी 20 उछाल पूरे करें।",
      'msg_err_input': "एक वैध दशमलव संख्या टाइप करें।",
      'msg_correct': "सही!",
      'msg_wrong': "बिल्कुल नहीं। अपने भागफल की जांच करें और पुनः प्रयास करें।",
      'h_0':
          "पासा फेंके दबाएं, फिर रिकॉर्ड करें। या जल्दी करने के लिए 'रोल और रिकॉर्ड ×10' का उपयोग करें।",
      'h_1': "4 की संख्या को 50 से विभाजित करें। (उदाहरण: 8 ÷ 50 = 0.16)।",
      'h_2': "सैद्धांतिक प्रायिकता = 1 ÷ 6 ≈ 0.17।",
      'h_3': "सिक्के पर टैप करें या सिक्का उछालें दबाएं। 20 उछाल पूरे करें।",
      'h_4': "चित की संख्या को 20 से विभाजित करें। (उदाहरण: 11 ÷ 20 = 0.55)।",
      'diag_observation': "अवलोकन",
      'diag_pass':
          "आपने परीक्षण डेटा एकत्र किया और प्रायोगिक की सैद्धांतिक प्रायिकता के साथ तुलना की।",
      'diag_fail':
          "कुछ परिणामों पर अभी भी काम करने की आवश्यकता है - आपका डेटा सुरक्षित है, समायोजित करें और पुनः सबमिट करें।",
      'prev': "पिछला",
      'next': "अगला",
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

    _coinAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _coinRotation = Tween<double>(begin: 0, end: pi * 10).animate(
      CurvedAnimation(parent: _coinAnimController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _sfxPlayer1.dispose();
    _sfxPlayer2.dispose();
    _shutterController.dispose();
    _coinAnimController.dispose();
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
      _rolls.clear();
      _tosses.clear();
      _activePhase = 0;
      _activeScenario = 0;
      _calcInput = "";
      _showReport = false;
      _pendingRoll = 1;
    });
    _shutterController.reverse();
  }

  void _rollDie() {
    if (_isRolling || _rolls.length >= _targetRolls) return;
    _playClick();
    setState(() => _isRolling = true);

    // Animate dice rolling effect
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (timer.tick > 6) {
        timer.cancel();
        setState(() {
          _isRolling = false;
          _pendingRoll = _rnd.nextInt(6) + 1;
        });
      } else {
        setState(() {
          _pendingRoll = _rnd.nextInt(6) + 1;
        });
      }
    });
  }

  void _recordRoll() {
    if (_rolls.length >= _targetRolls) return;
    _playClick();
    setState(() {
      _rolls.add(_pendingRoll);
    });
    if (_rolls.length == _targetRolls) {
      _playSuccess();
      _showSnack(
        t(
          'msg_dice_done',
        ).replaceAll('{c}', '${_rolls.where((r) => r == 4).length}'),
        Colors.green,
      );
    }
  }

  void _batchRoll() {
    if (_rolls.length >= _targetRolls) return;
    _playClick();
    setState(() {
      int toAdd = min(10, _targetRolls - _rolls.length);
      for (int i = 0; i < toAdd; i++) {
        _rolls.add(_rnd.nextInt(6) + 1);
      }
      _pendingRoll = _rolls.last;
    });
    if (_rolls.length == _targetRolls) {
      _playSuccess();
      _showSnack(
        t(
          'msg_dice_done',
        ).replaceAll('{c}', '${_rolls.where((r) => r == 4).length}'),
        Colors.green,
      );
    }
  }

  void _tossCoin() {
    if (_isFlipping || _tosses.length >= _targetTosses) return;
    _playClick();
    setState(() => _isFlipping = true);
    _coinAnimController.forward(from: 0).then((_) {
      setState(() {
        _isFlipping = false;
        String result = _rnd.nextBool() ? 'H' : 'T';
        _tosses.add(result);
      });
      if (_tosses.length == _targetTosses) {
        _playSuccess();
        _showSnack(
          t(
            'msg_coin_done',
          ).replaceAll('{h}', '${_tosses.where((t) => t == 'H').length}'),
          Colors.green,
        );
      }
    });
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

  void _validateInput(double expected, String phaseTitle, int nextPhase) {
    _playClick();
    double? val = double.tryParse(_calcInput);
    if (val == null) {
      _playError();
      _showSnack(t('msg_err_input'), Colors.redAccent);
      return;
    }

    // Allow +/- 0.02 tolerance due to rounding
    if ((val - expected).abs() <= 0.02) {
      _playSuccess();
      _showSnack(t('msg_correct'), Colors.green);
      setState(() {
        _activePhase = nextPhase;
        _calcInput = "";
        if (nextPhase == 3) {
          _activeScenario = 1; // Transition to scenario 2
        } else if (nextPhase == 5) {
          // End of activity
          _flashSuccess = true;
          _flashTitle = t('diag_pass');
          _flashDesc = t('diag_observation');
          _flashFeedback = "All probability calculations verified!";
          _showReport = true;
        }
      });
    } else {
      _playError();
      _showSnack(t('msg_wrong'), Colors.orangeAccent);
    }
  }

  void _submitPhase() {
    if (_activePhase == 0) {
      if (_rolls.length < _targetRolls) {
        _playError();
        _showSnack(t('msg_err_dice'), Colors.redAccent);
      } else {
        _playClick();
        setState(() {
          _activePhase = 1;
          _calcInput = "";
        });
      }
    } else if (_activePhase == 1) {
      int fours = _rolls.where((r) => r == 4).length;
      double expected = fours / 50.0;
      _validateInput(expected, t('ph1_t'), 2);
    } else if (_activePhase == 2) {
      double expected = 1.0 / 6.0;
      _validateInput(expected, t('ph2_t'), 3);
    } else if (_activePhase == 3) {
      if (_tosses.length < _targetTosses) {
        _playError();
        _showSnack(t('msg_err_coin'), Colors.redAccent);
      } else {
        _playClick();
        setState(() {
          _activePhase = 4;
          _calcInput = "";
        });
      }
    } else if (_activePhase == 4) {
      int heads = _tosses.where((c) => c == 'H').length;
      double expected = heads / 20.0;
      _validateInput(expected, t('ph4_t'), 5);
    }
  }

  Widget _buildDiceIcon(int value) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(painter: DicePainter(value, value == 4)),
    );
  }

  Widget _buildBarChart(
    List<int> counts,
    int total,
    List<String> labels,
    Color color,
  ) {
    if (total == 0) total = 1; // Prevent division by zero
    return Container(
      height: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(counts.length, (i) {
          double fraction = counts[i] / total;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${counts[i]}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: fraction * 80, // Max height 80
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[i],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFrequencyTable() {
    if (_activeScenario == 0) {
      // Dice
      List<int> counts = List.generate(
        6,
        (i) => _rolls.where((r) => r == i + 1).length,
      );
      int total = _rolls.length;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  t('ev_title'),
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$total / 50',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildBarChart(counts, total, [
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
          ], Colors.blueAccent),
        ],
      );
    } else {
      // Coin
      int hCount = _tosses.where((t) => t == 'H').length;
      int tCount = _tosses.where((t) => t == 'T').length;
      int total = _tosses.length;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  t('ev_coin_title'),
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$total / 20',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildBarChart(
            [hCount, tCount],
            total,
            [t('ev_heads'), t('ev_tails')],
            Colors.orangeAccent,
          ),
        ],
      );
    }
  }

  Widget _buildCalculator() {
    String title = '';
    String prompt = '';

    if (_activePhase == 1) {
      int fours = _rolls.where((r) => r == 4).length;
      title = t('calc_p1_title');
      prompt = t('calc_p1_prompt').replaceAll('{c}', '$fours');
    } else if (_activePhase == 2) {
      title = t('calc_p2_title');
      prompt = t('calc_p2_prompt');
    } else if (_activePhase == 4) {
      int heads = _tosses.where((t) => t == 'H').length;
      title = t('calc_p4_title');
      prompt = t('calc_p4_prompt').replaceAll('{h}', '$heads');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            prompt,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "0.00",
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) {
              setState(() => _calcInput = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16,
              top: 16,
              right: 16,
              bottom: 100,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Simulators Left Column
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xD80F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child:
                        _activeScenario == 0
                            ? _buildDiceSim()
                            : _buildCoinSim(),
                  ),
                ),
                const SizedBox(width: 16),

                // Evidence / Calculator Right Column
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xD80F172A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: _buildFrequencyTable(),
                      ),
                      const SizedBox(height: 16),
                      if (_activePhase == 1 ||
                          _activePhase == 2 ||
                          _activePhase == 4)
                        _buildCalculator(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiceSim() {
    int fours = _rolls.where((r) => r == 4).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('sim_dice_title'),
          style: const TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t('dice_instruction'),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 16),
        Center(
          child:
              _isRolling
                  ? Transform.rotate(
                    angle: _rnd.nextDouble() * pi,
                    child: _buildDiceIcon(_pendingRoll),
                  )
                  : _buildDiceIcon(_pendingRoll),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statBox('${_rolls.length}', t('stat_rolls')),
            _statBox('50', t('stat_target')),
            _statBox('$fours', t('stat_fours')),
          ],
        ),

        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _activePhase == 0 ? _rollDie : null,
              icon: const Icon(Icons.casino),
              label: Text(t('btn_roll')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            OutlinedButton(
              onPressed: _activePhase == 0 ? _recordRoll : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white30),
              ),
              child: Text(t('btn_record')),
            ),
            ElevatedButton(
              onPressed: _activePhase == 0 ? _batchRoll : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellowAccent,
                foregroundColor: Colors.black87,
              ),
              child: Text(
                t('btn_batch'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoinSim() {
    int heads = _tosses.where((t) => t == 'H').length;
    int tails = _tosses.where((t) => t == 'T').length;

    // Determine the letter to show on the coin based on flip state or last result
    String face = 'H';
    if (_tosses.isNotEmpty) face = _tosses.last;
    if (_isFlipping) face = _rnd.nextBool() ? 'H' : 'T';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('sim_coin_title'),
          style: const TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t('coin_instruction'),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: _activePhase == 3 ? _tossCoin : null,
            child: AnimatedBuilder(
              animation: _coinRotation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationX(_coinRotation.value),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      face,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statBox('${_tosses.length}', t('stat_tosses')),
            _statBox('$heads', t('stat_heads')),
            _statBox('$tails', t('stat_tails')),
          ],
        ),

        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: _activePhase == 3 ? _tossCoin : null,
            icon: const Icon(Icons.monetization_on),
            label: Text(t('btn_toss')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statBox(String val, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: const TextStyle(
              color: Colors.yellowAccent,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    String btnLabel = t('btn_submit_ans');
    if (_activePhase == 0) btnLabel = t('btn_submit_rolls');
    if (_activePhase == 3) btnLabel = t('btn_submit_toss');

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
              ), // Spacing placeholder
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
                      Icons.leaderboard,
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

                  // Scenario Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _activeScenario,
                        dropdownColor: const Color(0xFF1E293B),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.orangeAccent,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(value: 0, child: Text(t('scen_0'))),
                          DropdownMenuItem(value: 1, child: Text(t('scen_1'))),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            _playClick();
                            setState(() {
                              _activeScenario = val;
                              _activePhase = val == 0 ? 0 : 3;
                              _calcInput = "";
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildContentCard(
                    Icons.my_location,
                    t('obj_label'),
                    t('obj_desc'),
                    Colors.orange,
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
                  if (_activeScenario == 0) ...[
                    _buildStep(0, t('s0_1')),
                    _buildStep(1, t('s0_2')),
                    _buildStep(2, t('s0_3')),
                  ] else ...[
                    _buildStep(0, t('s1_1')),
                    _buildStep(1, t('s1_2')),
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
                    Icons.casino,
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

class DicePainter extends CustomPainter {
  final int value;
  final bool isTarget;
  DicePainter(this.value, this.isTarget);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
    final borderPaint =
        Paint()
          ..color = isTarget ? Colors.orange : const Color(0xFFCBD5E1)
          ..strokeWidth = isTarget ? 5 : 2
          ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      const Radius.circular(16),
    );
    canvas.drawRRect(rect, bgPaint);
    canvas.drawRRect(rect, borderPaint);

    final pipPaint =
        Paint()
          ..color = isTarget ? Colors.orange.shade800 : const Color(0xFF0B234D);
    final w = size.width;
    final h = size.height;
    final Map<String, Offset> P = {
      'TL': Offset(w * 0.3, h * 0.3),
      'TR': Offset(w * 0.7, h * 0.3),
      'ML': Offset(w * 0.3, h * 0.5),
      'MR': Offset(w * 0.7, h * 0.5),
      'BL': Offset(w * 0.3, h * 0.7),
      'BR': Offset(w * 0.7, h * 0.7),
      'C': Offset(w * 0.5, h * 0.5),
    };

    final map = {
      1: ['C'],
      2: ['TL', 'BR'],
      3: ['TL', 'C', 'BR'],
      4: ['TL', 'TR', 'BL', 'BR'],
      5: ['TL', 'TR', 'C', 'BL', 'BR'],
      6: ['TL', 'TR', 'ML', 'MR', 'BL', 'BR'],
    };

    final pips = map[value] ?? [];
    for (var p in pips) {
      canvas.drawCircle(P[p]!, w * 0.085, pipPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DicePainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.isTarget != isTarget;
}
