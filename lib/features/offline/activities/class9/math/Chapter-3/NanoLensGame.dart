// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: NanoLensGame()),
  );
}

// --- GAME DATA MODELS ---
class GameStep {
  final String title;
  final String desc;
  final String hint;
  final double rangeStart;
  final double rangeEnd;
  final double targetValue; // Unified target point/interval start for simplicity

  GameStep({
    required this.title,
    required this.desc,
    required this.hint,
    required this.rangeStart,
    required this.rangeEnd,
    required this.targetValue,
  });
}

// --- LOCALIZATION DICTIONARY ---
final Map<String, Map<String, dynamic>> i18n = {
  'en': {
    'app_title': 'THE NANO-LENS',
    'tagline': 'SUCCESSIVE MAGNIFICATION LAB',
    'init_btn': 'INITIALIZE LAB',
    'header_title': 'The Nano-Lens',
    'header_subtitle': 'CLASS 9 • NUMBER SYSTEMS - Successive Magnification',
    'btn_start_lab': 'Launch Nano-Lens',
    'lab_status_header': 'ZOOM STATUS',
    'mission_title': 'Objective',
    'btn_reset': 'Reset',
    'hud_range': 'Current Range',
    'hud_target': 'Target Value',
    'msg_awesome': 'ACQUIRED!',
    'log_init': 'Microscope Initialized.',
    'log_zoom': 'Zooming into range: ',
    'err_miss': 'Incorrect selection. Check the digits.',
    'gd_lo_t': '🎯 Learning Outcomes',
    'gd_lo_1': "Visualize the property of 'density' of real numbers.",
    'gd_lo_2':
        'Understand place value as a hierarchy of zooming in (tenths -> hundredths -> thousandths).',
    'gd_lo_3': 'Locate specific rational numbers on the number line.',
    // Condensed steps to make the updates immediate and smooth
    'steps': [
      GameStep(
        title: "Macro View",
        desc: "Target: 3.7654. Find the integer interval it lies between.",
        hint: "Click between 3 and 4.",
        rangeStart: 0,
        rangeEnd: 10,
        targetValue: 3.0,
      ),
      GameStep(
        title: "Tenths",
        desc: "Zoomed to 3.0 - 4.0. Locate 3.7 to narrow down.",
        hint: "Find 3.7.",
        rangeStart: 3.0,
        rangeEnd: 4.0,
        targetValue: 3.7,
      ),
      GameStep(
        title: "Hundredths",
        desc: "Zoomed to 3.70 - 3.80. Locate 3.76.",
        hint: "Find 3.76.",
        rangeStart: 3.7,
        rangeEnd: 3.8,
        targetValue: 3.76,
      ),
      GameStep(
        title: "Thousandths",
        desc: "Zoomed to 3.760 - 3.770. Locate 3.765.",
        hint: "Find 3.765.",
        rangeStart: 3.76,
        rangeEnd: 3.77,
        targetValue: 3.765,
      ),
      GameStep(
        title: "Ten-Thousandths",
        desc: "Microscopic Level! Range 3.7650 - 3.7660. Pinpoint 3.7654.",
        hint: "Pinpoint 3.7654.",
        rangeStart: 3.765,
        rangeEnd: 3.766,
        targetValue: 3.7654,
      ),
    ],
  },
  'hi': {
    'app_title': 'नैनो-लेंस',
    'tagline': 'क्रमिक आवर्धन प्रयोगशाला',
    'init_btn': 'लैब शुरू करें',
    'header_title': 'नैनो-लेंस',
    'header_subtitle': 'कक्षा 9 • संख्या पद्धति – क्रमिक आवर्धन',
    'btn_start_lab': 'लेंस शुरू करें',
    'lab_status_header': 'ज़ूम स्थिति',
    'mission_title': 'लक्ष्य',
    'btn_reset': 'रीसेट',
    'hud_range': 'वर्तमान रेंज',
    'hud_target': 'लक्ष्य मूल्य',
    'msg_awesome': 'प्राप्त किया!',
    'log_init': 'माइक्रोस्कोप तैयार।',
    'log_zoom': 'रेंज में ज़ूम कर रहे हैं: ',
    'err_miss': 'गलत चयन। अंकों की जाँच करें।',
    'gd_lo_t': '🎯 सीखने के परिणाम',
    'gd_lo_1': "वास्तविक संख्याओं के 'घनत्व' के गुण की कल्पना करें।",
    'gd_lo_2': 'स्थान मान को ज़ूम इन करने के पदानुक्रम के रूप में समझें।',
    'gd_lo_3': 'संख्या रेखा पर विशिष्ट परिमेय संख्याओं का पता लगाएं।',
    'steps': [
      GameStep(
        title: "मैक्रो दृश्य",
        desc: "लक्ष्य: 3.7654। उन पूर्णांकों को खोजें जिनके बीच यह स्थित है।",
        hint: "3 और 4 के बीच क्लिक करें।",
        rangeStart: 0,
        rangeEnd: 10,
        targetValue: 3.0,
      ),
      GameStep(
        title: "दसवां भाग",
        desc: "3.0 - 4.0 पर ज़ूम किया गया। 3.7 खोजें।",
        hint: "3.7 खोजें।",
        rangeStart: 3.0,
        rangeEnd: 4.0,
        targetValue: 3.7,
      ),
      GameStep(
        title: "सौवां भाग",
        desc: "रेंज 3.70 - 3.80। 3.76 खोजें।",
        hint: "3.76 खोजें।",
        rangeStart: 3.7,
        rangeEnd: 3.8,
        targetValue: 3.76,
      ),
      GameStep(
        title: "हज़ारवां भाग",
        desc: "रेंज 3.760 - 3.770। 3.765 खोजें।",
        hint: "3.765 खोजें।",
        rangeStart: 3.76,
        rangeEnd: 3.77,
        targetValue: 3.765,
      ),
      GameStep(
        title: "दस-हज़ारवां भाग",
        desc: "सूक्ष्म स्तर! रेंज 3.7650 - 3.7660। 3.7654 को इंगित करें।",
        hint: "3.7654 को इंगित करें।",
        rangeStart: 3.765,
        rangeEnd: 3.766,
        targetValue: 3.7654,
      ),
    ],
  },
};

