// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NumberVaultGame(),
    ),
  );
}

// --- LOCALIZATION DICTIONARY ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'THE NUMBER VAULT',
    'app_subtitle': 'CLASS 9 • Number Systems - Classification',
    'term_natural': 'Natural Numbers (N)',
    'desc_natural_short': 'Counting Numbers',
    'term_whole': 'Whole Numbers (W)',
    'desc_whole_short': 'Natural + Zero',
    'term_integer': 'Integers (Z)',
    'desc_integer_short': 'Positives + Negatives',
    'term_rational': 'Rational Numbers (Q)',
    'desc_rational_short': 'P/Q Form',
    'btn_start_lab': 'Initialize Vault',
    'game_security': 'SECURITY CLEARANCE',
    'game_mission': 'MISSION OBJECTIVE',
    'game_log': 'System Log',
    'btn_reset': 'Reboot System',
    'msg_correct': 'Correct! Captured.',
    'msg_wrong': 'Access Denied!',
    'modal_success': 'Clearance Granted!',
    'btn_next_level': 'PROCEED',
    'level_complete_msg': '{name} secured. Ready for next classification.',
    'all_complete_msg': 'All Number Systems Classified. Simulation Complete.',
    'mission_natural':
        'The Vault only accepts Natural Numbers. Identify numbers belonging to set N (1, 2, 3...).',
    'mission_whole':
        'The Vault needs Whole Numbers. Find Natural numbers plus Zero.',
    'mission_integer':
        'Locate Integers. This includes Whole numbers and their Negatives.',
    'mission_rational':
        'Target Rational Numbers. Look for fractions, ratios, and terminating decimals.',
    'mission_irrational':
        'Find Irrational Numbers. Complex numbers that cannot be simple fractions.',
    'log_level_start': 'System: Level {id} initiated.',
    'log_captured': 'Captured: {val}',
    'log_error': 'Error: {val} invalid.',
  },
  'hi': {
    'app_title': 'संख्या तिजोरी',
    'app_subtitle': 'कक्षा 9 • संख्या पद्धति – वास्तविक संख्या',
    'term_natural': 'प्राकृत संख्याएँ (N)',
    'desc_natural_short': 'गिनती की संख्याएँ',
    'term_whole': 'पूर्ण संख्याएँ (W)',
    'desc_whole_short': 'प्राकृत + शून्य',
    'term_integer': 'पूर्णांक (Z)',
    'desc_integer_short': 'धनात्मक + ऋणात्मक',
    'term_rational': 'परिमेय संख्याएँ (Q)',
    'desc_rational_short': 'P/Q रूप',
    'btn_start_lab': 'तिजोरी शुरू करें',
    'game_security': 'सुरक्षा निकासी',
    'game_mission': 'मिशन का उद्देश्य',
    'game_log': 'सिस्टम लॉग',
    'btn_reset': 'सिस्टम रीबूट करें',
    'msg_correct': 'सही! पकड़ लिया।',
    'msg_wrong': 'प्रवेश अस्वीकृत!',
    'modal_success': 'मंजूरी मिल गई!',
    'btn_next_level': 'आगे बढ़ें',
    'level_complete_msg': '{name} सुरक्षित। अगले वर्गीकरण के लिए तैयार।',
    'all_complete_msg':
        'सभी संख्या प्रणालियों का वर्गीकरण पूरा हुआ। सिमुलेशन समाप्त।',
    'mission_natural':
        'तिजोरी केवल प्राकृत संख्याएं स्वीकार करती है। N (1, 2, 3...) समूह की पहचान करें।',
    'mission_whole':
        'तिजोरी को पूर्ण संख्याओं की आवश्यकता है। प्राकृत संख्याएं और शून्य खोजें।',
    'mission_integer':
        'पूर्णांक का पता लगाएं। इसमें पूर्ण संख्याएं और उनके ऋणात्मक शामिल हैं।',
    'mission_rational':
        'परिमेय संख्याओं को लक्षित करें। भिन्न और समाप्त होने वाले दशमलव की तलाश करें।',
    'mission_irrational':
        'अपरिमेय संख्याएं खोजें। जटिल संख्याएं जो साधारण भिन्न नहीं हो सकतीं।',
    'log_level_start': 'सिस्टम: लेवल {id} शुरू किया गया।',
    'log_captured': 'पकड़ा गया: {val}',
    'log_error': 'त्रुटि: {val} अमान्य है।',
  },
};

