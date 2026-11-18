// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

// --- NETWORK AUDIO SOURCES ---
const String _clickUrl = 'audio/class9/click.mp3';
const String _successUrl = 'audio/class9/success.mp3';
const String _errorUrl = 'audio/class9/error.mp3'; // Exact error buzzer requested
const String _alertUrl = 'audio/class9/alert.mp3';
const String _shutterUrl = 'audio/class9/shutter.mp3'; // Exact shutter opening requested

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CricketScorerApp());
}

// --- THEME MANAGEMENT ---
class AppTheme {
  static const Color bg = Color(0xFF020617); // Slate 950
  static const Color surface = Color(0xFF0F172A); // Slate 900
  static const Color text = Color(0xFFF8FAFC);
  static const Color muted = Color(0xFF94A3B8);
  static const Color accent = Color(0xFFA3E635); // Lime/Cricket Green
  static const Color primary = Color(0xFF3B82F6); // Blue
  static const Color secondary = Color(0xFFF59E0B); // Amber
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color error = Color(0xFFEF4444); // Red
  static const Color gridLine = Color(0xFF1E293B);
  static const Color gridAxis = Color(0xFF64748B);
}

// --- DATA MODELS ---
class LevelData {
  final int id;
  final String scenarioKey;
  final String scenarioDescKey; // Detailed description
  final String displayEq;
  final int scale;
  final int requiredPoints;
  final bool Function(int x, int y) validator;

  LevelData({
    required this.id,
    required this.scenarioKey,
    required this.scenarioDescKey,
    required this.displayEq,
    required this.scale,
    this.requiredPoints = 2,
    required this.validator,
  });
}

class LogEntry {
  final String message;
  final bool isSuccess;
  LogEntry(this.message, this.isSuccess);
}

// --- LOCALIZATION ---
final Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': "THE CRICKET SCORER",
    'tagline': "LINEAR WORD PROBLEMS",
    'init_btn': "ENTER FIELD",
    'header_subtitle': "Class 9 • LINEAR EQUATIONS - Word Problems",
    'btn_start_lab': "Start Match",
    'lab_mission_header': "MATCH SCENARIO",
    'ctrl_panel': "Scoreboard Log",
    'instruction': "Valid Solutions Plotted:",
    'btn_restart': "Play Again",
    'btn_retry': "Clear Field",
    'msg_point_plotted': "Great Shot! Point logged.",
    'err_incorrect': "Howzat?! That point doesn't fit the scenario.",
    'sys_reset': "Reset System",
    'sys_init': "System Initialized.",
    'hud_equation': "DERIVED EQUATION",
    
    // Level Scenarios
    'lvl1_scenario': "Virat (x) and Rohit (y) scored 100 runs together in a partnership.",
    'lvl1_desc': "Tap on the grid to plot two points where the sum of X (Virat's runs) and Y (Rohit's runs) equals exactly 100. (e.g., 40 and 60).",
    
    'lvl2_scenario': "Dhoni (y) scored exactly twice as many runs as Raina (x).",
    'lvl2_desc': "Plot two points where the Y-coordinate is exactly double the X-coordinate. (e.g., X=20, Y=40).",
    
    'lvl3_scenario': "The team's score (x) is 30 runs more than the opponent's score (y).",
    'lvl3_desc': "Plot two points where the difference between X and Y is exactly 30. (e.g., X=50, Y=20).",
    
    'lvl4_scenario': "Sachin (x) and Yuvraj (y) hit a quick partnership of 50 runs.",
    'lvl4_desc': "Notice the grid scale is now 5s! Find two points where the X and Y coordinates sum up to 50.",
    
    'lvl5_scenario': "Ashwin (y) scored 20 runs more than Jadeja (x).",
    'lvl5_desc': "Plot two points where the Y value is exactly 20 greater than the X value. (e.g., X=10, Y=30).",

    'modal_title': "Match Won!",
    'modal_desc': "You have successfully analyzed and mapped all cricket scenarios.",
  },
  'hi': {
    'app_title': "क्रिकेट स्कोरर",
    'tagline': "रैखिक शब्द समस्याएं",
    'init_btn': "मैदान में प्रवेश करें",
    'header_subtitle': "कक्षा 9 • रैखिक समीकरण – शब्द समस्याएं",
    'btn_start_lab': "मैच शुरू करें",
    'lab_mission_header': "मैच परिदृश्य",
    'ctrl_panel': "स्कोरबोर्ड लॉग",
    'instruction': "प्लॉट किए गए मान्य समाधान:",
    'btn_restart': "फिर से खेलें",
    'btn_retry': "फ़ील्ड साफ़ करें",
    'msg_point_plotted': "बढ़िया शॉट! बिंदु दर्ज किया गया।",
    'err_incorrect': "हाउज़ैट?! वह बिंदु परिदृश्य में फिट नहीं बैठता।",
    'sys_reset': "सिस्टम रीसेट करें",
    'sys_init': "सिस्टम प्रारंभ हुआ।",
    'hud_equation': "व्युत्पन्न समीकरण",

    // Level Scenarios
    'lvl1_scenario': "विराट (x) और रोहित (y) ने साझेदारी में मिलकर 100 रन बनाए।",
    'lvl1_desc': "ग्रिड पर ऐसे दो बिंदु प्लॉट करें जहां X (विराट के रन) और Y (रोहित के रन) का योग 100 हो। (उदा., 40 और 60)।",
    
    'lvl2_scenario': "धोनी (y) ने रैना (x) से ठीक दोगुने रन बनाए।",
    'lvl2_desc': "ऐसे दो बिंदु प्लॉट करें जहां Y-निर्देशांक X-निर्देशांक का ठीक दोगुना हो। (उदा., X=20, Y=40)।",
    
    'lvl3_scenario': "टीम का स्कोर (x) प्रतिद्वंद्वी के स्कोर (y) से 30 रन अधिक है।",
    'lvl3_desc': "ऐसे दो बिंदु प्लॉट करें जहां X और Y के बीच का अंतर ठीक 30 हो। (उदा., X=50, Y=20)।",
    
    'lvl4_scenario': "सचिन (x) और युवराज (y) ने 50 रनों की तेज साझेदारी की।",
    'lvl4_desc': "ग्रिड पैमाने पर ध्यान दें जो अब 5 है! ऐसे दो बिंदु खोजें जहां X और Y का योग 50 हो।",
    
    'lvl5_scenario': "अश्विन (y) ने जडेजा (x) से 20 रन अधिक बनाए।",
    'lvl5_desc': "ऐसे दो बिंदु प्लॉट करें जहां Y मान X से ठीक 20 अधिक हो। (उदा., X=10, Y=30)।",

    'modal_title': "मैच जीत लिया!",
    'modal_desc': "आपने सभी क्रिकेट परिदृश्यों का सफलतापूर्वक विश्लेषण और मानचित्रण किया है।",
  },
};

