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
const String _errorUrl = 'audio/class9/error.mp3'; // Exact error buzzer
const String _alertUrl = 'audio/class9/alert.mp3';
const String _shutterUrl = 'audio/class9/shutter.mp3'; // Exact shutter

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WallBuilderApp());
}

// --- THEME MANAGEMENT ---
class AppTheme {
  static const Color bg = Color(0xFF020617); // Slate 950
  static const Color surface = Color(0xFF0F172A); // Slate 900
  static const Color text = Color(0xFFF8FAFC);
  static const Color muted = Color(0xFF94A3B8);
  static const Color accent = Color(0xFFF59E0B); // Amber (Wall Color)
  static const Color primary = Color(0xFF8B5CF6); // Violet
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color error = Color(0xFFEF4444); // Red
  static const Color gridLine = Color(0xFF1E293B);
  static const Color gridAxis = Color(0xFF64748B);
}

// --- DATA MODELS ---
class LevelData {
  final int id;
  final String displayEq;
  final String axis; // 'x' or 'y'
  final int value;

  LevelData({
    required this.id,
    required this.displayEq,
    required this.axis,
    required this.value,
  });
}

class WallData {
  final String axis;
  final int value;
  WallData(this.axis, this.value);
}

class LogEntry {
  final String message;
  final bool isSuccess;
  LogEntry(this.message, this.isSuccess);
}

// --- LOCALIZATION DICTIONARY ---
final Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': "THE WALL BUILDER",
    'tagline': "PARALLEL STRUCTURES",
    'init_btn': "INITIALIZE GRID",
    'header_subtitle': "Class 9 • LINEAR EQUATIONS - Parallel Lines",
    'lab_mission_header': "CURRENT BLUEPRINT",
    'ctrl_panel': "System Log",
    'instruction': "Tap anywhere on the grid where {eq} to build the wall.",
    'mouse_hint': "Look at the axis. If it's x=a, the line is vertical. If y=b, the line is horizontal.",
    'btn_restart': "Replay Mission",
    'btn_retry': "Reset Layout",
    'msg_wall_built': "Wall constructed!",
    'err_incorrect': "Coordinate mismatch. Wall collapsed!",
    'sys_reset': "System Rebooted",
    'sys_init': "System Initialized.",
    'modal_title': "Blueprint Complete!",
    'modal_desc': "You have successfully constructed all parallel structures.",
    'btn_proceed': "NEXT BLUEPRINT",
    'btn_finish': "COMPLETE SIMULATION",
    
    // Dynamically added translations for the UI
    'lbl_level': "LEVEL",
    'lbl_online': "ONLINE",
    'log_wall_built': "Wall erected at {eq}",
    'log_wall_failed': "Failed: Tapped near {attempt}",
    'log_lvl_loaded': "Level {val} Initialized.",
    'hud_equation': "TARGET EQUATION",
  },
  'hi': {
    'app_title': "दीवार निर्माता",
    'tagline': "समानांतर संरचनाएं",
    'init_btn': "ग्रिड प्रारंभ करें",
    'header_subtitle': "कक्षा 9 • रैखिक समीकरण – समानांतर रेखाएं",
    'lab_mission_header': "वर्तमान ब्लूप्रिंट",
    'ctrl_panel': "सिस्टम लॉग",
    'instruction': "दीवार बनाने के लिए ग्रिड पर कहीं भी टैप करें जहां {eq} हो।",
    'mouse_hint': "अक्ष को देखें। यदि यह x=a है, तो रेखा लंबवत है। यदि y=b है, तो रेखा क्षैतिज है।",
    'btn_restart': "फिर से खेलें",
    'btn_retry': "रीसेट करें",
    'msg_wall_built': "दीवार बन गई!",
    'err_incorrect': "निर्देशांक बेमेल। दीवार गिर गई!",
    'sys_reset': "सिस्टम रीसेट",
    'sys_init': "सिस्टम प्रारंभ हुआ।",
    'modal_title': "ब्लूप्रिंट पूरा हुआ!",
    'modal_desc': "आपने सफलतापूर्वक सभी समानांतर संरचनाओं का निर्माण कर लिया है।",
    'btn_proceed': "अगला ब्लूप्रिंट",
    'btn_finish': "सिमुलेशन पूरा करें",

    // Dynamically added translations for the UI
    'lbl_level': "स्तर",
    'lbl_online': "ऑनलाइन",
    'log_wall_built': "{eq} पर दीवार खड़ी की गई",
    'log_wall_failed': "विफल: {attempt} के पास टैप किया गया",
    'log_lvl_loaded': "स्तर {val} लोड हुआ।",
    'hud_equation': "लक्ष्य समीकरण",
  },
};