// --- GAME DATA MODELS ---
class LevelData {
  final int id;
  final String nameKey;
  final String missionKey;
  final List<Map<String, dynamic>> targets;
  final List<Map<String, dynamic>> distractors;

  LevelData({
    required this.id,
    required this.nameKey,
    required this.missionKey,
    required this.targets,
    required this.distractors,
  });
}

final List<LevelData> levels = [
  LevelData(
    id: 1,
    nameKey: "term_natural",
    missionKey: "mission_natural",
    targets: [
      {"val": 1.0, "label": "1"},
      {"val": 5.0, "label": "5"},
      {"val": 100.0, "label": "100"},
    ],
    distractors: [
      {"val": 0.0, "label": "0"},
      {"val": -1.0, "label": "-1"},
      {"val": 0.5, "label": "0.5"},
    ],
  ),
  LevelData(
    id: 2,
    nameKey: "term_whole",
    missionKey: "mission_whole",
    targets: [
      {"val": 0.0, "label": "0"},
      {"val": 7.0, "label": "7"},
    ],
    distractors: [
      {"val": -5.0, "label": "-5"},
      {"val": 1.2, "label": "1.2"},
      {"val": -10.0, "label": "-10"},
    ],
  ),
  LevelData(
    id: 3,
    nameKey: "term_integer",
    missionKey: "mission_integer",
    targets: [
      {"val": -5.0, "label": "-5"},
      {"val": -10.0, "label": "-10"},
      {"val": 0.0, "label": "0"},
      {"val": 8.0, "label": "8"},
      {"val": 25.0, "label": "25"},
    ],
    distractors: [
      {"val": 0.5, "label": "1/2"},
      {"val": 3.14, "label": "π"},
      {"val": 1.414, "label": "√2"},
      {"val": -2.5, "label": "-2.5"},
    ],
  ),
  LevelData(
    id: 4,
    nameKey: "term_rational",
    missionKey: "mission_rational",
    targets: [
      {"val": 0.5, "label": "1/2"},
      {"val": 0.75, "label": "0.75"},
      {"val": -2.5, "label": "-5/2"},
    ],
    distractors: [
      {"val": 1.414, "label": "√2"},
      {"val": 3.14, "label": "π"},
    ],
  ),
  LevelData(
    id: 5,
    nameKey: "mission_irrational",
    missionKey: "mission_irrational",
    targets: [
      {"val": 1.414, "label": "√2"},
      {"val": 3.14, "label": "π"},
      {"val": 1.732, "label": "√3"},
    ],
    distractors: [
      {"val": 4.0, "label": "√16"},
      {"val": 0.0, "label": "0"},
      {"val": 0.333, "label": "1/3"},
    ],
  ),
];

class FloatingNumber {
  final String label;
  final bool isTarget;
  final Color color;
  double x;
  double y;
  double vx;
  double vy;
  double scale;
  bool isCaptured = false;
  double shakeOffset = 0;

  FloatingNumber({
    required this.label,
    required this.isTarget,
    required this.color,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.scale = 1.0,
  });
}

// --- MAIN APP WIDGET ---
class NumberVaultGame extends StatefulWidget {
  const NumberVaultGame({super.key});

  @override
  State<NumberVaultGame> createState() => _NumberVaultGameState();
}