class CricketScorerApp extends StatelessWidget {
  const CricketScorerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'The Cricket Scorer',
      debugShowCheckedModeBanner: false,
      home: CricketScorerScreen(),
    );
  }
}

class CricketScorerScreen extends StatefulWidget {
  const CricketScorerScreen({Key? key}) : super(key: key);

  @override
  State<CricketScorerScreen> createState() => _CricketScorerScreenState();
}

class _CricketScorerScreenState extends State<CricketScorerScreen>
    with TickerProviderStateMixin {
  // Core State
  bool _showShutter = true;
  bool _sidebarOpen = true;
  bool missionComplete = false;
  String currentLang = 'en';

  // View State (Panning & Zooming)
  Offset _panOffset = Offset.zero;
  double _zoomScale = 1.0;
  double _previousZoom = 1.0;

  // Game State
  int currentLevelIndex = 0;
  List<Offset> plottedPoints = []; // Logical grid points
  bool isLineActive = false;
  List<LogEntry> logs = [];

  final List<LevelData> levels = [
    LevelData(
      id: 1,
      scenarioKey: 'lvl1_scenario',
      scenarioDescKey: 'lvl1_desc',
      displayEq: "x + y = 100",
      scale: 10,
      validator: (x, y) => x + y == 100,
    ),
    LevelData(
      id: 2,
      scenarioKey: 'lvl2_scenario',
      scenarioDescKey: 'lvl2_desc',
      displayEq: "y = 2x",
      scale: 10,
      validator: (x, y) => y == 2 * x,
    ),
    LevelData(
      id: 3,
      scenarioKey: 'lvl3_scenario',
      scenarioDescKey: 'lvl3_desc',
      displayEq: "x - y = 30",
      scale: 10,
      validator: (x, y) => x - y == 30,
    ),
    LevelData(
      id: 4,
      scenarioKey: 'lvl4_scenario',
      scenarioDescKey: 'lvl4_desc',
      displayEq: "x + y = 50",
      scale: 5,
      validator: (x, y) => x + y == 50,
    ),
    LevelData(
      id: 5,
      scenarioKey: 'lvl5_scenario',
      scenarioDescKey: 'lvl5_desc',
      displayEq: "y = x + 20",
      scale: 10,
      validator: (x, y) => y == x + 20,
    ),
  ];

  // Overlays
  String? _bannerMessage;
  String? _bannerType;

  // Animations & Audio
  late AnimationController _pulseController;
  late AnimationController _celebrationController;
  final ScrollController _hudScrollController = ScrollController();
  
  late final AudioPlayer _clickPlayer;
  late final AudioPlayer _fxPlayer;
  late final AudioPlayer _successPlayer;
  late final AudioPlayer _errorPlayer;
  late final AudioPlayer _shutterPlayer;

  String t(String key) => i18n[currentLang]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _pulseController.dispose();
    _celebrationController.dispose();
    _hudScrollController.dispose();
    
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _shutterPlayer.dispose();
    super.dispose();
  }

  void _playSound(AudioPlayer player, String url) async {
    try {
      await player.stop();
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio Playback Error: $e");
    }
  }

  void _addLog(String key, {Map<String, String>? params, bool isSuccess = true, bool raw = false}) {
    String msg = raw ? key : (i18n[currentLang]![key] ?? key);
    if (params != null) {
      params.forEach((k, v) {
        msg = msg.replaceAll('{$k}', v);
      });
    }
    setState(() {
      logs.insert(0, LogEntry("> $msg", isSuccess));
      if (logs.length > 20) logs.removeLast();
    });
  }

  void _onGridTap(Offset localPosition, Size size) {
    if (missionComplete || isLineActive || _showShutter) return;

    double gridSize = math.min(size.width, size.height);
    double unitSize = (gridSize / 12) * _zoomScale;
    Offset center = Offset(size.width / 2, size.height / 2) + _panOffset;

    double dx = localPosition.dx - center.dx;
    double dy = center.dy - localPosition.dy; // Invert Y for Cartesian

    int gridX = (dx / unitSize).round().clamp(-10, 10);
    int gridY = (dy / unitSize).round().clamp(-10, 10);

    Offset newPoint = Offset(gridX.toDouble(), gridY.toDouble());

    // Prevent duplicate points
    if (plottedPoints.contains(newPoint)) return;

    LevelData currentLevel = levels[currentLevelIndex];
    int actualX = gridX * currentLevel.scale;
    int actualY = gridY * currentLevel.scale;

    // Check if the values satisfy the scenario
    if (currentLevel.validator(actualX, actualY)) {
      setState(() {
        plottedPoints.add(newPoint);
      });
      _addLog("Point ($actualX, $actualY) verified.", raw: true, isSuccess: true);
      
      if (plottedPoints.length >= currentLevel.requiredPoints) {
        _playSound(_fxPlayer, _alertUrl);
        _activateLine();
      } else {
        HapticFeedback.selectionClick();
        _playSound(_clickPlayer, _clickUrl);
        _showBanner('success', t('msg_point_plotted'));
      }
    } else {
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
      _addLog("Attempt ($actualX, $actualY) failed.", raw: true, isSuccess: false);
      _showBanner('error', t('err_incorrect'));
    }
  }

  void _activateLine() {
    setState(() {
      isLineActive = true;
    });
    _addLog("TRAJECTORY CONFIRMED!", raw: true, isSuccess: true);
    _showBanner('success', "TRAJECTORY CONFIRMED!");

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      if (currentLevelIndex < levels.length - 1) {
        setState(() {
          currentLevelIndex++;
          plottedPoints.clear();
          isLineActive = false;
          _addLog("Match ${currentLevelIndex + 1} initialized.", raw: true, isSuccess: true);
        });
      } else {
        _playSound(_successPlayer, _successUrl);
        setState(() {
          missionComplete = true;
          _celebrationController.forward();
        });
      }
    });
  }

  void hardReset() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      currentLevelIndex = 0;
      missionComplete = false;
      plottedPoints.clear();
      isLineActive = false;
      logs.clear();
      _panOffset = Offset.zero;
      _zoomScale = 1.0;
      _addLog("System Rebooted.", raw: true, isSuccess: true);
      _addLog("Match 1 initialized.", raw: true, isSuccess: true);
      _celebrationController.reset();
      _sidebarOpen = true;
      _showShutter = true;
    });
  }

  void resetLevel() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      plottedPoints.clear();
      isLineActive = false;
    });
  }

  void _showBanner(String type, String message) {
    setState(() {
      _bannerType = type;
      _bannerMessage = message;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _bannerMessage == message) {
        setState(() => _bannerMessage = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double sidebarWidth = screenW * 0.38; // Strict 38% Width

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        body: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Expandable Sidebar Container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _sidebarOpen ? sidebarWidth : 0,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: const Border(right: BorderSide(color: Colors.white10)),
                  ),
                  child: ClipRect(
                    child: OverflowBox(
                      minWidth: 0,
                      maxWidth: sidebarWidth,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: sidebarWidth,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                          child: _buildSidebarContent(),
                        ),
                      ),
                    ),
                  ),
                ),

                // Main Workspace
                Expanded(
                  child: ClipRect(
                    child: _buildMainWorkspace()
                  )
                ),
              ],
            ),

            // Floating HUD - Bottom Left Docked
            if (!_sidebarOpen && !_showShutter && !missionComplete)
              _buildFloatingHUD(screenW),

            // Top Left Menu Button
            if (!_showShutter)
              Positioned(
                top: 16,
                left: 16,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    icon: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu),
                    color: Colors.white,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _playSound(_clickPlayer, _clickUrl);
                      setState(() => _sidebarOpen = !_sidebarOpen);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),

            // Overlays
            if (_bannerMessage != null) _buildBanner(),
            if (missionComplete && !_showShutter) _buildSuccessModal(),
            if (_showShutter) _buildCurtain(),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSidebarContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 56),

          Text(
            t('app_title'),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.1),
          ),
          const SizedBox(height: 4),
          Text(
            t('header_subtitle'),
            style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 24),

          // Settings Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                ),
                child: Row(children: [_langBtn('en', 'EN'), _langBtn('hi', 'HI')]),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.error.withOpacity(0.6), width: 2.0),
                ),
                child: IconButton(
                  icon: const Icon(Icons.power_settings_new, color: AppTheme.error),
                  tooltip: t('sys_reset'),
                  onPressed: () {
                    HapticFeedback.vibrate();
                    hardReset();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildLabContent(),

          const SizedBox(height: 32),
          const Center(
            child: Text(
              "© ZEROSCIENCELAB | Fall in Love with Math and Science",
              style: TextStyle(color: Colors.white38, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _langBtn(String code, String label) {
    bool active = currentLang == code;
    return GestureDetector(
      onTap: () {
        if (!active) {
          HapticFeedback.selectionClick();
          _playSound(_clickPlayer, _clickUrl);
          setState(() => currentLang = code);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppTheme.bg : Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLabContent() {
    if (missionComplete) return const SizedBox.shrink();
    LevelData level = levels[currentLevelIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Objective Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.muted.withOpacity(0.2), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t('lab_mission_header'), style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Text('${currentLevelIndex + 1}/${levels.length}', style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                t(level.scenarioKey),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
              ),
              const SizedBox(height: 8),
              Text(
                t(level.scenarioDescKey),
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic, height: 1.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Controls Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accent.withOpacity(0.5), width: 2),
            boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.1), blurRadius: 20)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(t('hud_equation'), style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text(level.displayEq, style: const TextStyle(color: AppTheme.accent, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t('instruction'), style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                  const SizedBox(width: 8),
                  Text("${plottedPoints.length} / ${level.requiredPoints}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              
              const SizedBox(height: 24),
              // Logs Area inside sidebar
              Container(
                height: 120, // Constrained log height
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.muted.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('ctrl_panel').toUpperCase(), style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              log.message,
                              style: TextStyle(color: log.isSuccess ? AppTheme.success : AppTheme.error, fontSize: 11, fontFamily: 'monospace'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.muted,
                  side: BorderSide(color: AppTheme.muted.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: resetLevel,
                icon: const Icon(Icons.refresh),
                label: Text(t('btn_retry').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingHUD(double screenW) {
    LevelData level = levels[currentLevelIndex];
    // Exact 38% width
    double hudWidth = screenW * 0.38;

    return Positioned(
      bottom: 20, 
      left: 20, // LEFT side perfectly docked
      child: Container(
        width: hudWidth,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: Colors.black87.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: const Border(left: BorderSide(color: AppTheme.success, width: 4)),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: RawScrollbar(
            controller: _hudScrollController,
            thumbColor: AppTheme.accent.withOpacity(0.8),
            radius: const Radius.circular(4),
            thickness: 4,
            crossAxisMargin: 2, // Keeps scrollbar safely on the right edge
            thumbVisibility: true,
            child: SingleChildScrollView( 
              controller: _hudScrollController,
              padding: const EdgeInsets.all(16.0), // Padding applied here keeps text safely away from scrollbar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t('lab_mission_header').toUpperCase(), style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text('SCENARIO ${currentLevelIndex + 1}/${levels.length}', style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t(level.scenarioKey),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t(level.scenarioDescKey),
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic, height: 1.3),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10)),
                  
                  Center(
                    child: Text(
                      level.displayEq,
                      style: const TextStyle(color: AppTheme.secondary, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t('instruction'), style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                      Text("${plottedPoints.length} / ${level.requiredPoints}", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.muted,
                      side: BorderSide(color: AppTheme.muted.withOpacity(0.5)),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: resetLevel,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(t('btn_retry').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainWorkspace() {
    LevelData? currentLevel = currentLevelIndex < levels.length ? levels[currentLevelIndex] : null;
    int scale = currentLevel?.scale ?? 10;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF020617)],
                  center: Alignment.center,
                  radius: 1.0,
                ),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: (details) {
                  _previousZoom = _zoomScale;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    _zoomScale = (_previousZoom * details.scale).clamp(0.5, 4.0);
                    _panOffset += details.focalPointDelta;
                    _panOffset = Offset(
                      _panOffset.dx.clamp(-constraints.maxWidth * 2, constraints.maxWidth * 2),
                      _panOffset.dy.clamp(-constraints.maxHeight * 2, constraints.maxHeight * 2),
                    );
                  });
                },
                onTapDown: (details) => _onGridTap(details.localPosition, Size(constraints.maxWidth, constraints.maxHeight)),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: CartesianGridPainter(
                    fontScale: 1.0,
                    plottedPoints: plottedPoints,
                    isLineActive: isLineActive,
                    animationValue: _pulseController.value,
                    scale: scale,
                    panOffset: _panOffset,
                    zoomScale: _zoomScale,
                  ),
                ),
              ),
            ),
            
            // Recenter Button
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                heroTag: 'recenter_btn',
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.white24)),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() { _panOffset = Offset.zero; _zoomScale = 1.0; });
                },
                child: const Icon(Icons.center_focus_strong, size: 20),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBanner() {
    bool isSuccess = _bannerType == 'success';
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      top: _bannerMessage != null ? 30 : -100, 
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: isSuccess ? AppTheme.success.withOpacity(0.9) : AppTheme.error.withOpacity(0.9),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: isSuccess ? Colors.greenAccent : Colors.redAccent),
            boxShadow: [BoxShadow(color: isSuccess ? AppTheme.success.withOpacity(0.5) : AppTheme.error.withOpacity(0.5), blurRadius: 30)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isSuccess ? Icons.check_circle : Icons.warning, color: AppTheme.bg, size: 24),
              const SizedBox(width: 12),
              Text(_bannerMessage ?? '', style: const TextStyle(color: AppTheme.bg, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessModal() {
    return Container(
      color: Colors.black87,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut)),
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.success, width: 4),
                  boxShadow: [BoxShadow(color: AppTheme.success.withOpacity(0.3), blurRadius: 40, spreadRadius: 10)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events, color: AppTheme.success, size: 80),
                    const SizedBox(height: 24),
                    Text(t('modal_title'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                    const SizedBox(height: 16),
                    Text(t('modal_desc'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _playSound(_shutterPlayer, _shutterUrl);
                        hardReset();
                      },
                      icon: const Icon(Icons.refresh, color: AppTheme.bg),
                      label: Text(t('btn_restart'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.bg, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurtain() {
    return Container(
      color: AppTheme.bg,
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) => Container(
                    width: 140 + (_pulseController.value * 30),
                    height: 140 + (_pulseController.value * 30),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.accent.withOpacity(0.2)),
                  ),
                ),
                const Icon(Icons.sports_cricket, size: 80, color: AppTheme.accent),
              ],
            ),
            const SizedBox(height: 20),
            Text(t('app_title'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2, shadows: [Shadow(color: AppTheme.accent, blurRadius: 15)])),
            const SizedBox(height: 10),
            Text(t('tagline'), style: const TextStyle(fontSize: 16, letterSpacing: 4, color: AppTheme.secondary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                _playSound(_shutterPlayer, _shutterUrl);
                setState(() {
                  _showShutter = false;
                });
                _addLog('sys_init');
                _addLog("Match 1 initialized.", raw: true, isSuccess: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.bg,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 10,
                shadowColor: AppTheme.accent.withOpacity(0.5),
              ),
              child: Text(t('init_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTERS ---

class CartesianGridPainter extends CustomPainter {
  final double fontScale;
  final List<Offset> plottedPoints;
  final bool isLineActive;
  final double animationValue;
  final int scale;
  final Offset panOffset;
  final double zoomScale;

  CartesianGridPainter({
    required this.fontScale,
    required this.plottedPoints,
    required this.isLineActive,
    required this.animationValue,
    required this.scale,
    required this.panOffset,
    required this.zoomScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double gridSize = math.min(size.width, size.height);
    // Adjusted to 12 for a highly spacious, readable grid
    double unitSize = (gridSize / 12) * zoomScale; 
    Offset center = Offset(size.width / 2, size.height / 2) + panOffset;

    final Paint gridPaint = Paint()
      ..color = AppTheme.gridLine
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Paint axisPaintX = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final Paint axisPaintY = Paint()
      ..color = AppTheme.secondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Strict 10x10 bounds
    double gridLimit = 10.5 * unitSize; 

    for (int i = -10; i <= 10; i++) {
      double offset = i * unitSize;
      canvas.drawLine(Offset(center.dx - gridLimit, center.dy + offset), Offset(center.dx + gridLimit, center.dy + offset), i == 0 ? axisPaintX : gridPaint); // Horiz
      canvas.drawLine(Offset(center.dx + offset, center.dy - gridLimit), Offset(center.dx + offset, center.dy + gridLimit), i == 0 ? axisPaintY : gridPaint); // Vert
    }

    TextStyle textStyle = const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold);

    for (int i = -10; i <= 10; i++) {
      if (i == 0) continue; 
      double offset = i * unitSize;
      
      // Removed the i % 2 == 0 condition so every label prints
      _drawText(canvas, (i * scale).toString(), Offset(center.dx + offset, center.dy + 14), textStyle);
      _drawText(canvas, '${-(i * scale)}', Offset(center.dx - 24, center.dy + offset), textStyle);
    }
    _drawText(canvas, '0', Offset(center.dx - 14, center.dy + 14), textStyle);

    // Draw Plotted Points
    final Paint pointPaint = Paint()..color = AppTheme.success..style = PaintingStyle.fill;
    final Paint pointBorderPaint = Paint()..color = Colors.white..strokeWidth = 2..style = PaintingStyle.stroke;

    for (Offset p in plottedPoints) {
      double px = center.dx + (p.dx * unitSize);
      double py = center.dy - (p.dy * unitSize);
      canvas.drawCircle(Offset(px, py), unitSize * 0.4, pointPaint);
      canvas.drawCircle(Offset(px, py), unitSize * 0.4, pointBorderPaint);
    }

    // Draw Connecting Trajectory Line extending through the whole 10x10 grid
    if (isLineActive && plottedPoints.length >= 2) {
      Offset p1 = plottedPoints[0];
      Offset p2 = plottedPoints[1];

      double x1 = p1.dx, y1 = p1.dy;
      double x2 = p2.dx, y2 = p2.dy;

      double startX = -10, startY;
      double endX = 10, endY;

      if (x1 == x2) {
        startX = x1; startY = -10;
        endX = x1; endY = 10;
      } else {
        double m = (y2 - y1) / (x2 - x1);
        double c = y1 - m * x1;
        startY = m * startX + c;
        endY = m * endX + c;
      }

      Offset screenStart = Offset(center.dx + (startX * unitSize), center.dy - (startY * unitSize));
      Offset screenEnd = Offset(center.dx + (endX * unitSize), center.dy - (endY * unitSize));

      final Paint lineGlowPaint = Paint()
        ..color = AppTheme.accent.withOpacity(0.4 + (animationValue * 0.4))
        ..strokeWidth = unitSize * 0.8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final Paint lineCorePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = unitSize * 0.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(screenStart, screenEnd, lineGlowPaint);
      canvas.drawLine(screenStart, screenEnd, lineCorePaint);
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final textPainter = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr, textAlign: TextAlign.center)..layout();
    textPainter.paint(canvas, Offset(offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CartesianGridPainter oldDelegate) {
    return oldDelegate.fontScale != fontScale ||
           oldDelegate.plottedPoints.length != plottedPoints.length || 
           oldDelegate.isLineActive != isLineActive || 
           oldDelegate.animationValue != animationValue || 
           oldDelegate.scale != scale || 
           oldDelegate.panOffset != panOffset || 
           oldDelegate.zoomScale != zoomScale;
  }
}