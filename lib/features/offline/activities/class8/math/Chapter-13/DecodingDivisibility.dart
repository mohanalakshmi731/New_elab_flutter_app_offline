// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class DecodingDivisibility extends StatefulWidget {
  const DecodingDivisibility({super.key});

  @override
  State<DecodingDivisibility> createState() => _DecodingDivisibilityState();
}

class _DecodingDivisibilityState extends State<DecodingDivisibility> {
  // --- UI State ---
  bool _showShutter = true;
  bool _isSidebarOpen = true;
  String _currentLang = 'en';
  bool _isCompleted = false;

  // --- Scenario State ---
  int _currentStep = 0;

  // --- Audio ---
  final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _curtainPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class8/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class8/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class8/mixkit_955.mp3';
  static const String _curtainUrl = 'audio/class8/mixkit_2574.mp3';


  List<int> _digits = [3, 4, 6];
  int _changeCount = 0;
  
  // Step 1 specific
  bool _splitDone = false;
  List<int>? _splitSnapshotDigits;

  // Step 2 & 5 specific
  bool _reversedDone = false;
  bool _resultDone = false;
  
  // Step 3 specific
  List<Map<String, int>> _trials = [];
  
  // Step 4 specific
  List<Map<String, int>> _sumTrials = [];
  int _pairIndex = 0;
  final List<List<int>> _sum11Pairs = [
    [3, 1],
    [2, 8],
    [1, 2],
  ];

  // Step 5 specific
  bool _cyclic1Done = false;
  bool _cyclic2Done = false;
  List<int>? _resultSnapshotDigits;

  // Step 6 specific
  bool _repeatDone = false;
  bool _div7Done = false;
  bool _div11Done = false;
  bool _div13Done = false;
  List<int>? _chainSnapshotDigits;

