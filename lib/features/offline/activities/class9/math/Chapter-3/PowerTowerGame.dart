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
      home: PowerTowerGame(),
    ),
  );
}

// --- GAME DATA MODELS ---
class GameStep {
  final String titleKey;
  final String descKey;

  GameStep({required this.titleKey, required this.descKey});
}

// --- LOCALIZATION DICTIONARY ---
final Map<String, Map<String, dynamic>> i18n = {
  'en': {
    'app_title': 'THE POWER TOWER',
    'tagline': 'LAWS OF EXPONENTS LAB',
    'init_btn': 'INITIALIZE LAB',
    'header_title': 'The Power Tower',
    'header_subtitle': 'CLASS 9 • NUMBER SYSTEMS - Operations & Exponents',
    'btn_start_lab': 'Launch Lab',
    'lab_status_header': 'MISSION PROGRESS',
    'mission_title': 'Objective',
    'btn_reset': 'Reboot System',
    'msg_success': 'Correct! Structure Stable.',
    'msg_error': 'Incorrect Modification.',
    'modal_title': 'MISSION SUCCESS',
    'btn_proceed': 'PROCEED',
    'btn_finish': 'SIMULATION COMPLETE',
    'lbl_equation': 'Live Equation',
    'lvl_1_title': 'Building Powers',
    'lvl_1_desc':
        'Start with 2¹ (1 block). Tap anywhere to stack blocks until you reach 2⁵ (5 blocks).',
    'lvl_2_title': 'Quotient Law',
    'lvl_2_desc':
        'Start with 2⁵. Tap anywhere to remove 2 blocks to visualize division (2⁵ ÷ 2²).',
    'lvl_3_title': 'Power of a Power',
    'lvl_3_desc':
        'Build a stack of 2 (2²). Tap anywhere to spawn 2 more copies to visualize (2²)³.',
    'lvl_complete': 'Structure verified. Ready for next sequence.',
    'all_complete': 'All exponent laws visualized. Simulation Complete.',
  },
  'hi': {
    'app_title': 'शक्ति मीनार',
    'tagline': 'घातांक के नियम लैब',
    'init_btn': 'लैब शुरू करें',
    'header_title': 'शक्ति मीनार',
    'header_subtitle': 'कक्षा 9 • संख्या पद्धति – संक्रियाएँ एवं घातांक',
    'btn_start_lab': 'लैब लॉन्च करें',
    'lab_status_header': 'मिशन प्रगति',
    'mission_title': 'उद्देश्य',
    'btn_reset': 'सिस्टम रीबूट करें',
    'msg_success': 'सही! संरचना स्थिर।',
    'msg_error': 'गलत संशोधन।',
    'modal_title': 'मिशन सफल',
    'btn_proceed': 'आगे बढ़ें',
    'btn_finish': 'सिमुलेशन पूर्ण',
    'lbl_equation': 'लाइव समीकरण',
    'lvl_1_title': 'घात का निर्माण',
    'lvl_1_desc':
        '2¹ (1 ब्लॉक) से शुरू करें। 2⁵ (5 ब्लॉक) तक पहुँचने के लिए कहीं भी टैप करें।',
    'lvl_2_title': 'भाग नियम',
    'lvl_2_desc':
        '2⁵ से शुरू करें। भाग (2⁵ ÷ 2²) की कल्पना करने के लिए 2 ब्लॉक हटाने के लिए टैप करें।',
    'lvl_3_title': 'शक्ति की शक्ति',
    'lvl_3_desc':
        '2 का ढेर (2²) बनाएं। (2²)³ की कल्पना करने के लिए 2 और प्रतियां बनाने के लिए टैप करें।',
    'lvl_complete': 'संरचना सत्यापित। अगले अनुक्रम के लिए तैयार।',
    'all_complete': 'सभी घातांक नियम देखे गए। सिमुलेशन पूर्ण।',
  },
};

