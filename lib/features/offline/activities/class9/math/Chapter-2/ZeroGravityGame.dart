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
      home: ZeroGravityGame(),
    ),
  );
}

// --- GAME DATA MODELS ---
class LevelData {
  final int id;
  final String polyStr;
  final String targetDescKey;
  final double Function(double) evaluate;
  final List<double> validRoots;

  LevelData({
    required this.id,
    required this.polyStr,
    required this.targetDescKey,
    required this.evaluate,
    required this.validRoots,
  });
}

// --- LOCALIZATION DICTIONARY ---
final Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'ZERO GRAVITY',
    'app_subtitle': 'CLASS 9 • Polynomials - Zeroes of a Polynomial',
    'mission_obj_lbl': 'MISSION OBJECTIVE',
    'mission_simple': 'The drone drops from space based on the polynomial curve. Enter an x-value that makes the final altitude y = 0 to land safely.',
    'btn_start_lab': 'Launch Mission',
    'lab_status_header': 'FLIGHT STATUS',
    'sector_lbl': 'SECTOR {id}/{total}',
    'mission_title': 'Current Polynomial',
    'target_x_lbl': 'TARGET X-COORDINATE',
    'btn_hint': 'Request Hint',
    'input_placeholder': 'Enter x value',
    'btn_launch': 'CALCULATE & LAUNCH',
    'msg_success': 'LANDING SUCCESSFUL!',
    'msg_crash': 'CRASH DETECTED. OFF TARGET.',
    'modal_title': 'AREA SECURED',
    'poly_zero_confirmed': 'Polynomial zero confirmed.',
    'btn_proceed': 'NEXT SECTOR',
    'btn_finish': 'BUILD THEOREM',
    'hud_coord': 'Drone Coordinates',
    'proof_title': 'THEOREM BUILDER',
    'proof_desc': 'Drag the correct components to complete the Remainder Theorem.',
    'proof_line_1': 'If x = a, then p(a) = 0 · q(a) + r(a)',
    'proof_line_2': 'Since it is a zero, r(x) = ',
    'proof_line_3': 'Therefore, p(a) = ',
    'btn_verify_proof': 'VERIFY THEOREM',
    'msg_proof_success': 'THEOREM VERIFIED! SIMULATION COMPLETE.',
    'mission_completed': 'MISSION COMPLETED',
    'restart_mission': 'RESTART MISSION',
    'init_flight': 'INITIALIZING FLIGHT SYSTEMS...',
    'lbl_target': 'TARGET',
    
    // Dynamic error msgs
    'err_proof': 'Logic sequence incorrect. Re-check the theorem.',
    'err_num_input': 'Invalid numerical input.',
    'err_coord_limit': 'Keep coordinates between -5 and 5.',

    'lvl_1_desc': 'Find the zero of linear polynomial.',
    'lvl_2_desc': 'Find any zero of the quadratic polynomial.',
    'lvl_3_desc': 'Find a zero for the cubic polynomial.',

    'hint_msg': 'Hint: What value of x makes the equation equal 0?',
  },
  'hi': {
    'app_title': 'शून्य गुरुत्वाकर्षण',
    'app_subtitle': 'कक्षा 9 • बहुपद - एक बहुपद के शून्यक',
    'mission_obj_lbl': 'मिशन का उद्देश्य',
    'mission_simple': 'ड्रोन बहुपद वक्र के आधार पर अंतरिक्ष से गिरता है। एक ऐसा x-मान दर्ज करें जो अंतिम ऊंचाई y = 0 बना दे ताकि सुरक्षित लैंडिंग हो सके।',
    'btn_start_lab': 'मिशन शुरू करें',
    'lab_status_header': 'उड़ान की स्थिति',
    'sector_lbl': 'सेक्टर {id}/{total}',
    'mission_title': 'वर्तमान बहुपद',
    'target_x_lbl': 'लक्ष्य X-निर्देशांक',
    'btn_hint': 'संकेत',
    'input_placeholder': 'x का मान दर्ज करें',
    'btn_launch': 'गणना करें और लॉन्च करें',
    'msg_success': 'सफल लैंडिंग!',
    'msg_crash': 'क्रैश! लक्ष्य से भटके।',
    'modal_title': 'क्षेत्र सुरक्षित',
    'poly_zero_confirmed': 'बहुपद शून्यक की पुष्टि हुई।',
    'btn_proceed': 'अगला सेक्टर',
    'btn_finish': 'प्रमेय बनाएं',
    'hud_coord': 'ड्रोन निर्देशांक',
    'proof_title': 'प्रमेय निर्माता',
    'proof_desc': 'शेषफल प्रमेय को पूरा करने के लिए सही घटकों को खींचें।',
    'proof_line_1': 'यदि x = a, तो p(a) = 0 · q(a) + r(a)',
    'proof_line_2': 'चूंकि यह एक शून्यक है, r(x) = ',
    'proof_line_3': 'इसलिए, p(a) = ',
    'btn_verify_proof': 'सत्यापित करें',
    'msg_proof_success': 'प्रमेय सत्यापित! सिमुलेशन पूर्ण।',
    'mission_completed': 'मिशन पूरा हुआ',
    'restart_mission': 'मिशन पुनरारंभ करें',
    'init_flight': 'उड़ान प्रणाली शुरू हो रही है...',
    'lbl_target': 'लक्ष्य',
    
    // Dynamic error msgs
    'err_proof': 'तर्क अनुक्रम गलत है। प्रमेय की पुनः जाँच करें।',
    'err_num_input': 'अमान्य संख्यात्मक इनपुट।',
    'err_coord_limit': 'निर्देशांक -5 और 5 के बीच रखें।',

    'lvl_1_desc': 'रैखिक बहुपद का शून्यक ज्ञात कीजिए।',
    'lvl_2_desc': 'द्विघात बहुपद का कोई शून्यक ज्ञात कीजिए।',
    'lvl_3_desc': 'त्रिघात बहुपद का शून्यक ज्ञात कीजिए।',

    'hint_msg': 'संकेत: x का कौन सा मान समीकरण को 0 के बराबर बनाता है?',
  },
};

