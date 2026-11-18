// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

// --- GLOBAL AUDIO ENGINE ---
// Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

// Local audio assets (assets/audio/class9/)
const String _clickUrl = 'audio/class9/click.mp3';
const String _successUrl = 'audio/class9/success.mp3';
const String _errorUrl = 'audio/class9/error.mp3'; // Exact error buzzer
const String _alertUrl = 'audio/class9/alert.mp3';
const String _shutterUrl = 'audio/class9/shutter.mp3'; // Exact shutter opening

// Web-safe playback helper
void _playSound(AudioPlayer player, String url) async {
  try {
    if (player.state == PlayerState.playing) {
      await player.stop();
    }
    await player.play(AssetSource(url));
  } catch (e) {
    debugPrint("Audio Playback Error: $e");
  }
}
// ---------------------------

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LaserLineApp());
}

// --- THEME MANAGEMENT ---
class AppTheme {
  static const Color bg = Color(0xFF020617); // Slate 950
  static const Color surface = Color(0xFF0F172A); // Slate 900
  static const Color text = Color(0xFFF8FAFC);
  static const Color muted = Color(0xFF94A3B8);
  static const Color accent = Color(0xFFF43F5E); // Rose (Laser color)
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
  final int requiredPoints;
  final bool Function(int x, int y) validator;

  LevelData({
    required this.id,
    required this.displayEq,
    this.requiredPoints = 2,
    required this.validator,
  });
}

class LogEntry {
  final String message;
  final bool isSuccess;
  LogEntry(this.message, this.isSuccess);
}

// --- LOCALIZATION DICTIONARY ---
final Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': "LASER LINE",
    'tagline': "GRAPHING THE EQUATION",
    'init_btn': "ACTIVATE GRID",
    'header_subtitle': "Class 9 • LINEAR EQUATIONS - Graphing",
    'lab_mission_header': "CURRENT OBJECTIVE",
    'ctrl_panel': "System Log",
    'instruction': "Plot {points} valid points on the grid to activate the laser for {eq}.",
    'mouse_hint': "Calculate valid (x, y) solutions and tap the grid to plot them.",
    'btn_check': "ACTIVATE LASER",
    'btn_restart': "Replay Mission",
    'btn_retry': "Clear Points",
    'msg_point_plotted': "Point Verified!",
    'err_incorrect': "Point does not satisfy the equation!",
    'sys_reset': "System Rebooted",
    'sys_init': "System Initialized.",
    'modal_title': "Mission Complete!",
    'modal_desc': "You have successfully graphed all equations.",
    'btn_proceed': "NEXT EQUATION",
    'btn_finish': "COMPLETE SIMULATION",
    
    // Dynamically added translations for the UI
    'lbl_level': "LEVEL",
    'lbl_online': "ONLINE",
    'lbl_points_logged': "Points Logged: ",
    'log_point_valid': "Point ({x}, {y}) verified.",
    'log_point_invalid': "Point ({x}, {y}) is not a solution.",
    'log_laser_active': "LASER ACTIVATED!",
    'log_lvl_loaded': "Level {val} Initialized.",
    'hud_equation': "TARGET EQUATION",
  },
  'hi': {
    'app_title': "लेज़र लाइन",
    'tagline': "समीकरण का ग्राफ बनाना",
    'init_btn': "ग्रिड सक्रिय करें",
    'header_subtitle': "कक्षा 9 • रैखिक समीकरण – आलेखन",
    'lab_mission_header': "वर्तमान उद्देश्य",
    'ctrl_panel': "सिस्टम लॉग",
    'instruction': "{eq} के लिए लेज़र सक्रिय करने हेतु ग्रिड पर {points} मान्य बिंदु प्लॉट करें।",
    'mouse_hint': "मान्य (x, y) समाधानों की गणना करें और उन्हें प्लॉट करने के लिए ग्रिड पर टैप करें।",
    'btn_check': "लेज़र सक्रिय करें",
    'btn_restart': "फिर से खेलें",
    'btn_retry': "बिंदु साफ़ करें",
    'msg_point_plotted': "बिंदु सत्यापित!",
    'err_incorrect': "बिंदु समीकरण को संतुष्ट नहीं करता है!",
    'sys_reset': "सिस्टम रीसेट",
    'sys_init': "सिस्टम प्रारंभ हुआ।",
    'modal_title': "मिशन पूरा हुआ!",
    'modal_desc': "आपने सफलतापूर्वक सभी समीकरणों का ग्राफ बना लिया है।",
    'btn_proceed': "अगला समीकरण",
    'btn_finish': "सिमुलेशन पूरा करें",

    // Dynamically added translations for the UI
    'lbl_level': "स्तर",
    'lbl_online': "ऑनलाइन",
    'lbl_points_logged': "लॉग किए गए बिंदु: ",
    'log_point_valid': "बिंदु ({x}, {y}) सत्यापित।",
    'log_point_invalid': "बिंदु ({x}, {y}) समाधान नहीं है।",
    'log_laser_active': "लेज़र सक्रिय!",
    'log_lvl_loaded': "स्तर {val} लोड हुआ।",
    'hud_equation': "लक्ष्य समीकरण",
  },
};

