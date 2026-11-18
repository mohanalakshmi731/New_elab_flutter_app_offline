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
const String _errorUrl = 'audio/class9/error.mp3'; 
const String _alertUrl = 'audio/class9/alert.mp3';
const String _shutterUrl = 'audio/class9/shutter.mp3';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuadraticCommanderApp());
}

// --- APP THEME ---
class AppTheme {
  static const Color bg = Color(0xFF020617);
  static const Color surface = Color(0xFF0F172A);
  static const Color text = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF94A3B8);
  static const Color accent = Color(0xFFF59E0B); // Amber
  static const Color primary = Color(0xFF3B82F6); // Blue
  static const Color secondary = Color(0xFF10B981); // Emerald
  static const Color success = Color(0xFF4ADE80);
  static const Color error = Color(0xFFEF4444);
  static const Color gridLine = Color(0xFF1E293B);
  static const Color gridAxis = Color(0xFFF8FAFC);
}

// --- GAME DATA MODELS ---
class LevelData {
  final String titleKey;
  final String descKey;
  final List<Offset> targets;

  const LevelData(this.titleKey, this.descKey, this.targets);
}

// --- LOCALIZATION ---
final Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': "QUADRATIC COMMANDER",
    'tagline': "MASTER THE PARABOLA",
    'init_btn': "START MISSION",
    'header_subtitle': "Class 10 • ALGEBRA - Quadratic Equations",
    'mission_obj_lbl': 'MISSION OBJECTIVE',
    'mission_simple': 'Adjust the A, B, and C parameters of the quadratic equation y = ax² + bx + c to make the parabola intersect all active targets.',
    'lab_mission_header': "MISSION PROGRESS",
    'target_label': "TARGETS ACQUIRED",
    'btn_test': "TEST TRAJECTORY",
    'btn_restart': "Replay Mission",
    'msg_awesome': "TRAJECTORY CONFIRMED!",
    'err_incorrect': "Targets Missed. Adjust Parameters!",
    'mouse_hint': "Drag to pan. Pinch to zoom. Use sliders to alter the parabola.",
    'modal_title': "GALAXY SECURED",
    'out_1_d': "You have mastered the Quadratic curves! Mission Complete.",
    'lbl_equation': "CURRENT EQUATION",
    'lbl_param_a': "A (Width & Direction)",
    'lbl_param_b': "B (Horizontal Shift)",
    'lbl_param_c': "C (Vertical Shift)",
    'lbl_level': "LEVEL",
    'lbl_lvl': "LVL",
    
    'lvl_1_t': "Basic U-Curve",
    'lvl_1_d': "Create a standard parabola opening upwards.",
    'lvl_2_t': "Inverted Arch",
    'lvl_2_d': "Flip the curve. Make 'A' negative to open downwards.",
    'lvl_3_t': "Y-Intercept Shift",
    'lvl_3_d': "Use the 'C' parameter to shift the parabola vertically.",
    'lvl_4_t': "Horizontal Translation",
    'lvl_4_d': "Balance 'B' and 'A' to shift the vertex horizontally.",
  },
  'hi': {
    'app_title': "द्विघात कमांडर",
    'tagline': "परवलय (PARABOLA) में महारत हासिल करें",
    'init_btn': "मिशन शुरू करें",
    'header_subtitle': "कक्षा 10 • बीजगणित - द्विघात समीकरण",
    'mission_obj_lbl': 'मिशन का उद्देश्य',
    'mission_simple': 'परवलय को सभी लक्ष्यों से गुजारने के लिए y = ax² + bx + c के A, B और C मापदंडों को समायोजित करें।',
    'lab_mission_header': "मिशन की प्रगति",
    'target_label': "लक्ष्य प्राप्त हुए",
    'btn_test': "प्रक्षेपवक्र परीक्षण",
    'btn_restart': "फिर से खेलें",
    'msg_awesome': "प्रक्षेपवक्र की पुष्टि!",
    'err_incorrect': "लक्ष्य चूक गए। मापदंडों को बदलें!",
    'mouse_hint': "पैन करने के लिए खींचें। ज़ूम करने के लिए पिंच करें। वक्र बदलने के लिए स्लाइडर का उपयोग करें।",
    'modal_title': "आकाशगंगा सुरक्षित",
    'out_1_d': "आपने द्विघात वक्रों में महारत हासिल कर ली है! मिशन पूरा हुआ।",
    'lbl_equation': "वर्तमान समीकरण",
    'lbl_param_a': "A (चौड़ाई और दिशा)",
    'lbl_param_b': "B (क्षैतिज बदलाव)",
    'lbl_param_c': "C (लंबवत बदलाव)",
    'lbl_level': "स्तर",
    'lbl_lvl': "स्तर",

    'lvl_1_t': "बेसिक यू-वक्र",
    'lvl_1_d': "ऊपर की ओर खुलने वाला एक मानक परवलय बनाएं।",
    'lvl_2_t': "उल्टा आर्च",
    'lvl_2_d': "वक्र को पलटें। नीचे की ओर खोलने के लिए 'A' को ऋणात्मक बनाएं।",
    'lvl_3_t': "Y-इंटरसेप्ट शिफ्ट",
    'lvl_3_d': "परवलय को लंबवत रूप से स्थानांतरित करने के लिए 'C' का उपयोग करें।",
    'lvl_4_t': "क्षैतिज अनुवाद",
    'lvl_4_d': "शीर्ष को क्षैतिज रूप से स्थानांतरित करने के लिए 'B' और 'A' को संतुलित करें।",
  },
};

