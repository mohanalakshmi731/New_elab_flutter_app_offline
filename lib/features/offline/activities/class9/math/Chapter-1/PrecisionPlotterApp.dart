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
final AudioPlayer _clickPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _successPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _errorPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _shutterPlayer = AudioPlayer()
  ..setReleaseMode(ReleaseMode.stop);

// Local audio assets (assets/audio/class9/)
const String _clickUrl =
    'audio/class9/click.mp3';
const String _successUrl =
    'audio/class9/success.mp3';
const String _errorUrl =
    'audio/class9/error.mp3'; // Exact error buzzer
const String _alertUrl =
    'audio/class9/alert.mp3';
const String _shutterUrl =
    'audio/class9/shutter.mp3'; // Exact shutter

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
  runApp(const PrecisionPlotterApp());
}

// --- THEME MANAGEMENT ---
class AppTheme {
  final Color bg;
  final Color surface;
  final Color text;
  final Color muted;
  final Color accent;
  final Color primary;
  final Color secondary;
  final Color success;
  final Color error;
  final Color gridLine;
  final Color gridAxis;

  const AppTheme({
    required this.bg,
    required this.surface,
    required this.text,
    required this.muted,
    required this.accent,
    required this.primary,
    required this.secondary,
    required this.success,
    required this.error,
    required this.gridLine,
    required this.gridAxis,
  });

  static const AppTheme defaultDark = AppTheme(
    bg: Color(0xFF020617), // Slate 950
    surface: Color(0xFF0F172A), // Slate 900
    text: Color(0xFFFFFFFF),
    muted: Color(0xFF94A3B8),
    accent: Color(0xFFF0ABFC), // Fuchsia 300
    primary: Color(0xFFA78BFA), // Violet 400
    secondary: Color(0xFF22D3EE), // Cyan 400
    success: Color(0xFF4ADE80),
    error: Color(0xFFFB7185),
    gridLine: Color(0xFF334155),
    gridAxis: Color(0xFFF8FAFC),
  );
}

// --- LOCALIZATION DICTIONARY ---
final Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': "PRECISION PLOTTER",
    'tagline': "SPACE ACADEMY: TARGET ACQUISITION",
    'init_btn': "START MISSION",
    'header_subtitle': "Class 9 • COORDINATE GEOMETRY - Plotting Points",
    'mission_obj_lbl': 'MISSION OBJECTIVE',
    'mission_simple':
        'Plot the exact (X, Y) coordinates on the Cartesian plane by dragging the glowing ghost marker and confirming the position.',
    'btn_start_lab': "Launch Mission",
    'lab_mission_header': "MISSION PROGRESS",
    'target_label': "TARGET COORDINATES",
    'btn_restart': "Replay Mission",
    'btn_hint': "REQUEST HINT",
    'msg_awesome': "PRECISE!",
    'mouse_hint':
        "Drag the graph to pan. Pinch to zoom. Drag the marker to plot.",
    'err_incorrect': "Incorrect Position. Check Coordinates!",
    'out_1_d':
        "Successfully plotted points in all four quadrants. Mission Complete!",

    // UI Elements that were previously hardcoded
    'modal_title': "MISSION SUCCESS",
    'lbl_target_prog': "TARGET",
    'lbl_lvl': "LVL",
    'ghost_lbl': "GHOST (X, Y):",
    'ghost_short': "GHOST:",
    'btn_plot': "PLOT POINT",
    'init_flight': "INITIALIZING SENSORS...",
    'btn_reset': "Reset System",
    'mission_comp': "Mission Complete!",

    // Directional
    'dir_right': "Right",
    'dir_left': "Left",
    'dir_up': "Up",
    'dir_down': "Down",
    'hud_move_phrase':
        "Move {dir1} to {val1}, then {dir2} to {val2} from the origin",
  },
  'hi': {
    'app_title': "सटीक प्लॉटर",
    'tagline': "स्पेस अकादमी: लक्ष्य प्राप्ति",
    'init_btn': "मिशन शुरू करें",
    'header_subtitle': "कक्षा 9 • निर्देशांक ज्यामिति – बिंदुओं का आलेखन",
    'mission_obj_lbl': 'मिशन का उद्देश्य',
    'mission_simple':
        'चमकते मार्कर को खींचकर और स्थिति की पुष्टि करके कार्टेशियन तल पर सटीक (X, Y) निर्देशांक प्लॉट करें।',
    'btn_start_lab': "मिशन शुरू करें",
    'lab_mission_header': "मिशन की प्रगति",
    'target_label': "लक्ष्य निर्देशांक",
    'btn_restart': "फिर से खेलें",
    'btn_hint': "संकेत मांगें",
    'msg_awesome': "सटीक!",
    'mouse_hint':
        "पैन करने के लिए ग्रिड खींचें। ज़ूम करने के लिए पिंच करें। मार्कर खींचें।",
    'err_incorrect': "गलत स्थिति। निर्देशांक जांचें!",
    'out_1_d':
        "सभी चार चतुर्थांशों में सफलतापूर्वक बिंदु प्लॉट किए। मिशन पूरा हुआ!",

    // UI Elements that were previously hardcoded
    'modal_title': "मिशन सफल",
    'lbl_target_prog': "लक्ष्य",
    'lbl_lvl': "स्तर",
    'ghost_lbl': "घोस्ट (X, Y):",
    'ghost_short': "घोस्ट:",
    'btn_plot': "पॉइंट प्लॉट करें",
    'init_flight': "सेंसर शुरू हो रहे हैं...",
    'btn_reset': "सिस्टम रीसेट",
    'mission_comp': "मिशन पूरा हुआ!",

    // Directional
    'dir_right': "दाएं",
    'dir_left': "बाएं",
    'dir_up': "ऊपर",
    'dir_down': "नीचे",
    'hud_move_phrase':
        "मूल बिंदु से {dir1} {val1} चलें, फिर {dir2} {val2} चलें",
  },
};

