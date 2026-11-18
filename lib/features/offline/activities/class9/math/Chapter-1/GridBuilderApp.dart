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
  runApp(const GridBuilderApp());
}

class GridBuilderApp extends StatelessWidget {
  const GridBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galactic Grid Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0518),
        fontFamily: 'monospace',
      ),
      home: const GridBuilderScreen(),
    );
  }
}

// --- GAME DATA MODELS ---
class AppColors {
  static const Color bg = Color(0xFF0F0518);
  static const Color panel = Color(0xFF140A28); // Made solid for sidebar
  static const Color text = Color(0xFFF8FAFC);
  static const Color accent = Color(0xFFD946EF); // Fuchsia
  static const Color primary = Color(0xFF8B5CF6); // Violet
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color success = Color(0xFF4ADE80); // Green
  static const Color error = Color(0xFFF43F5E); // Red
}

class LevelData {
  final int id;
  final int targetX;
  final int targetY;

  const LevelData(this.id, this.targetX, this.targetY);
}

class LogEntry {
  final String message;
  final bool isSuccess;
  LogEntry(this.message, this.isSuccess);
}

// --- LOCALIZATION DICTIONARY ---
const Map<String, Map<String, String>> i18n = {
  'en': {
    'curtain_title': "GALACTIC GRID QUEST",
    'curtain_tagline': "YOUR MISSION: MAP THE UNIVERSE!",
    'init_btn': "START MISSION! 🚀",
    'app_title': "GRID BUILDER",
    'header_subtitle': "CLASS 9 • COORDINATE GEOMETRY",
    'nav_guide': "Teacher's Guide",
    'nav_lab': "Explore Lab",
    'guide_title': "Mission Briefing",
    'btn_start_lab': "Launch Simulation",
    'gd_intro': "This virtual lab helps students visualize the Cartesian plane, understand signs in different quadrants, and practice plotting points.",
    'gd_activity_title': "Activity Overview",
    'gd_activity_desc': "In 'Galactic Grid Quest', students take on the role of a Space Navigator. The goal is to demystify Coordinate Geometry by treating it as a navigation system. Instead of abstract numbers, coordinates become instructions for movement in space.",
    'gd_workflow_title': "Activity Workflow",
    'gd_wf_1': "Level 1 (The Origin): Establishes (0,0) as the reference point 'Command Center'. Crucial for understanding that all measurement starts here.",
    'gd_wf_2': "Level 2 (X-Axis): Focuses purely on horizontal movement (Abscissa). Helps students isolate the 'x' value effect.",
    'gd_wf_3': "Level 3 (Y-Axis): Focuses purely on vertical movement (Ordinate). Helps students isolate the 'y' value effect.",
    'gd_wf_4': "Level 4 (Quadrant I): Combines X and Y. Students navigate to a point where both values are positive.",
    'gd_wf_5': "Level 5 (Quadrant III): Introduces negative integers. Students must navigate left and down to find the target.",
    'lab_status_header': "MISSION CONTROL",
    'btn_reset': "Reset System",
    'task_label': "Current Objective",
    'checklist_title': "Mission Checklist",
    'lbl_purpose': "Purpose:",
    'lbl_goal': "Goal:",
    'lbl_sys_log': "System Log",
    'lbl_complete': "Complete",
    'modal_title': "Mission Accomplished!",
    'modal_desc': "You have successfully mapped the galaxy. Coordinates verified.",
    'btn_restart': "Restart Mission",
    'msg_awesome': "EXCELLENT PLACEMENT!",
    'msg_try_again': "Check Coordinates!",
    'log_success': "Unit deployed at {coords} - SUCCESS",
    'log_failure': "Deployment failed at {coords}. Target missed.",
    'log_reset': "System Rebooted.",
    
    // Level specific keys
    'lvl_1_title': "Initialize System",
    'lvl_1_desc': "Locate the absolute center of the grid.",
    'lvl_1_instr': "Tap on the Origin point (0,0).",
    'lvl_1_purpose': "Establish the reference point (Origin) for the entire coordinate system.",
    'lvl_1_action': "Identify intersection of X and Y axes (0,0).",
    'lvl_2_title': "Axis Deployment",
    'lvl_2_desc': "Deploy scout units on the main axes.",
    'lvl_2_instr': "Deploy a unit at (3, 0) on the X-axis.",
    'lvl_2_purpose': "Understand movement along the horizontal X-axis.",
    'lvl_2_action': "Locate positive 3 on the horizontal line, keeping Y at 0.",
    'lvl_3_title': "Vertical Alignment",
    'lvl_3_desc': "Secure the vertical perimeter.",
    'lvl_3_instr': "Deploy a unit at (0, 4) on the Y-axis.",
    'lvl_3_purpose': "Understand movement along the vertical Y-axis.",
    'lvl_3_action': "Locate positive 4 on the vertical line, keeping X at 0.",
    'lvl_4_title': "Quadrant I",
    'lvl_4_desc': "Establish a base in the positive sector.",
    'lvl_4_instr': "Deploy Base Alpha at (2, 3).",
    'lvl_4_purpose': "Practice plotting in Quadrant I (+,+).",
    'lvl_4_action': "Move right 2 units, then up 3 units.",
    'lvl_5_title': "Quadrant III",
    'lvl_5_desc': "Explore the negative sector.",
    'lvl_5_instr': "Deploy Base Beta at (-3, -2).",
    'lvl_5_purpose': "Practice plotting in Quadrant III (-,-).",
    'lvl_5_action': "Move left 3 units, then down 2 units.",
    
    'quad_1': 'QUADRANT I',
    'quad_2': 'QUADRANT II',
    'quad_3': 'QUADRANT III',
    'quad_4': 'QUADRANT IV',
    'hud_coord': 'GRID COORDS',
  },
  'hi': {
    'curtain_title': "गेलेक्टिक ग्रिड क्वेस्ट",
    'curtain_tagline': "आपका मिशन: ब्रह्मांड का नक्शा बनाएं!",
    'init_btn': "मिशन शुरू करें! 🚀",
    'app_title': "ग्रिड बिल्डर",
    'header_subtitle': "कक्षा 9 • निर्देशांक ज्यामिति",
    'nav_guide': "शिक्षक गाइड",
    'nav_lab': "प्रयोगशाला",
    'guide_title': "मिशन ब्रीफिंग",
    'btn_start_lab': "सिमुलेशन शुरू करें",
    'gd_intro': "यह वर्चुअल लैब छात्रों को कार्तीय तल की कल्पना करने और विभिन्न चतुर्थांशों में संकेतों को समझने में मदद करती है।",
    'gd_activity_title': "गतिविधि अवलोकन",
    'gd_activity_desc': "'गेलेक्टिक ग्रिड क्वेस्ट' में, छात्र एक स्पेस नेविगेटर की भूमिका निभाते हैं। लक्ष्य नेविगेशन सिस्टम के रूप में निर्देशांक ज्यामिति को समझना है।",
    'gd_workflow_title': "गतिविधि कार्यप्रवाह",
    'gd_wf_1': "स्तर 1 (मूल बिंदु): (0,0) को संदर्भ बिंदु 'कमांड सेंटर' के रूप में स्थापित करता है।",
    'gd_wf_2': "स्तर 2 (X-अक्ष): पूरी तरह से क्षैतिज गति (भुज) पर केंद्रित है।",
    'gd_wf_3': "स्तर 3 (Y-अक्ष): पूरी तरह से लंबवत गति (कोटि) पर केंद्रित है।",
    'gd_wf_4': "स्तर 4 (चतुर्थांश I): X और Y को जोड़ता है। दोनों धनात्मक होते हैं।",
    'gd_wf_5': "स्तर 5 (चतुर्थांश III): ऋणात्मक पूर्णांकों का परिचय देता है।",
    'lab_status_header': "मिशन नियंत्रण",
    'btn_reset': "रीसेट करें",
    'task_label': "वर्तमान उद्देश्य",
    'checklist_title': "मिशन चेकलिस्ट",
    'lbl_purpose': "उद्देश्य:",
    'lbl_goal': "लक्ष्य:",
    'lbl_sys_log': "सिस्टम लॉग",
    'lbl_complete': "पूर्ण",
    'modal_title': "मिशन पूरा हुआ!",
    'modal_desc': "आपने आकाशगंगा का सफलतापूर्वक मानचित्रण कर लिया है।",
    'btn_restart': "पुनः आरंभ करें",
    'msg_awesome': "बहुत बढ़िया!",
    'msg_try_again': "निर्देशांक जांचें!",
    'log_success': "यूनिट {coords} पर तैनात - सफल",
    'log_failure': "{coords} पर तैनाती विफल। लक्ष्य चूक गया।",
    'log_reset': "सिस्टम रीसेट।",
    
    'lvl_1_title': "सिस्टम आरंभ करें",
    'lvl_1_desc': "ग्रिड के पूर्ण केंद्र का पता लगाएं।",
    'lvl_1_instr': "मूल बिंदु (0,0) पर टैप करें।",
    'lvl_1_purpose': "संदर्भ बिंदु (मूल) स्थापित करें।",
    'lvl_1_action': "X और Y अक्षों के प्रतिच्छेदन (0,0) की पहचान करें।",
    'lvl_2_title': "अक्ष तैनाती",
    'lvl_2_desc': "मुख्य अक्षों पर स्काउट इकाइयों को तैनात करें।",
    'lvl_2_instr': "X-अक्ष पर (3, 0) पर एक इकाई तैनात करें।",
    'lvl_2_purpose': "क्षैतिज X-अक्ष के साथ गति को समझें।",
    'lvl_2_action': "क्षैतिज रेखा पर धनात्मक 3 का पता लगाएं।",
    'lvl_3_title': "लंबवत संरेखण",
    'lvl_3_desc': "लंबवत परिधि को सुरक्षित करें।",
    'lvl_3_instr': "Y-अक्ष पर (0, 4) पर एक इकाई तैनात करें।",
    'lvl_3_purpose': "लंबवत Y-अक्ष के साथ गति को समझें।",
    'lvl_3_action': "लंबवत रेखा पर धनात्मक 4 का पता लगाएं।",
    'lvl_4_title': "प्रथम चतुर्थांश",
    'lvl_4_desc': "सकारात्मक क्षेत्र में एक आधार स्थापित करें।",
    'lvl_4_instr': "बेस अल्फा को (2, 3) पर तैनात करें।",
    'lvl_4_purpose': "चतुर्थांश I (+,+) में प्लॉट करें।",
    'lvl_4_action': "2 इकाई दाएं, फिर 3 इकाई ऊपर जाएं।",
    'lvl_5_title': "तृतीय चतुर्थांश",
    'lvl_5_desc': "नकारात्मक क्षेत्र का अन्वेषण करें।",
    'lvl_5_instr': "बेस बीटा को (-3, -2) पर तैनात करें।",
    'lvl_5_purpose': "चतुर्थांश III (-,-) में प्लॉट करें।",
    'lvl_5_action': "3 इकाई बाएं, फिर 2 इकाई नीचे जाएं।",
    
    'quad_1': 'चतुर्थांश I',
    'quad_2': 'चतुर्थांश II',
    'quad_3': 'चतुर्थांश III',
    'quad_4': 'चतुर्थांश IV',
    'hud_coord': 'ग्रिड निर्देशांक',
  },
};

