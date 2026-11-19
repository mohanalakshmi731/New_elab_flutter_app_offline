// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

const Map<String, Map<String, dynamic>> I18N = {
  'en': {
    'app_title': 'Parallelogram Shear Lab',
    'app_subtitle': 'CLASS 8 • AREA',
    'start_mission': 'START MISSION',
    'sidebar_title': 'Teacher Board',
    'ui_objective': 'Mission Objective',
    'mission_desc': 'Derive the Area of a parallelogram = base x height by shearing the shape and dissecting it into a rectangle.',
    'ui_concepts': 'Core Concepts',
    'guide_desc': '• A parallelogram has two pairs of parallel sides. Either pair can be chosen as the base, and its height is the perpendicular distance to the opposite side — not the slanted side length.\n\n• Drop a perpendicular from one top vertex down to the base (extending the base line if needed). This perpendicular meets the base at a foot point, splitting off a right-angled triangle.\n\n• Cut off that right triangle and slide it — without resizing — to the opposite end of the shape. Because opposite sides of a parallelogram are equal and parallel, the triangle fits exactly into the gap left behind.\n\n• The rearranged figure is now an exact rectangle with the same base and the same height as the original parallelogram — no area was added or removed, only moved.\n\n• So Area of a parallelogram = base × height. Since shearing the top edge only changes the slant side, and never the base or the perpendicular height, the area never changes when you shear.\n\n• The slant (adjacent) side is usually NOT the height — they are equal only in the special case where the parallelogram is already a rectangle. Compare a parallelogram to a rectangle sharing the same two side lengths: the parallelogram\'s area is always less than or equal to the rectangle\'s.',
    'ui_sequence': 'Current Step',
    'data_readouts': 'Data Readouts',
    'btn_verify': 'VERIFY',
    'btn_prev': 'PREV',
    'btn_next': 'NEXT',
    'btn_dissect': 'DISSECT',
    'hints': 'Hints / Evidence',
    'h_0': 'Drag BASE to 7 and HEIGHT to 4. Pull SHEAR handle. Type reasoning, press DISSECT, then VERIFY.',
    'h_1': 'Drag BASE to 5, HEIGHT to 3. Pull SHEAR handle. Press DISSECT, then VERIFY.',
    'h_2': 'Drag BASE to 5, HEIGHT to 4.8. Pull SHEAR handle. Press DISSECT, then VERIFY.',
    'h_3': 'Drag BASE to 4.4, HEIGHT to 2. Pull SHEAR handle. Press DISSECT, then VERIFY.',
    'h_4': 'Drag BASE to 5. Drag SLANT-SIDE handle until it reads exactly 4.0 cm. Press DISSECT, then VERIFY.',
    'scen_1': 'Scenario 1/5: Base 7 cm, Height 4 cm',
    'scen_1_desc': 'Drag BASE to 7 cm and HEIGHT to 4 cm. Shear the top edge at least once. Write your reasoning, press DISSECT, then VERIFY.',
    'scen_1_btn': 'VERIFY AREA = 28',
    'scen_2': 'Scenario 2/5: Base 5 cm, Height 3 cm',
    'scen_2_desc': 'Drag BASE to 5 cm and HEIGHT to 3 cm. Shear the top edge, press DISSECT, then VERIFY.',
    'scen_2_btn': 'VERIFY AREA = 15',
    'scen_3': 'Scenario 3/5: Base 5 cm, Height 4.8 cm',
    'scen_3_desc': 'Drag BASE to 5 cm and HEIGHT to 4.8 cm. Shear the top edge, press DISSECT, then VERIFY.',
    'scen_3_btn': 'VERIFY AREA = 24',
    'scen_4': 'Scenario 4/5: Base 4.4 cm, Height 2 cm',
    'scen_4_desc': 'Drag BASE to 4.4 cm and HEIGHT to 2 cm. Shear the top edge, press DISSECT, then VERIFY.',
    'scen_4_btn': 'VERIFY AREA = 8.8',
    'scen_5': 'Scenario 5/5: Parallelogram vs Rectangle',
    'scen_5_desc': 'Drag BASE to 5 cm. Drag SLANT-SIDE handle so slant side = 4 cm. Shear freely. Press DISSECT, then VERIFY.',
    'scen_5_btn': 'VERIFY COMPARISON',
    'err_target': 'Not quite. Adjust Base and Height (and Slant for step 5) to match the target.',
    'err_manipulate': 'Shear the parallelogram at least once before verifying.',
    'err_dissect': 'Press DISSECT to prove the rearrangement before verifying.',
    'err_reason': 'Please enter a short reasoning text before verifying.',
    'success_msg': 'Correct!',
    'reason_lbl': 'Reasoning',
  },
  'hi': {
    'app_title': 'समांतर चतुर्भुज अपरूपण (Shear) लैब',
    'app_subtitle': 'कक्षा 8 • क्षेत्रफल',
    'start_mission': 'मिशन प्रारंभ करें',
    'sidebar_title': 'शिक्षक बोर्ड',
    'ui_objective': 'मिशन का उद्देश्य',
    'mission_desc': 'आकृति को अपरूपित करके और उसे एक आयत में काटकर समांतर चतुर्भुज का क्षेत्रफल = आधार x ऊंचाई प्राप्त करें।',
    'ui_concepts': 'मूल अवधारणाएं',
    'guide_desc': '• समानांतर भुजाओं का कोई भी जोड़ा आधार हो सकता है। ऊँचाई लंबवत दूरी है।\n\n• एक शीर्ष से आधार तक एक लंब डालें। यह लंब आधार से मिलकर एक समकोण त्रिभुज बनाता है।\n\n• उस समकोण त्रिभुज को काटें और आयत बनाने के लिए इसे बिना आकार बदले दूसरी तरफ खिसकाएं।\n\n• पुनर्व्यवस्थित आकृति अब एक सटीक आयत है जिसका आधार और ऊँचाई मूल समांतर चतुर्भुज के समान है - कोई क्षेत्रफल जोड़ा या हटाया नहीं गया।\n\n• इसलिए समांतर चतुर्भुज का क्षेत्रफल = आधार x ऊँचाई। अपरूपण से क्षेत्रफल नहीं बदलता।\n\n• तिरछी भुजा आमतौर पर ऊँचाई नहीं होती है - वे केवल तभी बराबर होते हैं जब समांतर चतुर्भुज पहले से ही एक आयत हो।',
    'ui_sequence': 'वर्तमान चरण',
    'data_readouts': 'डेटा रीडआउट्स',
    'btn_verify': 'सत्यापित करें',
    'btn_prev': 'पिछला',
    'btn_next': 'अगला',
    'btn_dissect': 'काटें (DISSECT)',
    'hints': 'संकेत / प्रमाण',
    'h_0': 'BASE को 7 और HEIGHT को 4 पर खींचें। SHEAR खींचें। कारण टाइप करें, DISSECT दबाएं, फिर VERIFY दबाएं।',
    'h_1': 'BASE को 5, HEIGHT को 3 पर खींचें। SHEAR खींचें। DISSECT दबाएं, फिर VERIFY दबाएं।',
    'h_2': 'BASE को 5, HEIGHT को 4.8 पर खींचें। SHEAR खींचें। DISSECT दबाएं, फिर VERIFY दबाएं।',
    'h_3': 'BASE को 4.4, HEIGHT को 2 पर खींचें। SHEAR खींचें। DISSECT दबाएं, फिर VERIFY दबाएं।',
    'h_4': 'BASE को 5 पर खींचें। SLANT-SIDE को खींचें जब तक 4.0 सेमी न हो जाए। DISSECT दबाएं, फिर VERIFY दबाएं।',
    'scen_1': 'परिदृश्य 1/5: आधार 7 सेमी, ऊंचाई 4 सेमी',
    'scen_1_desc': 'BASE को 7 और HEIGHT को 4 पर खींचें। ऊपरी किनारे को कम से कम एक बार अपरूपित (Shear) करें। अपना कारण लिखें, DISSECT दबाएं, फिर VERIFY दबाएं।',
    'scen_1_btn': 'सत्यापित करें AREA = 28',
    'scen_2': 'परिदृश्य 2/5: आधार 5 सेमी, ऊंचाई 3 सेमी',
    'scen_2_desc': 'BASE को 5 और HEIGHT को 3 पर खींचें। ऊपरी किनारे को अपरूपित करें, DISSECT दबाएं, फिर VERIFY दबाएं।',
    'scen_2_btn': 'सत्यापित करें AREA = 15',
    'scen_3': 'परिदृश्य 3/5: आधार 5 सेमी, ऊंचाई 4.8 सेमी',
    'scen_3_desc': 'BASE को 5 और HEIGHT को 4.8 पर खींचें। ऊपरी किनारे को अपरूपित करें, DISSECT दबाएं, फिर VERIFY दबाएं।',
    'scen_3_btn': 'सत्यापित करें AREA = 24',
    'scen_4': 'परिदृश्य 4/5: आधार 4.4 सेमी, ऊंचाई 2 सेमी',
    'scen_4_desc': 'BASE को 4.4 और HEIGHT को 2 पर खींचें। ऊपरी किनारे को अपरूपित करें, DISSECT दबाएं, फिर VERIFY दबाएं।',
    'scen_4_btn': 'सत्यापित करें AREA = 8.8',
    'scen_5': 'परिदृश्य 5/5: समांतर चतुर्भुज vs आयत',
    'scen_5_desc': 'BASE को 5 पर खींचें। SLANT-SIDE को खींचें ताकि तिरछी भुजा = 4 सेमी हो जाए। DISSECT दबाएं, फिर VERIFY दबाएं।',
    'scen_5_btn': 'तुलना सत्यापित करें',
    'err_target': 'सही नहीं है। लक्ष्य से मेल खाने के लिए आधार और ऊंचाई को समायोजित करें।',
    'err_manipulate': 'सत्यापित करने से पहले समांतर चतुर्भुज को कम से कम एक बार अपरूपित (Shear) करें।',
    'err_dissect': 'सत्यापित करने से पहले पुनर्व्यवस्था साबित करने के लिए DISSECT दबाएं।',
    'err_reason': 'सत्यापित करने से पहले कृपया एक छोटा कारण टाइप करें।',
    'success_msg': 'सही!',
    'reason_lbl': 'कारण',
  }
};

