// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class DigitDetectiveApp extends StatefulWidget {
  const DigitDetectiveApp({super.key});

  @override
  State<DigitDetectiveApp> createState() => _DigitDetectiveAppState();
}

class _DigitDetectiveAppState extends State<DigitDetectiveApp>
    with TickerProviderStateMixin {
  final bool _isDark = true;
  String _lang = 'en';
  bool _sidebarOpen = true;
  bool _showShutter = true;
  bool _showDiagnostics = false;
  String _flashMsg = '';
  int _scen = 0;
  int _hintIdx = 0;

  bool _s1Pass = false, _s1Sub = false;
  bool _s2Pass = false, _s2Sub = false;
  bool _s3Pass = false, _s3Sub = false;

  // -- S1 State --
  int? _s1Deciding;
  final Map<int, Map<String, bool>> _s1Class = {
    4075: {'d2': false, 'd5': false, 'd10': false},
    320: {'d2': false, 'd5': false, 'd10': false},
    68: {'d2': false, 'd5': false, 'd10': false},
  };

  // -- S2 State --
  final Map<int, Map<String, dynamic>> _s2State = {
    427: {'sum': '', 'root': '', 'verdict': null},
    7309: {'sum': '', 'root': '', 'verdict': null},
  };

  // -- S3 State --
  String _s3r1 = '';
  String _s3r2 = '';
  String _s3root = '';
  Map<int, String?> _s3mult = {954: null, 483: null};

  // Virtual Keypad State
  String? _activeField; // format: 's2_sum_427', 's3_r1', etc.

  // Diagnostic Data
  Map<String, dynamic>? _diagData;

  late AudioPlayer _player;
  late AnimationController _shutterCtrl;
  late Animation<Offset> _shutterAnim;

  final Map<String, Map<String, String>> _text = {
    'en': {
      'app_title': "Digit Detective: Divisibility & Digital Roots",
      'app_subtitle': "Class 8 • Number Play",
      'start_mission': "Start Mission",
      'nav_prev': "Prev",
      'nav_next': "Next",
      'nav_submit': "Submit",
      'nav_report': "Report",
      'teacher_board': "Teacher Board",
      'ui_scenario': "Scenario",
      'ui_objective': "Mission Objective",
      'ui_sequence': "Instruction Sequence",
      'ui_hints': "Hints / Evidence",
      'ui_learnt': "Learnt Conclusion",
      'ui_close': "Close Report",
      'restart_mission': "Restart Mission",
      'scen_1': "Scenario 1 · EX-5-07 · Units digit",
      'scen_2': "Scenario 2 · EX-5-08 · Cast-out-nines",
      'scen_3': "Scenario 3 · EX-5-11 · Digital root",
      'mission_desc':
          "Crack three divisibility cases. Spotlight the units digit to test ÷2, ÷5, ÷10. Fold the digit sum with the cast-out-nines machine to test ÷9. Reduce to the digital root and spot the multiples of 9.",
      'learnt_desc':
          "Only the units digit decides 2/5/10. A number and its digit sum leave the same remainder on 9 and 3. Folding to one digit gives the digital root — and multiples of 9 always reduce to 9.",
      'step_0_1':
          "Read the place-value strip: which places are multiples of 10?",
      'step_0_2':
          "Tap the units cell — the only place that is NOT a multiple of 10.",
      'step_0_3': "Toggle ÷2 / ÷5 / ÷10 for 4075, 320 and 68.",
      'step_0_4': "Press Submit to check your classifications.",
      'step_1_1': "Read the digit tiles for 427 and 7309.",
      'step_1_2': "Type the digit sum of each number.",
      'step_1_3':
          "Fold again if needed; type the single-digit remainder on ÷9.",
      'step_1_4': "Pick 'Divisible by 9' or 'Not divisible', then Submit.",
      'step_2_1': "Sum the digits of 489710 → first reduction.",
      'step_2_2': "Fold again → second reduction.",
      'step_2_3': "Type the final digital root (one digit).",
      'step_2_4': "Flag 954 and 483 as multiple-of-9 or not, then Submit.",

      'hint_0_1':
          "Which places are 1000s, 100s, 10s? Each is a multiple of 10.",
      'hint_0_2': "Only the units digit is not a multiple of 10 — tap it.",
      'hint_0_3':
          "4075 units 5 → ÷5 only. 320 units 0 → ÷2,÷5,÷10. 68 units 8 → ÷2 only.",
      'hint_1_1': "427 → 4+2+7 = 13. Fold: 1+3 = 4.",
      'hint_1_2': "7309 → 7+3+0+9 = 19. Fold: 1+9 = 10 → 1+0 = 1.",
      'hint_1_3':
          "Remainder 0 (root 9) means divisible by 9. Here both are NOT divisible.",
      'hint_2_1': "4+8+9+7+1+0 = 29.",
      'hint_2_2': "2+9 = 11, then 1+1 = 2. Digital root = 2.",
      'hint_2_3': "954 → 18 → 9 (multiple of 9). 483 → 15 → 6 (not).",
      'hint_initial':
          "Ask: which places are multiples of 10? Why does the digit sum share the remainder on 9?",

      's1_title': "Scenario 1 · Place-Value Strip of 4075",
      's1_desc':
          "4075 = 4×1000 + 0×100 + 7×10 + 5. Every place above units is a multiple of 10, so 2, 5 and 10 only 'see' the units digit. Tap the deciding cell.",
      's1_deciding': "Deciding digit:",
      's1_tap_cell': "— tap a cell —",
      's1_units_correct': "units (5) ✓ correct place to inspect",
      's1_wrong_place': "— is that a multiple of 10?",
      's1_classify': "Classify by the Units Digit",
      's1_classify_desc':
          "Turn ON only the tests each number passes. ÷2 if units is even; ÷5 if units is 0 or 5; ÷10 if units is 0.",
      's1_units': "units",

      's2_title': "Scenario 2 · Cast-Out-Nines Machine",
      's2_desc':
          "A number leaves the same remainder on ÷9 as its digit sum. Keep folding the digit sum until one digit remains — that single digit is the remainder.",
      's2_ex':
          "427 → 4+2+7 = 13 → 1+3 = 4 (remainder 4).\n7309 → 7+3+0+9 = 19 → 1+9 = 10 → 1 (remainder 1).",
      's2_sum': "Digit sum",
      's2_fold': "Fold → remainder ÷9",
      's2_verdict': "Verdict",
      's2_div9': "÷9 ✓",
      's2_notdiv9': "Not ÷9",

      's3_title': "Scenario 3 · Digital-Root Reducer",
      's3_desc':
          "Sum the digits, then fold the result, and fold again until a single digit remains. That terminal digit is the digital root.",
      's3_sum': "Sum of digits",
      's3_fold': "Fold again",
      's3_root': "Digital root",
      's3_mult_title': "Multiples of 9 → Digital Root 9",
      's3_mult_desc':
          "Any multiple of 9 reduces to a digital root of 9. Flag each number.",
      's3_mult': "Multiple of 9",
      's3_notmult': "Not a multiple",

      'flash_scenario_cleared': "Scenario Cleared! Move to next.",
      'flash_all_cleared': "All scenarios cleared!",
      'flash_incorrect': "Incorrect. Please check your working.",
      'flash_reset': "Detective board reset.",
      'diag_title_pass': "All Cases Cracked!",
      'diag_sub_pass':
          "You proved the 2/5/10, 9 & 3 and digital-root shortcuts from place value.",
      'diag_title_fail': "Detective In Progress",
      'diag_sub_fail':
          "Some cases still need work — your entries are kept, adjust and resubmit.",
      'diag_prob': "Problem Solving",
      'diag_proc': "Procedural Fluency",
      'diag_math': "Math Modeling",
      'diag_logic': "Logical Reasoning",
      'strength_1':
          "You pinpointed the units digit and classified 2/5/10 accurately.",
      'imp_1': "Remember: only the units digit decides ÷2, ÷5 and ÷10.",
      'strength_2': "Your digit-sum folding steps were correct.",
      'imp_2': "Add every digit carefully before folding to a single digit.",
      'strength_3':
          "Your folded remainders, verdicts and digital root matched.",
      'imp_3': "Fold again whenever the digit sum is still two digits.",
      'strength_4': "You linked digital root 9 to multiples of 9.",
      'imp_4': "A digital root of 9 is the signature of a multiple of 9.",
    },
    'hi': {
      'app_title': "डिजिट डिटेक्टिव: विभाज्यता और डिजिटल मूल",
      'app_subtitle': "कक्षा 8 • संख्या खेल",
      'start_mission': "मिशन शुरू करें",
      'nav_prev': "पिछला",
      'nav_next': "अगला",
      'nav_submit': "सबमिट",
      'nav_report': "रिपोर्ट",
      'teacher_board': "शिक्षक बोर्ड",
      'ui_scenario': "परिदृश्य",
      'ui_objective': "मिशन का उद्देश्य",
      'ui_sequence': "निर्देश क्रम",
      'ui_hints': "संकेत / प्रमाण",
      'ui_learnt': "सीखा गया निष्कर्ष",
      'ui_close': "रिपोर्ट बंद करें",
      'restart_mission': "मिशन फिर से शुरू करें",
      'scen_1': "परिदृश्य 1 · EX-5-07 · इकाई का अंक",
      'scen_2': "परिदृश्य 2 · EX-5-08 · नौ को बाहर करना",
      'scen_3': "परिदृश्य 3 · EX-5-11 · अंकीय मूल",
      'mission_desc':
          "विभाज्यता के तीन मामलों को हल करें। ÷2, ÷5, ÷10 की जांच के लिए इकाई अंक पर ध्यान दें। ÷9 की जांच के लिए अंकों के योग को कास्ट-आउट-नाइन्स मशीन से छोटा करें। डिजिटल रूट तक कम करें और 9 के गुणकों की पहचान करें।",
      'learnt_desc':
          "केवल इकाई का अंक 2/5/10 तय करता है। एक संख्या और उसके अंकों का योग 9 और 3 पर समान शेषफल छोड़ते हैं। एक अंक तक मोड़ने से अंकीय मूल प्राप्त होता है - और 9 के गुणक हमेशा 9 तक कम हो जाते हैं।",
      'step_0_1': "स्थानीय मान पट्टी पढ़ें: कौन से स्थान 10 के गुणज हैं?",
      'step_0_2': "इकाई कक्ष पर टैप करें - केवल यही स्थान 10 का गुणज नहीं है।",
      'step_0_3': "4075, 320 और 68 के लिए ÷2 / ÷5 / ÷10 टॉगल करें।",
      'step_0_4': "अपने वर्गीकरण की जांच करने के लिए सबमिट दबाएं।",
      'step_1_1': "427 और 7309 के लिए अंक टाइलें पढ़ें।",
      'step_1_2': "प्रत्येक संख्या के अंकों का योग टाइप करें।",
      'step_1_3':
          "यदि आवश्यकता हो तो फिर से मोड़ें; ÷9 पर एक अंक का शेषफल टाइप करें।",
      'step_1_4': "'÷9 ✓' या '÷9 नहीं' चुनें, फिर सबमिट करें।",
      'step_2_1': "489710 के अंकों का योग करें → पहली कमी।",
      'step_2_2': "फिर से मोड़ें → दूसरी कमी।",
      'step_2_3': "अंतिम अंकीय मूल (एक अंक) टाइप करें।",
      'step_2_4':
          "954 और 483 को 9-के-गुणज या नहीं के रूप में चिह्नित करें, फिर सबमिट करें।",

      'hint_0_1':
          "1000s, 100s, 10s के स्थान कौन से हैं? प्रत्येक 10 का गुणज है।",
      'hint_0_2': "केवल इकाई का अंक 10 का गुणज नहीं है - इसे टैप करें।",
      'hint_0_3':
          "4075 की इकाई 5 → केवल ÷5। 320 की इकाई 0 → ÷2,÷5,÷10। 68 की इकाई 8 → केवल ÷2।",
      'hint_1_1': "427 → 4+2+7 = 13. मोड़ने पर: 1+3 = 4.",
      'hint_1_2': "7309 → 7+3+0+9 = 19. मोड़ने पर: 1+9 = 10 → 1+0 = 1.",
      'hint_1_3':
          "शेषफल 0 (मूल 9) का अर्थ है 9 से विभाज्य। यहाँ दोनों विभाज्य नहीं हैं।",
      'hint_2_1': "4+8+9+7+1+0 = 29.",
      'hint_2_2': "2+9 = 11, फिर 1+1 = 2. अंकीय मूल = 2.",
      'hint_2_3': "954 → 18 → 9 (9 का गुणज)। 483 → 15 → 6 (नहीं)।",
      'hint_initial':
          "पूछें: कौन से स्थान 10 के गुणज हैं? अंकों का योग 9 पर समान शेषफल क्यों छोड़ता है?",

      's1_title': "परिदृश्य 1 · 4075 की स्थानीय मान पट्टी",
      's1_desc':
          "4075 = 4×1000 + 0×100 + 7×10 + 5. इकाई के ऊपर का हर स्थान 10 का गुणज है, इसलिए 2, 5 और 10 केवल इकाई के अंक को 'देखते' हैं। निर्णायक सेल पर टैप करें।",
      's1_deciding': "निर्णायक अंक:",
      's1_tap_cell': "— एक सेल टैप करें —",
      's1_units_correct': "इकाई (5) ✓ जाँच करने के लिए सही स्थान",
      's1_wrong_place': "— क्या वह 10 का गुणज है?",
      's1_classify': "इकाई के अंक द्वारा वर्गीकरण",
      's1_classify_desc':
          "केवल उन परीक्षणों को चालू (ON) करें जिन्हें प्रत्येक संख्या पास करती है। ÷2 यदि इकाई सम है; ÷5 यदि इकाई 0 या 5 है; ÷10 यदि इकाई 0 है।",
      's1_units': "इकाई",

      's2_title': "परिदृश्य 2 · नौ को बाहर करने की मशीन",
      's2_desc':
          "एक संख्या ÷9 पर अपने अंकों के योग के समान ही शेषफल छोड़ती है। अंकों के योग को तब तक मोड़ते रहें जब तक कि एक अंक न रह जाए - वह एकल अंक शेषफल है।",
      's2_ex':
          "427 → 4+2+7 = 13 → 1+3 = 4 (शेष 4)।\n7309 → 7+3+0+9 = 19 → 1+9 = 10 → 1 (शेष 1)।",
      's2_sum': "अंकों का योग",
      's2_fold': "मोड़ें → शेषफल ÷9",
      's2_verdict': "निर्णय",
      's2_div9': "÷9 ✓",
      's2_notdiv9': "÷9 नहीं",

      's3_title': "परिदृश्य 3 · अंकीय मूल निकालने वाला",
      's3_desc':
          "अंकों का योग करें, फिर परिणाम को मोड़ें, और तब तक फिर से मोड़ें जब तक कि एक अंक न रह जाए। वह अंतिम अंक अंकीय मूल है।",
      's3_sum': "अंकों का योग",
      's3_fold': "फिर से मोड़ें",
      's3_root': "अंकीय मूल",
      's3_mult_title': "9 के गुणज → अंकीय मूल 9",
      's3_mult_desc':
          "9 का कोई भी गुणज 9 के अंकीय मूल तक कम हो जाता है। प्रत्येक संख्या को चिह्नित करें।",
      's3_mult': "9 का गुणज",
      's3_notmult': "गुणज नहीं",

      'flash_scenario_cleared': "परिदृश्य साफ़ हो गया! अगले पर जाएँ।",
      'flash_all_cleared': "सभी परिदृश्य साफ़ हो गए!",
      'flash_incorrect': "गलत। कृपया अपने काम की जाँच करें।",
      'flash_reset': "डिटेक्टिव बोर्ड रीसेट हो गया।",
      'diag_title_pass': "सभी मामले सुलझ गए!",
      'diag_sub_pass':
          "आपने स्थानीय मान से 2/5/10, 9 और 3 और अंकीय मूल शॉर्टकट साबित कर दिए हैं।",
      'diag_title_fail': "जासूस कार्य प्रगति पर है",
      'diag_sub_fail':
          "कुछ मामलों में अभी भी काम करने की आवश्यकता है - आपकी प्रविष्टियाँ सुरक्षित हैं, समायोजित करें और फिर से सबमिट करें।",
      'diag_prob': "समस्या समाधान",
      'diag_proc': "प्रक्रियात्मक प्रवाह",
      'diag_math': "गणितीय मॉडलिंग",
      'diag_logic': "तार्किक सोच",
      'strength_1':
          "आपने इकाई के अंक को पहचाना और 2/5/10 को सही ढंग से वर्गीकृत किया।",
      'imp_1': "याद रखें: केवल इकाई का अंक ÷2, ÷5 और ÷10 तय करता है।",
      'strength_2': "आपके अंक-योग को मोड़ने के चरण सही थे।",
      'imp_2':
          "एक अंक में मोड़ने से पहले प्रत्येक अंक को सावधानीपूर्वक जोड़ें।",
      'strength_3': "आपके मुड़े हुए शेषफल, निर्णय और अंकीय मूल मेल खाते हैं।",
      'imp_3': "जब भी अंकों का योग दो अंकों का हो, तो फिर से मोड़ें।",
      'strength_4': "आपने अंकीय मूल 9 को 9 के गुणकों से जोड़ा।",
      'imp_4': "9 का अंकीय मूल 9 के गुणज का हस्ताक्षर है।",
    },
  };

  String t(String key) => _text[_lang]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _player = AudioPlayer();
    _shutterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shutterAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(parent: _shutterCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _player.dispose();
    _shutterCtrl.dispose();
    super.dispose();
  }

  void _playTone(String tone) {
    _player.stop();
    if (tone == 'click') {
      _player.play(
        AssetSource(
          'audio/class8/mixkit_2568.mp3',
        ),
      );
    } else if (tone == 'snap') {
      _player.play(
        AssetSource(
          'audio/class8/mixkit_2568.mp3',
        ),
      );
    } else if (tone == 'success') {
      _player.play(
        AssetSource(
          'audio/class8/mixkit_2018.mp3',
        ),
      );
    } else if (tone == 'error') {
      _player.play(
        AssetSource(
          'audio/class8/mixkit_2570.mp3',
        ),
      );
    } else if (tone == 'launch') {
      _player.play(
        AssetSource(
          'audio/class8/mixkit_2018.mp3',
        ),
      );
    }
  }

  void _showFlash(String msg) {
    setState(() => _flashMsg = msg);
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _flashMsg == msg) setState(() => _flashMsg = '');
    });
  }

  void _reset() {
    _playTone('click');
    setState(() {
      _scen = 0;
      _hintIdx = 0;
      _s1Pass = _s1Sub = _s2Pass = _s2Sub = _s3Pass = _s3Sub = false;
      _s1Deciding = null;
      for (var k in _s1Class.keys) {
        _s1Class[k] = {'d2': false, 'd5': false, 'd10': false};
      }
      for (var k in _s2State.keys) {
        _s2State[k] = {'sum': '', 'root': '', 'verdict': null};
      }
      _s3r1 = _s3r2 = _s3root = '';
      _s3mult = {954: null, 483: null};
      _activeField = null;
      _showDiagnostics = false;
      _showShutter = true;
      _lang = 'en';
      _shutterCtrl.reset();
    });
    _showFlash(t('flash_reset'));
  }

  void _updateActiveField(String numStr) {
    if (_activeField == null) return;
    _playTone('click');
    setState(() {
      if (numStr == 'DEL') {
        _modifyFieldStr(
          (s) => s.isNotEmpty ? s.substring(0, s.length - 1) : '',
        );
      } else if (numStr == 'CLR') {
        _modifyFieldStr((s) => '');
      } else {
        _modifyFieldStr((s) => s.length < 5 ? s + numStr : s);
      }
    });
  }

  void _modifyFieldStr(String Function(String) modifier) {
    if (_activeField!.startsWith('s2_sum_')) {
      int id = int.parse(_activeField!.split('_').last);
      _s2State[id]!['sum'] = modifier(_s2State[id]!['sum']);
    } else if (_activeField!.startsWith('s2_root_')) {
      int id = int.parse(_activeField!.split('_').last);
      _s2State[id]!['root'] = modifier(_s2State[id]!['root']);
    } else if (_activeField == 's3_r1') {
      _s3r1 = modifier(_s3r1);
    } else if (_activeField == 's3_r2') {
      _s3r2 = modifier(_s3r2);
    } else if (_activeField == 's3_root') {
      _s3root = modifier(_s3root);
    }
  }

  // ==== Logic ====
  int _digitalRoot(int n) {
    int x = n;
    while (x > 9) {
      x = x
          .toString()
          .split('')
          .map((e) => int.parse(e))
          .reduce((a, b) => a + b);
    }
    return x;
  }

  void _submit() {
    _playTone('click');
    _activeField = null; // hide keypad

    bool c1 = true, c2 = true, c3 = true;

    // Check S1
    if (_s1Deciding != 3) c1 = false;
    for (int n in [4075, 320, 68]) {
      int u = n % 10;
      bool e2 = (u % 2 == 0), e5 = (u == 0 || u == 5), e10 = (u == 0);
      var g = _s1Class[n]!;
      if (g['d2'] != e2 || g['d5'] != e5 || g['d10'] != e10) c1 = false;
    }

    // Check S2
    final expS2 = {
      427: {'sum': 13, 'root': 4, 'div': false},
      7309: {'sum': 19, 'root': 1, 'div': false},
    };
    for (int n in [427, 7309]) {
      var st = _s2State[n]!;
      var ex = expS2[n]!;
      if (int.tryParse(st['sum']) != ex['sum'] ||
          int.tryParse(st['root']) != ex['root'] ||
          st['verdict'] != (ex['div'] == true ? 'yes' : 'no')) {
        c2 = false;
      }
    }

    // Check S3
    if (int.tryParse(_s3r1) != 29 ||
        int.tryParse(_s3r2) != 11 ||
        int.tryParse(_s3root) != 2) {
      c3 = false;
    }
    for (int n in [954, 483]) {
      if (_s3mult[n] != (_digitalRoot(n) == 9 ? 'yes' : 'no')) c3 = false;
    }

    bool validForCurrent = false;
    setState(() {
      if (_scen == 0 && c1) {
        _s1Pass = _s1Sub = true;
        validForCurrent = true;
      } else if (_scen == 0 && !c1) {
        _s1Sub = true;
      }

      if (_scen == 1 && c2) {
        _s2Pass = _s2Sub = true;
        validForCurrent = true;
      } else if (_scen == 1 && !c2) {
        _s2Sub = true;
      }

      if (_scen == 2 && c3) {
        _s3Pass = _s3Sub = true;
        validForCurrent = true;
      } else if (_scen == 2 && !c3) {
        _s3Sub = true;
      }
    });

    if (!validForCurrent) {
      _playTone('error');
      _showFlash(t('flash_incorrect'));
      return;
    }

    bool passedAll = _s1Pass && _s2Pass && _s3Pass;

    if (passedAll) {
      // Calculate XP and metrics
      int clsMatch = 0;
      for (int n in [4075, 320, 68]) {
        int u = n % 10;
        var g = _s1Class[n]!;
        if (g['d2'] == (u % 2 == 0) &&
            g['d5'] == (u == 0 || u == 5) &&
            g['d10'] == (u == 0)) {
          clsMatch++;
        }
      }
      double s1D = _s1Deciding == 3 ? 1 : 0;
      double prob = (s1D + (clsMatch / 3)) / 2;

      int sumSteps = 0;
      for (int n in [427, 7309]) {
        if (int.tryParse(_s2State[n]!['sum']) == expS2[n]!['sum']) sumSteps++;
      }
      double s3sumSteps =
          (int.tryParse(_s3r1) == 29 ? 1 : 0) +
          (int.tryParse(_s3r2) == 11 ? 1 : 0);
      double proc = (sumSteps + s3sumSteps) / 4;

      int rootSteps = 0, verdictSteps = 0;
      for (int n in [427, 7309]) {
        if (int.tryParse(_s2State[n]!['root']) == expS2[n]!['root']) {
          rootSteps++;
        }
        if (_s2State[n]!['verdict'] ==
            (expS2[n]!['div'] == true ? 'yes' : 'no')) {
          verdictSteps++;
        }
      }
      double math =
          (rootSteps + verdictSteps + (int.tryParse(_s3root) == 2 ? 1 : 0)) / 5;

      int multSteps = 0;
      for (int n in [954, 483]) {
        if (_s3mult[n] == (_digitalRoot(n) == 9 ? 'yes' : 'no')) multSteps++;
      }
      double logi = (multSteps / 2) * 0.6 + 0.4;

      prob = prob.clamp(0, 1);
      proc = proc.clamp(0, 1);
      math = math.clamp(0, 1);
      logi = logi.clamp(0, 1);
      int xp = ((prob + proc + math + logi) / 4 * 10).round();

      List<String> strengths = [], improvements = [];
      if (prob >= 0.8) {
        strengths.add('strength_1');
      } else {
        improvements.add('imp_1');
      }
      if (proc >= 0.8) {
        strengths.add('strength_2');
      } else {
        improvements.add('imp_2');
      }
      if (math >= 0.8) {
        strengths.add('strength_3');
      } else {
        improvements.add('imp_3');
      }
      if (logi >= 0.8) {
        strengths.add('strength_4');
      } else {
        improvements.add('imp_4');
      }

      setState(() {
        _diagData = {
          'xp': xp,
          'm': {'prob': prob, 'proc': proc, 'math': math, 'logi': logi},
          's': strengths,
          'i': improvements,
        };
        _showDiagnostics = true;
      });
      _playTone('success');
    } else {
      _playTone('success');
      _showFlash(t('flash_scenario_cleared'));
      if (_scen < 2) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) setState(() => _scen++);
        });
      }
    }
  }

  // ==== Main Build Layout Restructured ====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDark
          ? const Color(0xFF020617)
          : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (_sidebarOpen) _buildSidebar(),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                InteractiveViewer(
                                  boundaryMargin: const EdgeInsets.all(40),
                                  minScale: 0.2,
                                  maxScale: 3.0,
                                  constrained: true,
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: _buildCanvas(),
                                    ),
                                  ),
                                ),
                                // Virtual Keypad Floating Bottom Right
                                if (_activeField != null)
                                  Positioned(
                                    right: 24,
                                    bottom: 24,
                                    child: SafeArea(
                                      child: SizedBox(
                                        width: 280,
                                        child: _buildKeypad(),
                                      ),
                                    ),
                                  ),
                                // Flash Message
                                if (_flashMsg.isNotEmpty)
                                  Positioned(
                                    top: 20,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          _flashMsg,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _buildHUD(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Sidebar Toggle Button
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu, size: 28),
              color: Colors.orange,
              onPressed: () {
                _playTone('click');
                setState(() => _sidebarOpen = !_sidebarOpen);
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          if (_showDiagnostics) _buildDiagnosticsModal(),
          if (_showShutter) _buildShutterScreen(),
        ],
      ),
    );
  }

  Widget _buildShutterScreen() {
    return SlideTransition(
      position: _shutterAnim,
      child: Container(
        color: _isDark ? const Color(0xFF061024) : const Color(0xFFF8FAFC),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 24),
            Text(
              t('app_title'),
              style: TextStyle(
                color: _isDark ? Colors.white : Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t('app_subtitle'),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _playTone('launch');
                _shutterCtrl.forward().then(
                  (_) => setState(() => _showShutter = false),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                t('start_mission'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    bool passFlag = [_s1Pass, _s2Pass, _s3Pass][_scen];
    bool subFlag = [_s1Sub, _s2Sub, _s3Sub][_scen];

    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: _isDark
            ? const Color(0xD80F172A)
            : Colors.white.withOpacity(0.95),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(
          20,
        ).copyWith(top: 60), // Add top padding to clear the hamburger button
        children: [
          Text(
            t('app_title'),
            style: TextStyle(
              color: _isDark ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t('app_subtitle'),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.language),
                color: Colors.grey,
                onPressed: () {
                  _playTone('click');
                  setState(() => _lang = _lang == 'en' ? 'hi' : 'en');
                },
              ),
              Text(
                _lang.toUpperCase(),
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                color: Colors.grey,
                onPressed: _reset,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.co_present, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                t('teacher_board'),
                style: TextStyle(
                  color: _isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sideCard(
            t('ui_scenario'),
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _scen,
                isExpanded: true,
                dropdownColor: _isDark ? const Color(0xFF0F172A) : Colors.white,
                style: TextStyle(
                  color: _isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                items: [0, 1, 2]
                    .map(
                      (i) => DropdownMenuItem(
                        value: i,
                        child: Text(t('scen_${i + 1}')),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  _playTone('click');
                  if (v != null) {
                    setState(() {
                      _scen = v;
                      _activeField = null;
                    });
                  }
                },
              ),
            ),
          ),
          _sideCard(
            t('ui_objective'),
            Text(
              t('mission_desc'),
              style: TextStyle(
                color: _isDark ? Colors.grey.shade300 : Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
          _sideCard(
            t('ui_sequence'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(4, (i) {
                bool highlight = false;
                Color c = Colors.grey;
                if (passFlag) {
                  highlight = true;
                  c = Colors.green;
                } else if (subFlag && i == 3) {
                  highlight = true;
                  c = Colors.orange;
                } else if (i == 0 && !subFlag) {
                  highlight = true;
                  c = Colors.orange;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: highlight ? c.withOpacity(0.1) : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: highlight ? c : Colors.transparent,
                        width: 4,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${i + 1}. ${t('step_${_scen}_${i + 1}')}',
                    style: TextStyle(
                      color: highlight
                          ? c
                          : (_isDark ? Colors.grey : Colors.black54),
                      fontSize: 13,
                      fontWeight: highlight
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }),
            ),
          ),
          _sideCard(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t('ui_hints').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _playTone('click');
                    setState(() => _hintIdx++);
                  },
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
              ],
            ),
            Text(
              t(
                _hintIdx == 0
                    ? 'hint_initial'
                    : 'hint_${_scen}_${((_hintIdx - 1) % 3) + 1}',
              ),
              style: TextStyle(
                color: _isDark ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            isTitleWidget: true,
          ),
          _sideCard(
            t('ui_learnt'),
            Text(
              t('learnt_desc'),
              style: TextStyle(
                color: _isDark ? Colors.grey.shade300 : Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: const Text(
              '© ZEROSCIENCELAB - Fall in Love with Math and Science',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: 900,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: _isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.extension, color: Colors.orange, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      t('scen_${_scen + 1}'),
                      style: TextStyle(
                        color: _isDark ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(
                      t(
                        _scen == 0
                            ? 'step_0_2'
                            : (_scen == 1 ? 's2_desc' : 's3_desc'),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Current Scenario
          if (_scen == 0)
            _renderS1()
          else if (_scen == 1)
            _renderS2()
          else
            _renderS3(),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    bool passedAll = _s1Pass && _s2Pass && _s3Pass;
    return Container(
      color: _isDark ? const Color(0xFF0F172A) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: double.infinity,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _hudBtn(
                Icons.chevron_left,
                t('nav_prev'),
                _scen > 0
                    ? () {
                        _playTone('click');
                        setState(() => _scen--);
                      }
                    : null,
              ),
              const SizedBox(width: 8),
              _hudBtn(
                Icons.chevron_right,
                t('nav_next'),
                _scen < 2
                    ? () {
                        _playTone('click');
                        setState(() => _scen++);
                      }
                    : null,
                reverseIcon: true,
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _hudBtn(
                Icons.check_circle,
                t('nav_submit'),
                _submit,
                isPrimary: true,
              ),
              const SizedBox(width: 8),
              _hudBtn(
                Icons.bar_chart,
                t('nav_report'),
                passedAll
                    ? () {
                        _playTone('click');
                        setState(() => _showDiagnostics = true);
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticsModal() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      alignment: Alignment.center,
      child: Container(
        width: 450,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _isDark ? const Color(0xFF0A1936) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: const Icon(Icons.check, color: Colors.green, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('diag_title_pass'),
                        style: TextStyle(
                          color: _isDark ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        t('diag_sub_pass'),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.orange, Colors.amber],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '⭐ XP EARNED: ${_diagData!['xp']} / 10',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _diagMetric(
                            t('diag_prob'),
                            _diagData!['m']['prob'],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _diagMetric(
                            t('diag_proc'),
                            _diagData!['m']['proc'],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _diagMetric(
                            t('diag_math'),
                            _diagData!['m']['math'],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _diagMetric(
                            t('diag_logic'),
                            _diagData!['m']['logi'],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if ((_diagData!['s'] as List).isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Strengths',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      ...(_diagData!['s'] as List).map(
                        (s) => Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                t(s),
                                style: TextStyle(
                                  color: _isDark
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if ((_diagData!['i'] as List).isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Next Steps',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      ...(_diagData!['i'] as List).map(
                        (s) => Row(
                          children: [
                            const Icon(
                              Icons.arrow_right_alt,
                              color: Colors.orange,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                t(s),
                                style: TextStyle(
                                  color: _isDark
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _playTone('click');
                      setState(() => _showDiagnostics = false);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.orange.withOpacity(0.5)),
                      ),
                    ),
                    child: Text(
                      t('ui_close'),
                      style: TextStyle(
                        color: _isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _reset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      t('restart_mission'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==== UI Helpers ====
  Widget _buildField(
    String label,
    String id,
    String value, {
    bool isRoot = false,
  }) {
    bool isActive = _activeField == id;
    return GestureDetector(
      onTap: () {
        _playTone('snap');
        setState(() => _activeField = id);
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isRoot ? Colors.orange : Colors.orange.shade300,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 70,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _isDark ? const Color(0xFF061024) : Colors.grey.shade100,
              border: Border.all(
                color: isActive
                    ? Colors.orange
                    : (isRoot ? Colors.orange : Colors.orange.withOpacity(0.3)),
                width: isActive ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Text(
              value.isEmpty ? '?' : value,
              style: TextStyle(
                color: value.isEmpty
                    ? Colors.grey
                    : (_isDark ? Colors.white : Colors.black),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    String text,
    bool active,
    VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? Colors.orange
              : (_isDark ? Colors.white.withOpacity(0.08) : Colors.white),
          border: Border.all(
            color: active
                ? Colors.orangeAccent
                : (_isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.shade400),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active
                ? Colors.white
                : (_isDark ? Colors.white : Colors.black87),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF0F254A) : Colors.white,
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              1,
              2,
              3,
              4,
              5,
            ].map((d) => _keyBtn(d.toString())).toList(),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              6,
              7,
              8,
              9,
              0,
            ].map((d) => _keyBtn(d.toString())).toList(),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _keyBtn('CLR', color: Colors.red.withOpacity(0.8), flex: 2),
              _keyBtn('DEL', color: Colors.orange.withOpacity(0.8), flex: 2),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () => setState(() => _activeField = null),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.keyboard_hide,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keyBtn(String val, {Color? color, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: () => _updateActiveField(val),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color:
                  color ??
                  (_isDark ? const Color(0xFF1E3A8A) : Colors.blue.shade100),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              val,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==== Scenario 1 Render ====
  Widget _renderS1() {
    final places = [
      {'n': 4, 'p': '1000s', 'm': '×1000'},
      {'n': 0, 'p': '100s', 'm': '×100'},
      {'n': 7, 'p': '10s', 'm': '×10'},
      {'n': 5, 'p': '1s', 'm': '×1'},
    ];
    String cap = _s1Deciding == null
        ? t('s1_tap_cell')
        : (_s1Deciding == 3
              ? t('s1_units_correct')
              : '${places[_s1Deciding!]['p']} ${t('s1_wrong_place')}');

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('s1_title'),
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t('s1_desc'),
                style: TextStyle(
                  color: _isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: List.generate(4, (i) {
                  bool sel = _s1Deciding == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _playTone('snap');
                        setState(() => _s1Deciding = i);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: sel
                              ? Colors.orange.withOpacity(0.2)
                              : (_isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.grey.shade200),
                          border: Border.all(
                            color: sel
                                ? Colors.orange
                                : (i == 3
                                      ? Colors.orange
                                      : Colors.orange.withOpacity(0.4)),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${places[i]['n']}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: _isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              places[i]['p'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              places[i]['m'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: _isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Text(
                '${t('s1_deciding')} $cap',
                style: TextStyle(
                  color: _s1Deciding == 3 ? Colors.green : Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('s1_classify'),
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t('s1_classify_desc'),
                style: TextStyle(
                  color: _isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ...[4075, 320, 68].map((n) {
                var st = _s1Class[n]!;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isDark
                        ? const Color(0xFF1E293B)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$n',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              '${t('s1_units')} ${n % 10}',
                              style: TextStyle(
                                fontSize: 14,
                                color: _isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildChip('÷2', st['d2']!, () {
                        _playTone('snap');
                        setState(() => st['d2'] = !st['d2']!);
                      }),
                      const SizedBox(width: 12),
                      _buildChip('÷5', st['d5']!, () {
                        _playTone('snap');
                        setState(() => st['d5'] = !st['d5']!);
                      }),
                      const SizedBox(width: 12),
                      _buildChip('÷10', st['d10']!, () {
                        _playTone('snap');
                        setState(() => st['d10'] = !st['d10']!);
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ==== Scenario 2 Render ====
  Widget _renderS2() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('s2_title'),
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t('s2_desc'),
                style: TextStyle(
                  color: _isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  t('s2_ex'),
                  style: TextStyle(
                    color: _isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ...[427, 7309].map((n) {
                var st = _s2State[n]!;
                var digits = n.toString().split('');
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isDark
                        ? const Color(0xFF1E293B)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$n',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: _isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 24),
                          ...List.generate(digits.length, (i) {
                            return Row(
                              children: [
                                if (i > 0)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      '+',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                Container(
                                  width: 36,
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF123163),
                                        Color(0xFF0D2450),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.4),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    digits[i],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildField(t('s2_sum'), 's2_sum_$n', st['sum']),
                          const Padding(
                            padding: EdgeInsets.only(
                              bottom: 8,
                              left: 16,
                              right: 16,
                            ),
                            child: Text(
                              '→',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          _buildField(t('s2_fold'), 's2_root_$n', st['root']),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t('s2_verdict'),
                                style: TextStyle(
                                  color: Colors.orange.shade300,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildChip(
                                    t('s2_div9'),
                                    st['verdict'] == 'yes',
                                    () {
                                      _playTone('snap');
                                      setState(() => st['verdict'] = 'yes');
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _buildChip(
                                    t('s2_notdiv9'),
                                    st['verdict'] == 'no',
                                    () {
                                      _playTone('snap');
                                      setState(() => st['verdict'] = 'no');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ==== Scenario 3 Render ====
  Widget _renderS3() {
    var digits = "489710".split('');
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('s3_title'),
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(digits.length, (i) {
                  return Row(
                    children: [
                      if (i > 0)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '+',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      Container(
                        width: 42,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF123163), Color(0xFF0D2450)],
                          ),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.4),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          digits[i],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text(
                t('s3_desc'),
                style: TextStyle(
                  color: _isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildField(t('s3_sum'), 's3_r1', _s3r1),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8, left: 16, right: 16),
                    child: Text(
                      '→',
                      style: TextStyle(color: Colors.orange, fontSize: 24),
                    ),
                  ),
                  _buildField(t('s3_fold'), 's3_r2', _s3r2),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8, left: 16, right: 16),
                    child: Text(
                      '→',
                      style: TextStyle(color: Colors.orange, fontSize: 24),
                    ),
                  ),
                  _buildField(t('s3_root'), 's3_root', _s3root, isRoot: true),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('s3_mult_title'),
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t('s3_mult_desc'),
                style: TextStyle(
                  color: _isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ...[954, 483].map((n) {
                var v = _s3mult[n];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isDark
                        ? const Color(0xFF1E293B)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          '$n',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildChip(t('s3_mult'), v == 'yes', () {
                                _playTone('snap');
                                setState(() => _s3mult[n] = 'yes');
                              }),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildChip(t('s3_notmult'), v == 'no', () {
                                _playTone('snap');
                                setState(() => _s3mult[n] = 'no');
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hudBtn(
    IconData icon,
    String label,
    VoidCallback? onPressed, {
    bool isPrimary = false,
    bool reverseIcon = false,
  }) {
    return Opacity(
      opacity: onPressed == null ? 0.4 : 1.0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isPrimary
                ? Colors.orange
                : (_isDark ? const Color(0xFF1E293B) : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(24),
            border: isPrimary
                ? null
                : Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              if (!reverseIcon)
                Icon(
                  icon,
                  color: isPrimary
                      ? Colors.white
                      : (_isDark ? Colors.white : Colors.black),
                  size: 20,
                ),
              if (!reverseIcon) const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary
                      ? Colors.white
                      : (_isDark ? Colors.white : Colors.black),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (reverseIcon) const SizedBox(width: 8),
              if (reverseIcon)
                Icon(
                  icon,
                  color: isPrimary
                      ? Colors.white
                      : (_isDark ? Colors.white : Colors.black),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sideCard(
    dynamic titleWidget,
    Widget child, {
    bool isTitleWidget = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTitleWidget)
            titleWidget as Widget
          else
            Text(
              titleWidget.toString().toUpperCase(),
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _diagMetric(String label, double val) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: val,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.amber],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${(val * 100).round()}%',
            style: TextStyle(
              color: _isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
