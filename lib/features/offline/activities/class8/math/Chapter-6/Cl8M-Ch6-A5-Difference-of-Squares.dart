// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class DifferenceOfSquares extends StatefulWidget {
  const DifferenceOfSquares({super.key});

  @override
  State<DifferenceOfSquares> createState() => _DifferenceOfSquaresState();
}

class _DifferenceOfSquaresState extends State<DifferenceOfSquares> with SingleTickerProviderStateMixin {
  String _lang = 'en';
  bool _isDark = true;
  bool _sidebarOpen = true;
  int _scen = 0;
  int _hintIdx = 0;
  String _flashMsg = "";
  bool _showShutter = true;
  bool _showDiagnostics = false;

  late AnimationController _shutterCtrl;
  late Animation<Offset> _shutterAnim;
  final AudioPlayer _player = AudioPlayer();

  // Scenario 1 State
  bool _s1StripPlaced = false;
  String _s1Target = '98';
  Map<String, int> _s1b = {'98': 0, '45': 0};
  
  // Scenario 2 State
  int _s2a = 5;
  int _s2b = 6;
  Map<String, String> _s2Place = {}; // 'a1' -> 'L' or 'R'
  
  // Scenario 3 State
  Map<String, int> _s3b = {'31': 0, '197': 0};

  final Map<String, dynamic> _s1Cfg = {
    '98': {'a': 100, 'f1': 98, 'f2': 102, 'ans': 9996, 'bstar': 2},
    '45': {'a': 50, 'f1': 45, 'f2': 55, 'ans': 2475, 'bstar': 5}
  };
  
  final Map<String, dynamic> _s3Cfg = {
    '31': {'a': 31, 'ans': 961, 'bstar': 1, 'max': 9},
    '197': {'a': 197, 'ans': 38809, 'bstar': 3, 'max': 9}
  };

