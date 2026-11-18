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
// Local audio assets (assets/audio/class9/)
const String _clickUrl = 'audio/class9/click.mp3';
const String _successUrl = 'audio/class9/success.mp3';
const String _errorUrl = 'audio/class9/error.mp3'; // Exact error buzzer
const String _alertUrl = 'audio/class9/alert.mp3';
const String _shutterUrl = 'audio/class9/shutter.mp3'; // Exact shutter opening

// Web-safe playback helper
void _playSound(AudioPlayer player, String url) async {
  try {
    await player.stop();
    await player.play(AssetSource(url));
  } catch (e) {
    debugPrint("Audio Playback Error: $e");
  }
}
// ---------------------------

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SolutionGeneratorApp());
}

// --- THEME MANAGEMENT ---
class AppTheme {
  static const Color bg = Color(0xFF020617); // Slate 950
  static const Color surface = Color(0xFF0F172A); // Slate 900
  static const Color text = Color(0xFFF8FAFC);
  static const Color muted = Color(0xFF94A3B8);
  static const Color accent = Color(0xFF38BDF8); // Sky Blue
  static const Color primary = Color(0xFF818CF8); // Indigo
  static const Color secondary = Color(0xFFF472B6); // Pink
  static const Color success = Color(0xFF34D399); // Emerald
  static const Color error = Color(0xFFF87171); // Red
  static const Color gridLine = Color(0xFF334155);
  static const Color gridAxis = Color(0xFFE2E8F0);
}

// --- DATA MODELS ---
class LevelData {
  final int id;
  final String displayEq;
  final List<int> testInputs;
  final int Function(int x) evaluator;

  LevelData(this.id, this.displayEq, this.testInputs, this.evaluator);
}

class LogEntry {
  final String message;
  final bool isSuccess;
  LogEntry(this.message, this.isSuccess);
}

// --- LOCALIZATION DICTIONARY ---
final Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': "THE SOLUTION GENERATOR",
    'tagline': "INPUT/OUTPUT PROTOCOLS",
    'init_btn': "INITIALIZE MACHINE",
    'header_subtitle': "Class 9 • LINEAR EQUATIONS - Solutions",
    'lab_mission_header': "CURRENT OBJECTIVE",
    'ctrl_panel': "System Log",
    'instruction': "Calculate the 'y' output for the given 'x' input to power up the machine.",
    'mouse_hint': "Enter the calculated value in the OUTPUT box and tap PROCESS DATA.",
    'btn_check': "PROCESS DATA",
    'btn_restart': "Replay Mission",
    'btn_retry': "Reset Layout",
    'msg_level_up': "SYSTEM CALIBRATED!",
    'err_incorrect': "Output mismatch! Recalculate.",
    'err_invalid': "Enter a valid integer.",
    'sys_reset': "System Rebooted",
    'sys_init': "System Initialized.",
    'modal_title': "Mission Complete!",
    'modal_desc': "You have mastered finding solutions for linear equations.",
    'btn_proceed': "NEXT EQUATION",
    'btn_finish': "COMPLETE SIMULATION",
    
    // Dynamically added translations for the UI
    'lbl_level': "LEVEL",
    'lbl_online': "ONLINE",
    'log_processed': "Processed: f({x}) = {y}",
    'log_error_val': "Error: f({x}) != {y}",
    'log_lvl_loaded': "Level {val} Initialized.",
    'hud_equation': "FUNCTION CORE",
    'lbl_input_x': "INPUT (x)",
    'lbl_output_y': "OUTPUT (y)",
    'lbl_done': "DONE",
  },
  'hi': {
    'app_title': "समाधान जनरेटर",
    'tagline': "इनपुट/आउटपुट प्रोटोकॉल",
    'init_btn': "मशीन प्रारंभ करें",
    'header_subtitle': "कक्षा 9 • रैखिक समीकरण – समाधान",
    'lab_mission_header': "वर्तमान उद्देश्य",
    'ctrl_panel': "सिस्टम लॉग",
    'instruction': "मशीन को चालू करने के लिए दिए गए 'x' इनपुट के लिए 'y' आउटपुट की गणना करें।",
    'mouse_hint': "OUTPUT बॉक्स में गणना किया गया मान दर्ज करें और PROCESS DATA पर टैप करें।",
    'btn_check': "डेटा प्रोसेस करें",
    'btn_restart': "फिर से खेलें",
    'btn_retry': "रीसेट करें",
    'msg_level_up': "सिस्टम कैलिब्रेटेड!",
    'err_incorrect': "आउटपुट बेमेल! पुनर्गणना करें।",
    'err_invalid': "कृपया एक वैध पूर्णांक दर्ज करें।",
    'sys_reset': "सिस्टम रीसेट",
    'sys_init': "सिस्टम प्रारंभ हुआ।",
    'modal_title': "मिशन पूरा हुआ!",
    'modal_desc': "आपने रैखिक समीकरणों के समाधान खोजने में महारत हासिल कर ली है।",
    'btn_proceed': "अगला समीकरण",
    'btn_finish': "सिमुलेशन पूरा करें",

    // Dynamically added translations for the UI
    'lbl_level': "स्तर",
    'lbl_online': "ऑनलाइन",
    'log_processed': "संसाधित: f({x}) = {y}",
    'log_error_val': "त्रुटि: f({x}) != {y}",
    'log_lvl_loaded': "स्तर {val} लोड हुआ।",
    'hud_equation': "फंक्शन कोर",
    'lbl_input_x': "इनपुट (x)",
    'lbl_output_y': "आउटपुट (y)",
    'lbl_done': "पूर्ण",
  },
};

