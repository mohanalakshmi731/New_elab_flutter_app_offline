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
const String _errorUrl = 'audio/class9/error.mp3'; // Exact error buzzer requested
const String _alertUrl = 'audio/class9/alert.mp3';
const String _shutterUrl = 'audio/class9/shutter.mp3'; // Exact shutter opening requested

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
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CoordinateScoutApp(),
    ),
  );
}

// --- GAME DATA MODELS ---
class LevelData {
  final int id;
  final String name;
  final String targetDescKey;
  final Offset targetPos;

  LevelData({
    required this.id,
    required this.name,
    required this.targetDescKey,
    required this.targetPos,
  });
}

// --- LOCALIZATION DICTIONARY ---
final Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'COORDINATE SCOUT',
    'app_subtitle': 'CLASS 9 • Coordinate Geometry',
    'mission_obj_lbl': 'MISSION OBJECTIVE',
    'mission_simple': 'Deploy the scout to the exact (X, Y) coordinates on the Cartesian plane to locate hidden anomalies.',
    'btn_start_lab': 'Launch Mission',
    'lab_status_header': 'SCOUT STATUS',
    'sector_lbl': 'SECTOR {id}/{total}',
    'mission_title': 'Target Anomaly',
    'target_coord_lbl': 'TARGET COORDINATES',
    'btn_hint': 'REQUEST HINT',
    'input_x': 'X =',
    'input_y': 'Y =',
    'btn_launch': 'DEPLOY SCOUT',
    'msg_success': 'ANOMALY SECURED!',
    'msg_crash': 'SCAN FAILED. EMPTY SPACE.',
    'modal_title': 'TARGET ACQUIRED',
    'poly_zero_confirmed': 'Coordinates match the anomaly location perfectly.',
    'btn_proceed': 'NEXT SECTOR',
    'btn_finish': 'COMPLETE MISSION',
    'hud_coord': 'Scout Location',
    'msg_proof_success': 'ALL ANOMALIES FOUND! GALAXY MAPPED.',
    'mission_completed': 'MISSION COMPLETED',
    'restart_mission': 'RESTART MISSION',
    'init_flight': 'INITIALIZING SENSORS...',
    'lbl_target': 'ANOMALY',
    'err_num_input': 'Invalid coordinates.',
    'err_coord_limit': 'Keep coordinates between -10 and 10.',
    'hint_msg': 'Hint: The first number is X (Left/Right). The second is Y (Up/Down).',
    'quad_1': 'QUADRANT I',
    'quad_2': 'QUADRANT II',
    'quad_3': 'QUADRANT III',
    'quad_4': 'QUADRANT IV',

    'lvl_1_desc': 'Locate the anomaly Alpha in Quadrant I.',
    'lvl_2_desc': 'Locate the anomaly Beta in Quadrant II.',
    'lvl_3_desc': 'Locate the anomaly Gamma in Quadrant III.',
    'lvl_4_desc': 'Locate the anomaly Delta in Quadrant IV.',
    'lvl_5_desc': 'Locate the anomaly Echo on the Y-Axis.',
  },
  'hi': {
    'app_title': 'कोऑर्डिनेट स्काउट',
    'app_subtitle': 'कक्षा 9 • निर्देशांक ज्यामिति',
    'mission_obj_lbl': 'मिशन का उद्देश्य',
    'mission_simple': 'छिपी हुई विसंगतियों का पता लगाने के लिए कार्टेशियन तल पर सटीक (X, Y) निर्देशांक पर स्काउट तैनात करें।',
    'btn_start_lab': 'मिशन शुरू करें',
    'lab_status_header': 'स्काउट की स्थिति',
    'sector_lbl': 'सेक्टर {id}/{total}',
    'mission_title': 'लक्ष्य विसंगति',
    'target_coord_lbl': 'लक्ष्य निर्देशांक',
    'btn_hint': 'संकेत मांगें',
    'input_x': 'X =',
    'input_y': 'Y =',
    'btn_launch': 'स्काउट तैनात करें',
    'msg_success': 'विसंगति सुरक्षित!',
    'msg_crash': 'स्कैन विफल। खाली स्थान।',
    'modal_title': 'लक्ष्य प्राप्त',
    'poly_zero_confirmed': 'निर्देशांक विसंगति स्थान से पूरी तरह मेल खाते हैं।',
    'btn_proceed': 'अगला सेक्टर',
    'btn_finish': 'मिशन पूरा करें',
    'hud_coord': 'स्काउट स्थान',
    'msg_proof_success': 'सभी विसंगतियाँ मिल गईं! गैलेक्सी मैप की गई।',
    'mission_completed': 'मिशन पूरा हुआ',
    'restart_mission': 'मिशन पुनरारंभ करें',
    'init_flight': 'सेंसर शुरू हो रहे हैं...',
    'lbl_target': 'विसंगति',
    'err_num_input': 'अमान्य निर्देशांक।',
    'err_coord_limit': 'निर्देशांक -10 और 10 के बीच रखें।',
    'hint_msg': 'संकेत: पहली संख्या X (बाएं/दाएं) है। दूसरी Y (ऊपर/नीचे) है।',
    'quad_1': 'चतुर्थांश I',
    'quad_2': 'चतुर्थांश II',
    'quad_3': 'चतुर्थांश III',
    'quad_4': 'चतुर्थांश IV',

    'lvl_1_desc': 'चतुर्थांश I में विसंगति अल्फा का पता लगाएं।',
    'lvl_2_desc': 'चतुर्थांश II में विसंगति बीटा का पता लगाएं।',
    'lvl_3_desc': 'चतुर्थांश III में विसंगति गामा का पता लगाएं।',
    'lvl_4_desc': 'चतुर्थांश IV में विसंगति डेल्टा का पता लगाएं।',
    'lvl_5_desc': 'Y-अक्ष पर विसंगति इको का पता लगाएं।',
  },
};

