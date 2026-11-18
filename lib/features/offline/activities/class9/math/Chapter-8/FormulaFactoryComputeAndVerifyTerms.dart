// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FormulaFactoryApp());
}

class FormulaFactoryApp extends StatelessWidget {
  const FormulaFactoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formula Factory',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF071B3F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF97316),
          secondary: Color(0xFFFACC15),
          surface: Color(0xFF0B234D),
        ),
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const FormulaFactoryComputeAndVerifyTerms(),
    );
  }
}

// --- DATA MODELS ---
class PhaseData {
  final String kind; // 'compute' or 'member'
  final String name; // 'u', 's', 't'
  final int a;
  final int b;
  final List<int> vals;

  const PhaseData({
    required this.kind,
    required this.name,
    required this.a,
    required this.b,
    required this.vals,
  });
}

class FormulaFactoryComputeAndVerifyTerms extends StatefulWidget {
  const FormulaFactoryComputeAndVerifyTerms({super.key});

  @override
  State<FormulaFactoryComputeAndVerifyTerms> createState() =>
      _FormulaFactoryComputeAndVerifyTermsState();
}

class _FormulaFactoryComputeAndVerifyTermsState
    extends State<FormulaFactoryComputeAndVerifyTerms>
    with TickerProviderStateMixin {
  // === Configuration ===
  static const List<PhaseData> phases = [
    PhaseData(kind: 'compute', name: 'u', a: 2, b: -1, vals: [53, 108, 1170]),
    PhaseData(kind: 'member', name: 's', a: 5, b: -2, vals: [308, 305]),
    PhaseData(
      kind: 'compute',
      name: 't',
      a: 3,
      b: -7,
      vals: [1, 2, 3, 12, 18, 50],
    ),
    PhaseData(kind: 'member', name: 't', a: 3, b: -7, vals: [332, 250]),
  ];

  static const List<String> languages = ['en', 'hi'];

  // === State Variables ===
  bool _hasStarted = false;
  bool _isSidebarOpen = true;
  bool _showReport = false;

  int _activePhase = 0; // 0 to 3
  int _langIndex = 0;
  final bool _isDark = true;
  final double _fontSize = 14.0;

  int _hintIdx = 0;
  int _activeIndex = 0;
  int? _currentVal;

  late AnimationController _shutterController;
  late Animation<Offset> _shutterAnimation;

  // Track inputs for each phase
  final Map<String, TextEditingController> _controllers = {};

  // Track judgments for member phases
  final Map<int, List<String?>> _memberJudgment = {
    1: [null, null],
    3: [null, null],
  };
  final List<bool> _passed = [false, false, false, false];

  // Pending auto-advance after a phase is passed; cancelled whenever the
  // learner navigates, resets, or leaves so it can't skip or overrun phases.
  Timer? _advanceTimer;

  final ScrollController _scrollController = ScrollController();

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

  // === Dictionaries ===
  final Map<String, Map<String, String>> _text = {
    'en': {
      'app_title': 'Formula Factory',
      'tagline': 'Class 9 • Sequences and Progressions',
      'init_btn': 'START MISSION',
      'hud_k': 'Current Phase',
      'obj_label': 'Mission Objective',
      'scenario_label': 'Mission Phase',
      'steps_label': 'Instruction Sequence',
      'hint_label': 'Hint / Evidence',
      'conc_label': 'Learnt Conclusion',
      'p0_t': 'Phase 1 · Compute Terms (uₙ)',
      'p1_t': 'Phase 2 · Verify Membership (sₙ)',
      'p2_t': 'Phase 3 · Compute Terms (tₙ)',
      'p3_t': 'Phase 4 · Verify Membership (tₙ)',
      'btn_hint': 'Hint',
      'btn_submit': 'Submit',
      'btn_report': 'Report',
      'btn_close_report': 'Close Report',
      'btn_restart_exp': 'Restart Exploration',
      'obj_desc':
          'Apply explicit n-th term formulas to compute specific terms by visible substitution, then verify whether given numbers belong to each sequence.',
      'conc_desc':
          'An explicit formula lets you jump straight to any term by substituting its position n. To test membership, solve the formula for n — the number belongs only if n is a whole number ≥ 1.',
      'compute_note':
          'Slot each n into the formula, compute, then type the value.',
      'mem_title': 'Membership Inspector',
      'mem_note':
          'Solve the formula for n. If n is a whole number ≥ 1, the value is a term.',
      'th_pos': 'Position n',
      'th_sub': 'Substitution',
      'th_term': 'Term value',
      'lbl_in': '✓ In sequence',
      'lbl_out': '✗ Not a term',
      'pos_n': 'Position n =',
      'lbl_drop_n': 'Drop n here',
      'lbl_drop_num': 'Drop number',
      'tray_n': 'Drag n → slot',
      'tray_num': 'Drag number → slot',
      's0_1': 'Read the explicit rule on the machine.',
      's0_2': 'Drag each n into the slot and read the substitution.',
      's0_3': 'Multiply, subtract, then type the computed term.',
      's0_4': 'Submit to verify all terms.',
      's1_1': 'Read the rule for the sequence.',
      's1_2': 'Solve the formula for n = test number.',
      's1_3': 'Decide: whole-number n → term; otherwise not.',
      's1_4': 'Submit to verify both membership judgments.',
      's2_1': 'Read the explicit rule on the machine.',
      's2_2': 'Slot each n into the machine.',
      's2_3': 'Compute each term (mind negative values).',
      's2_4': 'Submit to verify the whole table.',
      's3_1': 'Read the rule for the sequence.',
      's3_2': 'Solve the formula for n = test number.',
      's3_3': 'A whole-number n means it belongs to the sequence.',
      's3_4': 'Submit to complete the mission.',
      'h_0_0': 'Drag an n-chip from the tray into the machine slot.',
      'h_0_1': 'Multiply the n value first, then subtract or add the constant.',
      'h_0_2': 'Example: u₅₃ = 2 × 53 − 1 = 105. Type each term in its row.',
      'h_1_0': 'Set the formula equal to the test number.',
      'h_1_1': 'Use algebra to solve for n.',
      'h_1_2':
          'If n is a whole number ≥ 1, the value is a term — type its position and pick "In sequence".',
      'h_2_0': 'Slot each n into the formula.',
      'h_2_1':
          'Multiply n by the coefficient, then subtract. Small n might give negative terms.',
      'h_2_2': 'Fill every row before you Submit.',
      'h_3_0': 'Set the formula equal to the test number and solve for n.',
      'h_3_1': 'A whole-number n means the value belongs.',
      'h_3_2': 'A fraction means it does not belong.',
      'msg_err_fill_comp': 'Fill in every term before submitting.',
      'msg_err_fill_mem':
          'Give a judgment (and position for members) for every number.',
      'msg_err_math_comp':
          'Some terms do not match the rule. Re-check your math.',
      'msg_err_math_mem': 'Some judgments are off. Solve for n correctly.',
      'msg_ok_comp': 'All terms match the formula!',
      'msg_ok_mem': 'Membership verified!',
      'diag_pass':
          'You successfully applied formulas to compute terms and verified sequence membership.',
      'diag_fail':
          'Some phases still need work — your progress is saved, adjust and resubmit.',
      'btn_prev': 'Prev',
      'btn_next': 'Next',
      'tray_hint_compute': 'Cards = values of n',
      'tray_hint_member': 'Cards = test numbers',
    },
    'hi': {
      'app_title': 'सूत्र कारखाना',
      'tagline': 'कक्षा 9 • अनुक्रम और श्रेढ़ी',
      'init_btn': 'मिशन शुरू करें',
      'hud_k': 'वर्तमान चरण',
      'obj_label': 'मिशन का उद्देश्य',
      'scenario_label': 'मिशन चरण',
      'steps_label': 'निर्देश अनुक्रम',
      'hint_label': 'संकेत / प्रमाण',
      'conc_label': 'सीखा हुआ निष्कर्ष',
      'p0_t': 'चरण 1 · पदों की गणना (uₙ)',
      'p1_t': 'चरण 2 · सदस्यता सत्यापित करें (sₙ)',
      'p2_t': 'चरण 3 · पदों की गणना (tₙ)',
      'p3_t': 'चरण 4 · सदस्यता सत्यापित करें (tₙ)',
      'btn_hint': 'संकेत',
      'btn_submit': 'सबमिट करें',
      'btn_report': 'रिपोर्ट',
      'btn_close_report': 'रिपोर्ट बंद करें',
      'btn_restart_exp': 'अन्वेषण पुनरारंभ करें',
      'obj_desc':
          'दृश्य प्रतिस्थापन द्वारा विशिष्ट पदों की गणना करने के लिए स्पष्ट n-वें पद के सूत्र लागू करें, फिर सत्यापित करें कि क्या दी गई संख्याएँ प्रत्येक अनुक्रम से संबंधित हैं।',
      'conc_desc':
          'एक स्पष्ट सूत्र आपको स्थिति n को प्रतिस्थापित करके सीधे किसी भी पद पर जाने की अनुमति देता है। सदस्यता का परीक्षण करने के लिए, n के लिए सूत्र हल करें - संख्या तभी संबंधित है जब n एक पूर्ण संख्या ≥ 1 हो।',
      'compute_note':
          'सूत्र में प्रत्येक n डालें, गणना करें, फिर मान टाइप करें।',
      'mem_title': 'सदस्यता निरीक्षक',
      'mem_note':
          'n के लिए सूत्र हल करें। यदि n एक पूर्ण संख्या ≥ 1 है, तो मान एक पद है।',
      'th_pos': 'स्थिति n',
      'th_sub': 'प्रतिस्थापन',
      'th_term': 'पद मान',
      'lbl_in': '✓ अनुक्रम में है',
      'lbl_out': '✗ पद नहीं है',
      'pos_n': 'स्थिति n =',
      'lbl_drop_n': 'यहाँ n छोड़ें',
      'lbl_drop_num': 'संख्या छोड़ें',
      'tray_n': 'n → स्लॉट में खींचें',
      'tray_num': 'संख्या → स्लॉट में खींचें',
      's0_1': 'मशीन पर स्पष्ट नियम पढ़ें।',
      's0_2': 'प्रत्येक n को स्लॉट में खींचें और प्रतिस्थापन पढ़ें।',
      's0_3': 'गुणा करें, घटाएं, फिर गणना किया गया पद टाइप करें।',
      's0_4': 'सभी पदों को सत्यापित करने के लिए सबमिट करें।',
      's1_1': 'अनुक्रम के लिए नियम पढ़ें।',
      's1_2': 'n = परीक्षण संख्या के लिए सूत्र हल करें।',
      's1_3': 'निर्णय लें: पूर्ण संख्या n → पद; अन्यथा नहीं।',
      's1_4': 'दोनों सदस्यता निर्णयों को सत्यापित करने के लिए सबमिट करें।',
      's2_1': 'मशीन पर स्पष्ट नियम पढ़ें।',
      's2_2': 'प्रत्येक n को मशीन में डालें।',
      's2_3': 'प्रत्येक पद की गणना करें (नकारात्मक मानों का ध्यान रखें)।',
      's2_4': 'पूरी तालिका को सत्यापित करने के लिए सबमिट करें।',
      's3_1': 'अनुक्रम के लिए नियम पढ़ें।',
      's3_2': 'n = परीक्षण संख्या के लिए सूत्र हल करें।',
      's3_3': 'पूर्ण संख्या n का अर्थ है कि यह अनुक्रम से संबंधित है।',
      's3_4': 'मिशन पूरा करने के लिए सबमिट करें।',
      'h_0_0': 'ट्रे से n-चिप को मशीन स्लॉट में खींचें।',
      'h_0_1': 'पहले n मान को गुणा करें, फिर स्थिरांक को घटाएं या जोड़ें।',
      'h_0_2':
          'उदाहरण: u₅₃ = 2 × 53 − 1 = 105. प्रत्येक पद को उसकी पंक्ति में टाइप करें।',
      'h_1_0': 'सूत्र को परीक्षण संख्या के बराबर सेट करें।',
      'h_1_1': 'n के लिए हल करने के लिए बीजगणित का उपयोग करें।',
      'h_1_2':
          'यदि n एक पूर्ण संख्या ≥ 1 है, तो मान एक पद है — उसकी स्थिति टाइप करें और "अनुक्रम में है" चुनें।',
      'h_2_0': 'प्रत्येक n को सूत्र में डालें।',
      'h_2_1':
          'n को गुणांक से गुणा करें, फिर घटाएं। छोटा n नकारात्मक पद दे सकता है।',
      'h_2_2': 'सबमिट करने से पहले हर पंक्ति भरें।',
      'h_3_0': 'सूत्र को परीक्षण संख्या के बराबर सेट करें और n के लिए हल करें।',
      'h_3_1': 'पूर्ण संख्या n का अर्थ है कि मान संबंधित है।',
      'h_3_2': 'भिन्न का अर्थ है कि यह संबंधित नहीं है।',
      'msg_err_fill_comp': 'सबमिट करने से पहले हर पद भरें।',
      'msg_err_fill_mem':
          'प्रत्येक संख्या के लिए निर्णय (और सदस्यों के लिए स्थिति) दें।',
      'msg_err_math_comp':
          'कुछ पद नियम से मेल नहीं खाते। अपने गणित की दोबारा जांच करें।',
      'msg_err_math_mem': 'कुछ निर्णय गलत हैं। n के लिए सही ढंग से हल करें।',
      'msg_ok_comp': 'सभी पद सूत्र से मेल खाते हैं!',
      'msg_ok_mem': 'सदस्यता सत्यापित हो गई!',
      'diag_pass':
          'आपने पदों की गणना करने के लिए सफलतापूर्वक सूत्र लागू किए और अनुक्रम सदस्यता को सत्यापित किया।',
      'diag_fail':
          'कुछ चरणों में अभी भी काम की आवश्यकता है — आपकी प्रगति सहेज ली गई है, समायोजित करें और पुनः सबमिट करें।',
      'btn_prev': 'पिछला',
      'btn_next': 'अगला',
      'tray_hint_compute': 'कार्ड = n के मान',
      'tray_hint_member': 'कार्ड = परीक्षण संख्याएँ',
    },
  };

  String t(String key) =>
      _text[languages[_langIndex]]?[key] ?? _text['en']?[key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

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

    _initData();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _advanceTimer?.cancel();
    _shutterController.dispose();
    _scrollController.dispose();
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // --- AUDIO HELPERS ---
  void _playClick() {
    _clickPlayer.play(AssetSource(_clickUrl));
  }

  void _playError() {
    _errorPlayer.play(AssetSource(_errorUrl));
  }

  void _playSuccess() {
    _successPlayer.play(AssetSource(_successUrl));
  }

  void _playShutter() {
    _fxPlayer.play(AssetSource(_shutterUrl));
  }

  void _initData() {
    _controllers.clear();
    for (int p = 0; p < phases.length; p++) {
      for (int i = 0; i < phases[p].vals.length; i++) {
        _controllers['${p}_$i'] = TextEditingController();
      }
    }
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

  String _subNum(int n) {
    const subs = {
      '0': '₀',
      '1': '₁',
      '2': '₂',
      '3': '₃',
      '4': '₄',
      '5': '₅',
      '6': '₆',
      '7': '₇',
      '8': '₈',
      '9': '₉',
      '-': '₋',
    };
    return n.toString().split('').map((c) => subs[c] ?? c).join('');
  }

  String _bStr(int b) => b < 0 ? '− ${b.abs()}' : '+ $b';
  String _fmtFormula(PhaseData p) => '${p.a}n ${_bStr(p.b)}';
  String _fmtSubs(PhaseData p, int v) => '${p.a} × $v ${_bStr(p.b)}';

  void _startMission() {
    _playClick();
    _playShutter();
    _shutterController.forward().then((_) {
      setState(() {
        _hasStarted = true;
        _currentVal = phases[0].vals[0];
      });
    });
  }

  void _reset() {
    _playClick();
    _advanceTimer?.cancel();
    _shutterController.reverse();
    setState(() {
      _hasStarted = false;
      _activePhase = 0;
      _langIndex = 0;
      for (int i = 0; i < 4; i++) {
        _passed[i] = false;
        if (phases[i].kind == 'member') {
          _memberJudgment[i] = List.generate(
            phases[i].vals.length,
            (_) => null,
          );
        }
      }
      _initData();
      _showReport = false;
      _hintIdx = 0;
      _activeIndex = 0;
      _currentVal = phases[0].vals[0];
    });
  }

  void _selectValue(int idx) {
    _playClick();
    setState(() {
      _activeIndex = idx;
      _currentVal = phases[_activePhase].vals[idx];
    });
  }

  void _submitPhase() {
    _playClick();
    FocusScope.of(context).unfocus();
    PhaseData p = phases[_activePhase];
    bool allCorrect = true;
    bool allFilled = true;

    if (p.kind == 'compute') {
      for (int i = 0; i < p.vals.length; i++) {
        String s = _controllers['${_activePhase}_$i']!.text;
        if (s.isEmpty) {
          allFilled = false;
          allCorrect = false;
        } else {
          int? val = int.tryParse(s);
          int expected = p.a * p.vals[i] + p.b;
          if (val != expected) allCorrect = false;
        }
      }
    } else {
      for (int i = 0; i < p.vals.length; i++) {
        String? judg = _memberJudgment[_activePhase]![i];
        if (judg == null) {
          allFilled = false;
          allCorrect = false;
        } else {
          int x = p.vals[i];
          double n = (x - p.b) / p.a;
          bool isMember = n == n.roundToDouble() && n >= 1;

          if (judg == 'in') {
            String posText = _controllers['${_activePhase}_$i']!.text;
            if (posText.isEmpty) {
              allFilled = false;
              allCorrect = false;
            } else {
              int? pos = int.tryParse(posText);
              if (!isMember || pos != n.round()) allCorrect = false;
            }
          } else {
            if (isMember) allCorrect = false;
          }
        }
      }
    }

    if (!allFilled) {
      _playError();
      _showSnack(
        t(p.kind == 'compute' ? 'msg_err_fill_comp' : 'msg_err_fill_mem'),
        Colors.redAccent,
      );
      return;
    }

    if (allCorrect) {
      _playSuccess();
      setState(() {
        _passed[_activePhase] = true;
        _showSnack(
          t(p.kind == 'compute' ? 'msg_ok_comp' : 'msg_ok_mem'),
          Colors.green,
        );
        if (_activePhase < phases.length - 1) {
          final int fromPhase = _activePhase;
          _advanceTimer?.cancel();
          _advanceTimer = Timer(const Duration(milliseconds: 1500), () {
            if (!mounted || _activePhase != fromPhase) return;
            setState(() {
              _activePhase = fromPhase + 1;
              _activeIndex = 0;
              _currentVal = phases[_activePhase].vals[0];
              _hintIdx = 0;
            });
          });
        } else if (_passed.every((passed) => passed)) {
          _showReport = true;
        }
      });
      if (_activePhase == phases.length - 1 &&
          !_passed.every((passed) => passed)) {
        _showSnack(t('diag_fail'), Colors.orange);
      }
    } else {
      _playError();
      setState(() => _passed[_activePhase] = false);
      _showSnack(
        t(p.kind == 'compute' ? 'msg_err_math_comp' : 'msg_err_math_mem'),
        Colors.redAccent,
      );
    }
  }

  // === UI WIDGETS ===
  Widget _buildGlassPanel({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _isDark
            ? const Color(0xDA0B234D)
            : Colors.white.withValues(alpha: 0.95),
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
                          Icons.calculate,
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
                          languages[_langIndex].toUpperCase(),
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
                            _langIndex = (_langIndex + 1) % languages.length;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        color: _isDark ? Colors.white : Colors.black,
                        onPressed: _reset,
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

                  _buildStepsList(),
                  const SizedBox(height: 12),

                  _buildSidebarSection(
                    Icons.lightbulb,
                    t('hint_label'),
                    t('h_${_activePhase}_0'),
                  ),
                  const SizedBox(height: 12),

                  _buildSidebarSection(
                    Icons.school,
                    t('conc_label'),
                    t('conc_desc'),
                  ),
                ],
              ),
            ),
          ),
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
                t('scenario_label').toUpperCase(),
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
                value: _activePhase,
                dropdownColor: _isDark ? const Color(0xFF0F2C60) : Colors.white,
                isExpanded: true,
                style: TextStyle(
                  color: _isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                items: List.generate(
                  4,
                  (i) => DropdownMenuItem(value: i, child: Text(t('p${i}_t'))),
                ),
                onChanged: (val) {
                  if (val != null && val != _activePhase) {
                    _playClick();
                    _advanceTimer?.cancel();
                    setState(() {
                      _activePhase = val;
                      _hintIdx = 0;
                      _activeIndex = 0;
                      _currentVal = phases[_activePhase].vals[0];
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList() {
    List<String> steps = [];
    if (_activePhase == 0) {
      steps = [t('s0_1'), t('s0_2'), t('s0_3'), t('s0_4')];
    } else if (_activePhase == 1) {
      steps = [t('s1_1'), t('s1_2'), t('s1_3'), t('s1_4')];
    } else if (_activePhase == 2) {
      steps = [t('s2_1'), t('s2_2'), t('s2_3'), t('s2_4')];
    } else if (_activePhase == 3) {
      steps = [t('s3_1'), t('s3_2'), t('s3_3'), t('s3_4')];
    }

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
              bool isActive = false;

              if (!isDone) {
                bool anyFilled = phases[_activePhase].kind == 'compute'
                    ? _controllers.entries
                          .where((e) => e.key.startsWith('${_activePhase}_'))
                          .any((e) => e.value.text.isNotEmpty)
                    : _memberJudgment[_activePhase]!.any((j) => j != null);

                if (anyFilled) {
                  if (i == 0 || i == 1) isDone = true;
                  if (i == 2) isActive = true;
                } else {
                  if (i == 0) isDone = true;
                  if (i == 1) isActive = true;
                }
              }

              Color bg = isActive
                  ? Colors.orange.withValues(alpha: 0.15)
                  : (_isDark ? Colors.white12 : Colors.black12);
              Color border = isDone
                  ? Colors.green
                  : (isActive ? Colors.orange : Colors.transparent);
              Color textCol = isDone
                  ? Colors.green
                  : (isActive
                        ? (_isDark ? Colors.white : Colors.black)
                        : Colors.grey);
              IconData icn = isDone
                  ? Icons.check_circle
                  : (isActive ? Icons.bolt : Icons.lock);

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
                    Icon(icn, size: 14, color: textCol),
                    const SizedBox(width: 8),
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
            // HUD and Ribbon
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 12,
              children: [_buildMiniMissionHUD(), _buildMilestoneRibbon()],
            ),
            const SizedBox(height: 24),

            // Machine
            _buildMachine(phases[_activePhase]),
            const SizedBox(height: 16),

            // Dynamic Panel
            if (phases[_activePhase].kind == 'compute')
              _buildComputePanel(phases[_activePhase])
            else
              _buildMemberPanel(phases[_activePhase]),

            const SizedBox(height: 16),
            _buildTray(),
            const SizedBox(height: 16),
            _buildControlBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMissionHUD() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDark
            ? const Color(0xD808152E)
            : Colors.white.withValues(alpha: 0.9),
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
            t('hud_k').toUpperCase(),
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t('p${_activePhase}_t'),
            style: TextStyle(
              color: _isDark ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
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
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _isDark ? Colors.white12 : Colors.black12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(4, (i) {
          bool isActive = i == _activePhase;
          bool isDone = _passed[i];
          Color bg = isActive
              ? Colors.orange
              : (isDone
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.transparent);
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
                  'Phase ${i + 1}',
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

  Widget _buildMachine(PhaseData p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF0B234D) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isDark ? Colors.white12 : Colors.black12,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: _isDark ? Colors.white : Colors.black,
                    ),
                    children: [
                      TextSpan(text: '${p.name}n = '),
                      TextSpan(
                        text: _fmtFormula(p),
                        style: const TextStyle(color: Color(0xFFF97316)),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    t(
                      p.kind == 'compute' ? 'lbl_drop_n' : 'lbl_drop_num',
                    ).toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: _isDark ? Colors.white54 : Colors.black54,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DragTarget<int>(
                    onAcceptWithDetails: (details) {
                      _playClick();
                      setState(() {
                        _activeIndex = details.data;
                        _currentVal = p.vals[details.data];
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      bool isHovered = candidateData.isNotEmpty;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 70,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isHovered
                              ? const Color(0xFFF97316).withValues(alpha: 0.2)
                              : const Color(0xFFFACC15).withValues(alpha: 0.1),
                          border: Border.all(
                            color: isHovered
                                ? const Color(0xFFF97316)
                                : (_currentVal != null
                                      ? (_isDark
                                            ? Colors.white24
                                            : Colors.black12)
                                      : const Color(0xFFFACC15)),
                            width: 2,
                            style: _currentVal != null && !isHovered
                                ? BorderStyle.solid
                                : BorderStyle.none,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _currentVal != null ? '$_currentVal' : '?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: _currentVal != null
                                ? const Color(0xFFFACC15)
                                : (_isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isDark
                  ? const Color(0xFF0F2C60)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: _buildMachineWorking(p),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineWorking(PhaseData p) {
    if (_currentVal == null) {
      return Text(
        'Drag a value from the tray into the machine slot to begin.',
        style: TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          color: _isDark ? Colors.white : Colors.black,
        ),
      );
    }

    if (p.kind == 'compute') {
      String typed = _controllers['${_activePhase}_$_activeIndex']!.text;
      bool hasVal = typed.isNotEmpty && double.tryParse(typed) != null;
      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: _isDark ? Colors.white : Colors.black,
          ),
          children: [
            TextSpan(text: '${p.name}${_subNum(_currentVal!)} = ${p.a} '),
            const TextSpan(
              text: '× ',
              style: TextStyle(color: Color(0xFFF97316)),
            ),
            TextSpan(text: '$_currentVal ${_bStr(p.b)} = '),
            hasVal
                ? TextSpan(
                    text: typed,
                    style: const TextStyle(color: Colors.green),
                  )
                : const TextSpan(
                    text: '?',
                    style: TextStyle(color: Color(0xFFFACC15)),
                  ),
          ],
        ),
      );
    } else {
      int x = _currentVal!;
      int rhs = x - p.b;
      String? judg = _memberJudgment[_activePhase]![_activeIndex];
      String pos = _controllers['${_activePhase}_$_activeIndex']!.text;
      bool hasPos = judg == 'in' && pos.isNotEmpty;

      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: _isDark ? Colors.white : Colors.black,
          ),
          children: [
            TextSpan(
              text:
                  'Test: ${p.a}n ${_bStr(p.b)} = $x  →  ${p.a}n = $rhs  →  n = $rhs ÷ ${p.a} = ',
            ),
            hasPos
                ? TextSpan(
                    text: pos,
                    style: const TextStyle(color: Colors.green),
                  )
                : const TextSpan(
                    text: '?',
                    style: TextStyle(color: Color(0xFFFACC15)),
                  ),
          ],
        ),
      );
    }
  }

  Widget _buildComputePanel(PhaseData p) {
    return _buildActivityPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Term Table · compute each term',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF97316),
            ),
          ),
          Text(
            t('compute_note'),
            style: TextStyle(
              fontSize: 12,
              color: _isDark ? Colors.white54 : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _isDark ? Colors.white12 : Colors.black12,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  color: _isDark
                      ? const Color(0xFF0F2C60)
                      : const Color(0xFFE2E8F0),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          t('th_pos').toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF97316),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          t('th_sub').toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF97316),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          t('th_term').toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFF97316),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: _isDark ? Colors.white12 : Colors.black12,
                ),
                // Body
                Column(
                  children: List.generate(p.vals.length, (i) {
                    bool isActive = i == _activeIndex;
                    Color bgColor = isActive
                        ? const Color(0xFFF97316).withValues(alpha: 0.1)
                        : Colors.transparent;

                    return InkWell(
                      onTap: () => _selectValue(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border(
                            left: BorderSide(
                              color: isActive
                                  ? const Color(0xFFF97316)
                                  : Colors.transparent,
                              width: 4,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'n = ${p.vals[i]}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _fmtSubs(p, p.vals[i]),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: _isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: SizedBox(
                                  width: 80,
                                  height: 36,
                                  child: TextField(
                                    controller:
                                        _controllers['${_activePhase}_$i'],
                                    enabled: !_passed[_activePhase],
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          signed: true,
                                        ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      hintText: '?',
                                      filled: true,
                                      fillColor: _isDark
                                          ? const Color(0xFF071B3F)
                                          : Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: _isDark
                                              ? Colors.white12
                                              : Colors.black12,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: _isDark
                                              ? Colors.white12
                                              : Colors.black12,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFFACC15),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      _playClick();
                                      if (isActive) setState(() {});
                                    },
                                    onTap: () => _selectValue(i),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberPanel(PhaseData p) {
    return _buildActivityPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('mem_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF97316),
            ),
          ),
          Text(
            t('mem_note'),
            style: TextStyle(
              fontSize: 12,
              color: _isDark ? Colors.white54 : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(p.vals.length, (i) {
              int x = p.vals[i];
              int rhs = x - p.b;
              bool isActive = i == _activeIndex;
              String? judg = _memberJudgment[_activePhase]![i];

              return InkWell(
                onTap: () => _selectValue(i),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isDark
                        ? const Color(0xFF0F2C60)
                        : const Color(0xFFF1F5F9),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFFF97316)
                          : (_isDark ? Colors.white12 : Colors.black12),
                      width: isActive ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Is $x a term of ${p.name}n = ${_fmtFormula(p)}?',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: _isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isDark
                              ? const Color(0xFF071B3F)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: _isDark ? Colors.white70 : Colors.black87,
                            ),
                            children: [
                              TextSpan(text: '${p.a}n ${_bStr(p.b)} = $x\n'),
                              TextSpan(text: '${p.a}n = $rhs\n'),
                              TextSpan(text: 'n = $rhs ÷ ${p.a} = '),
                              const TextSpan(
                                text: '?',
                                style: TextStyle(
                                  color: Color(0xFFFACC15),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            t('pos_n'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 70,
                            height: 32,
                            child: TextField(
                              controller: _controllers['${_activePhase}_$i'],
                              enabled: judg != 'out' && !_passed[_activePhase],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _isDark ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                filled: true,
                                fillColor: _isDark
                                    ? const Color(0xFF071B3F)
                                    : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: _isDark
                                        ? Colors.white12
                                        : Colors.black12,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: _isDark
                                        ? Colors.white12
                                        : Colors.black12,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFFACC15),
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                _playClick();
                                if (isActive) setState(() {});
                              },
                              onTap: () => _selectValue(i),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _passed[_activePhase]
                                  ? null
                                  : () {
                                      _playClick();
                                      setState(() {
                                        _memberJudgment[_activePhase]![i] =
                                            'in';
                                        _activeIndex = i;
                                        _currentVal = p.vals[i];
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: judg == 'in'
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : (_isDark
                                          ? const Color(0xFF071B3F)
                                          : Colors.white),
                                foregroundColor: judg == 'in'
                                    ? Colors.green
                                    : Colors.grey,
                                side: BorderSide(
                                  color: judg == 'in'
                                      ? Colors.green
                                      : (_isDark
                                            ? Colors.white12
                                            : Colors.black12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                t('lbl_in'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _passed[_activePhase]
                                  ? null
                                  : () {
                                      _playClick();
                                      setState(() {
                                        _memberJudgment[_activePhase]![i] =
                                            'out';
                                        _controllers['${_activePhase}_$i']!
                                            .clear();
                                        _activeIndex = i;
                                        _currentVal = p.vals[i];
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: judg == 'out'
                                    ? Colors.red.withValues(alpha: 0.2)
                                    : (_isDark
                                          ? const Color(0xFF071B3F)
                                          : Colors.white),
                                foregroundColor: judg == 'out'
                                    ? Colors.red
                                    : Colors.grey,
                                side: BorderSide(
                                  color: judg == 'out'
                                      ? Colors.red
                                      : (_isDark
                                            ? Colors.white12
                                            : Colors.black12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                t('lbl_out'),
                                style: const TextStyle(
                                  fontSize: 10,
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
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTray() {
    PhaseData p = phases[_activePhase];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF0B234D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isDark ? Colors.white12 : Colors.black12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(p.vals.length, (i) {
            bool isActive = i == _activeIndex;

            bool isEntered = false;
            if (p.kind == 'compute') {
              isEntered = _controllers['${_activePhase}_$i']!.text.isNotEmpty;
            } else {
              isEntered = _memberJudgment[_activePhase]![i] != null;
            }

            Widget chip = Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isActive
                      ? [Colors.orange.shade500, Colors.orange.shade700]
                      : [Colors.blue.shade500, Colors.blue.shade800],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? const Color(0xFFFACC15) : Colors.white24,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isEntered ? Colors.greenAccent : Colors.white30,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    p.kind == 'compute' ? 'n=${p.vals[i]}' : '${p.vals[i]}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isEntered && !isActive
                          ? Colors.white70
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            );

            return Draggable<int>(
              data: i,
              feedback: Material(
                color: Colors.transparent,
                child: Transform.scale(scale: 1.1, child: chip),
              ),
              childWhenDragging: Opacity(opacity: 0.5, child: chip),
              onDragStarted: () {
                _playClick();
                _selectValue(i);
              },
              child: GestureDetector(onTap: () => _selectValue(i), child: chip),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isDark
            ? const Color(0xD808152E)
            : Colors.white.withValues(alpha: 0.9),
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
                t(
                  phases[_activePhase].kind == 'compute'
                      ? 'tray_hint_compute'
                      : 'tray_hint_member',
                ),
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
                        _advanceTimer?.cancel();
                        setState(() {
                          _activePhase--;
                          _hintIdx = 0;
                          _activeIndex = 0;
                          _currentVal = phases[_activePhase].vals[0];
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
                onPressed: (_passed[_activePhase] && _activePhase < 3)
                    ? () {
                        _playClick();
                        _advanceTimer?.cancel();
                        setState(() {
                          _activePhase++;
                          _hintIdx = 0;
                          _activeIndex = 0;
                          _currentVal = phases[_activePhase].vals[0];
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
                  String hintStr = t('h_${_activePhase}_${_hintIdx % 3}');
                  _showSnack('💡 $hintStr', Colors.orange);
                  setState(() => _hintIdx++);
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
              if (!_passed[_activePhase])
                ElevatedButton(
                  onPressed: _submitPhase,
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

  // === MAIN BUILD ===
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: _isDark
            ? const Color(0xFF071B3F)
            : const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            // MAIN AREA
            if (_hasStarted)
              Positioned.fill(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: _isSidebarOpen
                          ? MediaQuery.of(context).size.width * 0.3
                          : 0,
                      child: ClipRect(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: _buildSidebar(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: _buildCanvas()),
                  ],
                ),
              ),

            // TOP LEFT MENU
            if (_hasStarted)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isSidebarOpen ? Icons.menu_open : Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _playClick();
                      setState(() => _isSidebarOpen = !_isSidebarOpen);
                    },
                  ),
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
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calculate,
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
              ),

            // REPORT MODAL
            if (_showReport)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  alignment: Alignment.center,
                  child: _buildGlassPanel(
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Mission Accomplished!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t('diag_pass'),
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _reset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(t('btn_restart_exp')),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              _playClick();
                              setState(() => _showReport = false);
                            },
                            child: Text(
                              t('btn_close_report'),
                              style: const TextStyle(color: Colors.white54),
                            ),
                          ),
                        ],
                      ),
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
