// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

const Map<String, Map<String, dynamic>> I18N = {
  'en': {
    'app_title': 'Triangle Area Lab',
    'app_subtitle': 'Class 8 • Area',
    'start_mission': 'Start Mission',
    'nav_submit': 'Submit',
    'sidebar_title': 'Teacher Board',
    'ui_scenario': 'Scenario',
    'ui_objective': 'Mission Objective',
    'ui_sequence': 'Instruction Sequence',
    'ui_learnt': 'Learnt Conclusion',
    'scen_1': 'S1 · Right triangle completes rectangle',
    'scen_2': 'S2 · Move apex — area unchanged',
    'scen_3': 'S3 · Obtuse triangle · b=7, h=4 → 14',
    'mission_desc': 'Show that any triangle is exactly half of its enclosing rectangle, so Area = ½ × base × height for right, shear-moved and obtuse triangles.',
    'learnt_desc': 'Area of a triangle = ½ × base × height — true for right, acute and obtuse triangles. For b=7, h=4 the area is ½ × 7 × 4 = 14 sq units.',
    'hint_0': 'A right triangle sits in one corner of the rectangle. Put the apex directly above a base end (apex x = 0 or 6). The dashed rectangle is base × height = 6 × 4 = 24. The flipped copy fills the other half. Two equal triangles → each is ½ × 6 × 4 = 12.',
    'hint_1': 'Keep the height at 4 and move the apex to a slanted, in-between spot (apex x between 0 and 6). Base and height are unchanged, so ½ × b × h is unchanged. Sliding the top of a triangle sideways (a shear) never changes its area.',
    'hint_2': 'Slide the apex beyond the base (apex x < 0 or > 7). The triangle leans out — it is obtuse. Still, base = 7 and height = 4. Flip the duplicate to see the enclosing rectangle. Area = ½ × 7 × 4 = 14 sq units, whatever the lean.',
    'apex_x': 'Apex horizontal position',
    'height_lbl': 'Height (perpendicular to base)',
    'area_ledger': 'Area Ledger',
    'dup_note': 'Use Flip Duplicate to rotate a copy of the triangle and complete the rectangle: two equal halves.',
    'flip_dup': 'Flip Duplicate',
    'step_s1_1': 'Set height to 4 and slide the apex above a base end (right angle).',
    'step_s1_2': 'Flip the duplicate to complete the rectangle.',
    'step_s1_3': 'Check area = ½ × base × height, then Submit.',
    'step_s2_1': 'Keep height = 4.',
    'step_s2_2': 'Slide the apex to an in-between position (not above a base end).',
    'step_s2_3': 'Confirm the area is still 12, then Submit.',
    'step_s3_1': 'Set height = 4 (base is fixed at 7).',
    'step_s3_2': 'Slide the apex past a base end (obtuse).',
    'step_s3_3': 'Flip the duplicate, then Submit to confirm 14 sq units.',
    'flash_scen': 'Scenario complete! Proceed to the next one.',
    'flash_scen_err': 'Not quite done. Follow the steps!',
    'flash_all': 'Mission Complete!',
    'v_h_err': 'Set the height to 4 first.',
    'v_ax_err': 'Place the apex correctly according to the scenario.',
    'v_dup_err': 'Flip the duplicate to complete the rectangle first.',
  },
  'hi': {
    'app_title': 'त्रिभुज क्षेत्रफल प्रयोगशाला',
    'app_subtitle': 'कक्षा 8 • क्षेत्रफल',
    'start_mission': 'मिशन शुरू करें',
    'nav_submit': 'सबमिट',
    'sidebar_title': 'शिक्षक बोर्ड',
    'ui_scenario': 'परिदृश्य',
    'ui_objective': 'मिशन का उद्देश्य',
    'ui_sequence': 'निर्देश क्रम',
    'ui_learnt': 'सीखा गया निष्कर्ष',
    'scen_1': 'S1 · समकोण त्रिभुज आयत को पूरा करता है',
    'scen_2': 'S2 · शीर्ष को ले जाएं - क्षेत्रफल अपरिवर्तित',
    'scen_3': 'S3 · अधिककोण त्रिभुज · b=7, h=4 → 14',
    'mission_desc': 'दिखाएं कि कोई भी त्रिभुज अपने संलग्न आयत का ठीक आधा है, इसलिए समकोण, स्थानांतरित और अधिककोण त्रिभुजों के लिए क्षेत्रफल = ½ × आधार × ऊंचाई।',
    'learnt_desc': 'त्रिभुज का क्षेत्रफल = ½ × आधार × ऊंचाई - समकोण, न्यूनकोण और अधिककोण त्रिभुजों के लिए सत्य है। b=7, h=4 के लिए क्षेत्रफल ½ × 7 × 4 = 14 वर्ग इकाई है।',
    'hint_0': 'एक समकोण त्रिभुज आयत के एक कोने में बैठता है। शीर्ष को सीधे आधार के अंत (शीर्ष x = 0 या 6) के ऊपर रखें। धराशायी आयत आधार × ऊंचाई = 6 × 4 = 24 है। फ़्लिप की गई प्रतिलिपि दूसरे आधे भाग को भरती है। दो समान त्रिभुज → प्रत्येक ½ × 6 × 4 = 12 है।',
    'hint_1': 'ऊंचाई को 4 पर रखें और शीर्ष को तिरछे, बीच वाले स्थान (शीर्ष x 0 और 6 के बीच) पर ले जाएं। आधार और ऊंचाई अपरिवर्तित हैं, इसलिए ½ × b × h अपरिवर्तित है। त्रिभुज के शीर्ष को बग़ल में खिसकाने (एक कतरनी) से उसका क्षेत्रफल कभी नहीं बदलता है।',
    'hint_2': 'शीर्ष को आधार (शीर्ष x < 0 या > 7) से आगे खिसकाएं। त्रिभुज बाहर की ओर झुकता है - यह अधिककोण है। फिर भी, आधार = 7 और ऊंचाई = 4. संलग्न आयत देखने के लिए डुप्लिकेट को फ़्लिप करें। क्षेत्रफल = ½ × 7 × 4 = 14 वर्ग इकाई, चाहे कोई भी झुकाव हो।',
    'apex_x': 'शीर्ष क्षैतिज स्थिति',
    'height_lbl': 'ऊंचाई (आधार के लंबवत)',
    'area_ledger': 'क्षेत्रफल खाता',
    'dup_note': 'आयत को पूरा करने के लिए त्रिभुज की प्रतिलिपि को घुमाने के लिए फ्लिप डुप्लिकेट का उपयोग करें: दो समान भाग।',
    'flip_dup': 'डुप्लिकेट फ़्लिप करें',
    'step_s1_1': 'ऊंचाई को 4 पर सेट करें और शीर्ष को आधार के अंत (समकोण) के ऊपर स्लाइड करें।',
    'step_s1_2': 'आयत को पूरा करने के लिए डुप्लिकेट को फ़्लिप करें।',
    'step_s1_3': 'क्षेत्रफल = ½ × आधार × ऊंचाई जांचें, फिर सबमिट करें।',
    'step_s2_1': 'ऊंचाई = 4 रखें।',
    'step_s2_2': 'शीर्ष को बीच की स्थिति में स्लाइड करें (आधार के अंत के ऊपर नहीं)।',
    'step_s2_3': 'पुष्टि करें कि क्षेत्रफल अभी भी 12 है, फिर सबमिट करें।',
    'step_s3_1': 'ऊंचाई = 4 सेट करें (आधार 7 पर तय है)।',
    'step_s3_2': 'शीर्ष को आधार के अंत (अधिककोण) के पार स्लाइड करें।',
    'step_s3_3': 'डुप्लिकेट को फ़्लिप करें, फिर 14 वर्ग इकाई की पुष्टि करने के लिए सबमिट करें।',
    'flash_scen': 'परिदृश्य पूरा हुआ! अगले पर जाएं।',
    'flash_scen_err': 'अभी पूरा नहीं हुआ। चरणों का पालन करें!',
    'flash_all': 'मिशन पूरा हुआ!',
    'v_h_err': 'पहले ऊंचाई को 4 पर सेट करें।',
    'v_ax_err': 'परिदृश्य के अनुसार शीर्ष को सही ढंग से रखें।',
    'v_dup_err': 'पहले आयत को पूरा करने के लिए डुप्लिकेट को फ़्लिप करें।',
  },
};