  final Map<String, Map<String, String>> _text = {
    'en': {
      'app_title': "Difference of Squares & Number Patterns",
      'app_subtitle': "Class 8 • We Distribute, Yet Things Multiply",
      'start_mission': "Start Mission",
      'nav_prev': "Prev", 'nav_next': "Next", 'nav_submit': "Submit", 'nav_report': "Report",
      'teacher_board': "Teacher Board", 'ui_scenario': "Scenario", 'ui_objective': "Mission Objective",
      'ui_sequence': "Instruction Sequence", 'ui_hints': "Hints / Evidence", 'ui_learnt': "Learnt Conclusion",
      'ui_settings': "Settings", 'ui_theme': "Color Theme", 'theme_dark': "Dark", 'theme_light': "Light",
      'ui_fontsize': "Sidebar Font Size", 'ui_close': "Close Report", 'restart_mission': "Restart Mission",
      
      'scen_1': "Scenario 1 · a²−b²", 'scen_2': "Scenario 2 · 2(a²+b²)", 'scen_3': "Scenario 3 · Śrīdhara",
      
      'mission_desc': "Reach three special-product identities by rearranging area pieces and driving number machines — no formula memorising.",
      'learnt_desc': "Each identity is one shape re-cut, so both sides are equal. This turns 98×102 into 9996, 2(25+36) into 122, and 197² into 38809 mentally.",
      
      'hint_0': "Ask students why re-arranging pieces cannot change the total area — that is the whole proof. For 98×102 use centre a=100 and offset b=2.",
      'hint_1': "Each frame needs exactly one a² and one b² tile. The ±2ab parts cancel, so both squares together hold 2a²+2b².",
      'hint_2': "Try offsets until 31−b or 31+b ends in 0. b=1 gives 30, so 31²=32×30+1=961.",

      'step_0_1': "Drag the orange strip onto the ghost target.",
      'step_0_2': "Watch the L reform into one (a+b)×(a−b) rectangle.",
      'step_0_3': "Set b=2 so 98×102=9996.",
      'step_0_4': "Set b=5 so 45×55=2475.",

      'step_1_1': "Read the four square tiles (two a², two b²).",
      'step_1_2': "Drag one a² and one b² into the (a+b)² frame.",
      'step_1_3': "Drag one a² and one b² into the (a−b)² frame.",
      'step_1_4': "Confirm 2(a²+b²)=(a+b)²+(a−b)².",

      'step_2_1': "On the 31 machine slide b to 1 → factor 30.",
      'step_2_2': "Read 32×30+1=961.",
      'step_2_3': "On the 197 machine slide b to 3 → factor 200.",
      'step_2_4': "Read 200×194+9=38809.",

      'canvas_inst_1': "Cut & Move: a² − b² = (a+b)(a−b)",
      'canvas_inst_1_sub': "The orange strip is cut from the L-shaped a²−b² region. Drag it onto the striped ghost target so the L reforms into one (a+b)×(a−b) rectangle.",
      'canvas_inst_1b': "Apply it to a hard product",
      'canvas_inst_1b_sub': "Centre a = {a}. Slide the offset b until the two factors become {f1} and {f2}, then read a² − b².",
      'offset_b': "offset b",

      'canvas_inst_2': "Sum-of-Squares Doubler",
      'canvas_inst_2_sub': "Drag the four tiles so each square frame holds one a² tile and one b² tile. Two a² and two b² together fill (a+b)² and (a−b)² exactly.",
      'canvas_inst_2b': "Read the totals",
      'canvas_inst_2b_sub': "Set a and b. The featured pattern uses a = 5, b = 6.",

      'canvas_inst_3a': "Squaring Machine · 31²",
      'canvas_inst_3a_sub': "Slide the offset b until one factor becomes a multiple of 10. Then 31² = (31+b)(31−b) + b².",
      'canvas_inst_3b': "Squaring Machine · 197²",
      'canvas_inst_3b_sub': "Slide the offset b until one factor becomes a multiple of 10. Then 197² = (197+b)(197−b) + b².",

      'flash_snapped': "Strip snapped! The L became one (a+b)×(a−b) rectangle.",
      'flash_hint': "💡 Hint Activated",
      'flash_scen': "Scenario Complete! Move to the next one.",
      'flash_scen_err': "Complete the tasks in this scenario first.",
      'flash_all': "All Scenarios Solved!",
      'flash_reset': "Activity completely reset.",
      
      'diag_title_pass': "All Cases Solved!",
      'diag_sub_pass': "You successfully proved the algebraic identities.",
      'diag_title_fail': "Detective Work in Progress",
      'diag_sub_fail': "Some cases still need work. Check your entries and try again.",
      'diag_prob': "Problem Solving",
      'diag_proc': "Procedural Fluency",
      'xp_earned': "⭐ XP EARNED: 10 / 10",

      's1_area_rem': "Area removed = a² − b²",
      's1_one_rect': "One rectangle: (a+b)(a−b) = a² − b² ✓",
      's3_easy_prod': "Make a factor round to get an easy product.",
      's3_round_found': "✓ Round factor found — easy product!"
    },
    'hi': {
      'app_title': "वर्गों का अंतर और संख्या पैटर्न",
      'app_subtitle': "कक्षा 8 • हम वितरित करते हैं, फिर भी चीजें गुणा होती हैं",
      'start_mission': "मिशन शुरू करें",
      'nav_prev': "पिछला", 'nav_next': "अगला", 'nav_submit': "सबमिट", 'nav_report': "रिपोर्ट",
      'teacher_board': "शिक्षक बोर्ड", 'ui_scenario': "परिदृश्य", 'ui_objective': "मिशन का उद्देश्य",
      'ui_sequence': "निर्देश क्रम", 'ui_hints': "संकेत / प्रमाण", 'ui_learnt': "सीखा गया निष्कर्ष",
      
      'scen_1': "परिदृश्य 1 · a²−b²", 'scen_2': "परिदृश्य 2 · 2(a²+b²)", 'scen_3': "परिदृश्य 3 · श्रीधराचार्य",
      
      'mission_desc': "क्षेत्र के टुकड़ों को पुनर्व्यवस्थित करके और संख्या मशीनों को चलाकर तीन विशेष-उत्पाद पहचानों तक पहुंचें - कोई सूत्र याद रखने की आवश्यकता नहीं है।",
      'learnt_desc': "प्रत्येक पहचान एक आकार को फिर से काटने से है, इसलिए दोनों पक्ष समान हैं। यह 98×102 को 9996 में, 2(25+36) को 122 में, और 197² को 38809 में बदल देता है।",
      
      'hint_0': "छात्रों से पूछें कि टुकड़ों को पुनर्व्यवस्थित करने से कुल क्षेत्रफल क्यों नहीं बदल सकता - यही पूरा प्रमाण है। 98×102 के लिए केंद्र a=100 और ऑफसेट b=2 का उपयोग करें।",
      'hint_1': "प्रत्येक फ्रेम में ठीक एक a² और एक b² टाइल की आवश्यकता होती है। ±2ab भाग रद्द हो जाते हैं, इसलिए दोनों वर्ग मिलकर 2a²+2b² रखते हैं।",
      'hint_2': "ऑफ़सेट तब तक आज़माएं जब तक 31−b या 31+b, 0 पर समाप्त न हो जाए। b=1, 30 देता है, इसलिए 31²=32×30+1=961।",

      'step_0_1': "नारंगी पट्टी को भूतिया लक्ष्य पर खींचें।",
      'step_0_2': "L आकार को एक (a+b)×(a−b) आयत में बदलते हुए देखें।",
      'step_0_3': "b=2 सेट करें ताकि 98×102=9996 हो।",
      'step_0_4': "b=5 सेट करें ताकि 45×55=2475 हो।",

      'step_1_1': "चार वर्ग टाइलें पढ़ें (दो a², दो b²)।",
      'step_1_2': "एक a² और एक b² को (a+b)² फ्रेम में खींचें।",
      'step_1_3': "एक a² और एक b² को (a−b)² फ्रेम में खींचें।",
      'step_1_4': "पुष्टि करें कि 2(a²+b²)=(a+b)²+(a−b)²।",

      'step_2_1': "31 मशीन पर b को 1 पर स्लाइड करें → कारक 30।",
      'step_2_2': "32×30+1=961 पढ़ें।",
      'step_2_3': "197 मशीन पर b को 3 पर स्लाइड करें → कारक 200।",
      'step_2_4': "200×194+9=38809 पढ़ें।",

      'canvas_inst_1': "काटें और ले जाएँ: a² − b² = (a+b)(a−b)",
      'canvas_inst_1_sub': "नारंगी पट्टी L-आकार के a²−b² क्षेत्र से काटी जाती है। इसे धारीदार लक्ष्य पर खींचें ताकि L एक (a+b)×(a−b) आयत में बदल जाए।",
      'canvas_inst_1b': "इसे एक कठिन गुणनफल पर लागू करें",
      'canvas_inst_1b_sub': "केंद्र a = {a}। ऑफसेट b को स्लाइड करें जब तक कि दो कारक {f1} और {f2} न हो जाएं, फिर a² − b² पढ़ें।",
      'offset_b': "ऑफसेट b",

      'canvas_inst_2': "वर्गों के योग को दोगुना करने वाला",
      'canvas_inst_2_sub': "चार टाइलों को खींचें ताकि प्रत्येक वर्गाकार फ्रेम में एक a² टाइल और एक b² टाइल हो। दो a² और दो b² मिलकर (a+b)² और (a−b)² को ठीक-ठीक भरते हैं।",
      'canvas_inst_2b': "योग पढ़ें",
      'canvas_inst_2b_sub': "a और b सेट करें। प्रदर्शित पैटर्न a = 5, b = 6 का उपयोग करता है।",

      'canvas_inst_3a': "वर्ग करने वाली मशीन · 31²",
      'canvas_inst_3a_sub': "ऑफसेट b को स्लाइड करें जब तक कि एक कारक 10 का गुणज न बन जाए। फिर 31² = (31+b)(31−b) + b²।",
      'canvas_inst_3b': "वर्ग करने वाली मशीन · 197²",
      'canvas_inst_3b_sub': "ऑफसेट b को स्लाइड करें जब तक कि एक कारक 10 का गुणज न बन जाए। फिर 197² = (197+b)(197−b) + b²।",

      'flash_snapped': "स्ट्रिप स्नैप हो गई! L एक (a+b)×(a−b) आयत बन गया।",
      'flash_hint': "💡 संकेत सक्रिय किया गया",
      'flash_scen': "परिदृश्य पूरा हुआ! अगले पर जाएँ।",
      'flash_scen_err': "पहले इस परिदृश्य में कार्यों को पूरा करें।",
      'flash_all': "सभी परिदृश्य सुलझ गए!",
      'flash_reset': "गतिविधि पूरी तरह रीसेट हो गई।",
      
      'diag_title_pass': "सभी मामले सुलझ गए!",
      'diag_sub_pass': "आपने सफलतापूर्वक बीजीय पहचान साबित कर दी।",
      'diag_title_fail': "जासूस का कार्य प्रगति पर है",
      'diag_sub_fail': "कुछ मामलों में अभी भी काम करने की आवश्यकता है। अपनी प्रविष्टियों की जाँच करें और पुनः प्रयास करें।",
      'diag_prob': "समस्या समाधान",
      'diag_proc': "प्रक्रियात्मक प्रवाह",
      'xp_earned': "⭐ प्राप्त XP: 10 / 10",

      's1_area_rem': "हटाया गया क्षेत्रफल = a² − b²",
      's1_one_rect': "एक आयत: (a+b)(a−b) = a² − b² ✓",
      's3_easy_prod': "आसान गुणनफल प्राप्त करने के लिए कारक को गोल करें।",
      's3_round_found': "✓ गोल कारक मिल गया — आसान गुणनफल!"
    }
  };