// --- MAIN APP WIDGET ---
class GridBuilderScreen extends StatefulWidget {
  const GridBuilderScreen({super.key});

  @override
  State<GridBuilderScreen> createState() => _GridBuilderScreenState();
}

class _GridBuilderScreenState extends State<GridBuilderScreen>
    with TickerProviderStateMixin {
  // App State
  String _currentLang = 'en';
  bool _sidebarOpen = true;
  bool _showShutter = true;

  // Game State
  int _currentLevelIndex = 0;
  bool _missionComplete = false;
  final List<Offset> _placedMarkers = []; 
  final List<LogEntry> _logs = [];

  // Coordinates, Panning, and Zooming
  Offset _panOffset = Offset.zero; 
  double _zoomScale = 1.0;
  double _previousZoom = 1.0;
  
  // Overlay
  String? _bannerMessage;
  String? _bannerType;
  late AnimationController _pulseController;

  // Levels
  final List<LevelData> levels = const [
    LevelData(1, 0, 0),
    LevelData(2, 3, 0),
    LevelData(3, 0, 4),
    LevelData(4, 2, 3),
    LevelData(5, -3, -2),
  ];

  String t(String key) => i18n[_currentLang]?[key] ?? key;
  LevelData get currentLevel => levels[_currentLevelIndex];

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
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    _pulseController.dispose();
    
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _shutterPlayer.dispose();
    
    super.dispose();
  }

  // --- GAME LOGIC ---
  void _addLog(
    String key, {
    Map<String, String>? params,
    bool isSuccess = true,
  }) {
    String msg = t(key);
    if (params != null) {
      params.forEach((k, v) {
        msg = msg.replaceAll('{$k}', v);
      });
    }
    setState(() {
      _logs.insert(0, LogEntry("> $msg", isSuccess));
      if (_logs.length > 25) _logs.removeLast();
    });
  }

  void _hardReset() {
    setState(() {
      _currentLevelIndex = 0;
      _missionComplete = false;
      _placedMarkers.clear();
      _logs.clear();
      _panOffset = Offset.zero;
      _zoomScale = 1.0;
      _bannerMessage = null;
      _addLog('log_reset', isSuccess: true);
    });
  }

  void _handleGridTap(int gridX, int gridY) {
    if (_missionComplete || _currentLevelIndex >= levels.length || _showShutter) return;

    final target = levels[_currentLevelIndex];
    if (gridX == target.targetX && gridY == target.targetY) {
      // Success
      HapticFeedback.heavyImpact();
      _playSound(_successPlayer, _successUrl);
      _showBanner('success', t('msg_awesome'));
      _addLog(
        'log_success',
        params: {'coords': '($gridX, $gridY)'},
        isSuccess: true,
      );

      setState(() {
        _placedMarkers.add(Offset(gridX.toDouble(), gridY.toDouble()));
      });

      if (_currentLevelIndex < levels.length - 1) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _currentLevelIndex++);
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _playSound(_fxPlayer, _alertUrl); // Mission complete sound
            setState(() {
              _missionComplete = true;
            });
          }
        });
      }
    } else {
      // Failure
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
      _showBanner('error', t('msg_try_again'));
      _addLog(
        'log_failure',
        params: {'coords': '($gridX, $gridY)'},
        isSuccess: false,
      );
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
    double sidebarWidth = screenW * 0.38; // Locked 38% sidebar

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
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
                    color: AppColors.panel,
                    border: Border(right: BorderSide(color: AppColors.accent.withOpacity(0.2))),
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
            if (_missionComplete && !_showShutter) _buildFinalCompleteModal(),
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
            t('header_subtitle'),
            style: const TextStyle(
              color: AppColors.primary,
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
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Row(children: [_langBtn('en', 'EN'), _langBtn('hi', 'HI')]),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.error.withOpacity(0.6), width: 2.0),
                ),
                child: IconButton(
                  icon: const Icon(Icons.power_settings_new, color: AppColors.error),
                  tooltip: t('btn_reset'),
                  onPressed: () {
                    HapticFeedback.vibrate();
                    _playSound(_clickPlayer, _clickUrl);
                    setState(() {
                      _showShutter = true;
                    });
                    _hardReset();
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
          color: active ? AppColors.accent : Colors.transparent,
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
    if (_missionComplete) return const SizedBox.shrink();

    LevelData? curLevelData = levels.isNotEmpty && _currentLevelIndex < levels.length
        ? levels[_currentLevelIndex]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    'LEVEL ${_currentLevelIndex + 1}/${levels.length}',
                    style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentLevelIndex + 1) / levels.length,
                backgroundColor: Colors.white10,
                color: AppColors.accent,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Mission Objective Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.my_location, color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    t('task_label').toUpperCase(),
                    style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (curLevelData != null) ...[
                Text(
                  t('lvl_${curLevelData.id}_title'),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 8),
                Text(
                  t('lvl_${curLevelData.id}_instr'),
                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // System Logs
        Container(
          height: 180, // Fixed height area inside scrollable sidebar
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black45,
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
                    t('lbl_sys_log').toUpperCase(),
                    style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1, fontFamily: 'monospace'),
                  ),
                  const Text(
                    'LIVE',
                    style: TextStyle(color: Colors.green, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        log.message,
                        style: TextStyle(
                          color: log.isSuccess ? AppColors.success : AppColors.error,
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

  Widget _buildMainWorkspace() {
    if (_missionComplete) {
      return _buildFinalCompleteModal();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF140A28), Color(0xFF0F0518)],
                  center: Alignment.center,
                  radius: 1.0,
                ),
              ),
            ),

            // Draggable & Zoomable Area for Graph & Markers
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: (details) {
                  _previousZoom = _zoomScale;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    _zoomScale = (_previousZoom * details.scale).clamp(0.5, 4.0);
                    _panOffset += details.focalPointDelta;
                    // Clamp to prevent getting lost in deep space
                    _panOffset = Offset(
                      _panOffset.dx.clamp(-constraints.maxWidth * 2, constraints.maxWidth * 2),
                      _panOffset.dy.clamp(-constraints.maxHeight * 2, constraints.maxHeight * 2),
                    );
                  });
                },
                onTapDown: (details) {
                  // Determine grid size to match painter's scale exactly
                  double scale = (math.min(constraints.maxWidth, constraints.maxHeight) / 22) * _zoomScale;
                  double cx = (constraints.maxWidth / 2) + _panOffset.dx;
                  double cy = (constraints.maxHeight / 2) + _panOffset.dy;

                  // Convert screen offset to logic grid coordinates
                  double logicX = (details.localPosition.dx - cx) / scale;
                  double logicY = (cy - details.localPosition.dy) / scale; // Invert Y

                  int gridX = logicX.round();
                  int gridY = logicY.round();

                  // Tap sensitivity check
                  if ((logicX - gridX).abs() < 0.4 && (logicY - gridY).abs() < 0.4) {
                     if (gridX >= -10 && gridX <= 10 && gridY >= -10 && gridY <= 10) {
                        _handleGridTap(gridX, gridY);
                     }
                  }
                },
                child: Stack(
                  children: [
                    // Interactive Area & Painting
                    CustomPaint(
                      size: Size.infinite,
                      painter: CartesianSpacePainter(
                        gridColor: AppColors.accent.withOpacity(0.1),
                        axisColor: AppColors.success.withOpacity(0.6),
                        panOffset: _panOffset,
                        zoomScale: _zoomScale,
                        quad1: t('quad_1'),
                        quad2: t('quad_2'),
                        quad3: t('quad_3'),
                        quad4: t('quad_4'),
                        accentTheme: AppColors.accent,
                      ),
                    ),

                    // Draw Placed Markers and active Hint
                    CustomPaint(
                      size: Size.infinite,
                      painter: MarkerPainter(
                        placedMarkers: _placedMarkers,
                        currentTarget: _currentLevelIndex < levels.length ? levels[_currentLevelIndex] : null,
                        panOffset: _panOffset,
                        zoomScale: _zoomScale,
                        pulse: _pulseController.value,
                        markerColor: AppColors.accent,
                        targetColor: AppColors.primary,
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
                  setState(() {
                    _panOffset = Offset.zero;
                    _zoomScale = 1.0;
                  });
                },
                child: const Icon(Icons.center_focus_strong, size: 20),
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
                        border: Border(left: const BorderSide(color: AppColors.primary, width: 4)),
                        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Takes only required height natively
                        children: [
                          Text(
                            t('task_label').toUpperCase(),
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 10, letterSpacing: 1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentLevelIndex < levels.length ? t('lvl_${levels[_currentLevelIndex].id}_title') : '',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentLevelIndex < levels.length ? t('lvl_${levels[_currentLevelIndex].id}_instr') : '',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                          ),
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
            color: isSuccess ? AppColors.success.withOpacity(0.9) : AppColors.error.withOpacity(0.9),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: isSuccess ? Colors.greenAccent : Colors.redAccent),
            boxShadow: [
              BoxShadow(color: isSuccess ? AppColors.success.withOpacity(0.5) : AppColors.error.withOpacity(0.5), blurRadius: 30),
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
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 80)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.public, color: AppColors.primary, size: 64),
                  const SizedBox(height: 24),
                  Text(
                    t('modal_title'),
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t('modal_desc'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _playSound(_shutterPlayer, _shutterUrl);
                      setState(() {
                        _showShutter = true;
                      });
                      _hardReset();
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      t('btn_restart'),
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
      color: AppColors.bg,
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
                          border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 3),
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withOpacity(0.3 + (_pulseController.value * 0.4)), blurRadius: 40),
                          ],
                        ),
                        child: const Icon(Icons.rocket_launch, color: AppColors.primary, size: 50),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Text(
                  t('curtain_title'),
                  style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
                ),
                const SizedBox(height: 12),
                Text(
                  t('curtain_tagline'),
                  style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 3, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
                    _hardReset(); // Trigger game start
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    t('init_btn').toUpperCase(),
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

class CartesianSpacePainter extends CustomPainter {
  final Color gridColor;
  final Color axisColor;
  final Offset panOffset;
  final double zoomScale;
  final String quad1;
  final String quad2;
  final String quad3;
  final String quad4;
  final Color accentTheme;

  CartesianSpacePainter({
    required this.gridColor,
    required this.axisColor,
    required this.panOffset,
    required this.zoomScale,
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
    
    // Scale by using the minimum dimension and apply zoom
    final double scale = (math.min(size.width, size.height) / 22) * zoomScale;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 2;

    // Draw the quadrant badges in the background around position 7 to avoid overlaps
    double qOffset = 7.5 * scale;
    _drawQuadrantBadge(canvas, quad1, Offset(cx + qOffset, cy - qOffset)); // Top Right
    _drawQuadrantBadge(canvas, quad2, Offset(cx - qOffset, cy - qOffset)); // Top Left
    _drawQuadrantBadge(canvas, quad3, Offset(cx - qOffset, cy + qOffset)); // Bottom Left
    _drawQuadrantBadge(canvas, quad4, Offset(cx + qOffset, cy + qOffset)); // Bottom Right

    // Bounded strictly to -10 to 10
    double gridLimit = 11.0 * scale; // Extended slightly so labels have margin and aren't cut off
    
    for (int i = -10; i <= 10; i++) {
      double offset = i * scale;
      
      // Draw bounded grid lines so they don't stretch to infinity, making the 10x10 box clear
      canvas.drawLine(Offset(cx - gridLimit, cy + offset), Offset(cx + gridLimit, cy + offset), gridPaint); // Horiz
      canvas.drawLine(Offset(cx + offset, cy - gridLimit), Offset(cx + offset, cy + gridLimit), gridPaint); // Vert
      
      // Draw Coordinate Numbers on Axes
      if (i != 0) {
        // X-axis: Centered under the tick mark
        _drawXText(canvas, '$i', Offset(cx + offset, cy), Colors.white70);
        // Y-axis: Centered left of the tick mark. Note screen Y increases downwards.
        _drawYText(canvas, '${-i}', Offset(cx, cy + offset), Colors.white70);
      }
    }

    // Axes (also bounded to gridLimit)
    canvas.drawLine(Offset(cx - gridLimit, cy), Offset(cx + gridLimit, cy), axisPaint);
    canvas.drawLine(Offset(cx, cy - gridLimit), Offset(cx, cy + gridLimit), axisPaint);
    _drawXText(canvas, '0', Offset(cx, cy), Colors.white);
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
  bool shouldRepaint(covariant CartesianSpacePainter oldDelegate) {
    return oldDelegate.panOffset != panOffset || 
           oldDelegate.zoomScale != zoomScale || 
           oldDelegate.quad1 != quad1;
  }
}

class MarkerPainter extends CustomPainter {
  final List<Offset> placedMarkers;
  final LevelData? currentTarget;
  final Offset panOffset;
  final double zoomScale;
  final double pulse;
  final Color markerColor;
  final Color targetColor;

  MarkerPainter({
    required this.placedMarkers,
    required this.currentTarget,
    required this.panOffset,
    required this.zoomScale,
    required this.pulse,
    required this.markerColor,
    required this.targetColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = (size.width / 2) + panOffset.dx;
    final double cy = (size.height / 2) + panOffset.dy;
    final double scale = (math.min(size.width, size.height) / 22) * zoomScale;

    // Draw active target hint if applicable
    if (currentTarget != null) {
       double tx = cx + (currentTarget!.targetX * scale);
       double ty = cy - (currentTarget!.targetY * scale);

       final hintPaint = Paint()..color = targetColor.withOpacity(0.2 + pulse * 0.3)..style = PaintingStyle.fill;
       final hintBorder = Paint()..color = targetColor..style = PaintingStyle.stroke..strokeWidth = 2;

       canvas.drawCircle(Offset(tx, ty), 16 + (pulse * 8), hintPaint);
       canvas.drawCircle(Offset(tx, ty), 12, hintBorder);
    }

    // Draw all successfully placed markers
    for (var pos in placedMarkers) {
      double px = cx + (pos.dx * scale);
      double py = cy - (pos.dy * scale); // Minus because screen Y goes down

      final markerFill = Paint()..color = markerColor..style = PaintingStyle.fill;
      final markerBorder = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;
      
      final glow = Paint()
        ..color = markerColor.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(Offset(px, py), 15, glow);
      canvas.drawCircle(Offset(px, py), 8, markerFill);
      canvas.drawCircle(Offset(px, py), 8, markerBorder);
      
      // Coordinate text label below marker
      final textPainter = TextPainter(
        text: TextSpan(
          text: '(${pos.dx.toInt()}, ${pos.dy.toInt()})',
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Beautiful Badge Background for the text to ensure high readability
      final Rect badgeRect = Rect.fromCenter(
        center: Offset(px, py + 22),
        width: textPainter.width + 16,
        height: textPainter.height + 8,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(badgeRect, const Radius.circular(12)),
        Paint()..color = Colors.black.withOpacity(0.85)..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(badgeRect, const Radius.circular(12)),
        Paint()..color = markerColor..style = PaintingStyle.stroke..strokeWidth = 1.5,
      );

      textPainter.paint(canvas, Offset(px - textPainter.width / 2, py + 22 - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant MarkerPainter oldDelegate) {
    return oldDelegate.placedMarkers != placedMarkers ||
        oldDelegate.currentTarget != currentTarget ||
        oldDelegate.pulse != pulse ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.zoomScale != zoomScale;
  }
}