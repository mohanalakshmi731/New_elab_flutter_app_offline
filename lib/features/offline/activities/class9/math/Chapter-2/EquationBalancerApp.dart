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
  runApp(const EquationBalancerApp());
}

// --- THEME MANAGEMENT ---
class AppTheme {
  static const Color bg = Color(0xFF09090B); // Zinc 950
  static const Color surface = Color(0xFF18181B); // Zinc 900
  static const Color text = Color(0xFFFAFAFA);
  static const Color muted = Color(0xFFA1A1AA);
  static const Color accent = Color(0xFF14B8A6); // Teal 500
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color secondary = Color(0xFFF43F5E); // Rose 500
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color gridLine = Color(0xFF27272A);
  static const Color gridAxis = Color(0xFFE4E4E7);
}

// --- DATA MODELS ---
class EquationTerm {
  final String id;
  int coefficient;
  final String variable;

  EquationTerm(this.id, this.coefficient, this.variable);

  String get display {
    String sign = coefficient < 0 ? "-" : "";
    // If coeff is 1 or -1 and there is a variable, hide the '1'
    String val = (coefficient.abs() == 1 && variable.isNotEmpty)
        ? ""
        : coefficient.abs().toString();
    return "$sign$val$variable";
  }

  EquationTerm clone() {
    return EquationTerm(id, coefficient, variable);
  }
}

class LevelData {
  final int id;
  final List<EquationTerm> initialLeft;
  final List<EquationTerm> initialRight;

  LevelData(this.id, this.initialLeft, this.initialRight);
}

class LogEntry {
  final String message;
  final bool isSuccess;
  LogEntry(this.message, this.isSuccess);
}

// --- LOCALIZATION DICTIONARY ---
final Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': "THE EQUATION BALANCER",
    'tagline': "STANDARD FORM RECON",
    'init_btn': "INITIALIZE SYSTEMS",
    'header_subtitle': "Class 9 • LINEAR EQUATIONS - Standard Form",
    'lab_mission_header': "CURRENT OBJECTIVE",
    'ctrl_panel': "System Log",
    'instruction': "Move all terms to the left side to set the equation to zero (Standard Form: ax + by + c = 0).",
    'mouse_hint': "Drag a term across the equals sign. Notice how the sign changes automatically (+ becomes -, and vice versa).",
    'btn_check': "VERIFY EQUATION",
    'btn_restart': "Replay Mission",
    'btn_retry': "Reset Layout",
    'msg_awesome': "EQUATION BALANCED!",
    'err_incorrect': "Equation not in standard form yet! Move all terms to the left.",
    'sys_reset': "System Rebooted",
    'sys_init': "System Initialized.",
    'modal_title': "Mission Complete!",
    'modal_desc': "You have mastered rearranging linear equations into Standard Form.",
    'btn_proceed': "NEXT EQUATION",
    'btn_finish': "COMPLETE SIMULATION",
    
    // Dynamically added translations for the UI
    'lbl_level': "LEVEL",
    'lbl_online': "ONLINE",
    'lbl_std_form': "Standard Form: ",
    'log_move_left': "Moved {term} to Left Side",
    'log_move_right': "Moved {term} to Right Side",
    'log_lvl_loaded': "Level {val} Loaded",
    'log_reset_layout': "Layout Reset",
  },
  'hi': {
    'app_title': "समीकरण बैलेंसर",
    'tagline': "मानक रूप निर्माण",
    'init_btn': "सिस्टम प्रारंभ करें",
    'header_subtitle': "कक्षा 9 • रैखिक समीकरण – मानक रूप",
    'lab_mission_header': "वर्तमान उद्देश्य",
    'ctrl_panel': "सिस्टम लॉग",
    'instruction': "समीकरण को शून्य (मानक रूप: ax + by + c = 0) के बराबर सेट करने के लिए सभी पदों को बाईं ओर ले जाएँ।",
    'mouse_hint': "पदों को बराबर के चिह्न के पार खींचें। ध्यान दें कि चिह्न कैसे बदलता है (+ से -, और - से +)।",
    'btn_check': "समीकरण जांचें",
    'btn_restart': "फिर से खेलें",
    'btn_retry': "रीसेट करें",
    'msg_awesome': "समीकरण संतुलित!",
    'err_incorrect': "समीकरण अभी मानक रूप में नहीं है! सभी पदों को बाईं ओर ले जाएँ।",
    'sys_reset': "सिस्टम रीसेट",
    'sys_init': "सिस्टम प्रारंभ हुआ।",
    'modal_title': "मिशन पूरा हुआ!",
    'modal_desc': "आपने रैखिक समीकरणों को मानक रूप में पुनर्व्यवस्थित करने में महारत हासिल कर ली है।",
    'btn_proceed': "अगला समीकरण",
    'btn_finish': "सिमुलेशन पूरा करें",

    // Dynamically added translations for the UI
    'lbl_level': "स्तर",
    'lbl_online': "ऑनलाइन",
    'lbl_std_form': "मानक रूप: ",
    'log_move_left': "{term} को बाईं ओर ले जाया गया",
    'log_move_right': "{term} को दाईं ओर ले जाया गया",
    'log_lvl_loaded': "स्तर {val} लोड हुआ",
    'log_reset_layout': "लेआउट रीसेट",
  },
};

