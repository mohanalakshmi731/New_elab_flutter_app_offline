// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpiralArchitectGame(),
    ),
  );
}

// --- LOCALIZATION DICTIONARY ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'THE SPIRAL ARCHITECT',
    'tagline': 'VISUALIZING IRRATIONAL NUMBERS',
    'init_btn': 'INITIALIZE LAB',
    'header_title': 'The Spiral Architect',
    'header_subtitle': 'CLASS 9 • NUMBER SYSTEMS - Locating Irrationals',
    'btn_start_lab': 'Launch Architect',
    'lab_status_header': 'CONSTRUCTION STATUS',
    'mission_title': 'Mission',
    'input_label': "Verify Calculation (Enter 'n' for √n)",
    'btn_check': 'Check & Build',
    'btn_reset': 'Reboot System',
    'btn_restart': 'Restart Activity',
    'hud_live_math': 'Live Math',
    'hud_status': 'Current Base',
    'msg_awesome': 'AWESOME!',
    'log_init': 'System Initialized. Drag from glowing node.',
    'mission_obj_title': 'MISSION OBJECTIVE',
    'mission_obj_desc':
        'Construct the Spiral of Theodorus up to √18.\n\nTwo ways to build:\n1. Drag from the glowing node to draw.\n2. Enter the next number (n) in the box below.',
    'chal_1':
        '1. Drag from the glowing node to draw a perpendicular line (Length 1).',
    'chal_2': '2. Connect the new point to Origin.',
    'log_perp': 'Perpendicular drawn. Connect to Origin.',
    'log_hyp': 'Hypotenuse √{n} constructed.',
    'err_lock': 'Start dragging from the glowing node.',
    'err_len': 'Length must be exactly 1 unit!',
    'err_ang': 'Must be 90° to the base.',
    'modal_title': 'MISSION SUCCESS',
    'btn_proceed': 'PROCEED',
    'btn_finish': 'RESTART SIMULATION',
    'all_complete': 'Spiral of Theodorus completed. Simulation Complete.',
  },
  'hi': {
    'app_title': 'सर्पिल वास्तुकार',
    'tagline': 'अपरिमेय संख्याओं का दृश्यीकरण',
    'init_btn': 'लैब शुरू करें',
    'header_title': 'सर्पिल वास्तुकार',
    'header_subtitle': 'कक्षा 9 • संख्या रेखा पर अपरिमेय संख्याएं',
    'btn_start_lab': 'आर्किटेक्ट शुरू करें',
    'lab_status_header': 'निर्माण स्थिति',
    'mission_title': 'मिशन',
    'input_label': "गणना सत्यापित करें (√n के लिए 'n' दर्ज करें)",
    'btn_check': 'जांचें और बनाएं',
    'btn_reset': 'सिस्टम रीबूट करें',
    'btn_restart': 'पुनः आरंभ करें',
    'hud_live_math': 'लाइव गणित',
    'hud_status': 'वर्तमान आधार',
    'msg_awesome': 'अद्भुत!',
    'log_init': 'सिस्टम तैयार। चमकते नोड से खींचें।',
    'mission_obj_title': 'मिशन का उद्देश्य',
    'mission_obj_desc':
        '√18 तक थियोडोरस का सर्पिल बनाएं।\n\nबनाने के दो तरीके:\n1. चमकते नोड से खींचकर बनाएं।\n2. नीचे बॉक्स में अगली संख्या (n) दर्ज करें।',
    'chal_1': '1. चमकते नोड से एक लंबवत रेखा (लंबाई 1) खींचें।',
    'chal_2': '2. नए बिंदु को मूल बिंदु (Origin) से जोड़ें।',
    'log_perp': 'लंबवत रेखा खींची गई। मूल बिंदु से जोड़ें।',
    'log_hyp': 'कर्ण √{n} निर्मित।',
    'err_lock': 'चमकते नोड से खींचना शुरू करें।',
    'err_len': 'लंबाई 1 इकाई होनी चाहिए!',
    'err_ang': 'आधार से 90° होना चाहिए।',
    'modal_title': 'मिशन सफल',
    'btn_proceed': 'आगे बढ़ें',
    'btn_finish': 'सिमुलेशन पूर्ण',
    'all_complete': 'थियोडोरस का सर्पिल पूरा हुआ। सिमुलेशन पूर्ण।',
  },
};

