// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use, file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class PatternExplorerIdentifyAndPredict extends StatefulWidget {
  const PatternExplorerIdentifyAndPredict({super.key});

  @override
  State<PatternExplorerIdentifyAndPredict> createState() =>
      _PatternExplorerIdentifyAndPredictState();
}

class _PatternExplorerIdentifyAndPredictState
    extends State<PatternExplorerIdentifyAndPredict>
    with TickerProviderStateMixin {
  // --- STATE ---
  bool _hasStarted = false;
  bool _isSidebarOpen = true;
  bool _showReport = false;

  int _activeScenario = 0;
  int _activePhase = 0; // 0 to 4
  int _langIndex = 0;
  final bool _isDark = true;
  final double _fontSize = 16.0;

  late AnimationController _shutterController;
  late Animation<Offset> _shutterAnimation;

  // 5 phases:
  // 0: tri-label, 1: sq-label, 2: tri-predict, 3: tri-notation, 4: sq-predict
  List<bool> _passed = [false, false, false, false, false];

  int? _triRuleChoice;
  int? _sqRuleChoice;

  // Track placements for drag and drop: map slot ID to value
  final Map<String, dynamic> _placements = {};

  // Track inputs for phase 3 and 4
  final Map<String, TextEditingController> _inputs = {};

  final ScrollController _scrollController = ScrollController();
  int _hintIdx = 0;

  // Audio Players
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  // Local audio assets (assets/audio/class9/)
  static const String _clickUrl =
      'audio/class9/click.mp3';
  static const String _successUrl =
      'audio/class9/success.mp3';
  static const String _errorUrl =
      'audio/class9/error.mp3';
  static const String _shutterUrl =
      'audio/class9/shutter.mp3';

  static const List<String> langs = ['en', 'hi'];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shutterAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1)).animate(
          CurvedAnimation(
            parent: _shutterController,
            curve: Curves.easeInOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _shutterController.dispose();
    _scrollController.dispose();
    for (var c in _inputs.values) {
      c.dispose();
    }
    super.dispose();
  }

  // Data
  final List<int> _triSequence = [1, 3, 6, 10, 15, 21, 28, 36, 45, 55];
  final List<int> _sqSequence = [1, 4, 9, 16, 25, 36, 49, 64, 81, 100];

  final Map<String, Map<String, String>> _text = {
    'en': {
      'app_title': 'Pattern Explorer: Identify and Predict Sequence Terms',
      'tagline':
          'Class 9 • Predicting What Comes Next — Sequences & Progressions',
      'init_btn': 'START MISSION',
      'obj_label': 'Mission Objective',
      'steps_label': 'Instruction Sequence',
      'obj_desc':
          'Recognise sequence patterns visually, label positions with term notation tn, and predict the next terms of triangular and square number sequences.',
      'phase_label': 'Current Phase',
      'pip_0': 'Tri Label',
      'pip_1': 'Sq Label',
      'pip_2': 'Extend',
      'pip_3': 'Notation',
      'pip_4': 'Predict',
      's1_title': 'Scenario 1 · Triangular & Square Patterns',
      's2_title': 'Scenario 2 · Term Notation & Prediction',
      'rule_title': 'Identify the growth rule',
      'rule_prompt': 'How does each term grow from the one before it?',
      'numeric_title': 'Type the term values',
      'bank_title': 'Term cards',
      'bank_hint':
          'Drag a card onto its slot. You can move cards again any time before you pass.',
      'tray_hint_cards': 'Cards = your term tokens',
      'btn_prev': 'Prev',
      'btn_next': 'Next',
      'btn_hint': 'Hint',
      'btn_submit': 'Submit',
      'btn_report': 'Report',
      'btn_close_report': 'Close Report',
      'btn_prev_scen': 'Prev Scenario',
      'btn_next_scen': 'Next Scenario',
      'btn_restart_exp': 'Restart Exploration',
      'scenario_lbl': 'Scenario',
      'hint_lbl': 'Hint / Evidence',
      'learnt_lbl': 'Learnt Conclusion',
      'hint_def':
          'Ask students what number comes next and why before they place a card. Keep attention on the visible growth between terms.',
      'learnt_desc':
          'A sequence is an ordered list of terms t1, t2, t3, … . Triangular numbers grow by adding the next natural number; square numbers grow by adding the next odd number. Term notation lets us name and predict any position.',
      'diag_title_pass': 'Mission Complete!',
      'diag_sub_pass': 'You successfully identified and extended sequences.',
      'diag_title_fail': 'Keep Exploring',
      'diag_sub_fail':
          'Some steps still need work — your data is kept, adjust and resubmit.',
      'diag_str': 'Strengths',
      'diag_nxt': 'Next Steps',
      'ph_tri_lbl_t': 'Label Triangular Numbers',
      'ph_tri_lbl_m':
          'Drag term cards t1–t5 onto the matching triangular dot figures.',
      'ph_sq_lbl_t': 'Label Square Numbers',
      'ph_sq_lbl_m':
          'Drag term cards t1–t6 onto the matching square dot figures.',
      'ph_tri_pred_t': 'Predict Triangular Terms',
      'ph_tri_pred_m':
          'Drag value cards into the empty slots to extend the triangular sequence.',
      'ph_tri_not_t': 'Write Triangular Terms',
      'ph_tri_not_m':
          'Type the values of t5, t6, t7 and t8 for the triangular sequence.',
      'ph_sq_pred_t': 'Predict Square Terms',
      'ph_sq_pred_m': 'Type the next four square numbers t7, t8, t9 and t10.',
      'st_0_0': 'Choose the growth rule for triangular numbers.',
      'st_0_1': 'Drag term cards t1–t5 onto the five triangular figures.',
      'st_0_2': 'Press Submit to check your term labels.',
      'st_1_0': 'Choose the growth rule for square numbers.',
      'st_1_1': 'Drag term cards t1–t6 onto the six square figures.',
      'st_1_2': 'Press Submit to check your labels.',
      'st_1_3': 'Press Next to move on to prediction.',
      'st_2_0': 'Read the triangular sequence 1, 3, 6, 10, 15.',
      'st_2_1': 'Drag the correct value cards into the t6, t7, t8 slots.',
      'st_2_2': 'Press Submit to check your prediction.',
      'st_3_0': 'Recall t5–t8 of the triangular sequence.',
      'st_3_1': 'Type each term value in its input field.',
      'st_3_2': 'Press Submit to check your notation.',
      'st_4_0': 'Study the square sequence up to t6 = 36.',
      'st_4_1': 'Predict and type t7, t8, t9, t10.',
      'st_4_2': 'Press Submit to finish the mission.',
      'rule_tri_p':
          'Triangular numbers: 1, 3, 6, 10, 15 … how does each term grow?',
      'rule_tri_o0': 'Add the next natural number (+2, +3, +4 …)',
      'rule_tri_o1': 'Add the next odd number (+3, +5, +7 …)',
      'rule_tri_o2': 'Multiply by 2 each time',
      'rule_tri_o3': 'Add a constant 3 each time',
      'rule_sq_p': 'Square numbers: 1, 4, 9, 16, 25 … how does each term grow?',
      'rule_sq_o0': 'Add the next odd number (+3, +5, +7 …)',
      'rule_sq_o1': 'Add the next natural number (+2, +3, +4 …)',
      'rule_sq_o2': 'Multiply by 3 each time',
      'rule_sq_o3': 'Add a constant 4 each time',
      'pat_tri_t': 'Triangular number figures',
      'pat_tri_h': 'Count the dots and drop the matching term card.',
      'pat_sq_t': 'Square number figures',
      'pat_sq_h': 'Drop the matching term card.',
      'pat_ex_tri_t': 'Extend the triangular sequence',
      'pat_ex_tri_h': 'Drag value cards into the slots.',
      'pat_not_tri_t': 'Triangular sequence so far',
      'pat_not_tri_h': 'Use the rule tn = sum of first n natural numbers.',
      'pat_ex_sq_t': 'Square sequence so far',
      'pat_ex_sq_h': 'Each square number is n × n.',
      'num_not_t': 'Write t5, t6, t7, t8',
      'num_not_h': 'Type each term value.',
      'num_sq_t': 'Predict t7, t8, t9, t10',
      'num_sq_h': 'Type the next four square numbers.',
      'tray_tri': 'Cards t1–t5',
      'tray_sq': 'Cards t1–t6',
      'tray_val': 'Pick the right values',
      'tray_type': 'Type the values',
      'flash_pass': '✅ Correct!',
      'flash_fail': '❌ Not quite right. Adjust and try again.',
      'pos': 'pos',
      'val_cards': 'Value cards',
      'msg_err_fill': 'Please fill all slots and select a rule!',
      'set_title': 'Settings',
      'set_theme': 'Dark Theme',
      'set_theme_desc': 'Switch to dark mode interface',
      'set_font': 'Board Font Size',
      'set_font_desc': 'Adjust Teacher Board text',
    },
    'hi': {
      'app_title': 'पैटर्न अन्वेषक: अनुक्रम पदों को पहचानें',
      'tagline': 'कक्षा 9 • आगे क्या आएगा इसकी भविष्यवाणी — अनुक्रम और प्रगति',
      'init_btn': 'मिशन शुरू करें',
      'obj_label': 'मिशन का उद्देश्य',
      'steps_label': 'अनुदेश अनुक्रम',
      'obj_desc':
          'दृश्यात्मक रूप से अनुक्रम पैटर्न को पहचानें, स्थितियों को पद संकेतन tn के साथ लेबल करें, और त्रिकोणीय और वर्ग संख्या अनुक्रमों के अगले पदों की भविष्यवाणी करें।',
      'phase_label': 'वर्तमान चरण',
      'pip_0': 'त्रिकोणीय लेबल',
      'pip_1': 'वर्ग लेबल',
      'pip_2': 'विस्तार करें',
      'pip_3': 'संकेतन',
      'pip_4': 'भविष्यवाणी',
      's1_title': 'परिदृश्य 1 · त्रिकोणीय और वर्ग पैटर्न',
      's2_title': 'परिदृश्य 2 · पद संकेतन और भविष्यवाणी',
      'rule_title': 'विकास नियम को पहचानें',
      'rule_prompt': 'प्रत्येक पद अपने से पहले वाले पद से कैसे बढ़ता है?',
      'numeric_title': 'पद के मान टाइप करें',
      'bank_title': 'पद कार्ड',
      'bank_hint':
          'कार्ड को उसके स्लॉट पर खींचें। आप पास होने से पहले किसी भी समय कार्ड को फिर से ले जा सकते हैं।',
      'tray_hint_cards': 'कार्ड = आपके पद टोकन',
      'btn_prev': 'पिछला',
      'btn_next': 'अगला',
      'btn_hint': 'संकेत',
      'btn_submit': 'सबमिट',
      'btn_report': 'रिपोर्ट',
      'btn_close_report': 'रिपोर्ट बंद करें',
      'btn_prev_scen': 'पिछला परिदृश्य',
      'btn_next_scen': 'अगला परिदृश्य',
      'btn_restart_exp': 'अन्वेषण पुनरारंभ करें',
      'scenario_lbl': 'परिदृश्य',
      'hint_lbl': 'संकेत / साक्ष्य',
      'learnt_lbl': 'सीखा हुआ निष्कर्ष',
      'hint_def':
          'छात्रों से पूछें कि कार्ड रखने से पहले अगली कौन सी संख्या आती है और क्यों। पदों के बीच दिखाई देने वाले विकास पर ध्यान दें।',
      'learnt_desc':
          'अनुक्रम t1, t2, t3, … पदों की एक क्रमित सूची है। त्रिकोणीय संख्याएँ अगली प्राकृत संख्या जोड़ने से बढ़ती हैं; वर्ग संख्याएँ अगली विषम संख्या जोड़ने से बढ़ती हैं। पद संकेतन हमें किसी भी स्थिति का नाम देने और भविष्यवाणी करने की सुविधा देता है।',
      'diag_title_pass': 'मिशन पूरा हुआ!',
      'diag_sub_pass':
          'आपने अनुक्रमों की सफलतापूर्वक पहचान की और उनका विस्तार किया।',
      'diag_title_fail': 'अन्वेषण जारी रखें',
      'diag_sub_fail':
          'कुछ चरणों में अभी भी काम करने की आवश्यकता है — आपका डेटा रखा गया है, समायोजित करें और फिर से सबमिट करें।',
      'diag_str': 'ताकत',
      'diag_nxt': 'अगले कदम',
      'ph_tri_lbl_t': 'त्रिकोणीय संख्याओं को लेबल करें',
      'ph_tri_lbl_m':
          'मिलान करने वाले त्रिकोणीय बिंदु आकृतियों पर पद कार्ड t1–t5 खींचें।',
      'ph_sq_lbl_t': 'वर्ग संख्याओं को लेबल करें',
      'ph_sq_lbl_m':
          'मिलान करने वाले वर्ग बिंदु आकृतियों पर पद कार्ड t1–t6 खींचें।',
      'ph_tri_pred_t': 'त्रिकोणीय पदों की भविष्यवाणी करें',
      'ph_tri_pred_m':
          'त्रिकोणीय अनुक्रम का विस्तार करने के लिए खाली स्लॉट में मान कार्ड खींचें।',
      'ph_tri_not_t': 'त्रिकोणीय पद लिखें',
      'ph_tri_not_m':
          'त्रिकोणीय अनुक्रम के लिए t5, t6, t7 और t8 के मान टाइप करें।',
      'ph_sq_pred_t': 'वर्ग पदों की भविष्यवाणी करें',
      'ph_sq_pred_m': 'अगली चार वर्ग संख्याएँ t7, t8, t9 और t10 टाइप करें।',
      'st_0_0': 'त्रिकोणीय संख्याओं के लिए विकास नियम चुनें।',
      'st_0_1': 'पांच त्रिकोणीय आकृतियों पर पद कार्ड t1–t5 खींचें।',
      'st_0_2': 'अपने पद लेबलों की जांच करने के लिए सबमिट दबाएं।',
      'st_1_0': 'वर्ग संख्याओं के लिए विकास नियम चुनें।',
      'st_1_1': 'छह वर्ग आकृतियों पर पद कार्ड t1–t6 खींचें।',
      'st_1_2': 'अपने लेबलों की जांच करने के लिए सबमिट दबाएं।',
      'st_1_3': 'भविष्यवाणी पर जाने के लिए अगला दबाएं।',
      'st_2_0': 'त्रिकोणीय अनुक्रम 1, 3, 6, 10, 15 पढ़ें।',
      'st_2_1': 't6, t7, t8 स्लॉट में सही मान कार्ड खींचें।',
      'st_2_2': 'अपनी भविष्यवाणी की जांच करने के लिए सबमिट दबाएं।',
      'st_3_0': 'त्रिकोणीय अनुक्रम के t5–t8 को याद करें।',
      'st_3_1': 'प्रत्येक पद का मान उसके इनपुट फ़ील्ड में टाइप करें।',
      'st_3_2': 'अपने संकेतन की जांच करने के लिए सबमिट दबाएं।',
      'st_4_0': 't6 = 36 तक वर्ग अनुक्रम का अध्ययन करें।',
      'st_4_1': 't7, t8, t9, t10 की भविष्यवाणी करें और टाइप करें।',
      'st_4_2': 'मिशन समाप्त करने के लिए सबमिट दबाएं।',
      'rule_tri_p':
          'त्रिकोणीय संख्याएँ: 1, 3, 6, 10, 15 … प्रत्येक पद कैसे बढ़ता है?',
      'rule_tri_o0': 'अगली प्राकृत संख्या जोड़ें (+2, +3, +4 …)',
      'rule_tri_o1': 'अगली विषम संख्या जोड़ें (+3, +5, +7 …)',
      'rule_tri_o2': 'हर बार 2 से गुणा करें',
      'rule_tri_o3': 'हर बार एक स्थिरांक 3 जोड़ें',
      'rule_sq_p':
          'वर्ग संख्याएँ: 1, 4, 9, 16, 25 … प्रत्येक पद कैसे बढ़ता है?',
      'rule_sq_o0': 'अगली विषम संख्या जोड़ें (+3, +5, +7 …)',
      'rule_sq_o1': 'अगली प्राकृत संख्या जोड़ें (+2, +3, +4 …)',
      'rule_sq_o2': 'हर बार 3 से गुणा करें',
      'rule_sq_o3': 'हर बार एक स्थिरांक 4 जोड़ें',
      'pat_tri_t': 'त्रिकोणीय संख्या आकृतियाँ',
      'pat_tri_h': 'बिंदुओं को गिनें और मिलान करने वाला पद कार्ड छोड़ें।',
      'pat_sq_t': 'वर्ग संख्या आकृतियाँ',
      'pat_sq_h': 'मिलान करने वाला पद कार्ड छोड़ें।',
      'pat_ex_tri_t': 'त्रिकोणीय अनुक्रम का विस्तार करें',
      'pat_ex_tri_h': 'स्लॉट में मान कार्ड खींचें।',
      'pat_not_tri_t': 'अब तक का त्रिकोणीय अनुक्रम',
      'pat_not_tri_h':
          'नियम tn = पहली n प्राकृत संख्याओं का योग का उपयोग करें।',
      'pat_ex_sq_t': 'अब तक का वर्ग अनुक्रम',
      'pat_ex_sq_h': 'प्रत्येक वर्ग संख्या n × n है।',
      'num_not_t': 't5, t6, t7, t8 लिखें',
      'num_not_h': 'प्रत्येक पद का मान टाइप करें।',
      'num_sq_t': 't7, t8, t9, t10 की भविष्यवाणी करें',
      'num_sq_h': 'अगली चार वर्ग संख्याएँ टाइप करें।',
      'tray_tri': 'कार्ड t1–t5',
      'tray_sq': 'कार्ड t1–t6',
      'tray_val': 'सही मान चुनें',
      'tray_type': 'मान टाइप करें',
      'flash_pass': '✅ सही!',
      'flash_fail': '❌ पूरी तरह सही नहीं। समायोजित करें और पुनः प्रयास करें।',
      'pos': 'स्थिति',
      'val_cards': 'मान कार्ड',
      'msg_err_fill': 'कृपया सभी स्लॉट भरें और नियम चुनें!',
      'set_title': 'सेटिंग्स',
      'set_theme': 'डार्क थीम',
      'set_theme_desc': 'डार्क मोड इंटरफेस पर स्विच करें',
      'set_font': 'बोर्ड फ़ॉन्ट आकार',
      'set_font_desc': 'शिक्षक बोर्ड टेक्स्ट समायोजित करें',
    },
  };

  String t(String key) {
    return _text[langs[_langIndex]]?[key] ?? _text['en']![key] ?? key;
  }

  void _showSnack(String msg, Color c) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: c,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _playClick() {
    _clickPlayer.play(AssetSource(_clickUrl));
  }

  void _playError() {
    _errorPlayer.play(AssetSource(_errorUrl));
  }

  void _playSuccess() {
    _successPlayer.play(AssetSource(_successUrl));
  }

  void _startMission() {
    _playClick();
    _fxPlayer.play(AssetSource(_shutterUrl));
    _shutterController.forward().then((_) {
      setState(() => _hasStarted = true);
    });
  }

  void _reset() {
    _shutterController.reverse();
    setState(() {
      _hasStarted = false;
      _activeScenario = 0;
      _activePhase = 0;
      _langIndex = 0;
      _passed = [false, false, false, false, false];
      _triRuleChoice = null;
      _sqRuleChoice = null;
      _placements.clear();
      _inputs.clear();
      _hintIdx = 0;
    });
  }

  // === UI HELPER WIDGETS ===
  Widget _buildGlassPanel({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _isDark
            ? const Color(0xDA0B234D)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isDark ? const Color(0x66F97316) : const Color(0x4DF97316),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildActivityPanel({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF0B234D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isDark ? Colors.white12 : Colors.black12),
      ),
      child: child,
    );
  }

  // === SIDEBAR (Teacher Board) ===
  Widget _buildSidebar() {
    return _buildGlassPanel(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 64,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.amber],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.category,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('app_title').toUpperCase(),
                              style: TextStyle(
                                color: _isDark ? Colors.white : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              t('tagline'),
                              style: const TextStyle(
                                color: Colors.orange,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.language, size: 16),
                        label: Text(
                          langs[_langIndex].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: _isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () {
                          _playClick();
                          setState(() {
                            _langIndex = (_langIndex + 1) % langs.length;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        color: _isDark ? Colors.white : Colors.black,
                        onPressed: () {
                          _playClick();
                          _reset();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),

                  _buildSidebarSection(
                    Icons.my_location,
                    t('obj_label'),
                    t('obj_desc'),
                  ),
                  const SizedBox(height: 12),
                  _buildScenarioDropdown(),
                  const SizedBox(height: 12),
                  _buildPhaseLabelForSidebar(), // <--- ADDDED HERE
                  const SizedBox(height: 12),
                  _buildStepsList(),
                  const SizedBox(height: 12),
                  _buildSidebarSection(
                    Icons.lightbulb,
                    t('hint_lbl'),
                    t('hint_def'),
                  ),
                  const SizedBox(height: 12),
                  _buildSidebarSection(
                    Icons.school,
                    t('learnt_lbl'),
                    t('learnt_desc'),
                  ),
                ],
              ),
            ),
          ),
          // Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isDark
                  ? const Color(0xD80F172A)
                  : const Color(0xFFE2E8F0),
              border: Border(
                top: BorderSide(
                  color: _isDark ? Colors.white12 : Colors.black12,
                ),
              ),
            ),
            child: const Text(
              '© ZEROSCIENCELAB | Fall in Love with Math and Science',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseLabelForSidebar() {
    String pTitle = "";
    String pDesc = "";
    if (_activePhase == 0) {
      pTitle = t('ph_tri_lbl_t');
      pDesc = t('ph_tri_lbl_m');
    } else if (_activePhase == 1) {
      pTitle = t('ph_sq_lbl_t');
      pDesc = t('ph_sq_lbl_m');
    } else if (_activePhase == 2) {
      pTitle = t('ph_tri_pred_t');
      pDesc = t('ph_tri_pred_m');
    } else if (_activePhase == 3) {
      pTitle = t('ph_tri_not_t');
      pDesc = t('ph_tri_not_m');
    } else if (_activePhase == 4) {
      pTitle = t('ph_sq_pred_t');
      pDesc = t('ph_sq_pred_m');
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF0F2C60) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                t('phase_label').toUpperCase(),
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pTitle,
            style: TextStyle(
              color: _isDark ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pDesc,
            style: TextStyle(
              color: _isDark ? Colors.white70 : Colors.black54,
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarSection(IconData icon, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF071B3F) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: _isDark ? Colors.white : Colors.black87,
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioDropdown() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF071B3F) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.map, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                t('scenario_lbl').toUpperCase(),
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _isDark ? const Color(0xFF0F2C60) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _activeScenario,
                dropdownColor: _isDark ? const Color(0xFF0F2C60) : Colors.white,
                isExpanded: true,
                style: TextStyle(
                  color: _isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                items: [0, 1]
                    .map(
                      (i) => DropdownMenuItem(
                        value: i,
                        child: Text(t('s${i + 1}_title')),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null && val != _activeScenario) {
                    _playClick();
                    setState(() {
                      _activeScenario = val;
                      _activePhase = val == 0 ? 0 : 3;
                      _hintIdx = 0;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _activeScenario == 0
                      ? null
                      : () {
                          _playClick();
                          setState(() {
                            _activeScenario = 0;
                            _activePhase = 0;
                            _hintIdx = 0;
                          });
                        },
                  icon: const Icon(Icons.arrow_left, size: 16),
                  label: Text(
                    t('btn_prev_scen'),
                    style: const TextStyle(fontSize: 10),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isDark
                        ? const Color(0xFF1E293B)
                        : Colors.grey.shade300,
                    foregroundColor: _isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _activeScenario == 1
                      ? null
                      : () {
                          _playClick();
                          setState(() {
                            _activeScenario = 1;
                            _activePhase = 3;
                            _hintIdx = 0;
                          });
                        },
                  icon: const Icon(Icons.arrow_right, size: 16),
                  label: Text(
                    t('btn_next_scen'),
                    style: const TextStyle(fontSize: 10),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isDark
                        ? const Color(0xFF1E293B)
                        : Colors.grey.shade300,
                    foregroundColor: _isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Number of procedural steps per phase (phase 1 has four, the rest three).
  static const List<int> _stepCountByPhase = [3, 4, 3, 3, 3];

  Widget _buildStepsList() {
    final List<String> steps = List.generate(
      _stepCountByPhase[_activePhase],
      (i) => t('st_${_activePhase}_$i'),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF071B3F) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t('steps_label').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: List.generate(steps.length, (i) {
              bool isDone = _passed[_activePhase];
              bool isActive = !isDone && _hintIdx == i;
              Color bg = isActive
                  ? Colors.orange.withOpacity(0.15)
                  : (_isDark ? Colors.white12 : Colors.black12);
              Color border = isDone
                  ? Colors.green
                  : (isActive ? Colors.orange : Colors.transparent);
              Color textCol = isDone
                  ? Colors.green
                  : (isActive
                        ? (_isDark ? Colors.white : Colors.black)
                        : Colors.grey);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border(left: BorderSide(color: border, width: 4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        steps[i],
                        style: TextStyle(
                          color: textCol,
                          fontSize: _fontSize * 0.85,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // === CANVAS (Main Activity) ===
  Widget _buildCanvas() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -1),
          radius: 1.5,
          colors: _isDark
              ? [
                  const Color(0xFF0E2A5E),
                  const Color(0xFF0A1F45),
                  const Color(0xFF071B3F),
                ]
              : [
                  const Color(0xFFCBD5E1),
                  const Color(0xFFE2E8F0),
                  const Color(0xFFF1F5F9),
                ],
          stops: const [0, 0.6, 1],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isDark ? Colors.white12 : Colors.black12),
      ),
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HUD and Ribbon Row
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 12,
              children: [_buildMiniMissionHUD(), _buildMilestoneRibbon()],
            ),
            const SizedBox(height: 24),

            // Panels
            if (_activePhase < 2) _buildRulePanel(),
            if (_activePhase < 2) const SizedBox(height: 16),

            _buildPatternPanel(),
            const SizedBox(height: 16),

            if (_activePhase >= 3) _buildNumericPanel(),
            if (_activePhase >= 3) const SizedBox(height: 16),

            if (_activePhase < 3) _buildBankPanel(),
            if (_activePhase < 3) const SizedBox(height: 16),

            _buildControlBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMissionHUD() {
    String pTitle = "";
    String pDesc = "";
    if (_activePhase == 0) {
      pTitle = t('ph_tri_lbl_t');
      pDesc = t('ph_tri_lbl_m');
    } else if (_activePhase == 1) {
      pTitle = t('ph_sq_lbl_t');
      pDesc = t('ph_sq_lbl_m');
    } else if (_activePhase == 2) {
      pTitle = t('ph_tri_pred_t');
      pDesc = t('ph_tri_pred_m');
    } else if (_activePhase == 3) {
      pTitle = t('ph_tri_not_t');
      pDesc = t('ph_tri_not_m');
    } else if (_activePhase == 4) {
      pTitle = t('ph_sq_pred_t');
      pDesc = t('ph_sq_pred_m');
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDark
            ? const Color(0xD808152E)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isDark ? Colors.white12 : Colors.black12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('phase_label').toUpperCase(),
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pTitle,
            style: TextStyle(
              color: _isDark ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            pDesc,
            style: TextStyle(
              color: _isDark ? Colors.white70 : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneRibbon() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _isDark
            ? const Color(0xD808152E)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _isDark ? Colors.white12 : Colors.black12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(5, (i) {
          bool isActive = i == _activePhase;
          bool isDone = _passed[i];
          Color bg = isActive
              ? Colors.orange
              : (isDone ? Colors.green.withOpacity(0.2) : Colors.transparent);
          Color textCol = isActive
              ? Colors.white
              : (isDone ? Colors.green : Colors.grey);
          Color dotCol = isActive
              ? Colors.white
              : (isDone ? Colors.green : Colors.grey);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotCol,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  t('pip_$i'),
                  style: TextStyle(
                    color: textCol,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isDark
            ? const Color(0xD808152E)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isDark ? Colors.white12 : Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Text(
                _activePhase < 2
                    ? t('tray_hint_cards')
                    : (_activePhase == 2 ? t('tray_val') : t('tray_type')),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _activePhase > 0
                    ? () {
                        _playClick();
                        setState(() {
                          _activePhase--;
                          _activeScenario = _activePhase < 3 ? 0 : 1;
                          _hintIdx = 0;
                        });
                      }
                    : null,
                icon: const Icon(Icons.arrow_left),
                label: Text(t('btn_prev')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDark
                      ? const Color(0xFF1E293B)
                      : Colors.grey.shade300,
                  foregroundColor: _isDark ? Colors.white : Colors.black,
                ),
              ),
              ElevatedButton.icon(
                onPressed: (_passed[_activePhase] && _activePhase < 4)
                    ? () {
                        _playClick();
                        setState(() {
                          _activePhase++;
                          _activeScenario = _activePhase < 3 ? 0 : 1;
                          _hintIdx = 0;
                        });
                      }
                    : null,
                icon: const Icon(Icons.arrow_right),
                label: Text(t('btn_next')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDark
                      ? const Color(0xFF1E293B)
                      : Colors.grey.shade300,
                  foregroundColor: _isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              ElevatedButton.icon(
                onPressed: () {
                  _playClick();
                  _showSnack(t('hint_def'), Colors.white70);
                  setState(
                    () => _hintIdx = min(
                      _stepCountByPhase[_activePhase] - 1,
                      _hintIdx + 1,
                    ),
                  );
                },
                icon: const Icon(Icons.lightbulb, color: Colors.yellow),
                label: Text(t('btn_hint')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDark
                      ? const Color(0xFF1E293B)
                      : Colors.grey.shade300,
                  foregroundColor: _isDark ? Colors.white : Colors.black,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _playClick();
                  _submitPhase();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  t('btn_submit').toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              if (_passed.every((p) => p))
                ElevatedButton.icon(
                  onPressed: () {
                    _playClick();
                    setState(() => _showReport = true);
                  },
                  icon: const Icon(Icons.pie_chart),
                  label: Text(t('btn_report')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // === PANELS ===
  Widget _buildRulePanel() {
    List<String> options = _activePhase == 0
        ? [
            t('rule_tri_o0'),
            t('rule_tri_o1'),
            t('rule_tri_o2'),
            t('rule_tri_o3'),
          ]
        : [t('rule_sq_o0'), t('rule_sq_o1'), t('rule_sq_o2'), t('rule_sq_o3')];

    int? currentChoice = _activePhase == 0 ? _triRuleChoice : _sqRuleChoice;

    return _buildActivityPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('rule_title'),
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _activePhase == 0 ? t('rule_tri_p') : t('rule_sq_p'),
            style: TextStyle(
              color: _isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(options.length, (i) {
              bool isSelected = currentChoice == i;
              return InkWell(
                onTap: () {
                  if (_passed[_activePhase]) return;
                  _playClick();
                  setState(() {
                    if (_activePhase == 0)
                      _triRuleChoice = i;
                    else
                      _sqRuleChoice = i;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.orange
                        : (_isDark
                              ? const Color(0xFF0F2C60)
                              : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.orange
                          : (_isDark ? Colors.white12 : Colors.black12),
                    ),
                  ),
                  child: Text(
                    options[i],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (_isDark ? Colors.white : Colors.black),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternPanel() {
    String title = "";
    String hint = "";
    if (_activePhase == 0) {
      title = t('pat_tri_t');
      hint = t('pat_tri_h');
    } else if (_activePhase == 1) {
      title = t('pat_sq_t');
      hint = t('pat_sq_h');
    } else if (_activePhase == 2) {
      title = t('pat_ex_tri_t');
      hint = t('pat_ex_tri_h');
    } else if (_activePhase == 3) {
      title = t('pat_not_tri_t');
      hint = t('pat_not_tri_h');
    } else if (_activePhase == 4) {
      title = t('pat_ex_sq_t');
      hint = t('pat_ex_sq_h');
    }

    return _buildActivityPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: TextStyle(
              color: _isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _buildSequenceRow()),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSequenceRow() {
    List<Widget> row = [];
    if (_activePhase == 0 || _activePhase == 1) {
      List<int> vals = _activePhase == 0
          ? _triSequence.sublist(0, 5)
          : _sqSequence.sublist(0, 6);
      for (int i = 0; i < vals.length; i++) {
        if (i > 0) {
          row.add(
            Column(
              children: [
                Text(
                  '+${vals[i] - vals[i - 1]}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Icon(Icons.arrow_right, color: Colors.orange),
              ],
            ),
          );
        }
        String slotId = 'p${_activePhase}_pos_${i + 1}';
        bool isFilled = _placements.containsKey(slotId);

        row.add(
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isDark
                  ? const Color(0xFF0F2C60)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${t('pos')} ${i + 1}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CustomPaint(
                    painter: _activePhase == 0
                        ? TriangleDotsPainter(i + 1)
                        : SquareDotsPainter(i + 1),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${vals[i]}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                DragTarget<Object>(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 50,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isFilled
                            ? Colors.transparent
                            : (_isDark
                                  ? const Color(0xFF071B3F)
                                  : Colors.white),
                        border: isFilled
                            ? null
                            : Border.all(
                                color: candidateData.isNotEmpty
                                    ? Colors.orange
                                    : Colors.grey,
                                style: BorderStyle.solid,
                              ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isFilled
                          ? _buildPlacedTile(slotId)
                          : const Text(
                              't?',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                  // A filled slot also accepts a drop: the new card replaces
                  // the old one, which returns to the bank automatically.
                  onWillAcceptWithDetails: (details) => !_passed[_activePhase],
                  onAcceptWithDetails: (details) {
                    setState(() {
                      _placements[slotId] = details.data;
                    });
                    _playClick();
                  },
                ),
              ],
            ),
          ),
        );
      }
    } else if (_activePhase == 2 || _activePhase == 3 || _activePhase == 4) {
      // Phases 2, 3, 4
      List<int> known;
      if (_activePhase == 2)
        known = _triSequence.sublist(0, 5); // [1, 3, 6, 10, 15]
      else if (_activePhase == 3)
        known = _triSequence.sublist(0, 4); // [1, 3, 6, 10]
      else
        known = _sqSequence.sublist(0, 6); // [1, 4, 9, 16, 25, 36]

      List<String> targets = _activePhase == 2
          ? ['pos_6', 'pos_7', 'pos_8']
          : [];

      for (int i = 0; i < known.length; i++) {
        if (i > 0) {
          row.add(
            Column(
              children: [
                Text(
                  '+${known[i] - known[i - 1]}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Icon(Icons.arrow_right, color: Colors.orange),
              ],
            ),
          );
        }
        row.add(
          Column(
            children: [
              Text(
                't${i + 1}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 50,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isDark
                      ? const Color(0xFF0F2C60)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: Text(
                  '${known[i]}',
                  style: TextStyle(
                    color: _isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (_activePhase == 2) {
        for (int i = 0; i < targets.length; i++) {
          row.add(
            Column(
              children: [
                const Text(
                  '?',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Icon(Icons.arrow_right, color: Colors.orange),
              ],
            ),
          );
          String slotId = 'p${_activePhase}_${targets[i]}';
          bool isFilled = _placements.containsKey(slotId);

          row.add(
            Column(
              children: [
                Text(
                  't${known.length + i + 1}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                DragTarget<Object>(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 50,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isFilled
                            ? Colors.transparent
                            : (_isDark
                                  ? const Color(0xFF071B3F)
                                  : Colors.white),
                        border: isFilled
                            ? null
                            : Border.all(
                                color: candidateData.isNotEmpty
                                    ? Colors.orange
                                    : Colors.grey,
                                style: BorderStyle.solid,
                              ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isFilled
                          ? _buildPlacedTile(slotId)
                          : const Text(
                              '?',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                  // A filled slot also accepts a drop: the new card replaces
                  // the old one, which returns to the bank automatically.
                  onWillAcceptWithDetails: (details) => !_passed[_activePhase],
                  onAcceptWithDetails: (details) {
                    setState(() {
                      _placements[slotId] = details.data;
                    });
                    _playClick();
                  },
                ),
              ],
            ),
          );
        }
      }
    }
    return row;
  }

  Widget _buildNumericPanel() {
    List<String> targetLabels = _activePhase == 3
        ? ['t5', 't6', 't7', 't8']
        : ['t7', 't8', 't9', 't10'];
    List<String> targetKeys = _activePhase == 3
        ? ['n5', 'n6', 'n7', 'n8']
        : ['s7', 's8', 's9', 's10'];

    for (var k in targetKeys) {
      if (!_inputs.containsKey(k)) _inputs[k] = TextEditingController();
    }

    return _buildActivityPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t(_activePhase == 3 ? 'num_not_t' : 'num_sq_t'),
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t(_activePhase == 3 ? 'num_not_h' : 'num_sq_h'),
            style: TextStyle(
              color: _isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(targetLabels.length, (i) {
              return Column(
                children: [
                  Text(
                    targetLabels[i],
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 70,
                    height: 50,
                    child: TextField(
                      controller: _inputs[targetKeys[i]],
                      enabled: !_passed[_activePhase],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isDark ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _isDark
                            ? const Color(0xFF0F2C60)
                            : const Color(0xFFF1F5F9),
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.orange,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        _playClick();
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBankPanel() {
    List<String> items = [];
    if (_activePhase == 0) {
      items = ['t4', 't2', 't5', 't1', 't3'];
    } else if (_activePhase == 1) {
      items = ['t3', 't6', 't1', 't4', 't2', 't5'];
    } else if (_activePhase == 2) {
      items = ['21', '28', '36', '20', '25', '45'];
    }

    List<String> currentPhasePlacements = _placements.entries
        .where((e) => e.key.startsWith('p${_activePhase}_'))
        .map((e) => e.value.toString())
        .toList();
    List<String> available = items
        .where((i) => !currentPhasePlacements.contains(i))
        .toList();

    return _buildActivityPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('bank_title'),
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t('bank_hint'),
            style: TextStyle(
              color: _isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: available
                .map(
                  (item) => Draggable<Object>(
                    data: item,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _buildTile(item, true),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _buildTile(item, false),
                    ),
                    child: _buildTile(item, false),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  /// A card sitting in a slot. Tapping it (before the phase is passed) sends
  /// it back to the bank so the learner can correct a wrong placement.
  Widget _buildPlacedTile(String slotId) {
    return GestureDetector(
      onTap: _passed[_activePhase]
          ? null
          : () {
              setState(() => _placements.remove(slotId));
              _playClick();
            },
      child: _buildTile('${_placements[slotId]}', false),
    );
  }

  Widget _buildTile(String text, bool isDragging) {
    bool isTerm = text.startsWith('t');
    return Container(
      width: 50,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTerm
              ? [const Color(0xFFFB923C), const Color(0xFFEA580C)]
              : [const Color(0xFFE2E8F0), const Color(0xFF94A3B8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          if (isDragging)
            const BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              offset: Offset(0, 6),
            )
          else
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF08152E),
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // === SUBMIT ===
  void _submitPhase() {
    if (_activePhase == 0) {
      int count = _placements.keys.where((k) => k.startsWith('p0_')).length;
      if (_triRuleChoice == null || count < 5) {
        _showSnack(t('msg_err_fill'), Colors.redAccent);
        _playError();
        return;
      }
      bool pass = _triRuleChoice == 0;
      for (int i = 0; i < 5; i++) {
        if (_placements['p0_pos_${i + 1}'] != 't${i + 1}') pass = false;
      }
      if (pass) {
        _passPhase();
      } else {
        _failPhase();
      }
    } else if (_activePhase == 1) {
      int count = _placements.keys.where((k) => k.startsWith('p1_')).length;
      if (_sqRuleChoice == null || count < 6) {
        _showSnack(t('msg_err_fill'), Colors.redAccent);
        _playError();
        return;
      }
      bool pass = _sqRuleChoice == 0;
      for (int i = 0; i < 6; i++) {
        if (_placements['p1_pos_${i + 1}'] != 't${i + 1}') pass = false;
      }
      if (pass) {
        _passPhase();
      } else {
        _failPhase();
      }
    } else if (_activePhase == 2) {
      int count = _placements.keys.where((k) => k.startsWith('p2_')).length;
      if (count < 3) {
        _showSnack(t('msg_err_fill'), Colors.redAccent);
        _playError();
        return;
      }
      if (_placements['p2_pos_6'] == '21' &&
          _placements['p2_pos_7'] == '28' &&
          _placements['p2_pos_8'] == '36') {
        _passPhase();
      } else {
        _failPhase();
      }
    } else if (_activePhase == 3) {
      _checkTypedAnswers(const {'n5': 15, 'n6': 21, 'n7': 28, 'n8': 36});
    } else if (_activePhase == 4) {
      _checkTypedAnswers(const {'s7': 49, 's8': 64, 's9': 81, 's10': 100});
    }
  }

  /// Grades typed answers, ignoring surrounding spaces and leading zeros.
  /// Empty fields get the "fill all" message instead of a wrong-answer one.
  void _checkTypedAnswers(Map<String, int> expectedByField) {
    final bool anyEmpty = expectedByField.keys.any(
      (field) => (_inputs[field]?.text.trim() ?? '').isEmpty,
    );
    if (anyEmpty) {
      _showSnack(t('msg_err_fill'), Colors.redAccent);
      _playError();
      return;
    }
    final bool allCorrect = expectedByField.entries.every(
      (entry) => int.tryParse(_inputs[entry.key]!.text.trim()) == entry.value,
    );
    if (allCorrect) {
      _passPhase();
    } else {
      _failPhase();
    }
  }

  void _passPhase() {
    _playSuccess();
    setState(() {
      _passed[_activePhase] = true;
      _showSnack(t('flash_pass'), Colors.green);
      // Only the final phase opens the report, and only once every phase
      // (including those skipped via "Next Scenario") has been passed.
      if (_activePhase == 4 && _passed.every((passed) => passed)) {
        _showReport = true;
      }
    });
  }

  void _failPhase() {
    _playError();
    _showSnack(t('flash_fail'), Colors.redAccent);
  }

  // === MAIN BUILD ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDark
          ? const Color(0xFF071B3F)
          : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // MAIN AREA
          if (_hasStarted)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isSidebarOpen ? 350 : 0,
                    child: _isSidebarOpen
                        ? _buildSidebar()
                        : const SizedBox.shrink(),
                  ),
                  Expanded(child: _buildCanvas()),
                ],
              ),
            ),

          // FLOATING SIDEBAR TOGGLE
          if (_hasStarted)
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: _isDark
                    ? const Color(0xFF1E293B)
                    : Colors.white,
                foregroundColor: _isDark ? Colors.white : Colors.black,
                child: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                onPressed: () {
                  _playClick();
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                },
              ),
            ),

          // START OVERLAY
          if (!_hasStarted)
            Positioned.fill(
              child: SlideTransition(
                position: _shutterAnimation,
                child: Container(
                  color: _isDark
                      ? const Color(0xFF071B3F)
                      : const Color(0xFFF8FAFC),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.category,
                          size: 80,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          t('app_title').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t('tagline'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        ElevatedButton.icon(
                          onPressed: _startMission,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(t('init_btn')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0B1026),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // REPORT MODAL
          if (_showReport)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: _buildGlassPanel(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('diag_title_pass'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t('diag_sub_pass'),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          _playClick();
                          setState(() {
                            _showReport = false;
                            _reset();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(t('btn_restart_exp')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TriangleDotsPainter extends CustomPainter {
  final int n;
  TriangleDotsPainter(this.n);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.amber;
    double radius = 4;
    double spacing = 12;
    double startY = size.height - radius;

    for (int row = 0; row < n; row++) {
      int dotsInRow = n - row;
      double rowWidth = (dotsInRow - 1) * spacing;
      double startX = (size.width - rowWidth) / 2;
      double y = startY - (row * spacing * 0.866);

      for (int i = 0; i < dotsInRow; i++) {
        canvas.drawCircle(Offset(startX + (i * spacing), y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TriangleDotsPainter oldDelegate) =>
      n != oldDelegate.n;
}

class SquareDotsPainter extends CustomPainter {
  final int m;
  SquareDotsPainter(this.m);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.amber;
    double radius = 4;
    double spacing = 12;
    double totalWidth = (m - 1) * spacing;
    double startX = (size.width - totalWidth) / 2;
    double startY = (size.height - totalWidth) / 2;

    for (int i = 0; i < m; i++) {
      for (int j = 0; j < m; j++) {
        canvas.drawCircle(
          Offset(startX + (j * spacing), startY + (i * spacing)),
          radius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SquareDotsPainter oldDelegate) =>
      m != oldDelegate.m;
}