// Level Definitions
final List<LevelData> levels = [
  LevelData(
    id: 1,
    polyStr: 'p(x) = x - 2',
    targetDescKey: 'lvl_1_desc',
    evaluate: (x) => x - 2,
    validRoots: [2.0],
  ),
  LevelData(
    id: 2,
    polyStr: 'p(x) = x² - 4',
    targetDescKey: 'lvl_2_desc',
    evaluate: (x) => (x * x) - 4,
    validRoots: [2.0, -2.0],
  ),
  LevelData(
    id: 3,
    polyStr: 'p(x) = x³ - x',
    targetDescKey: 'lvl_3_desc',
    evaluate: (x) => (x * x * x) - x,
    validRoots: [0.0, 1.0, -1.0],
  ),
];

// --- MAIN APP WIDGET ---
class ZeroGravityGame extends StatefulWidget {
  const ZeroGravityGame({super.key});

  @override
  State<ZeroGravityGame> createState() => _ZeroGravityGameState();
}

class _ZeroGravityGameState extends State<ZeroGravityGame>
    with TickerProviderStateMixin {
  // Theme colors (Cyber/Space Theme)
  final Color bgTheme = const Color(0xFF020617); // slate-950
  final Color panelColor = const Color(0xFF0f172a); // solid slate-900
  final Color accentTheme = const Color(0xFF06b6d4); // cyan-500
  final Color primaryTheme = const Color(0xFF3b82f6); // blue-500
  final Color successTheme = const Color(0xFF10b981); // emerald-500
  final Color errorTheme = const Color(0xFFf43f5e); // rose-500

  // App State
  String _currentLang = 'en';
  bool _sidebarOpen = true;
  bool _showShutter = true;

  // Game State
  int _stepIndex = 0;
  String _gameState = 'idle'; // idle, flying, landed, crashed, proof_builder, complete
  final TextEditingController _mathInputController = TextEditingController();

  // Coordinates and Animation
  Offset _dronePos = const Offset(0, 6); // Graph coordinates
  late AnimationController _flightController;
  late Animation<Offset> _flightAnim;

  // Proof Builder State
  Map<int, String?> _proofSlots = {0: null, 1: null, 2: null, 3: null};
  final List<String> _draggableItems = ['q(x)', 'r(x)', '0', 'p(a)'];

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
      duration: const Duration(milliseconds: 2000),
    )..addListener(() {
        setState(() {
          _dronePos = _flightAnim.value;
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
    _mathInputController.dispose();
    
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
      _dronePos = const Offset(0, 6); // Starting high up
      _mathInputController.clear();
      _bannerMessage = null;
    });
  }

  void _launchDrone() {
    if (_gameState == 'flying' || _mathInputController.text.isEmpty) return;

    double? xInput = double.tryParse(_mathInputController.text.trim());
    if (xInput == null) {
      _showBanner('error', t('err_num_input'));
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
      return;
    }

    // Clamp input to visible grid [-5, 5]
    if (xInput < -5 || xInput > 5) {
      _showBanner('error', t('err_coord_limit'));
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
      return;
    }

    HapticFeedback.selectionClick();
    _playSound(_fxPlayer, _alertUrl); // Launch sound
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    double yOutput = currentLevel.evaluate(xInput);

    setState(() {
      _gameState = 'flying';
    });

    // Animate from (0, 6) to (xInput, yOutput)
    _flightAnim = Tween<Offset>(
      begin: const Offset(0, 6),
      end: Offset(xInput, yOutput),
    ).animate(
      CurvedAnimation(
        parent: _flightController,
        curve: Curves.easeInOutQuad,
      ),
    );

    _flightController.forward(from: 0.0).then((_) {
      // Check landing condition
      if (yOutput.abs() < 0.01) {
        // Safe Landing
        HapticFeedback.heavyImpact();
        _playSound(_successPlayer, _successUrl);
        setState(() => _gameState = 'landed');
        _showBanner('success', t('msg_success'));
      } else {
        // Crash
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
        // Enter Proof Builder Mode
        _gameState = 'proof_builder';
        _proofSlots = {0: null, 1: null, 2: null, 3: null};
      }
    });
  }

  void _verifyProof() {
    if (_proofSlots[0] == 'q(x)' &&
        _proofSlots[1] == 'r(x)' &&
        _proofSlots[2] == '0' &&
        _proofSlots[3] == '0') {
      HapticFeedback.heavyImpact();
      _playSound(_successPlayer, _successUrl);
      _showBanner('success', t('msg_proof_success'));
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _gameState = 'complete'; // Shows the final mission completed overlay
          });
        }
      });
    } else {
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
      _showBanner('error', t('err_proof'));
    }
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
    double sidebarWidth = screenW * 0.38;

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
          const SizedBox(height: 56),

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
                  border: Border.all(color: Colors.redAccent.withOpacity(0.6), width: 2.0),
                ),
                child: IconButton(
                  icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
                  tooltip: t('btn_reset'),
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
    if (_gameState == 'proof_builder' || _gameState == 'complete') return const SizedBox.shrink();

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
                currentLevel.polyStr,
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
          t('target_x_lbl'),
          style: TextStyle(color: primaryTheme, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('x = ', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _mathInputController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                enabled: _gameState == 'idle' || _gameState == 'crashed',
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 18),
                decoration: InputDecoration(
                  hintText: t('input_placeholder'),
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                  filled: true,
                  fillColor: Colors.black45,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: accentTheme)),
                ),
                onSubmitted: (_) => _launchDrone(),
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
          onPressed: (_gameState == 'idle' || _gameState == 'crashed') ? _launchDrone : null,
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
    if (_gameState == 'proof_builder' || _gameState == 'complete') {
      return _buildProofBuilder();
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

            // Interactive Area & Painting
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: SpaceGridPainter(
                gridColor: accentTheme.withOpacity(0.1),
                axisColor: Colors.white30,
                targetRoots: currentLevel.validRoots,
                targetColor: successTheme,
                targetText: t('lbl_target'),
              ),
            ),

            // Flight Path & Drone
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: DronePainter(
                dronePos: _dronePos,
                droneColor: _gameState == 'crashed' ? errorTheme : accentTheme,
                isLanded: _gameState == 'landed',
              ),
            ),

            // HUD Coordinate Bottom Right
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accentTheme.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      t('hud_coord').toUpperCase(),
                      style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'X: ${_dronePos.dx.toStringAsFixed(1)}  Y: ${_dronePos.dy.toStringAsFixed(1)}',
                      style: TextStyle(color: accentTheme, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
            
            // Comprehensive Mission Overlay (Bottom Left when sidebar closed)
            if (!_sidebarOpen && !_showShutter)
              Positioned(
                bottom: 20,
                left: 20,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: math.min(constraints.maxWidth * 0.5, 350.0),
                    maxHeight: constraints.maxHeight - 40,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: 350.0,
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
                            currentLevel.polyStr,
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

  // --- THEOREM BUILDER ---
  Widget _buildProofBuilder() {
    return Container(
      color: const Color(0xFF020617),
      padding: const EdgeInsets.all(32),
      child: FittedBox(
        fit: BoxFit.scaleDown, // Ensures proof builder scales perfectly on mobile landscape
        child: SizedBox(
          width: 900, // Widened base container for breathing room
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.extension, color: successTheme, size: 48),
              const SizedBox(height: 16),
              Text(
                t('proof_title'),
                // Dynamically larger font when sidebar is closed
                style: TextStyle(color: Colors.white, fontSize: _sidebarOpen ? 24 : 32, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text(t('proof_desc'), style: TextStyle(color: Colors.white70, fontSize: _sidebarOpen ? 14 : 18)),

              const SizedBox(height: 32),

              // Theorem Assembly Area
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: successTheme.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    // Dynamic Font sizes to fill extra space when sidebar is closed
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('p(x) = (x - a) · ', style: TextStyle(color: Colors.white, fontSize: _sidebarOpen ? 24 : 36, fontFamily: 'monospace')),
                        _buildDragTarget(0),
                        Text(' + ', style: TextStyle(color: Colors.white, fontSize: _sidebarOpen ? 24 : 36, fontFamily: 'monospace')),
                        _buildDragTarget(1),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t('proof_line_1'),
                          style: TextStyle(color: Colors.white70, fontSize: _sidebarOpen ? 18 : 28, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(t('proof_line_2'), style: TextStyle(color: Colors.white, fontSize: _sidebarOpen ? 20 : 30, fontFamily: 'monospace')),
                        _buildDragTarget(2),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(t('proof_line_3'), style: TextStyle(color: Colors.white, fontSize: _sidebarOpen ? 24 : 36, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                        _buildDragTarget(3),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Draggable Bank
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _draggableItems.map((item) => _buildDraggable(item)).toList(),
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: successTheme,
                  foregroundColor: Colors.black,
                  // Dynamic, expansive padding depending on state
                  padding: EdgeInsets.symmetric(horizontal: _sidebarOpen ? 24 : 40, vertical: _sidebarOpen ? 16 : 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _verifyProof,
                icon: Icon(Icons.fact_check, size: _sidebarOpen ? 24 : 32),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    t('btn_verify_proof'),
                    style: TextStyle(
                      fontSize: _sidebarOpen ? 18 : 26, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggable(String text) {
    Widget pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: primaryTheme,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
      ),
      // Scale font up when sidebar closed
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: _sidebarOpen ? 18 : 28, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
    );

    return Draggable<String>(
      data: text,
      feedback: Opacity(opacity: 0.8, child: pill),
      childWhenDragging: Opacity(opacity: 0.3, child: pill),
      child: pill,
    );
  }

  Widget _buildDragTarget(int slotId) {
    bool hasData = _proofSlots[slotId] != null;
    // Dynamically scale up target sizes for improved readability
    double sizeHeight = _sidebarOpen ? 45 : 65;
    double sizeWidth = _sidebarOpen ? 80 : 110;
    
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: sizeWidth,
          height: sizeHeight,
          decoration: BoxDecoration(
            color: hasData ? primaryTheme : (candidateData.isNotEmpty ? Colors.white24 : Colors.black54),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasData ? primaryTheme : Colors.white30,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Text(
              _proofSlots[slotId] ?? '',
              style: TextStyle(color: Colors.white, fontSize: _sidebarOpen ? 18 : 28, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
          ),
        );
      },
      onAcceptWithDetails: (details) {
        HapticFeedback.selectionClick();
        _playSound(_clickPlayer, _clickUrl);
        setState(() {
          _proofSlots[slotId] = details.data;
        });
      },
    );
  }

  // --- OVERLAYS ---

  Widget _buildBanner() {
    bool isSuccess = _bannerType == 'success';
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      bottom: _bannerMessage != null ? 40 : -100,
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
                      t('btn_proceed'),
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
                border: Border.all(color: successTheme),
                boxShadow: [BoxShadow(color: successTheme.withOpacity(0.2), blurRadius: 80)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, color: successTheme, size: 64),
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
                      backgroundColor: successTheme,
                      foregroundColor: Colors.black,
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
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accentTheme.withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(color: accentTheme.withOpacity(0.3 + (_pulseController.value * 0.4)), blurRadius: 40),
                          ],
                        ),
                        child: Icon(Icons.rocket, color: accentTheme, size: 50),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Text(
                  t('app_title'),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
                ),
                const SizedBox(height: 12),
                Text(
                  t('init_flight'),
                  style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 3, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentTheme,
                    foregroundColor: Colors.black,
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
  final List<double> targetRoots;
  final Color targetColor;
  final String targetText;

  SpaceGridPainter({
    required this.gridColor,
    required this.axisColor,
    required this.targetRoots,
    required this.targetColor,
    required this.targetText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    // Map [-5, 5] to screen width
    final double scale = math.min(size.width, size.height) / 12;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 2;

    // Draw Grid Lines [-10 to 10] roughly
    for (int i = -10; i <= 10; i++) {
      double offset = i * scale;
      canvas.drawLine(Offset(0, cy + offset), Offset(size.width, cy + offset), gridPaint); // Horiz
      canvas.drawLine(Offset(cx + offset, 0), Offset(cx + offset, size.height), gridPaint); // Vert
    }

    // Axes
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), axisPaint);
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), axisPaint);

    // Target Landing Pads (Roots)
    final padPaint = Paint()..color = targetColor.withOpacity(0.5)..style = PaintingStyle.fill;
    final padBorder = Paint()..color = targetColor..style = PaintingStyle.stroke..strokeWidth = 2;

    for (double root in targetRoots) {
      double px = cx + (root * scale);
      double py = cy; // Y=0 is the axis

      Rect rect = Rect.fromCenter(center: Offset(px, py), width: scale * 0.8, height: scale * 0.3);
      canvas.drawOval(rect, padPaint);
      canvas.drawOval(rect, padBorder);

      TextPainter(
        text: TextSpan(text: targetText, style: TextStyle(color: targetColor, fontSize: 8, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, Offset(px - 15, py + 10));
    }
  }

  @override
  bool shouldRepaint(covariant SpaceGridPainter oldDelegate) {
    return oldDelegate.targetRoots != targetRoots || oldDelegate.targetText != targetText;
  }
}

class DronePainter extends CustomPainter {
  final Offset dronePos;
  final Color droneColor;
  final bool isLanded;

  DronePainter({
    required this.dronePos,
    required this.droneColor,
    required this.isLanded,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double scale = math.min(size.width, size.height) / 12;

    // Map logic coordinate to screen pixel
    double px = cx + (dronePos.dx * scale);
    double py = cy - (dronePos.dy * scale); // Minus because screen Y goes down

    final paint = Paint()..color = droneColor..style = PaintingStyle.fill;
    final glow = Paint()
      ..color = droneColor.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(Offset(px, py), 15, glow);
    canvas.drawCircle(Offset(px, py), 8, paint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(px, py), width: 30, height: 4), const Radius.circular(2)),
      paint,
    );
    canvas.drawCircle(Offset(px, py - 5), 3, Paint()..color = Colors.white);

    if (dronePos.dy > 0.5) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(px, cy), width: 20 + (dronePos.dy * 2), height: 5 + (dronePos.dy * 0.5)),
        Paint()
          ..color = Colors.black.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      _drawDashedLine(
        canvas,
        Offset(px, py + 10),
        Offset(px, cy),
        Paint()..color = droneColor.withOpacity(0.5)..strokeWidth = 1,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 4, dashSpace = 4;
    double dx = p2.dx - p1.dx, dy = p2.dy - p1.dy;
    double dist = math.sqrt(dx * dx + dy * dy);
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
  bool shouldRepaint(covariant DronePainter oldDelegate) {
    return oldDelegate.dronePos != dronePos ||
        oldDelegate.droneColor != droneColor ||
        oldDelegate.isLanded != isLanded;
  }
}