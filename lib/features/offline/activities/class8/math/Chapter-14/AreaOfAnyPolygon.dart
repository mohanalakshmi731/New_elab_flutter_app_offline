// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

const Map<String, Map<String, dynamic>> I18N = {
  'en': {
    'app_title': 'Area of Any Polygon Lab',
    'app_subtitle': 'CLASS 8 • AREA',
    'start_mission': 'START MISSION',
    'sidebar_title': 'Teacher Board',
    'ui_objective': 'Mission Objective',
    'mission_desc': 'Find the area of any polygon by decomposing it into triangles.',
    'ui_concepts': 'Core Concepts',
    'guide_desc': '1. Any polygon can be divided into non-overlapping triangles.\n2. Quad area = diagonal split: Area = ½ × d × (h₁ + h₂).\n3. Area by subtraction: Full Area − Cutout Area = Remaining Area.',
    'ui_sequence': 'Current Step',
    'data_readouts': 'Data Readouts',
    'btn_verify': 'VERIFY',
    'scen_1': 'Step 1/3: Split the Quadrilateral',
    'scen_1_desc': 'Drag handle C so diagonal AC = 22, then drag B and D so BM = 3 and DN = 3. Press VERIFY.',
    'scen_1_btn': 'VERIFY AREA = 66',
    'scen_2': 'Step 2/3: Subtract the Corner',
    'scen_2_desc': 'Drag the rectangle to 18×10, place E at 10 and F at 6. The shaded region is the rectangle minus corner triangle AFE.',
    'scen_2_btn': 'VERIFY SHADED AREA = 150',
    'scen_3': 'Step 3/3: Decompose Your Polygon',
    'scen_3_desc': 'Drag the 5 vertices to build an irregular polygon, add both cut lines to triangulate it completely, and write a reasoning. Press VERIFY.',
    'scen_3_btn': 'VERIFY DECOMPOSITION',
    'hints': 'Hints / Evidence',
    'h_0': 'Target: AC = 22, BM = 3, DN = 3',
    'h_1': 'Target: W = 18, H = 10, AE = 10, AF = 6',
    'h_2': 'Click BOTH cut buttons to fully triangulate. Add reasoning text.',
    'cut1': 'CUT V0 - V2',
    'cut2': 'CUT V0 - V3',
    'err_target': 'Not quite! Make sure dimensions exactly match the target.',
    'err_cuts': 'Add BOTH cut lines (V0–V2 and V0–V3) to fully triangulate!',
    'err_reason': 'Please enter a short reasoning text before verifying.',
    'success_msg': 'Correct!',
    'reason_lbl': 'Reasoning',
    'btn_prev': 'PREV',
    'btn_next': 'NEXT',
  },
  'hi': {
    'app_title': 'किसी भी बहुभुज का क्षेत्रफल',
    'app_subtitle': 'कक्षा 8 • क्षेत्रफल',
    'start_mission': 'मिशन शुरू करें',
    'sidebar_title': 'शिक्षक बोर्ड',
    'ui_objective': 'मिशन का उद्देश्य',
    'mission_desc': 'किसी भी बहुभुज को त्रिभुजों में विभाजित करके उसका क्षेत्रफल ज्ञात करें।',
    'ui_concepts': 'मूल अवधारणाएं',
    'guide_desc': '1. किसी भी बहुभुज को बिना ओवरलैप वाले त्रिभुजों में विभाजित किया जा सकता है।\n2. चतुर्भुज का क्षेत्रफल: ½ × d × (h₁ + h₂)।\n3. घटाव द्वारा क्षेत्रफल: कुल क्षेत्रफल − काटा गया क्षेत्रफल = शेष क्षेत्रफल।',
    'ui_sequence': 'वर्तमान चरण',
    'data_readouts': 'डेटा रीडआउट्स',
    'btn_verify': 'सत्यापित करें',
    'scen_1': 'चरण 1/3: चतुर्भुज को विभाजित करें',
    'scen_1_desc': 'AC = 22 करने के लिए C खींचें, फिर BM = 3 और DN = 3 करने के लिए B और D खींचें।',
    'scen_1_btn': 'क्षेत्रफल = 66 सत्यापित करें',
    'scen_2': 'चरण 2/3: कोना घटाएं',
    'scen_2_desc': 'आयत को 18×10 बनाएं, E को 10 और F को 6 पर रखें।',
    'scen_2_btn': 'छायांकित क्षेत्रफल = 150 सत्यापित करें',
    'scen_3': 'चरण 3/3: अपने बहुभुज को विच्छेदित करें',
    'scen_3_desc': '5 शीर्षों को खींचें, दोनों कट रेखाएँ जोड़ें, और एक तर्क लिखें।',
    'scen_3_btn': 'विच्छेदन सत्यापित करें',
    'hints': 'संकेत',
    'h_0': 'लक्ष्य: AC = 22, BM = 3, DN = 3',
    'h_1': 'लक्ष्य: W = 18, H = 10, AE = 10, AF = 6',
    'h_2': 'पूरी तरह से त्रिभुजित करने के लिए दोनों कट बटन पर क्लिक करें।',
    'cut1': 'कट V0 - V2',
    'cut2': 'कट V0 - V3',
    'err_target': 'अभी सही नहीं है! आयामों को लक्ष्य से मिलाएँ।',
    'err_cuts': 'पूरी तरह से त्रिभुजित करने के लिए दोनों कट रेखाएँ जोड़ें!',
    'err_reason': 'कृपया सत्यापित करने से पहले एक छोटा तर्क दर्ज करें।',
    'success_msg': 'सही!',
    'reason_lbl': 'तर्क',
    'btn_prev': 'पिछला',
    'btn_next': 'अगला',
  },
};

