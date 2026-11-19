// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

const Map<String, Map<String, dynamic>> I18N = {
  'en': {
    'app_title': 'Area of Trapezium',
    'app_subtitle': 'Class 8 • AREA',
    'start_mission': 'ENTER LAB',
    'mission_desc': 'Discover how to find the area of a trapezium by turning it into shapes you already know.',
    'guide_desc': '• Rectangle Area = base × height\n• Triangle Area = 1/2 × base × height\n• Parallelogram Area = base × height',
    'ui_objective': 'Mission Objective',
    'ui_concepts': 'Core Concepts',
    'ui_sequence': 'Procedural Steps',
    'data_readouts': 'Measurements',
    'hints': 'System Hint',
    'btn_prev': 'PREV',
    'btn_next': 'NEXT',
    'success_msg': 'Task Completed Successfully!',
    
    'scen_1': 'Step 1: Decomposition Method',
    'scen_1_desc': 'A trapezium has one pair of parallel sides. We can find its area by cutting it into a rectangle and two triangles.',
    'scen_1_btn': 'Dissect Shape',
    'h_0': 'Tap the dissect button to drop perpendiculars and slice the shape.',
    
    'scen_2': 'Step 2: Cutting & Pasting',
    'scen_2_desc': 'Let\'s derive a single formula. Take a second identical trapezium, flip it, and attach it to the first to form a parallelogram.',
    'scen_2_btn': 'Duplicate & Flip',
    'h_1': 'Tap the button to create a parallelogram with base (a+b) and height h.',
    
    'scen_3': 'Step 3: Figure It Out',
    'scen_3_desc': 'Area = 1/2 × (sum of parallel sides) × height. Find the area of a trapezium with parallel sides 10 cm and 12 cm, and height 4 cm.',
    'scen_3_btn': 'Verify Area',
    'h_2': 'Sum = 22, half is 11, multiply by 4.',
    'area_lbl': 'Total Area:',
    
    'scen_4': 'Step 4: River Problem',
    'scen_4_desc': 'A trapezium field has a river side parallel to a road side. The river side is twice as long as the road side. Area = 10500 sq.m, Height = 100 m. Find their lengths.',
    'scen_4_btn': 'Verify Lengths',
    'h_3': 'Area = 1/2 × (x + 2x) × 100 = 10500. Solve for x.',
    'road_lbl': 'Road Side (x):',
    'river_lbl': 'River Side (2x):',
    
    'err_val': 'Incorrect value. Try again!',
    'err_empty': 'Please fill all fields before verifying.'
  },
  'hi': {
    'app_title': 'समलंब का क्षेत्रफल',
    'app_subtitle': 'कक्षा 8 • क्षेत्रफल',
    'start_mission': 'लैब में प्रवेश करें',
    'mission_desc': 'समलंब के क्षेत्रफल को उन आकृतियों में बदलकर खोजना सीखें जिन्हें आप पहले से जानते हैं।',
    'guide_desc': '• आयत का क्षेत्रफल = आधार × ऊंचाई\n• त्रिभुज का क्षेत्रफल = 1/2 × आधार × ऊंचाई\n• समांतर चतुर्भुज का क्षेत्रफल = आधार × ऊंचाई',
    'ui_objective': 'मिशन का उद्देश्य',
    'ui_concepts': 'मूल अवधारणाएं',
    'ui_sequence': 'प्रक्रियात्मक चरण',
    'data_readouts': 'माप',
    'hints': 'सिस्टम संकेत',
    'btn_prev': 'पिछला',
    'btn_next': 'अगला',
    'success_msg': 'कार्य सफलतापूर्वक पूर्ण हुआ!',
    
    'scen_1': 'चरण 1: अपघटन विधि',
    'scen_1_desc': 'समलंब में समानांतर भुजाओं की एक जोड़ी होती है। हम इसे एक आयत और दो त्रिभुजों में काटकर इसका क्षेत्रफल ज्ञात कर सकते हैं।',
    'scen_1_btn': 'आकृति को काटें',
    'h_0': 'लंबवत रेखाएं खींचने और आकार को काटने के लिए बटन पर टैप करें।',
    
    'scen_2': 'चरण 2: काटना और चिपकाना',
    'scen_2_desc': 'आइए एक एकल सूत्र प्राप्त करें। एक दूसरा समान समलंब लें, उसे पलटें, और पहले वाले से जोड़कर एक समांतर चतुर्भुज बनाएं।',
    'scen_2_btn': 'डुप्लिकेट और पलटें',
    'h_1': 'आधार (a+b) और ऊंचाई h वाला समांतर चतुर्भुज बनाने के लिए बटन पर टैप करें।',
    
    'scen_3': 'चरण 3: हल करें',
    'scen_3_desc': 'क्षेत्रफल = 1/2 × (समानांतर भुजाओं का योग) × ऊंचाई। 10 सेमी और 12 सेमी समानांतर भुजाओं और 4 सेमी ऊंचाई वाले समलंब का क्षेत्रफल ज्ञात करें।',
    'scen_3_btn': 'क्षेत्रफल सत्यापित करें',
    'h_2': 'योग = 22, आधा 11 है, 4 से गुणा करें।',
    'area_lbl': 'कुल क्षेत्रफल:',
    
    'scen_4': 'चरण 4: नदी की समस्या',
    'scen_4_desc': 'एक समलंब खेत में नदी का किनारा सड़क के किनारे के समानांतर है। नदी का किनारा सड़क के किनारे से दोगुना लंबा है। क्षेत्रफल = 10500 वर्ग मीटर, ऊंचाई = 100 मीटर। उनकी लंबाई ज्ञात करें।',
    'scen_4_btn': 'लंबाई सत्यापित करें',
    'h_3': 'क्षेत्रफल = 1/2 × (x + 2x) × 100 = 10500. x के लिए हल करें।',
    'road_lbl': 'सड़क का किनारा (x):',
    'river_lbl': 'नदी का किनारा (2x):',
    
    'err_val': 'गलत मान। पुनः प्रयास करें!',
    'err_empty': 'सत्यापित करने से पहले कृपया सभी फ़ील्ड भरें।'
  }
};