class ParallelogramShearApp extends StatefulWidget {
  const ParallelogramShearApp({super.key});

  @override
  State<ParallelogramShearApp> createState() => _ParallelogramShearAppState();
}

class _ParallelogramShearAppState extends State<ParallelogramShearApp> with TickerProviderStateMixin {
  String _currentLang = 'en';
  bool _isShutterOpen = true;
  bool _isSidebarOpen = true;

  final AudioPlayer _audioClick = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _audioSuccess = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _audioError = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  int _activeStep = 0;
  bool _showVictory = false;

  // Geometry State
  double _base = 8;
  double _height = 5;
  double _shear = 3; // Shift of top edge rightwards
  
  // Validation Flags
  bool _hasManipulated = false;
  bool _isDissected = false;
  String _reasoning = "";
  final TextEditingController _reasoningCtrl = TextEditingController();

  // Dragging
  String _dragHandle = "";

  // Animation
  late AnimationController _cutAnimCtrl;
  late Animation<double> _cutAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _cutAnimCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _cutAnim = CurvedAnimation(parent: _cutAnimCtrl, curve: Curves.easeInOut);
    _cutAnim.addListener(() {
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
    _reasoningCtrl.dispose();
    _cutAnimCtrl.dispose();
    super.dispose();
  }

  void playSound(String type) {
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

  void _showToastMsg(String title, {bool isError = false}) {
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

  void _fullReset() {
    playSound('click');
    _cutAnimCtrl.reset();
    setState(() {
      _currentLang = 'en';
      _isShutterOpen = true;
      _activeStep = 0;
      _showVictory = false;
      _base = 8;
      _height = 5;
      _shear = 3;
      _hasManipulated = false;
      _isDissected = false;
      _reasoning = "";
      _reasoningCtrl.clear();
    });
  }

  void _resetStep() {
    playSound('click');
    _cutAnimCtrl.reverse();
    setState(() {
      _hasManipulated = false;
      _isDissected = false;
      if (_activeStep == 0) { _base = 8; _height = 5; _shear = 3; }
      else if (_activeStep == 1) { _base = 6; _height = 4; _shear = -2; }
      else if (_activeStep == 2) { _base = 6; _height = 6; _shear = 2; }
      else if (_activeStep == 3) { _base = 5; _height = 3; _shear = -3; }
      else if (_activeStep == 4) { _base = 6; _height = 4; _shear = 2; }
    });
  }

  void _doDissect() {
    if (_shear == 0) {
      _showToastMsg("Already a rectangle, no need to dissect!", isError: false);
      setState(() => _isDissected = true);
      return;
    }
    playSound('click');
    setState(() {
      _isDissected = true;
    });
    _cutAnimCtrl.forward();
  }

  double _getSlant() {
    return math.sqrt(_shear * _shear + _height * _height);
  }

  void _verifyStep() {
    playSound('click');
    final t = I18N[_currentLang]!;
    
    // Check constraints based on step
    bool isTargetMet = false;
    if (_activeStep == 0) {
      isTargetMet = (_base == 7 && _height == 4);
    } else if (_activeStep == 1) {
      isTargetMet = (_base == 5 && _height == 3);
    } else if (_activeStep == 2) {
      isTargetMet = (_base == 5 && _height == 4.8);
    } else if (_activeStep == 3) {
      isTargetMet = (_base == 4.4 && _height == 2);
    } else if (_activeStep == 4) {
      isTargetMet = (_base == 5 && _getSlant().toStringAsFixed(1) == "4.0");
    }

    if (!isTargetMet) {
      playSound('error');
      _showToastMsg(t['err_target'], isError: true);
      return;
    }

    if (!_hasManipulated) {
      playSound('error');
      _showToastMsg(t['err_manipulate'], isError: true);
      return;
    }

    if (!_isDissected) {
      playSound('error');
      _showToastMsg(t['err_dissect'], isError: true);
      return;
    }

    if (_activeStep == 0 && _reasoning.trim().isEmpty) {
      playSound('error');
      _showToastMsg(t['err_reason'], isError: true);
      return;
    }

    // Success!
    playSound('success');
    _showToastMsg(t['success_msg']);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_activeStep < 4) {
        _nextStep();
      } else {
        setState(() => _showVictory = true);
      }
    });
  }