class LaserLineApp extends StatelessWidget {
  const LaserLineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Laser Line',
      debugShowCheckedModeBanner: false,
      home: LaserLineScreen(),
    );
  }
}

class LaserLineScreen extends StatefulWidget {
  const LaserLineScreen({Key? key}) : super(key: key);

  @override
  State<LaserLineScreen> createState() => _LaserLineScreenState();
}

class _LaserLineScreenState extends State<LaserLineScreen>
    with TickerProviderStateMixin {
  // Core State
  bool _showShutter = true;
  bool _sidebarOpen = true;
  bool missionComplete = false;
  String currentLang = 'en';

  // Game State
  int currentLevelIndex = 0;
  List<Offset> plottedPoints = [];
  bool isLaserActive = false;
  List<LogEntry> logs = [];

  // View State (Panning & Zooming)
  Offset _panOffset = Offset.zero;
  double _zoomScale = 1.0;
  double _previousZoom = 1.0;

  final List<LevelData> levels = [
    LevelData(id: 1, displayEq: "y = x", validator: (x, y) => y == x),
    LevelData(id: 2, displayEq: "y = 2x - 1", validator: (x, y) => y == 2 * x - 1),
    LevelData(id: 3, displayEq: "x + y = 4", validator: (x, y) => x + y == 4),
    LevelData(id: 4, displayEq: "y = -x + 2", validator: (x, y) => y == -x + 2),
    LevelData(id: 5, displayEq: "y = 3", validator: (x, y) => y == 3),
  ];

  // Overlays
  String? _bannerMessage;
  String? _bannerType;

  // Animations
  late AnimationController _pulseController;
  late AnimationController _celebrationController;
  final ScrollController _hudScrollController = ScrollController();

  String t(String key) => i18n[currentLang]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

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
    if (missionComplete || isLaserActive || _showShutter) return;

    double gridSize = math.min(constraints.maxWidth, constraints.maxHeight);
    // Adjusted to 12 for a highly spacious, readable grid for precise plotting
    double unitSize = (gridSize / 12) * _zoomScale; 
    Offset center = Offset(cx, cy) + _panOffset;

    double dx = localPosition.dx - center.dx;
    double dy = center.dy - localPosition.dy; // Invert Y for Cartesian

    // Clamped strictly to a maximum of 15
    int gridX = (dx / unitSize).round().clamp(-15, 15); 
    int gridY = (dy / unitSize).round().clamp(-15, 15);

    Offset newPoint = Offset(gridX.toDouble(), gridY.toDouble());

    // Prevent duplicate points
    if (plottedPoints.contains(newPoint)) return;

    LevelData currentLevel = levels[currentLevelIndex];

    if (currentLevel.validator(gridX, gridY)) {
      // Correct Point
      setState(() {
        plottedPoints.add(newPoint);
      });
      _addLog('log_point_valid', params: {'x': gridX.toString(), 'y': gridY.toString()}, isSuccess: true);
      
      if (plottedPoints.length >= currentLevel.requiredPoints) {
        _playSound(_fxPlayer, _alertUrl); // Play target sound
        _activateLaser();
      } else {
        HapticFeedback.selectionClick();
        _playSound(_clickPlayer, _clickUrl);
        _showBanner('success', t('msg_point_plotted'));
      }
    } else {
      // Incorrect Point
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
      _addLog('log_point_invalid', params: {'x': gridX.toString(), 'y': gridY.toString()}, isSuccess: false);
      _showBanner('error', t('err_incorrect'));
    }
  }

  void _activateLaser() {
    setState(() {
      isLaserActive = true;
    });
    _addLog('log_laser_active', isSuccess: true);
    _showBanner('success', t('log_laser_active'));

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      if (currentLevelIndex < levels.length - 1) {
        setState(() {
          currentLevelIndex++;
          plottedPoints.clear();
          isLaserActive = false;
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
  }

  void hardReset() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      currentLevelIndex = 0;
      missionComplete = false;
      plottedPoints.clear();
      isLaserActive = false;
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

  void resetLevel() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      plottedPoints.clear();
      isLaserActive = false;
      _addLog('btn_retry', isSuccess: false);
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
                    child: _buildMainWorkspace(screenW)
                  )
                ),
              ],
            ),

            // Floating HUD - Bottom Left (Docked perfectly since Back Button is removed)
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
                        child: const Icon(Icons.linear_scale, color: AppTheme.accent, size: 50),
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
                    foregroundColor: Colors.white,
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('lab_mission_header'), style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(
                t('instruction')
                  .replaceAll('{points}', currentLevel.requiredPoints.toString())
                  .replaceAll('{eq}', currentLevel.displayEq),
                style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
              ),
              const SizedBox(height: 8),
              Text(
                t('mouse_hint'),
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic, height: 1.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Status Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('lbl_level'),
                    style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  Text(
                    '${currentLevelIndex + 1}/${levels.length}',
                    style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (currentLevelIndex + 1) / levels.length,
                backgroundColor: Colors.white10,
                color: AppTheme.accent,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
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
            border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 2),
            boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.1), blurRadius: 20)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(t('hud_equation'), style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text(currentLevel.displayEq, style: const TextStyle(color: AppTheme.accent, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t('lbl_points_logged'), style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                  const SizedBox(width: 8),
                  Text("${plottedPoints.length} / ${currentLevel.requiredPoints}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              
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
    LevelData currentLevel = levels[currentLevelIndex];
    double hudWidth = math.min(screenW * 0.38, 320.0);

    return Positioned(
      bottom: 20, 
      left: 20, // Docked perfectly to the left corner
      child: Container(
        width: hudWidth,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: Colors.black87.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: const Border(left: BorderSide(color: AppTheme.success, width: 4)),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
        ),
        // By placing padding strictly inside the scroll view, the scrollbar paints on the absolute edge without overlapping text!
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
              padding: const EdgeInsets.all(16.0), // Generous padding here keeps content away from the scrollbar
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
                    t('instruction')
                      .replaceAll('{points}', currentLevel.requiredPoints.toString())
                      .replaceAll('{eq}', currentLevel.displayEq),
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
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t('lbl_points_logged'), style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                      Text("${plottedPoints.length} / ${currentLevel.requiredPoints}", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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

  Widget _buildMainWorkspace(double screenW) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // DYNAMIC CENTERING FIX
        // Automatically shift the center of the graph to the right so it is completely unobstructed by the HUD!
        bool isHudVisible = !_sidebarOpen && !_showShutter && !missionComplete;
        double hudRightEdge = 20.0 + math.min(screenW * 0.38, 320.0);
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
                  painter: LaserGridPainter(
                    centerX: cx,
                    centerY: cy,
                    plottedPoints: plottedPoints,
                    isLaserActive: isLaserActive,
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
                    const Icon(Icons.architecture, color: AppTheme.success, size: 80),
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

class LaserGridPainter extends CustomPainter {
  final double centerX;
  final double centerY;
  final List<Offset> plottedPoints;
  final bool isLaserActive;
  final double animationValue;
  final Offset panOffset;
  final double zoomScale;

  LaserGridPainter({
    required this.centerX,
    required this.centerY,
    required this.plottedPoints,
    required this.isLaserActive,
    required this.animationValue,
    required this.panOffset,
    required this.zoomScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double gridSize = math.min(size.width, size.height);
    // Expand to 12 base for highly spacious blocks
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

    // STRICT -15 TO +15 BOUNDED GRID LOGIC (As per user request to limit bounds)
    double gridLimit = 15.0 * unitSize; 

    // Draw grid lines limited from -15 to 15
    for (int i = -15; i <= 15; i++) {
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

    // Draw Labels 
    TextStyle textStyle = const TextStyle(
      color: AppTheme.gridAxis,
      fontSize: 12, 
      fontFamily: 'monospace',
      fontWeight: FontWeight.bold,
    );

    // Only draw labels strictly between -15 and 15
    for (int i = -15; i <= 15; i++) {
      if (i == 0) continue;
      double offset = i * unitSize;
      
      // X-axis labels
      _drawText(canvas, '$i', Offset(center.dx + offset, center.dy + 14), textStyle);
      
      // Y-axis labels
      _drawText(canvas, '${-i}', Offset(center.dx - 18, center.dy + offset), textStyle);
    }
    _drawText(canvas, '0', Offset(center.dx - 14, center.dy + 14), textStyle);

    // Draw Plotted Points
    final Paint pointPaint = Paint()
      ..color = AppTheme.success
      ..style = PaintingStyle.fill;

    final Paint pointBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (Offset p in plottedPoints) {
      double px = center.dx + (p.dx * unitSize);
      double py = center.dy - (p.dy * unitSize);
      canvas.drawCircle(Offset(px, py), unitSize * 0.3, pointPaint);
      canvas.drawCircle(Offset(px, py), unitSize * 0.3, pointBorderPaint);
    }

    // Draw Connecting Trajectory Laser Line across the -15 to +15 bounds
    if (isLaserActive && plottedPoints.length >= 2) {
      Offset p1 = plottedPoints[0];
      Offset p2 = plottedPoints[1];

      double x1 = p1.dx, y1 = p1.dy;
      double x2 = p2.dx, y2 = p2.dy;

      // Extend logically out strictly to -15 and +15
      double startX = -15, startY;
      double endX = 15, endY;

      if (x1 == x2) {
        startX = x1; startY = -15;
        endX = x1; endY = 15;
      } else {
        double m = (y2 - y1) / (x2 - x1);
        double c = y1 - m * x1;
        startY = m * startX + c;
        endY = m * endX + c;
      }

      Offset screenStart = Offset(center.dx + (startX * unitSize), center.dy - (startY * unitSize));
      Offset screenEnd = Offset(center.dx + (endX * unitSize), center.dy - (endY * unitSize));

      final Paint laserGlowPaint = Paint()
        ..color = AppTheme.accent.withOpacity(0.4 + (animationValue * 0.4))
        ..strokeWidth = unitSize * 0.8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final Paint laserCorePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = unitSize * 0.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(screenStart, screenEnd, laserGlowPaint);
      canvas.drawLine(screenStart, screenEnd, laserCorePaint);
    }
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
  bool shouldRepaint(covariant LaserGridPainter oldDelegate) {
    return oldDelegate.plottedPoints.length != plottedPoints.length ||
           oldDelegate.isLaserActive != isLaserActive ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.panOffset != panOffset ||
           oldDelegate.zoomScale != zoomScale ||
           oldDelegate.centerX != centerX;
  }
}