class PrecisionPlotterApp extends StatelessWidget {
  const PrecisionPlotterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Precision Plotter',
      debugShowCheckedModeBanner: false,
      home: PrecisionPlotterScreen(),
    );
  }
}

class PrecisionPlotterScreen extends StatefulWidget {
  const PrecisionPlotterScreen({super.key});

  @override
  State<PrecisionPlotterScreen> createState() => _PrecisionPlotterScreenState();
}

class _PrecisionPlotterScreenState extends State<PrecisionPlotterScreen>
    with TickerProviderStateMixin {
  // Core State
  bool _showShutter = true;
  bool _sidebarOpen = true;
  bool missionComplete = false;
  String currentLang = 'en';

  // Theme & Settings
  AppTheme theme = AppTheme.defaultDark;
  double fontScale = 1.0;

  // Game State
  int currentLevelIndex = 0;
  int ghostX = 0;
  int ghostY = 0;

  // Panning & Zooming
  Offset _panOffset = Offset.zero;
  double _zoomScale = 1.0;
  double _previousZoom = 1.0;
  bool _isDraggingGhost = false;

  final List<Offset> levels = const [
    Offset(3, 2),
    Offset(-4, 1),
    Offset(-2, -3),
    Offset(5, -4),
    Offset(0, 3),
    Offset(-5, 0),
    Offset(4, 4),
    Offset(-3, 5),
    Offset(2, -2),
    Offset(-1, -5),
  ];

  List<Offset> markers = [];

  // Overlays
  String? _bannerMessage;
  String? _bannerType;

  // Animations
  late AnimationController _pulseController;
  late AnimationController _celebrationController;

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

    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _shutterPlayer.dispose();
    super.dispose();
  }

  void _plotPoint() {
    if (missionComplete || currentLevelIndex >= levels.length || _showShutter)
      return;

    Offset target = levels[currentLevelIndex];

    if (ghostX == target.dx.toInt() && ghostY == target.dy.toInt()) {
      // Success
      HapticFeedback.heavyImpact();
      _playSound(_successPlayer, _successUrl);
      _showBanner('success', t('msg_awesome'));

      setState(() {
        markers.add(Offset(ghostX.toDouble(), ghostY.toDouble()));
      });

      if (currentLevelIndex < levels.length - 1) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              currentLevelIndex++;
            });
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _playSound(_fxPlayer, _alertUrl); // Mission complete sound
            setState(() {
              missionComplete = true;
              _celebrationController.forward();
            });
          }
        });
      }
    } else {
      // Failure
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
      _showBanner('error', t('err_incorrect'));
    }
  }

  void hardReset() {
    setState(() {
      currentLevelIndex = 0;
      missionComplete = false;
      ghostX = 0;
      ghostY = 0;
      _panOffset = Offset.zero;
      _zoomScale = 1.0;
      markers.clear();
      _celebrationController.reset();
      _showShutter = true;
      _sidebarOpen = true;
    });
  }

  void _showBanner(String type, String message) {
    setState(() {
      _bannerType = type;
      _bannerMessage = message;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _bannerMessage == message) {
        setState(() {
          _bannerMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double sidebarWidth = screenW * 0.38; // 38% exactly

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        FocusScope.of(context).unfocus();
      },
      child: Theme(
        data: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: theme.bg,
          fontFamily: 'monospace',
          textTheme: TextTheme(
            bodyMedium: TextStyle(fontSize: 14 * fontScale, color: theme.text),
            bodySmall: TextStyle(fontSize: 12 * fontScale, color: theme.muted),
          ),
        ),
        child: Scaffold(
          backgroundColor: theme.bg,
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
                      color: theme.surface,
                      border: Border(
                        right: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        width: sidebarWidth,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(
                            top: 16.0,
                            bottom: 24.0,
                          ),
                          child: _buildSidebarContent(),
                        ),
                      ),
                    ),
                  ),

                  // Center Activity
                  Expanded(child: ClipRect(child: _buildMainWorkspace())),
                ],
              ),

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
                        setState(() {
                          _sidebarOpen = !_sidebarOpen;
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

              // Floating HUD - Rendered only when sidebar is closed. Docked at left bottom.
              if (!_sidebarOpen && !_showShutter && !missionComplete)
                _buildFloatingHUD(screenW),

              // Overlays
              if (_bannerMessage != null) _buildBanner(),
              if (missionComplete && !_showShutter) _buildSuccessModal(),
              if (_showShutter) _buildCurtain(),
            ],
          ),
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 24 * fontScale,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              height: 1.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            t('header_subtitle'),
            style: TextStyle(
              color: theme.primary,
              fontSize: 11 * fontScale,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontFamily: 'monospace',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
                  border: Border.all(color: theme.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [_langBtn('en', 'EN'), _langBtn('hi', 'HI')],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.error.withOpacity(0.6),
                    width: 2.0,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.power_settings_new, color: theme.error),
                  tooltip: t('btn_reset'),
                  onPressed: () {
                    HapticFeedback.vibrate();
                    _playSound(_clickPlayer, _clickUrl);
                    hardReset();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Active Content View
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
        HapticFeedback.selectionClick();
        _playSound(_clickPlayer, _clickUrl);
        setState(() => currentLang = code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? theme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? theme.bg : Colors.white60,
            fontSize: 12 * fontScale,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLabContent() {
    if (missionComplete) return const SizedBox.shrink();
    Offset? target = currentLevelIndex < levels.length
        ? levels[currentLevelIndex]
        : null;

    String movePhrase = target != null
        ? t('hud_move_phrase')
              .replaceAll(
                '{dir1}',
                target.dx >= 0 ? t('dir_right') : t('dir_left'),
              )
              .replaceAll('{val1}', target.dx.abs().toInt().toString())
              .replaceAll(
                '{dir2}',
                target.dy >= 0 ? t('dir_up') : t('dir_down'),
              )
              .replaceAll('{val2}', target.dy.abs().toInt().toString())
        : t('mission_comp');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mission Objective Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.accent.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('mission_obj_lbl'),
                style: TextStyle(
                  color: theme.accent,
                  fontSize: 10 * fontScale,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t('mission_simple'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12 * fontScale,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Status Box
        Container(
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
                    t('lab_mission_header'),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10 * fontScale,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '${t('lbl_target_prog')} ${currentLevelIndex + 1}/${levels.length}',
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 10 * fontScale,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (currentLevelIndex + 1) / levels.length,
                backgroundColor: Colors.white10,
                color: theme.accent,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Target & Ghost Coordinates Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.radar, color: theme.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    t('target_label').toUpperCase(),
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 12 * fontScale,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  target != null
                      ? '(${target.dx.toInt()}, ${target.dy.toInt()})'
                      : '(?, ?)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36 * fontScale,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Prominent Action Description
              Center(
                child: Text(
                  movePhrase,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14 * fontScale,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Colors.white10),
              ),

              // Coordinates input feedback area
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t('ghost_lbl'),
                      style: TextStyle(
                        color: theme.muted,
                        fontSize: 12 * fontScale,
                      ),
                    ),
                    Text(
                      '($ghostX, $ghostY)',
                      style: TextStyle(
                        color: theme.secondary,
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.success,
                  foregroundColor: theme.bg,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _plotPoint,
                icon: const Icon(Icons.gps_fixed),
                label: Text(
                  t('btn_plot'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 14 * fontScale,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingHUD(double screenW) {
    Offset? target = currentLevelIndex < levels.length
        ? levels[currentLevelIndex]
        : null;
    double hudWidth = math.min(screenW * 0.45, 280.0);

    String movePhrase = target != null
        ? t('hud_move_phrase')
              .replaceAll(
                '{dir1}',
                target.dx >= 0 ? t('dir_right') : t('dir_left'),
              )
              .replaceAll('{val1}', target.dx.abs().toInt().toString())
              .replaceAll(
                '{dir2}',
                target.dy >= 0 ? t('dir_up') : t('dir_down'),
              )
              .replaceAll('{val2}', target.dy.abs().toInt().toString())
        : t('mission_comp');

    return Positioned(
      bottom: 20,
      left: 20, // Docked in the bottom-left corner securely
      child: Container(
        width: hudWidth,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: theme.success, width: 4)),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t('target_label').toUpperCase(),
                  style: TextStyle(
                    color: theme.muted,
                    fontSize: 10 * fontScale,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${t('lbl_lvl')} ${currentLevelIndex + 1}/${levels.length}',
                  style: TextStyle(
                    color: theme.accent,
                    fontSize: 10 * fontScale,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              target != null
                  ? '(${target.dx.toInt()}, ${target.dy.toInt()})'
                  : '(?, ?)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24 * fontScale,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              movePhrase,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12 * fontScale,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Colors.white10),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t('ghost_short'),
                  style: TextStyle(
                    color: theme.muted,
                    fontSize: 10 * fontScale,
                  ),
                ),
                Text(
                  '($ghostX, $ghostY)',
                  style: TextStyle(
                    color: theme.secondary,
                    fontSize: 14 * fontScale,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.success,
                foregroundColor: theme.bg,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _plotPoint,
              icon: const Icon(Icons.gps_fixed, size: 18),
              label: Text(
                t('btn_plot'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12 * fontScale,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainWorkspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Background grid container
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF0f172a), Color(0xFF020617)],
                  center: Alignment.center,
                  radius: 1.0,
                ),
              ),
            ),

            // Draggable & Zoomable Graph Area
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: (details) {
                  _previousZoom = _zoomScale;
                  // Determine if we grabbed the ghost marker
                  double gridSize = math.min(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  double unitSize = (gridSize / 14) * _zoomScale;
                  Offset center =
                      Offset(
                        constraints.maxWidth / 2,
                        constraints.maxHeight / 2,
                      ) +
                      _panOffset;

                  double screenX = center.dx + (ghostX * unitSize);
                  double screenY = center.dy - (ghostY * unitSize);

                  // Generous hit box for touching the marker
                  if ((details.localFocalPoint - Offset(screenX, screenY))
                          .distance <
                      50) {
                    _isDraggingGhost = true;
                  } else {
                    _isDraggingGhost = false;
                  }
                },
                onScaleUpdate: (details) {
                  setState(() {
                    if (_isDraggingGhost && details.scale == 1.0) {
                      // Moving the marker
                      double gridSize = math.min(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      double unitSize = (gridSize / 14) * _zoomScale;
                      Offset center =
                          Offset(
                            constraints.maxWidth / 2,
                            constraints.maxHeight / 2,
                          ) +
                          _panOffset;

                      double dx = details.localFocalPoint.dx - center.dx;
                      double dy =
                          center.dy -
                          details.localFocalPoint.dy; // Cartesian Y invert

                      // Clamped to +/- 10
                      ghostX = (dx / unitSize).round().clamp(-10, 10);
                      ghostY = (dy / unitSize).round().clamp(-10, 10);
                    } else {
                      // Zooming and Panning the Grid
                      _zoomScale = (_previousZoom * details.scale).clamp(
                        0.5,
                        4.0,
                      );
                      _panOffset += details.focalPointDelta;
                      // Clamp to prevent flying off into deep space
                      _panOffset = Offset(
                        _panOffset.dx.clamp(
                          -constraints.maxWidth * 2,
                          constraints.maxWidth * 2,
                        ),
                        _panOffset.dy.clamp(
                          -constraints.maxHeight * 2,
                          constraints.maxHeight * 2,
                        ),
                      );
                    }
                  });
                },
                onTapDown: (details) {
                  if (missionComplete || _showShutter) return;

                  // Instantly move marker on tap
                  double gridSize = math.min(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  double unitSize = (gridSize / 14) * _zoomScale;
                  Offset center =
                      Offset(
                        constraints.maxWidth / 2,
                        constraints.maxHeight / 2,
                      ) +
                      _panOffset;

                  double dx = details.localPosition.dx - center.dx;
                  double dy = center.dy - details.localPosition.dy;

                  setState(() {
                    ghostX = (dx / unitSize).round().clamp(-10, 10);
                    ghostY = (dy / unitSize).round().clamp(-10, 10);
                  });
                },
                child: Stack(
                  children: [
                    // Background Grid & Axes
                    CustomPaint(
                      size: Size.infinite,
                      painter: CartesianGridPainter(
                        theme: theme,
                        fontScale: fontScale,
                        panOffset: _panOffset,
                        zoomScale: _zoomScale,
                      ),
                    ),

                    // Placed Markers
                    ...markers.map(
                      (pos) => _buildMarker(pos, constraints, true),
                    ),

                    // Ghost Marker (Draggable)
                    if (!missionComplete && currentLevelIndex < levels.length)
                      _buildMarker(
                        Offset(ghostX.toDouble(), ghostY.toDouble()),
                        constraints,
                        false,
                      ),
                  ],
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.white24),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _panOffset = Offset.zero;
                    _zoomScale = 1.0;
                  });
                },
                child: const Icon(Icons.center_focus_strong, size: 20),
              ),
            ),

            // Instructions (only when sidebar open to save space)
            if (_sidebarOpen && !missionComplete)
              Positioned(
                top: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      t('mouse_hint'),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12 * fontScale,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMarker(
    Offset pos,
    BoxConstraints constraints,
    bool isPermanent,
  ) {
    double gridSize = math.min(constraints.maxWidth, constraints.maxHeight);
    double unitSize = (gridSize / 14) * _zoomScale; // Match new larger spacing
    Offset center =
        Offset(constraints.maxWidth / 2, constraints.maxHeight / 2) +
        _panOffset;

    double screenX = center.dx + (pos.dx * unitSize);
    double screenY = center.dy - (pos.dy * unitSize);
    double markerSize = isPermanent ? unitSize * 0.5 : unitSize * 0.8;
    // Cap marker size to not get astronomically huge
    markerSize = markerSize.clamp(10.0, 50.0);

    return Positioned(
      left: screenX - (markerSize / 2),
      top: screenY - (markerSize / 2),
      width: markerSize,
      height: markerSize,
      child: IgnorePointer(
        child: isPermanent
            ? Container(
                decoration: BoxDecoration(
                  color: theme.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: theme.success.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              )
            : AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: markerSize,
                        height: markerSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.accent.withOpacity(0.5),
                          border: Border.all(color: theme.accent, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: theme.accent.withOpacity(
                                0.5 * _pulseController.value,
                              ),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
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
            color: isSuccess
                ? theme.success.withOpacity(0.9)
                : theme.error.withOpacity(0.9),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: isSuccess ? Colors.greenAccent : Colors.redAccent,
            ),
            boxShadow: [
              BoxShadow(
                color: isSuccess
                    ? theme.success.withOpacity(0.5)
                    : theme.error.withOpacity(0.5),
                blurRadius: 30,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.warning,
                color: theme.bg,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                _bannerMessage ?? '',
                style: TextStyle(
                  color: theme.bg,
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
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
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: _celebrationController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.success, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: theme.success.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.public, color: theme.success, size: 80),
                    const SizedBox(height: 24),
                    Text(
                      t('modal_title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26 * fontScale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t('out_1_d'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14 * fontScale,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _playSound(_shutterPlayer, _shutterUrl);
                        hardReset();
                      },
                      icon: Icon(Icons.refresh, color: theme.bg),
                      label: Text(
                        t('btn_restart'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.bg,
                          fontSize: 16 * fontScale,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.success,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
      color: theme.bg,
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.accent.withOpacity(0.2),
                    ),
                  ),
                ),
                Icon(Icons.gps_fixed, size: 80, color: theme.accent),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              t('app_title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48 * fontScale,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [Shadow(color: theme.accent, blurRadius: 15)],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t('tagline'),
              style: TextStyle(
                fontSize: 16 * fontScale,
                letterSpacing: 4,
                color: theme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                _playSound(_shutterPlayer, _shutterUrl);
                setState(() {
                  _showShutter = false; // Starts the game directly
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accent,
                foregroundColor: theme.bg,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 10,
                shadowColor: theme.accent.withOpacity(0.5),
              ),
              child: Text(
                t('init_btn'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18 * fontScale,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTERS ---

class CartesianGridPainter extends CustomPainter {
  final AppTheme theme;
  final double fontScale;
  final Offset panOffset;
  final double zoomScale;

  CartesianGridPainter({
    required this.theme,
    required this.fontScale,
    required this.panOffset,
    required this.zoomScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double gridSize = math.min(size.width, size.height);
    // Expand to 14 base for much more spacious blocks!
    double unitSize = (gridSize / 14) * zoomScale;
    Offset center = Offset(size.width / 2, size.height / 2) + panOffset;

    final Paint gridPaint = Paint()
      ..color = theme.gridLine
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Paint axisPaintX = Paint()
      ..color = theme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final Paint axisPaintY = Paint()
      ..color = theme.secondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw Grid Lines bounded strictly to -10 to 10
    double gridLimit = 11.0 * unitSize;

    for (int i = -10; i <= 10; i++) {
      double offset = i * unitSize;

      canvas.drawLine(
        Offset(center.dx - gridLimit, center.dy + offset),
        Offset(center.dx + gridLimit, center.dy + offset),
        i == 0 ? axisPaintX : gridPaint,
      ); // Horiz
      canvas.drawLine(
        Offset(center.dx + offset, center.dy - gridLimit),
        Offset(center.dx + offset, center.dy + gridLimit),
        i == 0 ? axisPaintY : gridPaint,
      ); // Vert
    }

    // Draw Labels
    TextStyle textStyle = TextStyle(
      color: theme.gridAxis,
      fontSize: 12 * fontScale,
      fontFamily: 'monospace',
      fontWeight: FontWeight.bold,
    );

    for (int i = -10; i <= 10; i++) {
      if (i == 0) continue;
      double offset = i * unitSize;
      // X-axis: Centered under the tick mark
      _drawText(
        canvas,
        '$i',
        Offset(center.dx + offset, center.dy + 14),
        textStyle,
      );
      // Y-axis: Centered left of the tick mark
      _drawText(
        canvas,
        '${-i}',
        Offset(center.dx - 18, center.dy + offset),
        textStyle,
      );
    }

    // Origin
    _drawText(canvas, '0', Offset(center.dx - 12, center.dy + 12), textStyle);
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
  bool shouldRepaint(covariant CartesianGridPainter oldDelegate) =>
      oldDelegate.theme != theme ||
      oldDelegate.fontScale != fontScale ||
      oldDelegate.panOffset != panOffset ||
      oldDelegate.zoomScale != zoomScale;
}