class AreaOfTrapeziumApp extends StatefulWidget {
  const AreaOfTrapeziumApp({super.key});

  @override
  State<AreaOfTrapeziumApp> createState() => _AreaOfTrapeziumAppState();
}

class _AreaOfTrapeziumAppState extends State<AreaOfTrapeziumApp> with TickerProviderStateMixin {
  String _currentLang = 'en';
  bool _isShutterOpen = true;
  bool _isSidebarOpen = true;
  int _activeStep = 0;
  bool _showVictory = false;

  final AudioPlayer _audioClick = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _audioSuccess = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _audioError = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  late AnimationController _animStep1Ctrl;
  late AnimationController _animStep2Ctrl;
  
  final TextEditingController _areaCtrl = TextEditingController();
  final TextEditingController _roadCtrl = TextEditingController();
  final TextEditingController _riverCtrl = TextEditingController();
  
  bool _hasDissected = false;
  bool _hasDuplicated = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _animStep1Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animStep1Ctrl.addListener(() => setState(() {}));
    
    _animStep2Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _animStep2Ctrl.addListener(() => setState(() {}));
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
    _animStep1Ctrl.dispose();
    _animStep2Ctrl.dispose();
    _areaCtrl.dispose();
    _roadCtrl.dispose();
    _riverCtrl.dispose();
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
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
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
  
  void _resetApp() {
    _playSound('click');
    _animStep1Ctrl.reset();
    _animStep2Ctrl.reset();
    setState(() {
      _currentLang = 'en';
      _isShutterOpen = true;
      _activeStep = 0;
      _showVictory = false;
      _hasDissected = false;
      _hasDuplicated = false;
      _areaCtrl.clear();
      _roadCtrl.clear();
      _riverCtrl.clear();
    });
  }

  void _nextStep() {
    if (_activeStep < 3) {
      _playSound('click');
      _animStep1Ctrl.reset();
      _animStep2Ctrl.reset();
      setState(() {
        _activeStep++;
        _hasDissected = false;
        _hasDuplicated = false;
        _areaCtrl.clear();
        _roadCtrl.clear();
        _riverCtrl.clear();
      });
    }
  }

  void _prevStep() {
    if (_activeStep > 0) {
      _playSound('click');
      _animStep1Ctrl.reset();
      _animStep2Ctrl.reset();
      setState(() {
        _activeStep--;
        _hasDissected = false;
        _hasDuplicated = false;
      });
    }
  }

  void _doAction() {
    _playSound('click');
    if (_activeStep == 0) {
      _hasDissected = true;
      _animStep1Ctrl.forward();
    } else if (_activeStep == 1) {
      _hasDuplicated = true;
      _animStep2Ctrl.forward();
    }
  }

