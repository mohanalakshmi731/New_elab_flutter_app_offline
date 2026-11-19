// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class ExponentBuilder extends StatefulWidget {
  const ExponentBuilder({super.key});

  @override
  State<ExponentBuilder> createState() => _ExponentBuilderState();
}

class SignCardState {
  String? parity;
  String? sign;
}

class _ExponentBuilderState extends State<ExponentBuilder> {
  // Audio Players
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl =
      'audio/class8/mixkit_2568.mp3';
  static const String _successUrl =
      'audio/class8/mixkit_2018.mp3';
  static const String _errorUrl =
      'audio/class8/mixkit_955.mp3';
  static const String _fxUrl =
      'audio/class8/mixkit_2574.mp3';

  // Configs
  final int treeTarget = 32400;
  final Map<int, int> treeExp = {2: 4, 3: 4, 5: 2};
  final List<Map<String, dynamic>> signCardsData = [
    {'id': 'c0', 'base': '(-4)', 'sup': '3', 'parity': 'odd', 'sign': '-'},
    {'id': 'c1', 'base': '4', 'sup': '3', 'parity': 'odd', 'sign': '+'},
    {'id': 'c2', 'base': '(-1)', 'sup': '5', 'parity': 'odd', 'sign': '-'},
    {'id': 'c3', 'base': '(-1)', 'sup': '56', 'parity': 'even', 'sign': '+'},
    {'id': 'c4', 'base': '(-2)', 'sup': '4', 'parity': 'even', 'sign': '+'},
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
  int _s1Placed = 0;
  final TextEditingController _s1Base = TextEditingController();
  final TextEditingController _s1Exp = TextEditingController();
  final TextEditingController _s1Val = TextEditingController();

  int _s2Placed = 0;
  final TextEditingController _s2Base = TextEditingController();
  final TextEditingController _s2Exp = TextEditingController();
  final TextEditingController _s2Val = TextEditingController();

  late List<SignCardState> _s3Cards;

  int _s4Current = 32400;
  final List<int> _s4Factors = [];
  final TextEditingController _s4E2 = TextEditingController();
  final TextEditingController _s4E3 = TextEditingController();
  final TextEditingController _s4E5 = TextEditingController();

  List<bool> _res = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    _s3Cards = List.generate(5, (_) => SignCardState());
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Prepare shutter sound
    _fxPlayer.setSource(AssetSource(_fxUrl));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playClick() => _clickPlayer.play(AssetSource(_clickUrl));
  void _playSuccess() => _successPlayer.play(AssetSource(_successUrl));
  void _playError() => _errorPlayer.play(AssetSource(_errorUrl));
  void _playSnap() => _fxPlayer.play(AssetSource(_fxUrl));

  void _showSnack(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: bg,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _hardReset() {
    _playClick();
    setState(() {
      _scen = 0;
      _hintIdx = 0;
      _s1Placed = 0;
      _s1Base.clear();
      _s1Exp.clear();
      _s1Val.clear();
      _s2Placed = 0;
      _s2Base.clear();
      _s2Exp.clear();
      _s2Val.clear();
      _s3Cards = List.generate(5, (_) => SignCardState());
      _s4Current = treeTarget;
      _s4Factors.clear();
      _s4E2.clear();
      _s4E3.clear();
      _s4E5.clear();
      _res = [false, false, false, false];
      _showReport = false;
      _shutterActive = true;
      _lang = 'en';
    });
  }

  void _gotoScenario(int idx) {
    if (idx < 0 || idx > 3) return;
    setState(() {
      _scen = idx;
    });
  }

  void _submit() {
    _playClick();
    bool passed = false;

    if (_scen == 0) {
      int? b = int.tryParse(_s1Base.text.trim());
      int? e = int.tryParse(_s1Exp.text.trim());
      int? v = int.tryParse(_s1Val.text.trim());
      passed = (_s1Placed == 4 && b == 5 && e == 4 && v == 625);
      _res[0] = passed;
    } else if (_scen == 1) {
      int? b = int.tryParse(_s2Base.text.trim());
      int? e = int.tryParse(_s2Exp.text.trim());
      int? v = int.tryParse(_s2Val.text.trim());
      passed = (_s2Placed == 10 && b == 2 && e == 10 && v == 1024);
      _res[1] = passed;
    } else if (_scen == 2) {
      passed = true;
      for (int i = 0; i < 5; i++) {
        if (_s3Cards[i].parity != signCardsData[i]['parity'] ||
            _s3Cards[i].sign != signCardsData[i]['sign']) {
          passed = false;
          break;
        }
      }
      _res[2] = passed;
    } else if (_scen == 3) {
      int? e2 = int.tryParse(_s4E2.text.trim());
      int? e3 = int.tryParse(_s4E3.text.trim());
      int? e5 = int.tryParse(_s4E5.text.trim());
      passed =
          (_s4Current == 1 &&
          e2 == treeExp[2] &&
          e3 == treeExp[3] &&
          e5 == treeExp[5]);
      _res[3] = passed;
    }

    if (passed) {
      _playSuccess();
      _hintIdx = 0;
      if (_res.every((r) => r)) {
        setState(() => _showReport = true);
      }
    } else {
      _playError();
      _showSnack("Check your work and try again!", Colors.redAccent);
    }
    setState(() {});
  }

  // --- RENDERING ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: _isDark
            ? const Color(0xFF020617)
            : const Color(0xFFF8FAFC),
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
            // Menu / Sidebar Toggle (Top Left)
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: Icon(
                  _sidebarOpen ? Icons.menu_open : Icons.menu,
                  size: 28,
                ),
                color: Colors.amber,
                onPressed: () {
                  _playClick();
                  setState(() => _sidebarOpen = !_sidebarOpen);
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            if (_showReport) _buildReportModal(),
            if (_shutterActive) _buildShutterScreen(),
          ],
        ),
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
              const Icon(Icons.layers, color: Colors.amber, size: 64),
              const SizedBox(height: 16),
              Text(
                t('app_title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t('app_subtitle'),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  _playSnap();
                  setState(() => _shutterActive = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  t('start_mission').toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    double width = MediaQuery.of(context).size.width * 0.38;
    if (width < 320) width = 320;

    // Determine active steps
    int active = 0;
    List<int> done = [];
    if (_scen == 0 || _scen == 1) {
      int placed = _scen == 0 ? _s1Placed : _s2Placed;
      int max = _scen == 0 ? 4 : 10;
      active = placed >= max ? 2 : (placed > 0 ? 1 : 0);
      if (placed > 0) done.add(0);
      if (placed >= max) done.add(1);
      if (_res[_scen]) {
        active = 3;
        done = [0, 1, 2];
      }
    } else if (_scen == 2) {
      int set = _s3Cards
          .where((c) => c.parity != null && c.sign != null)
          .length;
      active = set >= 5 ? 3 : (set > 0 ? 2 : 0);
      if (set > 0) done.addAll([0, 1]);
      if (_res[2]) done = [0, 1, 2, 3];
    } else {
      active = _s4Current == 1 ? 2 : (_s4Factors.isNotEmpty ? 1 : 0);
      if (_s4Factors.isNotEmpty) done.add(0);
      if (_s4Current == 1) done.add(1);
      if (_res[3]) done = [0, 1, 2, 3];
    }

    List<String> stepKeys = _scen < 2
        ? [
            's${_scen + 1}_1',
            's${_scen + 1}_2',
            's${_scen + 1}_3',
            's${_scen + 1}_4',
          ]
        : (_scen == 2
              ? ['s3_1', 's3_2', 's3_3', 's3_4']
              : ['s4_1', 's4_2', 's4_3', 's4_4']);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: _isDark
            ? const Color(0xD80F172A)
            : Colors.white.withOpacity(0.95),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 50,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Header Content Moved to Sidebar ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 12, top: 4),
                        decoration: BoxDecoration(
                          color: _isDark
                              ? const Color(0xFF1E293B)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.layers,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('app_title'),
                              style: TextStyle(
                                color: _isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t('app_subtitle'),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton.icon(
                        icon: const Icon(
                          Icons.language,
                          color: Colors.grey,
                          size: 18,
                        ),
                        label: Text(
                          _lang.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: _isDark
                              ? const Color(0xFF1E293B)
                              : Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          _playClick();
                          setState(() {
                            _lang = _lang == 'en' ? 'hi' : 'en';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.grey),
                        onPressed: _hardReset,
                        style: IconButton.styleFrom(
                          backgroundColor: _isDark
                              ? const Color(0xFF1E293B)
                              : Colors.grey.shade200,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ---------------------------------------
                  Row(
                    children: [
                      const Icon(
                        Icons.co_present,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t('teacher_board'),
                          style: TextStyle(
                            color: _isDark ? Colors.white : Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Scenario Selector
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isDark
                          ? const Color(0xFF1E293B)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('scenario').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _scen,
                            isExpanded: true,
                            dropdownColor: _isDark
                                ? const Color(0xFF0F172A)
                                : Colors.white,
                            style: TextStyle(
                              color: _isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            items: List.generate(
                              4,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text(
                                  t('scen_${i + 1}'),
                                  style: TextStyle(
                                    color: _res[i] ? Colors.green : null,
                                  ),
                                ),
                              ),
                            ),
                            onChanged: (v) {
                              if (v != null) {
                                _playClick();
                                _gotoScenario(v);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mission Obj
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isDark
                          ? const Color(0xFF1E293B)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('mission_obj').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t('global_mission'),
                          style: TextStyle(
                            color: _isDark ? Colors.white : Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isDark
                          ? const Color(0xFF1E293B)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('inst_seq').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: List.generate(4, (i) {
                            bool isActive = (i == active);
                            bool isDone = done.contains(i) || _res[_scen];
                            Color bg = isActive
                                ? Colors.amber.withOpacity(0.2)
                                : Colors.transparent;
                            Color tc = isDone
                                ? Colors.green
                                : (isActive
                                      ? (_isDark ? Colors.white : Colors.black)
                                      : Colors.grey);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isActive
                                      ? Colors.amber
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isDone
                                        ? Icons.check_circle
                                        : (isActive
                                              ? Icons.arrow_circle_right
                                              : Icons.circle_outlined),
                                    color: tc,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      t(stepKeys[i]),
                                      style: TextStyle(
                                        color: tc,
                                        fontSize: 12,
                                        fontWeight: isActive
                                            ? FontWeight.bold
                                            : FontWeight.w600,
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
                  ),
                  const SizedBox(height: 12),

                  // Hints
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isDark
                          ? const Color(0xFF1E293B)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t('hint_ev').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                _playClick();
                                setState(() => _hintIdx++);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isDark
                                    ? Colors.black26
                                    : Colors.white,
                                foregroundColor: Colors.amber,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              icon: const Icon(Icons.lightbulb, size: 14),
                              label: Text(t('get_hint')),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Builder(
                          builder: (ctx) {
                            List<List<String>> hints = [
                              ['h_1a', 'h_1b', 'h_1c'],
                              ['h_2a', 'h_2b', 'h_2c'],
                              ['h_3a', 'h_3b', 'h_3c'],
                              ['h_4a', 'h_4b', 'h_4c'],
                            ];
                            return Text(
                              t(hints[_scen][_hintIdx % hints[_scen].length]),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Conclusion
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isDark
                          ? const Color(0xFF1E293B)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('learnt_conc').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t('learnt_text'),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer Credits inside scrollable area
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: const Text(
                      '© ZEROSCIENCELAB - Fall in Love with Math and Science',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          child: _scen < 2
              ? _buildPowerPress(_scen == 0 ? 5 : 2, _scen == 0 ? 4 : 10)
              : (_scen == 2 ? _buildSignCards() : _buildPrimeTree()),
        ),
      ),
    );
  }

  Widget _buildPowerPress(int base, int max) {
    int placed = base == 5 ? _s1Placed : _s2Placed;
    int avail = max - placed;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t('ui_factor'),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  base == 5 ? t('ui_drag5') : t('ui_drag2'),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _isDark
                        ? const Color(0xFF020617)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white24,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: avail > 0
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            avail,
                            (_) => _buildFactorTile(base),
                          ),
                        )
                      : Text(
                          t('ui_allplaced'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${t('ui_placed')} $placed  ·  ${t('ui_target')} $max',
                  style: TextStyle(
                    color: _isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t('ui_press'),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                DragTarget<int>(
                  builder: (ctx, incoming, rejected) {
                    bool hot = incoming.isNotEmpty;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: hot
                            ? Colors.amber.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hot ? Colors.amber : Colors.orange,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: placed > 0
                          ? Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: List.generate(
                                placed,
                                (_) => GestureDetector(
                                  onTap: () {
                                    _playClick();
                                    setState(() {
                                      if (base == 5) {
                                        _s1Placed--;
                                      } else {
                                        _s2Placed--;
                                      }
                                    });
                                  },
                                  child: _buildPressSlot(base),
                                ),
                              ),
                            )
                          : const Text(
                              'Drop tiles here',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                    );
                  },
                  onWillAcceptWithDetails: (d) =>
                      d.data == base && placed < max,
                  onAcceptWithDetails: (d) {
                    _playSnap();
                    setState(() {
                      if (base == 5) {
                        _s1Placed++;
                      } else {
                        _s2Placed++;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (placed > 0)
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${List.generate(placed, (_) => base).join(' × ')} = $base',
                          style: TextStyle(
                            color: _isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        WidgetSpan(
                          child: Transform.translate(
                            offset: const Offset(2, -8),
                            child: Text(
                              '$placed',
                              style: TextStyle(
                                color: _isDark ? Colors.white : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(
                          text: ' = ${pow(base, placed)}',
                          style: TextStyle(
                            color: _isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  t('ui_taprem'),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        t('ui_base'),
                        base == 5 ? _s1Base : _s2Base,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInput(
                        t('ui_exp'),
                        base == 5 ? _s1Exp : _s2Exp,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInput(
                        t('ui_val'),
                        base == 5 ? _s1Val : _s2Val,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFactorTile(int n) {
    return Draggable<int>(
      data: n,
      feedback: Material(
        color: Colors.transparent,
        child: _buildTileUI(n, dragging: true),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildTileUI(n)),
      child: _buildTileUI(n),
    );
  }

  Widget _buildTileUI(int n, {bool dragging = false}) {
    List<Color> cols = [Colors.orange.shade400, Colors.orange.shade700];
    if (n == 2 || n == 3 || n == 5) {
      if (_scen == 3) cols = [Colors.lightBlue.shade400, Colors.blue.shade700];
    }
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cols,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
        boxShadow: dragging
            ? const [BoxShadow(color: Colors.black45, blurRadius: 10)]
            : const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        '$n',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildPressSlot(int n) {
    return Container(
      width: 45,
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade700],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
      ),
      child: Text(
        '$n',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: _isDark ? const Color(0xFF020617) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.amber, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignCards() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: List.generate(5, (i) {
        var cd = signCardsData[i];
        var st = _s3Cards[i];
        return Container(
          width: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: cd['base'],
                      style: TextStyle(
                        color: _isDark ? Colors.white : Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    WidgetSpan(
                      child: Transform.translate(
                        offset: const Offset(2, -14),
                        child: Text(
                          cd['sup'],
                          style: TextStyle(
                            color: _isDark ? Colors.white : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      t('ui_parity'),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildTgBtn(st.parity == 'odd', t('ui_odd'), () {
                      _playClick();
                      setState(() => st.parity = 'odd');
                    }),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildTgBtn(st.parity == 'even', t('ui_even'), () {
                      _playClick();
                      setState(() => st.parity = 'even');
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      t('ui_res'),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildTgBtn(st.sign == '+', t('ui_pos'), () {
                      _playClick();
                      setState(() => st.sign = '+');
                    }),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildTgBtn(st.sign == '-', t('ui_neg'), () {
                      _playClick();
                      setState(() => st.sign = '-');
                    }),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTgBtn(bool sel, String lbl, VoidCallback cb) {
    return GestureDetector(
      onTap: cb,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sel
              ? Colors.amber
              : (_isDark ? const Color(0xFF020617) : Colors.grey.shade200),
          border: Border.all(color: sel ? Colors.amber : Colors.white12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          lbl,
          style: TextStyle(
            color: sel ? Colors.black : (_isDark ? Colors.white : Colors.black),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimeTree() {
    bool done = _s4Current == 1;
    Map<int, int> counts = {2: 0, 3: 0, 5: 0};
    for (var f in _s4Factors) {
      counts[f] = (counts[f] ?? 0) + 1;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('ui_primediv'),
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      t('ui_dragprime'),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _isDark
                            ? const Color(0xFF020617)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white24,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFactorTile(2),
                          _buildFactorTile(3),
                          _buildFactorTile(5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t('ui_currq'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$_s4Current',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DragTarget<int>(
                      builder: (ctx, incoming, rejected) {
                        bool hot = incoming.isNotEmpty;
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: hot
                                ? Colors.amber.withOpacity(0.2)
                                : Colors.amber.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Text(
                            done ? t('ui_divdone') : t('ui_dropdiv'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      onWillAcceptWithDetails: (d) => !done,
                      onAcceptWithDetails: (d) {
                        int p = d.data;
                        if (_s4Current % p == 0) {
                          _playSnap();
                          setState(() {
                            _s4Factors.add(p);
                            _s4Current = _s4Current ~/ p;
                          });
                        } else {
                          _playError();
                          _showSnack(t('err_remainder'), Colors.redAccent);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('ui_tree'),
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_s4Factors.isEmpty)
                      Text(
                        t('ui_nodiv'),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Column(
                        children: () {
                          List<Widget> nodes = [];
                          int v = treeTarget;
                          for (int p in _s4Factors) {
                            int from = v;
                            v = v ~/ p;
                            nodes.add(
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _isDark
                                      ? const Color(0xFF020617)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade900,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '÷ $p',
                                        style: const TextStyle(
                                          color: Colors.lightBlueAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '$from = $p × $v',
                                      style: TextStyle(
                                        color: _isDark
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return nodes;
                        }(),
                      ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [2, 3, 5]
                          .map(
                            (p) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade900,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Text(
                                '$p × ${counts[p]}',
                                style: const TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              if (done) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('ui_collect'),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        t('ui_write'),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildInput(t('ui_p2'), _s4E2)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildInput(t('ui_p3'), _s4E3)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildInput(t('ui_p5'), _s4E5)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHUD() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _isDark
            ? const Color(0xD80F172A)
            : Colors.white.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: _scen > 0
                ? () {
                    _playClick();
                    _gotoScenario(_scen - 1);
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
            label: Text(t('prev')),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              t('submit').toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: _scen < 3
                ? () {
                    _playClick();
                    _gotoScenario(_scen + 1);
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
            label: Text(t('next')),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
          const SizedBox(width: 24),
          TextButton.icon(
            onPressed: _res.every((r) => r)
                ? () {
                    _playClick();
                    setState(() => _showReport = true);
                  }
                : null,
            icon: const Icon(Icons.bar_chart),
            label: Text(t('report')),
            style: TextButton.styleFrom(
              foregroundColor: _res.every((r) => r)
                  ? Colors.amber
                  : Colors.grey.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportModal() {
    bool all = _res.every((r) => r);
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: all ? Colors.green : Colors.amber),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                all ? Icons.check_circle : Icons.warning_amber_rounded,
                color: all ? Colors.green : Colors.amber,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                all ? t('rep_success_title') : t('rep_prog_title'),
                style: TextStyle(
                  color: all ? Colors.green : Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                all ? t('rep_success_sub') : t('rep_prog_sub'),
                style: TextStyle(
                  color: _isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _playClick();
                  setState(() => _showReport = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDark
                      ? const Color(0xFF1E293B)
                      : Colors.grey.shade200,
                  foregroundColor: _isDark ? Colors.white : Colors.black,
                ),
                child: Text(t('close_report')),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _hardReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: Text(t('restart_exp')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TEXT CONSTANTS ---
  final Map<String, Map<String, String>> _text = {
    'en': {
      'app_title': "Exponent Builder: From Repeated Product to Power",
      'app_subtitle':
          "Class 8 • Power Play — Exponential Notation & Prime Powers",
      'start_mission': "Start Mission",
      'teacher_board': "Teacher Board",
      'scenario': "Scenario",
      'mission_obj': "Mission Objective",
      'inst_seq': "Instruction Sequence",
      'hint_ev': "Hint / Evidence",
      'learnt_conc': "Learnt Conclusion",
      'get_hint': "Get Hint",
      'close_report': "Close Report",
      'restart_exp': "Restart Exploration",
      'prev': "Prev",
      'next': "Next",
      'submit': "Submit",
      'report': "Report",
      'scen_1': "Scenario 1 · Build 5⁴ = 625",
      'scen_2': "Scenario 2 · Build 2¹⁰ = 1024",
      'scen_3': "Scenario 3 · Sign of Powers",
      'scen_4': "Scenario 4 · Prime Tree 32400",
      'global_mission':
          "Collapse repeated multiplication into powers, decide the sign of powers of negative numbers, and rebuild 32400 as a product of prime powers.",
      'learnt_text':
          "nᵃ means 'a' equal factors of 'n'. Sign of (−n)ᵃ is negative for odd 'a', positive for even 'a'. Every number is a product of prime powers.",
      'rep_success_title': "Mission Accomplished!",
      'rep_success_sub':
          "You have mastered exponential notation, signs, and prime powers.",
      'rep_prog_title': "Mission in Progress",
      'rep_prog_sub': "Complete all scenarios to fully master the concepts.",
      's1_1': "Drag four 5-tiles into the power press.",
      's1_2': "Read the collapsed power 5⁴.",
      's1_3': "Type base = 5, exponent = 4, value = 625.",
      's1_4': "Press Submit.",
      's2_1': "Drag ten 2-tiles into the press.",
      's2_2': "Watch the exponent grow to 10.",
      's2_3': "Type base = 2, exponent = 10, value = 1024.",
      's2_4': "Press Submit.",
      's3_1': "For every card, set exponent parity and result sign.",
      's3_2': "Mark odd or even.",
      's3_3': "Choose the result sign + or −.",
      's3_4': "Press Submit when all five are set.",
      's4_1':
          "Drag prime tiles (2, 3, 5) onto the current number to divide it.",
      's4_2': "Keep dividing until the quotient is 1.",
      's4_3': "Collect equal primes into powers: exponent of 2, of 3, of 5.",
      's4_4': "Press Submit.",
      'ui_factor': "Factor Tiles",
      'ui_drag5': "Drag 5-tiles into the power press.",
      'ui_drag2': "Drag 2-tiles into the power press.",
      'ui_placed': "Placed:",
      'ui_target': "Target:",
      'ui_allplaced': "All tiles placed — remove one to get it back.",
      'ui_press': "Power Press",
      'ui_taprem': "Tap a placed tile to remove it.",
      'ui_drop': "Drop tiles to build a product",
      'ui_base': "Base",
      'ui_exp': "Exponent",
      'ui_val': "Value nᵃ",
      'ui_parity': "Exponent",
      'ui_odd': "Odd",
      'ui_even': "Even",
      'ui_res': "Result",
      'ui_pos': "+ Positive",
      'ui_neg': "− Negative",
      'ui_primediv': "Prime Divisors",
      'ui_dragprime': "Drag a prime onto the current number to divide it.",
      'ui_currq': "Current quotient",
      'ui_dropdiv': "Drop a prime here to divide",
      'ui_divdone': "Quotient is 1 — complete!",
      'ui_tree': "Factor Tree",
      'ui_nodiv': "No divisions yet.",
      'ui_collect': "Collect Prime Powers",
      'ui_write': "Write 32400 as 2ᵃ × 3ᵇ × 5ᶜ",
      'ui_p2': "Power of 2",
      'ui_p3': "Power of 3",
      'ui_p5': "Power of 5",
      'h_1a': "The exponent equals the number of tiles.",
      'h_1b': "5 × 5 × 5 × 5 collapses to 5⁴.",
      'h_1c': "5⁴ = 625. Type base 5, exp 4, val 625.",
      'h_2a': "Ten equal 2-tiles give exponent 10.",
      'h_2b': "2¹⁰ means double 1 ten times.",
      'h_2c': "2¹⁰ = 1024. Type base 2, exp 10, val 1024.",
      'h_3a': "Odd exponent keeps a negative base negative.",
      'h_3b': "Even exponent turns a negative base positive.",
      'h_3c': "A positive base is always positive.",
      'h_4a': "Divide by 2 until odd (four times).",
      'h_4b': "Divide by 3 until you cannot (four times).",
      'h_4c': "Divide by 5 twice to reach 1.",
      'err_remainder': "Cannot divide without a remainder!",
    },
    'hi': {
      'app_title': "घातांक निर्माता: बार-बार गुणा से घात तक",
      'app_subtitle': "कक्षा 8 • पावर प्ले — घातांकीय संकेतन और अभाज्य घात",
      'start_mission': "मिशन शुरू करें",
      'teacher_board': "शिक्षक बोर्ड",
      'scenario': "परिदृश्य",
      'mission_obj': "मिशन का उद्देश्य",
      'inst_seq': "निर्देश क्रम",
      'hint_ev': "संकेत / साक्ष्य",
      'learnt_conc': "सीखा हुआ निष्कर्ष",
      'get_hint': "संकेत प्राप्त करें",
      'close_report': "रिपोर्ट बंद करें",
      'restart_exp': "पुनः प्रारंभ करें",
      'prev': "पिछला",
      'next': "अगला",
      'submit': "सबमिट",
      'report': "रिपोर्ट",
      'scen_1': "परिदृश्य 1 · 5⁴ = 625 बनाएं",
      'scen_2': "परिदृश्य 2 · 2¹⁰ = 1024 बनाएं",
      'scen_3': "परिदृश्य 3 · घातों का चिन्ह",
      'scen_4': "परिदृश्य 4 · 32400 का अभाज्य वृक्ष",
      'global_mission':
          "बार-बार गुणा को घात में संकुचित करें, ऋणात्मक संख्याओं के घातों का चिन्ह तय करें, और 32400 को अभाज्य घातों के गुणनफल के रूप में फिर से बनाएं।",
      'learnt_text':
          "nᵃ का अर्थ है 'n' के 'a' समान गुणनखंड। विषम 'a' के लिए (−n)ᵃ का चिन्ह ऋणात्मक है, सम 'a' के लिए धनात्मक है। प्रत्येक संख्या अभाज्य घातों का गुणनफल है।",
      'rep_success_title': "मिशन पूरा हुआ!",
      'rep_success_sub':
          "आपने घातांकीय संकेतन, चिन्हों और अभाज्य घातों में महारत हासिल कर ली है।",
      'rep_prog_title': "मिशन प्रगति पर",
      'rep_prog_sub':
          "अवधारणाओं में पूरी तरह से महारत हासिल करने के लिए सभी परिदृश्यों को पूरा करें।",
      's1_1': "चार 5-टाइलें पावर प्रेस में खींचें।",
      's1_2': "संक्षिप्त घात 5⁴ पढ़ें।",
      's1_3': "आधार = 5, घातांक = 4, मान = 625 लिखें।",
      's1_4': "सबमिट दबाएं।",
      's2_1': "दस 2-टाइलें प्रेस में खींचें।",
      's2_2': "घातांक को 10 तक बढ़ते देखें।",
      's2_3': "आधार = 2, घातांक = 10, मान = 1024 लिखें।",
      's2_4': "सबमिट दबाएं।",
      's3_1':
          "प्रत्येक कार्ड के लिए घातांक सम/विषम और परिणाम का चिन्ह सेट करें।",
      's3_2': "सम या विषम चिह्नित करें।",
      's3_3': "परिणाम चिन्ह + या - चुनें।",
      's3_4': "सभी पांच सेट होने पर सबमिट दबाएं।",
      's4_1':
          "वर्तमान संख्या पर एक अभाज्य (2, 3, 5) खींचें जब तक कि भागफल 1 न हो जाए।",
      's4_2': "भागफल 1 होने तक भाग देते रहें।",
      's4_3':
          "समान अभाज्यों को घातों में एकत्र करें: 2 की घात, 3 की घात, 5 की घात।",
      's4_4': "सबमिट दबाएं।",
      'ui_factor': "गुणनखंड टाइलें",
      'ui_drag5': "5-टाइलों को पावर प्रेस में खींचें।",
      'ui_drag2': "2-टाइलों को पावर प्रेस में खींचें।",
      'ui_placed': "रखे गए:",
      'ui_target': "लक्ष्य:",
      'ui_allplaced': "सभी टाइलें रखी गईं — वापस पाने के लिए एक निकालें।",
      'ui_press': "पावर प्रेस",
      'ui_taprem': "निकालने के लिए रखी गई टाइल पर टैप करें।",
      'ui_drop': "गुणनफल बनाने के लिए टाइलें छोड़ें",
      'ui_base': "आधार",
      'ui_exp': "घातांक",
      'ui_val': "मान nᵃ",
      'ui_parity': "घातांक",
      'ui_odd': "विषम",
      'ui_even': "सम",
      'ui_res': "परिणाम",
      'ui_pos': "+ धनात्मक",
      'ui_neg': "− ऋणात्मक",
      'ui_primediv': "अभाज्य भाजक",
      'ui_dragprime': "भाग देने के लिए वर्तमान संख्या पर एक अभाज्य खींचें।",
      'ui_currq': "वर्तमान भागफल",
      'ui_dropdiv': "भाग देने के लिए यहाँ अभाज्य छोड़ें",
      'ui_divdone': "भागफल 1 है — पूर्ण!",
      'ui_tree': "गुणनखंड वृक्ष",
      'ui_nodiv': "अभी तक कोई भाग नहीं।",
      'ui_collect': "अभाज्य घात एकत्र करें",
      'ui_write': "32400 को 2ᵃ × 3ᵇ × 5ᶜ के रूप में लिखें",
      'ui_p2': "2 की घात",
      'ui_p3': "3 की घात",
      'ui_p5': "5 की घात",
      'h_1a': "घातांक टाइलों की संख्या के बराबर होता है।",
      'h_1b': "5 × 5 × 5 × 5 संक्षिप्त होकर 5⁴ बनता है।",
      'h_1c': "5⁴ = 625. आधार 5, घातांक 4, मान 625 लिखें।",
      'h_2a': "दस समान 2-टाइलें घातांक 10 देती हैं।",
      'h_2b': "2¹⁰ का अर्थ है 1 को दस बार दोगुना करना।",
      'h_2c': "2¹⁰ = 1024. आधार 2, घातांक 10, मान 1024 लिखें।",
      'h_3a': "विषम घातांक ऋणात्मक आधार को ऋणात्मक रखता है।",
      'h_3b': "सम घातांक ऋणात्मक आधार को धनात्मक बनाता है।",
      'h_3c': "धनात्मक आधार हमेशा धनात्मक होता है।",
      'h_4a': "विषम होने तक 2 से भाग दें (चार बार)।",
      'h_4b': "3 से भाग दें जब तक न जा सके (चार बार)।",
      'h_4c': "1 तक पहुँचने के लिए 5 से दो बार भाग दें।",
      'err_remainder': "शेषफल के बिना भाग नहीं दे सकते!",
    },
  };

  String t(String key) {
    return _text[_lang]?[key] ?? _text['en']![key] ?? key;
  }
}