  void _nextStep() {
    if (_activeStep < 4) {
      playSound('click');
      _cutAnimCtrl.reset();
      setState(() {
        _activeStep++;
        _hasManipulated = false;
        _isDissected = false;
        _reasoning = "";
        _reasoningCtrl.clear();
        _resetStep(); // to set default coords for the new step
      });
    }
  }

  void _prevStep() {
    if (_activeStep > 0) {
      playSound('click');
      _cutAnimCtrl.reset();
      setState(() {
        _activeStep--;
        _hasManipulated = false;
        _isDissected = false;
        _reasoning = "";
        _reasoningCtrl.clear();
        _resetStep();
      });
    }
  }

  // Handle Dragging
  void _onPanStart(DragStartDetails details, Size size) {
    if (_cutAnimCtrl.isAnimating || _isDissected) return; // Lock if dissected
    playSound('click');
    
    double cx = size.width / 2;
    double cy = size.height / 2;
    double unit = 20.0;
    
    Offset localPos = details.localPosition;
    Offset worldTouch = Offset((localPos.dx - cx) / unit, -(localPos.dy - cy) / unit);
    
    double threshold = 2.0;
    
    Offset pBase = Offset(_base/2 - _shear/2, -_height/2);
    Offset pHeight = Offset(-_base/2 + _shear/2, _height/2);
    Offset pShear = Offset(_base/2 + _shear/2, _height/2);
    Offset pSlant = pShear; // Slant and shear share the top-right corner
    
    if ((worldTouch - pBase).distance < threshold) { _dragHandle = "BASE"; return; }
    if ((worldTouch - pHeight).distance < threshold) { _dragHandle = "HEIGHT"; return; }
    if ((worldTouch - pShear).distance < threshold) { _dragHandle = "SHEAR"; return; }
    
    _dragHandle = "";
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (_dragHandle.isEmpty || _isDissected) return;
    
    double cx = size.width / 2;
    double cy = size.height / 2;
    double unit = 20.0;
    
    Offset localPos = details.localPosition;
    Offset worldTouch = Offset((localPos.dx - cx) / unit, -(localPos.dy - cy) / unit);
    
    setState(() {
      _hasManipulated = true;
      if (_dragHandle == "BASE") {
        // Base handle controls width (distance between bottom left and right)
        // BL is at -b/2 - s/2, BR is at b/2 - s/2
        // We calculate b from worldTouch X
        double newBase = (worldTouch.dx + (_shear/2)) * 2;
        _base = newBase.clamp(2.0, 16.0);
        // snap nicely
        _base = ((_base * 10).round() / 10.0);
      } else if (_dragHandle == "HEIGHT") {
        // Height handle controls vertical height
        _height = (worldTouch.dy * 2).clamp(2.0, 14.0);
        _height = ((_height * 10).round() / 10.0);
      } else if (_dragHandle == "SHEAR") {
        // Shear handle controls horizontal shift of top edge
        // TR is at b/2 + s/2
        double newShear = (worldTouch.dx - (_base/2)) * 2;
        _shear = newShear.clamp(-12.0, 12.0);
        _shear = ((_shear * 10).round() / 10.0);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _dragHandle = "";
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
                playSound('click');
                _resetStep();
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
              const Text("You proved Area = base × height by shearing, dissecting, and comparing across five scenarios.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _fullReset,
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

  Widget _buildReadouts() {
    double area = _base * _height;
    double rectArea = area; // For Step 5
    
    return Column(
      children: [
        _buildRow("Base (b)", "${_base.toStringAsFixed(1)} cm"),
        _buildRow("Height (h)", "${_height.toStringAsFixed(1)} cm"),
        _buildRow("Slant Side", "${_getSlant().toStringAsFixed(1)} cm", color: Colors.pinkAccent),
        const Divider(color: Color(0xFF334155)),
        _buildRow("Parallelogram Area", "${area.toStringAsFixed(1)} sq cm", isTotal: true),
        if (_activeStep == 4)
          _buildRow("Rectangle Area", "${rectArea.toStringAsFixed(1)} sq cm", color: Colors.orangeAccent),
      ],
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

  Widget _buildSidebarSection(String title, String content, IconData icon, {String? titleSuffix}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1e293b), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.cyan, size: 12),
                  const SizedBox(width: 6),
                  Text(title.toUpperCase(), style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.0)),
                ],
              ),
              if (titleSuffix != null)
                Text(titleSuffix, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
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
                  playSound('click');
                  setState(() => _currentLang = _currentLang == 'en' ? 'hi' : 'en');
                },
                icon: const Icon(Icons.language, color: Colors.grey, size: 16),
                label: Text(_currentLang.toUpperCase(), style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              IconButton(icon: const Icon(Icons.refresh, color: Colors.grey, size: 18), onPressed: _fullReset),
            ],
          ),
          const Divider(color: Color(0xFF334155)),
          const SizedBox(height: 8),

          _buildSidebarSection(t['ui_objective'], t['mission_desc'], Icons.track_changes),
          const SizedBox(height: 8),

          _buildSidebarSection(t['ui_concepts'], t['guide_desc'], Icons.lightbulb_outline),
          const SizedBox(height: 8),
          
          _buildSidebarSection(
            t['ui_sequence'], 
            t['scen_${_activeStep+1}_desc'], 
            Icons.list_alt,
            titleSuffix: t['scen_${_activeStep+1}'].split(':').first
          ),
          const SizedBox(height: 8),
          
          _buildSidebarSectionWidget(
            t['data_readouts'],
            _buildReadouts(),
            Icons.bar_chart
          ),
          const SizedBox(height: 12),
          
          // Action Area
          if (_activeStep == 0) ...[
            TextField(
              controller: _reasoningCtrl,
              onChanged: (v) => _reasoning = v,
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
            const SizedBox(height: 12),
          ],
          
          ElevatedButton(
            onPressed: _isDissected ? null : _doDissect,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade500,
              disabledBackgroundColor: Colors.purple.shade900,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(t['btn_dissect'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
            child: Text(t['scen_${_activeStep+1}_btn'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                  onPressed: _activeStep < 4 ? _nextStep : null,
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
          
          // Footer
          const Center(
            child: Text('© ZeroScienceLab - Fall in love with Math & Science', style: TextStyle(color: Colors.grey, fontSize: 8, letterSpacing: 1, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = I18N[_currentLang]!;
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
                        // Background Grid
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/offline_texture.png'),
                              repeat: ImageRepeat.repeat,
                            ),
                          ),
                        ),
                        
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              onPanStart: (d) => _onPanStart(d, Size(constraints.maxWidth, constraints.maxHeight)),
                              onPanUpdate: (d) => _onPanUpdate(d, Size(constraints.maxWidth, constraints.maxHeight)),
                              onPanEnd: _onPanEnd,
                              child: Container(
                                color: Colors.transparent, 
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                                child: CustomPaint(
                                  painter: _ParallelogramPainter(
                                    base: _base, height: _height, shear: _shear,
                                    cutProgress: _cutAnim.value,
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
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
                          playSound('click');
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

class _ParallelogramPainter extends CustomPainter {
  final double base, height, shear;
  final double cutProgress; // 0.0 to 1.0

  _ParallelogramPainter({
    required this.base, required this.height, required this.shear,
    required this.cutProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double unit = 20.0;
    double cx = size.width / 2;
    double cy = size.height / 2;
    
    Offset toCanvas(Offset p) {
      return Offset(cx + p.dx * unit, cy - p.dy * unit);
    }

    void drawText(String text, Offset p, {Color color = Colors.white}) {
      final textSpan = TextSpan(text: text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold, backgroundColor: Colors.black45));
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(toCanvas(p).dx - textPainter.width / 2, toCanvas(p).dy - textPainter.height / 2 - 12));
    }

    // Grid and Axes
    final gridP = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1;
    final axisP = Paint()..color = Colors.white.withOpacity(0.2)..strokeWidth = 2;
    for (int i = -40; i <= 40; i++) {
      canvas.drawLine(toCanvas(Offset(i.toDouble(), -40)), toCanvas(Offset(i.toDouble(), 40)), gridP);
      canvas.drawLine(toCanvas(Offset(-40, i.toDouble())), toCanvas(Offset(40, i.toDouble())), gridP);
    }
    canvas.drawLine(toCanvas(const Offset(-40, 0)), toCanvas(const Offset(40, 0)), axisP);
    canvas.drawLine(toCanvas(const Offset(0, -40)), toCanvas(const Offset(0, 40)), axisP);

    final strokeP = Paint()..color = Colors.cyanAccent..style = PaintingStyle.stroke..strokeWidth = 2;
    final dashP = Paint()..color = Colors.white54..style = PaintingStyle.stroke..strokeWidth = 1.5;
    
    void drawHandle(Offset p, Color color) {
      canvas.drawCircle(toCanvas(p), 10, Paint()..color = color.withOpacity(0.5));
      canvas.drawCircle(toCanvas(p), 6, Paint()..color = color);
      canvas.drawCircle(toCanvas(p), 3, Paint()..color = Colors.white);
    }

    // Points
    Offset pBL = Offset(-base/2 - shear/2, -height/2);
    Offset pBR = Offset(base/2 - shear/2, -height/2);
    Offset pTR = Offset(base/2 + shear/2, height/2);
    Offset pTL = Offset(-base/2 + shear/2, height/2);

    // Dissection logic
    // If shear > 0, the cut triangle is on the left.
    // If shear < 0, the cut triangle is on the right.
    // Let's form the main polygon and the cut triangle based on shear direction.
    
    Path mainPoly = Path();
    Path cutTri = Path();
    Offset cutOffset = Offset(0, 0);

    if (shear == 0) {
      // It's a rectangle already
      mainPoly.moveTo(toCanvas(pBL).dx, toCanvas(pBL).dy);
      mainPoly.lineTo(toCanvas(pBR).dx, toCanvas(pBR).dy);
      mainPoly.lineTo(toCanvas(pTR).dx, toCanvas(pTR).dy);
      mainPoly.lineTo(toCanvas(pTL).dx, toCanvas(pTL).dy);
      mainPoly.close();
    } else if (shear > 0) {
      // Cut triangle is on the left
      // Vertices of cut triangle: pTL, pBL, and (pTL.x, pBL.y)
      Offset pFoot = Offset(pTL.dx, pBL.dy);
      
      // Main Poly: pFoot -> pBR -> pTR -> pTL
      mainPoly.moveTo(toCanvas(pFoot).dx, toCanvas(pFoot).dy);
      mainPoly.lineTo(toCanvas(pBR).dx, toCanvas(pBR).dy);
      mainPoly.lineTo(toCanvas(pTR).dx, toCanvas(pTR).dy);
      mainPoly.lineTo(toCanvas(pTL).dx, toCanvas(pTL).dy);
      mainPoly.close();

      // Cut Tri: pTL -> pBL -> pFoot
      cutTri.moveTo(toCanvas(pTL).dx, toCanvas(pTL).dy);
      cutTri.lineTo(toCanvas(pBL).dx, toCanvas(pBL).dy);
      cutTri.lineTo(toCanvas(pFoot).dx, toCanvas(pFoot).dy);
      cutTri.close();

      // Animate Cut Tri to the right by `base`
      cutOffset = Offset(base * unit * cutProgress, 0);
    } else {
      // shear < 0
      // Cut triangle is on the right
      Offset pFoot = Offset(pTR.dx, pBR.dy);
      
      // Main Poly: pBL -> pFoot -> pTR -> pTL
      mainPoly.moveTo(toCanvas(pBL).dx, toCanvas(pBL).dy);
      mainPoly.lineTo(toCanvas(pFoot).dx, toCanvas(pFoot).dy);
      mainPoly.lineTo(toCanvas(pTR).dx, toCanvas(pTR).dy);
      mainPoly.lineTo(toCanvas(pTL).dx, toCanvas(pTL).dy);
      mainPoly.close();

      // Cut Tri: pTR -> pFoot -> pBR
      cutTri.moveTo(toCanvas(pTR).dx, toCanvas(pTR).dy);
      cutTri.lineTo(toCanvas(pFoot).dx, toCanvas(pFoot).dy);
      cutTri.lineTo(toCanvas(pBR).dx, toCanvas(pBR).dy);
      cutTri.close();

      // Animate Cut Tri to the left by `base`
      cutOffset = Offset(-base * unit * cutProgress, 0);
    }

    // Draw Main Poly
    canvas.drawPath(mainPoly, Paint()..color = Colors.cyan.withOpacity(0.3)..style = PaintingStyle.fill);
    canvas.drawPath(mainPoly, strokeP);

    // Draw Cut Tri (with offset)
    if (shear != 0) {
      canvas.save();
      canvas.translate(cutOffset.dx, cutOffset.dy);
      canvas.drawPath(cutTri, Paint()..color = Colors.purpleAccent.withOpacity(0.4)..style = PaintingStyle.fill);
      canvas.drawPath(cutTri, Paint()..color = Colors.purpleAccent..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.restore();
      
      // Draw dashed cut line on the main figure if not animating
      if (cutProgress == 0) {
        if (shear > 0) {
          canvas.drawLine(toCanvas(pTL), toCanvas(Offset(pTL.dx, pBL.dy)), dashP);
        } else {
          canvas.drawLine(toCanvas(pTR), toCanvas(Offset(pTR.dx, pBR.dy)), dashP);
        }
      }
    }

    // Draw Handles & Labels (Only when not fully dissected)
    if (cutProgress < 1.0) {
      // Base handle (Bottom right)
      drawHandle(pBR, Colors.cyanAccent);
      drawText("BASE = ${base.toStringAsFixed(1)}", Offset(pBL.dx + base/2, pBL.dy - 0.7), color: Colors.cyanAccent);

      // Height handle (Top left)
      drawHandle(pTL, Colors.purpleAccent);
      // Draw a vertical dashed height line on the left side
      canvas.drawLine(toCanvas(pTL), toCanvas(Offset(pTL.dx, pBL.dy)), dashP);
      drawText("h = ${height.toStringAsFixed(1)}", Offset(pTL.dx - 1.5, 0), color: Colors.purpleAccent);

      // Shear handle (Top right)
      drawHandle(pTR, Colors.orangeAccent);
      drawText("SHEAR", Offset(pTR.dx, pTR.dy + 1.2), color: Colors.orangeAccent);

      // Slant side label
      double slant = math.sqrt(shear * shear + height * height);
      drawText("SLANT = ${slant.toStringAsFixed(1)}", Offset(pTR.dx - shear/2 + 1, 0), color: Colors.pinkAccent);
    }
  }

  @override
  bool shouldRepaint(covariant _ParallelogramPainter oldDelegate) => true;
}