class AreaOfAnyPolygonApp extends StatefulWidget {
  const AreaOfAnyPolygonApp({super.key});

  @override
  State<AreaOfAnyPolygonApp> createState() => _AreaOfAnyPolygonAppState();
}

class _AreaOfAnyPolygonAppState extends State<AreaOfAnyPolygonApp> with TickerProviderStateMixin {
  String _currentLang = 'en';
  bool _isShutterOpen = true;
  bool _isSidebarOpen = true;

  final AudioPlayer _audioClick = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _audioSuccess = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _audioError = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  int _activeStep = 0;
  bool _showVictory = false;

  // Step 1 State
  double _ac = 14;
  double _bm = 2;
  double _dn = 4;
  
  // Step 2 State
  double _w = 14;
  double _h = 8;
  double _ae = 5;
  double _af = 3;
  
  // Step 3 State
  List<Offset> _poly = [
    const Offset(0, 0),
    const Offset(6, 0),
    const Offset(7, 3),
    const Offset(3, 2),
    const Offset(-1, 3),
  ];
  bool _c1 = false;
  bool _c2 = false;
  String _reasoning = "";
  final TextEditingController _reasoningCtrl = TextEditingController();

  int _dragNodeIndex = -1; // For Step 3
  String _dragHandle = ""; // For Step 1 & 2

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
    _reasoningCtrl.dispose();
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
      debugPrint("Audio error: \$e");
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
    setState(() {
      _currentLang = 'en';
      _isShutterOpen = true;
      _activeStep = 0;
      _showVictory = false;
      _ac = 14; _bm = 2; _dn = 4;
      _w = 14; _h = 8; _ae = 5; _af = 3;
      _poly = [
        const Offset(0, 0), const Offset(6, 0), const Offset(7, 3), const Offset(3, 2), const Offset(-1, 3),
      ];
      _c1 = false; _c2 = false;
      _reasoning = "";
      _reasoningCtrl.clear();
    });
  }

  void _verifyStep() {
    playSound('click');
    final t = I18N[_currentLang]!;
    
    if (_activeStep == 0) {
      if (_ac == 22 && _bm == 3 && _dn == 3) {
        playSound('success');
        _showToastMsg(t['success_msg']);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => _activeStep = 1);
        });
      } else {
        playSound('error');
        _showToastMsg(t['err_target'], isError: true);
      }
    } else if (_activeStep == 1) {
      if (_w == 18 && _h == 10 && _ae == 10 && _af == 6) {
        playSound('success');
        _showToastMsg(t['success_msg']);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => _activeStep = 2);
        });
      } else {
        playSound('error');
        _showToastMsg(t['err_target'], isError: true);
      }
    } else if (_activeStep == 2) {
      if (!_c1 || !_c2) {
        playSound('error');
        _showToastMsg(t['err_cuts'], isError: true);
        return;
      }
      if (_reasoning.trim().isEmpty) {
        playSound('error');
        _showToastMsg(t['err_reason'], isError: true);
        return;
      }
      playSound('success');
      _showToastMsg(t['success_msg']);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _showVictory = true);
      });
    }
  }

  void _nextStep() {
    if (_activeStep < 2) {
      playSound('click');
      setState(() => _activeStep++);
    }
  }

  void _prevStep() {
    if (_activeStep > 0) {
      playSound('click');
      setState(() => _activeStep--);
    }
  }

  // Handle Dragging
  void _onPanStart(DragStartDetails details, Size size) {
    playSound('click');
    
    double cx = size.width / 2;
    double cy = size.height / 2;
    double unit = 20.0;
    
    Offset localPos = details.localPosition;
    Offset worldTouch = Offset((localPos.dx - cx) / unit, -(localPos.dy - cy) / unit);
    
    double threshold = 2.0;
    
    if (_activeStep == 0) {
      Offset pC = Offset(_ac / 2, 0);
      Offset pB = Offset(-_ac/2 + _ac * 0.36, _bm);
      Offset pD = Offset(-_ac/2 + _ac * 0.68, -_dn);
      
      if ((worldTouch - pC).distance < threshold) { _dragHandle = "C"; return; }
      if ((worldTouch - pB).distance < threshold) { _dragHandle = "B"; return; }
      if ((worldTouch - pD).distance < threshold) { _dragHandle = "D"; return; }
    } else if (_activeStep == 1) {
      Offset pCorner = Offset(_w/2, -_h/2); // bottom-right
      Offset pA = Offset(-_w/2, _h/2);
      Offset pE = Offset(pA.dx + _ae, pA.dy);
      Offset pF = Offset(pA.dx, pA.dy - _af);
      
      if ((worldTouch - pCorner).distance < threshold) { _dragHandle = "WH"; return; }
      if ((worldTouch - pE).distance < threshold) { _dragHandle = "E"; return; }
      if ((worldTouch - pF).distance < threshold) { _dragHandle = "F"; return; }
    } else if (_activeStep == 2) {
      for (int i = 0; i < _poly.length; i++) {
        if ((worldTouch - _poly[i]).distance < threshold) {
          _dragNodeIndex = i;
          return;
        }
      }
    }
    
    _dragHandle = "";
    _dragNodeIndex = -1;
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (_dragHandle.isEmpty && _dragNodeIndex == -1) return;
    
    double cx = size.width / 2;
    double cy = size.height / 2;
    double unit = 20.0;
    
    Offset localPos = details.localPosition;
    Offset worldTouch = Offset((localPos.dx - cx) / unit, -(localPos.dy - cy) / unit);
    
    setState(() {
      if (_activeStep == 0) {
        if (_dragHandle == "C") {
          _ac = (worldTouch.dx * 2).clamp(10.0, 30.0).roundToDouble();
        } else if (_dragHandle == "B") {
          _bm = worldTouch.dy.clamp(1.0, 10.0).roundToDouble();
        } else if (_dragHandle == "D") {
          _dn = (-worldTouch.dy).clamp(1.0, 10.0).roundToDouble();
        }
      } else if (_activeStep == 1) {
        if (_dragHandle == "WH") {
          _w = (worldTouch.dx * 2).clamp(10.0, 24.0).roundToDouble();
          _h = (-worldTouch.dy * 2).clamp(6.0, 14.0).roundToDouble();
          if (_ae > _w) _ae = _w;
          if (_af > _h) _af = _h;
        } else if (_dragHandle == "E") {
          Offset pA = Offset(-_w/2, _h/2);
          _ae = (worldTouch.dx - pA.dx).clamp(2.0, _w).roundToDouble();
        } else if (_dragHandle == "F") {
          Offset pA = Offset(-_w/2, _h/2);
          _af = (pA.dy - worldTouch.dy).clamp(2.0, _h).roundToDouble();
        }
      } else if (_activeStep == 2) {
        if (_dragNodeIndex != -1) {
          _poly[_dragNodeIndex] = Offset(
            worldTouch.dx.clamp(-16.0, 16.0).roundToDouble(),
            worldTouch.dy.clamp(-12.0, 12.0).roundToDouble()
          );
        }
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _dragHandle = "";
    _dragNodeIndex = -1;
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
            const Icon(Icons.draw, size: 70, color: Colors.cyanAccent),
            const SizedBox(height: 24),
            Text(t['app_title'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(t['app_subtitle'], style: const TextStyle(fontSize: 12, color: Colors.cyan, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                playSound('click');
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
              const Text("You found the area of a quadrilateral, a cut-corner rectangle, and your own irregular polygon — all by decomposing into triangles.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5)),
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
                child: const Icon(Icons.draw, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['app_title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(t['sidebar_title'], style: const TextStyle(color: Colors.cyan, fontSize: 9, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
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
          
          // Data Readouts specific to step
          _buildSidebarSectionWidget(
            t['data_readouts'],
            _buildReadouts(),
            Icons.bar_chart
          ),
          const SizedBox(height: 12),
          
          // Action Area
          if (_activeStep == 2) ...[
            Row(
              children: [
                Expanded(child: ElevatedButton(
                  onPressed: () => setState(() { _c1 = true; playSound('click'); }),
                  style: ElevatedButton.styleFrom(backgroundColor: _c1 ? Colors.green : const Color(0xFF1e293b), foregroundColor: Colors.white),
                  child: Text(t['cut1'], style: const TextStyle(fontSize: 10)),
                )),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton(
                  onPressed: () => setState(() { _c2 = true; playSound('click'); }),
                  style: ElevatedButton.styleFrom(backgroundColor: _c2 ? Colors.green : const Color(0xFF1e293b), foregroundColor: Colors.white),
                  child: Text(t['cut2'], style: const TextStyle(fontSize: 10)),
                )),
              ],
            ),
            const SizedBox(height: 8),
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
                  onPressed: _activeStep < 2 ? _nextStep : null,
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

  Widget _buildReadouts() {
    if (_activeStep == 0) {
      double area = 0.5 * _ac * (_bm + _dn);
      return Column(
        children: [
          _buildRow("Diagonal AC", "${_ac.toInt()} cm"),
          _buildRow("Height BM", "${_bm.toInt()} cm"),
          _buildRow("Height DN", "${_dn.toInt()} cm"),
          const Divider(color: Color(0xFF334155)),
          _buildRow("Total Area", "${area.toStringAsFixed(1)} sq cm", isTotal: true),
        ],
      );
    } else if (_activeStep == 1) {
      double totalArea = _w * _h;
      double cutArea = 0.5 * _ae * _af;
      return Column(
        children: [
          _buildRow("Rect W × H", "${_w.toInt()} × ${_h.toInt()}"),
          _buildRow("Cut AE / AF", "${_ae.toInt()} / ${_af.toInt()}"),
          const Divider(color: Color(0xFF334155)),
          _buildRow("Shaded Area", "${(totalArea - cutArea).toStringAsFixed(1)} sq cm", isTotal: true),
        ],
      );
    } else {
      double shoeArea = _calculateShoelace();
      return Column(
        children: [
          _buildRow("Vertices", "5"),
          _buildRow("Cuts Added", "${(_c1 ? 1 : 0) + (_c2 ? 1 : 0)}/2"),
          const Divider(color: Color(0xFF334155)),
          _buildRow("Shoelace Area", "${shoeArea.toStringAsFixed(1)}", isTotal: true),
        ],
      );
    }
  }

  double _calculateShoelace() {
    double sum = 0;
    for (int i = 0; i < _poly.length; i++) {
      int j = (i + 1) % _poly.length;
      sum += _poly[i].dx * _poly[j].dy - _poly[j].dx * _poly[i].dy;
    }
    return (sum.abs() / 2.0);
  }

  Widget _buildRow(String label, String val, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11))),
          Text(val, style: TextStyle(color: isTotal ? Colors.greenAccent : Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
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
                                color: Colors.transparent, // Important for drag detection
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                                child: CustomPaint(
                                  painter: _PolygonPainter(
                                    step: _activeStep,
                                    ac: _ac, bm: _bm, dn: _dn,
                                    w: _w, h: _h, ae: _ae, af: _af,
                                    poly: _poly,
                                    c1: _c1, c2: _c2,
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

class _PolygonPainter extends CustomPainter {
  final int step;
  final double ac, bm, dn;
  final double w, h, ae, af;
  final List<Offset> poly;
  final bool c1, c2;

  _PolygonPainter({
    required this.step,
    required this.ac, required this.bm, required this.dn,
    required this.w, required this.h, required this.ae, required this.af,
    required this.poly, required this.c1, required this.c2
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
      final textSpan = TextSpan(text: text, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold, backgroundColor: Colors.black45));
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(toCanvas(p).dx - textPainter.width / 2, toCanvas(p).dy - textPainter.height / 2 - 15));
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

    final fillP = Paint()..color = Colors.cyan.withOpacity(0.3)..style = PaintingStyle.fill;
    final strokeP = Paint()..color = Colors.cyanAccent..style = PaintingStyle.stroke..strokeWidth = 2;
    final dashP = Paint()..color = Colors.white54..style = PaintingStyle.stroke..strokeWidth = 1.5;
    
    void drawHandle(Offset p, Color color) {
      canvas.drawCircle(toCanvas(p), 10, Paint()..color = color.withOpacity(0.5));
      canvas.drawCircle(toCanvas(p), 6, Paint()..color = color);
      canvas.drawCircle(toCanvas(p), 3, Paint()..color = Colors.white);
    }

    if (step == 0) {
      // Quadrilateral
      Offset pA = Offset(-ac/2, 0);
      Offset pC = Offset(ac/2, 0);
      Offset pB = Offset(pA.dx + ac * 0.36, bm);
      Offset pD = Offset(pA.dx + ac * 0.68, -dn);
      
      Path path = Path()..moveTo(toCanvas(pA).dx, toCanvas(pA).dy)
        ..lineTo(toCanvas(pB).dx, toCanvas(pB).dy)
        ..lineTo(toCanvas(pC).dx, toCanvas(pC).dy)
        ..lineTo(toCanvas(pD).dx, toCanvas(pD).dy)..close();
        
      canvas.drawPath(path, fillP);
      canvas.drawPath(path, strokeP);
      
      // Diagonals & Heights
      canvas.drawLine(toCanvas(pA), toCanvas(pC), dashP);
      canvas.drawLine(toCanvas(pB), toCanvas(Offset(pB.dx, 0)), dashP);
      canvas.drawLine(toCanvas(pD), toCanvas(Offset(pD.dx, 0)), dashP);
      
      drawHandle(pC, Colors.purpleAccent);
      drawHandle(pB, Colors.orangeAccent);
      drawHandle(pD, Colors.orangeAccent);

      drawText("AC = ${ac.toInt()}", Offset(0, 0.5), color: Colors.purpleAccent);
      drawText("BM = ${bm.toInt()}", Offset(pB.dx, bm/2), color: Colors.orangeAccent);
      drawText("DN = ${dn.toInt()}", Offset(pD.dx, -dn/2), color: Colors.orangeAccent);
      
    } else if (step == 1) {
      // Rectangle with cutout
      Offset pA = Offset(-w/2, h/2);
      Offset pB = Offset(w/2, h/2); // Top Right
      Offset pC = Offset(w/2, -h/2); // Bottom Right
      Offset pD = Offset(-w/2, -h/2); // Bottom Left
      
      Offset pE = Offset(pA.dx + ae, pA.dy);
      Offset pF = Offset(pA.dx, pA.dy - af);
      
      // Shaded Area (Rectangle minus corner)
      Path path = Path()..moveTo(toCanvas(pF).dx, toCanvas(pF).dy)
        ..lineTo(toCanvas(pE).dx, toCanvas(pE).dy)
        ..lineTo(toCanvas(pB).dx, toCanvas(pB).dy)
        ..lineTo(toCanvas(pC).dx, toCanvas(pC).dy)
        ..lineTo(toCanvas(pD).dx, toCanvas(pD).dy)..close();
        
      canvas.drawPath(path, fillP);
      canvas.drawPath(path, strokeP);
      
      // Ghost full rect
      Path rectPath = Path()..moveTo(toCanvas(pA).dx, toCanvas(pA).dy)
        ..lineTo(toCanvas(pB).dx, toCanvas(pB).dy)
        ..lineTo(toCanvas(pC).dx, toCanvas(pC).dy)
        ..lineTo(toCanvas(pD).dx, toCanvas(pD).dy)..close();
      canvas.drawPath(rectPath, Paint()..color=Colors.white24..style=PaintingStyle.stroke..strokeWidth=1);
      
      canvas.drawLine(toCanvas(pE), toCanvas(pF), dashP);
      
      drawHandle(pC, Colors.greenAccent); // WH control
      drawHandle(pE, Colors.pinkAccent);
      drawHandle(pF, Colors.pinkAccent);

      drawText("W = ${w.toInt()}", Offset(0, -h/2 - 1));
      drawText("H = ${h.toInt()}", Offset(w/2 + 1.5, 0));
      drawText("AE = ${ae.toInt()}", Offset(pA.dx + ae/2, pA.dy - 0.5), color: Colors.pinkAccent);
      drawText("AF = ${af.toInt()}", Offset(pA.dx + 1.5, pA.dy - af/2), color: Colors.pinkAccent);
      
    } else if (step == 2) {
      // Irregular Pentagon
      Path path = Path()..moveTo(toCanvas(poly[0]).dx, toCanvas(poly[0]).dy);
      for (int i=1; i<poly.length; i++) {
        path.lineTo(toCanvas(poly[i]).dx, toCanvas(poly[i]).dy);
      }
      path.close();
      
      canvas.drawPath(path, fillP);
      canvas.drawPath(path, strokeP);
      
      if (c1) {
        canvas.drawLine(toCanvas(poly[0]), toCanvas(poly[2]), Paint()..color=Colors.yellowAccent..strokeWidth=2);
      }
      if (c2) {
        canvas.drawLine(toCanvas(poly[0]), toCanvas(poly[3]), Paint()..color=Colors.yellowAccent..strokeWidth=2);
      }
      
      for (int i=0; i<poly.length; i++) {
        drawHandle(poly[i], Colors.blueAccent);
        drawText("V$i (${poly[i].dx.toInt()},${poly[i].dy.toInt()})", poly[i], color: Colors.blueAccent);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PolygonPainter oldDelegate) => true;
}