  void _verifyStep() {
    _playSound('click');
    var t = I18N[_currentLang]!;
    
    if (_activeStep == 0) {
      if (!_hasDissected) {
        _playSound('error');
        _showToast(t['h_0'], isError: true);
        return;
      }
    } else if (_activeStep == 1) {
      if (!_hasDuplicated) {
        _playSound('error');
        _showToast(t['h_1'], isError: true);
        return;
      }
    } else if (_activeStep == 2) {
      if (_areaCtrl.text.trim().isEmpty) {
        _playSound('error');
        _showToast(t['err_empty'], isError: true);
        return;
      }
      if (_areaCtrl.text.trim() != '44') {
        _playSound('error');
        _showToast(t['err_val'], isError: true);
        return;
      }
    } else if (_activeStep == 3) {
      if (_roadCtrl.text.trim().isEmpty || _riverCtrl.text.trim().isEmpty) {
        _playSound('error');
        _showToast(t['err_empty'], isError: true);
        return;
      }
      if (_roadCtrl.text.trim() != '70' || _riverCtrl.text.trim() != '140') {
        _playSound('error');
        _showToast(t['err_val'], isError: true);
        return;
      }
    }
    
    _playSound('success');
    _showToast(t['success_msg']);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_activeStep < 3) {
        _nextStep();
      } else {
        setState(() => _showVictory = true);
      }
    });
  }

  Widget _buildShutter(Map<String, dynamic> t) {
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

  Widget _buildVictoryModal(Map<String, dynamic> t) {
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
              const Text("You have successfully mastered the area of a trapezium!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _resetApp,
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

  Widget _buildSidebar(Map<String, dynamic> t) {
    return Container(
      color: const Color(0xFF0f172a).withOpacity(0.95),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
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
              IconButton(icon: const Icon(Icons.refresh, color: Colors.grey, size: 18), onPressed: _resetApp),
            ],
          ),
          const Divider(color: Color(0xFF334155)),
          const SizedBox(height: 8),

          _buildSidebarSection(t['ui_objective'], t['mission_desc'], Icons.track_changes),
          const SizedBox(height: 8),
          _buildSidebarSection(t['ui_concepts'], t['guide_desc'], Icons.lightbulb_outline),
          const SizedBox(height: 8),

          _buildSidebarSectionWidget(
            t['ui_sequence'],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['scen_${_activeStep + 1}'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.cyanAccent)),
                const SizedBox(height: 8),
                Text(t['scen_${_activeStep + 1}_desc'], style: const TextStyle(fontSize: 11, color: Colors.white)),
                
                if (_activeStep == 2) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _areaCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: t['area_lbl'],
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1e293b),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                    ),
                  ),
                ],
                
                if (_activeStep == 3) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _roadCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: t['road_lbl'],
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1e293b),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _riverCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: t['river_lbl'],
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

          if (_activeStep < 2) ...[
            ElevatedButton(
              onPressed: (_activeStep == 0 && _hasDissected) || (_activeStep == 1 && _hasDuplicated) ? null : _doAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade500,
                disabledBackgroundColor: Colors.purple.shade900,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(t['scen_${_activeStep + 1}_btn'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
          ],

          ElevatedButton(
            onPressed: _verifyStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(t['scen_${_activeStep + 1}_btn'] != null ? 'VERIFY' : 'VERIFY', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _activeStep > 0 ? _prevStep : null,
                  icon: const Icon(Icons.arrow_back, size: 14),
                  label: Text(t['btn_prev']),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF334155), foregroundColor: Colors.white, disabledBackgroundColor: const Color(0xFF1e293b)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _activeStep < 3 ? _nextStep : null,
                  icon: const Icon(Icons.arrow_forward, size: 14),
                  label: Text(t['btn_next']),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF334155), foregroundColor: Colors.white, disabledBackgroundColor: const Color(0xFF1e293b)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildSidebarSection(t['hints'], t['h_$_activeStep'], Icons.lightbulb),
          const SizedBox(height: 24),
          
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
        return Container(
          color: Colors.transparent,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: CustomPaint(
            painter: TrapeziumPainter(
              activeStep: _activeStep,
              animStep1: _animStep1Ctrl.value,
              animStep2: _animStep2Ctrl.value,
            ),
          ),
        );
      }
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
            ? _buildShutter(t)
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
                    
                  if (_showVictory) _buildVictoryModal(t),
                ],
              ),
      ),
    );
  }
}

class TrapeziumPainter extends CustomPainter {
  final int activeStep;
  final double animStep1;
  final double animStep2;