// --- MAIN APP WIDGET ---
class SpiralArchitectGame extends StatefulWidget {
  const SpiralArchitectGame({super.key});

  @override
  State<SpiralArchitectGame> createState() => _SpiralArchitectGameState();
}

class _SpiralArchitectGameState extends State<SpiralArchitectGame>
    with TickerProviderStateMixin {
  // Theme colors
  final Color bgTheme = const Color(0xFF0f0518);
  final Color panelColor = const Color(0xFF140a28); // Solid deep purple
  final Color accentTheme = const Color(0xFFd946ef); // Fuchsia
  final Color primaryTheme = const Color(0xFF8b5cf6); // Violet
  final Color secondaryTheme = const Color(0xFF06b6d4); // Cyan
  final Color successTheme = const Color(0xFF4ade80);
  final Color errorTheme = const Color(0xFFf43f5e);

  // State
  String _currentLang = 'en';
  bool _sidebarOpen = true;
  bool _showShutter = true;

  // Game/Spiral State
  int _step = 1;
  final int _maxSteps = 18;
  String _gameState = 'idle'; // idle, hyp_ready, won, complete
  List<Offset> _spiralPoints = [const Offset(0, 0), const Offset(1, 0)];

  // Canvas View State
  double _scale = 80.0;
  Offset _panOffset = Offset.zero;
  bool _isPanning = false;
  bool _isDrawing = false;
  Offset? _tempLineEnd;

  // Controllers
  late AnimationController _glowController;
  final TextEditingController _mathInputController = TextEditingController();

  // Audio Player Instances (Dedicated players for overlapping sounds)
  final AudioPlayer _playerClick = AudioPlayer();
  final AudioPlayer _playerPop = AudioPlayer();
  final AudioPlayer _playerError = AudioPlayer();
  final AudioPlayer _playerComplete = AudioPlayer();
  final AudioPlayer _playerShutter = AudioPlayer();

  // Ultra-short, professional UI sounds
  final String _sfxPop = 'audio/class9/pop.mp3'; // Crisp UI snap for building
  // Short error beep (Google sound library, bundled locally)
  final String _sfxError = 'audio/class9/beep_short.ogg'; 
  final String _sfxComplete = 'audio/class9/success.mp3'; // Short digital success chime
  final String _sfxClick = 'audio/class9/click.mp3'; // Soft clean click
  final String _sfxInit = 'audio/class9/click.mp3'; // Small mechanical opening snap
  final String _sfxClose = 'audio/class9/snap_close.mp3'; // Small mechanical closing snap

  // Overlay state
  String? _bannerMessage;
  String? _bannerType;

  String t(String key) => i18n[_currentLang]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    // Enforce Landscape Mode and Immersive UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    // Reset Orientation and UI Mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    // Dispose all audio players
    _playerClick.dispose();
    _playerPop.dispose();
    _playerError.dispose();
    _playerComplete.dispose();
    _playerShutter.dispose();

    _glowController.dispose();
    _mathInputController.dispose();
    super.dispose();
  }

  // --- AUDIO HELPER ---
  void _playSound(AudioPlayer player, String url) async {
    try {
      if (player.state == PlayerState.playing) {
        await player.stop();
      }
      // Play from the bundled asset
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  // --- GAME LOGIC ---

  void _resetLab() {
    setState(() {
      _step = 1;
      _gameState = 'idle';
      _spiralPoints = [const Offset(0, 0), const Offset(1, 0)];
      _scale = 80.0;
      _panOffset = Offset.zero;
      _mathInputController.clear();
      _bannerMessage = null;
      _sidebarOpen = true;
    });
  }

  Offset _getExpectedTarget() {
    if (_gameState == 'hyp_ready') return Offset.zero; // Target is origin

    // Calculate perpendicular target
    Offset prev = _spiralPoints.last;
    double dx = prev.dx;
    double dy = prev.dy;
    double len = math.sqrt(dx * dx + dy * dy);

    // Perpendicular vector (-dy, dx) normalized
    double pdx = -dy / len;
    double pdy = dx / len;

    return Offset(prev.dx + pdx, prev.dy + pdy);
  }

  void _validateManualInput() {
    int? val = int.tryParse(_mathInputController.text.trim());
    if (val != null && val == _step + 1) {
      HapticFeedback.heavyImpact();
      _playSound(_playerPop, _sfxPop);
      _showBanner('success', 'Correct! Building √$val');

      setState(() {
        if (_gameState == 'idle') {
          _spiralPoints.add(_getExpectedTarget());
        }
        _gameState = 'idle'; // Reset state
        _step++;
        _mathInputController.clear();

        if (_step >= _maxSteps) {
          _gameState = 'won'; // freeze interactions
          _playSound(_playerComplete, _sfxComplete);
          _showBanner('success', 'Simulation Complete!');
          // Delay to show the final built spiral
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (mounted) setState(() => _gameState = 'complete');
          });
        }
      });
      _autoCenter();
    } else {
      HapticFeedback.vibrate();
      _playSound(_playerError, _sfxError);
      _showBanner('error', 'Incorrect Calculation');
    }
  }

  void _confirmStep() {
    HapticFeedback.mediumImpact();
    _playSound(_playerPop, _sfxPop);
    
    setState(() {
      if (_gameState == 'idle') {
        _spiralPoints.add(_getExpectedTarget());
        _gameState = 'hyp_ready';
      } else if (_gameState == 'hyp_ready') {
        _gameState = 'idle';
        _step++;
        
        if (_step >= _maxSteps) {
          _gameState = 'won'; // freeze interactions
          _playSound(_playerComplete, _sfxComplete);
          _showBanner('success', 'Simulation Complete!');
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (mounted) setState(() => _gameState = 'complete');
          });
        }
      }
    });
    _autoCenter();
  }

  void _autoCenter() {
    // Soft pan and dynamic zoom to keep current node visible and prevent getting stuck
    if (_spiralPoints.isEmpty) return;
    Offset current = _spiralPoints.last;
    setState(() {
      // Dynamic scaling: gradually zoom out as the spiral grows to fit on screen
      _scale = math.max(25.0, 85.0 - (_step * 3.0));
      
      // Pan calculation to center the active node
      _panOffset = Offset(
        -current.dx * _scale * 0.4,
        current.dy * _scale * 0.4,
      );
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

  // --- INTERACTION LOGIC (CANVAS COORDS) ---

  Offset _screenToCanvas(Offset screenPos, Size size) {
    double cx = size.width / 2 + _panOffset.dx;
    double cy = size.height / 2 + _panOffset.dy;
    double x = (screenPos.dx - cx) / _scale;
    double y = -(screenPos.dy - cy) / _scale; // Y is inverted in math
    return Offset(x, y);
  }

  void _onPanStart(DragStartDetails details, BoxConstraints constraints) {
    if (_gameState == 'complete' || _gameState == 'won' || _showShutter) return;

    Size size = Size(constraints.maxWidth, constraints.maxHeight);
    Offset canvasPos = _screenToCanvas(details.localPosition, size);
    Offset activeNode = _gameState == 'hyp_ready'
        ? _spiralPoints.last
        : _spiralPoints.last;

    // Check if close to active node
    if ((canvasPos - activeNode).distance < 0.8) {
      setState(() {
        _isDrawing = true;
        _isPanning = false;
        _tempLineEnd = canvasPos;
      });
    } else {
      setState(() {
        _isPanning = true;
        _isDrawing = false;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_isPanning) {
      setState(() {
        _panOffset += details.delta;
      });
    } else if (_isDrawing) {
      Size size = Size(constraints.maxWidth, constraints.maxHeight);
      setState(() {
        _tempLineEnd = _screenToCanvas(details.localPosition, size);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isDrawing && _tempLineEnd != null) {
      Offset target = _getExpectedTarget();
      double dist = (_tempLineEnd! - target).distance;

      // Generous tolerance so dragging works easily even at small scales
      if (dist < 0.8) {
        _confirmStep();
      } else {
        HapticFeedback.vibrate();
        _playSound(_playerError, _sfxError);
        // Corrected banner logic so it shows correctly regardless of current draw state
        if (_gameState == 'idle') {
          _showBanner('error', t('err_ang'));
        } else {
          _showBanner('error', t('err_len'));
        }
      }
    }
    setState(() {
      _isDrawing = false;
      _isPanning = false;
      _tempLineEnd = null;
    });
  }

  // --- UI BUILDING ---
  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    // Set sidebar width to exactly 38%
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
            // Dynamic Layout using Row ensures canvas adjusts alongside the sidebar
            Row(
              children: [
                // Expandable Sidebar Container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _sidebarOpen ? sidebarWidth : 0,
                  decoration: BoxDecoration(
                    color: panelColor,
                    border: Border(
                        right: BorderSide(color: accentTheme.withOpacity(0.2))),
                  ),
                  child: ClipRect(
                    child: OverflowBox(
                      minWidth: 0,
                      maxWidth: sidebarWidth,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: sidebarWidth,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(
                              left: 0, top: 16.0, right: 16.0, bottom: 24.0),
                          child: _buildSidebarContent(),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Center Activity (Responsive Workspace) - Takes remaining width dynamically
                Expanded(
                  child: _buildWorkspace(),
                ),
              ],
            ),

            // Top Left Menu Button (Z-Index Front so it always floats)
            Positioned(
              top: 16,
              left: 16,
              child: SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu),
                  color: Colors.white,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _playSound(_playerClick, _sfxClick);
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
            if (_showShutter) _buildLoadingShutter(),
            if (_gameState == 'complete' && !_showShutter) _buildLevelCompleteModal(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Spacer to push the title content completely below the floating menu icon
        const SizedBox(height: 56),

        // Wrap the rest of the contents in padding since the parent ScrollView has left: 0
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title on the next line below the menu icon
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
              // Subtitle on the line after the title
              Text(
                t('header_subtitle'),
                style: TextStyle(
                  color: secondaryTheme,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  fontFamily: 'monospace',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),

              // Settings Row (Language Toggle & Reset Button)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                        children: [_langBtn('en', 'EN'), _langBtn('hi', 'HI')]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.6),
                        width: 2.0,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.power_settings_new,
                          color: Colors.redAccent),
                      tooltip: t('btn_reset'),
                      onPressed: () {
                        HapticFeedback.vibrate();
                        _playSound(_playerShutter, _sfxClose); // Close Shutter Sound
                        setState(() {
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
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
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

  Widget _langBtn(String code, String label) {
    bool active = _currentLang == code;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (!active) _playSound(_playerClick, _sfxClick);
        setState(() => _currentLang = code);
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
    if (_showShutter) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Objective
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentTheme.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentTheme.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('mission_obj_title'),
                style: TextStyle(
                  color: accentTheme,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t('mission_obj_desc'),
                style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Status
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('lab_status_header'),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Base: √$_step',
                    style: TextStyle(
                      color: accentTheme,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'Step ${_step - 1} / $_maxSteps',
                    style: TextStyle(
                      color: successTheme,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Mission & Inputs
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.compass_calibration,
                    color: secondaryTheme,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t('mission_title').toUpperCase(),
                    style: TextStyle(
                      color: secondaryTheme,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _gameState == 'hyp_ready' ? t('chal_2') : t('chal_1'),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),

              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 12),

              Text(
                t('input_label').toUpperCase(),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '√',
                    style: TextStyle(
                      color: accentTheme,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _mathInputController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: accentTheme),
                        ),
                      ),
                      onSubmitted: (_) => _validateManualInput(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentTheme.withOpacity(0.2),
                    foregroundColor: accentTheme,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _validateManualInput,
                  child: Text(
                    t('btn_check'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Background grid aesthetic
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF0f172a), Colors.black],
                  center: Alignment.center,
                  radius: 1.0,
                ),
              ),
            ),

            // Interaction layer bounded by ClipRect to prevent bleeding
            ClipRect(
              child: GestureDetector(
                onPanStart: (d) => _onPanStart(d, constraints),
                onPanUpdate: (d) => _onPanUpdate(d, constraints),
                onPanEnd: _onPanEnd,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: SpiralPainter(
                    points: _spiralPoints,
                    step: _step,
                    gameState: _gameState,
                    scale: _scale,
                    panOffset: _panOffset,
                    tempLineEnd: _tempLineEnd,
                    glowValue: _glowController.value,
                    themeColor: accentTheme,
                    hypColor: secondaryTheme,
                  ),
                ),
              ),
            ),

            // HUD Overlay (Top Center for Live Math)
            if (!_showShutter)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: accentTheme.withOpacity(0.5), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          t('hud_live_math').toUpperCase(),
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _step == 1
                              ? 'Base Line'
                              : '(√${_step - 1})² + 1² = (√$_step)²',
                          style: TextStyle(
                            color: accentTheme,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Mission Objective HUD (Bottom Left - Shown only when sidebar is closed)
            if (!_showShutter && !_sidebarOpen)
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  width: math.min(constraints.maxWidth * 0.6, 400.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(color: secondaryTheme, width: 4),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('mission_title').toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _gameState == 'hyp_ready' ? t('chal_2') : t('chal_1'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Zoom controls
            if (!_showShutter)
              Positioned(
                bottom: 16,
                right: 16,
                child: Column(
                  children: [
                    _ctrlBtn(Icons.center_focus_strong, () {
                      _playSound(_playerClick, _sfxClick);
                      _autoCenter();
                    }),
                    const SizedBox(height: 8),
                    _ctrlBtn(Icons.add, () {
                      _playSound(_playerClick, _sfxClick);
                      setState(() => _scale = math.min(150.0, _scale + 10));
                    }),
                    const SizedBox(height: 8),
                    _ctrlBtn(Icons.remove, () {
                      _playSound(_playerClick, _sfxClick);
                      setState(() => _scale = math.max(15.0, _scale - 10));
                    }),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _ctrlBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildBanner() {
    bool isSuccess = _bannerType == 'success';
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      // Drops from top
      top: _bannerMessage != null ? 80 : -100, 
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isSuccess
                ? successTheme.withOpacity(0.9)
                : errorTheme.withOpacity(0.9),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: isSuccess ? Colors.greenAccent : Colors.redAccent,
            ),
            boxShadow: [
              BoxShadow(
                color: isSuccess
                    ? successTheme.withOpacity(0.5)
                    : errorTheme.withOpacity(0.5),
                blurRadius: 30,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.warning,
                color: Colors.white,
                size: 20, 
              ),
              const SizedBox(width: 10),
              Text(
                _bannerMessage ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14, 
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

  Widget _buildLevelCompleteModal() {
    String title = t('modal_title');
    String msg = t('all_complete');

    return Container(
      color: Colors.black87,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: bgTheme,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentTheme),
              boxShadow: [
                BoxShadow(color: accentTheme.withOpacity(0.2), blurRadius: 80),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: accentTheme, size: 60),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentTheme,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _playSound(_playerShutter, _sfxClose); // Shutter close sound
                    setState(() {
                      _showShutter = true;
                    });
                  },
                  child: Text(
                    t('btn_finish'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _glowController,
              builder: (_, child) {
                return Transform.scale(
                  scale: 0.9 + (_glowController.value * 0.1),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentTheme.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: accentTheme.withOpacity(
                            0.3 + (_glowController.value * 0.4),
                          ),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: Icon(Icons.architecture, color: accentTheme, size: 50),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            Text(
              t('app_title').toUpperCase(),
              style: TextStyle(
                color: accentTheme,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
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
                _playSound(_playerShutter, _sfxInit); // Powerful Shutter Open Sound
                setState(() {
                  _showShutter = false;
                });
                _resetLab(); // Trigger game start
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
    );
  }
}

// --- CUSTOM PAINTER FOR SPIRAL ---
class SpiralPainter extends CustomPainter {
  final List<Offset> points;
  final int step;
  final String gameState;
  final double scale;
  final Offset panOffset;
  final Offset? tempLineEnd;
  final double glowValue;
  final Color themeColor;
  final Color hypColor;

  SpiralPainter({
    required this.points,
    required this.step,
    required this.gameState,
    required this.scale,
    required this.panOffset,
    this.tempLineEnd,
    required this.glowValue,
    required this.themeColor,
    required this.hypColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double cx = size.width / 2 + panOffset.dx;
    double cy = size.height / 2 + panOffset.dy;

    Offset toScreen(Offset c) => Offset(cx + c.dx * scale, cy - c.dy * scale);

    // 1. Grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    double stepSize = scale;
    for (double x = cx % stepSize; x < size.width; x += stepSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = cy % stepSize; y < size.height; y += stepSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Axes
    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), axisPaint);
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), axisPaint);

    // 2. Draw Triangles
    final fillPaint = Paint()
      ..color = hypColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final edgePaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final perpPaint = Paint()
      ..color = themeColor
      ..strokeWidth = 2;
    final hypPaint = Paint()
      ..color = hypColor
      ..strokeWidth = 2;

    Offset origin = toScreen(const Offset(0, 0));

    for (int i = 1; i < points.length; i++) {
      Offset p1 = toScreen(points[i - 1]);
      Offset p2 = toScreen(points[i]);

      // Fill triangle if it forms a full triangle (i > 1)
      if (i > 1) {
        Path path = Path()
          ..moveTo(origin.dx, origin.dy)
          ..lineTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..close();
        canvas.drawPath(path, fillPaint);
      }

      // Base/Hypotenuse line
      if (i == 1) {
        canvas.drawLine(origin, p2, edgePaint); // Initial base
      } else {
        canvas.drawLine(origin, p2, hypPaint); // Hypotenuse from new point
        canvas.drawLine(p1, p2, perpPaint); // Perpendicular line
      }

      // Node dots
      canvas.drawCircle(p2, 4, Paint()..color = Colors.white);
    }
    canvas.drawCircle(origin, 4, Paint()..color = Colors.white);

    // 3. Draw Active interactions
    if (gameState != 'complete' && gameState != 'won' && points.isNotEmpty) {
      Offset activeCanvas = gameState == 'hyp_ready'
          ? points.last
          : points.last;
      Offset activeScreen = toScreen(activeCanvas);

      // Glow on active node
      double r = 8 + (glowValue * 6);
      canvas.drawCircle(
        activeScreen,
        r,
        Paint()..color = themeColor.withOpacity(0.5),
      );
      canvas.drawCircle(activeScreen, 6, Paint()..color = themeColor);

      // Temp Line
      if (tempLineEnd != null) {
        Offset endScreen = toScreen(tempLineEnd!);
        canvas.drawLine(
          activeScreen,
          endScreen,
          Paint()
            ..color = Colors.yellow
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
      }
    }

    // Draw text labels
    _drawText(canvas, 'O', origin + const Offset(-15, 10), Colors.white54);
    if (points.length > 1) {
      _drawText(
        canvas,
        '1',
        toScreen(points[1]) + const Offset(5, 10),
        Colors.white54,
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset pos, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant SpiralPainter oldDelegate) => true; // Keep simple for animation
}