// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class CryptarithmCracker extends StatefulWidget {
  const CryptarithmCracker({super.key});

  @override
  _CryptarithmCrackerState createState() => _CryptarithmCrackerState();
}

class _CryptarithmCrackerState extends State<CryptarithmCracker> with TickerProviderStateMixin {
  // Audio
  final AudioPlayer _fxPlayer = AudioPlayer();
  final String _shutterUrl = 'audio/class8/mixkit_2574.mp3';
  final String _clickUrl = 'audio/class8/mixkit_2568.mp3';
  final String _successUrl = 'audio/class8/mixkit_2018.mp3';
  final String _errorUrl = 'audio/class8/mixkit_955.mp3';

  // Configs
  final List<Map<String, dynamic>> s2Options = [
    {'gh': 11, 'h': 9}, {'gh': 12, 'h': 8}, {'gh': 46, 'h': 2},
    {'gh': 24, 'h': 4}, {'gh': 47, 'h': 2}, {'gh': 31, 'h': 3}, {'gh': 16, 'h': 6}
  ];

  // State
  int _scen = 0;
  final bool _isDark = true;
  String _lang = 'en';
  
  bool _sidebarOpen = true;
  bool _showReport = false;
  int _hintIdx = 0;
  bool _shutterActive = true;
  
  // Scenarios State
  final List<String> _s1Letters = ['P', 'Q', 'R', 'S'];
  Map<String, int?> _s1Map = {'P': null, 'Q': null, 'R': null, 'S': null};
  String? _s1Active;

  int? _s2Selected;

  final List<String> _s3Letters = ['B', 'Y', 'E', 'R', 'A'];
  Map<String, int?> _s3Map = {'B': null, 'Y': null, 'E': null, 'R': null, 'A': null};
  String? _s3Active;

