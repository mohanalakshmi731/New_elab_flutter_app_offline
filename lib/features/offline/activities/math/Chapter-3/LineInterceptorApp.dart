// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LineInterceptorApp(),
    ),
  );
}

// --- DATA MODELS ---
class PointF {
  final double x;
  final double y;
  const PointF(this.x, this.y);
}

class LineData {
  final double m;
  final double c;
  final List<PointF> points;
  const LineData({required this.m, required this.c, required this.points});
}

class SystemData {
  final int id;
  final String eq1;
  final String eq2;
  final String type;
  final String res;
  final LineData line1;
  final LineData line2;
  final PointF? intersection;

  const SystemData({
    required this.id,
    required this.eq1,
    required this.eq2,
    required this.type,
    required this.res,
    required this.line1,
    required this.line2,
    this.intersection,
  });
}

// --- CONSTANTS & DATA ---
const List<SystemData> kSystems = [
  SystemData(
    id: 0,
    eq1: "x + y = 3",
    eq2: "2x - y = 3",
    type: "intersect",
    res: "Intersecting at (2, 1)",
    line1: LineData(m: -1, c: 3, points: [PointF(0, 3), PointF(3, 0)]),
    line2: LineData(m: 2, c: -3, points: [PointF(0, -3), PointF(1, -1)]),
    intersection: PointF(2, 1),
  ),
  SystemData(
    id: 1,
    eq1: "2x + 4y = 10",
    eq2: "3x + 6y = 12",
    type: "parallel",
    res: "Parallel Lines",
    line1: LineData(m: -0.5, c: 2.5, points: [PointF(1, 2), PointF(5, 0)]),
    line2: LineData(m: -0.5, c: 2, points: [PointF(0, 2), PointF(4, 0)]),
  ),
  SystemData(
    id: 2,
    eq1: "x + 2y = 4",
    eq2: "2x + 4y = 8",
    type: "coincident",
    res: "Coincident Lines",
    line1: LineData(m: -0.5, c: 2, points: [PointF(0, 2), PointF(4, 0)]),
    line2: LineData(m: -0.5, c: 2, points: [PointF(-2, 3), PointF(2, 1)]),
  ),
  SystemData(
    id: 3,
    eq1: "2x - y = 4",
    eq2: "x + y = 5",
    type: "intersect",
    res: "Intersecting at (3, 2)",
    line1: LineData(m: 2, c: -4, points: [PointF(0, -4), PointF(2, 0)]),
    line2: LineData(m: -1, c: 5, points: [PointF(0, 5), PointF(5, 0)]),
    intersection: PointF(3, 2),
  ),
  SystemData(
    id: 4,
    eq1: "x + 2y = 6",
    eq2: "2x + 4y = 16",
    type: "parallel",
    res: "Parallel Lines",
    line1: LineData(m: -0.5, c: 3, points: [PointF(0, 3), PointF(6, 0)]),
    line2: LineData(m: -0.5, c: 4, points: [PointF(0, 4), PointF(8, 0)]),
  ),
];

const Map<String, Map<String, String>> kI18N = {
  'en': {
    'app_title': 'THE LINE INTERCEPTOR',
    'tagline': 'GRAPHICAL METHOD & CONSISTENCY • CLASS 10',
    'init_btn': 'ACTIVATE GRID',
    'header_title': 'The Line Interceptor',
    'header_subtitle': 'CLASS 10 • PAIR OF LINEAR EQUATIONS',
    'btn_restart': 'Reset Grid',
    'lbl_progress': 'Grid Analysis',
    'hud_status': 'Grid Status',
    'lbl_select_sys': 'Select Equation Pair',
    'btn_load': 'INITIATE PLOT',
    'msg_plot1': 'Calculating Trajectory for Line 1',
    'btn_plot1': 'FIRE LASER 1',
    'msg_plot2': 'Calculating Trajectory for Line 2',
    'btn_plot2': 'FIRE LASER 2',
    'msg_analyze': 'Observe Laser Interaction',
    'msg_success': 'ANALYSIS COMPLETE',
    'btn_next': 'Next System',
  },
  'hi': {
    'app_title': 'लाइन इंटरसेप्टर',
    'tagline': 'ग्राफिकल विधि और संगतता • कक्षा 10',
    'init_btn': 'ग्रिड सक्रिय करें',
    'header_title': 'लाइन इंटरसेप्टर',
    'header_subtitle': 'कक्षा 10 • रैखिक समीकरण युग्म',
    'btn_restart': 'ग्रिड रीसेट करें',
    'lbl_progress': 'ग्रिड विश्लेषण',
    'hud_status': 'ग्रिड स्थिति',
    'lbl_select_sys': 'समीकरण युग्म चुनें',
    'btn_load': 'प्लॉट शुरू करें',
    'msg_plot1': 'लाइन 1 के लिए प्रक्षेपवक्र की गणना',
    'btn_plot1': 'लेजर 1 फायर करें',
    'msg_plot2': 'लाइन 2 के लिए प्रक्षेपवक्र की गणना',
    'btn_plot2': 'लेजर 2 फायर करें',
    'msg_analyze': 'लेजर इंटरेक्शन का निरीक्षण करें',
    'msg_success': 'विश्लेषण पूर्ण',
    'btn_next': 'अगला सिस्टम',
  },
};