  TrapeziumPainter({
    required this.activeStep,
    required this.animStep1,
    required this.animStep2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    
    final gridP = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1;
    final axisP = Paint()..color = Colors.white.withOpacity(0.2)..strokeWidth = 2;
    for (int i = -40; i <= 40; i++) {
      canvas.drawLine(Offset(center.dx + i * 20, 0), Offset(center.dx + i * 20, size.height), gridP);
      canvas.drawLine(Offset(0, center.dy + i * 20), Offset(size.width, center.dy + i * 20), gridP);
    }
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), axisP);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), axisP);

    Paint strokePaint = Paint()..color = Colors.cyanAccent..style = PaintingStyle.stroke..strokeWidth = 2;
    Paint fillMain = Paint()..color = Colors.blue.withOpacity(0.4)..style = PaintingStyle.fill;
    Paint fillTriL = Paint()..color = Colors.green.withOpacity(0.4)..style = PaintingStyle.fill;
    Paint fillTriR = Paint()..color = Colors.purple.withOpacity(0.4)..style = PaintingStyle.fill;
    Paint fillDup = Paint()..color = Colors.orange.withOpacity(0.4)..style = PaintingStyle.fill;
    
    // Trapezium dimensions
    double topW = 100;
    double botW = 200;
    double h = 80;
    
    // Vertices relative to a center point
    Offset pTL = Offset(-topW/2, -h/2);
    Offset pTR = Offset(topW/2, -h/2);
    Offset pBL = Offset(-botW/2, h/2);
    Offset pBR = Offset(botW/2, h/2);
    
    // Dissection points
    Offset pF1 = Offset(-topW/2, h/2);
    Offset pF2 = Offset(topW/2, h/2);
    
    void _drawText(String text, Offset pos, Color color) {
      final textSpan = TextSpan(text: text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold, backgroundColor: Colors.black45));
      final textPainter = TextPainter(text: textSpan, textDirection: ui.TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos.dx - textPainter.width/2, pos.dy - textPainter.height/2));
    }

    if (activeStep == 0) {
      // Step 1: Dissect
      double gap = 30 * animStep1;
      
      Path pathMid = Path()..moveTo(center.dx + pTL.dx, center.dy + pTL.dy)
        ..lineTo(center.dx + pTR.dx, center.dy + pTR.dy)
        ..lineTo(center.dx + pF2.dx, center.dy + pF2.dy)
        ..lineTo(center.dx + pF1.dx, center.dy + pF1.dy)
        ..close();
        
      Path pathL = Path()..moveTo(center.dx + pTL.dx - gap, center.dy + pTL.dy)
        ..lineTo(center.dx + pF1.dx - gap, center.dy + pF1.dy)
        ..lineTo(center.dx + pBL.dx - gap, center.dy + pBL.dy)
        ..close();
        
      Path pathR = Path()..moveTo(center.dx + pTR.dx + gap, center.dy + pTR.dy)
        ..lineTo(center.dx + pBR.dx + gap, center.dy + pBR.dy)
        ..lineTo(center.dx + pF2.dx + gap, center.dy + pF2.dy)
        ..close();
        
      canvas.drawPath(pathMid, fillMain); canvas.drawPath(pathMid, strokePaint);
      canvas.drawPath(pathL, fillTriL); canvas.drawPath(pathL, strokePaint);
      canvas.drawPath(pathR, fillTriR); canvas.drawPath(pathR, strokePaint);
      
      // Draw dotted height lines if not fully dissected
      if (animStep1 < 0.5) {
        Paint dotP = Paint()..color = Colors.white54..strokeWidth = 2;
        canvas.drawLine(Offset(center.dx + pTL.dx, center.dy + pTL.dy), Offset(center.dx + pF1.dx, center.dy + pF1.dy), dotP);
        canvas.drawLine(Offset(center.dx + pTR.dx, center.dy + pTR.dy), Offset(center.dx + pF2.dx, center.dy + pF2.dy), dotP);
      }
      
    } else if (activeStep == 1) {
      // Step 2: Duplicate & Flip
      Path pathOrig = Path()..moveTo(center.dx + pTL.dx, center.dy + pTL.dy)
        ..lineTo(center.dx + pTR.dx, center.dy + pTR.dy)
        ..lineTo(center.dx + pBR.dx, center.dy + pBR.dy)
        ..lineTo(center.dx + pBL.dx, center.dy + pBL.dy)
        ..close();
      canvas.drawPath(pathOrig, fillMain); canvas.drawPath(pathOrig, strokePaint);
      
      if (animStep2 > 0) {
        canvas.save();
        // Translate and Rotate logic
        // Original right side is pTR to pBR.
        // Flipped trapezium needs its left side (was right side) to match pTR to pBR.
        // Rotation by 180 degrees around a point.
        // Easiest is to compute final translation: Shift right by (topW + botW)/2
        double endTx = (topW + botW) / 2;
        double currentTx = endTx * animStep2;
        
        canvas.translate(center.dx + currentTx, center.dy);
        canvas.rotate(math.pi * animStep2);
        
        Path pathDup = Path()..moveTo(pTL.dx, pTL.dy)
          ..lineTo(pTR.dx, pTR.dy)
          ..lineTo(pBR.dx, pBR.dy)
          ..lineTo(pBL.dx, pBL.dy)
          ..close();
        canvas.drawPath(pathDup, fillDup); canvas.drawPath(pathDup, strokePaint);
        canvas.restore();
      }
      
      _drawText("a", Offset(center.dx, center.dy - h/2 - 15), Colors.cyanAccent);
      _drawText("b", Offset(center.dx, center.dy + h/2 + 15), Colors.cyanAccent);
      
    } else if (activeStep == 2) {
      // Step 3: Calculation (Static Trapezium)
      Path pathOrig = Path()..moveTo(center.dx + pTL.dx, center.dy + pTL.dy)
        ..lineTo(center.dx + pTR.dx, center.dy + pTR.dy)
        ..lineTo(center.dx + pBR.dx, center.dy + pBR.dy)
        ..lineTo(center.dx + pBL.dx, center.dy + pBL.dy)
        ..close();
      canvas.drawPath(pathOrig, fillMain); canvas.drawPath(pathOrig, strokePaint);
      
      Paint dotP = Paint()..color = Colors.amberAccent..strokeWidth = 2;
      canvas.drawLine(Offset(center.dx + pTL.dx, center.dy + pTL.dy), Offset(center.dx + pF1.dx, center.dy + pF1.dy), dotP);
      
      _drawText("10 cm", Offset(center.dx, center.dy - h/2 - 15), Colors.white);
      _drawText("12 cm", Offset(center.dx, center.dy + h/2 + 15), Colors.white);
      _drawText("h = 4 cm", Offset(center.dx + pTL.dx + 40, center.dy), Colors.amberAccent);
      
    } else if (activeStep == 3) {
      // Step 4: River Problem (Static Diagram)
      Path pathOrig = Path()..moveTo(center.dx + pTL.dx, center.dy + pTL.dy)
        ..lineTo(center.dx + pTR.dx, center.dy + pTR.dy)
        ..lineTo(center.dx + pBR.dx, center.dy + pBR.dy)
        ..lineTo(center.dx + pBL.dx, center.dy + pBL.dy)
        ..close();
      canvas.drawPath(pathOrig, fillMain); canvas.drawPath(pathOrig, strokePaint);
      
      // Draw river (top) and road (bottom) decorators
      Paint riverP = Paint()..color = Colors.blueAccent..strokeWidth = 6;
      Paint roadP = Paint()..color = Colors.grey..strokeWidth = 6;
      
      canvas.drawLine(Offset(center.dx + pTL.dx - 40, center.dy + pTL.dy - 10), Offset(center.dx + pTR.dx + 40, center.dy + pTR.dy - 10), riverP);
      canvas.drawLine(Offset(center.dx + pBL.dx - 20, center.dy + pBL.dy + 10), Offset(center.dx + pBR.dx + 20, center.dy + pBR.dy + 10), roadP);
      
      _drawText("River (2x)", Offset(center.dx, center.dy - h/2 - 25), Colors.cyanAccent);
      _drawText("Road (x)", Offset(center.dx, center.dy + h/2 + 25), Colors.amberAccent);
      _drawText("Area = 10500 m²", Offset(center.dx, center.dy), Colors.white);
      
      Paint dotP = Paint()..color = Colors.white54..strokeWidth = 2;
      canvas.drawLine(Offset(center.dx + pTL.dx, center.dy + pTL.dy), Offset(center.dx + pF1.dx, center.dy + pF1.dy), dotP);
      _drawText("h = 100m", Offset(center.dx + pTL.dx + 40, center.dy), Colors.white70);
    }
  }

  @override
  bool shouldRepaint(covariant TrapeziumPainter oldDelegate) {
    return oldDelegate.activeStep != activeStep || 
           oldDelegate.animStep1 != animStep1 || 
           oldDelegate.animStep2 != animStep2;
  }
}