class _NumberVaultGameState extends State<NumberVaultGame>
    with TickerProviderStateMixin {
  // Theme Colors
  final Color bgTheme = const Color(0xFF2e1065); // Deep Purple
  final Color accentTheme = const Color(0xFFfacc15); // Yellow
  final Color primaryTheme = const Color(0xFF38bdf8); // Sky Blue
  final Color secondaryTheme = const Color(0xFFfb7185); // Rose
  final Color panelColor = const Color(0xFF3b0764); // Solid Sidebar Purple
  
  final Color successTheme = const Color(0xFF22c55e);
  final Color errorTheme = const Color(0xFFf43f5e);

  // State
  String _currentLang = 'en';
  bool _sidebarOpen = true;
  bool _showShutter = true;

  // Game Engine State
  late Ticker _ticker;
  final List<FloatingNumber> _bubbles = [];
  int _currentLevel = 0;
  int _foundCount = 0;
  int _totalTargets = 0;
  String _gameState = 'idle'; // idle, playing, won, complete
  final List<String> _systemLogs = [];
  double _gameWidth = 100;
  double _gameHeight = 100;

  // Overlay state
  String? _bannerMessage;
  String? _bannerType; // 'success' or 'error'

  // Animations
  late AnimationController _vaultRotateController;

  // Audio Player Instances (Dedicated to prevent overlapping cuts)
  final AudioPlayer _playerClick = AudioPlayer();
  final AudioPlayer _playerPop = AudioPlayer();
  final AudioPlayer _playerError = AudioPlayer();
  final AudioPlayer _playerComplete = AudioPlayer();
  final AudioPlayer _playerShutter = AudioPlayer();

  // Local audio assets (assets/audio/class9/)
  final String _sfxPop = 'audio/class9/pop_crisp.mp3'; // Crisp UI pop
  final String _sfxError = 'audio/class9/error_beep.mp3'; // Computer error beep
  final String _sfxComplete = 'audio/class9/success.mp3'; // Magic level up chime
  final String _sfxClick = 'audio/class9/click.mp3'; // Clean mechanical click
  
  // FIX: Fast, short (1-second) mechanical transition/whoosh that works very reliably
  final String _sfxInit = 'audio/class9/shutter.mp3'; 
  final String _sfxClose = 'audio/class9/snap_close.mp3'; // Mechanical closing snap

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

    // Explicitly avoiding pre-loading tasks here to prevent Browser Audio Policy Timeouts.

    _vaultRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _ticker = createTicker(_updatePhysics);
  }

  @override
  void dispose() {
    // Reset Orientation & Audio
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _playerClick.dispose();
    _playerPop.dispose();
    _playerError.dispose();
    _playerComplete.dispose();
    _playerShutter.dispose();
    
    _vaultRotateController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  // --- WEB-SAFE AUDIO HELPER ---
  // Plays immediately upon user tap, heavily resistant to rate limits and blocks.
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

  // --- GAME LOGIC ---
  void _loadLevel(int levelIdx) {
    setState(() {
      _currentLevel = levelIdx;
      _foundCount = 0;
      _gameState = 'playing';
      _sidebarOpen = true;
      _bubbles.clear();
      _systemLogs.clear();

      LevelData data = levels[levelIdx];
      _totalTargets = data.targets.length;

      _logSystemMessage(
        t('log_level_start').replaceAll('{id}', data.id.toString()),
        isPrimary: true,
      );

      // Spawn bubbles
      final rand = math.Random();
      final colors = [
        const Color(0xFF0ea5e9),
        const Color(0xFFec4899),
        const Color(0xFF8b5cf6),
        const Color(0xFF10b981),
        const Color(0xFFf59e0b),
      ];

      void spawnList(List<Map<String, dynamic>> items, bool isTarget) {
        for (var item in items) {
          _bubbles.add(
            FloatingNumber(
              label: item['label'],
              isTarget: isTarget,
              color: colors[rand.nextInt(colors.length)],
              x: 50.0 + rand.nextDouble() * 200,
              y: 50.0 + rand.nextDouble() * 200,
              vx: (rand.nextDouble() - 0.5) * 2.5,
              vy: (rand.nextDouble() - 0.5) * 2.5,
            ),
          );
        }
      }

      spawnList(data.targets, true);
      spawnList(data.distractors, false);
      
      if (!_ticker.isTicking) _ticker.start();
    });
  }

  void _updatePhysics(Duration elapsed) {
    if (_gameState != 'playing' || _gameWidth <= 0 || _gameHeight <= 0 || _showShutter) return;

    bool needsUpdate = false;
    for (var b in _bubbles) {
      if (b.isCaptured) continue;

      // Shake decay
      if (b.shakeOffset != 0) {
        b.shakeOffset *= -0.8;
        if (b.shakeOffset.abs() < 0.5) b.shakeOffset = 0;
        needsUpdate = true;
      }

      // Movement
      b.x += b.vx;
      b.y += b.vy;

      // Bounce off walls (Radius ~30 for 60x60 bubbles)
      if (b.x < 30) {
        b.x = 30;
        b.vx *= -1;
      }
      if (b.x > _gameWidth - 30) {
        b.x = _gameWidth - 30;
        b.vx *= -1;
      }
      if (b.y < 30) {
        b.y = 30;
        b.vy *= -1;
      }
      if (b.y > _gameHeight - 30) {
        b.y = _gameHeight - 30;
        b.vy *= -1;
      }
      needsUpdate = true;
    }

    if (needsUpdate) setState(() {});
  }

  void _onBubbleTap(FloatingNumber b) {
    if (_gameState != 'playing' || b.isCaptured) return;

    if (b.isTarget) {
      // Correct
      HapticFeedback.heavyImpact();
      _playSound(_playerPop, _sfxPop); // Correct sound
      _showBanner('success', t('msg_correct'));
      _logSystemMessage(
        t('log_captured').replaceAll('{val}', b.label),
        isSuccess: true,
      );

      setState(() {
        _foundCount++;
        b.isCaptured = true;
      });

      if (_foundCount >= _totalTargets) {
        setState(() {
          _gameState = 'won'; // Lock interactions, keep canvas visible
        });
        _playSound(_playerComplete, _sfxComplete); // Level Complete Sound
        
        // Give 2 seconds for user to see cleared vault
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            setState(() {
              _gameState = 'complete';
            });
          }
        });
      }
    } else {
      // Wrong
      HapticFeedback.vibrate();
      _playSound(_playerError, _sfxError); // Error Sound
      _showBanner('error', t('msg_wrong'));
      _logSystemMessage(
        t('log_error').replaceAll('{val}', b.label),
        isError: true,
      );
      setState(() {
        b.shakeOffset = 20.0; // Trigger visual shake
      });
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

  void _logSystemMessage(
    String msg, {
    bool isError = false,
    bool isSuccess = false,
    bool isPrimary = false,
  }) {
    final time =
        "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}";
    String prefix = '>';

    setState(() {
      _systemLogs.insert(0, "$time $prefix $msg");
      if (_systemLogs.length > 25) _systemLogs.removeLast();
    });
  }

  // --- UI BUILDING ---
  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    // Sidebar width perfectly locked at 38%
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
                    _playSound(_playerClick, _sfxClick); // UI Sound
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
                        _playSound(_playerClick, _sfxClose); // UI Sound
                        // Bring up shutter screen on reboot
                        setState(() {
                          _showShutter = true;
                          _gameState = 'idle';
                          _ticker.stop();
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
        if (!active) {
          HapticFeedback.selectionClick();
          _playSound(_playerClick, _sfxClick); // UI Sound
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
    LevelData? curLevelData = levels.isNotEmpty && _currentLevel < levels.length
        ? levels[_currentLevel]
        : null;
        
    if (_gameState == 'idle') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('game_security'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'LEVEL ${_currentLevel + 1}',
                    style: TextStyle(
                      color: primaryTheme,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Text(
                '$_foundCount/$_totalTargets',
                style: TextStyle(
                  color: accentTheme,
                  fontSize: 24,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: accentTheme.withOpacity(0.5), blurRadius: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Objective and Logs Area
        Container(
          height: 280, // Fixed height to handle nested scrolling properly
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.radar, color: secondaryTheme, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    t('game_mission').toUpperCase(),
                    style: TextStyle(
                      color: secondaryTheme,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Objective Description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border(
                    left: BorderSide(color: secondaryTheme, width: 3),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  curLevelData != null ? t(curLevelData.missionKey) : '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Colors.white10),
              ),

              // Decoder Logs Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('game_log').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Logs List
              Expanded(
                child: ListView.builder(
                  itemCount: _systemLogs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        _systemLogs[index],
                        style: TextStyle(
                          color: _systemLogs[index].contains('Error')
                              ? errorTheme
                              : _systemLogs[index].contains('Captured')
                                  ? successTheme
                                  : accentTheme,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
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

  Widget _buildWorkspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Update physics boundaries dynamically to be fully responsive
        _gameWidth = constraints.maxWidth;
        _gameHeight = constraints.maxHeight;

        return Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF1e1b4b), Colors.black],
                  center: Alignment.center,
                  radius: 1.2,
                ),
              ),
            ),

            // Center Vault Graphic
            Center(
              child: AnimatedBuilder(
                animation: _vaultRotateController,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _vaultRotateController.value * 2 * math.pi,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4c1d95).withOpacity(0.5),
                        border: Border.all(color: primaryTheme, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: primaryTheme.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Transform.rotate(
                          angle: -(_vaultRotateController.value * 4 * math.pi), // counter rotate inner
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white30,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.filter_center_focus,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Floating Number Bubbles (Reduced to 60x60 for cleaner look)
            ..._bubbles.map((b) {
              if (b.isCaptured) return const SizedBox.shrink();

              return Positioned(
                left: b.x - 30 + b.shakeOffset, // Adjusted for 60 radius (30)
                top: b.y - 30,
                child: GestureDetector(
                  onTap: () => _onBubbleTap(b),
                  child: Transform.scale(
                    scale: b.scale,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: b.color,
                        boxShadow: [
                          BoxShadow(
                            color: b.color.withOpacity(0.6),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                          const BoxShadow(
                            color: Colors.white54,
                            spreadRadius: -2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          b.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18, // Reduced font size to match smaller bubble
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            
            // HUD Overlay (Top Center for Security Clearance)
            if (!_showShutter && _gameState != 'idle' && !_sidebarOpen)
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
                          t('game_security').toUpperCase(),
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'LEVEL ${_currentLevel + 1}',
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

            // Left Corner Mission HUD when Sidebar is Closed
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
                        t('game_mission').toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t(levels[_currentLevel].missionKey),
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
      // Drops smoothly from the top
      top: _bannerMessage != null ? 80 : -100, 
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isSuccess
                ? Colors.green.shade900.withOpacity(0.9)
                : Colors.red.shade900.withOpacity(0.9),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: isSuccess ? Colors.greenAccent : Colors.redAccent,
            ),
            boxShadow: [
              BoxShadow(
                color: isSuccess
                    ? Colors.greenAccent.withOpacity(0.5)
                    : Colors.redAccent.withOpacity(0.5),
                blurRadius: 30,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.warning,
                color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                _bannerMessage ?? '',
                style: TextStyle(
                  color: isSuccess ? Colors.greenAccent : Colors.redAccent,
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
    LevelData curData = levels[_currentLevel];
    String title = t('modal_success');
    String msg = t(
      'level_complete_msg',
    ).replaceAll('{name}', t(curData.nameKey));
    bool isLast = _currentLevel >= levels.length - 1;

    if (isLast) {
      msg = t('all_complete_msg');
    }

    return Container(
      color: Colors.black87,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: bgTheme,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accentTheme),
              boxShadow: [
                BoxShadow(color: accentTheme.withOpacity(0.3), blurRadius: 40),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: accentTheme,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star, color: bgTheme, size: 40),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentTheme,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
                      _loadLevel(_currentLevel + 1);
                    }
                  },
                  icon: Icon(
                    isLast ? Icons.refresh : Icons.arrow_forward,
                  ),
                  label: Text(
                    isLast ? 'RESTART SIMULATION' : t('btn_next_level'),
                    style: const TextStyle(
                      fontSize: 16,
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
      color: const Color(0xFF1e1b4b),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _vaultRotateController,
              builder: (_, child) {
                return Transform.rotate(
                  angle: _vaultRotateController.value * 2 * math.pi,
                  child: child,
                );
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryTheme, width: 8),
                  boxShadow: [
                    BoxShadow(
                      color: primaryTheme.withOpacity(0.5),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 60,
                ),
              ),
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
                _playSound(_playerShutter, _sfxInit); // Fast Short Init Sound
                setState(() {
                  _showShutter = false;
                });
                _loadLevel(0); // Trigger game start
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