class TriangleAreaApp extends StatefulWidget {
  const TriangleAreaApp({super.key});

  @override
  State<TriangleAreaApp> createState() => _TriangleAreaAppState();
}

class _TriangleAreaAppState extends State<TriangleAreaApp>
    with TickerProviderStateMixin {
  String _currentLang = 'en';
  bool _isShutterOpen = true;
  bool _isSidebarOpen = true;

  // Audio Players using Mixkit URLs
  final AudioPlayer _audioClick = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _audioSuccess = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _audioError = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // App State variables
  int _activeScenario = 0;
  List<double> _apexX = [0, 0, -2];
  List<double> _h = [4, 4, 4];
  List<bool> _dupFlipped = [false, false, false];
  List<bool> _submitted = [false, false, false];
  bool _showVictory = false;
  
  final TransformationController _transformationController =
      TransformationController();
      
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
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
    _transformationController.dispose();
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
        backgroundColor: isError ? Colors.redAccent : Colors.orange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _fullReset() {
    playSound('click');
    setState(() {
      _currentLang = 'en';
      _isShutterOpen = true;
      _activeScenario = 0;
      _apexX = [0, 0, -2];
      _h = [4, 4, 4];
      _dupFlipped = [false, false, false];
      _submitted = [false, false, false];
      _showVictory = false;
    });
    _showToastMsg("Activity reset.");
  }
  
  int _getBase() {
    return _activeScenario == 2 ? 7 : 6;
  }
  
  double _getMinX() {
    if (_activeScenario == 0) return 0;
    if (_activeScenario == 1) return -2;
    return -4;
  }
  
  double _getMaxX() {
    if (_activeScenario == 0) return 6;
    if (_activeScenario == 1) return 8;
    return 11;
  }
  
  void _submitScenario() {
    playSound('click');
    final t = I18N[_currentLang]!;
    
    double ax = _apexX[_activeScenario];
    double h = _h[_activeScenario];
    int baseLength = _getBase();
    
    if (h != 4) {
      _showToastMsg(t['v_h_err'], isError: true);
      playSound('error');
      return;
    }
    
    if (!_dupFlipped[_activeScenario]) {
      _showToastMsg(t['v_dup_err'], isError: true);
      playSound('error');
      return;
    }
    
    bool validApex = false;
    if (_activeScenario == 0) {
      validApex = (ax == 0 || ax == baseLength);
    } else if (_activeScenario == 1) {
      validApex = (ax > 0 && ax < baseLength);
    } else if (_activeScenario == 2) {
      validApex = (ax < 0 || ax > baseLength);
    }
    
    if (!validApex) {
      _showToastMsg(t['v_ax_err'], isError: true);
      playSound('error');
      return;
    }
    
    setState(() {
      _submitted[_activeScenario] = true;
    });
    playSound('success');
    
    if (_activeScenario < 2) {
      _showToastMsg(t['flash_scen']);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _activeScenario++;
          });
        }
      });
    } else {
      _showToastMsg(t['flash_all']);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _showVictory = true;
          });
        }
      });
    }
  }

  Offset? _activeDragPos;
  void _handlePanStart(DragStartDetails details, BoxConstraints constraints) {
    playSound('click');
    final tileSize = constraints.maxHeight / 10;
    _activeDragPos = Offset(_apexX[_activeScenario] * tileSize, _h[_activeScenario] * tileSize);
  }

  void _handlePanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_activeDragPos == null) return;

    double scale = _transformationController.value.entry(0, 0);
    Offset sceneDelta = details.delta / scale;

    _activeDragPos = Offset(
      _activeDragPos!.dx + sceneDelta.dx,
      _activeDragPos!.dy - sceneDelta.dy,
    );

    final tileSize = constraints.maxHeight / 10;
    double rawX = _activeDragPos!.dx / tileSize;
    double rawY = _activeDragPos!.dy / tileSize;

    double snappedX = rawX.roundToDouble().clamp(_getMinX(), _getMaxX());
    double snappedY = rawY.roundToDouble().clamp(1, 8);

    setState(() {
      _apexX[_activeScenario] = snappedX;
      _h[_activeScenario] = snappedY;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    _activeDragPos = null;
  }

  Widget _buildShutter(Map<String, dynamic> t) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: const Color(0xFF0f172a),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 20)
                ],
              ),
              child: const Icon(Icons.change_history, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              t['app_title'],
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              t['app_subtitle'],
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                playSound('click');
                setState(() {
                  _isShutterOpen = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(
                t['start_mission'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVictoryModal(Map<String, dynamic> t) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF020617),
            borderRadius: BorderRadius.circular(16),
            border: const Border(top: BorderSide(color: Colors.orange, width: 4)),
            boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.2), blurRadius: 20)]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.orange, size: 60),
              const SizedBox(height: 16),
              const Text("MISSION COMPLETE!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("All triangle area concepts learned.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _fullReset,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Restart Mission'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              )
            ],
          ),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: const Icon(Icons.change_history, color: Colors.orange, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['app_title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(t['app_subtitle'], style: const TextStyle(color: Colors.grey, fontSize: 9, letterSpacing: 0.5)),
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
                  playSound('click');
                  setState(() {
                    _currentLang = _currentLang == 'en' ? 'hi' : 'en';
                  });
                },
                icon: const Icon(Icons.language, color: Colors.grey, size: 16),
                label: Text(_currentLang.toUpperCase(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.grey, size: 18),
                onPressed: _fullReset,
                tooltip: "Reset Activity",
              ),
            ],
          ),
          const Divider(color: Color(0xFF334155)),
          const SizedBox(height: 8),

          _buildSidebarSection(
            t['ui_scenario'],
            DropdownButtonFormField<int>(
              value: _activeScenario,
              dropdownColor: const Color(0xFF1e293b),
              isDense: true,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF020617),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              items: [
                DropdownMenuItem(value: 0, child: Text(t['scen_1'], style: const TextStyle(color: Colors.white, fontSize: 11))),
                DropdownMenuItem(value: 1, child: Text(t['scen_2'], style: const TextStyle(color: Colors.white, fontSize: 11))),
                DropdownMenuItem(value: 2, child: Text(t['scen_3'], style: const TextStyle(color: Colors.white, fontSize: 11))),
              ],
              onChanged: (val) {
                if (val != null) {
                  playSound('click');
                  setState(() { _activeScenario = val; });
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildSidebarSection(
            t['ui_objective'],
            Text(t['mission_desc'], style: const TextStyle(color: Colors.white, height: 1.4, fontSize: 11)),
          ),
          const SizedBox(height: 12),
          _buildSidebarSection(
            t['ui_sequence'],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepItem(t['step_s${_activeScenario + 1}_1'], true),
                _buildStepItem(t['step_s${_activeScenario + 1}_2'], _h[_activeScenario] == 4),
                _buildStepItem(t['step_s${_activeScenario + 1}_3'], _dupFlipped[_activeScenario]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSidebarSection(
            "Hints / Evidence",
            Text(t['hint_$_activeScenario'], style: const TextStyle(color: Colors.white, height: 1.4, fontSize: 11)),
          ),
          const SizedBox(height: 12),
          _buildSidebarSection(
            t['ui_learnt'],
            Text(
              _submitted[0] && _submitted[1] && _submitted[2] ? t['learnt_desc'] : "Complete all scenarios to unlock the conclusion.", 
              style: TextStyle(color: _submitted[0] && _submitted[1] && _submitted[2] ? Colors.white : Colors.grey, height: 1.4, fontSize: 11)
            ),
          ),
          const SizedBox(height: 24),
          // Footer Credits
          const Center(
            child: Text(
              '© ZeroScienceLab - Fall in love with Math & Science',
              style: TextStyle(color: Colors.grey, fontSize: 8, letterSpacing: 1, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
  
  Widget _buildStepItem(String text, bool active) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(active ? Icons.check_circle : Icons.circle_outlined, color: active ? Colors.green : Colors.grey, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.grey, height: 1.4, fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildSidebarSection(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = I18N[_currentLang]!;
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth > 800 ? 380 : screenWidth * 0.45;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF020617),
        body: _isShutterOpen
            ? _buildShutter(t)
            : Stack(
                children: [
                  // Main Canvas Area (Beside Sidebar)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: _isSidebarOpen ? sidebarWidth : 0,
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: Row(
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                children: [
                                  InteractiveViewer(
                                    transformationController: _transformationController,
                                    boundaryMargin: const EdgeInsets.all(100),
                                    minScale: 0.5,
                                    maxScale: 3.0,
                                    child: CustomPaint(
                                      size: Size(constraints.maxWidth, constraints.maxHeight),
                                      painter: _TrianglePainter(
                                        ax: _apexX[_activeScenario],
                                        h: _h[_activeScenario],
                                        b: _getBase().toDouble(),
                                        isFlipped: _dupFlipped[_activeScenario],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: (_apexX[_activeScenario] + 4) * (constraints.maxHeight / 10) - 40,
                                    top: constraints.maxHeight - (_h[_activeScenario] + 1) * (constraints.maxHeight / 10) - 40,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onPanStart: (d) => _handlePanStart(d, constraints),
                                      onPanUpdate: (d) => _handlePanUpdate(d, constraints),
                                      onPanEnd: _handlePanEnd,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 24,
                                    left: 24,
                                    right: 24,
                                    child: Center(
                                      child: ElevatedButton.icon(
                                        onPressed: _submitScenario,
                                        icon: const Icon(Icons.check_circle),
                                        label: Text(t['nav_submit']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        
                        // Right Control Panel
                        Container(
                          width: 300,
                          decoration: const BoxDecoration(
                            border: Border(left: BorderSide(color: Color(0xFF334155))),
                            color: Color(0xFF0f172a),
                          ),
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              Text(t['scen_${_activeScenario+1}'].split('·').last.trim(), style: const TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              
                              Text(t['apex_x'], style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                              Slider(
                                value: _apexX[_activeScenario],
                                min: _getMinX(),
                                max: _getMaxX(),
                                divisions: (_getMaxX() - _getMinX()).toInt(),
                                activeColor: Colors.orange,
                                onChanged: (val) {
                                  setState(() { _apexX[_activeScenario] = val; });
                                }
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                color: const Color(0xFF1e293b),
                                child: Text("apex x = ${_apexX[_activeScenario].toInt()}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 24),
                              
                              Text(t['height_lbl'], style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                              Slider(
                                value: _h[_activeScenario],
                                min: 1,
                                max: 8,
                                divisions: 7,
                                activeColor: Colors.orange,
                                onChanged: (val) {
                                  setState(() { _h[_activeScenario] = val; });
                                }
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                color: const Color(0xFF1e293b),
                                child: Text("h = ${_h[_activeScenario].toInt()} units", textAlign: TextAlign.center, style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 32),
                              
                              ElevatedButton.icon(
                                onPressed: () {
                                  playSound('click');
                                  setState(() {
                                    _dupFlipped[_activeScenario] = !_dupFlipped[_activeScenario];
                                  });
                                },
                                icon: const Icon(Icons.flip),
                                label: Text(t['flip_dup']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.orange,
                                  side: const BorderSide(color: Colors.orange, width: 2),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1e293b),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF334155)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t['area_ledger'], style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 12),
                                    Text("Enclosing rectangle = ${_getBase()} × ${_h[_activeScenario].toInt()} = ${_getBase() * _h[_activeScenario].toInt()}", style: const TextStyle(color: Colors.white, height: 1.5)),
                                    const SizedBox(height: 8),
                                    Text("Triangle is exactly half: ½ × ${_getBase()} × ${_h[_activeScenario].toInt()} = ${0.5 * _getBase() * _h[_activeScenario]}", style: const TextStyle(color: Colors.greenAccent, height: 1.5, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  // Animated Sidebar
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: _isSidebarOpen ? 0 : -sidebarWidth,
                    top: 0,
                    bottom: 0,
                    width: sidebarWidth,
                    child: _buildSidebar(t),
                  ),

                  // Fixed Toggle Menu Icon (Top-Left of Sidebar space)
                  if (!_isShutterOpen)
                    Positioned(
                      left: 16,
                      top: 16,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: const Color(0xFF1e293b).withOpacity(0.8),
                        foregroundColor: Colors.orange,
                        elevation: 4,
                        onPressed: () {
                          playSound('click');
                          setState(() {
                            _isSidebarOpen = !_isSidebarOpen;
                          });
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

class _TrianglePainter extends CustomPainter {
  final double ax;
  final double h;
  final double b;
  final bool isFlipped;

  _TrianglePainter({required this.ax, required this.h, required this.b, required this.isFlipped});

  @override
  void paint(Canvas canvas, Size size) {
    final double tileSize = size.height / 10;
    
    // Offset Grid so that origin is at x=4, y=1 from bottom left
    double originX = 4 * tileSize;
    double originY = size.height - (1 * tileSize);
    
    Offset toCanvas(double x, double y) {
      return Offset(originX + x * tileSize, originY - y * tileSize);
    }

    final gridPaint = Paint()..color = const Color(0xFF334155)..strokeWidth = 1;
    final axisPaint = Paint()..color = Colors.grey..strokeWidth = 2;
    
    for (int i = -4; i <= 11; i++) {
      canvas.drawLine(toCanvas(i.toDouble(), -1), toCanvas(i.toDouble(), 9), gridPaint);
    }
    for (int j = -1; j <= 9; j++) {
      canvas.drawLine(toCanvas(-4, j.toDouble()), toCanvas(11, j.toDouble()), gridPaint);
    }
    canvas.drawLine(toCanvas(-4, 0), toCanvas(11, 0), axisPaint); // X Axis

    // Ghost rectangle
    final rectPaint = Paint()
      ..color = Colors.lightBlue.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final rectStroke = Paint()
      ..color = Colors.lightBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    final rectBounds = Rect.fromPoints(toCanvas(0, 0), toCanvas(b, h));
    canvas.drawRect(rectBounds, rectPaint);
    
    canvas.drawRect(rectBounds, rectStroke);

    // Height Line
    final hLinePaint = Paint()..color = Colors.white.withOpacity(0.5)..strokeWidth = 2;
    canvas.drawLine(toCanvas(ax, 0), toCanvas(ax, h), hLinePaint);

    // Main Triangle
    final triPaint = Paint()
      ..color = Colors.blue.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    final triStroke = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
      
    Path triPath = Path()
      ..moveTo(toCanvas(0, 0).dx, toCanvas(0, 0).dy)
      ..lineTo(toCanvas(b, 0).dx, toCanvas(b, 0).dy)
      ..lineTo(toCanvas(ax, h).dx, toCanvas(ax, h).dy)
      ..close();
      
    canvas.drawPath(triPath, triPaint);
    canvas.drawPath(triPath, triStroke);

    // Duplicate Triangle
    final dupPaint = Paint()
      ..color = Colors.orange.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    final dupStroke = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    if (isFlipped) {
      Path dupPath = Path()
        ..moveTo(toCanvas(b, h).dx, toCanvas(b, h).dy)
        ..lineTo(toCanvas(0, h).dx, toCanvas(0, h).dy)
        ..lineTo(toCanvas(b - ax, 0).dx, toCanvas(b - ax, 0).dy)
        ..close();
      canvas.drawPath(dupPath, dupPaint);
      canvas.drawPath(dupPath, dupStroke);
    } else {
      // Draw it resting outside
      double px = b + 1;
      double py = 0;
      Path dupPath = Path()
        ..moveTo(toCanvas(px, py).dx, toCanvas(px, py).dy)
        ..lineTo(toCanvas(px + b, py).dx, toCanvas(px + b, py).dy)
        ..lineTo(toCanvas(px + ax, py - h).dx, toCanvas(px + ax, py - h).dy)
        ..close();
      canvas.drawPath(dupPath, dupPaint);
      canvas.drawPath(dupPath, dupStroke);
    }

    // Apex Handle
    final handlePaint = Paint()..color = Colors.orange;
    final handleStroke = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawCircle(toCanvas(ax, h), 12, handlePaint);
    canvas.drawCircle(toCanvas(ax, h), 12, handleStroke);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.ax != ax || oldDelegate.h != h || oldDelegate.b != b || oldDelegate.isFlipped != isFlipped;
  }
}
