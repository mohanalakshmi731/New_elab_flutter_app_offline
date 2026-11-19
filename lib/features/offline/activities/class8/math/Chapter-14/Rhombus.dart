// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math';

const Map<String, Map<String, dynamic>> I18N = {
  'en': {
    'app_title': 'Rhombus Diagonals Lab',
    'app_subtitle': 'Class 8 • Area',
    'start_mission': 'Start Mission',
    'sidebar_title': 'Teacher Board',
    'ui_objective': 'Mission Objective',
    'mission_desc': 'Derive Area = ½ × d1 × d2 by pulling the diagonals and dissecting the shape into a rectangle.',
    'ui_concepts': 'Core Concepts',
    'guide_desc': '• A rhombus is a quadrilateral with all four sides equal in length.\n\n• Its two diagonals always intersect at right angles (perpendicular) and bisect each other (each is cut exactly in half at the crossing point).\n\n• This lets the diagonals split the rhombus into 4 congruent right-angled triangles, each with legs d1/2 and d2/2.\n\n• Rearranging these four triangles (translating the pieces) tiles them into a rectangle of size d1 × (d2/2), with no gaps or overlaps.\n\n• Since the rectangle\'s area = d1 × d2/2 = ½ × d1 × d2, and the pieces were only cut and moved (never resized), the rhombus must have that same area.',
    'ui_sequence': 'Current Step',
    'data_readouts': 'Data Readouts',
    'btn_verify': 'VERIFY',
    'btn_prev': 'Prev',
    'btn_next': 'Next',
    'btn_prove': 'PROVE IT',
    'hints': 'Hints / Proof',
    'h_0': 'Drag the cyan (d1) and amber (d2) handles. Watch the d1 and d2 readouts until they hit exactly 4.0 and 5.0.',
    'h_1': 'Pick ANY new pair (like d1=6, d2=3). Press PROVE IT, watch the animation, then explain what you saw in the text box.',
    'scen_1': 'Step 1 of 2: Build the Target Rhombus',
    'scen_1_desc': 'Drag the two diagonal handles (cyan = d1, amber = d2) until d1 = 4 cm and d2 = 5 cm. Watch the live area meter, then press VERIFY.',
    'scen_1_btn': 'VERIFY AREA = 10',
    'scen_2': 'Step 2 of 2: Prove It Generalises',
    'scen_2_desc': 'Drag the diagonals to any NEW pair of lengths (not 4 and 5). Write one sentence explaining why the formula still works, press PROVE IT, then press VERIFY.',
    'scen_2_btn': 'VERIFY GENERAL CASE',
    'err_target': 'Not quite yet. Drag until d1 = 4 cm and d2 = 5 cm.',
    'err_distinct': 'Pick a NEW pair distinct from d1=4, d2=5 to prove the rule generalizes.',
    'err_prove': 'Press PROVE IT to watch the dissection before verifying.',
    'err_reason': 'Please add a sentence explaining how the dissection proves ½×d1×d2 before verifying.',
    'success_msg': 'Correct!',
    'reason_lbl': 'Reasoning',
    'd1_lbl': 'Diagonal d1',
    'd2_lbl': 'Diagonal d2',
    'area_lbl': 'Area',
  },
  'hi': {
    'app_title': 'समचतुर्भुज विकर्ण प्रयोगशाला',
    'app_subtitle': 'कक्षा 8 • क्षेत्रफल',
    'start_mission': 'मिशन शुरू करें',
    'sidebar_title': 'शिक्षक बोर्ड',
    'ui_objective': 'मिशन का उद्देश्य',
    'mission_desc': 'विकर्णों को खींचकर और आकार को एक आयत में काटकर समचतुर्भुज का क्षेत्रफल = ½ × d1 × d2 प्राप्त करें।',
    'ui_concepts': 'मूल अवधारणाएं',
    'guide_desc': '• समचतुर्भुज एक चतुर्भुज है जिसकी चारों भुजाएं समान लंबाई की होती हैं।\n\n• इसके दो विकर्ण हमेशा समकोण (लंबवत) पर प्रतिच्छेद करते हैं और एक दूसरे को समद्विभाजित करते हैं (प्रतिच्छेदन बिंदु पर प्रत्येक को ठीक आधा काटा जाता है)।\n\n• यह विकर्णों को समचतुर्भुज को 4 सर्वांगसम समकोण त्रिभुजों में विभाजित करने देता है, जिनमें से प्रत्येक के पैर d1/2 और d2/2 हैं।\n\n• इन चार त्रिभुजों को पुनर्व्यवस्थित करने पर (टुकड़ों को खिसकाकर) वे बिना किसी अंतराल या अतिव्यापन के d1 × (d2/2) आकार के आयत में टाइल हो जाते हैं।\n\n• चूँकि आयत का क्षेत्रफल = d1 × d2/2 = ½ × d1 × d2 है, और टुकड़ों को केवल काटा और खिसकाया गया था (कभी भी आकार नहीं बदला गया), समचतुर्भुज का क्षेत्रफल भी वही होना चाहिए।',
    'ui_sequence': 'वर्तमान चरण',
    'data_readouts': 'डेटा रीडआउट्स',
    'btn_verify': 'सत्यापित करें',
    'btn_prev': 'पिछला',
    'btn_next': 'अगला',
    'btn_prove': 'सिद्ध करें',
    'hints': 'संकेत / प्रमाण',
    'h_0': 'सियान (d1) और अंबर (d2) हैंडल खींचें। d1 और d2 रीडिंग को तब तक देखें जब तक वे ठीक 4.0 और 5.0 न हो जाएं।',
    'h_1': 'कोई भी नई जोड़ी चुनें (जैसे d1=6, d2=3)। PROVE IT दबाएं, एनीमेशन देखें, फिर टेक्स्ट बॉक्स में बताएं कि आपने क्या देखा।',
    'scen_1': 'चरण 1/2: लक्ष्य समचतुर्भुज बनाएं',
    'scen_1_desc': 'दोनों विकर्ण हैंडल (सियान = d1, अंबर = d2) तब तक खींचें जब तक d1 = 4 सेमी और d2 = 5 सेमी न हो जाए। लाइव क्षेत्रफल मीटर देखें, फिर VERIFY दबाएं।',
    'scen_1_btn': 'क्षेत्रफल = 10 सत्यापित करें',
    'scen_2': 'चरण 2/2: सिद्ध करें कि यह सामान्यीकृत है',
    'scen_2_desc': 'विकर्णों को किसी भी नई लंबाई की जोड़ी (4 और 5 नहीं) तक खींचें। एक वाक्य लिखें जो बताए कि सूत्र अभी भी क्यों काम करता है, सिद्ध करें दबाएं, फिर सत्यापित करें दबाएं।',
    'scen_2_btn': 'सामान्य स्थिति सत्यापित करें',
    'err_target': 'अभी सही नहीं है। तब तक खींचें जब तक d1 = 4 सेमी और d2 = 5 सेमी न हो जाए।',
    'err_distinct': 'd1=4, d2=5 से भिन्न एक नई जोड़ी चुनें, यह सिद्ध करने के लिए कि नियम सामान्यीकृत होता है।',
    'err_prove': 'सत्यापित करने से पहले विच्छेदन देखने के लिए सिद्ध करें दबाएं।',
    'err_reason': 'सत्यापित करने से पहले यह बताते हुए एक वाक्य जोड़ें कि विच्छेदन ½×d1×d2 को कैसे सिद्ध करता है।',
    'success_msg': 'सही!',
    'reason_lbl': 'कारण',
    'd1_lbl': 'विकर्ण d1',
    'd2_lbl': 'विकर्ण d2',
    'area_lbl': 'क्षेत्रफल',
  }
};