class WallBuilderApp extends StatelessWidget {
  const WallBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'The Wall Builder',
      debugShowCheckedModeBanner: false,
      home: WallBuilderScreen(),
    );
  }
}

class WallBuilderScreen extends StatefulWidget {
  const WallBuilderScreen({super.key});

  @override
  State<WallBuilderScreen> createState() => _WallBuilderScreenState();
}

class _WallBuilderScreenState extends State<WallBuilderScreen>
    with TickerProviderStateMixin {
  // Core State
  bool _showShutter = true;
  bool _sidebarOpen = true;
  bool missionComplete = false;
  String currentLang = 'en';

  // Game State
  int currentLevelIndex = 0;
  List<WallData> builtWalls = [];
  List<LogEntry> logs = [];

  // View State (Panning & Zooming)
  Offset _panOffset = Offset.zero;
  double _zoomScale = 1.0;
  double _previousZoom = 1.0;

  final List<LevelData> levels = [
    LevelData(id: 1, displayEq: "x = 3", axis: 'x', value: 3),
    LevelData(id: 2, displayEq: "y = -2", axis: 'y', value: -2),
    LevelData(id: 3, displayEq: "x = -4", axis: 'x', value: -4),
    LevelData(id: 4, displayEq: "y = 5", axis: 'y', value: 5),
    LevelData(id: 5, displayEq: "x = 0", axis: 'x', value: 0),
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

  void _onGridTap(Offset localPosition, double cx, double cy, BoxConstraints constraints) {
    if (missionComplete || _showShutter) return;

    double gridSize = math.min(constraints.maxWidth, constraints.maxHeight);
    // Adjusted to 12 for a highly spacious, readable grid
    double unitSize = (gridSize / 12) * _zoomScale; 
    Offset center = Offset(cx, cy) + _panOffset;

    double dx = localPosition.dx - center.dx;
    double dy = center.dy - localPosition.dy; // Invert Y for Cartesian

    int gridX = (dx / unitSize).round();
    int gridY = (dy / unitSize).round();

    // Prevent plotting wildly outside bounds (Constrained to 10x10)
    if (gridX < -10 || gridX > 10 || gridY < -10 || gridY > 10) return;

    LevelData currentLevel = levels[currentLevelIndex];

    bool isCorrect = false;
    if (currentLevel.axis == 'x' && gridX == currentLevel.value) {
      isCorrect = true;
    } else if (currentLevel.axis == 'y' && gridY == currentLevel.value) {
      isCorrect = true;
    }

    if (isCorrect) {
      HapticFeedback.heavyImpact();
      _playSound(_fxPlayer, _alertUrl); // Wall built sound
      _showBanner('success', t('msg_wall_built'));
      
      setState(() {
        builtWalls.add(WallData(currentLevel.axis, currentLevel.value));
      });

      _addLog('log_wall_built', params: {'eq': currentLevel.displayEq}, isSuccess: true);

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        if (currentLevelIndex < levels.length - 1) {
          setState(() {
            currentLevelIndex++;
            _addLog('log_lvl_loaded', params: {'val': (currentLevelIndex + 1).toString()}, isSuccess: true);
          });
        } else {
          _playSound(_successPlayer, _successUrl);
          setState(() {
            missionComplete = true;
            _celebrationController.forward();
          });
        }
      });
    } else {
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
      String attempt = currentLevel.axis == 'x' ? "x = $gridX" : "y = $gridY";
      _addLog('log_wall_failed', params: {'attempt': attempt}, isSuccess: false);
      _showBanner('error', t('err_incorrect'));
    }
  }

  void hardReset() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      currentLevelIndex = 0;
      missionComplete = false;
      builtWalls.clear();
      logs.clear();
      _panOffset = Offset.zero;
      _zoomScale = 1.0;
      _addLog('sys_reset');
      _addLog('log_lvl_loaded', params: {'val': '1'}, isSuccess: true);
      _celebrationController.reset();
      _sidebarOpen = true;
      _showShutter = true;
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

            // Floating HUD - Docked perfectly in the Bottom Left
            if (!_sidebarOpen && !_showShutter && !missionComplete)
              _buildFloatingHUD(screenW),

            // Top Left Menu Button (Z-Index Front so it's never covered)
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
            if (_showShutter) _buildLoadingShutter(),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildLoadingShutter() {
    return Container(
      color: AppTheme.bg,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, child) {
                    return Transform.scale(
                      scale: 0.9 + (_pulseController.value * 0.1),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accent.withOpacity(0.5), width: 3),
                          boxShadow: [
                            BoxShadow(color: AppTheme.accent.withOpacity(0.3 + (_pulseController.value * 0.4)), blurRadius: 40),
                          ],
                        ),
                        child: const Icon(Icons.view_agenda, color: AppTheme.accent, size: 50),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Text(
                  t('app_title').toUpperCase(),
                  style: const TextStyle(color: AppTheme.accent, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
                ),
                const SizedBox(height: 12),
                Text(
                  t('tagline').toUpperCase(),
                  style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 3, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _playSound(_shutterPlayer, _shutterUrl); 
                    setState(() => _showShutter = false);
                    _addLog('sys_init');
                    _addLog('log_lvl_loaded', params: {'val': '1'}, isSuccess: true);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(t('init_btn').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

          // Lang / Reset Row
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
                  tooltip: t('btn_reset'),
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
            color: active ? Colors.black : Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLabContent() {
    if (missionComplete) return const SizedBox.shrink();
    LevelData currentLevel = levels[currentLevelIndex];

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
                t('instruction').replaceAll('{eq}', currentLevel.displayEq),
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.3),
              ),
              const SizedBox(height: 8),
              Text(
                t('mouse_hint'),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t('hud_equation'), style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text(currentLevel.displayEq, style: const TextStyle(color: AppTheme.accent, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              
              const SizedBox(height: 24),
              // Logs Area inside sidebar
              Container(
                height: 140, 
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingHUD(double screenW) {
    LevelData currentLevel = levels[currentLevelIndex];
    double hudWidth = math.min(screenW * 0.38, 320.0);

    return Positioned(
      bottom: 20, 
      left: 20, // Docked perfectly to the left corner
      child: Container(
        width: hudWidth,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 8), 
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
            crossAxisMargin: 2,
            thumbVisibility: true,
            child: SingleChildScrollView( 
              controller: _hudScrollController,
              padding: const EdgeInsets.only(right: 16.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t('lab_mission_header').toUpperCase(), style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text('${t('lbl_level')} ${currentLevelIndex + 1}/${levels.length}', style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t('instruction').replaceAll('{eq}', currentLevel.displayEq),
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t('mouse_hint'),
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic, height: 1.3),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10)),
                  
                  Center(
                    child: Text(
                      currentLevel.displayEq,
                      style: const TextStyle(color: AppTheme.secondary, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Small Log View in HUD
                  Text(t('ctrl_panel').toUpperCase(), style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    height: 80,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            log.message,
                            style: TextStyle(color: log.isSuccess ? AppTheme.success : AppTheme.error, fontSize: 10, fontFamily: 'monospace'),
                          ),
                        );
                      },
                    ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // DYNAMIC CENTERING FIX
        // Automatically shift the center of the graph to the right so it is completely unobstructed by the HUD!
        bool isHudVisible = !_sidebarOpen && !_showShutter && !missionComplete;
        double hudRightEdge = 20.0 + math.min(MediaQuery.of(context).size.width * 0.38, 320.0);
        double cx = isHudVisible ? hudRightEdge + (constraints.maxWidth - hudRightEdge) / 2 : constraints.maxWidth / 2;
        double cy = constraints.maxHeight / 2;

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
                onTapDown: (details) => _onGridTap(details.localPosition, cx, cy, constraints),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: CartesianGridPainter(
                    centerX: cx,
                    centerY: cy,
                    builtWalls: builtWalls,
                    animationValue: _pulseController.value,
                    panOffset: _panOffset,
                    zoomScale: _zoomScale,
                  ),
                ),
              ),
            ),
            
            // Recenter Button
            Positioned(
              top: 20,
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
                    const Icon(Icons.domain_verification, color: AppTheme.success, size: 80),
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
}

// --- CUSTOM PAINTERS ---

class CartesianGridPainter extends CustomPainter {
  final double centerX;
  final double centerY;
  final List<WallData> builtWalls;
  final double animationValue;
  final Offset panOffset;
  final double zoomScale;

  CartesianGridPainter({
    required this.centerX,
    required this.centerY,
    required this.builtWalls,
    required this.animationValue,
    required this.panOffset,
    required this.zoomScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double gridSize = math.min(size.width, size.height);
    // 12 base for a highly spacious, readable grid for integer plotting
    double unitSize = (gridSize / 12) * zoomScale; 
    Offset center = Offset(centerX, centerY) + panOffset;

    final Paint gridPaint = Paint()
      ..color = AppTheme.gridLine.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final Paint axisPaintX = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final Paint axisPaintY = Paint()
      ..color = AppTheme.secondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // STRICT -10 TO +10 BOUNDED GRID LOGIC for improved readability
    double gridLimit = 10.5 * unitSize; 

    // Draw grid lines limited from -10 to 10
    for (int i = -10; i <= 10; i++) {
      double offset = i * unitSize;
      
      // Horizontal Lines
      canvas.drawLine(
        Offset(center.dx - gridLimit, center.dy + offset), 
        Offset(center.dx + gridLimit, center.dy + offset), 
        i == 0 ? axisPaintX : gridPaint
      );
      
      // Vertical Lines
      canvas.drawLine(
        Offset(center.dx + offset, center.dy - gridLimit), 
        Offset(center.dx + offset, center.dy + gridLimit), 
        i == 0 ? axisPaintY : gridPaint
      ); 
    }

    // Draw Built Walls constrained within the 10x10 limits
    final Paint wallGlowPaint = Paint()
      ..color = AppTheme.accent.withOpacity(0.3 + (animationValue * 0.3))
      ..strokeWidth = unitSize * 0.6
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final Paint wallCorePaint = Paint()
      ..color = AppTheme.accent
      ..strokeWidth = unitSize * 0.2
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    for (WallData wall in builtWalls) {
      if (wall.axis == 'x') {
        // Vertical wall parallel to Y-axis
        double px = center.dx + (wall.value * unitSize);
        canvas.drawLine(Offset(px, center.dy - gridLimit), Offset(px, center.dy + gridLimit), wallGlowPaint);
        canvas.drawLine(Offset(px, center.dy - gridLimit), Offset(px, center.dy + gridLimit), wallCorePaint);
      } else if (wall.axis == 'y') {
        // Horizontal wall parallel to X-axis
        double py = center.dy - (wall.value * unitSize);
        canvas.drawLine(Offset(center.dx - gridLimit, py), Offset(center.dx + gridLimit, py), wallGlowPaint);
        canvas.drawLine(Offset(center.dx - gridLimit, py), Offset(center.dx + gridLimit, py), wallCorePaint);
      }
    }

    // Draw Labels 
    TextStyle textStyle = const TextStyle(
      color: AppTheme.gridAxis,
      fontSize: 12, 
      fontFamily: 'monospace',
      fontWeight: FontWeight.bold,
    );

    // Only draw labels strictly between -10 and 10
    for (int i = -10; i <= 10; i++) {
      if (i == 0) continue;
      double offset = i * unitSize;
      
      // X-axis labels
      _drawText(canvas, '$i', Offset(center.dx + offset, center.dy + 14), textStyle);
      
      // Y-axis labels
      _drawText(canvas, '${-i}', Offset(center.dx - 18, center.dy + offset), textStyle);
    }
    _drawText(canvas, '0', Offset(center.dx - 14, center.dy + 14), textStyle);
    
    // Axis Ends Labels
    _drawText(
      canvas, 'X', Offset(center.dx + gridLimit + 20, center.dy), 
      const TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w900)
    );
    _drawText(
      canvas, 'Y', Offset(center.dx, center.dy - gridLimit - 20), 
      const TextStyle(color: AppTheme.secondary, fontSize: 18, fontWeight: FontWeight.w900)
    );
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        offset.dx - textPainter.width / 2,
        offset.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CartesianGridPainter oldDelegate) {
    return oldDelegate.builtWalls.length != builtWalls.length ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.panOffset != panOffset ||
           oldDelegate.zoomScale != zoomScale ||
           oldDelegate.centerX != centerX;
  }
}