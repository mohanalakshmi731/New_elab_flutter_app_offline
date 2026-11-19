// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Cl8MCh6A4SquareBuilderIdentities(),
    ),
  );
}

enum ScenarioMode { build, remove }

class PieceModel {
  final String id;
  final String kind;
  final String label;
  PieceModel(this.id, this.kind, this.label);
}

class ScenarioConfig {
  final ScenarioMode mode;
  final bool numeric;
  final int total;
  final int bMin;
  final int bMax;
  final int bTarget;
  final int bDefault;
  final String a2Piece;
  final String abPiece;
  final String b2Piece;
  final String decoyPiece;
  final List<String> signs;
  final int confirmTarget;
  final String resultStr;
  final bool liveNum;
  final String aLabelBase;
  final String bLabelBase;
  final String eqLhs;

  ScenarioConfig({
    required this.mode,
    required this.numeric,
    required this.total,
    required this.bMin,
    required this.bMax,
    required this.bTarget,
    required this.bDefault,
    required this.a2Piece,
    required this.abPiece,
    required this.b2Piece,
    required this.decoyPiece,
    required this.signs,
    required this.confirmTarget,
    required this.resultStr,
    required this.liveNum,
    required this.aLabelBase,
    required this.bLabelBase,
    required this.eqLhs,
  });

  List<PieceModel> getAvailablePieces() {
    return [
      PieceModel('p1', 'a2', a2Piece),
      PieceModel('p2', 'ab', abPiece),
      PieceModel('p3', 'ab', abPiece),
      PieceModel('p4', 'b2', b2Piece),
      PieceModel('p5', 'decoy', decoyPiece),
    ];
  }
}

final List<ScenarioConfig> scenarios = [
  ScenarioConfig(
    mode: ScenarioMode.build,
    numeric: true,
    total: 65,
    bMin: 1,
    bMax: 12,
    bTarget: 5,
    bDefault: 9,
    a2Piece: '3600',
    abPiece: '300',
    b2Piece: '25',
    decoyPiece: '305',
    signs: ['', '+', '+', '+'],
    confirmTarget: 4225,
    resultStr: '3600 + 300 + 300 + 25 = 4225',
    liveNum: true,
    aLabelBase: '60',
    bLabelBase: '5',
    eqLhs: '65² =',
  ),
  ScenarioConfig(
    mode: ScenarioMode.build,
    numeric: false,
    total: 11,
    bMin: 1,
    bMax: 10,
    bTarget: 5,
    bDefault: 8,
    a2Piece: '36x²',
    abPiece: '30x',
    b2Piece: '25',
    decoyPiece: '11x',
    signs: ['', '+', '+', '+'],
    confirmTarget: 60,
    resultStr: '36x² + 30x + 30x + 25 = 36x² + 60x + 25',
    liveNum: false,
    aLabelBase: '6x',
    bLabelBase: '5',
    eqLhs: '(6x+5)² =',
  ),
  ScenarioConfig(
    mode: ScenarioMode.remove,
    numeric: true,
    total: 60,
    bMin: 1,
    bMax: 12,
    bTarget: 5,
    bDefault: 9,
    a2Piece: '3600',
    abPiece: '300',
    b2Piece: '25',
    decoyPiece: '600',
    signs: ['', '−', '−', '+'],
    confirmTarget: 3025,
    resultStr: '3600 − 300 − 300 + 25 = 3025',
    liveNum: true,
    aLabelBase: '60',
    bLabelBase: '5',
    eqLhs: '55² =',
  ),
  ScenarioConfig(
    mode: ScenarioMode.remove,
    numeric: false,
    total: 10,
    bMin: 1,
    bMax: 8,
    bTarget: 4,
    bDefault: 2,
    a2Piece: 'a²',
    abPiece: 'ab',
    b2Piece: 'b²',
    decoyPiece: '2ab',
    signs: ['', '−', '−', '+'],
    confirmTarget: 2,
    resultStr: 'a² − ab − ab + b² = a² − 2ab + b²',
    liveNum: false,
    aLabelBase: 'a',
    bLabelBase: 'b',
    eqLhs: '(a−b)² =',
  ),
];

final Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'Square Builder',
    'app_subtitle': 'Class 8 • Identities (a+b)² & (a−b)²',
    'start_mission': 'Start Mission',
    'nav_prev': 'Prev',
    'nav_next': 'Next',
    'nav_submit': 'Submit',
    'sidebar_title': 'Teacher Board',
    'ui_scenario': 'Scenario',
    'ui_objective': 'Objective',
    'ui_sequence': 'Sequence',
    'ui_hints': 'Hints',
    'scen_1': 'Scenario 1 · 65²',
    'scen_2': 'Scenario 2 · (6x+5)²',
    'scen_3': 'Scenario 3 · 55²',
    'scen_4': 'Scenario 4 · (a−b)²',
    'mission_desc':
        'Slide the divider to split the square\'s side, then assemble the regions to prove the identity.',
    'hint_initial':
        'For (a+b)², add areas. For (a−b)², subtract strips and add the overlapping corner back.',
    'flash_all_solved': 'All Scenarios Solved!',
    'flash_scen_solved': 'Scenario Solved! Move to the next one.',
    'flash_check': 'Check your slots and try again.',
    'flash_split_first': 'Set the divider correctly first!',
    'flash_fill': 'Fill all area slots first!',
    'flash_reset': 'Activity reset.',
    'area_ledger': 'Area Ledger',
    'asm_title': 'Assemble Regions',
    'confirm_title': 'Confirm Value',
    'split_label': 'Slide to split value b',
    'model_desc': 'Drag the divider, then place each region into the equation.',
  },
  'hi': {
    'app_title': 'स्क्वायर बिल्डर',
    'app_subtitle': 'कक्षा 8 • सर्वसमिकाएँ (a+b)² और (a−b)²',
    'start_mission': 'मिशन शुरू करें',
    'nav_prev': 'पिछला',
    'nav_next': 'अगला',
    'nav_submit': 'सबमिट',
    'sidebar_title': 'शिक्षक बोर्ड',
    'ui_scenario': 'परिदृश्य',
    'ui_objective': 'उद्देश्य',
    'ui_sequence': 'निर्देश क्रम',
    'ui_hints': 'संकेत',
    'scen_1': 'परिदृश्य 1 · 65²',
    'scen_2': 'परिदृश्य 2 · (6x+5)²',
    'scen_3': 'परिदृश्य 3 · 55²',
    'scen_4': 'परिदृश्य 4 · (a−b)²',
    'mission_desc':
        'वर्ग की भुजा को विभाजित करने के लिए डिवाइडर को स्लाइड करें, फिर पहचान साबित करने के लिए क्षेत्रों को इकट्ठा करें।',
    'hint_initial':
        '(a+b)² के लिए, क्षेत्र जोड़ें। (a−b)² के लिए, पट्टियाँ घटाएँ और अतिव्यापी कोने को वापस जोड़ें।',
    'flash_all_solved': 'सभी परिदृश्य हल हो गए!',
    'flash_scen_solved': 'परिदृश्य हल! अगले पर जाएं।',
    'flash_check': 'अपने स्लॉट जांचें और पुनः प्रयास करें।',
    'flash_split_first': 'पहले डिवाइडर को सही ढंग से सेट करें!',
    'flash_fill': 'पहले सभी स्लॉट भरें!',
    'flash_reset': 'गतिविधि रीसेट की गई।',
    'area_ledger': 'क्षेत्र विवरण',
    'asm_title': 'क्षेत्रों को इकट्ठा करें',
    'confirm_title': 'मान की पुष्टि करें',
    'split_label': 'b मान विभाजित करने के लिए स्लाइड करें',
    'model_desc': 'डिवाइडर खींचें, फिर प्रत्येक क्षेत्र को समीकरण में रखें।',
  },
};

class Cl8MCh6A4SquareBuilderIdentities extends StatefulWidget {
  const Cl8MCh6A4SquareBuilderIdentities({super.key});
  @override
  State<Cl8MCh6A4SquareBuilderIdentities> createState() =>
      _Cl8MCh6A4SquareBuilderIdentitiesState();
}