class QuadraticCommanderApp extends StatefulWidget {
  const QuadraticCommanderApp({super.key});

  @override
  State<QuadraticCommanderApp> createState() => _QuadraticCommanderAppState();
}

class _QuadraticCommanderAppState extends State<QuadraticCommanderApp>
    with TickerProviderStateMixin {
  
  bool _showShutter = true;
  bool _sidebarOpen = true;
  bool missionComplete = false;
  String currentLang = 'en';

  // Equation State
  double valA = 1.0;
  double valB = 0.0;
  double valC = 0.0;

  // View State
  Offset _panOffset = Offset.zero;
  double _zoomScale = 1.0;
  double _previousZoom = 1.0;

  int currentLevelIndex = 0;
  
  final List<LevelData> levels = const [
    LevelData('lvl_1_t', 'lvl_1_d', [Offset(0, 0), Offset(2, 4), Offset(-2, 4)]),
    LevelData('lvl_2_t', 'lvl_2_d', [Offset(0, 4), Offset(2, 0), Offset(-2, 0)]),
    LevelData('lvl_3_t', 'lvl_3_d', [Offset(0, -3), Offset(3, 6), Offset(-3, 6)]),
    LevelData('lvl_4_t', 'lvl_4_d', [Offset(3, -1), Offset(1, 3), Offset(5, 3)]),
  ];

  String? _bannerMessage;
  String? _bannerType;

  late AnimationController _pulseController;
  late AnimationController _celebrationController;
  final ScrollController _hudScrollController = ScrollController(); // Used for the visible HUD scrollbar

  // Dedicated audio players initialized inside state to prevent disposal bugs
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

    // Initialize audio players inside initState to ensure they survive hot reloads properly
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

    // Safely dispose audio engines
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

  void _testTrajectory() {
    if (missionComplete || currentLevelIndex >= levels.length || _showShutter) return;

    LevelData level = levels[currentLevelIndex];
    bool success = true;

    // Check if the current equation y = Ax^2 + Bx + C passes through all targets
    for (Offset target in level.targets) {
      double expectedY = (valA * target.dx * target.dx) + (valB * target.dx) + valC;
      if ((expectedY - target.dy).abs() > 0.3) { // Tolerance threshold
        success = false;
        break;
      }
    }

    if (success) {
      HapticFeedback.heavyImpact();
      _playSound(_successPlayer, _successUrl);
      _showBanner('success', t('msg_awesome'));

      if (currentLevelIndex < levels.length - 1) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              currentLevelIndex++;
              // Reset values for next level challenge
              valA = 1.0; valB = 0.0; valC = 0.0;
            });
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _playSound(_fxPlayer, _alertUrl); 
            setState(() {
              missionComplete = true;
              _celebrationController.forward();
            });
          }
        });
      }
    } else {
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
      _showBanner('error', t('err_incorrect'));
    }
  }

  void hardReset() {
    setState(() {
      currentLevelIndex = 0;
      missionComplete = false;
      valA = 1.0; valB = 0.0; valC = 0.0;
      _panOffset = Offset.zero;
      _zoomScale = 1.0;
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
        setState(() => _bannerMessage = null);
      }
    });
  }

  String _getEquationString() {
    String eq = "y = ";
    if (valA != 0) eq += "${valA.toStringAsFixed(1)}x² ";
    if (valB > 0) eq += "+ ${valB.toStringAsFixed(1)}x ";
    if (valB < 0) eq += "- ${valB.abs().toStringAsFixed(1)}x ";
    if (valC > 0) eq += "+ ${valC.toStringAsFixed(1)}";
    if (valC < 0) eq += "- ${valC.abs().toStringAsFixed(1)}";
    if (valA == 0 && valB == 0 && valC == 0) eq += "0";
    return eq;
  }

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
                        child: _buildSidebarContent(),
                      ),
                    ),
                  ),
                ),

                // Main Workspace
                Expanded(
                  child: ClipRect(
                    child: _buildMainWorkspace()
                  )
                ),
              ],
            ),

            // Left-Aligned Docked HUD (38% width) - Rendered BEFORE the menu button so it doesn't cover it
            if (!_sidebarOpen && !_showShutter && !missionComplete)
              _buildFloatingHUD(screenW),

            // Top Left Menu Button - Moved to the end of the stack to ensure it always floats ON TOP
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
            if (_showShutter) _buildCurtain(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarContent() {
    // Unpinned the footer by making the entire sidebar content part of a single scrollable view
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 24.0),
      physics: const BouncingScrollPhysics(),
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
                  tooltip: 'Reset System',
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

          _buildLabContent(),

          const SizedBox(height: 40), // Spacer before footer
          
          // Unpinned Footer placed at the bottom of the scroll view
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
            color: active ? AppTheme.bg : Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLabContent() {
    if (missionComplete) return const SizedBox.shrink();
    LevelData level = levels[currentLevelIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Objective Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('mission_obj_lbl'), style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(t('mission_simple'), style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Level Progress Status Box
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
                    t('lab_mission_header'),
                    style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  Text(
                    '${t('lbl_level')} ${currentLevelIndex + 1}/${levels.length}',
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

        // Controls Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t(level.titleKey), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              const SizedBox(height: 8),
              Text(t(level.descKey), style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic)),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white10)),
              
              // Equation Display
              Center(
                child: Text(
                  _getEquationString(),
                  style: const TextStyle(color: AppTheme.secondary, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 24),

              // Sliders with limits from -10 to 10 to ensure Level 4 is playable
              _buildSliderRow(t('lbl_param_a'), valA, -10, 10, (v) => setState(() => valA = v)),
              _buildSliderRow(t('lbl_param_b'), valB, -10, 10, (v) => setState(() => valB = v)),
              _buildSliderRow(t('lbl_param_c'), valC, -10, 10, (v) => setState(() => valC = v)),
              
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  foregroundColor: AppTheme.bg,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _testTrajectory,
                icon: const Icon(Icons.rocket_launch),
                label: Text(t('btn_test'), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.accent,
              inactiveTrackColor: Colors.white10,
              thumbColor: AppTheme.accent,
              overlayColor: AppTheme.accent.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) * 2).toInt(), // Snap to 0.5 increments
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHUD(double screenW) {
    LevelData level = levels[currentLevelIndex];
    // Exact 38% width
    double hudWidth = screenW * 0.38;

    return Positioned(
      bottom: 20, 
      left: 20, // LEFT side exactly as requested
      child: Container(
        width: hudWidth,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 8), // Right padding reduced to accommodate scrollbar
        decoration: BoxDecoration(
          color: Colors.black87.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: const Border(left: BorderSide(color: AppTheme.success, width: 4)),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
        ),
        // Wrapped with a highly visible scrollbar
        child: RawScrollbar(
          controller: _hudScrollController,
          thumbColor: AppTheme.accent.withOpacity(0.8),
          radius: const Radius.circular(4),
          thickness: 4,
          thumbVisibility: true,
          child: SingleChildScrollView( 
            controller: _hudScrollController,
            padding: const EdgeInsets.only(right: 8.0), // Inner padding so thumb doesn't overlap text
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t('lbl_equation'), style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text('${t('lbl_lvl')} ${currentLevelIndex + 1}/${levels.length}', style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _getEquationString(),
                    style: const TextStyle(color: AppTheme.secondary, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(t(level.descKey), style: const TextStyle(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic)),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10)),
                
                // Scrollable parameters included directly in the HUD
                _buildSliderRow(t('lbl_param_a'), valA, -10, 10, (v) => setState(() => valA = v)),
                _buildSliderRow(t('lbl_param_b'), valB, -10, 10, (v) => setState(() => valB = v)),
                _buildSliderRow(t('lbl_param_c'), valC, -10, 10, (v) => setState(() => valC = v)),
                
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: AppTheme.bg,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _testTrajectory,
                  icon: const Icon(Icons.rocket_launch, size: 18),
                  label: Text(t('btn_test'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainWorkspace() {
    LevelData? currentLevel = currentLevelIndex < levels.length ? levels[currentLevelIndex] : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF020617)],
                  center: Alignment.center,
                  radius: 1.0,
                ),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: (details) {
                  _previousZoom = _zoomScale;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    _zoomScale = (_previousZoom * details.scale).clamp(0.5, 4.0);
                    _panOffset += details.focalPointDelta;
                    _panOffset = Offset(
                      _panOffset.dx.clamp(-constraints.maxWidth * 2, constraints.maxWidth * 2),
                      _panOffset.dy.clamp(-constraints.maxHeight * 2, constraints.maxHeight * 2),
                    );
                  });
                },
                child: Stack(
                  children: [
                    // Grid & Axes
                    CustomPaint(
                      size: Size.infinite,
                      painter: CartesianGridPainter(
                        panOffset: _panOffset,
                        zoomScale: _zoomScale,
                      ),
                    ),
                    
                    // Parabola Curve
                    if (!missionComplete)
                      CustomPaint(
                        size: Size.infinite,
                        painter: ParabolaPainter(
                          valA: valA,
                          valB: valB,
                          valC: valC,
                          panOffset: _panOffset,
                          zoomScale: _zoomScale,
                          curveColor: AppTheme.secondary,
                        ),
                      ),

                    // Targets
                    if (currentLevel != null && !missionComplete)
                      CustomPaint(
                        size: Size.infinite,
                        painter: TargetPainter(
                          targets: currentLevel.targets,
                          panOffset: _panOffset,
                          zoomScale: _zoomScale,
                          pulse: _pulseController.value,
                          targetColor: AppTheme.accent,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Recenter Button
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                heroTag: 'recenter_btn',
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.white24)),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() { _panOffset = Offset.zero; _zoomScale = 1.0; });
                },
                child: const Icon(Icons.center_focus_strong, size: 20),
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
      top: _bannerMessage != null ? 30 : -100, // Drop from top
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
                    const Icon(Icons.rocket_launch, color: AppTheme.success, size: 80),
                    const SizedBox(height: 24),
                    Text(t('modal_title'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                    const SizedBox(height: 16),
                    Text(t('out_1_d'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)),
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

  Widget _buildCurtain() {
    return Container(
      color: AppTheme.bg,
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
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.accent.withOpacity(0.2)),
                  ),
                ),
                const Icon(Icons.polyline, size: 80, color: AppTheme.accent),
              ],
            ),
            const SizedBox(height: 20),
            Text(t('app_title'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2, shadows: [Shadow(color: AppTheme.accent, blurRadius: 15)])),
            const SizedBox(height: 10),
            Text(t('tagline'), style: const TextStyle(fontSize: 16, letterSpacing: 4, color: AppTheme.secondary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                _playSound(_shutterPlayer, _shutterUrl);
                setState(() => _showShutter = false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.bg,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 10,
                shadowColor: AppTheme.accent.withOpacity(0.5),
              ),
              child: Text(t('init_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTERS ---

class CartesianGridPainter extends CustomPainter {
  final Offset panOffset;
  final double zoomScale;

  CartesianGridPainter({required this.panOffset, required this.zoomScale});

  @override
  void paint(Canvas canvas, Size size) {
    double gridSize = math.min(size.width, size.height);
    double unitSize = (gridSize / 12) * zoomScale; 
    Offset center = Offset(size.width / 2, size.height / 2) + panOffset;

    final Paint gridPaint = Paint()..color = AppTheme.gridLine..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final Paint axisPaint = Paint()..color = AppTheme.gridAxis.withOpacity(0.8)..strokeWidth = 3..style = PaintingStyle.stroke;

    double gridLimit = 15.0 * unitSize; // Extended limit to draw more lines

    for (int i = -15; i <= 15; i++) {
      double offset = i * unitSize;
      canvas.drawLine(Offset(center.dx - gridLimit, center.dy + offset), Offset(center.dx + gridLimit, center.dy + offset), i == 0 ? axisPaint : gridPaint); // Horiz
      canvas.drawLine(Offset(center.dx + offset, center.dy - gridLimit), Offset(center.dx + offset, center.dy + gridLimit), i == 0 ? axisPaint : gridPaint); // Vert
    }

    TextStyle textStyle = const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold);

    for (int i = -15; i <= 15; i++) {
      if (i == 0) continue;
      double offset = i * unitSize;
      _drawText(canvas, '$i', Offset(center.dx + offset, center.dy + 14), textStyle);
      _drawText(canvas, '${-i}', Offset(center.dx - 18, center.dy + offset), textStyle);
    }
    _drawText(canvas, '0', Offset(center.dx - 14, center.dy + 14), textStyle);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final textPainter = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr, textAlign: TextAlign.center)..layout();
    textPainter.paint(canvas, Offset(offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CartesianGridPainter oldDelegate) => oldDelegate.panOffset != panOffset || oldDelegate.zoomScale != zoomScale;
}

class ParabolaPainter extends CustomPainter {
  final double valA;
  final double valB;
  final double valC;
  final Offset panOffset;
  final double zoomScale;
  final Color curveColor;

  ParabolaPainter({
    required this.valA,
    required this.valB,
    required this.valC,
    required this.panOffset,
    required this.zoomScale,
    required this.curveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double gridSize = math.min(size.width, size.height);
    double unitSize = (gridSize / 12) * zoomScale; 
    Offset center = Offset(size.width / 2, size.height / 2) + panOffset;

    final Paint curvePaint = Paint()
      ..color = curveColor
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    final Paint glowPaint = Paint()
      ..color = curveColor.withOpacity(0.5)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    Path path = Path();
    bool started = false;

    // Draw from x = -15 to x = 15 to ensure the line spans wide enough
    for (double x = -15.0; x <= 15.0; x += 0.1) {
      double y = (valA * x * x) + (valB * x) + valC;
      
      // Stop rendering if it shoots wildly off the bounds vertically
      if (y < -25 || y > 25) {
        started = false;
        continue;
      }

      double screenX = center.dx + (x * unitSize);
      double screenY = center.dy - (y * unitSize);

      if (!started) {
        path.moveTo(screenX, screenY);
        started = true;
      } else {
        path.lineTo(screenX, screenY);
      }
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, curvePaint);
  }

  @override
  bool shouldRepaint(covariant ParabolaPainter oldDelegate) {
    return oldDelegate.valA != valA || oldDelegate.valB != valB || oldDelegate.valC != valC ||
           oldDelegate.panOffset != panOffset || oldDelegate.zoomScale != zoomScale;
  }
}

class TargetPainter extends CustomPainter {
  final List<Offset> targets;
  final Offset panOffset;
  final double zoomScale;
  final double pulse;
  final Color targetColor;

  TargetPainter({
    required this.targets,
    required this.panOffset,
    required this.zoomScale,
    required this.pulse,
    required this.targetColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double gridSize = math.min(size.width, size.height);
    double unitSize = (gridSize / 12) * zoomScale; 
    Offset center = Offset(size.width / 2, size.height / 2) + panOffset;

    for (Offset target in targets) {
       double tx = center.dx + (target.dx * unitSize);
       double ty = center.dy - (target.dy * unitSize);

       final hintPaint = Paint()..color = targetColor.withOpacity(0.2 + pulse * 0.3)..style = PaintingStyle.fill;
       final hintBorder = Paint()..color = targetColor..style = PaintingStyle.stroke..strokeWidth = 2;
       final core = Paint()..color = Colors.white..style = PaintingStyle.fill;

       canvas.drawCircle(Offset(tx, ty), 16 + (pulse * 8), hintPaint);
       canvas.drawCircle(Offset(tx, ty), 12, hintBorder);
       canvas.drawCircle(Offset(tx, ty), 4, core);
    }
  }

  @override
  bool shouldRepaint(covariant TargetPainter oldDelegate) {
    return oldDelegate.targets != targets || oldDelegate.panOffset != panOffset ||
           oldDelegate.zoomScale != zoomScale || oldDelegate.pulse != pulse;
  }
}