class LineInterceptorApp extends StatefulWidget {
  const LineInterceptorApp({Key? key}) : super(key: key);

  @override
  State<LineInterceptorApp> createState() => _LineInterceptorAppState();
}

class _LineInterceptorAppState extends State<LineInterceptorApp>
    with TickerProviderStateMixin {
  bool _showCurtain = true;
  String _lang = 'en';
  bool _isSidebarOpen = true;

  int _step = 1;
  SystemData? _currentSys;
  int _selectedSysId = 0;

  bool _showCelebration = false;
  String _celebrationText = '';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final TransformationController _transformController =
      TransformationController();
  double _currentZoom = 1.0;

  // Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  // Network Audio Sources for guaranteed playback on Android
  static const String _clickUrl = 'audio/math/click.mp3';
  static const String _successUrl = 'audio/math/success.mp3';
  static const String _errorUrl = 'audio/math/error.mp3';
  static const String _shutterUrl = 'audio/math/shutter.mp3';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _transformController.addListener(() {
      setState(() {
        _currentZoom = _transformController.value.getMaxScaleOnAxis();
      });
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _transformController.dispose();
    _pulseController.dispose();

    // Dispose Audio players
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();

    super.dispose();
  }

  void _playSound(AudioPlayer player, String url) async {
    try {
      await player.stop();
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void playClick() => _playSound(_clickPlayer, _clickUrl);
  void playSuccess() => _playSound(_successPlayer, _successUrl);
  void playError() => _playSound(_errorPlayer, _errorUrl);
  void playShutter() => _playSound(_fxPlayer, _shutterUrl);

  String get(String key) {
    return kI18N[_lang]?[key] ?? key;
  }

  void _executeStep(int nextStep) {
    setState(() {
      if (nextStep == 2) {
        _currentSys = kSystems[_selectedSysId];
      }
      _step = nextStep;
    });
  }

  void _checkAnswer(String choice) {
    if (_currentSys == null) return;
    if (choice == _currentSys!.type) {
      playSuccess();
      setState(() {
        _step = 5;
        _showCelebration = true;
        _celebrationText = _currentSys!.res;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showCelebration = false;
          });
        }
      });
    } else {
      playError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect observation. Try again!'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _resetApp() {
    setState(() {
      _step = 1;
      _currentSys = null;
      _showCelebration = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xff0f172a), // Slate 900
        body: Stack(
          children: [
            _buildMainUI(),
            if (_showCelebration) _buildCelebrationOverlay(),
            if (_showCurtain) _buildCurtain(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurtain() {
    return Container(
      color: const Color(0xff020617),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.my_location, size: 80, color: Color(0xfff43f5e)),
          const SizedBox(height: 20),
          Text(
            get('app_title'),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [Shadow(color: Color(0xfff43f5e), blurRadius: 10)],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            get('tagline'),
            style: const TextStyle(
              color: Color(0xfffda4af),
              fontSize: 16,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            icon: const Icon(Icons.power_settings_new, color: Colors.white),
            label: Text(
              get('init_btn'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffe11d48), // Rose 600
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 10,
              shadowColor: const Color(0xfff43f5e),
            ),
            onPressed: () {
              playShutter();
              setState(() {
                _showCurtain = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return Container(
      color: Colors.black87,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "LOCKED!",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xff0f172a).withOpacity(0.9),
                border: Border.all(color: const Color(0xff10b981), width: 2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x8810b981), blurRadius: 20),
                ],
              ),
              child: Text(
                _celebrationText,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff6ee7b7),
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainUI() {
    double screenWidth = MediaQuery.of(context).size.width;
    double panelWidth = screenWidth * 0.38; // Set exactly to 38%
    if (panelWidth < 300)
      panelWidth = 300; // Minimum viable width for the side panel

    return Stack(
      children: [
        // 1. Base Layer: The Main Split Layout
        Row(
          children: [
            // Side Panel with Slide Animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _isSidebarOpen ? panelWidth : 0,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  minWidth: panelWidth,
                  maxWidth: panelWidth,
                  child: _buildSidePanel(),
                ),
              ),
            ),
            // The Canvas Area (Takes up remaining space)
            Expanded(child: _buildCanvasArea()),
          ],
        ),

        // 2. Floating Mission Card (Visible only when side panel is collapsed)
        if (!_isSidebarOpen)
          Positioned(
            top: 70,
            left: 20, // Positioned next to the floating menu button
            child: _buildMissionCard(),
          ),

        // 3. Floating Menu Button (Top Left)
        Positioned(top: 24, left: 24, child: _buildFloatingMenuBtn()),
      ],
    );
  }

  Widget _buildFloatingMenuBtn() {
    return IconButton(
      icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
      color: Colors.white,
      onPressed: () {
        playClick();
        setState(() => _isSidebarOpen = !_isSidebarOpen);
      },
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xff1e293b).withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Colors.white10),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildMissionCard() {
    return Container(
      width: 280, // Keep floating card at a comfortable responsive width
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xff020617).withOpacity(0.95),
        border: const Border(
          left: BorderSide(color: Color(0xfff43f5e), width: 4),
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                get('hud_status'),
                style: const TextStyle(
                  color: Color(0xfffb7185),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Step $_step/5',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _step >= 4 ? "ACTIVE" : "PLOTTING",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 16),
          // Directly embed the interactive controls right in the floating mission card
          _buildInteractiveSteps(),
        ],
      ),
    );
  }

  Widget _buildSidePanel() {
    return Container(
      color: const Color(0xff1e293b),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Scrollable content area expands to push footer down
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            top: 70,
                            right: 24,
                            bottom: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row 1: Titles
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          get('header_title'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          get('header_subtitle'),
                                          style: const TextStyle(
                                            color: Color(0xfffb7185),
                                            fontSize: 10,
                                            letterSpacing: 1.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Row 2: Language Toggles & Restart Action
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xff0f172a,
                                      ).withOpacity(0.5),
                                      border: Border.all(
                                        color: const Color(0xff334155),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: ['en', 'hi'].map((l) {
                                        bool isSelected = _lang == l;
                                        return InkWell(
                                          onTap: () {
                                            playClick();
                                            setState(() => _lang = l);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xffe11d48)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              l.toUpperCase(),
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : const Color(0xff94a3b8),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),

                                  IconButton(
                                    onPressed: () {
                                      playClick();
                                      _resetApp();
                                      setState(() => _showCurtain = true);
                                    },
                                    icon: const Icon(
                                      Icons.power_settings_new,
                                      color: Color(0xfff87171),
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color(0x33ef4444),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),
                              const Divider(color: Colors.white10, height: 1),
                              const SizedBox(height: 24),

                              // Row 3: Explore Content (Lab controls)
                              _buildExploreContent(),
                            ],
                          ),
                        ),
                      ),

                      // Footer (Pinned to bottom via IntrinsicHeight & Expanded parent logic)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xff020617),
                          border: Border(
                            top: BorderSide(color: Color(0xff334155)),
                          ),
                        ),
                        child: const Text(
                          "© ZEROSCIENCELAB | Fall in Love with Math and Science",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xff64748b),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExploreContent() {
    double progress = (_step / 5.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              get('lbl_progress'),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xfffb7185),
                letterSpacing: 1,
              ),
            ),
            Text(
              'Step $_step/5',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color(0xff0f172a),
          color: const Color(0xfff43f5e),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: _buildInteractiveSteps(), // Use the refactored widget here
        ),
      ],
    );
  }

  // Extracted step-by-step logic and buttons used by both Sidebar and Floating Mission Card
  Widget _buildInteractiveSteps() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_step == 1) ...[
          Text(
            get('lbl_select_sys'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xff94a3b8),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xff1e293b),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xff475569)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                itemHeight: null, // Allow dynamic height for multiline items
                dropdownColor: const Color(0xff1e293b),
                value: _selectedSysId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
                items: kSystems
                    .map(
                      (s) => DropdownMenuItem(
                        value: s.id,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Sys ${String.fromCharCode(65 + s.id)}:\n  ${s.eq1}\n  ${s.eq2}',
                            style: const TextStyle(
                              height: 1.4,
                            ), // Improve line spacing
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    playClick();
                    setState(() => _selectedSysId = val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _actionBtn(get('btn_load'), const Color(0xffe11d48), () {
            playClick();
            _executeStep(2);
          }),
        ],
        if (_step == 2) ...[
          Text(
            get('msg_plot1'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xffcbd5e1), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            _currentSys!.eq1,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xfffb7185),
              fontSize: 18,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _actionBtn(get('btn_plot1'), const Color(0xff2563eb), () {
            playClick();
            _executeStep(3);
          }),
        ],
        if (_step == 3) ...[
          Text(
            get('msg_plot2'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xffcbd5e1), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            _currentSys!.eq2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xfffb923c),
              fontSize: 18,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _actionBtn(get('btn_plot2'), const Color(0xff2563eb), () {
            playClick();
            _executeStep(4);
          }),
        ],
        if (_step == 4) ...[
          Text(
            get('msg_analyze'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xffcbd5e1), fontSize: 12),
          ),
          const SizedBox(height: 16),
          _ansBtn('Intersecting (Unique Solution)', 'intersect'),
          const SizedBox(height: 8),
          _ansBtn('Parallel (No Solution)', 'parallel'),
          const SizedBox(height: 8),
          _ansBtn('Coincident (Infinitely Many)', 'coincident'),
        ],
        if (_step == 5) ...[
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0x3310b981),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xff10b981)),
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xff34d399),
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            get('msg_success'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff34d399),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          _actionBtn(get('btn_next'), const Color(0xffe11d48), () {
            playClick();
            setState(() {
              _selectedSysId = (_selectedSysId + 1) % kSystems.length;
            });
            _resetApp();
          }),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              playClick();
              _resetApp();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xff334155)),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(get('btn_restart')),
          ),
        ],
      ],
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _ansBtn(String label, String value) {
    return ElevatedButton(
      onPressed: () => _checkAnswer(value), // Custom plays audio logic inside
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff0f172a),
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white10),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCanvasArea() {
    return Container(
      color: Colors.black,
      child: InteractiveViewer(
        transformationController: _transformController,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        minScale: 0.5,
        maxScale: 4.0,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: GridPainter(
                step: _step,
                currentSys: _currentSys,
                pulseScale: _pulseAnimation.value,
                zoomScale: _currentZoom,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER ---
class GridPainter extends CustomPainter {
  final int step;
  final SystemData? currentSys;
  final double pulseScale;
  final double zoomScale;

  GridPainter({
    required this.step,
    this.currentSys,
    required this.pulseScale,
    required this.zoomScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Center the origin
    canvas.translate(size.width / 2, size.height / 2);

    // Scale mapping logic (Logical -10 to 10 mapped to screen)
    double scale =
        min(size.width, size.height) / 20; // 20 units total (-10 to 10)

    // Dynamic widths based on zoom to keep them responsive
    double gridStroke = 1.0 / zoomScale;
    double axisStroke = 2.0 / zoomScale;
    double axisLabelFontSize = 10.0 / zoomScale;

    // Background and Grid
    final gridPaint = Paint()
      ..color = const Color(0xff1e293b)
      ..strokeWidth = gridStroke;

    for (int i = -10; i <= 10; i++) {
      double pos = i * scale;
      canvas.drawLine(
        Offset(pos, -10 * scale),
        Offset(pos, 10 * scale),
        gridPaint,
      );
      canvas.drawLine(
        Offset(-10 * scale, pos),
        Offset(10 * scale, pos),
        gridPaint,
      );

      // Draw coordinates on axes
      if (i != 0) {
        // X-axis numbers
        _drawText(
          canvas,
          i.toString(),
          Offset(pos, 12 / zoomScale),
          Colors.white54,
          axisLabelFontSize,
          true,
        );
        // Y-axis numbers (negative because y is mathematically up, but visually down in Canvas)
        _drawText(
          canvas,
          (-i).toString(),
          Offset(12 / zoomScale, pos),
          Colors.white54,
          axisLabelFontSize,
          true,
        );
      }
    }

    // Axes
    final axisPaintX = Paint()
      ..color = const Color(0xff3b82f6)
      ..strokeWidth = axisStroke;
    final axisPaintY = Paint()
      ..color = const Color(0xff10b981)
      ..strokeWidth = axisStroke;

    canvas.drawLine(Offset(-10 * scale, 0), Offset(10 * scale, 0), axisPaintX);
    canvas.drawLine(Offset(0, -10 * scale), Offset(0, 10 * scale), axisPaintY);

    if (currentSys != null) {
      if (step >= 3) {
        // Draw Line 1
        _drawLine(
          canvas,
          currentSys!.line1,
          const Color(0xfff43f5e),
          scale,
          false,
        );
      }
      if (step >= 4) {
        // Draw Line 2
        bool isCoincident = currentSys!.type == 'coincident';
        _drawLine(
          canvas,
          currentSys!.line2,
          const Color(0xfff59e0b),
          scale,
          isCoincident,
        );
      }
      if (step >= 4 &&
          currentSys!.type == 'intersect' &&
          currentSys!.intersection != null) {
        _drawIntersection(canvas, currentSys!.intersection!, scale);
      }
    }

    canvas.restore();
  }

  void _drawLine(
    Canvas canvas,
    LineData line,
    Color color,
    double scale,
    bool dash,
  ) {
    double lineStroke = 3.0 / zoomScale;
    final paint = Paint()
      ..color = color
      ..strokeWidth = lineStroke
      ..style = PaintingStyle.stroke;

    // Calculate line endpoints logic
    double x1 = -10;
    double y1 = line.m * x1 + line.c;
    double x2 = 10;
    double y2 = line.m * x2 + line.c;

    Offset p1 = Offset(x1 * scale, -y1 * scale);
    Offset p2 = Offset(x2 * scale, -y2 * scale);

    if (dash) {
      // Simple dash effect by shifting slightly if coincident so both colors are visible
      canvas.save();
      canvas.translate(
        2.0 / zoomScale,
        2.0 / zoomScale,
      ); // Slight offset responsive to zoom
      canvas.drawLine(p1, p2, paint);
      canvas.restore();
    } else {
      canvas.drawLine(p1, p2, paint);
    }

    // Draw Points and Labels
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    double pointRadius = (4.0 * pulseScale) / zoomScale;
    double pointFontSize = 14.0 / zoomScale;

    for (var p in line.points) {
      Offset pos = Offset(p.x * scale, -p.y * scale);

      // Draw point
      canvas.drawCircle(pos, pointRadius, pointPaint);

      // Draw text
      _drawText(
        canvas,
        '${p.x.toInt()}, ${p.y.toInt()}',
        pos,
        color,
        pointFontSize,
        false,
      );
    }
  }

  void _drawIntersection(Canvas canvas, PointF p, double scale) {
    Offset pos = Offset(p.x * scale, -p.y * scale);

    final paint = Paint()
      ..color = const Color(0xff10b981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 / zoomScale;

    canvas.drawCircle(pos, (8.0 * pulseScale) / zoomScale, paint);

    final fillPaint = Paint()
      ..color = const Color(0xff10b981)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 4.0 / zoomScale, fillPaint);

    _drawText(
      canvas,
      'Intersection: ${p.x.toInt()}, ${p.y.toInt()}',
      pos,
      const Color(0xff10b981),
      14.0 / zoomScale,
      false,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    Color color,
    double fontSize,
    bool isAxisLabel,
  ) {
    final textStyle = TextStyle(
      color: isAxisLabel ? color : Colors.white,
      fontSize: fontSize,
      fontWeight: isAxisLabel ? FontWeight.normal : FontWeight.bold,
      background: isAxisLabel
          ? null
          : (Paint()..color = Colors.black.withOpacity(0.7)),
      fontFamily: 'monospace',
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: 300);

    // Adjust offset to display gracefully and responsively around the points/axes
    double yOffset = isAxisLabel
        ? (-textPainter.height / 2)
        : (-24 / zoomScale);
    double xOffset = isAxisLabel && position.dx == (12 / zoomScale)
        ? 0
        : (-textPainter.width / 2);

    if (isAxisLabel) {
      if (position.dy == (12 / zoomScale)) {
        // X axis labels
        xOffset = -textPainter.width / 2;
        yOffset = 4 / zoomScale;
      } else {
        // Y axis labels
        xOffset = 4 / zoomScale;
        yOffset = -textPainter.height / 2;
      }
    }

    final offset = Offset(position.dx + xOffset, position.dy + yOffset);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.step != step ||
        oldDelegate.currentSys != currentSys ||
        oldDelegate.pulseScale != pulseScale ||
        oldDelegate.zoomScale != zoomScale;
  }
}