class _Cl8MCh6A4SquareBuilderIdentitiesState
    extends State<Cl8MCh6A4SquareBuilderIdentities>
    with TickerProviderStateMixin {
  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  // UI State
  bool _showCurtain = true;
  bool _sidebarOpen = true;
  double _sidebarWidth = 320.0;
  String _lang = 'en';
  final bool _isDark = true;
  String? _flashMsg;

  // Game State
  int _activeScenario = 0;
  List<int> _bValues = [];
  List<bool> _submitted = [false, false, false, false];
  List<bool> _correct = [false, false, false, false];
  List<String> _confirmVals = ['', '', '', ''];

  List<List<PieceModel?>> _slots = [];
  List<List<PieceModel>> _tray = [];

  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class8/mixkit_2073.mp3',
      ),
    );
  }

  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class8/gotitem.mp3',
      ),
    );
  }

  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource(
        'audio/class8/mixkit_1491.mp3',
      ),
    );
  }

  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class8/mixkit_946.mp3',
      ),
    );
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class8/mixkit_2574.mp3',
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Enforce immersive mode properly
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initGameState();
  }

  void _initGameState() {
    _bValues = scenarios.map((s) => s.bDefault).toList();
    _submitted = [false, false, false, false];
    _correct = [false, false, false, false];
    _confirmVals = ['', '', '', ''];
    _slots = List.generate(4, (_) => List.filled(4, null));
    _tray = scenarios.map((s) => s.getAvailablePieces()).toList();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    super.dispose();
  }

  String t(String key) => i18n[_lang]?[key] ?? i18n['en']![key] ?? key;

  // Theme Colors
  Color get bgBase =>
      _isDark ? const Color(0xFF061024) : const Color(0xFFF1F5F9);
  Color get bgPrimary =>
      _isDark ? const Color(0xFF0A1936) : const Color(0xFFFFFFFF);
  Color get bgSecondary =>
      _isDark ? const Color(0xFF0F254A) : const Color(0xFFE2E8F0);
  Color get textPrimary =>
      _isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get textSecondary =>
      _isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  Color get accent => const Color(0xFFF97316);
  Color get success => const Color(0xFF22C55E);
  Color get error => const Color(0xFFEF4444);
  Color get borderColor => const Color(0x4DF97316);

  void _showFlash(String msg) {
    setState(() => _flashMsg = msg);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _flashMsg == msg) setState(() => _flashMsg = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBase,
      body: Stack(
        children: [
          // Canvas Area
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            top: 0,
            bottom: 0,
            right: 0,
            left: _sidebarOpen ? _sidebarWidth : 0,
            child: _buildCanvasArea(),
          ),

          // Sidebar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            top: 0,
            bottom: 0,
            left: _sidebarOpen ? 0 : -_sidebarWidth,
            width: _sidebarWidth,
            child: _buildSidebar(),
          ),

          // Menu Toggle Button
          Positioned(
            top: 16,
            child: SafeArea(
              child: FloatingActionButton(
                mini: true,
                backgroundColor: bgSecondary,
                foregroundColor: accent,
                elevation: 4,
                onPressed: () {
                  playClick();
                  setState(() => _sidebarOpen = !_sidebarOpen);
                },
                child: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu),
              ),
            ),
          ),

          // Flash Messages
          if (_flashMsg != null)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: success,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _flashMsg!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

          // Initial Shutter Screen
          if (_showCurtain) _buildCurtain(),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    bool allSlotsFilled = _slots[_activeScenario].every((p) => p != null);

    return Row(
      children: [
        Expanded(
          child: Container(
            color: bgPrimary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 64,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  // Header
                  Row(
                    children: [
                      Icon(Icons.dashboard_customize, color: accent, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t('sidebar_title'),
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t('app_subtitle'),
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Controls (Lang & Reset)
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.language, size: 18),
                        label: Text(_lang.toUpperCase()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bgSecondary,
                          foregroundColor: accent,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          playClick();
                          setState(() {
                            if (_lang == 'en') {
                              _lang = 'hi';
                            } else {
                              _lang = 'en';
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        color: textSecondary,
                        tooltip: 'Reset',
                        onPressed: () {
                          playClick();
                          setState(() {
                            _initGameState();
                            _activeScenario = 0;
                            _showCurtain = true;
                          });
                          _showFlash(t('flash_reset'));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Scenario Dropdown
                  _buildCard(
                    t('ui_scenario'),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _activeScenario,
                        dropdownColor: bgSecondary,
                        isExpanded: true,
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        items: List.generate(
                          4,
                          (i) => DropdownMenuItem(
                            value: i,
                            child: Text(t('scen_${i + 1}')),
                          ),
                        ),
                        onChanged: (val) {
                          playDropdown();
                          if (val != null) {
                            setState(() => _activeScenario = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Objectives & Info
                  _buildCard(
                    t('ui_objective'),
                    Text(
                      t('mission_desc'),
                      style: TextStyle(color: textPrimary, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    t('ui_hints'),
                    Text(
                      t('hint_initial'),
                      style: TextStyle(color: textPrimary, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Navigation
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bgSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle),
                          label: Text(t('nav_submit')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _checkSubmission(allSlotsFilled),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.chevron_left),
                              label: Text(t('nav_prev')),
                              style: TextButton.styleFrom(
                                foregroundColor: _activeScenario > 0
                                    ? textPrimary
                                    : textSecondary,
                              ),
                              onPressed: _activeScenario > 0
                                  ? () {
                                      playClick();
                                      setState(() => _activeScenario--);
                                    }
                                  : null,
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    _correct[_activeScenario] &&
                                        _activeScenario < 3
                                    ? textPrimary
                                    : textSecondary,
                              ),
                              onPressed:
                                  _correct[_activeScenario] &&
                                      _activeScenario < 3
                                  ? () {
                                      playClick();
                                      setState(() => _activeScenario++);
                                    }
                                  : null,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(t('nav_next')),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Footer
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: borderColor)),
                    ),
                    child: Text(
                      '© ZeroScienceLab\nFall in love with math and Science',
                      style: TextStyle(
                        color: textSecondary,
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
        ),
        // Drag Handle Resizer
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            setState(() {
              _sidebarWidth = (_sidebarWidth + details.delta.dx).clamp(
                280.0,
                MediaQuery.of(context).size.width * 0.5,
              );
            });
          },
          child: Container(
            width: 12,
            color: bgPrimary,
            child: Center(
              child: Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        Container(width: 1, color: borderColor),
      ],
    );
  }

  Widget _buildCard(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildCanvasArea() {
    return Column(
      children: [
        // Interactive Viewer handles smooth zoom and pan seamlessly
        Expanded(
          child: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            minScale: 0.5,
            maxScale: 3.0,
            boundaryMargin: const EdgeInsets.all(100),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isWide = constraints.maxWidth > 700;
                  List<Widget> panels = [
                    Expanded(flex: isWide ? 1 : 0, child: _buildModelPanel()),
                    SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
                    Expanded(flex: isWide ? 1 : 0, child: _buildWorkPanel()),
                  ];
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: panels,
                        )
                      : Column(children: panels);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModelPanel() {
    ScenarioConfig cfg = scenarios[_activeScenario];
    int currentB = _bValues[_activeScenario];

    return Column(
      children: [
        _buildCard(
          t('model_desc'),
          Column(
            children: [
              // Square Canvas drawing
              Container(
                width: 240,
                height: 240,
                margin: const EdgeInsets.all(16),
                child: CustomPaint(
                  painter: SquarePainter(
                    mode: cfg.mode,
                    total: cfg.total,
                    b: currentB,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t('split_label'),
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: accent,
                  inactiveTrackColor: textSecondary.withOpacity(0.3),
                  thumbColor: accent,
                  overlayColor: accent.withOpacity(0.2),
                ),
                child: Slider(
                  value: currentB.toDouble(),
                  min: cfg.bMin.toDouble(),
                  max: cfg.bMax.toDouble(),
                  divisions: cfg.bMax - cfg.bMin,
                  onChangeEnd: (val) {
                    if (!_correct[_activeScenario]) playDropdown();
                  },
                  onChanged: _correct[_activeScenario]
                      ? null
                      : (val) {
                          setState(
                            () => _bValues[_activeScenario] = val.toInt(),
                          );
                        },
                ),
              ),
              Text(
                'b = $currentB',
                style: TextStyle(
                  color: error,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkPanel() {
    ScenarioConfig cfg = scenarios[_activeScenario];

    return Column(
      children: [
        _buildCard(
          t('asm_title'),
          Column(
            children: [
              // Equation Builder
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 12,
                children: [
                  Text(
                    cfg.eqLhs,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  for (int i = 0; i < 4; i++) ...[
                    if (cfg.signs[i].isNotEmpty)
                      Text(
                        cfg.signs[i],
                        style: TextStyle(
                          color: accent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    _buildSlot(i),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              // Tray
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _tray[_activeScenario]
                    .map((p) => _buildDraggable(p))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          t('confirm_title'),
          Column(
            children: [
              TextField(
                enabled: !_correct[_activeScenario],
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '?',
                  hintStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: bgBase,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accent, width: 2),
                  ),
                ),
                onChanged: (val) => _confirmVals[_activeScenario] = val,
              ),
              if (_correct[_activeScenario])
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    '= ${cfg.resultStr}',
                    style: TextStyle(
                      color: success,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlot(int index) {
    PieceModel? piece = _slots[_activeScenario][index];
    bool isLocked = _correct[_activeScenario];

    return DragTarget<PieceModel>(
      onWillAccept: (data) => piece == null && !isLocked,
      onAccept: (data) {
        playDropdown();
        setState(() {
          _tray[_activeScenario].remove(data);
          _slots[_activeScenario][index] = data;
        });
      },
      builder: (context, candidateData, rejectedData) {
        bool hover = candidateData.isNotEmpty;
        return GestureDetector(
          onTap: () {
            // Click to remove piece back to tray if not locked
            if (piece != null && !isLocked) {
              playClick();
              setState(() {
                _slots[_activeScenario][index] = null;
                _tray[_activeScenario].add(piece);
              });
            }
          },
          child: Container(
            width: 60,
            height: 50,
            decoration: BoxDecoration(
              color: piece != null
                  ? _getPieceColor(piece.kind)
                  : (hover ? accent.withOpacity(0.2) : bgBase),
              border: Border.all(
                color: hover ? accent : borderColor,
                width: 2,
                style: piece != null ? BorderStyle.solid : BorderStyle.none,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: piece != null
                ? Text(
                    piece.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildDraggable(PieceModel piece) {
    Widget visual = Container(
      width: 60,
      height: 50,
      decoration: BoxDecoration(
        color: _getPieceColor(piece.kind),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        piece.label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );

    if (_correct[_activeScenario]) return visual;

    return Draggable<PieceModel>(
      data: piece,
      onDragStarted: () => playClick(),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(scale: 1.1, child: visual),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: visual),
      child: visual,
    );
  }

  Color _getPieceColor(String kind) {
    switch (kind) {
      case 'a2':
        return const Color(0xFFF97316);
      case 'ab':
        return const Color(0xFF3B82F6);
      case 'b2':
        return const Color(0xFFEAB308);
      default:
        return const Color(0xFF64748B);
    }
  }

  void _checkSubmission(bool allSlotsFilled) {
    ScenarioConfig cfg = scenarios[_activeScenario];

    if (cfg.bTarget != _bValues[_activeScenario]) {
      playError();
      _showFlash(t('flash_split_first'));
      return;
    }
    if (!allSlotsFilled) {
      playError();
      _showFlash(t('flash_fill'));
      return;
    }

    // Validate structure (a2, ab, ab, b2)
    var s = _slots[_activeScenario];
    bool piecesOk =
        s[0]?.kind == 'a2' &&
        s[1]?.kind == 'ab' &&
        s[2]?.kind == 'ab' &&
        s[3]?.kind == 'b2';
    // Ensure distinct ab pieces
    bool distinctAb = s[1]?.id != s[2]?.id;

    // Validate Input
    String cVal = _confirmVals[_activeScenario].trim();
    bool valOk = cVal == cfg.confirmTarget.toString();

    setState(() {
      _submitted[_activeScenario] = true;
      if (piecesOk && distinctAb && valOk) {
        playPageOpen();
        _correct[_activeScenario] = true;
        if (_correct.where((e) => e).length == 4) {
          _showFlash(t('flash_all_solved'));
        } else {
          _showFlash(t('flash_scen_solved'));
        }
      } else {
        playError();
        _correct[_activeScenario] = false;
        _showFlash(t('flash_check'));
      }
    });
  }

  Widget _buildCurtain() {
    return Positioned.fill(
      child: Container(
        color: bgBase,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.extension, size: 80, color: accent),
              const SizedBox(height: 24),
              Text(
                t('app_title'),
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t('app_subtitle'),
                style: TextStyle(color: textSecondary, fontSize: 18),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  curtainScreen();
                  setState(() => _showCurtain = false);
                },
                child: Text(t('start_mission')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SquarePainter extends CustomPainter {
  final ScenarioMode mode;
  final int total;
  final int b;

  SquarePainter({required this.mode, required this.total, required this.b});

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;

    Paint border = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Proportions
    double fa, fb;
    if (mode == ScenarioMode.build) {
      double a = (total - b).toDouble();
      fa = a / total;
      fb = b / total;
    } else {
      fa = (total - b) / total;
      fb = b / total;
    }

    double aw = w * fa;
    double bw = w * fb;

    // Rectangles
    Rect tl = Rect.fromLTWH(0, 0, aw, aw);
    Rect tr = Rect.fromLTWH(aw, 0, bw, aw);
    Rect bl = Rect.fromLTWH(0, aw, aw, bw);
    Rect br = Rect.fromLTWH(aw, aw, bw, bw);

    Paint pA2 = Paint()..color = const Color(0xFFF97316); // a2
    Paint pAB = Paint()..color = const Color(0xFF3B82F6); // ab
    Paint pB2 = Paint()..color = const Color(0xFFEAB308); // b2
    Paint pBase = Paint()..color = const Color(0x22F97316); // dim base

    if (mode == ScenarioMode.build) {
      canvas.drawRect(tl, pA2);
      canvas.drawRect(tr, pAB);
      canvas.drawRect(bl, pAB);
      canvas.drawRect(br, pB2);
    } else {
      // In remove mode, base square is fully a^2, and strips are removed.
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), pBase);
      // Highlight the result (a-b)^2 area
      canvas.drawRect(tl, Paint()..color = const Color(0x4D22C55E));
      canvas.drawRect(tr, pAB);
      canvas.drawRect(bl, pAB);
      canvas.drawRect(br, pB2);
    }

    // Draw dividers
    Paint dashed = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    _drawDashedLine(canvas, Offset(aw, 0), Offset(aw, h), dashed);
    _drawDashedLine(canvas, Offset(0, aw), Offset(w, aw), dashed);

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), border);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 5;
    const double dashSpace = 5;
    double distance = (p2 - p1).distance;
    double dashes = distance / (dashWidth + dashSpace);

    double dx = (p2.dx - p1.dx) / dashes;
    double dy = (p2.dy - p1.dy) / dashes;

    Offset start = p1;
    for (int i = 0; i < dashes; i++) {
      Offset end =
          start +
          Offset(
            dx * (dashWidth / (dashWidth + dashSpace)),
            dy * (dashWidth / (dashWidth + dashSpace)),
          );
      canvas.drawLine(start, end, paint);
      start += Offset(dx, dy);
    }
  }

  @override
  bool shouldRepaint(covariant SquarePainter oldDelegate) {
    return oldDelegate.mode != mode ||
        oldDelegate.total != total ||
        oldDelegate.b != b;
  }
}