class EquationBalancerApp extends StatelessWidget {
  const EquationBalancerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'The Equation Balancer',
      debugShowCheckedModeBanner: false,
      home: EquationBalancerScreen(),
    );
  }
}

class EquationBalancerScreen extends StatefulWidget {
  const EquationBalancerScreen({Key? key}) : super(key: key);

  @override
  State<EquationBalancerScreen> createState() => _EquationBalancerScreenState();
}

class _EquationBalancerScreenState extends State<EquationBalancerScreen>
    with TickerProviderStateMixin {
  
  // Core State
  bool _showShutter = true;
  bool _sidebarOpen = true;
  bool missionComplete = false;
  String currentLang = 'en';

  // Game State
  int currentLevelIndex = 0;
  List<EquationTerm> leftSide = [];
  List<EquationTerm> rightSide = [];
  List<LogEntry> logs = [];

  final List<LevelData> levels = [
    LevelData(1, [EquationTerm("t1", 2, "x")], [EquationTerm("t2", 3, "y")]), // 2x = 3y
    LevelData(2, [EquationTerm("t1", 1, "y")], [EquationTerm("t2", 5, "x"), EquationTerm("t3", 2, "")]), // y = 5x + 2
    LevelData(3, [EquationTerm("t1", 1, "x"), EquationTerm("t2", -4, "")], [EquationTerm("t3", 2, "y")]), // x - 4 = 2y
    LevelData(4, [EquationTerm("t1", -3, "x")], [EquationTerm("t2", 4, "y"), EquationTerm("t3", -7, "")]), // -3x = 4y - 7
    LevelData(5, [EquationTerm("t1", 5, "")], [EquationTerm("t2", 2, "x"), EquationTerm("t3", 3, "y")]), // 5 = 2x + 3y
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

    _loadLevel(0);
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

  void _loadLevel(int index) {
    if (index >= levels.length) return;
    setState(() {
      leftSide = levels[index].initialLeft.map((t) => t.clone()).toList();
      rightSide = levels[index].initialRight.map((t) => t.clone()).toList();
    });
  }

  void _handleDrop(EquationTerm term, String targetSide) {
    setState(() {
      if (targetSide == 'left') {
        if (rightSide.any((t) => t.id == term.id)) {
          rightSide.removeWhere((t) => t.id == term.id);
          term.coefficient *= -1; // Transposition sign flip
          leftSide.add(term);
          _playSound(_fxPlayer, _alertUrl);
          _addLog('log_move_left', params: {'term': term.display}, isSuccess: true);
        }
      } else if (targetSide == 'right') {
        if (leftSide.any((t) => t.id == term.id)) {
          leftSide.removeWhere((t) => t.id == term.id);
          term.coefficient *= -1; // Transposition sign flip
          rightSide.add(term);
          _playSound(_fxPlayer, _alertUrl);
          _addLog('log_move_right', params: {'term': term.display}, isSuccess: true);
        }
      }
    });
  }

  void _checkEquation() {
    if (missionComplete || _showShutter) return;

    if (rightSide.isEmpty) {
      // Success - all terms on the left
      HapticFeedback.heavyImpact();
      _playSound(_successPlayer, _successUrl);
      _showBanner('success', t('msg_awesome'));
      _addLog('msg_awesome');

      if (currentLevelIndex < levels.length - 1) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              currentLevelIndex++;
              _loadLevel(currentLevelIndex);
              _addLog('log_lvl_loaded', params: {'val': (currentLevelIndex + 1).toString()}, isSuccess: true);
            });
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              missionComplete = true;
              _celebrationController.forward();
            });
          }
        });
      }
    } else {
      // Error
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
      _showBanner('error', t('err_incorrect'));
      _addLog('err_incorrect', isSuccess: false);
    }
  }

  void hardReset() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      currentLevelIndex = 0;
      missionComplete = false;
      _loadLevel(0);
      logs.clear();
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
      _loadLevel(currentLevelIndex);
      _addLog('log_reset_layout', isSuccess: false);
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
                        child: const Icon(Icons.balance, color: AppTheme.accent, size: 50),
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
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  foregroundColor: AppTheme.bg,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _checkEquation,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(t('btn_check'), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14)),
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
                    t('instruction'),
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t('mouse_hint'),
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic, height: 1.3),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10)),
                  
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: AppTheme.bg,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _checkEquation,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(t('btn_check'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
    // Determine dynamic padding when HUD is visible to keep drop zones clear of the HUD
    bool isHudVisible = !_sidebarOpen && !_showShutter && !missionComplete;
    double hudRightEdge = 20.0 + math.min(screenW * 0.38, 320.0);
    double leftPad = isHudVisible ? hudRightEdge : 0.0;

    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background Grid Painter
          Positioned.fill(
            child: CustomPaint(
              painter: BalancerBackgroundPainter(),
            ),
          ),
          
          // Drag & Drop Area Wrapped in FittedBox to perfectly scale without scrolling!
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(left: leftPad + 24, right: 24, top: 16, bottom: 16),
              child: Center(
                child: FittedBox( 
                  fit: BoxFit.scaleDown, // Ensures boxes maintain exact proportions without overflowing
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t('lbl_std_form'),
                              style: const TextStyle(color: AppTheme.muted, fontSize: 14),
                            ),
                            const Text(
                              "ax + by + c = 0",
                              style: TextStyle(color: AppTheme.accent, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Fixed Row (FittedBox handles any necessary scaling)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDropZone('left', leftSide),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.surface,
                                    border: Border.all(
                                      color: AppTheme.accent.withOpacity(0.5 + 0.5 * _pulseController.value),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accent.withOpacity(0.2 * _pulseController.value),
                                        blurRadius: 15,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    "=",
                                    style: TextStyle(color: AppTheme.accent, fontSize: 32, fontWeight: FontWeight.bold),
                                  ),
                                );
                              },
                            ),
                          ),
                          _buildDropZone('right', rightSide),
                        ],
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

  Widget _buildDropZone(String side, List<EquationTerm> terms) {
    return DragTarget<EquationTerm>(
      onAcceptWithDetails: (details) {
        _handleDrop(details.data, side);
      },
      builder: (context, candidateData, rejectedData) {
        bool isHovered = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 260, // Perfectly square-like fixed size
          height: 260,
          decoration: BoxDecoration(
            color: isHovered ? AppTheme.accent.withOpacity(0.1) : AppTheme.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isHovered ? AppTheme.accent : AppTheme.muted.withOpacity(0.2),
              width: isHovered ? 3 : 2,
            ),
            boxShadow: [
              if (isHovered)
                BoxShadow(color: AppTheme.accent.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: Center(
            child: terms.isEmpty
                ? Text(
                    "0",
                    style: TextStyle(color: AppTheme.muted.withOpacity(0.5), fontSize: 48, fontWeight: FontWeight.w900),
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: terms.map((t) => _buildDraggableTerm(t)).toList(),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDraggableTerm(EquationTerm term) {
    return Draggable<EquationTerm>(
      data: term,
      feedback: Material(
        color: Colors.transparent,
        child: _buildTermBlock(term, isDragging: true),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildTermBlock(term)),
      child: _buildTermBlock(term),
      onDragStarted: () {
        HapticFeedback.selectionClick();
        _playSound(_clickPlayer, _clickUrl);
      },
    );
  }

  Widget _buildTermBlock(EquationTerm term, {bool isDragging = false}) {
    Color blockColor;
    if (term.variable == 'x') {
      blockColor = AppTheme.primary;
    } else if (term.variable == 'y') {
      blockColor = AppTheme.secondary;
    } else {
      blockColor = AppTheme.accent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: blockColor, width: 2),
        boxShadow: isDragging
            ? [BoxShadow(color: blockColor.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)]
            : [],
      ),
      child: Text(
        term.display,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20, 
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: blockColor, blurRadius: 5)],
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
                    const Icon(Icons.check_circle, color: AppTheme.success, size: 80),
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

class BalancerBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = AppTheme.gridLine.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BalancerBackgroundPainter oldDelegate) => false;
}