class SolutionGeneratorApp extends StatelessWidget {
  const SolutionGeneratorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'The Solution Generator',
      debugShowCheckedModeBanner: false,
      home: SolutionGeneratorScreen(),
    );
  }
}

class SolutionGeneratorScreen extends StatefulWidget {
  const SolutionGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<SolutionGeneratorScreen> createState() => _SolutionGeneratorScreenState();
}

class _SolutionGeneratorScreenState extends State<SolutionGeneratorScreen>
    with TickerProviderStateMixin {
  
  // Core State
  bool _showShutter = true;
  bool _sidebarOpen = true;
  bool missionComplete = false;
  String currentLang = 'en';

  // Game State
  int currentLevelIndex = 0;
  int currentInputIndex = 0;
  final TextEditingController _yInputController = TextEditingController();
  List<LogEntry> logs = [];

  // Machine Anim State
  bool isProcessing = false;
  bool isSuccessAnim = false;

  late final AudioPlayer _clickPlayer;
  late final AudioPlayer _fxPlayer;
  late final AudioPlayer _successPlayer;
  late final AudioPlayer _errorPlayer;
  late final AudioPlayer _shutterPlayer;

  final List<LevelData> levels = [
    LevelData(1, "y = 2x + 1", [1, -1], (x) => 2 * x + 1),
    LevelData(2, "y = -3x", [0, 2], (x) => -3 * x),
    LevelData(3, "x + y = 5", [3, 5], (x) => 5 - x),
    LevelData(4, "2x - y = 4", [2, 0], (x) => 2 * x - 4),
    LevelData(5, "y = ½x + 2", [4, -2], (x) => (x ~/ 2) + 2),
  ];

  // Overlays
  String? _bannerMessage;
  String? _bannerType;

  // Animations & Audio
  late AnimationController _pulseController;
  late AnimationController _celebrationController;
  late AnimationController _machineController;

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

    _machineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
    _machineController.dispose();
    _hudScrollController.dispose();
    _yInputController.dispose();

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

  void _processInput() {
    if (isProcessing || missionComplete || _showShutter) return;

    final String inputStr = _yInputController.text.trim();
    if (inputStr.isEmpty) return;

    final int? yValue = int.tryParse(inputStr);
    if (yValue == null) {
      _playSound(_errorPlayer, _errorUrl);
      _showBanner('error', t('err_invalid'));
      return;
    }

    HapticFeedback.mediumImpact();
    _playSound(_clickPlayer, _clickUrl);

    setState(() {
      isProcessing = true;
    });

    _machineController.forward(from: 0).then((_) {
      LevelData currentLevel = levels[currentLevelIndex];
      int xVal = currentLevel.testInputs[currentInputIndex];
      int expectedY = currentLevel.evaluator(xVal);

      if (yValue == expectedY) {
        // Success
        _playSound(_fxPlayer, _alertUrl); // Target processed
        _addLog('log_processed', params: {'x': xVal.toString(), 'y': yValue.toString()}, isSuccess: true);
        setState(() {
          isSuccessAnim = true;
        });

        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          setState(() {
            isProcessing = false;
            isSuccessAnim = false;
            _yInputController.clear();

            if (currentInputIndex < currentLevel.testInputs.length - 1) {
              currentInputIndex++;
            } else {
              // Level Complete
              if (currentLevelIndex < levels.length - 1) {
                currentLevelIndex++;
                currentInputIndex = 0;
                _playSound(_successPlayer, _successUrl);
                _showBanner('success', t('msg_level_up'));
                _addLog('log_lvl_loaded', params: {'val': (currentLevelIndex + 1).toString()}, isSuccess: true);
              } else {
                _playSound(_successPlayer, _successUrl);
                missionComplete = true;
                _celebrationController.forward();
              }
            }
          });
        });
      } else {
        // Failure
        HapticFeedback.vibrate();
        _playSound(_errorPlayer, _errorUrl);
        _addLog('log_error_val', params: {'x': xVal.toString(), 'y': yValue.toString()}, isSuccess: false);
        _showBanner('error', t('err_incorrect'));
        setState(() {
          isProcessing = false;
        });
      }
    });
  }

  void hardReset() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      currentLevelIndex = 0;
      currentInputIndex = 0;
      missionComplete = false;
      _yInputController.clear();
      isProcessing = false;
      isSuccessAnim = false;
      logs.clear();
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
                    child: _buildMainWorkspace(screenW)
                  )
                ),
              ],
            ),

            // Floating HUD - Docked in the Bottom Left
            // Positioned safely at left: 20
            if (!_sidebarOpen && !_showShutter && !missionComplete)
              _buildFloatingHUD(screenW),

            // Top Left Menu Button (Z-Index Front)
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
                        child: const Icon(Icons.hub, color: AppTheme.accent, size: 50),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Objective Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t('lab_mission_header'), style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Text('${currentLevelIndex + 1}/${levels.length}', style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                t('instruction'),
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

        // Logs Area inside sidebar
        Container(
          height: 180, 
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.muted.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t('ctrl_panel').toUpperCase(), style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(t('lbl_online').toUpperCase(), style: const TextStyle(color: Colors.green, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                ],
              ),
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
    );
  }

  Widget _buildFloatingHUD(double screenW) {
    double hudWidth = math.min(screenW * 0.38, 320.0);

    return Positioned(
      bottom: 20, 
      left: 20, // Safely docked at left: 20 since Back Button is removed
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
            crossAxisMargin: 2,
            thumbVisibility: true,
            child: SingleChildScrollView( 
              controller: _hudScrollController,
              padding: const EdgeInsets.all(16.0), 
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
                    t('instruction'),
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t('mouse_hint'),
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic, height: 1.3),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10)),
                  
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

  Widget _buildMainWorkspace(double screenW) {
    LevelData? currentLevel;
    int? currentX;
    if (currentLevelIndex < levels.length) {
      currentLevel = levels[currentLevelIndex];
      if (currentInputIndex < currentLevel.testInputs.length) {
        currentX = currentLevel.testInputs[currentInputIndex];
      }
    }

    // Determine dynamic padding when HUD is visible to keep the machine clear of the HUD
    bool isHudVisible = !_sidebarOpen && !_showShutter && !missionComplete;
    double hudRightEdge = 20.0 + math.min(screenW * 0.38, 320.0); // 20 due to left offset
    double leftPad = isHudVisible ? hudRightEdge : 0.0;

    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background Grid Painter
          Positioned.fill(
            child: CustomPaint(
              painter: DataGridPainter(),
            ),
          ),
          
          // Machine Area Wrapped in FittedBox to perfectly scale without scrolling
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(left: leftPad + 24, right: 24, top: 16, bottom: 16),
              child: Center(
                child: FittedBox( 
                  fit: BoxFit.scaleDown, // Ensures machine maintains exact proportions without overflowing
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Input Conveyor
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        transform: Matrix4.translationValues(0, isProcessing ? 20 : 0, 0),
                        child: Container(
                          width: 350,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.2),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            border: Border.all(color: AppTheme.primary, width: 2),
                            boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10)],
                          ),
                          child: Column(
                            children: [
                              Text(
                                t('lbl_input_x'),
                                style: const TextStyle(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentX != null ? currentX.toString() : "-",
                                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // The Machine Core
                      AnimatedBuilder(
                        animation: _machineController,
                        builder: (context, child) {
                          double shake = math.sin(_machineController.value * math.pi * 10) * 5;
                          if (!isProcessing) shake = 0;

                          return Transform.translate(
                            offset: Offset(shake, 0),
                            child: Container(
                              width: 350,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: isSuccessAnim ? AppTheme.success.withOpacity(0.2) : AppTheme.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSuccessAnim ? AppTheme.success : AppTheme.accent,
                                  width: isProcessing ? 4 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSuccessAnim
                                        ? AppTheme.success.withOpacity(0.5)
                                        : AppTheme.accent.withOpacity(isProcessing ? 0.6 : 0.2),
                                    blurRadius: isProcessing || isSuccessAnim ? 30 : 10,
                                    spreadRadius: isProcessing || isSuccessAnim ? 5 : 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.memory,
                                        color: isSuccessAnim ? AppTheme.success : AppTheme.accent,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        t('hud_equation'),
                                        style: const TextStyle(
                                          color: AppTheme.muted,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    currentLevel != null ? currentLevel.displayEq : t('lbl_done'),
                                    style: TextStyle(
                                      color: isSuccessAnim ? AppTheme.success : Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Output Conveyor
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        transform: Matrix4.translationValues(0, isSuccessAnim ? 10 : 0, 0),
                        child: Container(
                          width: 350,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSuccessAnim ? AppTheme.success.withOpacity(0.2) : AppTheme.secondary.withOpacity(0.2),
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                            border: Border.all(
                              color: isSuccessAnim ? AppTheme.success : AppTheme.secondary,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isSuccessAnim ? AppTheme.success : AppTheme.secondary).withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                t('lbl_output_y'),
                                style: TextStyle(
                                  color: isSuccessAnim ? AppTheme.success : AppTheme.secondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  controller: _yInputController,
                                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                  enabled: !isProcessing && !missionComplete,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppTheme.bg,
                                    hintText: "?",
                                    hintStyle: TextStyle(color: AppTheme.muted.withOpacity(0.5)),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppTheme.secondary),
                                    ),
                                  ),
                                  onSubmitted: (_) => _processInput(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Action Button
                      SizedBox(
                        width: 350,
                        child: ElevatedButton.icon(
                          onPressed: isProcessing || missionComplete ? null : _processInput,
                          icon: const Icon(Icons.bolt),
                          label: Text(
                            t('btn_check'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: AppTheme.bg,
                            disabledBackgroundColor: AppTheme.surface,
                            disabledForegroundColor: AppTheme.muted,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
                    const Icon(Icons.verified, color: AppTheme.success, size: 80),
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

class DataGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = AppTheme.gridLine.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double spacing = 30.0;

    // Draw subtle vertical and horizontal lines
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DataGridPainter oldDelegate) => false;
}