final List<GameStep> gameSteps = [
  GameStep(titleKey: 'lvl_1_title', descKey: 'lvl_1_desc'),
  GameStep(titleKey: 'lvl_2_title', descKey: 'lvl_2_desc'),
  GameStep(titleKey: 'lvl_3_title', descKey: 'lvl_3_desc'),
];

// --- UTILS ---
String toSuperscript(int n) {
  if (n < 0) return '⁻${toSuperscript(n.abs())}';
  const superscripts = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'];
  return n
      .toString()
      .split('')
      .map((char) => superscripts[int.parse(char)])
      .join('');
}

// --- MAIN APP WIDGET ---
class PowerTowerGame extends StatefulWidget {
  const PowerTowerGame({super.key});

  @override
  State<PowerTowerGame> createState() => _PowerTowerGameState();
}

class _PowerTowerGameState extends State<PowerTowerGame>
    with TickerProviderStateMixin {
  // Theme colors
  final Color bgTheme = const Color(0xFF0f172a); // slate-900
  final Color panelColor = const Color(0xFF1e293b); // Solid slate-800
  final Color accentTheme = const Color(0xFFf59e0b); // amber-500
  final Color primaryTheme = const Color(0xFF3b82f6); // blue-500
  final Color secondaryTheme = const Color(0xFF8b5cf6); // violet-500
  final Color successTheme = const Color(0xFF22c55e); // green-500
  final Color errorTheme = const Color(0xFFef4444); // red-500

  // State
  String _currentLang = 'en';
  bool _sidebarOpen = true;
  bool _showShutter = true;

  // Game State
  int _stepIndex = 0;
  String _gameState = 'idle'; // idle, playing, won, complete
  List<int> _stacks = []; // Tracks height of each tower stack

  // Overlay state
  String? _bannerMessage;
  String? _bannerType; // 'success' or 'error'

  // Animations
  late AnimationController _pulseController;

  // Audio Player Instances (Dedicated players for overlapping sounds)
  final AudioPlayer _playerClick = AudioPlayer();
  final AudioPlayer _playerPop = AudioPlayer();
  final AudioPlayer _playerError = AudioPlayer();
  final AudioPlayer _playerComplete = AudioPlayer();
  final AudioPlayer _playerShutter = AudioPlayer();

  // Ultra-short, professional UI sounds from reliable sources
  final String _sfxPop =
      'audio/class9/pop.mp3'; // Crisp UI snap/pop for building
  final String _sfxError =
      'audio/class9/beep_short.ogg'; // Clean error beep
  final String _sfxComplete =
      'audio/class9/success.mp3'; // Short digital success chime
  final String _sfxClick =
      'audio/class9/click.mp3'; // Soft clean click
  final String _sfxInit =
      'audio/class9/click.mp3'; // Small mechanical opening snap
  final String _sfxClose =
      'audio/class9/snap_close.mp3'; // Small mechanical closing snap

  String t(String key) => i18n[_currentLang]?[key] ?? key;
  GameStep? get currentStepOrNull {
    if (gameSteps.isEmpty) return null;
    if (_stepIndex < 0 || _stepIndex >= gameSteps.length) return null;
    return gameSteps[_stepIndex];
  }

  int get totalBlocks => _stacks.fold(0, (sum, val) => sum + val);

  @override
  void initState() {
    super.initState();
    // Enforce Landscape Mode and Immersive UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _initAudio(); // Load audio sources to eliminate latency

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _initAudio() async {
    // Pre-load sources, but never let a failed load crash the game.
    await _safePreload(_playerClick, _sfxClick);
    await _safePreload(_playerPop, _sfxPop);
    await _safePreload(_playerError, _sfxError);
    await _safePreload(_playerComplete, _sfxComplete);
    await _safePreload(_playerShutter, _sfxInit);
  }

  Future<void> _safePreload(AudioPlayer player, String url) async {
    try {
      await player.setSource(AssetSource(url));
      await player.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('Audio preload failed for $url: $e');
    }
  }

  @override
  void dispose() {
    // Reset Orientation and UI
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

    _pulseController.dispose();
    super.dispose();
  }

  // --- AUDIO HELPER ---
  void _playSound(AudioPlayer player, String url) async {
    try {
      // `stop` is safe to call defensively and avoids state lookups.
      await player.stop();
      // Play from the bundled asset
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  // --- GAME LOGIC ---
  void _loadLevel(int index) {
    if (gameSteps.isEmpty) return;

    final safeIndex = index.clamp(0, gameSteps.length - 1);

    setState(() {
      _stepIndex = safeIndex;
      _gameState = 'playing';
      _sidebarOpen = true;

      if (safeIndex == 0) {
        _stacks = [1]; // Start with 2^1
      } else if (safeIndex == 1) {
        _stacks = [5]; // Start with 2^5
      } else if (safeIndex == 2) {
        _stacks = [2]; // Start with 2^2
      }
    });
  }

  void _handleWorkspaceTap() {
    if (_gameState != 'playing' || _showShutter || _stacks.isEmpty) return;

    bool changed = false;

    setState(() {
      // Step logic
      if (_stepIndex == 0) {
        if (_stacks[0] < 5) {
          _stacks[0]++;
          changed = true;
        }
      } else if (_stepIndex == 1) {
        if (_stacks[0] > 3) {
          _stacks[0]--;
          changed = true;
        }
      } else if (_stepIndex == 2) {
        if (_stacks.length < 3) {
          _stacks.add(2);
          changed = true;
        }
      }

      // Feedback logic
      if (changed) {
        HapticFeedback.selectionClick();
        _playSound(_playerPop, _sfxPop);
      } else {
        HapticFeedback.vibrate();
        _playSound(_playerError, _sfxError);
      }

      _checkWinCondition();
    });
  }

  void _checkWinCondition() {
    if (_stacks.isEmpty) return;

    bool win = false;
    if (_stepIndex == 0 && _stacks[0] == 5) win = true;
    if (_stepIndex == 1 && _stacks[0] == 3) win = true;
    if (_stepIndex == 2 && _stacks.length == 3) win = true;

    if (win) {
      // Set to 'won' to prevent further taps but keep the canvas visible
      _gameState = 'won';
      _playSound(_playerComplete, _sfxComplete);
      _showBanner('success', t('msg_success'));
      HapticFeedback.heavyImpact();

      // Give the user 2 seconds to see the final equation and block structure
      // before showing the level complete modal.
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          setState(() {
            _gameState = 'complete';
          });
        }
      });
    }
  }

  void _showBanner(String type, String message) {
    setState(() {
      _bannerType = type;
      _bannerMessage = message;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _bannerMessage == message) {
        setState(() {
          _bannerMessage = null;
        });
      }
    });
  }

  String _getLiveEquation() {
    if (_stacks.isEmpty) return '';
    if (_stepIndex == 0) {
      return '2${toSuperscript(_stacks[0])}';
    } else if (_stepIndex == 1) {
      int removed = 5 - _stacks[0];
      if (removed == 0) return '2${toSuperscript(5)}';
      return '2${toSuperscript(5)} ÷ 2${toSuperscript(removed)} = 2${toSuperscript(_stacks[0])}';
    } else if (_stepIndex == 2) {
      if (_stacks.length == 1) return '2${toSuperscript(2)}';
      return '(2${toSuperscript(2)})${toSuperscript(_stacks.length)} = 2${toSuperscript(totalBlocks)}';
    }
    return '';
  }

  Color _getBlockColor() {
    if (_stepIndex == 0) return primaryTheme;
    if (_stepIndex == 1) return successTheme;
    return secondaryTheme;
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
                      right: BorderSide(color: accentTheme.withOpacity(0.2)),
                    ),
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
                            left: 0,
                            top: 16.0,
                            right: 16.0,
                            bottom: 24.0,
                          ),
                          child: _buildSidebarContent(),
                        ),
                      ),
                    ),
                  ),
                ),

                // Center Activity (Responsive Workspace) - Takes remaining width dynamically
                Expanded(child: _buildWorkspace()),
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
            if (_gameState == 'complete' && !_showShutter)
              _buildLevelCompleteModal(),
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

              // Settings Row (Language Toggle & Reset Button)
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
                    child: Row(
                      children: [_langBtn('en', 'EN'), _langBtn('hi', 'HI')],
                    ),
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
                      icon: const Icon(
                        Icons.power_settings_new,
                        color: Colors.redAccent,
                      ),
                      tooltip: t('btn_reset'),
                      onPressed: () {
                        HapticFeedback.vibrate();
                        _playSound(
                          _playerShutter,
                          _sfxClose,
                        ); // Close Shutter Sound
                        // Bring up shutter screen on reboot
                        setState(() {
                          _showShutter = true;
                          _gameState = 'idle';
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
        ),
      ],
    );
  }

  Widget _langBtn(String code, String label) {
    bool active = _currentLang == code;
    return GestureDetector(
      onTap: () {
        if (!active) {
          HapticFeedback.selectionClick();
          _playSound(_playerClick, _sfxClick);
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
    if (_gameState == 'idle') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Box
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
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '${_stepIndex + 1}/${gameSteps.length}',
                    style: TextStyle(
                      color: accentTheme,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor:
                      _stepIndex /
                      (gameSteps.length - 1 == 0 ? 1 : gameSteps.length - 1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: accentTheme,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Steps List
        // Map instead of ListView.builder inside a ScrollView to prevent boundary issues
        ...gameSteps.asMap().entries.map((entry) {
          int index = entry.key;
          bool isActive = index == _stepIndex;
          bool isCompleted = index < _stepIndex;
          GameStep step = entry.value;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color:
                  isActive
                      ? accentTheme.withOpacity(0.1)
                      : (isCompleted
                          ? successTheme.withOpacity(0.05)
                          : Colors.white.withOpacity(0.02)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isActive
                        ? accentTheme.withOpacity(0.5)
                        : (isCompleted
                            ? successTheme.withOpacity(0.3)
                            : Colors.white10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color:
                              isActive
                                  ? accentTheme
                                  : (isCompleted ? successTheme : panelColor),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child:
                              isCompleted
                                  ? const Icon(
                                    Icons.check,
                                    color: Colors.black,
                                    size: 14,
                                  )
                                  : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color:
                                          isActive
                                              ? Colors.black
                                              : Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        t(step.titleKey).toUpperCase(),
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: 12,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: accentTheme.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        t(step.descKey),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildWorkspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF1e293b), Colors.black],
                  center: Alignment.center,
                  radius: 1.0,
                ),
              ),
            ),

            // Floor Grid
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 120,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white10, Colors.transparent],
                  ),
                ),
                child: CustomPaint(
                  painter: FloorGridPainter(
                    color: accentTheme.withOpacity(0.1),
                  ),
                ),
              ),
            ),

            // Tap Area
            GestureDetector(
              onTap: _handleWorkspaceTap,
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
                child: Stack(children: _buildBlocks(constraints)),
              ),
            ),

            // Live Equation HUD (Top Center)
            if (!_showShutter && _gameState != 'idle')
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
                      border: Border.all(
                        color: accentTheme.withOpacity(0.5),
                        width: 2,
                      ),
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
                          t('lbl_equation').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _getLiveEquation(),
                            key: ValueKey(_getLiveEquation()),
                            style: TextStyle(
                              color: accentTheme,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Mission Objective HUD (Bottom Left - Shown only when sidebar is closed)
            if (!_showShutter && _gameState != 'idle' && !_sidebarOpen)
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
                      if (currentStepOrNull != null)
                        Text(
                          t(currentStepOrNull!.descKey),
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

            // Instruction prompt in center (fades out when interacting)
            if (_gameState == 'playing' &&
                _stacks.length == 1 &&
                _stacks.first == 1 &&
                _stepIndex == 0)
              Positioned(
                bottom: 140,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: 0.3 + (_pulseController.value * 0.7),
                          child: Text(
                            "TAP ANYWHERE TO INTERACT",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildBlocks(BoxConstraints constraints) {
    List<Widget> widgets = [];
    if (_showShutter || _gameState == 'idle') return widgets;

    // Dynamic sizing based on screen bounds to prevent overflow
    // Max height needed is 5 blocks, max width needed is 3 blocks
    double maxAvailableHeight =
        constraints.maxHeight - 120; // 120px for HUD and floor
    double maxAvailableWidth =
        constraints.maxWidth - 60; // 60px for side padding

    double maxBlockH = maxAvailableHeight / 5;
    double maxBlockW = (maxAvailableWidth - (2 * 20)) / 3; // 2 spacing gaps

    // Ensure blocks are square, scale down if needed, and cap at 90
    double blockSize = math.min(90.0, math.min(maxBlockH, maxBlockW));
    blockSize = math.max(30.0, blockSize); // Set a reasonable minimum limit

    double spacingX =
        blockSize * 0.33; // Dynamic spacing relative to block size

    double totalWidth =
        (_stacks.length * blockSize) + ((_stacks.length - 1) * spacingX);
    double startX = (constraints.maxWidth - totalWidth) / 2;
    Color blockColor = _getBlockColor();

    for (int s = 0; s < _stacks.length; s++) {
      for (int y = 0; y < _stacks[s]; y++) {
        widgets.add(
          AnimatedPositioned(
            key: ValueKey('block_${s}_$y'),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            bottom: 40 + (y * blockSize),
            left: startX + (s * (blockSize + spacingX)),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: blockSize,
                height: blockSize,
                decoration: BoxDecoration(
                  color: blockColor.withOpacity(0.2),
                  border: Border.all(color: blockColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: blockColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: blockSize * 0.4, // Scale font dynamically
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return widgets;
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
          // Made the padding slightly more compact
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color:
                isSuccess
                    ? successTheme.withOpacity(0.9)
                    : errorTheme.withOpacity(0.9),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: isSuccess ? Colors.greenAccent : Colors.redAccent,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isSuccess
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
                size: 20, // Decreased icon size slightly
              ),
              const SizedBox(width: 10),
              Text(
                _bannerMessage ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14, // Decreased font size
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
    bool isLast = _stepIndex >= gameSteps.length - 1;
    String title = t('modal_title');
    String msg = isLast ? t('all_complete') : t('lvl_complete');

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
                    _playSound(_playerClick, _sfxClick);
                    if (isLast) {
                      setState(() {
                        _showShutter = true;
                        _gameState = 'idle';
                      });
                    } else {
                      _loadLevel(_stepIndex + 1);
                    }
                  },
                  child: Text(
                    isLast ? 'RESTART SIMULATION' : t('btn_proceed'),
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
                        BoxShadow(
                          color: accentTheme.withOpacity(
                            0.3 + (_pulseController.value * 0.4),
                          ),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: Icon(Icons.layers, color: accentTheme, size: 50),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                _playSound(
                  _playerShutter,
                  _sfxInit,
                ); // Powerful Shutter Open Sound
                setState(() {
                  _showShutter = false;
                });
                _loadLevel(0); // Trigger game start
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(
                t('btn_start_lab').toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
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

// Custom grid painter for the floor
class FloorGridPainter extends CustomPainter {
  final Color color;

  FloorGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || size.height <= 0 || size.width <= 0) return;

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1;

    double step = 60;
    // Horizontal perspective lines
    for (double i = 0; i < size.height; i += step * (i / size.height + 0.5)) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    // Vertical perspective lines
    double cx = size.width / 2;
    for (double i = 0; i <= cx; i += step) {
      canvas.drawLine(
        Offset(cx + i, size.height),
        Offset(cx + (i * 0.2), 0),
        paint,
      );
      canvas.drawLine(
        Offset(cx - i, size.height),
        Offset(cx - (i * 0.2), 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