  String t(String key) => _text[_lang]?[key] ?? _text['en']![key] ?? key;

  bool get _s1Pass => _s1StripPlaced && _s1b['98'] == 2 && _s1b['45'] == 5;
  bool get _s1Sub => _s1Pass; 
  
  bool _s2FrameOk(String frame) {
    var ids = _s2Place.entries.where((e) => e.value == frame).map((e) => e.key).toList();
    if (ids.length != 2) return false;
    bool hasA = ids.any((id) => id.startsWith('a'));
    bool hasB = ids.any((id) => id.startsWith('b'));
    return hasA && hasB;
  }
  
  bool get _s2Pass => _s2FrameOk('L') && _s2FrameOk('R') && ((_s2a == 5 && _s2b == 6) || (_s2a == 6 && _s2b == 5));
  bool get _s2Sub => _s2Pass;

  bool get _s3Pass {
    bool r31 = _s3b['31']! > 0 && (((31 - _s3b['31']!) % 10 == 0) || ((31 + _s3b['31']!) % 10 == 0));
    bool r197 = _s3b['197']! > 0 && (((197 - _s3b['197']!) % 10 == 0) || ((197 + _s3b['197']!) % 10 == 0));
    return r31 && r197;
  }
  bool get _s3Sub => _s3Pass;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _shutterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _shutterAnim = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.0)).animate(CurvedAnimation(parent: _shutterCtrl, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _shutterCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  void _playTone(String tone) {
    try {
      _player.stop();
      if (tone == 'launch') _player.play(AssetSource('audio/class8/mixkit_2018.mp3'));
      else if (tone == 'click') _player.play(AssetSource('audio/class8/mixkit_2568.mp3'));
      else if (tone == 'snap') _player.play(AssetSource('audio/class8/mixkit_2568.mp3'));
      else if (tone == 'error') _player.play(AssetSource('audio/class8/mixkit_2574.mp3'));
    } catch (e) {
      // Ignored: Android MediaPlayer SocketException when rapidly fetching remote URLs
    }
  }

  void _flash(String msg) {
    setState(() => _flashMsg = msg);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _flashMsg == msg) setState(() => _flashMsg = "");
    });
  }

  void _reset() {
    _playTone('click');
    setState(() {
      _scen = 0; _hintIdx = 0;
      _s1StripPlaced = false; _s1Target = '98'; _s1b = {'98': 0, '45': 0};
      _s2a = 5; _s2b = 6; _s2Place = {};
      _s3b = {'31': 0, '197': 0};
      _showDiagnostics = false;
      _lang = 'en';
      _showShutter = true;
    });
    _shutterCtrl.reset();
  }

  void _submit() {
    _playTone('click');
    bool passed = [_s1Pass, _s2Pass, _s3Pass][_scen];
    if (passed) {
      if (_s1Pass && _s2Pass && _s3Pass) {
        _flash(t('flash_all'));
        setState(() => _showDiagnostics = true);
      } else {
        _flash(t('flash_scen'));
      }
    } else {
      _playTone('error');
      _flash(t('flash_scen_err'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
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
                                if (_flashMsg.isNotEmpty)
                                  Positioned(
                                    top: 20, left: 0, right: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)]),
                                        child: Text(_flashMsg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          Positioned(
            top: 10, left: 10,
            child: IconButton(
              icon: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu, size: 28),
              color: Colors.orange,
              onPressed: () { _playTone('click'); setState(() => _sidebarOpen = !_sidebarOpen); },
              style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.3)),
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
              width: 64, height: 64,
              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 8))]),
              child: const Icon(Icons.join_inner, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 24),
            Text(t('app_title'), style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(t('app_subtitle'), style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _playTone('launch');
                _shutterCtrl.forward().then((_) => setState(() => _showShutter = false));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(t('start_mission'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sideCard(dynamic title, Widget content, {bool isTitleWidget = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _isDark ? const Color(0xFF1E293B) : Colors.white, border: Border.all(color: Colors.orange.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isTitleWidget ? title : Text(title, style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    bool passFlag = [_s1Pass, _s2Pass, _s3Pass][_scen];
    bool subFlag = [_s1Sub, _s2Sub, _s3Sub][_scen];

    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xD80F172A) : Colors.white.withOpacity(0.95),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.15))),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20).copyWith(top: 60),
        children: [
          Text(t('app_title'), style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(t('app_subtitle'), style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
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
              Text(_lang.toUpperCase(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.refresh), color: Colors.grey, onPressed: _reset),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.co_present, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(t('teacher_board'), style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _sideCard(t('ui_scenario'), DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _scen,
              isExpanded: true,
              dropdownColor: _isDark ? const Color(0xFF0F172A) : Colors.white,
              style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
              items: [0, 1, 2].map((i) => DropdownMenuItem(value: i, child: Text(t('scen_${i + 1}')))).toList(),
              onChanged: (v) { _playTone('click'); if (v != null) setState(() => _scen = v); },
            ),
          )),
          _sideCard(t('ui_objective'), Text(t('mission_desc'), style: TextStyle(color: _isDark ? Colors.grey.shade300 : Colors.black87, fontSize: 13))),
          _sideCard(t('ui_sequence'), Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(4, (i) {
              bool highlight = false;
              Color c = Colors.grey;
              if (passFlag) { highlight = true; c = Colors.green; }
              else if (subFlag && i == 3) { highlight = true; c = Colors.orange; }
              else if (i == 0 && !subFlag) { highlight = true; c = Colors.orange; }
              
              String stepTxt = t('step_${_scen}_${i + 1}');
              if (stepTxt == 'step_${_scen}_${i + 1}') return const SizedBox.shrink(); // In case string is missing

              return Container(
                margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: highlight ? c.withOpacity(0.1) : Colors.transparent, border: Border(left: BorderSide(color: highlight ? c : Colors.transparent, width: 4)), borderRadius: BorderRadius.circular(4)),
                child: Text('${i + 1}. $stepTxt', style: TextStyle(color: highlight ? c : (_isDark ? Colors.grey : Colors.black54), fontSize: 13, fontWeight: highlight ? FontWeight.bold : FontWeight.normal)),
              );
            }),
          )),
          _sideCard(Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t('ui_hints').toUpperCase(), style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              GestureDetector(onTap: () { _playTone('click'); setState(() => _hintIdx++); }, child: const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20)),
            ],
          ), Text(t('hint_${_scen}'), style: TextStyle(color: _isDark ? Colors.white : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)), isTitleWidget: true),
          _sideCard(t('ui_learnt'), Text(t('learnt_desc'), style: TextStyle(color: _isDark ? Colors.grey.shade300 : Colors.black87, fontSize: 13))),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: const Text('© ZEROSCIENCELAB - Fall in Love with Math and Science', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(color: _isDark ? const Color(0xFF0F172A) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.extension, color: Colors.orange, size: 24),
                    const SizedBox(width: 12),
                    Text(t('scen_${_scen + 1}'), style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Expanded(child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(t('canvas_inst_${_scen+1}'), style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_scen == 0) _renderS1() else if (_scen == 1) _renderS2() else _renderS3(),
        ],
      ),
    );
  }

  Widget _box(String title, String sub, Widget content) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: _isDark ? const Color(0xFF0F254A) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.withOpacity(0.3))),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
            if (sub.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _renderS1() {
    double a = 6, b = 2;
    double u = 100 / (a + b), uy = 100 / a;
    
    String cTarget = _s1Target;
    var cfg = _s1Cfg[cTarget];
    int ca = cfg['a'], cb = _s1b[cTarget]!, cf1 = ca - cb, cf2 = ca + cb, cans = ca*ca - cb*cb;
    bool isHit = (cf1 == cfg['f1'] && cf2 == cfg['f2']);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _box(t('canvas_inst_1'), t('canvas_inst_1_sub'), Column(
          children: [
            SizedBox(
              width: 280, height: 280,
              child: Stack(
                children: [
                  Positioned(left: 0, top: b*uy*2.8, width: a*u*2.8, height: (a-b)*uy*2.8, child: Container(
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3), border: Border.all(color: Colors.blueAccent, width: 2), borderRadius: BorderRadius.circular(4)),
                    alignment: Alignment.center, child: const Text('a(a−b)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )),
                  Positioned(left: (a-b)*u*2.8, top: 0, width: b*u*2.8, height: b*uy*2.8, child: Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), border: Border.all(color: Colors.white30, width: 2, style: BorderStyle.solid), borderRadius: BorderRadius.circular(4)),
                    alignment: Alignment.center, child: const Text('b²', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                  )),
                  Positioned(left: a*u*2.8, top: 0, width: b*u*2.8, height: (a-b)*uy*2.8, child: DragTarget<String>(
                    onWillAcceptWithDetails: (d) => !_s1StripPlaced,
                    onAcceptWithDetails: (d) { _playTone('snap'); _flash(t('flash_snapped')); setState(() => _s1StripPlaced = true); },
                    builder: (context, c, r) => Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), border: Border.all(color: Colors.white54, width: 2)),
                    ),
                  )),
                  if (!_s1StripPlaced)
                    Positioned(left: 0, top: 0, width: (a-b)*u*2.8, height: b*uy*2.8, child: Draggable<String>(
                      data: 'strip',
                      feedback: Container(
                        width: (a-b)*u*2.8, height: b*uy*2.8,
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.8), border: Border.all(color: Colors.orange, width: 2), borderRadius: BorderRadius.circular(4)),
                      ),
                      childWhenDragging: const SizedBox.shrink(),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.4), border: Border.all(color: Colors.orange, width: 2), borderRadius: BorderRadius.circular(4)),
                        alignment: Alignment.center,
                      ),
                    )),
                  if (_s1StripPlaced)
                    Positioned(left: a*u*2.8, top: 0, width: b*u*2.8, height: (a-b)*uy*2.8, child: Container(
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.4), border: Border.all(color: Colors.green, width: 2), borderRadius: BorderRadius.circular(4)),
                      alignment: Alignment.center, child: const Text('b(a−b)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(_s1StripPlaced ? t('s1_one_rect') : t('s1_area_rem'), style: TextStyle(color: _s1StripPlaced ? Colors.green : Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        )),
        _box(t('canvas_inst_1b'), t('canvas_inst_1b_sub').replaceAll('{a}', ca.toString()).replaceAll('{f1}', cfg['f1'].toString()).replaceAll('{f2}', cfg['f2'].toString()), Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['98', '45'].map((v) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(v == '98' ? '98 × 102' : '45 × 55', style: const TextStyle(fontWeight: FontWeight.bold)),
                  selected: _s1Target == v,
                  selectedColor: Colors.orange,
                  backgroundColor: _isDark ? const Color(0xFF061024) : Colors.white,
                  labelStyle: TextStyle(color: _s1Target == v ? Colors.white : (_isDark ? Colors.white : Colors.black)),
                  onSelected: (sel) { if (sel) { _playTone('click'); setState(() => _s1Target = v); } },
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _stepperBtn('-', () { if (cb > 0) { _playTone('tick'); setState(() => _s1b[cTarget] = cb - 1); } }),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: _isDark ? const Color(0xFF061024) : Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Text('$cb', style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(t('offset_b'), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
                _stepperBtn('+', () { if (cb < 12) { _playTone('tick'); setState(() => _s1b[cTarget] = cb + 1); } }),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: _isDark ? const Color(0xFF061024) : Colors.white, borderRadius: BorderRadius.circular(8)), child: Text('a−b = $cf1', style: TextStyle(color: cf1 == cfg['f1'] ? Colors.green : Colors.grey, fontWeight: FontWeight.bold, fontSize: 16))),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: _isDark ? const Color(0xFF061024) : Colors.white, borderRadius: BorderRadius.circular(8)), child: Text('a+b = $cf2', style: TextStyle(color: cf2 == cfg['f2'] ? Colors.green : Colors.grey, fontWeight: FontWeight.bold, fontSize: 16))),
              ],
            ),
            const SizedBox(height: 16),
            Text('a² − b² = $cans', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(isHit ? '✓ ${cfg['f1']} × ${cfg['f2']} = ${cfg['ans']}' : '', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        )),
      ],
    );
  }

  Widget _stepperBtn(String txt, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: Text(txt, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _renderS2() {
    int L = 2 * (_s2a*_s2a + _s2b*_s2b);
    int R = (_s2a+_s2b)*(_s2a+_s2b) + (_s2a-_s2b).abs()*(_s2a-_s2b).abs();
    
    List<String> tiles = ['a1', 'a2', 'b1', 'b2'];
    Widget tileWidget(String id) {
      bool isA = id.startsWith('a');
      return Draggable<String>(
        data: id,
        feedback: Container(width: 60, height: 60, decoration: BoxDecoration(color: isA ? Colors.amber : Colors.blue, borderRadius: BorderRadius.circular(8)), alignment: Alignment.center, child: Text(isA ? 'a²' : 'b²', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
        childWhenDragging: const SizedBox(width: 60, height: 60),
        child: Container(width: 60, height: 60, decoration: BoxDecoration(color: isA ? Colors.amber : Colors.blue, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]), alignment: Alignment.center, child: Text(isA ? 'a²' : 'b²', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      );
    }

    Widget frameDrop(String frameId, String title) {
      bool isOk = _s2FrameOk(frameId);
      return Container(
        width: 140, constraints: const BoxConstraints(minHeight: 100),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), border: Border.all(color: isOk ? Colors.green : Colors.orange, width: 2, style: isOk ? BorderStyle.solid : BorderStyle.none), borderRadius: BorderRadius.circular(12)),
        child: DragTarget<String>(
          onAcceptWithDetails: (d) { _playTone('snap'); setState(() => _s2Place[d.data] = frameId); },
          builder: (c, acc, rej) {
            var placed = _s2Place.entries.where((e) => e.value == frameId).map((e) => e.key).toList();
            return Column(
              children: [
                Text(title, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
                  children: placed.map((id) => GestureDetector(
                    onTap: () { _playTone('snap'); setState(() => _s2Place.remove(id)); },
                    child: tileWidget(id)
                  )).toList(),
                )
              ],
            );
          },
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _box(t('canvas_inst_2'), t('canvas_inst_2_sub'), Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12), constraints: const BoxConstraints(minHeight: 84),
              decoration: BoxDecoration(color: _isDark ? const Color(0xFF061024) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
              child: Wrap(
                spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
                children: tiles.where((id) => !_s2Place.containsKey(id)).map((id) => tileWidget(id)).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                frameDrop('L', '(a+b)² frame'),
                const SizedBox(width: 16),
                frameDrop('R', '(a−b)² frame'),
              ],
            ),
          ],
        )),
        _box(t('canvas_inst_2b'), t('canvas_inst_2b_sub'), Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _stepperBtn('-', () { if (_s2a > 1) { _playTone('tick'); setState(() => _s2a--); } }),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: _isDark ? const Color(0xFF061024) : Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Column(children: [Text('$_s2a', style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)), const Text('a', style: TextStyle(color: Colors.grey, fontSize: 10))]),
                ),
                _stepperBtn('+', () { if (_s2a < 20) { _playTone('tick'); setState(() => _s2a++); } }),
                
                const SizedBox(width: 16),
                
                _stepperBtn('-', () { if (_s2b > 1) { _playTone('tick'); setState(() => _s2b--); } }),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: _isDark ? const Color(0xFF061024) : Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Column(children: [Text('$_s2b', style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)), const Text('b', style: TextStyle(color: Colors.grey, fontSize: 10))]),
                ),
                _stepperBtn('+', () { if (_s2b < 20) { _playTone('tick'); setState(() => _s2b++); } }),
              ],
            ),
            const SizedBox(height: 24),
            Text('2(a²+b²) = $L', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('(a+b)² + (${(_s2a-_s2b).abs()})² = $R', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(_s2FrameOk('L') && _s2FrameOk('R') && L == R ? '✓ Both squares total $L = 2(a²+b²)' : '', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        )),
      ],
    );
  }

  Widget _renderS3() {
    Widget s3Box(String key) {
      var cfg = _s3Cfg[key];
      int ca = cfg['a'], cb = _s3b[key]!, cf1 = ca - cb, cf2 = ca + cb, cprod = cf1 * cf2, ctot = cprod + cb * cb;
      bool isRound = (cf1 % 10 == 0) || (cf2 % 10 == 0);
      
      return _box(t(key == '31' ? 'canvas_inst_3a' : 'canvas_inst_3b'), t(key == '31' ? 'canvas_inst_3a_sub' : 'canvas_inst_3b_sub'), Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stepperBtn('-', () { if (cb > 0) { _playTone('tick'); setState(() => _s3b[key] = cb - 1); } }),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: _isDark ? const Color(0xFF061024) : Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Column(children: [Text('$cb', style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)), Text(t('offset_b'), style: const TextStyle(color: Colors.grey, fontSize: 10))]),
              ),
              _stepperBtn('+', () { if (cb < cfg['max']) { _playTone('tick'); setState(() => _s3b[key] = cb + 1); } }),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _isDark ? const Color(0xFF061024) : Colors.white, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Column(
              children: [
                if (cb == 0) ...[
                  Text('$ca² = $ca×$ca + 0 = $ctot', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(t('s3_easy_prod'), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                ] else ...[
                  Text('$ca² = ($ca+$cb)($ca−$cb) + $cb² = $cf2×$cf1 + ${cb*cb} = $ctot', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('$cf2×$cf1 = $cprod', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                ]
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(isRound && cb > 0 ? t('s3_round_found') : '', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        s3Box('31'),
        s3Box('197'),
      ],
    );
  }

  Widget _hudBtn(IconData icon, String label, VoidCallback? onTap, {bool isPrimary = false, bool reverseIcon = false}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.orange : (_isDark ? const Color(0xFF1E293B) : Colors.white),
        foregroundColor: isPrimary ? Colors.white : (_isDark ? Colors.white : Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: isPrimary ? Colors.orange : Colors.orange.withOpacity(0.3))),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reverseIcon
            ? [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 8), Icon(icon, size: 20)]
            : [Icon(icon, size: 20), const SizedBox(width: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.bold))],
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
              _hudBtn(Icons.chevron_left, t('nav_prev'), _scen > 0 ? () { _playTone('click'); setState(() => _scen--); } : null),
              const SizedBox(width: 8),
              _hudBtn(Icons.chevron_right, t('nav_next'), _scen < 2 ? () { _playTone('click'); setState(() => _scen++); } : null, reverseIcon: true),
              Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.3), margin: const EdgeInsets.symmetric(horizontal: 16)),
              _hudBtn(Icons.check_circle, t('nav_submit'), _submit, isPrimary: true),
              const SizedBox(width: 8),
              _hudBtn(Icons.bar_chart, t('nav_report'), passedAll ? () { _playTone('click'); setState(() => _showDiagnostics = true); } : null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _diagMetric(String label, int pct) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _isDark ? const Color(0xFF061024) : Colors.white, border: Border.all(color: Colors.orange.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: pct / 100, backgroundColor: Colors.grey.withOpacity(0.2), color: Colors.orange, minHeight: 8),
          ),
          const SizedBox(height: 4),
          Text('$pct%', style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDiagnosticsModal() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      alignment: Alignment.center,
      child: Container(
        width: 450,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: _isDark ? const Color(0xFF0A1936) : Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.orange.withOpacity(0.3))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: Colors.green, width: 2)), child: const Icon(Icons.check, color: Colors.green, size: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('diag_title_pass'), style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(t('diag_sub_pass'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.orange, Colors.amber]), borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: Text(t('xp_earned'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _diagMetric(t('diag_prob'), 100)), const SizedBox(width: 12),
                        Expanded(child: _diagMetric(t('diag_proc'), 100)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () { _playTone('click'); setState(() => _showDiagnostics = false); },
                    style: ElevatedButton.styleFrom(backgroundColor: _isDark ? const Color(0xFF1E293B) : Colors.white, foregroundColor: _isDark ? Colors.white : Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orange.withOpacity(0.3))), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(t('ui_close'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _reset,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(t('restart_mission'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