class RhombusDiagonalsApp extends StatefulWidget {
  const RhombusDiagonalsApp({super.key});

  @override
  State<RhombusDiagonalsApp> createState() => _RhombusDiagonalsAppState();
}

class _RhombusDiagonalsAppState extends State<RhombusDiagonalsApp> with TickerProviderStateMixin {
  String _currentLang = 'en';
  bool _isShutterOpen = true;
  bool _isSidebarOpen = true;

  final AudioPlayer _audioClick = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _audioSuccess = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _audioError = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  int _currentStep = 0;
  double _d1 = 6.0; // horizontal
  double _d2 = 4.0; // vertical
  
  bool _hasProved = false;
  final TextEditingController _reasonController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _animValue;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animValue = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    
    _animController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioClick.dispose();
    _audioSuccess.dispose();
    _audioError.dispose();
    _animController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _playSound(String type) {
    try {
      if (type == 'click') {
        _audioClick.play(AssetSource("audio/class8/mixkit_2574.mp3"));
      } else if (type == 'success') {
        _audioSuccess.play(AssetSource("audio/class8/mixkit_2018.mp3"));
      } else if (type == 'error') {
        _audioError.play(AssetSource("audio/class8/mixkit_955.mp3"));
      }
    } catch (e) {
      debugPrint("Audio error: $e");
    }
  }

