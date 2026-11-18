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
      home: DecimalDecoderGame(),
    ),
  );
}

// --- LOCALIZATION DICTIONARY ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': 'DECIMAL DECODER',
    'app_subtitle': 'CLASS 9 • Number Systems - Decimal Expansions',
    'btn_start': 'Initialize Decoder',
    'game_system': 'SYSTEM STATUS',
    'mission_label': 'CURRENT OBJECTIVE',
    'btn_reset': 'Reboot',
    'btn_hint': 'Scan Area',
    'msg_success': 'ACCEPTED',
    'msg_error': 'REJECTED',
    'modal_title': 'DECODING SUCCESS',
    'btn_proceed': 'PROCEED',
    'btn_finish': 'SIMULATION COMPLETE',
    'lvl_1_miss':
        'Capture Terminating Decimals. Look for denominators with factors 2 or 5 (e.g., 2, 4, 5, 8, 10).',
    'lvl_2_miss':
        'Capture Recurring Decimals. Look for denominators with factors like 3, 7, 9, 11.',
    'lvl_3_miss':
        'Capture Patterned Decimals. Identify repeating sequences (e.g., 0.1212...) and fractions like 22/7.',
    'lvl_complete': 'Sequence Decoded. Ready for next stream.',
    'all_complete': 'All Decimals Analyzed. Simulation Complete.',
    'hint_msg': 'Hint: Scan for {val}',
  },
  'hi': {
    'app_title': 'दशमलव डिकोडर',
    'app_subtitle': 'कक्षा 9 • संख्या पद्धति – दशमलव विस्तार',
    'btn_start': 'डिकोडर शुरू करें',
    'game_system': 'सिस्टम स्थिति',
    'mission_label': 'वर्तमान उद्देश्य',
    'btn_reset': 'रीबूट',
    'btn_hint': 'स्कैन',
    'msg_success': 'स्वीकृत',
    'msg_error': 'अस्वीकृत',
    'modal_title': 'सफलता',
    'btn_proceed': 'आगे बढ़ें',
    'btn_finish': 'सिमुलेशन समाप्त',
    'lvl_1_miss': 'सांत दशमलव पकड़ें। हर में 2 या 5 वाले भिन्नों को खोजें।',
    'lvl_2_miss': 'आवर्ती दशमलव पकड़ें। हर में 3, 7, 9, 11 जैसे गुणनखंड खोजें।',
    'lvl_3_miss': 'पैटर्न वाले दशमलव पकड़ें। दोहराने वाले क्रमों की पहचान करें।',
    'lvl_complete': 'अनुक्रम डिकोड किया गया।',
    'all_complete': 'सभी दशमलव का विश्लेषण किया गया।',
    'hint_msg': 'संकेत: {val} को खोजें',
  },
};

// --- GAME DATA MODELS ---
class LevelData {
  final int id;
  final String missionKey;
  final List<Map<String, String>> targets;
  final List<Map<String, String>> distractors;

  LevelData({
    required this.id,
    required this.missionKey,
    required this.targets,
    required this.distractors,
  });
}

final List<LevelData> levels = [
  LevelData(
    id: 1,
    missionKey: "lvl_1_miss",
    targets: [
      {"val": "1/2", "label": "1/2"},
      {"val": "0.5", "label": "0.5"},
      {"val": "2/5", "label": "2/5"},
      {"val": "3/4", "label": "3/4"},
      {"val": "0.25", "label": "0.25"},
    ],
    distractors: [
      {"val": "1/3", "label": "1/3"},
      {"val": "1/7", "label": "1/7"},
      {"val": "0.33...", "label": "0.33..."},
      {"val": "2/9", "label": "2/9"},
    ],
  ),
  LevelData(
    id: 2,
    missionKey: "lvl_2_miss",
    targets: [
      {"val": "1/3", "label": "1/3"},
      {"val": "0.33...", "label": "0.33..."},
      {"val": "1/7", "label": "1/7"},
      {"val": "2/9", "label": "2/9"},
    ],
    distractors: [
      {"val": "1/2", "label": "1/2"},
      {"val": "0.5", "label": "0.5"},
      {"val": "1/5", "label": "1/5"},
      {"val": "1/10", "label": "1/10"},
    ],
  ),
  LevelData(
    id: 3,
    missionKey: "lvl_3_miss",
    targets: [
      {"val": "22/7", "label": "22/7"},
      {"val": "0.142...", "label": "0.142..."},
      {"val": "10/3", "label": "10/3"},
      {"val": "0.66...", "label": "0.66..."},
    ],
    distractors: [
      {"val": "3/4", "label": "3/4"},
      {"val": "0.125", "label": "0.125"},
      {"val": "7/8", "label": "7/8"},
    ],
  ),
];