  // --- Constants ---
  final Color _bgDark = const Color(0xFF020617);
  final Color _panelDark = const Color(0xFF1E293B);
  final Color _accentCyan = const Color(0xFF06B6D4);
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _loadStep(0);
    _curtainPlayer.play(AssetSource(_curtainUrl));
  }

  @override
  void dispose() {
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _curtainPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  // --- Math Utilities ---
  int _digitsToNumber(List<int> d) => int.parse(d.join(''));

  Map<String, dynamic> _unitsDigitTest(List<int> d, int div) {
    int num = _digitsToNumber(d);
    int u = d.last;
    return {
      'numRem': num % div,
      'unitRem': u % div,
      'matches': (num % div) == (u % div),
    };
  }

  Map<String, dynamic> _decomposePlaceValue3(List<int> d) {
    int num = _digitsToNumber(d);
    int h99 = d[0] * 99;
    int t9 = d[1] * 9;
    int remBlock = d[0] + d[1] + d[2];
    int digitSum = remBlock;
    return {
      'number': num,
      'ninetyNineH': h99,
      'nineT': t9,
      'remainderBlock': remBlock,
      'digitSum': digitSum,
      'reconstructs': (h99 + t9 + remBlock) == num,
      'check9': (num % 9) == (digitSum % 9),
      'check3': (num % 3) == (digitSum % 3),
    };
  }

  Map<String, dynamic> _reverseDiffTrick(List<int> d) {
    int orig = _digitsToNumber(d);
    int rev = _digitsToNumber(d.reversed.toList());
    int diff = (orig - rev).abs();
    int quotient = diff ~/ 9;
    int rem = diff % 9;
    return {
      'original': orig,
      'reversed': rev,
      'difference': diff,
      'quotient': quotient,
      'remainder': rem,
      'isExactlyDivisible': rem == 0,
      'digitSumRelationHolds': quotient == (d[0] - d.last).abs(),
    };
  }

  Map<String, dynamic> _reverseSumTrick(List<int> d) {
    int orig = _digitsToNumber(d);
    int rev = _digitsToNumber(d.reversed.toList());
    int sum = orig + rev;
    int quotient = sum ~/ 11;
    int rem = sum % 11;
    return {
      'original': orig,
      'reversed': rev,
      'sum': sum,
      'quotient': quotient,
      'remainder': rem,
      'isExactlyDivisible': rem == 0,
      'relationHolds': quotient == (d[0] + d.last),
    };
  }

  Map<String, dynamic> _cyclicSumTrick(List<int> d) {
    int orig = _digitsToNumber(d);
    List<int> p1 = [d[1], d[2], d[0]];
    List<int> p2 = [d[2], d[0], d[1]];
    int n1 = _digitsToNumber(p1);
    int n2 = _digitsToNumber(p2);
    int sum = orig + n1 + n2;
    return {
      'original': orig,
      'p1': p1,
      'p2': p2,
      'n1': n1,
      'n2': n2,
      'cyclicSum': sum,
      'divisibleBy37': sum % 37 == 0,
    };
  }

  Map<String, dynamic> _repeatDivisionChain(List<int> d) {
    int orig = _digitsToNumber(d);
    List<int> rep = [...d, ...d];
    int repNum = _digitsToNumber(rep);
    List<Map<String, int>> chain = [];
    int val = repNum;
    for (int div in [7, 11, 13]) {
      int q = val ~/ div;
      int r = val % div;
      chain.add({'divisor': div, 'quotient': q, 'remainder': r});
      val = q;
    }
    return {
      'original': orig,
      'repeated': rep,
      'repeatedNumber': repNum,
      'chain': chain,
    };
  }

  // --- Step Management ---
  void _loadStep(int index) {
    setState(() {
      _currentStep = index;
      _changeCount = 0;
      switch (index) {
        case 0: _digits = [3, 4, 6]; break;
        case 1:
          _digits = [2, 5, 9];
          _splitDone = false;
          _splitSnapshotDigits = null;
          break;
        case 2:
          _digits = [0, 0];
          _reversedDone = false;
          _resultDone = false;
          break;
        case 3:
          _digits = [8, 3];
          _trials = [];
          break;
        case 4:
          _pairIndex = 0;
          _digits = List.from(_sum11Pairs[0]);
          _sumTrials = [];
          break;
        case 5:
          _digits = [1, 2, 3];
          _cyclic1Done = false;
          _cyclic2Done = false;
          _resultDone = false;
          break;
        case 6:
          _digits = [1, 2, 3];
          _repeatDone = false;
          _div7Done = false;
          _div11Done = false;
          _div13Done = false;
          break;
      }
    });
  }

  void _adjustDigit(int idx, int delta, int minVal) {
    setState(() {
      int next = _digits[idx] + delta;
      if (next > 9) next = 9;
      if (next < minVal) next = minVal;
      _digits[idx] = next;
      _changeCount++;
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent, duration: const Duration(seconds: 2)),
    );
  }
  
  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green, duration: const Duration(seconds: 2)),
    );
  }

  void _verifyStep() {
    var t = _i18n[_currentLang]!;
    bool isCorrect = false;
    String failMsg = "";

    switch (_currentStep) {
      case 0:
        var u2 = _unitsDigitTest(_digits, 2);
        var u5 = _unitsDigitTest(_digits, 5);
        var u10 = _unitsDigitTest(_digits, 10);
        if (_changeCount < 2) { failMsg = t['msgNeedMoreTests']; break; }
        isCorrect = _digits[0] >= 1 && u2['matches'] && u5['matches'] && u10['matches'];
        failMsg = t['msgNeedMoreTests'];
        break;
      case 1:
        if (!_splitDone) { failMsg = t['msgNeedSplit']; break; }
        if (_splitSnapshotDigits?.join() != _digits.join()) { failMsg = t['msgSplitStale']; break; }
        if (_changeCount < 1) { failMsg = t['msgNeedChangeFirst']; break; }
        var r = _decomposePlaceValue3(_digits);
        isCorrect = _digits[0] >= 1 && r['reconstructs'] && r['check9'] && r['check3'];
        failMsg = t['msgNeedChangeFirst'];
        break;
      case 2:
        if (_digits[0] != 4 || _digits[1] != 7) { failMsg = t['msgNeedTarget47']; break; }
        if (!_reversedDone) { failMsg = t['msgNeedReverse']; break; }
        if (!_resultDone) { failMsg = t['msgNeedDivideBoth']; break; }
        var r2 = _reverseDiffTrick(_digits);
        isCorrect = r2['original'] == 47 && r2['reversed'] == 74 && r2['difference'] == 27 && r2['quotient'] == 3 && r2['remainder'] == 0;
        failMsg = t['msgNeedDivideBoth'];
        break;
      case 3:
        if (_trials.length < 3) { failMsg = t['msgNeedThreeTrials']; break; }
        Set<String> seen = {};
        bool allOk = true;
        for (var tr in _trials) {
          int a = tr['a']!;
          int b = tr['b']!;
          String key = "${min(a,b)}-${max(a,b)}";
          if (seen.contains(key) || a == b) allOk = false;
          seen.add(key);
          var rr = _reverseDiffTrick([a, b]);
          if (!rr['isExactlyDivisible'] || !rr['digitSumRelationHolds']) allOk = false;
        }
        isCorrect = allOk && seen.length >= 3;
        failMsg = t['msgNeedDistinctTrial'];
        break;
      case 4:
        if (_sumTrials.length < 3) { failMsg = t['msgNeedAllThreeSum']; break; }
        var expected = [{'sum': 44, 'q': 4}, {'sum': 110, 'q': 10}, {'sum': 33, 'q': 3}];
        bool allOk4 = true;
        for (int i = 0; i < _sumTrials.length; i++) {
          var rr = _reverseSumTrick([_sumTrials[i]['a']!, _sumTrials[i]['b']!]);
          if (!rr['isExactlyDivisible'] || !rr['relationHolds']) allOk4 = false;
          if (i < expected.length && (rr['sum'] != expected[i]['sum'] || rr['quotient'] != expected[i]['q'])) allOk4 = false;
        }
        isCorrect = allOk4;
        failMsg = t['msgNeedAllThreeSum'];
        break;
      case 5:
        if (!_resultDone || _resultSnapshotDigits?.join() != _digits.join()) { failMsg = t['msgNeedCheck37']; break; }
        if (_digits[0] < 1) { failMsg = t['msgNeedValidNumber']; break; }
        var r5 = _cyclicSumTrick(_digits);
        isCorrect = r5['divisibleBy37'] == true;
        failMsg = "Check cyclic sum logic.";
        break;
      case 6:
        if (!_div13Done || _chainSnapshotDigits?.join() != _digits.join()) { failMsg = t['msgStaleChain']; break; }
        var chain = _repeatDivisionChain(_digits);
        isCorrect = chain['chain'][2]['quotient'] == _digitsToNumber(_digits);
        failMsg = "Follow the division steps.";
        break;
    }

    if (isCorrect) {
      _showSuccess(t['msgStep${_currentStep}Ok']);
      _showConclusionPopup(t['msgStep${_currentStep}Ok']);
    } else {
      _showError(failMsg);
    }
  }

  void _showConclusionPopup(String proofText) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: _panelDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 56),
              const SizedBox(height: 16),
              const Text(
                "Proof Completed",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                proofText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _accentCyan),
                onPressed: () {
                  Navigator.pop(ctx);
                  if (_currentStep < 6) {
                    _loadStep(_currentStep + 1);
                  } else {
                    setState(() => _isCompleted = true);
                  }
                },
                child: const Text("PROCEED", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    if (_showShutter) return _buildShutter();
    if (_isCompleted) return _buildFinalScreen();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: _bgDark,
        body: Stack(
          children: [
            // 1. Canvas Layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 340 : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: _buildCanvasArea(),
            ),

            // 2. Sidebar Layer (Sliding from Left)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -340,
              top: 0,
              bottom: 0,
              width: 340,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.95),
                  border: const Border(right: BorderSide(color: Color(0xFF334155), width: 1)),
                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5)],
                ),
                child: _buildSidebarContent(),
              ),
            ),

            // 3. Floating Toggle Button (Attached to Sidebar Right Edge)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 340 : 0,
              top: 0,
              child: GestureDetector(
                onTap: () {
                  _clickPlayer.play(AssetSource(_clickUrl));
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    border: Border.all(color: const Color(0xFF334155)),
                    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(15)),
                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                  ),
                  child: Icon(
                    _isSidebarOpen ? Icons.chevron_left : Icons.chevron_right,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShutter() {
    var t = _i18n[_currentLang]!;
    return Scaffold(
      backgroundColor: _bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.percent, size: 80, color: _accentCyan),
            const SizedBox(height: 24),
            Text(t['appTitle'], style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
              child: Text(t['tagline'], style: TextStyle(color: _accentCyan, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: Text(t['initBtn'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                _clickPlayer.play(AssetSource(_clickUrl));
                setState(() => _showShutter = false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalScreen() {
    var t = _i18n[_currentLang]!;
    return Scaffold(
      backgroundColor: _bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
            const SizedBox(height: 24),
            Text(t['msgMissionComplete'], style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(t['finalSubtitle'], style: const TextStyle(color: Colors.white70, fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("RESTART", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () {
                setState(() => _isCompleted = false);
                _loadStep(0);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarContent() {
    var t = _i18n[_currentLang]!;
    var stepData = t['steps'][_currentStep];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Title & Controls
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.cyan, Colors.blue]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.percent, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['appTitle'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        Text(t['tagline'], style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ToggleButtons(
                    isSelected: [_currentLang == 'en', _currentLang == 'hi'],
                    onPressed: (index) {
                      _clickPlayer.play(AssetSource(_clickUrl));
                      setState(() => _currentLang = index == 0 ? 'en' : 'hi');
                    },
                    borderRadius: BorderRadius.circular(8),
                    fillColor: Colors.cyan.withOpacity(0.2),
                    selectedColor: Colors.cyanAccent,
                    color: Colors.white54,
                    constraints: const BoxConstraints(minWidth: 50, minHeight: 30),
                    children: const [
                      Text("EN", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("HI", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
                    onPressed: () {
                      _clickPlayer.play(AssetSource(_clickUrl));
                      setState(() {
                        _currentLang = 'en';
                        _currentStep = 0;
                        _isCompleted = false;
                        _showShutter = true;
                        _loadStep(0);
                        _curtainPlayer.play(AssetSource(_curtainUrl));
                      });
                    },
                    tooltip: "Reset All",
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF334155), height: 1),
              const SizedBox(height: 20),

              // Objective
              Text(t['objLabel'].toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                child: Text(t['objDesc'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ),
              const SizedBox(height: 16),
              
              // Current Step
              Text(t['stepInfoLabel'].toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stepData['title'], style: TextStyle(color: _accentCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(stepData['instruction'], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Readouts
              Text(t['dataReadouts'].toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                child: _buildSidebarReadouts(),
              ),
              const SizedBox(height: 16),

              // Dynamic Controls
              _buildControlPanel(),
            ],
          ),
        ),
        // Footer inside sidebar
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFF334155), width: 1)),
          ),
          child: Text(
            "© ZeroScienceLab - Fall in love with math and Science",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
          ),
        ),
      ],
    );
  }

  // --- Step Content Components ---
  
  Widget _buildSidebarReadouts() {
    var t = _i18n[_currentLang]!;
    List<Widget> rows = [];
    
    Widget buildRow(String label, String value, [Color valColor = Colors.cyanAccent]) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold))),
            Text(value, style: TextStyle(color: valColor, fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    if (_currentStep == 0) {
      var u2 = _unitsDigitTest(_digits, 2);
      var u5 = _unitsDigitTest(_digits, 5);
      var u10 = _unitsDigitTest(_digits, 10);
      rows.add(buildRow(t['numberLabel'], '${_digitsToNumber(_digits)}'));
      rows.add(buildRow(t['unitsLabel'], '${_digits.last}', Colors.amber));
      rows.add(buildRow(t['div2Label'], 'n%2=${u2['numRem']}, u%2=${u2['unitRem']}'));
      rows.add(buildRow(t['div5Label'], 'n%5=${u5['numRem']}, u%5=${u5['unitRem']}'));
      rows.add(buildRow(t['div10Label'], 'n%10=${u10['numRem']}, u%10=${u10['unitRem']}'));
    } 
    else if (_currentStep == 1) {
      var r = _decomposePlaceValue3(_digits);
      rows.add(buildRow(t['numberLabel'], '${r['number']}'));
      rows.add(buildRow(t['digitSumLabel'], '${r['digitSum']}', Colors.amber));
    }
    else if (_currentStep == 2) {
      var r = _reverseDiffTrick(_digits);
      rows.add(buildRow(t['numberLabel'], '${r['original']}'));
    }
    else if (_currentStep == 3) {
      var r = _reverseDiffTrick(_digits);
      rows.add(buildRow(t['differenceLabel'], '${r['difference']}'));
      rows.add(buildRow(t['quotientLabel'], '${r['quotient']}', Colors.amber));
    }
    else if (_currentStep == 4) {
      var r = _reverseSumTrick(_digits);
      rows.add(buildRow(t['sumLabel'], '${r['sum']}'));
      rows.add(buildRow(t['quotientLabel'], '${r['quotient']}', Colors.amber));
    }
    else if (_currentStep == 5) {
      var r = _cyclicSumTrick(_digits);
      rows.add(buildRow("abc", '${r['original']}'));
    }
    else if (_currentStep == 6) {
      var chain = _repeatDivisionChain(_digits);
      rows.add(buildRow("abc", '${chain['original']}'));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }

  Widget _buildControlPanel() {
    var t = _i18n[_currentLang]!;
    List<Widget> controls = [];
    
    Widget buildStepper(String label, int index, int minVal) {
      return Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white70, size: 24),
                onPressed: () => _adjustDigit(index, -1, minVal),
              ),
              Container(
                width: 24,
                alignment: Alignment.center,
                child: Text('${_digits[index]}', style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.add_circle_outline, color: Colors.white70, size: 24),
                onPressed: () => _adjustDigit(index, 1, minVal),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label.split(" ")[0], style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      );
    }
    
    Widget buildActionBtn(String label, bool isDone, bool isDisabled, VoidCallback onTapped) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDone ? Colors.green.shade800 : _panelDark,
            side: BorderSide(color: isDone ? Colors.greenAccent : Colors.white24),
            disabledBackgroundColor: Colors.black26,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: isDisabled ? null : onTapped,
          child: Text(label, style: TextStyle(color: isDone ? Colors.greenAccent : Colors.white, fontSize: 12)),
        ),
      );
    }

    // Tools based on step
    if (_currentStep == 0) {
      controls.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        buildStepper(t['hLabel'], 0, 1),
        buildStepper(t['tLabel'], 1, 0),
        buildStepper(t['uLabel'], 2, 0),
      ]));
      controls.add(Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text("Changes: $_changeCount (need >= 2)", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white30, fontSize: 11)),
      ));
    }
    else if (_currentStep == 1) {
      controls.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        buildStepper(t['hLabel'], 0, 1),
        buildStepper(t['tLabel'], 1, 0),
        buildStepper(t['uLabel'], 2, 0),
      ]));
      controls.add(const SizedBox(height: 12));
      controls.add(buildActionBtn(t['btnSplit'], _splitDone, false, () {
        _successPlayer.play(AssetSource(_successUrl));
        setState(() {
          _splitDone = true;
          _splitSnapshotDigits = List.from(_digits);
        });
      }));
    }
    else if (_currentStep == 2) {
      controls.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        buildStepper(t['aLabel'], 0, 0),
        buildStepper(t['bLabel'], 1, 0),
      ]));
      controls.add(const SizedBox(height: 12));
      controls.add(buildActionBtn(t['btnReverse'], _reversedDone, false, () => setState(() => _reversedDone = true)));
      controls.add(buildActionBtn(t['btnDivideBy9'], _resultDone, !_reversedDone, () {
        _successPlayer.play(AssetSource(_successUrl));
        setState(() {
          _resultDone = true;
        });
      }));
    }
    else if (_currentStep == 3) {
      controls.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        buildStepper(t['aLabel'], 0, 0),
        buildStepper(t['bLabel'], 1, 0),
      ]));
      controls.add(const SizedBox(height: 12));
      controls.add(buildActionBtn(t['btnLogTrial'], false, false, () {
        int a = _digits[0], b = _digits[1];
        if (a == b) { _showError(t['msgNeedDistinctTrial']); return; }
        String key = "${min(a,b)}-${max(a,b)}";
        if (_trials.any((tr) => "${min(tr['a']!, tr['b']!)}-${max(tr['a']!, tr['b']!)}" == key)) {
          _errorPlayer.play(AssetSource(_errorUrl));
          _showError(t['msgNeedDistinctTrial']); return;
        }
        _successPlayer.play(AssetSource(_successUrl));
        setState(() {
          _trials.add({'a': a, 'b': b});
          _showSuccess(t['msgTrialLogged']);
        });
      }));
      if (_trials.isNotEmpty) {
        controls.add(Wrap(
          spacing: 4, runSpacing: 4,
          children: _trials.map((tr) => Chip(
            backgroundColor: _panelDark,
            side: const BorderSide(color: Colors.cyanAccent),
            label: Text("${tr['a']},${tr['b']}", style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
          )).toList(),
        ));
      }
    }
    else if (_currentStep == 4) {
      var req = _sum11Pairs[min(_pairIndex, 2)];
      controls.add(Text("Target trial ${min(_pairIndex + 1, 3)}/3: set to ${req[0]}${req[1]}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.amberAccent, fontSize: 11)));
      controls.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        buildStepper(t['aLabel'], 0, 0),
        buildStepper(t['bLabel'], 1, 0),
      ]));
      controls.add(const SizedBox(height: 12));
      controls.add(buildActionBtn(t['btnLogSumTrial'], false, _sumTrials.length >= 3, () {
        if (_digits[0] != req[0] || _digits[1] != req[1]) {
          _showError(t['msgNeedExactPair']); return;
        }
        _successPlayer.play(AssetSource(_successUrl));
        setState(() {
          _sumTrials.add({'a': req[0], 'b': req[1]});
          _pairIndex = min(_pairIndex + 1, _sum11Pairs.length - 1);
          if (_sumTrials.length < _sum11Pairs.length) {
            _digits = List.from(_sum11Pairs[_pairIndex]);
          }
          _showSuccess(t['msgSumTrialLogged']);
        });
      }));
      if (_sumTrials.isNotEmpty) {
        controls.add(Wrap(
          spacing: 4, runSpacing: 4,
          children: _sumTrials.map((tr) => Chip(
            backgroundColor: _panelDark,
            side: const BorderSide(color: Colors.greenAccent),
            label: Text("${tr['a']},${tr['b']}", style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
          )).toList(),
        ));
      }
    }
    else if (_currentStep == 5) {
      controls.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        buildStepper(t['hLabel'], 0, 1),
        buildStepper(t['tLabel'], 1, 0),
        buildStepper(t['uLabel'], 2, 0),
      ]));
      controls.add(const SizedBox(height: 12));
      controls.add(buildActionBtn(t['btnCyclic1'], _cyclic1Done, false, () => setState(() => _cyclic1Done = true)));
      controls.add(buildActionBtn(t['btnCyclic2'], _cyclic2Done, !_cyclic1Done, () => setState(() => _cyclic2Done = true)));
      controls.add(buildActionBtn(t['btnCheck37'], _resultDone, !(_cyclic1Done && _cyclic2Done), () {
        _successPlayer.play(AssetSource(_successUrl));
        setState(() {
          _resultDone = true;
          _resultSnapshotDigits = List.from(_digits);
        });
      }));
    }
    else if (_currentStep == 6) {
      controls.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        buildStepper(t['hLabel'], 0, 1),
        buildStepper(t['tLabel'], 1, 0),
        buildStepper(t['uLabel'], 2, 0),
      ]));
      controls.add(const SizedBox(height: 12));
      controls.add(buildActionBtn(t['btnRepeat'], _repeatDone, false, () {
        _successPlayer.play(AssetSource(_successUrl));
        setState(() {
          _repeatDone = true;
          _chainSnapshotDigits = List.from(_digits);
          _div7Done = false; _div11Done = false; _div13Done = false;
        });
      }));
      controls.add(Row(children: [
        Expanded(child: buildActionBtn(t['btnDiv7'], _div7Done, !_repeatDone, () => setState(() => _div7Done = true))),
        const SizedBox(width: 8),
        Expanded(child: buildActionBtn(t['btnDiv11'], _div11Done, !_div7Done, () => setState(() => _div11Done = true))),
      ]));
      controls.add(buildActionBtn(t['btnDiv13'], _div13Done, !_div11Done, () => setState(() => _div13Done = true)));
    }

    // Common Verification Button
    controls.add(const SizedBox(height: 16));
    controls.add(ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentCyan,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _verifyStep,
      child: Text(t['steps'][_currentStep]['validateLabel'] ?? "VERIFY", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
    ));
    
    // Prev/Next Nav
    controls.add(const SizedBox(height: 8));
    controls.add(Row(
      children: [
        Expanded(child: TextButton(
          onPressed: _currentStep > 0 ? () => _loadStep(_currentStep - 1) : null,
          child: const Text("Prev", style: TextStyle(color: Colors.white70)),
        )),
        Expanded(child: TextButton(
          onPressed: _currentStep < 6 ? () => _loadStep(_currentStep + 1) : null,
          child: const Text("Next", style: TextStyle(color: Colors.white70)),
        )),
      ],
    ));

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: controls);
  }

  // --- Visuals (2D Tiles) ---
  Widget _buildCanvasArea() {
    return Container(
      color: const Color(0xFF0F172A),
      child: Stack(
        children: [
          // Background grid (decorative)
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: _GridPainter()),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: _buildDynamicScene(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicScene() {
    if (_currentStep == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _build2DDigitRow(_digits, showLabels: true),
          const SizedBox(height: 40),
          _buildEqLabel("Number = ${_digitsToNumber(_digits)}"),
        ],
      );
    }
    else if (_currentStep == 1) {
      var r = _decomposePlaceValue3(_digits);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _build2DDigitRow(_digits, showLabels: true),
          const SizedBox(height: 20),
          _buildEqLabel("Number = ${_digitsToNumber(_digits)}"),
          if (_splitDone) ...[
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(r['ninetyNineH'], "99×h", Colors.purpleAccent),
                const SizedBox(width: 20),
                _buildBar(r['nineT'], "9×t", Colors.indigoAccent),
                const SizedBox(width: 20),
                _buildBar(r['remainderBlock'], "Leftover(h+t+u)", Colors.orangeAccent),
              ],
            )
          ]
        ],
      );
    }
    else if (_currentStep == 2 || _currentStep == 3 || _currentStep == 4) {
      int orig = _digitsToNumber(_digits);
      List<int> revD = _digits.reversed.toList();
      int rev = _digitsToNumber(revD);
      
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _build2DDigitRow(_digits, showLabels: true),
          const SizedBox(height: 20),
          _buildEqLabel("Number = $orig"),
          if ((_currentStep == 2 && _reversedDone) || _currentStep > 2) ...[
            const SizedBox(height: 20),
            const Icon(Icons.swap_vert, color: Colors.white54, size: 32),
            const SizedBox(height: 20),
            _build2DDigitRow(revD, showLabels: false, fallbackColor: Colors.deepPurpleAccent),
            const SizedBox(height: 20),
            _buildEqLabel("Reversed = $rev"),
          ],
          if ((_currentStep == 2 && _resultDone) || _currentStep > 2) ...[
             const SizedBox(height: 20),
             if (_currentStep == 4)
                _buildEqLabel("Sum: $orig + $rev = ${orig + rev}")
             else
                _buildEqLabel("Difference: |$orig - $rev| = ${(orig - rev).abs()}"),
          ]
        ],
      );
    }
    else if (_currentStep == 5) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _build2DDigitRow(_digits, showLabels: true),
          const SizedBox(height: 20),
          _buildEqLabel("abc = ${_digitsToNumber(_digits)}"),
          
          if (_cyclic1Done) ...[
            const SizedBox(height: 20),
            _build2DDigitRow([_digits[1], _digits[2], _digits[0]], showLabels: false, fallbackColor: Colors.deepPurpleAccent),
            const SizedBox(height: 10),
            _buildEqLabel("bca = ${_digitsToNumber([_digits[1], _digits[2], _digits[0]])}"),
          ],
          if (_cyclic2Done) ...[
            const SizedBox(height: 20),
            _build2DDigitRow([_digits[2], _digits[0], _digits[1]], showLabels: false, fallbackColor: Colors.teal),
            const SizedBox(height: 10),
            _buildEqLabel("cab = ${_digitsToNumber([_digits[2], _digits[0], _digits[1]])}"),
          ],
          if (_resultDone) ...[
            const SizedBox(height: 20),
            _buildEqLabel("Cyclic Sum = ${_cyclicSumTrick(_digits)['cyclicSum']}"),
          ]
        ],
      );
    }
    else if (_currentStep == 6) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _build2DDigitRow(_digits, showLabels: true),
          const SizedBox(height: 20),
          _buildEqLabel("abc = ${_digitsToNumber(_digits)}"),
          if (_repeatDone) ...[
            const SizedBox(height: 20),
            _build2DDigitRow([..._digits, ..._digits], showLabels: false, fallbackColor: Colors.deepPurpleAccent),
            const SizedBox(height: 10),
            _buildEqLabel("abcabc = ${_digitsToNumber([..._digits, ..._digits])}"),
          ],
          if (_div7Done) ...[
            const SizedBox(height: 10),
            _buildEqLabel("÷ 7 = ${_digitsToNumber([..._digits, ..._digits]) ~/ 7}"),
          ],
          if (_div11Done) ...[
            const SizedBox(height: 10),
            _buildEqLabel("÷ 11 = ${(_digitsToNumber([..._digits, ..._digits]) ~/ 7) ~/ 11}"),
          ],
          if (_div13Done) ...[
            const SizedBox(height: 10),
            _buildEqLabel("÷ 13 = ${((_digitsToNumber([..._digits, ..._digits]) ~/ 7) ~/ 11) ~/ 13}"),
          ],
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildBar(int val, String label, Color c) {
    double h = max(40.0, min(150.0, val.toDouble() * 1.5));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: h,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c.withOpacity(0.8), c], begin: Alignment.bottomCenter, end: Alignment.topCenter),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: c.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text("$val", style: TextStyle(color: c, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEqLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
    );
  }

  Widget _build2DDigitRow(List<int> digits, {required bool showLabels, Color? fallbackColor}) {
    List<Color> defaultColors = [Colors.purpleAccent, Colors.indigoAccent, Colors.cyanAccent];
    var t = _i18n[_currentLang]!;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(digits.length, (i) {
        Color c = fallbackColor ?? (digits.length == 3 ? defaultColors[i] : defaultColors[i+1]);
        String place = "";
        if (showLabels) {
          if (digits.length == 3) {
            place = [t['hLabel'], t['tLabel'], t['uLabel']][i].split(" ")[0];
          } else {
            place = [t['aLabel'], t['bLabel']][i].split(" ")[0];
          }
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.withOpacity(0.8), width: 2),
                  boxShadow: [
                    BoxShadow(color: c.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Text("${digits[i]}", style: TextStyle(color: c, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
              ),
              if (showLabels) ...[
                const SizedBox(height: 6),
                Text(place, style: TextStyle(color: c.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
              ]
            ],
          ),
        );
      }),
    );
  }

  // --- Dictionary ---
  final Map<String, Map<String, dynamic>> _i18n = {
    'en': {
      'appTitle': "DECODING DIVISIBILITY",
      'tagline': "Class 8 • TALES BY DOTS AND LINES",
      'initBtn': "START MISSION",
      'boardTitle': "Teacher Board",
      'objLabel': "Mission Objective",
      'objDesc': "Explore how expanding numbers by place value mathematically proves common divisibility rules.",
      'stepInfoLabel': "Current Step",
      'dataReadouts': "Data Readouts",
      'msgMissionComplete': "MISSION ACCOMPLISHED",
      'finalSubtitle': "You proved every divisibility trick from place value — nothing was magic.",
      'hLabel': "Hundreds (h)", 'tLabel': "Tens (t)", 'uLabel': "Units (u)", 'aLabel': "Tens (a)", 'bLabel': "Units (b)",
      'numberLabel': "Number", 'unitsLabel': "Units digit", 'div2Label': "÷ 2 test", 'div5Label': "÷ 5 test", 'div10Label': "÷ 10 test",
      'digitSumLabel': "Digit sum", 'differenceLabel': "Difference", 'quotientLabel': "Quotient", 'sumLabel': "Sum",
      'btnSplit': "SPLIT NUMBER: 100h+10t+u", 'btnReverse': "REVERSE DIGITS", 'btnDivideBy9': "DIVIDE DIFFERENCE BY 9",
      'btnLogTrial': "LOG TRIAL", 'btnLogSumTrial': "LOG SUM TRIAL", 'btnCyclic1': "BUILD SHIFT 1", 'btnCyclic2': "BUILD SHIFT 2",
      'btnCheck37': "CHECK ÷ 37", 'btnRepeat': "REPEAT DIGITS", 'btnDiv7': "DIVIDE BY 7", 'btnDiv11': "DIVIDE BY 11", 'btnDiv13': "DIVIDE BY 13",
      'msgNeedMoreTests': "Change the digits at least twice before verifying.",
      'msgNeedSplit': "Press SPLIT NUMBER to break 100h+10t+u into 99h + 9t + (h+t+u) first.",
      'msgNeedChangeFirst': "Try at least one different 3-digit number before splitting.",
      'msgSplitStale': "You changed the digits after splitting. Press SPLIT NUMBER again.",
      'msgNeedTarget47': "Set the digit tiles to exactly 4 and 7 first.",
      'msgNeedReverse': "Press REVERSE THE DIGITS to form 74 from 47.",
      'msgNeedDivideBoth': "Press DIVIDE THE DIFFERENCE BY 9 to complete the example.",
      'msgNeedThreeTrials': "Log at least 3 DIFFERENT 2-digit numbers as trials before verifying.",
      'msgNeedDistinctTrial': "That pair repeats a trial or both digits are equal — try a new pair.",
      'msgTrialLogged': "Trial logged.",
      'msgNeedExactPair': "Set the tiles to exactly this trial's pair before logging it.",
      'msgSumTrialLogged': "Sum trial logged.",
      'msgNeedAllThreeSum': "Log all 3 required trials (31, 28, 12) before verifying.",
      'msgNeedCheck37': "Press CHECK ÷ 37 first.",
      'msgNeedValidNumber': "The hundreds digit can't be 0.",
      'msgStaleChain': "You changed the digits. Repeat and divide again.",
      'msgStep0Ok': "Correct! The units digit alone decides divisibility by 2, 5 and 10.",
      'msgStep1Ok': "Correct! The number and its digit sum always leave the same remainder mod 9 and mod 3.",
      'msgStep2Ok': "Correct! 74 − 47 = 27 = 9 × 3.",
      'msgStep3Ok': "Correct! The quotient equals the digit difference — the rule generalises.",
      'msgStep4Ok': "Correct! All three reverse-and-add trials are exact multiples of 11.",
      'msgStep5Ok': "Correct! The cyclic sum is exactly divisible by 37.",
      'msgStep6Ok': "Correct! abcabc ÷ 7 ÷ 11 ÷ 13 returns your original number exactly.",
      'steps': [
        { 'title': "Step 1/7: Units Digit (÷2, ÷5, ÷10)", 'instruction': "Build any 3-digit number. Watch how the units digit ALONE decides whether the number divides exactly by 2, 5 or 10 — change digits twice, then VERIFY.", 'validateLabel': "VERIFY UNITS RULE" },
        { 'title': "Step 2/7: Split the Number (÷9 and ÷3)", 'instruction': "Change digits once, then press SPLIT NUMBER. The leftover block is the digit sum.", 'validateLabel': "VERIFY THE SPLIT" },
        { 'title': "Step 3/7: Reverse 47 and Divide by 9", 'instruction': "Set tiles to 4 and 7. Press REVERSE to form 74, then DIVIDE THE DIFFERENCE BY 9.", 'validateLabel': "VERIFY 47 → 74 → 27 ÷ 9" },
        { 'title': "Step 4/7: Spot the Quotient Pattern", 'instruction': "Pick a 2-digit number (different digits), reverse it, divide diff by 9, then LOG TRIAL. Repeat 3 times.", 'validateLabel': "VERIFY 3+ TRIALS" },
        { 'title': "Step 5/7: Reverse and ADD (÷ 11)", 'instruction': "Work through the book's three examples in order: 31, then 28, then 12 — set tiles to match and LOG SUM TRIAL.", 'validateLabel': "VERIFY 3 SUM TRIALS" },
        { 'title': "Step 6/7: Cyclic Shuffle (÷ 37)", 'instruction': "Pick ANY 3-digit number. Build its two cyclic shifts, then CHECK ÷ 37.", 'validateLabel': "VERIFY CYCLIC SUM ÷ 37" },
        { 'title': "Step 7/7: The 1001 Magic Trick", 'instruction': "Pick ANY 3-digit number. REPEAT DIGITS to 6 digits, then divide by 7, then 11, then 13.", 'validateLabel': "VERIFY THE 1001 TRICK" },
      ]
    },
    'hi': {
      'appTitle': "विभाज्यता को डिकोड करें",
      'tagline': "कक्षा 8 • बिंदुओं और रेखाओं की कहानियाँ",
      'initBtn': "मिशन शुरू करें",
      'boardTitle': "शिक्षक बोर्ड",
      'objLabel': "मिशन का उद्देश्य",
      'objDesc': "अन्वेषण करें कि स्थानीय मान द्वारा संख्याओं का विस्तार सामान्य विभाज्यता नियमों को गणितीय रूप से कैसे सिद्ध करता है।",
      'stepInfoLabel': "वर्तमान चरण",
      'dataReadouts': "डेटा रीडआउट्स",
      'msgMissionComplete': "मिशन पूरा हुआ",
      'finalSubtitle': "आपने स्थानीय मान से हर विभाज्यता ट्रिक को सिद्ध किया — कुछ भी जादू नहीं था।",
      'hLabel': "सैकड़ा (h)", 'tLabel': "दहाई (t)", 'uLabel': "इकाई (u)", 'aLabel': "दहाई (a)", 'bLabel': "इकाई (b)",
      'numberLabel': "संख्या", 'unitsLabel': "इकाई अंक", 'div2Label': "÷ 2 जांच", 'div5Label': "÷ 5 जांच", 'div10Label': "÷ 10 जांच",
      'digitSumLabel': "अंकों का योग", 'differenceLabel': "अंतर", 'quotientLabel': "भागफल", 'sumLabel': "योग",
      'btnSplit': "संख्या विभाजित करें: 100h+10t+u", 'btnReverse': "अंकों को उलटें", 'btnDivideBy9': "अंतर को 9 से भाग दें",
      'btnLogTrial': "परीक्षण दर्ज करें", 'btnLogSumTrial': "योग परीक्षण दर्ज करें", 'btnCyclic1': "शिफ्ट 1 बनाएं", 'btnCyclic2': "शिफ्ट 2 बनाएं",
      'btnCheck37': "÷ 37 जांचें", 'btnRepeat': "अंक दोहराएं", 'btnDiv7': "7 से भाग दें", 'btnDiv11': "11 से भाग दें", 'btnDiv13': "13 से भाग दें",
      'msgNeedMoreTests': "सत्यापित करने से पहले अंकों को कम से कम दो बार बदलें और देखें कि इकाई-अंक नियम हर बार सही है।",
      'msgNeedSplit': "पहले 100h+10t+u को 99h + 9t + (h+t+u) में तोड़ने के लिए SPLIT NUMBER दबाएं।",
      'msgNeedChangeFirst': "विभाजित करने से पहले कम से कम एक अलग 3-अंकीय संख्या आज़माएं।",
      'msgSplitStale': "आपने विभाजित करने के बाद अंक बदल दिए। फिर से SPLIT NUMBER दबाएं।",
      'msgNeedTarget47': "पहले अंक टाइलों को ठीक 4 और 7 पर सेट करें।",
      'msgNeedReverse': "47 से 74 बनाने के लिए REVERSE DIGITS दबाएं।",
      'msgNeedDivideBoth': "उदाहरण को पूरा करने के लिए DIVIDE DIFFERENCE BY 9 दबाएं।",
      'msgNeedThreeTrials': "सत्यापित करने से पहले कम से कम 3 अलग-अलग 2-अंकीय संख्याओं को परीक्षण के रूप में दर्ज करें।",
      'msgNeedDistinctTrial': "यह जोड़ी एक परीक्षण को दोहराती है या दोनों अंक बराबर हैं — एक नई जोड़ी आज़माएं।",
      'msgTrialLogged': "परीक्षण दर्ज किया गया।",
      'msgNeedExactPair': "इसे दर्ज करने से पहले टाइलों को ठीक इस परीक्षण की जोड़ी पर सेट करें।",
      'msgSumTrialLogged': "योग परीक्षण दर्ज किया गया।",
      'msgNeedAllThreeSum': "सत्यापित करने से पहले सभी 3 आवश्यक परीक्षण (31, 28, 12) दर्ज करें।",
      'msgNeedCheck37': "पहले CHECK ÷ 37 दबाएं।",
      'msgNeedValidNumber': "सैकड़ा अंक 0 नहीं हो सकता।",
      'msgStaleChain': "आपने अंक बदल दिए। फिर से दोहराएं और भाग दें।",
      'msgStep0Ok': "सही! इकाई अंक अकेले 2, 5 और 10 से विभाज्यता तय करता है।",
      'msgStep1Ok': "सही! संख्या और उसके अंकों का योग हमेशा 9 और 3 से भाग देने पर समान शेषफल छोड़ते हैं।",
      'msgStep2Ok': "सही! 74 − 47 = 27 = 9 × 3.",
      'msgStep3Ok': "सही! भागफल अंकों के अंतर के बराबर है — नियम सामान्यीकृत होता है।",
      'msgStep4Ok': "सही! तीनों उलटकर-जोड़ने वाले परीक्षण 11 के ठीक गुणज हैं।",
      'msgStep5Ok': "सही! चक्रीय योग 37 से ठीक विभाज्य है।",
      'msgStep6Ok': "सही! abcabc ÷ 7 ÷ 11 ÷ 13 आपकी मूल संख्या को ठीक वापस लाता है।",
      'steps': [
        { 'title': "चरण 1/7: इकाई अंक (÷2, ÷5, ÷10)", 'instruction': "कोई भी 3-अंकीय संख्या बनाएं। देखें कि कैसे केवल इकाई अंक तय करता है कि संख्या 2, 5 या 10 से पूरी तरह विभाजित होती है या नहीं — अंकों को दो बार बदलें, फिर VERIFY करें।", 'validateLabel': "इकाई नियम सत्यापित करें" },
        { 'title': "चरण 2/7: संख्या को विभाजित करें (÷9 और ÷3)", 'instruction': "अंकों को एक बार बदलें, फिर SPLIT NUMBER दबाएं। बचा हुआ खंड अंकों का योग है, और यह संख्या के 9 और 3 से शेषफल से मेल खाता है।", 'validateLabel': "विभाजन सत्यापित करें" },
        { 'title': "चरण 3/7: 47 को उलटें और 9 से भाग दें", 'instruction': "टाइलों को 4 और 7 पर सेट करें। 74 बनाने के लिए REVERSE दबाएं, फिर 74 − 47 = 27 = 9 × 3 देखने के लिए DIVIDE DIFFERENCE BY 9 दबाएं।", 'validateLabel': "47 → 74 → 27 ÷ 9 सत्यापित करें" },
        { 'title': "चरण 4/7: भागफल पैटर्न खोजें", 'instruction': "दो अलग-अलग अंकों वाली 2-अंकीय संख्या चुनें, उसे उलटें, अंतर को 9 से भाग दें, फिर LOG TRIAL दबाएं। 3 बार दोहराएं।", 'validateLabel': "3+ परीक्षण सत्यापित करें" },
        { 'title': "चरण 5/7: उलटें और जोड़ें (÷ 11)", 'instruction': "किताब के तीन सटीक उदाहरणों को क्रम से हल करें: पहले 31, फिर 28, फिर 12 — प्रत्येक से मेल खाने के लिए टाइलें सेट करें और LOG SUM TRIAL दबाएं।", 'validateLabel': "3 योग परीक्षण सत्यापित करें" },
        { 'title': "चरण 6/7: चक्रीय फेरबदल (÷ 37)", 'instruction': "कोई भी 3-अंकीय संख्या चुनें। इसके दो चक्रीय शिफ्ट बनाएं, फिर CHECK ÷ 37 दबाएं।", 'validateLabel': "चक्रीय योग ÷ 37 सत्यापित करें" },
        { 'title': "चरण 7/7: 1001 का जादुई करतब", 'instruction': "कोई भी 3-अंकीय संख्या चुनें। 6-अंकीय संख्या बनाने के लिए REPEAT DIGITS दबाएं, फिर क्रम से 7, फिर 11, फिर 13 से भाग दें। आप अपनी मूल संख्या पर वापस पहुंचेंगे।", 'validateLabel': "1001 ट्रिक सत्यापित करें" },
      ]
    },
    'te': {
      'appTitle': "భాజ్యతను డీకోడ్ చేయండి",
      'tagline': "తరగతి 8 • చుక్కలు మరియు గీతల కథలు",
      'initBtn': "మిషన్ ప్రారంభించు",
      'boardTitle': "టీచర్ బోర్డు",
      'objLabel': "మిషన్ లక్ష్యం",
      'objDesc': "స్థాన విలువ ద్వారా సంఖ్యలను విస్తరించడం సాధారణ భాజ్యత నియమాలను గణితశాస్త్రపరంగా ఎలా నిరూపిస్తుందో అన్వేషించండి.",
      'stepInfoLabel': "ప్రస్తుత దశ",
      'dataReadouts': "డేటా రీడౌట్స్",
      'msgMissionComplete': "మిషన్ విజయవంతం",
      'finalSubtitle': "మీరు స్థాన విలువ నుండి ప్రతి భాజ్యత ఉపాయాన్ని నిరూపించారు — ఏదీ మాయాజాలం కాదు.",
      'hLabel': "వందల (h)", 'tLabel': "పదుల (t)", 'uLabel': "ఒకట్ల (u)", 'aLabel': "పదుల (a)", 'bLabel': "ఒకట్ల (b)",
      'numberLabel': "సంఖ్య", 'unitsLabel': "ఒకట్ల అంకె", 'div2Label': "÷ 2 పరీక్ష", 'div5Label': "÷ 5 పరీక్ష", 'div10Label': "÷ 10 పరీక్ష",
      'digitSumLabel': "అంకెల మొత్తం", 'differenceLabel': "బేధం", 'quotientLabel': "భాగఫలం", 'sumLabel': "మొత్తం",
      'btnSplit': "సంఖ్యను విభజించండి: 100h+10t+u", 'btnReverse': "అంకెలను తిప్పండి", 'btnDivideBy9': "బేధాన్ని 9 తో భాగించండి",
      'btnLogTrial': "ప్రయత్నాన్ని నమోదు చేయండి", 'btnLogSumTrial': "మొత్తం ప్రయత్నాన్ని నమోదు చేయండి", 'btnCyclic1': "మార్పు 1 నిర్మించండి", 'btnCyclic2': "మార్పు 2 నిర్మించండి",
      'btnCheck37': "÷ 37 తనిఖీ చేయండి", 'btnRepeat': "అంకెలను పునరావృతం చేయండి", 'btnDiv7': "7 తో భాగించండి", 'btnDiv11': "11 తో భాగించండి", 'btnDiv13': "13 తో భాగించండి",
      'msgNeedMoreTests': "ధృవీకరించే ముందు అంకెలను కనీసం రెండుసార్లు మార్చి, ఒకట్ల-అంకె నియమం ప్రతిసారీ నిజమవుతుందో చూడండి.",
      'msgNeedSplit': "మొదట 100h+10t+u ను 99h + 9t + (h+t+u) గా విభజించడానికి SPLIT NUMBER నొక్కండి.",
      'msgNeedChangeFirst': "విభజించే ముందు కనీసం ఒక వేరే 3-అంకెల సంఖ్యను ప్రయత్నించండి.",
      'msgSplitStale': "మీరు విభజించిన తర్వాత అంకెలను మార్చారు. మళ్లీ SPLIT NUMBER నొక్కండి.",
      'msgNeedTarget47': "మొదట అంకె టైల్స్‌ను సరిగ్గా 4 మరియు 7కు సెట్ చేయండి.",
      'msgNeedReverse': "47 నుండి 74ను నిర్మించడానికి REVERSE DIGITS నొక్కండి.",
      'msgNeedDivideBoth': "ఉదాహరణను పూర్తి చేయడానికి DIVIDE DIFFERENCE BY 9 నొక్కండి.",
      'msgNeedThreeTrials': "ధృవీకరించే ముందు కనీసం 3 వేర్వేరు 2-అంకెల సంఖ్యలను ప్రయత్నాలుగా నమోదు చేయండి.",
      'msgNeedDistinctTrial': "ఈ జత ఒక ప్రయత్నాన్ని పునరావృతం చేస్తుంది లేదా రెండు అంకెలు సమానం — కొత్త జతను ప్రయత్నించండి.",
      'msgTrialLogged': "ప్రయత్నం నమోదు చేయబడింది.",
      'msgNeedExactPair': "నమోదు చేసే ముందు టైల్స్‌ను సరిగ్గా ఈ ప్రయత్నం జతకు సెట్ చేయండి.",
      'msgSumTrialLogged': "మొత్తం ప్రయత్నం నమోదు చేయబడింది.",
      'msgNeedAllThreeSum': "ధృవీకరించే ముందు అవసరమైన 3 ప్రయత్నాలను (31, 28, 12) నమోదు చేయండి.",
      'msgNeedCheck37': "మొదట CHECK ÷ 37 నొక్కండి.",
      'msgNeedValidNumber': "వందల అంకె 0 కాకూడదు.",
      'msgStaleChain': "మీరు అంకెలను మార్చారు. మళ్లీ పునరావృతం చేసి భాగించండి.",
      'msgStep0Ok': "సరైనది! ఒకట్ల అంకె మాత్రమే భాజ్యతను 2, 5 మరియు 10 ద్వారా నిర్ణయిస్తుంది.",
      'msgStep1Ok': "సరైనది! సంఖ్య మరియు దాని అంకెల మొత్తం ఎల్లప్పుడూ 9 మరియు 3తో ఒకే శేషాన్ని వదులుతాయి.",
      'msgStep2Ok': "సరైనది! 74 − 47 = 27 = 9 × 3.",
      'msgStep3Ok': "సరైనది! భాగఫలం అంకెల బేధానికి సమానం — నియమం సాధారణీకరించబడుతుంది.",
      'msgStep4Ok': "సరైనది! మూడు తిప్పి-కూడే ప్రయత్నాలు 11 యొక్క ఖచ్చితమైన గుణిజాలు.",
      'msgStep5Ok': "సరైనది! చక్రీయ మొత్తం 37తో ఖచ్చితంగా భాగించబడుతుంది.",
      'msgStep6Ok': "సరైనది! abcabc ÷ 7 ÷ 11 ÷ 13 మీ అసలు సంఖ్యకు ఖచ్చితంగా తిరిగి వస్తుంది.",
      'steps': [
        { 'title': "దశ 1/7: ఒకట్ల అంకె (÷2, ÷5, ÷10)", 'instruction': "ధృవీకరించే ముందు అంకెలను కనీసం రెండుసార్లు మార్చి, ఒకట్ల-అంకె నియమం ప్రతిసారీ నిజమవుతుందో చూడండి.", 'validateLabel': "ఒకట్ల నియమం ధృవీకరించండి" },
        { 'title': "దశ 2/7: సంఖ్యను విభజించండి (÷9 మరియు ÷3)", 'instruction': "అంకెలను ఒకసారి మార్చండి, ఆపై SPLIT NUMBER నొక్కండి. మిగిలిన బ్లాక్ అంకెల మొత్తం, మరియు ఇది సంఖ్య యొక్క 9 మరియు 3తో శేషంతో సరిపోలుతుంది.", 'validateLabel': "విభజన ధృవీకరించండి" },
        { 'title': "దశ 3/7: 47 ని తిప్పండి మరియు 9 తో భాగించండి", 'instruction': "టైల్స్‌ను 4 మరియు 7 కి సెట్ చేయండి. 74 చేయడానికి REVERSE నొక్కండి, ఆపై 74 - 47 = 27 = 9 × 3 చూడటానికి DIVIDE DIFFERENCE BY 9 నొక్కండి.", 'validateLabel': "47 → 74 → 27 ÷ 9 ధృవీకరించండి" },
        { 'title': "దశ 4/7: భాగఫలం నమూనాను కనుగొనండి", 'instruction': "రెండు వేర్వేరు అంకెలతో కూడిన 2-అంకెల సంఖ్యను ఎంచుకోండి, దాన్ని తిప్పండి, బేధాన్ని 9 తో భాగించండి, ఆపై LOG TRIAL నొక్కండి. 3 సార్లు పునరావృతం చేయండి.", 'validateLabel': "3+ ప్రయత్నాలను ధృవీకరించండి" },
        { 'title': "దశ 5/7: తిప్పండి మరియు కలపండి (÷ 11)", 'instruction': "పుస్తకం యొక్క మూడు ఖచ్చితమైన ఉదాహరణలను వరుసగా పరిష్కరించండి: మొదట 31, తర్వాత 28, తర్వాత 12 — ప్రతిదానికి సరిపోలేలా టైల్స్ సెట్ చేయండి మరియు LOG SUM TRIAL నొక్కండి.", 'validateLabel': "3 మొత్తం ప్రయత్నాలను ధృవీకరించండి" },
        { 'title': "దశ 6/7: చక్రీయ మార్పిడి (÷ 37)", 'instruction': "ఏదైనా 3-అంకెల సంఖ్యను ఎంచుకోండి. దాని రెండు చక్రీయ మార్పులను నిర్మించండి, ఆపై CHECK ÷ 37 నొక్కండి.", 'validateLabel': "చక్రీయ మొత్తం ÷ 37 ధృవీకరించండి" },
        { 'title': "దశ 7/7: 1001 మాయాజాలం", 'instruction': "ఏదైనా 3-అంకెల సంఖ్యను ఎంచుకోండి. 6-అంకెల సంఖ్యను నిర్మించడానికి REPEAT DIGITS నొక్కండి, ఆపై వరుసగా 7, 11, మరియు 13 తో భాగించండి. మీరు మీ అసలు సంఖ్యకు తిరిగి చేరుకుంటారు.", 'validateLabel': "1001 ట్రిక్ ధృవీకరించండి" },
      ]
    }
  };
}

// Simple grid painter for background
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var p = Paint()
      ..color = Colors.cyan.withOpacity(0.2)
      ..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), p);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