  void _showToast(String title, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _verifyStep() {
    _playSound('click');
    var t = I18N[_currentLang]!;
    
    if (_currentStep == 0) {
      if ((_d1 - 4.0).abs() < 0.1 && (_d2 - 5.0).abs() < 0.1) {
        _playSound('success');
        _showToast(t['success_msg']);
        setState(() {
          _currentStep++;
          _animController.reset();
        });
      } else {
        _playSound('error');
        _showToast(t['err_target'], isError: true);
      }
    } else if (_currentStep == 1) {
      if ((_d1 - 4.0).abs() < 0.1 && (_d2 - 5.0).abs() < 0.1) {
        _playSound('error');
        _showToast(t['err_distinct'], isError: true);
        return;
      }
      if (!_hasProved) {
        _playSound('error');
        _showToast(t['err_prove'], isError: true);
        return;
      }
      if (_reasonController.text.trim().length < 5) {
        _playSound('error');
        _showToast(t['err_reason'], isError: true);
        return;
      }
      _playSound('success');
      _showToast(t['success_msg']);
      _showSuccessPopup();
    }
  }

  void _toggleProve() {
    _playSound('click');
    if (_animController.isCompleted) {
      _animController.reverse();
    } else {
      _animController.forward();
      setState(() {
        _hasProved = true;
      });
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        var t = I18N[_currentLang]!;
        return Container(
          color: Colors.black.withOpacity(0.85),
          child: Center(
            child: Container(
              width: 360,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                borderRadius: BorderRadius.circular(20),
                border: const Border(top: BorderSide(color: Colors.greenAccent, width: 4)),
                boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.2), blurRadius: 30)]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.greenAccent, size: 70),
                  const SizedBox(height: 16),
                  const Text("MISSION ACCOMPLISHED", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  const Text("You proved the Area formula of a Rhombus by dissecting it into a rectangle.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _playSound('click');
                        Navigator.of(context).pop();
                        _resetApp();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('RESTART'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  void _resetApp() {
    _playSound('click');
    setState(() {
      _currentLang = 'en';
      _currentStep = 0;
      _d1 = 6.0;
      _d2 = 4.0;
      _hasProved = false;
      _reasonController.clear();
      _animController.reset();
      _isShutterOpen = true;
      _isSidebarOpen = true;
    });
  }

  Widget _buildSidebarSection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1e293b), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.cyan, size: 12),
              const SizedBox(width: 6),
              Text(title.toUpperCase(), style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.0)),
            ],
          ),
          const SizedBox(height: 8),
          if (content.isNotEmpty)
            Text(content, style: const TextStyle(color: Colors.white, height: 1.4, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSidebarSectionWidget(String title, Widget child, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1e293b), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.cyan, size: 12),
              const SizedBox(width: 6),
              Text(title.toUpperCase(), style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.0)),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String val, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11))),
          Text(val, style: TextStyle(color: color ?? (isTotal ? Colors.greenAccent : Colors.cyanAccent), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildReadouts(Map<String, dynamic> t) {
    return Column(
      children: [
        _buildRow(t['d1_lbl'], "${_d1.toStringAsFixed(1)} cm", color: Colors.cyanAccent),
        _buildRow(t['d2_lbl'], "${_d2.toStringAsFixed(1)} cm", color: Colors.amberAccent),
        const Divider(color: Color(0xFF334155)),
        _buildRow(t['area_lbl'], "${((_d1 * _d2) / 2).toStringAsFixed(1)} sq cm", isTotal: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var t = I18N[_currentLang]!;
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth > 800 ? 320 : screenWidth * 0.45;

    return GestureDetector(
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: _isShutterOpen
            ? _buildShutterScreen(t)
            : Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: _isSidebarOpen ? sidebarWidth : 0,
                    top: 0, bottom: 0, right: 0,
                    child: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/offline_texture.png'),
                              repeat: ImageRepeat.repeat,
                            ),
                          ),
                        ),
                        _buildCanvasArea(),
                      ],
                    ),
                  ),

                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: _isSidebarOpen ? 0 : -sidebarWidth,
                    top: 0, bottom: 0, width: sidebarWidth,
                    child: _buildSidebar(t),
                  ),

                  if (!_isShutterOpen)
                    Positioned(
                      left: 12, top: 12,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: const Color(0xFF1e293b).withOpacity(0.9),
                        foregroundColor: Colors.cyanAccent,
                        elevation: 4,
                        onPressed: () {
                          _playSound('click');
                          setState(() => _isSidebarOpen = !_isSidebarOpen);
                        },
                        child: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu, size: 20),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildShutterScreen(Map<String, dynamic> t) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: BoxDecoration(
          color: const Color(0xFF0f172a),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.cyan.withOpacity(0.4)),
          boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.2), blurRadius: 40)]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.change_history, size: 70, color: Colors.cyanAccent),
            const SizedBox(height: 24),
            Text(t['app_title'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(t['app_subtitle'], style: const TextStyle(fontSize: 12, color: Colors.cyan, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _playSound('click');
                setState(() => _isShutterOpen = false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(t['start_mission'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(Map<String, dynamic> t) {
    return Container(
      color: const Color(0xFF0f172a).withOpacity(0.95),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Compact Header
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: Colors.cyan.shade600, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.change_history, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['app_title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(t['app_subtitle'], style: const TextStyle(color: Colors.cyan, fontSize: 9, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Tools
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  _playSound('click');
                  setState(() => _currentLang = _currentLang == 'en' ? 'hi' : 'en');
                },
                icon: const Icon(Icons.language, color: Colors.grey, size: 16),
                label: Text(_currentLang.toUpperCase(), style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              IconButton(icon: const Icon(Icons.refresh, color: Colors.grey, size: 18), onPressed: () {
                _playSound('click');
                _resetApp();
              }),
            ],
          ),
          const Divider(color: Color(0xFF334155)),
          const SizedBox(height: 8),

          _buildSidebarSection(t['ui_objective'], t['mission_desc'], Icons.track_changes),
          const SizedBox(height: 8),
          _buildSidebarSection(t['ui_concepts'], t['guide_desc'], Icons.lightbulb_outline),
          const SizedBox(height: 8),

          _buildSidebarSectionWidget(
            t['data_readouts'],
            _buildReadouts(t),
            Icons.bar_chart
          ),
          const SizedBox(height: 12),

          _buildSidebarSectionWidget(
            t['ui_sequence'],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['scen_${_currentStep + 1}'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.cyanAccent)),
                const SizedBox(height: 8),
                Text(t['scen_${_currentStep + 1}_desc'], style: const TextStyle(fontSize: 11, color: Colors.white)),
                if (_currentStep == 1) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reasonController,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: t['reason_lbl'],
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1e293b),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                    ),
                  ),
                ],
              ],
            ),
            Icons.list_alt
          ),
          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: _toggleProve,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(t['btn_prove'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: _verifyStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(t['scen_${_currentStep + 1}_btn'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 12),

          _buildSidebarSection(t['hints'], t['h_$_currentStep'], Icons.lightbulb),
          const SizedBox(height: 24),
          
          // Footer
          const Center(
            child: Text('© ZeroScienceLab - Fall in love with Math & Science', style: TextStyle(color: Colors.grey, fontSize: 8, letterSpacing: 1, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCanvasArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (details) => _handleDrag(details.localPosition, Size(constraints.maxWidth, constraints.maxHeight)),
          onPanStart: (details) => _handleDrag(details.localPosition, Size(constraints.maxWidth, constraints.maxHeight)),
          child: Container(
            color: Colors.transparent,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: CustomPaint(
              painter: RhombusPainter(
                d1: _d1,
                d2: _d2,
                animValue: _animValue.value,
              ),
            ),
          ),
        );
      }
    );
  }

  void _handleDrag(Offset localPos, Size size) {
    if (_animController.value > 0.0) return; // Disable dragging during dissection
    
    Offset center = Offset(size.width / 2, size.height / 2);
    double pixelsPerCm = 20.0; // Scale factor matches A5 grid
    
    // Determine if drag is closer to horizontal handle (d1) or vertical handle (d2)
    double handleD1x = center.dx + (_d1 / 2) * pixelsPerCm;
    double handleD1y = center.dy;
    
    double handleD2x = center.dx;
    double handleD2y = center.dy - (_d2 / 2) * pixelsPerCm;
    
    double distD1 = (localPos - Offset(handleD1x, handleD1y)).distance;
    double distD2 = (localPos - Offset(handleD2x, handleD2y)).distance;
    
    if (distD1 < distD2 && distD1 < 100) {
      double newD1 = (localPos.dx - center.dx) * 2 / pixelsPerCm;
      newD1 = newD1.clamp(2.0, 16.0);
      newD1 = (newD1 * 10).roundToDouble() / 10;
      setState(() {
        _d1 = newD1;
      });
    } else if (distD2 < distD1 && distD2 < 100) {
      double newD2 = (center.dy - localPos.dy) * 2 / pixelsPerCm;
      newD2 = newD2.clamp(2.0, 14.0);
      newD2 = (newD2 * 10).roundToDouble() / 10;
      setState(() {
        _d2 = newD2;
      });
    }
  }
}

class RhombusPainter extends CustomPainter {
  final double d1;
  final double d2;
  final double animValue;

  RhombusPainter({required this.d1, required this.d2, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    double pixelsPerCm = 20.0;
    Offset center = Offset(size.width / 2, size.height / 2);
    
    double w = (d1 / 2) * pixelsPerCm; // half width
    double h = (d2 / 2) * pixelsPerCm; // half height
    
    // Grid and Axes
    final gridP = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1;
    final axisP = Paint()..color = Colors.white.withOpacity(0.2)..strokeWidth = 2;
    for (int i = -40; i <= 40; i++) {
      canvas.drawLine(Offset(center.dx + i * pixelsPerCm, 0), Offset(center.dx + i * pixelsPerCm, size.height), gridP);
      canvas.drawLine(Offset(0, center.dy + i * pixelsPerCm), Offset(size.width, center.dy + i * pixelsPerCm), gridP);
    }
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), axisP);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), axisP);

    // Base positions relative to center
    List<Offset> pT1 = [Offset.zero, Offset(w, 0), Offset(0, -h)];
    List<Offset> pT2 = [Offset.zero, Offset(-w, 0), Offset(0, -h)];
    List<Offset> pT3 = [Offset.zero, Offset(-w, 0), Offset(0, h)];
    List<Offset> pT4 = [Offset.zero, Offset(w, 0), Offset(0, h)];
    
    Offset offsetT3 = Offset(w * animValue, -h * animValue);
    Offset offsetT4 = Offset(-w * animValue, -h * animValue);
    
    Paint fillPaint = Paint()..style = PaintingStyle.fill;
    Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.cyanAccent.withOpacity(0.8)
      ..strokeWidth = 2;

    void drawTriangle(List<Offset> pts, Offset tOffset, Color color) {
      Path path = Path();
      path.moveTo(center.dx + pts[0].dx + tOffset.dx, center.dy + pts[0].dy + tOffset.dy);
      path.lineTo(center.dx + pts[1].dx + tOffset.dx, center.dy + pts[1].dy + tOffset.dy);
      path.lineTo(center.dx + pts[2].dx + tOffset.dx, center.dy + pts[2].dy + tOffset.dy);
      path.close();
      
      fillPaint.color = color;
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }
    
    // Draw 4 triangles
    drawTriangle(pT1, Offset.zero, Colors.blue.withOpacity(0.5));
    drawTriangle(pT2, Offset.zero, Colors.green.withOpacity(0.5));
    drawTriangle(pT3, offsetT3, Colors.orange.withOpacity(0.5));
    drawTriangle(pT4, offsetT4, Colors.purple.withOpacity(0.5));
    
    // Draw Diagonals (only when not fully dissected)
    if (animValue < 0.1) {
      Paint d1Paint = Paint()..color = Colors.cyan..strokeWidth = 3;
      Paint d2Paint = Paint()..color = Colors.amber..strokeWidth = 3;
      
      // Horizontal d1
      canvas.drawLine(Offset(center.dx - w, center.dy), Offset(center.dx + w, center.dy), d1Paint);
      // Vertical d2
      canvas.drawLine(Offset(center.dx, center.dy - h), Offset(center.dx, center.dy + h), d2Paint);
      
      // Handles
      Paint handleD1 = Paint()..color = Colors.cyan.withOpacity(0.5)..style = PaintingStyle.fill;
      Paint handleD2 = Paint()..color = Colors.amber.withOpacity(0.5)..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(center.dx + w, center.dy), 10, handleD1);
      canvas.drawCircle(Offset(center.dx + w, center.dy), 6, Paint()..color = Colors.cyan);
      
      canvas.drawCircle(Offset(center.dx, center.dy - h), 10, handleD2);
      canvas.drawCircle(Offset(center.dx, center.dy - h), 6, Paint()..color = Colors.amber);
      
      // Handle Labels
      _drawText(canvas, 'd1', Offset(center.dx + w + 16, center.dy - 10), Colors.cyanAccent);
      _drawText(canvas, 'd2', Offset(center.dx + 16, center.dy - h - 10), Colors.amberAccent);
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, Color color) {
    final textStyle = TextStyle(
      color: color,
      fontSize: 13,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.black45,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: 200);
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant RhombusPainter oldDelegate) {
    return oldDelegate.d1 != d1 || oldDelegate.d2 != d2 || oldDelegate.animValue != animValue;
  }
}