// Level Definitions
final List<LevelData> levels = [
  LevelData(id: 1, name: 'Alpha', targetDescKey: 'lvl_1_desc', targetPos: const Offset(4, 3)),
  LevelData(id: 2, name: 'Beta', targetDescKey: 'lvl_2_desc', targetPos: const Offset(-5, 2)),
  LevelData(id: 3, name: 'Gamma', targetDescKey: 'lvl_3_desc', targetPos: const Offset(-3, -4)),
  LevelData(id: 4, name: 'Delta', targetDescKey: 'lvl_4_desc', targetPos: const Offset(5, -2)),
  LevelData(id: 5, name: 'Echo', targetDescKey: 'lvl_5_desc', targetPos: const Offset(0, 6)),
];

// --- MAIN APP WIDGET ---
class CoordinateScoutApp extends StatefulWidget {
  const CoordinateScoutApp({super.key});

  @override
  State<CoordinateScoutApp> createState() => _CoordinateScoutAppState();
}

class _CoordinateScoutAppState extends State<CoordinateScoutApp>
    with TickerProviderStateMixin {
  // Theme colors (Cyber/Space Theme)
  final Color bgTheme = const Color(0xFF020617); // slate-950
  final Color panelColor = const Color(0xFF0f172a); // solid slate-900
  final Color accentTheme = const Color(0xFF06b6d4); // cyan-500
  final Color primaryTheme = const Color(0xFFa855f7); // purple-500
  final Color successTheme = const Color(0xFF10b981); // emerald-500
  final Color errorTheme = const Color(0xFFf43f5e); // rose-500

  // App State
  String _currentLang = 'en';
  bool _sidebarOpen = true;
  bool _showShutter = true;

  // Game State
  int _stepIndex = 0;
  String _gameState = 'idle'; // idle, scanning, landed, crashed, complete
  final TextEditingController _xInputController = TextEditingController();
  final TextEditingController _yInputController = TextEditingController();

  // Coordinates and Animation
  Offset _scoutPos = const Offset(0, 0); // Starts at origin
  Offset _panOffset = Offset.zero; // For draggable graph
  late AnimationController _flightController;
  late Animation<Offset> _flightAnim;

  // Overlay
  String? _bannerMessage;
  String? _bannerType;
  late AnimationController _pulseController;

  String t(String key) => i18n[_currentLang]?[key] ?? key;
  LevelData get currentLevel => levels[_stepIndex];

  @override
  void initState() {
    super.initState();
    // Enforce Landscape Mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(() {
        setState(() {
          _scoutPos = _flightAnim.value;
        });
      });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _pulseController.dispose();
    _flightController.dispose();
    _xInputController.dispose();
    _yInputController.dispose();
    
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _shutterPlayer.dispose();
    
    super.dispose();
  }

  // --- GAME LOGIC ---
  void _resetLevel() {
    setState(() {
      _gameState = 'idle';
      _scoutPos = const Offset(0, 0);
      _panOffset = Offset.zero;
      _xInputController.clear();
      _yInputController.clear();
      _bannerMessage = null;
    });
  }

  void _launchScout() {
    if (_gameState == 'scanning' || _xInputController.text.isEmpty || _yInputController.text.isEmpty) return;

    double? xInput = double.tryParse(_xInputController.text.trim());
    double? yInput = double.tryParse(_yInputController.text.trim());

    if (xInput == null || yInput == null) {
      _showBanner('error', t('err_num_input'));
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
      return;
    }

    // Clamp input to visible grid [-10, 10]
    if (xInput < -10 || xInput > 10 || yInput < -10 || yInput > 10) {
      _showBanner('error', t('err_coord_limit'));
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
      return;
    }

    HapticFeedback.selectionClick();
    _playSound(_fxPlayer, _alertUrl); // Launch sound
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    setState(() {
      _gameState = 'scanning';
    });

    // Animate from (0, 0) to (xInput, yInput)
    _flightAnim = Tween<Offset>(
      begin: const Offset(0, 0),
      end: Offset(xInput, yInput),
    ).animate(
      CurvedAnimation(
        parent: _flightController,
        curve: Curves.easeInOutQuad,
      ),
    );

    _flightController.forward(from: 0.0).then((_) {
      // Check landing condition
      double dist = (Offset(xInput, yInput) - currentLevel.targetPos).distance;
      if (dist < 0.1) {
        // Safe Landing
        HapticFeedback.heavyImpact();
        _playSound(_successPlayer, _successUrl);
        setState(() => _gameState = 'landed');
        _showBanner('success', t('msg_success'));
      } else {
        // Missed Target
        HapticFeedback.vibrate();
        _playSound(_errorPlayer, _errorUrl);
        setState(() => _gameState = 'crashed');
        _showBanner('error', t('msg_crash'));
      }
    });
  }

  void _proceedToNext() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      if (_stepIndex < levels.length - 1) {
        _stepIndex++;
        _resetLevel();
      } else {
        // Mission Complete
        _playSound(_successPlayer, _successUrl);
        _gameState = 'complete';
      }
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

  // --- UI BUILDING ---

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double sidebarWidth = screenW * 0.38; // Locked 38% sidebar

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: bgTheme,
        body: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 38% Sidebar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _sidebarOpen ? sidebarWidth : 0,
                  decoration: BoxDecoration(
                    color: panelColor,
                    border: Border(right: BorderSide(color: accentTheme.withOpacity(0.2))),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      width: sidebarWidth,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                        child: _buildSidebarContent(),
                      ),
                    ),
                  ),
                ),
                
                // Responsive Workspace
                Expanded(
                  child: ClipRect(
                    child: _buildMainWorkspace()
                  )
                ),
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

            // Overlays
            if (_bannerMessage != null) _buildBanner(),
            if (_gameState == 'landed' && !_showShutter) _buildSuccessModal(),
            if (_gameState == 'complete' && !_showShutter) _buildFinalCompleteModal(),
            if (_showShutter) _buildLoadingShutter(),
          ],
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
          const SizedBox(height: 56), // Spacer for top-left menu

          Text(
            t('app_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              height: 1.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            t('app_subtitle'),
            style: TextStyle(
              color: primaryTheme,
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
                  border: Border.all(color: accentTheme.withOpacity(0.3)),
                ),
                child: Row(children: [_langBtn('en', 'EN'), _langBtn('hi', 'HI')]),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryTheme.withOpacity(0.6), width: 2.0),
                ),
                child: IconButton(
                  icon: Icon(Icons.power_settings_new, color: primaryTheme),
                  tooltip: 'Reset Top Level',
                  onPressed: () {
                    HapticFeedback.vibrate();
                    _playSound(_clickPlayer, _clickUrl);
                    setState(() {
                      _stepIndex = 0;
                      _resetLevel();
                      _showShutter = true;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Active Content View
          _buildLabContent(),

          // Footer
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
    bool active = _currentLang == code;
    return GestureDetector(
      onTap: () {
        if (!active) {
          HapticFeedback.selectionClick();
          _playSound(_clickPlayer, _clickUrl);
          setState(() => _currentLang = code);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? accentTheme : Colors.transparent,
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
    if (_gameState == 'complete') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mission Objective
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentTheme.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentTheme.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('mission_obj_lbl'),
                style: TextStyle(
                  color: accentTheme,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t('mission_simple'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
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
                    t('lab_status_header'),
                    style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  Text(
                    t('sector_lbl')
                        .replaceAll('{id}', '${_stepIndex + 1}')
                        .replaceAll('{total}', '${levels.length}'),
                    style: TextStyle(color: accentTheme, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_stepIndex + 1) / levels.length,
                backgroundColor: Colors.white10,
                color: accentTheme,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Mission Input Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryTheme.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryTheme.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.radar, color: accentTheme, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    t('mission_title').toUpperCase(),
                    style: TextStyle(color: accentTheme, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                currentLevel.name,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 8),
              Text(
                t(currentLevel.targetDescKey),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Colors.white10),
              ),

              // Reused Input Controls
              _buildInputControls(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('target_coord_lbl'),
          style: TextStyle(color: primaryTheme, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(t('input_x'), style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: _xInputController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                enabled: _gameState == 'idle' || _gameState == 'crashed',
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15), // Highly readable against dark background
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: accentTheme)),
                ),
                onSubmitted: (_) => _launchScout(),
              ),
            ),
            const SizedBox(width: 12),
            Text(t('input_y'), style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: _yInputController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                enabled: _gameState == 'idle' || _gameState == 'crashed',
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15), // Highly readable against dark background
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: accentTheme)),
                ),
                onSubmitted: (_) => _launchScout(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTheme,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            disabledBackgroundColor: Colors.white10,
          ),
          onPressed: (_gameState == 'idle' || _gameState == 'crashed') ? _launchScout : null,
          child: Text(t('btn_launch'), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: accentTheme,
            side: BorderSide(color: accentTheme.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            _playSound(_clickPlayer, _clickUrl);
            _showBanner('info', t('hint_msg'));
          },
          icon: const Icon(Icons.lightbulb_outline, size: 16),
          label: Text(t('btn_hint').toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildMainWorkspace() {
    if (_gameState == 'complete') {
      return _buildFinalCompleteModal();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Background grid
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF0f172a), Color(0xFF020617)],
                  center: Alignment.center,
                  radius: 1.0,
                ),
              ),
            ),

            // Draggable Area for Graph & Drone
            Positioned.fill(
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _panOffset += details.delta;
                    // Clamp to prevent getting lost in deep space
                    _panOffset = Offset(
                      _panOffset.dx.clamp(-constraints.maxWidth * 2, constraints.maxWidth * 2),
                      _panOffset.dy.clamp(-constraints.maxHeight * 2, constraints.maxHeight * 2),
                    );
                  });
                },
                child: Stack(
                  children: [
                    // Interactive Area & Painting
                    CustomPaint(
                      size: Size.infinite,
                      painter: SpaceGridPainter(
                        gridColor: accentTheme.withOpacity(0.1),
                        axisColor: Colors.white30,
                        targetPos: currentLevel.targetPos,
                        targetColor: primaryTheme,
                        targetText: t('lbl_target'),
                        pulse: _pulseController.value,
                        panOffset: _panOffset,
                        quad1: t('quad_1'),
                        quad2: t('quad_2'),
                        quad3: t('quad_3'),
                        quad4: t('quad_4'),
                        accentTheme: accentTheme,
                      ),
                    ),

                    // Flight Path & Scout Drone
                    CustomPaint(
                      size: Size.infinite,
                      painter: ScoutDronePainter(
                        scoutPos: _scoutPos,
                        scoutColor: _gameState == 'crashed' ? errorTheme : accentTheme,
                        isLanded: _gameState == 'landed',
                        panOffset: _panOffset,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Recenter Button (Bottom Right)
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
                  setState(() => _panOffset = Offset.zero);
                },
                child: const Icon(Icons.center_focus_strong, size: 20),
              ),
            ),

            // HUD Coordinate Top Right
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      t('hud_coord').toUpperCase(),
                      style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'X: ${_scoutPos.dx.toStringAsFixed(1)}  Y: ${_scoutPos.dy.toStringAsFixed(1)}',
                      style: TextStyle(color: accentTheme, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
            
            // Comprehensive Mission Overlay (Left side when sidebar closed, safely docked in bottom-left)
            if (!_sidebarOpen && !_showShutter)
              Positioned(
                bottom: 20,
                left: 20,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: math.min(constraints.maxWidth * 0.4, 280.0), // Compact HUD size
                    maxHeight: constraints.maxHeight - 40,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: 280.0, // Fixed compact width
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black87.withOpacity(0.95), // Solid to cover background
                        borderRadius: BorderRadius.circular(12),
                        border: Border(left: BorderSide(color: primaryTheme, width: 4)),
                        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Takes only required height natively
                        children: [
                          Text(
                            t('mission_title').toUpperCase(),
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 10, letterSpacing: 1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentLevel.name,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t(currentLevel.targetDescKey),
                            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Colors.white10),
                          ),
                          // Input Controls integrated into Canvas HUD
                          _buildInputControls(),
                        ],
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

  // --- OVERLAYS ---

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
            color: isSuccess ? successTheme.withOpacity(0.9) : errorTheme.withOpacity(0.9),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: isSuccess ? Colors.greenAccent : Colors.redAccent),
            boxShadow: [
              BoxShadow(color: isSuccess ? successTheme.withOpacity(0.5) : errorTheme.withOpacity(0.5), blurRadius: 30),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isSuccess ? Icons.check_circle : Icons.warning, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                _bannerMessage ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessModal() {
    bool isLast = _stepIndex >= levels.length - 1;

    return Container(
      color: Colors.black87,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: bgTheme,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: successTheme),
                boxShadow: [BoxShadow(color: successTheme.withOpacity(0.2), blurRadius: 80)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: successTheme, size: 60),
                  const SizedBox(height: 24),
                  Text(
                    t('modal_title'),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t('poly_zero_confirmed'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successTheme,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _proceedToNext();
                    },
                    child: Text(
                      isLast ? t('btn_finish') : t('btn_proceed'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
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

  Widget _buildFinalCompleteModal() {
    return Container(
      color: Colors.black87,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: bgTheme,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryTheme),
                boxShadow: [BoxShadow(color: primaryTheme.withOpacity(0.2), blurRadius: 80)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, color: primaryTheme, size: 64),
                  const SizedBox(height: 24),
                  Text(
                    t('mission_completed'),
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t('msg_proof_success'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTheme,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _playSound(_shutterPlayer, _shutterUrl);
                      setState(() {
                        _stepIndex = 0;
                        _resetLevel();
                        _showShutter = true;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      t('restart_mission'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
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

  Widget _buildLoadingShutter() {
    return Container(
      color: bgTheme,
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
                          border: Border.all(color: primaryTheme.withOpacity(0.5), width: 3),
                          boxShadow: [
                            BoxShadow(color: primaryTheme.withOpacity(0.3 + (_pulseController.value * 0.4)), blurRadius: 40),
                          ],
                        ),
                        child: Icon(Icons.gps_fixed, color: primaryTheme, size: 50),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Text(
                  t('app_title'),
                  style: TextStyle(color: primaryTheme, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
                ),
                const SizedBox(height: 12),
                Text(
                  t('init_flight'),
                  style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 3, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTheme,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _playSound(_shutterPlayer, _shutterUrl);
                    setState(() {
                      _showShutter = false;
                    });
                    if (_gameState == 'idle' && _stepIndex == 0) _resetLevel();
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    t('btn_start_lab').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTERS ---

class SpaceGridPainter extends CustomPainter {
  final Color gridColor;
  final Color axisColor;
  final Offset targetPos;
  final Color targetColor;
  final String targetText;
  final double pulse;
  final Offset panOffset;
  
  final String quad1;
  final String quad2;
  final String quad3;
  final String quad4;
  final Color accentTheme;

  SpaceGridPainter({
    required this.gridColor,
    required this.axisColor,
    required this.targetPos,
    required this.targetColor,
    required this.targetText,
    required this.pulse,
    required this.panOffset,
    required this.quad1,
    required this.quad2,
    required this.quad3,
    required this.quad4,
    required this.accentTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = (size.width / 2) + panOffset.dx;
    final double cy = (size.height / 2) + panOffset.dy;
    
    // Divide max dimension by 22 for more breathing room per unit
    final double scale = math.max(size.width, size.height) / 22;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 2;

    // Draw the quadrant badges in the background
    double qOffset = 5 * scale;
    _drawQuadrantBadge(canvas, quad1, Offset(cx + qOffset, cy - qOffset)); // Top Right
    _drawQuadrantBadge(canvas, quad2, Offset(cx - qOffset, cy - qOffset)); // Top Left
    _drawQuadrantBadge(canvas, quad3, Offset(cx - qOffset, cy + qOffset)); // Bottom Left
    _drawQuadrantBadge(canvas, quad4, Offset(cx + qOffset, cy + qOffset)); // Bottom Right

    // Bounded strictly to -10 to 10
    double gridLimit = 10.8 * scale; // Extends slightly past 10 so labels are comfortably inside
    
    for (int i = -10; i <= 10; i++) {
      double offset = i * scale;
      
      // Draw bounded grid lines so they don't stretch to infinity, making the 10x10 box clear
      canvas.drawLine(Offset(cx - gridLimit, cy + offset), Offset(cx + gridLimit, cy + offset), gridPaint); // Horiz
      canvas.drawLine(Offset(cx + offset, cy - gridLimit), Offset(cx + offset, cy + gridLimit), gridPaint); // Vert
      
      // Draw Coordinate Numbers on Axes
      if (i != 0) {
        // X-axis: at y = cy.
        _drawXText(canvas, '$i', Offset(cx + offset, cy), Colors.white70);
        // Y-axis: at x = cx.
        // Visually screen Y increases downwards, so i=10 is down. In math, down is negative.
        _drawYText(canvas, '${-i}', Offset(cx, cy + offset), Colors.white70);
      }
    }

    // Axes
    canvas.drawLine(Offset(cx - gridLimit, cy), Offset(cx + gridLimit, cy), axisPaint);
    canvas.drawLine(Offset(cx, cy - gridLimit), Offset(cx, cy + gridLimit), axisPaint);
    _drawXText(canvas, '0', Offset(cx, cy), Colors.white);

    // Target Anomaly Point
    double px = cx + (targetPos.dx * scale);
    double py = cy - (targetPos.dy * scale); // Minus because screen Y goes down

    final padPaint = Paint()..color = targetColor.withOpacity(0.3 + pulse * 0.4)..style = PaintingStyle.fill;
    final padBorder = Paint()..color = targetColor..style = PaintingStyle.stroke..strokeWidth = 2;

    canvas.drawCircle(Offset(px, py), 12 + (pulse * 8), padPaint);
    canvas.drawCircle(Offset(px, py), 8, padBorder);

    TextPainter(
      text: TextSpan(text: targetText, style: TextStyle(color: targetColor, fontSize: 10, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, Offset(px - 15, py + 20));
  }

  void _drawXText(Canvas canvas, String text, Offset pos, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    // Centered underneath the tick mark
    textPainter.paint(canvas, Offset(pos.dx - textPainter.width / 2, pos.dy + 8));
  }
  
  void _drawYText(Canvas canvas, String text, Offset pos, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    // Centered to the left of the tick mark
    textPainter.paint(canvas, Offset(pos.dx - textPainter.width - 8, pos.dy - textPainter.height / 2));
  }

  void _drawQuadrantBadge(Canvas canvas, String text, Offset center) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: accentTheme.withOpacity(0.6), 
          fontSize: 14, 
          fontWeight: FontWeight.bold, 
          letterSpacing: 2
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    final rect = Rect.fromCenter(
      center: center, 
      width: textPainter.width + 32, 
      height: textPainter.height + 16
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));
    
    // Draw pill background and border
    canvas.drawRRect(rrect, Paint()..color = accentTheme.withOpacity(0.05)..style = PaintingStyle.fill);
    canvas.drawRRect(rrect, Paint()..color = accentTheme.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    
    // Draw text centered in the pill
    textPainter.paint(
      canvas, 
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2)
    );
  }

  @override
  bool shouldRepaint(covariant SpaceGridPainter oldDelegate) {
    return oldDelegate.targetPos != targetPos || 
           oldDelegate.pulse != pulse ||
           oldDelegate.panOffset != panOffset ||
           oldDelegate.quad1 != quad1;
  }
}

class ScoutDronePainter extends CustomPainter {
  final Offset scoutPos;
  final Color scoutColor;
  final bool isLanded;
  final Offset panOffset;

  ScoutDronePainter({
    required this.scoutPos,
    required this.scoutColor,
    required this.isLanded,
    required this.panOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = (size.width / 2) + panOffset.dx;
    final double cy = (size.height / 2) + panOffset.dy;
    
    // MUST match the SpaceGridPainter scale
    final double scale = math.max(size.width, size.height) / 22;

    // Map logic coordinate to screen pixel
    double px = cx + (scoutPos.dx * scale);
    double py = cy - (scoutPos.dy * scale); 

    // Draw flight path line from origin to scout
    final pathPaint = Paint()
      ..color = scoutColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    _drawDashedLine(canvas, Offset(cx, cy), Offset(px, py), pathPaint);

    // Draw Scout Crosshair / Drone
    final paint = Paint()
      ..color = scoutColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    final glow = Paint()
      ..color = scoutColor.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(Offset(px, py), 15, glow);
    canvas.drawCircle(Offset(px, py), 6, paint);
    
    // Crosshair Lines
    canvas.drawLine(Offset(px - 10, py), Offset(px - 2, py), paint);
    canvas.drawLine(Offset(px + 2, py), Offset(px + 10, py), paint);
    canvas.drawLine(Offset(px, py - 10), Offset(px, py - 2), paint);
    canvas.drawLine(Offset(px, py + 2), Offset(px, py + 10), paint);

    // Center dot
    canvas.drawCircle(Offset(px, py), 2, Paint()..color = Colors.white);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 5, dashSpace = 5;
    double dx = p2.dx - p1.dx, dy = p2.dy - p1.dy;
    double dist = math.sqrt(dx * dx + dy * dy);
    if (dist == 0) return;
    
    double dxStep = (dx / dist) * (dashWidth + dashSpace);
    double dyStep = (dy / dist) * (dashWidth + dashSpace);

    double x = p1.dx, y = p1.dy;
    for (double i = 0; i < dist; i += dashWidth + dashSpace) {
      canvas.drawLine(Offset(x, y), Offset(x + (dx / dist) * dashWidth, y + (dy / dist) * dashWidth), paint);
      x += dxStep;
      y += dyStep;
    }
  }

  @override
  bool shouldRepaint(covariant ScoutDronePainter oldDelegate) {
    return oldDelegate.scoutPos != scoutPos ||
        oldDelegate.scoutColor != scoutColor ||
        oldDelegate.isLanded != isLanded ||
        oldDelegate.panOffset != panOffset;
  }
}