// --- MAIN APP WIDGET ---
class NanoLensGame extends StatefulWidget {
  const NanoLensGame({super.key});

  @override
  State<NanoLensGame> createState() => _NanoLensGameState();
}

class _NanoLensGameState extends State<NanoLensGame>
    with TickerProviderStateMixin {
  // Theme colors
  final Color bgTheme = const Color(0xFF0f0518);
  final Color accentTheme = const Color(0xFF06b6d4); // Cyan
  final Color primaryTheme = const Color(0xFF3b82f6); // Blue
  final Color secondaryTheme = const Color(0xFF8b5cf6); // Violet
  final Color successTheme = const Color(0xFF22c55e);
  final Color errorTheme = const Color(0xFFf43f5e);
  final Color panelColor = const Color(0xFF0f172a); // Solid, removed opacity

  // State
  String _currentLang = 'en';
  bool _sidebarOpen = true;
  bool _showShutter = true;
  bool _isZooming = false; // Prevents interactions while zooming

  // Game State
  int _stepIndex = 0;
  String _gameState = 'idle'; // idle, playing, complete
  final List<String> _systemLogs = [];
  bool _showHint = false;

  // View Bounds for rendering (animated)
  double _currentRangeStart = 0;
  double _currentRangeEnd = 10;
  late AnimationController _zoomController;
  late Animation<double> _animStart;
  late Animation<double> _animEnd;

  // Interaction state
  double? _hoverX;

  // Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
  final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Local audio assets (assets/audio/class9/)
  final String _clickUrl = 'audio/class9/click.mp3';
  final String _successUrl = 'audio/class9/success.mp3';
  final String _errorUrl = 'audio/class9/error.mp3';
  final String _alertUrl = 'audio/class9/alert.mp3';
  final String _shutterUrl = 'audio/class9/shutter.mp3';

  String t(String key) => i18n[_currentLang]?[key] ?? key;
  List<GameStep> get steps => i18n[_currentLang]!['steps'];
  GameStep get currentStep => steps[_stepIndex];

  @override
  void initState() {
    super.initState();
    // Enforce Landscape Mode and Immersive UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Standard smooth zoom duration
    )..addListener(() {
        setState(() {
          _currentRangeStart = _animStart.value;
          _currentRangeEnd = _animEnd.value;
        });
      });
  }

  @override
  void dispose() {
    // Reset Orientation and UI mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    // Dispose resources properly
    _zoomController.dispose();
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _shutterPlayer.dispose();
    
    super.dispose();
  }

  // --- WEB-SAFE AUDIO HELPER ---
  // Plays immediately upon user tap, highly resistant to rate limits and blocks.
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
  void _resetLab() {
    _zoomController.stop(); // Safe guard animation
    setState(() {
      _stepIndex = 0;
      _gameState = 'playing';
      _currentRangeStart = steps[0].rangeStart;
      _currentRangeEnd = steps[0].rangeEnd;
      _showHint = false;
      _isZooming = false;
      _systemLogs.clear();
      _logSystemMessage(t('log_init'), isPrimary: true);
    });
  }

  void _handleTap(double tappedValue) {
    if (_gameState == 'complete' || _isZooming || _showShutter) return;

    double expectedValue = currentStep.targetValue;
    double currentRange = currentStep.rangeEnd - currentStep.rangeStart;
    double tolerance = currentRange * 0.08; // 8% of current range tolerance

    if ((tappedValue - expectedValue).abs() <= tolerance) {
      // Success
      _isZooming = true; // Lock interactions
      HapticFeedback.heavyImpact();
      _playSound(_fxPlayer, _alertUrl); // Zoom acquired sound
      
      _logSystemMessage(
        "${t('log_zoom')}${expectedValue.toStringAsFixed(4)}",
        isSuccess: true,
      );
      _triggerFeedbackBanner('success');

      // Delay state update and zoom so user can process the success banner
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _showHint = false;
          if (_stepIndex < steps.length - 1) {
            _stepIndex++;
            _animateZoomTo(
              steps[_stepIndex].rangeStart,
              steps[_stepIndex].rangeEnd,
            );
          } else {
            _gameState = 'complete';
            _isZooming = false;
            _triggerCelebration();
          }
        });
      });
    } else {
      // Error
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl); // Wrong selection sound
      _logSystemMessage(t('err_miss'), isError: true);
      _triggerFeedbackBanner('error');
    }
  }

  void _animateZoomTo(double newStart, double newEnd) {
    // Only animate if bounds actually change
    if ((_currentRangeStart - newStart).abs() > 0.00001 ||
        (_currentRangeEnd - newEnd).abs() > 0.00001) {
      _animStart = Tween<double>(begin: _currentRangeStart, end: newStart)
          .animate(
        CurvedAnimation(
          parent: _zoomController,
          curve: Curves.easeInOutCubic,
        ),
      );
      _animEnd = Tween<double>(begin: _currentRangeEnd, end: newEnd).animate(
        CurvedAnimation(parent: _zoomController, curve: Curves.easeInOutCubic),
      );
      _zoomController.forward(from: 0.0).then((_) {
        // Unlock interactions once zoom is completely done
        if (mounted) {
          setState(() {
            _isZooming = false;
          });
        }
      });
    } else {
      _isZooming = false;
    }
  }

  void _triggerFeedbackBanner(String type) {
    // Shows temporary banner via overlay
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100,
        left: MediaQuery.of(context).size.width / 2 - 100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: type == 'error'
                  ? errorTheme.withOpacity(0.9)
                  : successTheme.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 10),
              ],
            ),
            child: Text(
              type == 'error' ? t('err_miss') : t('msg_awesome'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry?.remove());
  }

  void _triggerCelebration() {
    _playSound(_successPlayer, _successUrl); // Success completion sound
    _triggerFeedbackBanner('success');
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
    // Sidebar width at 35%
    double sidebarWidth = math.max(screenW * 0.35, 340.0);

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
                    _playSound(_clickPlayer, _clickUrl); // UI click
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
            if (_showShutter) _buildLoadingShutter(),
            if (_gameState == 'complete' && !_showShutter) _buildCompleteOverlay(),
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
                style: const TextStyle(
                  color: Colors.white54,
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
                      boxShadow: [
                        BoxShadow(
                            color: Colors.redAccent.withOpacity(0.2),
                            blurRadius: 10),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.power_settings_new,
                          color: Colors.redAccent),
                      tooltip: t('btn_reset'),
                      onPressed: () {
                        HapticFeedback.vibrate();
                        _playSound(_clickPlayer, _clickUrl); // UI click
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
          _playSound(_clickPlayer, _clickUrl); // UI click
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
    if (steps.isEmpty || _gameState == 'idle') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Box
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
                t('lab_status_header'),
                style: TextStyle(
                  color: secondaryTheme,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentStep.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Target: 3.7654',
                    style: TextStyle(
                      color: successTheme,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress Bar
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _stepIndex / (steps.length - 1),
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

        // Objective and Logs Area
        Container(
          height: 250, // Fixed height to handle nested scrolling properly
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
                children: [
                  Icon(Icons.my_location, color: secondaryTheme, size: 16),
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
                currentStep.desc,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Colors.white10),
              ),
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
                              : _systemLogs[index].contains('Zooming')
                                  ? successTheme
                                  : accentTheme,
                          fontSize: 10,
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

            // Interaction layer
            GestureDetector(
              onTapDown: (details) {
                double x = details.localPosition.dx;
                double width = constraints.maxWidth;
                double padding = 40.0;

                if (x >= padding && x <= width - padding) {
                  double pct = (x - padding) / (width - padding * 2);
                  double val = _currentRangeStart +
                      pct * (_currentRangeEnd - _currentRangeStart);
                  _handleTap(val);
                }
              },
              onPanUpdate: (details) {
                // Hover effect logic
                if (!_isZooming && !_showShutter) {
                  setState(() {
                    _hoverX = details.localPosition.dx;
                  });
                }
              },
              onPanEnd: (_) => setState(() => _hoverX = null),
              child: CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: NumberLinePainter(
                  start: _currentRangeStart,
                  end: _currentRangeEnd,
                  hoverX: _hoverX,
                  targetValue: _showHint ? currentStep.targetValue : null,
                  themeColor: accentTheme,
                ),
              ),
            ),

            // HUD Overlay (Top Center for Bounds)
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
                          t('hud_range').toUpperCase(),
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '[${_currentRangeStart.toStringAsFixed(_getPrecision(_currentRangeEnd - _currentRangeStart))}, ${_currentRangeEnd.toStringAsFixed(_getPrecision(_currentRangeEnd - _currentRangeStart))}]',
                          style: const TextStyle(
                            color: Colors.white,
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

            // Left Corner Target Value HUD when Sidebar is Closed
            if (!_sidebarOpen && !_showShutter && _gameState != 'idle')
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(color: successTheme, width: 4),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('hud_target').toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '3.7654', // Always show the final objective value
                        style: TextStyle(
                          color: successTheme,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
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

  int _getPrecision(double range) {
    // Robust thresholds to prevent floating-point inaccuracy rounding bugs
    if (range > 1.5) return 0;
    if (range > 0.15) return 1;
    if (range > 0.015) return 2;
    if (range > 0.0015) return 3;
    return 4;
  }

  Widget _buildLoadingShutter() {
    return Container(
      color: bgTheme,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.science, color: accentTheme, size: 60),
            const SizedBox(height: 20),
            Text(
              t('app_title'),
              style: TextStyle(
                color: accentTheme,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
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
                _playSound(_shutterPlayer, _shutterUrl); // Fast initialization sound
                setState(() {
                  _showShutter = false;
                });
                _resetLab();
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

  Widget _buildCompleteOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgTheme,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: successTheme),
            boxShadow: [
              BoxShadow(color: successTheme.withOpacity(0.2), blurRadius: 80),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, color: Colors.greenAccent, size: 80),
              const SizedBox(height: 24),
              Text(
                t('msg_awesome'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Target 3.7654 successfully acquired.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentTheme,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _playSound(_clickPlayer, _clickUrl); // UI click
                  // Open the shutter screen when restarting simulation
                  setState(() {
                    _showShutter = true;
                    _gameState = 'idle';
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'RESTART SIMULATION',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER FOR NUMBER LINE ---
class NumberLinePainter extends CustomPainter {
  final double start;
  final double end;
  final double? hoverX;
  final double? targetValue;
  final Color themeColor;

  NumberLinePainter({
    required this.start,
    required this.end,
    this.hoverX,
    this.targetValue,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double padding = 40.0;
    double innerWidth = size.width - padding * 2;
    double centerY = size.height / 2;

    // Background Grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Main Line
    final linePaint = Paint()
      ..color = const Color(0xFF3b82f6) // Primary blue
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(padding, centerY),
      Offset(size.width - padding, centerY),
      linePaint,
    );

    // Calculate precision for text
    double range = end - start;
    int precision = 0;
    
    // Robust thresholds to avoid floating point bugs
    if (range > 1.5) {
      precision = 0;
    } else if (range > 0.15) {
      precision = 1;
    } else if (range > 0.015) {
      precision = 2;
    } else if (range > 0.0015) {
      precision = 3;
    } else {
      precision = 4;
    }

    double step = range / 10;

    // Dynamic font size logic to keep text from squishing
    double fSize = precision >= 3 ? 10.5 : 12.0;

    // Draw Ticks and Labels
    final tickPaint = Paint()
      ..color = themeColor
      ..strokeWidth = 2;
    final textStyle = TextStyle(
      color: Colors.white70,
      fontSize: fSize,
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
    );

    for (int i = 0; i <= 10; i++) {
      double val = start + i * step;
      double x = padding + (i / 10) * innerWidth;

      // Tick
      double tickHeight = (i == 0 || i == 10) ? 20 : 10;
      canvas.drawLine(
        Offset(x, centerY - tickHeight),
        Offset(x, centerY + tickHeight),
        tickPaint,
      );

      // Label
      String labelText = val.toStringAsFixed(precision);
      final textPainter = TextPainter(
        text: TextSpan(text: labelText, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // STAGGER TEXT (Odd/Even alternations) to completely prevent overlapping text logic
      double yOffset = (i % 2 == 0) ? 25.0 : 45.0;
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, centerY + yOffset),
      );

      // Draw subtle connective line for the staggered labels so user knows which tick it relates to
      if (i % 2 != 0) {
        canvas.drawLine(
          Offset(x, centerY + tickHeight),
          Offset(x, centerY + yOffset - 4),
          Paint()
            ..color = Colors.white24
            ..strokeWidth = 1,
        );
      }

      // Draw subtle hit zones
      if (i < 10) {
        double nextX = padding + ((i + 1) / 10) * innerWidth;
        canvas.drawRect(
          Rect.fromLTRB(x, centerY - 10, nextX, centerY + 10),
          Paint()..color = themeColor.withOpacity(0.0),
        ); // Invisible hit zone
      }
    }

    // Draw Hint Highlight
    if (targetValue != null && targetValue! >= start && targetValue! <= end) {
      double x = padding + ((targetValue! - start) / range) * innerWidth;

      // Highlight interval if it's not the exact end point
      if (targetValue! < end) {
        double nextX = x + (innerWidth / 10);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(x, centerY - 15, nextX, centerY + 15),
            const Radius.circular(4),
          ),
          Paint()
            ..color = Colors.yellow.withOpacity(0.3)
            ..style = PaintingStyle.fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(x, centerY - 15, nextX, centerY + 15),
            const Radius.circular(4),
          ),
          Paint()
            ..color = Colors.yellow
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      } else {
        // Point highlight
        canvas.drawCircle(
          Offset(x, centerY),
          15,
          Paint()
            ..color = Colors.yellow.withOpacity(0.5)
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          Offset(x, centerY),
          15,
          Paint()
            ..color = Colors.yellow
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    // Hover Lens Effect
    if (hoverX != null &&
        hoverX! >= padding &&
        hoverX! <= size.width - padding) {
      canvas.drawCircle(
        Offset(hoverX!, centerY),
        30,
        Paint()..color = themeColor.withOpacity(0.2),
      );
      canvas.drawCircle(
        Offset(hoverX!, centerY),
        30,
        Paint()
          ..color = themeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Calculate hovered value
      double pct = (hoverX! - padding) / innerWidth;
      double hoverVal = start + pct * range;
      String tooltipText = hoverVal.toStringAsFixed(precision + 1);
      final tooltipPainter = TextPainter(
        text: TextSpan(
          text: tooltipText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tooltipPainter.layout();
      tooltipPainter.paint(
        canvas,
        Offset(hoverX! - tooltipPainter.width / 2, centerY - 50),
      );
    }
  }

  @override
  bool shouldRepaint(covariant NumberLinePainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.hoverX != hoverX ||
        oldDelegate.targetValue != targetValue;
  }
}