  List<bool> _res = [false, false, false];
  List<Map<String, dynamic>?> _diags = [null, null, null];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _fxPlayer.setSource(AssetSource(_shutterUrl));
  }

  @override
  void dispose() {
    _fxPlayer.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playClick() { _fxPlayer.stop(); _fxPlayer.play(AssetSource(_clickUrl)); }
  void _playSuccess() { _fxPlayer.stop(); _fxPlayer.play(AssetSource(_successUrl)); }
  void _playError() { _fxPlayer.stop(); _fxPlayer.play(AssetSource(_errorUrl)); }
  void _playShutter() { _fxPlayer.stop(); _fxPlayer.play(AssetSource(_shutterUrl)); }

  void _showSnack(String msg, Color bg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      backgroundColor: bg,
      duration: const Duration(milliseconds: 2500),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 80, left: 50, right: 50),
    ));
  }

  void _hardReset() {
    _playClick();
    setState(() {
      _scen = 0;
      _hintIdx = 0;
      _s1Map = {'P': null, 'Q': null, 'R': null, 'S': null}; _s1Active = null;
      _s2Selected = null;
      _s3Map = {'B': null, 'Y': null, 'E': null, 'R': null, 'A': null}; _s3Active = null;
      _res = [false, false, false];
      _diags = [null, null, null];
      _showReport = false;
      _shutterActive = true;
      _lang = 'en';
    });
  }

  void _gotoScenario(int idx) {
    if (idx < 0 || idx > 2) return;
    setState(() {
      _scen = idx;
      _s1Active = null;
      _s3Active = null;
    });
  }

  Map<String, dynamic> _validateS1() {
    List<int?> vals = [_s1Map['P'], _s1Map['Q'], _s1Map['R'], _s1Map['S']];
    bool allSet = !vals.contains(null);
    int setCount = vals.where((v) => v != null).length;
    bool distinct = allSet && vals.toSet().length == 4;
    bool leadOk = allSet && _s1Map['P'] != 0 && _s1Map['R'] != 0;
    bool arith = allSet && (10 * _s1Map['P']! + _s1Map['Q']!) * 8 == (10 * _s1Map['R']! + _s1Map['S']!);
    bool passed = allSet && distinct && leadOk && arith;
    return {'allSet': allSet, 'distinct': distinct, 'leadOk': leadOk, 'arith': arith, 'passed': passed, 'setCount': setCount, 'total': 4};
  }

  Map<String, dynamic> _validateS2() {
    if (_s2Selected == null) return {'selected': false, 'unitsOk': false, 'rangeOk': false, 'distinct': false, 'passed': false};
    var o = s2Options[_s2Selected!];
    int G = o['gh'] ~/ 10;
    int H = o['gh'] % 10;
    int prod = o['gh'] * o['h'];
    int K = prod % 10;
    bool unitsOk = o['h'] == H;
    bool rangeOk = prod >= 90 && prod <= 99;
    bool distinct = {G, H, K}.length == 3;
    bool passed = unitsOk && rangeOk && distinct;
    return {'selected': true, 'unitsOk': unitsOk, 'rangeOk': rangeOk, 'distinct': distinct, 'passed': passed};
  }

  Map<String, dynamic> _validateS3() {
    List<int?> vals = [_s3Map['B'], _s3Map['Y'], _s3Map['E'], _s3Map['R'], _s3Map['A']];
    bool allSet = !vals.contains(null);
    int setCount = vals.where((v) => v != null).length;
    bool distinct = allSet && vals.toSet().length == 5;
    bool leadOk = allSet && _s3Map['B'] != 0 && _s3Map['R'] != 0;
    bool arith = allSet && (100 * _s3Map['B']! + 10 * _s3Map['Y']! + _s3Map['E']!) * 6 == (100 * _s3Map['R']! + 10 * _s3Map['A']! + _s3Map['Y']!);
    bool passed = allSet && distinct && leadOk && arith;
    return {'allSet': allSet, 'distinct': distinct, 'leadOk': leadOk, 'arith': arith, 'passed': passed, 'setCount': setCount, 'total': 5};
  }

  void _submit() {
    _playClick();
    double ps = 0, pf = 0, mm = 0, lr = 0;
    bool passed = false;

    if (_scen == 0) {
      var v = _validateS1();
      passed = v['passed'];
      pf = v['setCount'] / v['total'];
      mm = v['arith'] ? 1 : 0;
      lr = (v['distinct'] ? 0.5 : 0) + (v['leadOk'] ? 0.5 : 0);
      ps = passed ? 1 : (v['arith'] && v['allSet'] ? 0.6 : 0.2);
    } else if (_scen == 1) {
      var v = _validateS2();
      passed = v['passed'];
      pf = v['selected'] ? 1 : 0;
      mm = v['unitsOk'] && v['rangeOk'] ? 1 : (v['selected'] ? 0.4 : 0);
      lr = v['distinct'] ? 1 : (v['selected'] ? 0.3 : 0);
      ps = passed ? 1 : (v['selected'] ? 0.5 : 0);
    } else {
      var v = _validateS3();
      passed = v['passed'];
      pf = v['setCount'] / v['total'];
      mm = v['arith'] ? 1 : 0;
      lr = (v['distinct'] ? 0.5 : 0) + (v['leadOk'] ? 0.5 : 0);
      ps = passed ? 1 : (v['arith'] && v['allSet'] ? 0.6 : 0.2);
    }

    setState(() {
      _res[_scen] = passed;
      List<String> str = [], imp = [];
      if (ps >= 0.8) {
        str.add(t('rep_str1'));
      } else {
        imp.add(t('rep_imp1'));
      }
      if (pf >= 0.8) {
        str.add(t('rep_str2'));
      } else {
        imp.add(t('rep_imp2'));
      }
      if (mm >= 0.8) {
        str.add(t('rep_str3'));
      } else {
        imp.add(t('rep_imp3'));
      }
      if (lr >= 0.8) {
        str.add(t('rep_str4'));
      } else {
        imp.add(t('rep_imp4'));
      }
      _diags[_scen] = {'str': str, 'imp': imp, 'passed': passed};

      if (passed) {
        _playSuccess();
        _hintIdx = 0;
        if (_res.every((r) => r)) {
          _showReport = true;
        } else {
          _showSnack(t('ui_scen_cleared'), Colors.green);
        }
      } else {
        _playError();
        _showReport = true;
      }
    });
  }

  void _doHint() {
    _playClick();
    List<List<String>> hArr = [
      ['h_1a', 'h_1b', 'h_1c'],
      ['h_2a', 'h_2b', 'h_2c'],
      ['h_3a', 'h_3b', 'h_3c']
    ];
    String k = hArr[_scen][_hintIdx % hArr[_scen].length];
    setState(() => _hintIdx++);
    if (!_sidebarOpen) setState(() => _sidebarOpen = true);
    _showSnack(t(k), Colors.amber.shade900);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Row(
            children: [
              if (_sidebarOpen) _buildSidebar(),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(40),
                        minScale: 0.5,
                        maxScale: 3.0,
                        constrained: false,
                        child: _buildCanvas(),
                      ),
                    ),
                    _buildHUD(),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 10, left: 10,
            child: IconButton(
              icon: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu, size: 28),
              color: Colors.amber,
              onPressed: () { _playClick(); setState(() => _sidebarOpen = !_sidebarOpen); },
              style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.3)),
            ),
          ),
          if (_showReport) _buildReportModal(),
          if (_shutterActive) _buildShutterScreen(),
        ],
      ),
    );
  }

  Widget _buildShutterScreen() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: _shutterActive ? 1.0 : 0.0,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.password, color: Colors.amber, size: 80),
              const SizedBox(height: 16),
              Text(t('app_title'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(t('app_subtitle'), style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  _playShutter();
                  setState(() => _shutterActive = false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                child: Text(t('start_mission').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    List<String> steps = _scen == 0 ? ['s1_1', 's1_2', 's1_3'] : (_scen == 1 ? ['s2_1', 's2_2', 's2_3'] : ['s3_1', 's3_2', 's3_3']);
    
    int active = 0; List<int> done = [];
    if (_scen == 1) {
      if (_s2Selected != null) active = 1;
      if (_res[1]) done = [0, 1, 2];
    } else {
      var map = _scen == 0 ? _s1Map : _s3Map;
      int setCount = map.values.where((v) => v != null).length;
      active = setCount == 0 ? 0 : (setCount < map.length ? 1 : 2);
      if (setCount > 0) done.add(0);
      if (setCount == map.length) done.add(1);
      if (_res[_scen]) done = [0, 1, 2];
    }

    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xD80F172A) : Colors.white.withOpacity(0.95),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.15))),
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.language),
                  color: Colors.grey,
                  onPressed: () {
                    _playClick();
                    setState(() => _lang = _lang == 'en' ? 'hi' : 'en');
                  },
                ),
                Text(_lang.toUpperCase(), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.refresh), color: Colors.grey, onPressed: _hardReset),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20).copyWith(top: 0),
              children: [
                const SizedBox(height: 12),
                Text(t('app_title'), style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(t('app_subtitle'), style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.co_present, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(t('teacher_board'), style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildPanel(t('scenario'), DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _scen,
                    isExpanded: true,
                    dropdownColor: _isDark ? const Color(0xFF0F172A) : Colors.white,
                    style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                    items: [0, 1, 2].map((i) => DropdownMenuItem(value: i, child: Text(t('scen_${i+1}')))).toList(),
                    onChanged: (v) { _playClick(); _gotoScenario(v!); },
                  ),
                )),
                const SizedBox(height: 16),
                _buildPanel(t('mission_obj'), Text(t('global_mission'), style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600))),
                const SizedBox(height: 16),
                _buildPanel(t('inst_seq'), Column(
                  children: List.generate(steps.length, (i) {
                    bool isDone = done.contains(i);
                    bool isActive = active == i && !isDone;
                    Color bg = isDone ? Colors.green.withOpacity(0.1) : (isActive ? Colors.orange.withOpacity(0.2) : Colors.transparent);
                    Color textCol = isDone ? Colors.green : (isActive ? Colors.amber : Colors.grey);
                    IconData icon = isDone ? Icons.check_circle : (isActive ? Icons.arrow_circle_right : Icons.circle_outlined);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border(left: BorderSide(color: isActive || isDone ? textCol : Colors.transparent, width: 4))),
                      child: Row(
                        children: [
                          Icon(icon, color: textCol, size: 20),
                          const SizedBox(width: 12),
                          Expanded(child: Text(t(steps[i]), style: TextStyle(color: textCol, fontWeight: isActive || isDone ? FontWeight.bold : FontWeight.normal))),
                        ],
                      ),
                    );
                  }),
                )),
                const SizedBox(height: 16),
                _buildPanel(t('learnt_conc'), Text(t('learnt_text'), style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600))),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _doHint,
                  icon: const Icon(Icons.lightbulb),
                  label: Text(t('get_hint').toUpperCase()),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  child: const Text('© ZEROSCIENCELAB - Fall in Love with Math and Science', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _isDark ? const Color(0xFF0F172A) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
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
                        const Icon(Icons.extension, color: Colors.amber),
                        const SizedBox(width: 12),
                        Text(t('scen_${_scen+1}'), style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(t(_scen == 0 ? 's1_2' : (_scen == 1 ? 's2_3' : 's3_3')), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildCanvasCard(t('scen_${_scen+1}'), _buildEquation()),
                        if (_scen != 1) const SizedBox(height: 24),
                        if (_scen != 1) _buildCanvasCard(t('ui_decodel'), _buildRack(), sub: t('ui_taplet')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        if (_scen != 1) _buildCanvasCard(t('ui_dkeypad'), _buildKeypad(), sub: (_scen == 0 ? _s1Active : _s3Active) == null ? t('ui_sel_let') : t('ui_tap_d').replaceAll('{0}', _scen == 0 ? _s1Active! : _s3Active!)),
                        if (_scen == 1) _buildCanvasCard(t('ui_optc'), _buildOptions()),
                        const SizedBox(height: 24),
                        _buildCanvasCard(t('ui_cclist'), _buildChecklist()),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCanvasCard(String title, Widget content, {String? sub}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _isDark ? const Color(0xFF0F172A) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _glyph(String l, int? val, bool active, bool isResult) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (_res[_scen]) return;
            if (isResult) return;
            _playClick();
            setState(() { if (_scen == 0) {
              _s1Active = l;
            } else {
              _s3Active = l;
            } });
          },
          child: Container(
            width: 50, height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isResult ? Colors.blue.shade900 : (active ? Colors.amber : (_isDark ? const Color(0xFF0F172A) : Colors.white)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isResult ? Colors.blueAccent : (active ? Colors.white : Colors.amber), width: active ? 3 : 2),
            ),
            child: Text(val == null ? '?' : '$val', style: TextStyle(color: isResult ? Colors.blueAccent : (active ? Colors.black : (_isDark ? Colors.white : Colors.black)), fontSize: 28, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(isResult ? ' ' : l, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _op(String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Text(t, style: const TextStyle(color: Colors.amber, fontSize: 32, fontWeight: FontWeight.bold)),
    );
  }

  Widget _fixed(String t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50, height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Text(t, style: const TextStyle(color: Colors.amber, fontSize: 28, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        const Text(' ', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildEquation() {
    if (_scen == 0) {
      int? p = _s1Map['P'], q = _s1Map['Q'], r = _s1Map['R'], s = _s1Map['S'];
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _glyph('P', p, _s1Active == 'P', false), _glyph('Q', q, _s1Active == 'Q', false),
              _op('×'), _fixed('8'), _op('='),
              _glyph('R', r, _s1Active == 'R', false), _glyph('S', s, _s1Active == 'S', false),
            ],
          ),
          if (p != null && q != null) ...[
            const SizedBox(height: 16),
            Text('${t('ui_live')} ${10*p+q} × 8 = ${(10*p+q)*8}${r!=null&&s!=null ? '  ·  ${t('ui_yr_ans')} RS = ${10*r+s}' : ''}', style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ]
        ],
      );
    } else if (_scen == 2) {
      int? b = _s3Map['B'], y = _s3Map['Y'], e = _s3Map['E'], r = _s3Map['R'], a = _s3Map['A'];
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _glyph('B', b, _s3Active == 'B', false), _glyph('Y', y, _s3Active == 'Y', false), _glyph('E', e, _s3Active == 'E', false),
                _op('×'), _fixed('6'), _op('='),
                _glyph('R', r, _s3Active == 'R', false), _glyph('A', a, _s3Active == 'A', false), _glyph('Y', y, _s3Active == 'Y', false),
              ],
            ),
            if (b != null && y != null && e != null) ...[
              const SizedBox(height: 16),
              Text('${t('ui_live')} ${100*b+10*y+e} × 6 = ${(100*b+10*y+e)*6}${r!=null&&a!=null ? '  ·  ${t('ui_yr_ans')} RAY = ${100*r+10*a+y}' : ''}', style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ]
          ],
        ),
      );
    } else {
      if (_s2Selected == null) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _glyph('G', null, false, true), _glyph('H', null, false, true),
            _op('×'), _glyph('H', null, false, true), _op('='),
            _fixed('9'), _glyph('K', null, false, true),
          ],
        );
      } else {
        var o = s2Options[_s2Selected!];
        int G = o['gh'] ~/ 10, H = o['gh'] % 10, prod = o['gh'] * o['h'], K = prod % 10;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _glyph('G', G, false, true), _glyph('H', H, false, true),
                _op('×'), _glyph('H', o['h'], false, true), _op('='),
                _glyph('9', prod ~/ 10, false, true), _glyph('K', K, false, true),
              ],
            ),
            const SizedBox(height: 16),
            Text('${t('ui_c_ans')} ${o['gh']} × ${o['h']} = $prod  →  G=$G, H=$H, K=$K', style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        );
      }
    }
  }

  Widget _buildRack() {
    var letters = _scen == 0 ? _s1Letters : _s3Letters;
    var map = _scen == 0 ? _s1Map : _s3Map;
    var active = _scen == 0 ? _s1Active : _s3Active;

    return Wrap(
      spacing: 12, runSpacing: 12,
      alignment: WrapAlignment.center,
      children: letters.map((l) {
        bool isActive = active == l;
        bool isFilled = map[l] != null;
        return GestureDetector(
          onTap: () {
            if (_res[_scen]) return;
            _playClick();
            setState(() { if (_scen == 0) {
              _s1Active = l;
            } else {
              _s3Active = l;
            } });
          },
          child: Container(
            width: 60, height: 75,
            decoration: BoxDecoration(
              color: isActive ? Colors.amber.withOpacity(0.2) : (_isDark ? const Color(0xFF0F172A) : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isActive ? Colors.white : Colors.white12, width: isActive ? 3 : 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l, style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(isFilled ? '${map[l]}' : '—', style: TextStyle(color: isFilled ? Colors.green : Colors.grey, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeypad() {
    var active = _scen == 0 ? _s1Active : _s3Active;
    return Column(
      children: [
        Wrap(
          spacing: 8, runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(10, (i) {
            return ElevatedButton(
              onPressed: () {
                if (_res[_scen]) return;
                if (active == null) {
                  _playError();
                  _showSnack(t('ui_sel_let'), Colors.redAccent);
                  return;
                }
                _playClick();
                setState(() {
                  if (_scen == 0) {
                    _s1Map[active] = i;
                  } else {
                    _s3Map[active] = i;
                  }
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: _isDark ? const Color(0xFF020617) : Colors.grey.shade100, foregroundColor: _isDark ? Colors.white : Colors.black, minimumSize: const Size(60, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white12))),
              child: Text('$i', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            );
          }),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            if (_res[_scen]) return;
            if (active == null) return;
            _playClick();
            setState(() { if (_scen == 0) {
              _s1Map[active] = null;
            } else {
              _s3Map[active] = null;
            } });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1), foregroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text(t('ui_clear'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Column(
      children: List.generate(s2Options.length, (i) {
        var o = s2Options[i];
        bool isSel = _s2Selected == i;
        return GestureDetector(
          onTap: () {
            if (_res[1]) return;
            _playClick();
            setState(() => _s2Selected = i);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: isSel ? Colors.amber.withOpacity(0.2) : (_isDark ? const Color(0xFF020617) : Colors.grey.shade100), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSel ? Colors.amber : Colors.white12, width: 2)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${o['gh']} × ${o['h']} = ${o['gh']*o['h']}', style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(t('ui_units').replaceAll('{0}', '${o['gh']}').replaceAll('{1}', '${o['gh']%10}'), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildChecklist() {
    List<Map<String, dynamic>> items = [];
    if (_scen == 0 || _scen == 2) {
      var v = _scen == 0 ? _validateS1() : _validateS3();
      var m = _scen == 0 ? _s1Map : _s3Map;
      if (_scen == 0) {
        items.add({'ok': v['allSet'], 'txt': t('c_s1_1').replaceAll('{0}', '${v['setCount']}').replaceAll('{1}', '${v['total']}')});
        items.add({'ok': v['distinct'], 'txt': t('c_s1_2')});
        items.add({'ok': v['leadOk'], 'txt': t('c_s1_3')});
        items.add({'ok': v['arith'], 'txt': t('c_s1_4')});
      } else {
        items.add({'ok': v['allSet'], 'txt': t('c_s1_1').replaceAll('{0}', '${v['setCount']}').replaceAll('{1}', '${v['total']}')});
        items.add({'ok': v['distinct'], 'txt': t('c_s1_2')});
        items.add({'ok': v['leadOk'], 'txt': t('c_s1_3')});
        items.add({'ok': v['arith'], 'txt': t('c_s3_1')});
        items.add({'ok': m['B'] == 1, 'txt': t('c_s3_2')});
        items.add({'ok': m['Y'] != null && m['Y']! % 2 == 0 && m['Y']! < 7, 'txt': t('c_s3_3')});
      }
    } else {
      var v = _validateS2();
      items.add({'ok': v['selected'], 'txt': t('c_s2_1')});
      if (v['selected']) {
        items.add({'ok': v['unitsOk'], 'txt': t('c_s2_2')});
        items.add({'ok': v['rangeOk'], 'txt': t('c_s2_3')});
        items.add({'ok': v['distinct'], 'txt': t('c_s2_4')});
      } else {
        items.add({'ok': false, 'txt': t('c_s2_2')});
        items.add({'ok': false, 'txt': t('c_s2_3')});
        items.add({'ok': false, 'txt': t('c_s2_4')});
      }
    }

    return Column(
      children: items.map((it) {
        bool ok = it['ok'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: ok ? Colors.green : (_isDark ? const Color(0xFF020617) : Colors.grey.shade200), borderRadius: BorderRadius.circular(6), border: Border.all(color: ok ? Colors.green : Colors.white12)),
                child: ok ? const Icon(Icons.check, color: Colors.black, size: 16) : null,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(it['txt'], style: TextStyle(color: ok ? (_isDark ? Colors.white : Colors.black) : Colors.grey, fontWeight: FontWeight.bold))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHUD() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xD80F172A) : Colors.white.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: _scen > 0 ? () { _playClick(); _gotoScenario(_scen - 1); } : null,
            icon: const Icon(Icons.chevron_left),
            label: Text(t('prev')),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            child: Text(t('submit').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: _scen < 2 ? () { _playClick(); _gotoScenario(_scen + 1); } : null,
            icon: const Icon(Icons.chevron_right),
            label: Text(t('next')),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
          const SizedBox(width: 24),
          TextButton.icon(
            onPressed: _res.every((r) => r) || _diags[_scen] != null ? () { _playClick(); setState(() => _showReport = true); } : null,
            icon: const Icon(Icons.bar_chart),
            label: Text(t('report')),
            style: TextButton.styleFrom(foregroundColor: _res.every((r) => r) || _diags[_scen] != null ? Colors.amber : Colors.grey.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildReportModal() {
    bool all = _res.every((r) => r);
    var diag = _diags[_scen];
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: _isDark ? const Color(0xFF0F172A) : Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: all ? Colors.green : Colors.amber, width: 2)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(all ? Icons.check_circle : Icons.warning_amber_rounded, color: all ? Colors.green : Colors.amber, size: 64),
              const SizedBox(height: 16),
              Text(all ? t('rep_success_title') : t('rep_prog_title'), style: TextStyle(color: all ? Colors.green : Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(all ? t('rep_success_sub') : t('rep_prog_sub'), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              
              if (diag != null) ...[
                const SizedBox(height: 24),
                if ((diag['str'] as List).isNotEmpty) ...[
                  const Align(alignment: Alignment.centerLeft, child: Text('STRENGTHS', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 12))),
                  const SizedBox(height: 8),
                  ...((diag['str'] as List).map((s) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle, color: Colors.green, size: 16), const SizedBox(width: 8), Expanded(child: Text(s, style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 13)))])))),
                  const SizedBox(height: 16),
                ],
                if (!all && (diag['imp'] as List).isNotEmpty) ...[
                  Align(alignment: Alignment.centerLeft, child: Text(t('rep_improve').toUpperCase(), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 12))),
                  const SizedBox(height: 8),
                  ...((diag['imp'] as List).map((s) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.arrow_forward, color: Colors.amber, size: 16), const SizedBox(width: 8), Expanded(child: Text(s, style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 13)))])))),
                ],
                if (all) ...[
                  Align(alignment: Alignment.centerLeft, child: Text(t('rep_improve').toUpperCase(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 12))),
                  const SizedBox(height: 8),
                  Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.arrow_forward, color: Colors.amber, size: 16), const SizedBox(width: 8), Expanded(child: Text('Move on to the next math activity!', style: TextStyle(color: _isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 13)))])),
                ]
              ],

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () { _playClick(); setState(() => _showReport = false); },
                style: ElevatedButton.styleFrom(backgroundColor: _isDark ? const Color(0xFF020617) : Colors.grey.shade200, foregroundColor: _isDark ? Colors.white : Colors.black, minimumSize: const Size(double.infinity, 50)),
                child: Text(t('close_report'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _hardReset,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
                child: Text(t('restart_exp'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Translations
  String t(String key) {
    if (_text[_lang] != null && _text[_lang]!.containsKey(key)) {
      return _text[_lang]![key]!;
    }
    return key;
  }

  final Map<String, Map<String, String>> _text = {
    'en': {
      'app_title': "Cryptarithm Cracker: Digits in Disguise", 
      'app_subtitle': "Class 8 • Number Play — Digits in Disguise",
      'start_mission': "Start Mission", 'teacher_board': "Teacher Board",
      'scenario': "Scenario", 'mission_obj': "Mission Objective", 'inst_seq': "Instruction Sequence",
      'hint_ev': "Hint / Evidence", 'learnt_conc': "Learnt Conclusion", 'get_hint': "Get Hint",
      'close_report': "Close Report", 'restart_exp': "Restart Exploration",
      'prev': "Prev", 'next': "Next", 'submit': "Submit", 'report': "Report",
      'scen_1': "Scenario 1 · PQ × 8 = RS", 'scen_2': "Scenario 2 · GH × H = 9K", 'scen_3': "Scenario 3 · BYE × 6 = RAY",
      'global_mission': "Every letter hides a single digit. Crack three multiplication puzzles — PQ×8=RS, GH×H=9K, and BYE×6=RAY — so the arithmetic comes out true, with distinct letters = distinct digits and no leading zero. Reason with size bounds and units digits, then Submit.",
      'learnt_text': "A cryptarithm is cracked by reasoning, not guessing: size bounds, units-digit logic, and the distinct-digit / no-leading-zero rules squeeze the letters down to one solution.",
      
      'rep_success_title': "Cryptarithm Cracked!", 'rep_success_sub': "Every letter is decoded and the arithmetic checks out.",
      'rep_prog_title': "Not Yet — Keep Cracking", 'rep_prog_sub': "Some constraints still fail. Your assignment is preserved — adjust and resubmit.",
      'rep_str1': "You reasoned all the way to a full valid assignment.", 'rep_imp1': "Keep testing candidate digits against every constraint before submitting.",
      'rep_str2': "You assigned a digit to every letter in the puzzle.", 'rep_imp2': "Make sure every letter has a digit before you submit.",
      'rep_str3': "Your recomputed product matched the puzzle exactly.", 'rep_imp3': "Recheck the multiplication — the product must match the letters.",
      'rep_str4': "You honoured the distinct-digit and no-leading-zero rules.", 'rep_imp4': "Remember: distinct letters need distinct digits and no leading digit is 0.",
      'rep_strengths': "Strengths", 'rep_improve': "Next Steps",

      's1_1': "A 2-digit number × 8 must stay 2-digit, so how big can PQ be?", 's1_2': "Tap a letter, then a digit, to build PQ and RS.", 's1_3': "Press Submit to check PQ × 8 = RS with all digits distinct.",
      's2_1': "Read the seven candidate product lines.", 's2_2': "GH × H means the second factor equals the units digit of GH.", 's2_3': "Pick the line that is in the 90s with distinct digits.",
      's3_1': "If B ≥ 2 then BYE × 6 > 1200 — too big. So B = 1.", 's3_2': "The units digit Y = (E × 6) mod 10 is even; keep Y even and < 7.", 's3_3': "Assign every letter, then Submit to check BYE × 6 = RAY.",
      
      'h_1a': "A 2-digit number times 8 stays below 100 only when the number is at most 12.", 'h_1b': "Try PQ = 12. Then 12 × 8 = 96, so R = 9 and S = 6.", 'h_1c': "Check the four digits 1, 2, 9, 6 are all different — they are.",
      'h_2a': "GH × H uses the units digit of GH as the multiplier.", 'h_2b': "24 × 4 = 96 fits: 4 is the units digit of 24, and 96 is a 9K number.", 'h_2c': "16 × 6 = 96 also lands in the 90s, but the digit 6 repeats — so it is not allowed.",
      'h_3a': "If B is 2 or more, BYE × 6 is at least 1200 — a 4-digit answer. So B must be 1.", 'h_3b': "The units digit of the product equals (E × 6) mod 10, which is always even. That digit is Y, so Y is even.", 'h_3c': "With B = 1, search: 105 × 6 = 630 gives Y = 0, R = 6, A = 3 — all digits distinct.",

      'ui_decodel': "Letters to Decode", 'ui_taplet': "tap a letter, then tap a digit", 'ui_dkeypad': "Digit Keypad",
      'ui_sel_let:': "Select a letter first.", 'ui_optc': "Choose the Valid Line", 'ui_cclist': "Constraint Checklist",
      'ui_c_ans': "Chosen:", 'ui_live': "Live:", 'ui_yr_ans': "your", 'ui_tap_d': "Active letter: {0} — tap a digit to assign.",
      'ui_clear': "Clear", 'ui_units': "units of {0} is {1}", 'ui_scen_cleared': "Scenario Cleared! Move to next.",
      'c_s1_1': "All letters assigned ({0}/{1})", 'c_s1_2': "Distinct letters use distinct digits", 'c_s1_3': "No leading digit is 0", 'c_s1_4': "PQ × 8 equals RS",
      'c_s3_1': "BYE × 6 equals RAY", 'c_s3_2': "B = 1 (else product > 1200)", 'c_s3_3': "Y is even and < 7",
      'c_s2_1': "A candidate line is selected", 'c_s2_2': "Second factor = units digit of GH", 'c_s2_3': "Product is a 9K number (90–99)", 'c_s2_4': "Digits G, H, K all distinct",
      'ui_sel_let': 'Select a letter first'
    },
    'hi': {
      'app_title': "क्रिप्टैरिथ्म क्रैकर: भेस में अंक", 
      'app_subtitle': "कक्षा 8 • संख्या खेल — भेस में अंक",
      'start_mission': "मिशन शुरू करें", 'teacher_board': "शिक्षक बोर्ड",
      'scenario': "परिदृश्य", 'mission_obj': "मिशन का उद्देश्य", 'inst_seq': "निर्देश क्रम",
      'hint_ev': "संकेत / साक्ष्य", 'learnt_conc': "सीखा हुआ निष्कर्ष", 'get_hint': "संकेत प्राप्त करें",
      'close_report': "रिपोर्ट बंद करें", 'restart_exp': "पुनः प्रारंभ करें",
      'prev': "पिछला", 'next': "अगला", 'submit': "सबमिट", 'report': "रिपोर्ट",
      'scen_1': "परिदृश्य 1 · PQ × 8 = RS", 'scen_2': "परिदृश्य 2 · GH × H = 9K", 'scen_3': "परिदृश्य 3 · BYE × 6 = RAY",
      'global_mission': "प्रत्येक अक्षर एक अंक छिपाता है। तीन गुणा पहेलियाँ हल करें — PQ×8=RS, GH×H=9K, और BYE×6=RAY — ताकि अंकगणित सही निकले, जहाँ अलग-अलग अक्षर = अलग-अलग अंक और कोई भी अंक 0 से शुरू न हो। आकार की सीमाओं और इकाई के अंकों के साथ तर्क करें, फिर सबमिट करें।",
      'learnt_text': "क्रिप्टैरिथ्म तर्क से हल किया जाता है, अनुमान से नहीं: आकार की सीमाएं, इकाई-अंक का तर्क, और अलग-अंक / कोई-अग्रणी-शून्य-नहीं के नियम अक्षरों को एक समाधान तक ले जाते हैं।",
      
      'rep_success_title': "क्रिप्टैरिथ्म हल हो गया!", 'rep_success_sub': "प्रत्येक अक्षर डिकोड हो गया है और अंकगणित सही है।",
      'rep_prog_title': "अभी नहीं — हल करते रहें", 'rep_prog_sub': "कुछ नियम अभी भी विफल हैं। आपका कार्य सुरक्षित है — समायोजित करें और पुनः सबमिट करें।",
      'rep_str1': "आपने एक पूर्ण वैध असाइनमेंट तक तर्क किया।", 'rep_imp1': "सबमिट करने से पहले प्रत्येक नियम के खिलाफ अंकों का परीक्षण करते रहें।",
      'rep_str2': "आपने पहेली में हर अक्षर को एक अंक सौंपा है।", 'rep_imp2': "सबमिट करने से पहले सुनिश्चित करें कि प्रत्येक अक्षर में एक अंक है।",
      'rep_str3': "आपका पुनर्गणना उत्पाद पहेली से बिल्कुल मेल खाता है।", 'rep_imp3': "गुणा की दोबारा जांच करें — उत्पाद अक्षरों से मेल खाना चाहिए।",
      'rep_str4': "आपने विशिष्ट-अंक और कोई-अग्रणी-शून्य-नहीं नियमों का सम्मान किया।", 'rep_imp4': "याद रखें: अलग-अलग अक्षरों को अलग-अलग अंकों की आवश्यकता होती है और कोई भी अग्रणी अंक 0 नहीं होता है।",
      'rep_strengths': "मजबूती", 'rep_improve': "अगले कदम",

      's1_1': "2-अंकीय संख्या × 8 को 2-अंकीय रहना चाहिए, तो PQ कितना बड़ा हो सकता है?", 's1_2': "PQ और RS बनाने के लिए एक अक्षर पर टैप करें, फिर एक अंक पर टैप करें।", 's1_3': "सभी अंकों को अलग-अलग रखकर PQ × 8 = RS जांचने के लिए सबमिट दबाएं।",
      's2_1': "सात संभावित उत्पाद पंक्तियों को पढ़ें।", 's2_2:': "GH × H का अर्थ है दूसरा कारक GH के इकाई अंक के बराबर है।", 's2_3': "वह पंक्ति चुनें जो अलग-अलग अंकों के साथ 90 के दशक में हो।",
      's3_1': "यदि B ≥ 2 है तो BYE × 6 > 1200 — बहुत बड़ा। तो B = 1.", 's3_2': "इकाई अंक Y = (E × 6) mod 10 सम है; Y को सम और < 7 रखें।", 's3_3': "प्रत्येक अक्षर निर्दिष्ट करें, फिर BYE × 6 = RAY जांचने के लिए सबमिट दबाएं।",
      
      'h_1a': "2-अंकीय संख्या को 8 से गुणा करने पर वह 100 से कम तभी रहती है जब संख्या अधिकतम 12 हो।", 'h_1b': "PQ = 12 का प्रयास करें। फिर 12 × 8 = 96, तो R = 9 और S = 6.", 'h_1c': "जांचें कि चारों अंक 1, 2, 9, 6 सभी अलग हैं — वे हैं।",
      'h_2a': "GH × H गुणक के रूप में GH के इकाई अंक का उपयोग करता है।", 'h_2b': "24 × 4 = 96 फिट बैठता है: 4, 24 का इकाई अंक है, और 96 एक 9K संख्या है।", 'h_2c': "16 × 6 = 96 भी 90 के दशक में आता है, लेकिन अंक 6 दोहराता है — इसलिए इसकी अनुमति नहीं है।",
      'h_3a': "यदि B, 2 या अधिक है, तो BYE × 6 कम से कम 1200 है — 4-अंकीय उत्तर। तो B, 1 होना चाहिए।", 'h_3b': "उत्पाद का इकाई अंक (E × 6) mod 10 के बराबर है, जो हमेशा सम होता है। वह अंक Y है, तो Y सम है।", 'h_3c': "B = 1 के साथ, खोजें: 105 × 6 = 630 Y = 0, R = 6, A = 3 देता है — सभी अंक अलग हैं।",

      'ui_decodel': "डिकोड करने के लिए अक्षर", 'ui_taplet': "अक्षर पर टैप करें, फिर एक अंक पर टैप करें", 'ui_dkeypad': "अंक कीपैड",
      'ui_sel_let': "पहले एक अक्षर चुनें।", 'ui_optc': "वैध पंक्ति चुनें", 'ui_cclist': "बाधा चेकलिस्ट",
      'ui_c_ans': "चुना गया:", 'ui_live': "लाइव:", 'ui_yr_ans': "आपका", 'ui_tap_d': "सक्रिय अक्षर: {0} — असाइन करने के लिए एक अंक पर टैप करें।",
      'ui_clear': "स्पष्ट", 'ui_units': "{0} की इकाई {1} है", 'ui_scen_cleared': "परिदृश्य साफ़ किया गया! अगले पर जाएं।",
      'c_s1_1': "सभी अक्षर निर्दिष्ट ({0}/{1})", 'c_s1_2': "अलग-अलग अक्षर अलग-अलग अंकों का उपयोग करते हैं", 'c_s1_3': "कोई भी अग्रणी अंक 0 नहीं है", 'c_s1_4': "PQ × 8, RS के बराबर है",
      'c_s3_1': "BYE × 6, RAY के बराबर है", 'c_s3_2': "B = 1 (अन्यथा उत्पाद > 1200)", 'c_s3_3': "Y सम है और < 7",
      'c_s2_1': "एक उम्मीदवार पंक्ति का चयन किया गया है", 'c_s2_2': "दूसरा कारक = GH का इकाई अंक", 'c_s2_3': "उत्पाद 9K संख्या (90-99) है", 'c_s2_4': "अंक G, H, K सभी अलग हैं"
    }
  };
}