class FloatingNumber {
  final String label;
  final bool isTarget;
  double x;
  double y;
  double vx;
  double vy;
  double scale;
  bool isCaptured = false;
  double shakeOffset = 0;
  bool isHinted = false;

  FloatingNumber({
    required this.label,
    required this.isTarget,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.scale = 1.0,
  });
}

// --- MAIN APP WIDGET ---
class DecimalDecoderGame extends StatefulWidget {
  const DecimalDecoderGame({super.key});

  @override
  State<DecimalDecoderGame> createState() => _DecimalDecoderGameState();
}

class _DecimalDecoderGameState extends State<DecimalDecoderGame>
    with TickerProviderStateMixin {
  // Theme colors based on HTML CSS
  final Color bgTheme = const Color(0xFF020617); // slate-950
  final Color accentTheme = const Color(0xFF06b6d4); // cyan-500
  final Color primaryTheme = const Color(0xFF10b981); // emerald-500
  final Color secondaryTheme = const Color(0xFF8b5cf6); // violet-500
  final Color panelColor = const Color(0xFF0f172a); // Removed opacity to make sidebar solid
  final Color errorTheme = const Color(0xFFf43f5e); // red-500
  final Color successTheme = const Color(0xFF22c55e); // green-500

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
  late AnimationController _coreRotateController;
  late AnimationController _pulseController;

  // Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Local audio assets (assets/audio/class9/)
  static const String _clickUrl = 'audio/class9/click.mp3';
  static const String _successUrl = 'audio/class9/success.mp3';
  static const String _errorUrl = 'audio/class9/error.mp3'; // Exact Error Sound requested
  static const String _alertUrl = 'audio/class9/alert.mp3';
  static const String _shutterUrl = 'audio/class9/shutter.mp3'; // Exact Shutter Sound requested

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

    _coreRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _ticker = createTicker(_updatePhysics);
  }

  @override
  void dispose() {
    // Reset Orientation to normal (allow portrait) and UI mode on exit
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _coreRotateController.dispose();
    _pulseController.dispose();
    _ticker.dispose();
    
    // Dispose all audio players
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _shutterPlayer.dispose();
    
    super.dispose();
  }

  // --- WEB-SAFE AUDIO HELPER ---
  // Plays immediately upon user tap, highly resistant to rate limits and browser blocks.
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
      _systemLogs.clear(); // Clear logs on new level for cleaner UI

      LevelData data = levels[levelIdx];
      _totalTargets = data.targets.length;

      _logSystemMessage('Initializing Level ${data.id}...', isPrimary: true);

      // Spawn bubbles
      final rand = math.Random();

      void spawnList(List<Map<String, String>> items, bool isTarget) {
        for (var item in items) {
          _bubbles.add(
            FloatingNumber(
              label: item['label']!,
              isTarget: isTarget,
              x: 50.0 + rand.nextDouble() * 200,
              y: 50.0 + rand.nextDouble() * 200,
              vx: (rand.nextDouble() - 0.5) * 3.0,
              vy: (rand.nextDouble() - 0.5) * 3.0,
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

      // Hint decay
      if (b.isHinted && b.scale > 1.0) {
        b.scale -= 0.05;
        if (b.scale <= 1.0) b.isHinted = false;
        needsUpdate = true;
      }

      // Movement
      b.x += b.vx;
      b.y += b.vy;

      // Bounce off walls (radius ~35)
      if (b.x < 35) {
        b.x = 35;
        b.vx *= -1;
      }
      if (b.x > _gameWidth - 35) {
        b.x = _gameWidth - 35;
        b.vx *= -1;
      }
      if (b.y < 35) {
        b.y = 35;
        b.vy *= -1;
      }
      if (b.y > _gameHeight - 35) {
        b.y = _gameHeight - 35;
        b.vy *= -1;
      }
      needsUpdate = true;
    }

    if (needsUpdate) setState(() {});
  }

  void _onBubbleTap(FloatingNumber b) {
    if (_gameState != 'playing' || b.isCaptured || _showShutter) return;

    if (b.isTarget) {
      // Correct
      HapticFeedback.heavyImpact();
      _playSound(_fxPlayer, _alertUrl); // Play target acquired sound
      _showBanner('success', t('msg_success'));
      _logSystemMessage('Decoded: ${b.label}', isSuccess: true);

      setState(() {
        _foundCount++;
        b.isCaptured = true;
      });

      if (_foundCount >= _totalTargets) {
        setState(() {
          _gameState = 'won'; // Lock interactions immediately
        });
        _playSound(_successPlayer, _successUrl); // Play Level Complete Sound

        // 2 Second delay before showing the final modal
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
      _playSound(_errorPlayer, _errorUrl); // Play custom Error Sound
      _showBanner('error', t('msg_error'));
      _logSystemMessage('Error: ${b.label} Invalid', isError: true);
      setState(() {
        b.shakeOffset = 25.0; // Trigger shake
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

  void _triggerHint() {
    if (_gameState != 'playing' || _showShutter) return;
    HapticFeedback.selectionClick();
    _playSound(_clickPlayer, _clickUrl); // Play generic UI click

    FloatingNumber? target;
    for (var b in _bubbles) {
      if (b.isTarget && !b.isCaptured) {
        target = b;
        break;
      }
    }

    if (target != null) {
      _logSystemMessage(
        t('hint_msg').replaceAll('{val}', target.label),
        isPrimary: true,
      );
      setState(() {
        target!.isHinted = true;
        target.scale = 2.0;
      });
    }
  }

  // --- UI BUILDING ---
  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    // Unified 38% Sidebar Width
    double sidebarWidth = screenW * 0.38;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // Enforce immersive mode if user taps anywhere outside inputs
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
                    border: Border(right: BorderSide(color: accentTheme.withOpacity(0.2))),
                  ),
                  child: ClipRect(
                    // OverflowBox ensures the content doesn't squeeze and wrap while the sidebar is sliding out
                    child: OverflowBox(
                      minWidth: 0,
                      maxWidth: sidebarWidth,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: sidebarWidth,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(left: 0, top: 16.0, right: 16.0, bottom: 24.0),
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
                height: 48, // Fixed size to match the header alignment perfectly
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(_sidebarOpen ? Icons.menu_open : Icons.menu),
                  color: Colors.white,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _playSound(_clickPlayer, _clickUrl); // Play click sound
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
                    child: Row(children: [_langBtn('en', 'EN'), _langBtn('hi', 'HI')]),
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
                      icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
                      tooltip: t('btn_reset'),
                      onPressed: () {
                        HapticFeedback.vibrate();
                        _playSound(_clickPlayer, _clickUrl); // Play click sound
                        setState(() {
                          _systemLogs.clear();
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
          _playSound(_clickPlayer, _clickUrl); // Play click sound
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

    if (_showShutter || _gameState == 'idle') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Objective Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: secondaryTheme.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            border: Border(left: BorderSide(color: secondaryTheme, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('mission_label'),
                style: TextStyle(
                  color: secondaryTheme,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                curLevelData != null ? t(curLevelData.missionKey) : '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.3,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Decoder Log Area (Fixed height area inside scrollable sidebar)
        Container(
          height: 250,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DECODER LOG',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: 0.3 + (_pulseController.value * 0.7),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
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
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _systemLogs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        _systemLogs[index],
                        style: TextStyle(
                          color: _systemLogs[index].contains('Error')
                              ? Colors.redAccent
                              : _systemLogs[index].contains('Decoded')
                              ? Colors.greenAccent
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

        // Actions
        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: accentTheme,
            side: BorderSide(color: accentTheme.withOpacity(0.5)),
            backgroundColor: accentTheme.withOpacity(0.1),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _triggerHint,
          icon: const Icon(Icons.radar, size: 18),
          label: Text(
            t('btn_hint').toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
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
                  colors: [Color(0xFF0f172a), Colors.black],
                  center: Alignment.center,
                  radius: 1.0,
                ),
              ),
            ),

            // Background grid aesthetic
            CustomPaint(
              size: Size(_gameWidth, _gameHeight),
              painter: GridPainter(color: accentTheme.withOpacity(0.05)),
            ),

            // Center Decoder Core Graphic
            Center(
              child: AnimatedBuilder(
                animation: _coreRotateController,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _coreRotateController.value * 2 * math.pi,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentTheme.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Transform.rotate(
                          angle:
                              -(_coreRotateController.value *
                                  4 *
                                  math.pi), // counter rotate inner
                          child: Icon(
                            Icons.memory,
                            color: accentTheme.withOpacity(0.6),
                            size: 70,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Floating Number Bubbles
            ..._bubbles.map((b) {
              if (b.isCaptured) return const SizedBox.shrink();

              return Positioned(
                left: b.x - 35 + b.shakeOffset, // Add shake to X
                top: b.y - 35,
                child: GestureDetector(
                  onTap: () => _onBubbleTap(b),
                  child: Transform.scale(
                    scale: b.scale,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black87,
                        border: Border.all(color: accentTheme, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: accentTheme.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: accentTheme.withOpacity(0.2),
                            spreadRadius: -2,
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          b.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            // HUD Overlay (Top Center for Status)
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
                          t('game_system').toUpperCase(),
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'LEVEL ${_currentLevel + 1}',
                              style: TextStyle(
                                color: accentTheme,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$_foundCount/$_totalTargets',
                              style: TextStyle(
                                color: primaryTheme,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
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
                        t('mission_label').toUpperCase(),
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
      // Drops from top to avoid covering game elements
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
    bool isLast = _currentLevel >= levels.length - 1;
    String title = t('modal_title');
    String msg = isLast ? t('all_complete') : t('lvl_complete');

    return Container(
      color: Colors.black87,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: SingleChildScrollView(
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
                  Icon(Icons.memory, color: accentTheme, size: 60),
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
                    style: const TextStyle(
                      color: Colors.white70, 
                      fontSize: 14,
                      fontFamily: 'monospace',
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
                      _playSound(_clickPlayer, _clickUrl); // Play click sound
                      if (isLast) {
                        setState(() {
                          _systemLogs.clear();
                          _showShutter = true;
                          _gameState = 'idle';
                          _ticker.stop();
                        });
                      } else {
                        _loadLevel(_currentLevel + 1);
                      }
                    },
                    icon: Icon(isLast ? Icons.refresh : Icons.arrow_forward),
                    label: Text(
                      isLast ? t('btn_finish') : t('btn_proceed'),
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
                    child: Icon(Icons.radar, color: accentTheme, size: 50),
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
                _playSound(_shutterPlayer, _shutterUrl); // Specifically requested initialization sound
                setState(() {
                  _showShutter = false;
                });
                _loadLevel(0); // Trigger game start
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(
                t('btn_start').toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple Custom grid painter to match the cyber aesthetic
class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    double step = 40;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}