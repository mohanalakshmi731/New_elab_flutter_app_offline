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
final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

// Local audio assets (assets/audio/class9/)
const String _clickUrl = 'audio/class9/click.mp3';
const String _successUrl = 'audio/class9/success.mp3';
const String _errorUrl = 'audio/class9/error.mp3'; 
const String _alertUrl = 'audio/class9/alert.mp3';
const String _shutterUrl = 'audio/class9/shutter.mp3';

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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShapeShifterApp());
}

// --- THEME MANAGEMENT ---
class AppTheme {
  static const Color bg = Color(0xFF0F172A); // Slate 900
  static const Color surface = Color(0xFF1E293B); // Slate 800
  static const Color text = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF94A3B8);
  static const Color accent = Color(0xFF38BDF8); // Light Blue 400
  static const Color primary = Color(0xFF818CF8); // Indigo 400
  static const Color secondary = Color(0xFFF472B6); // Pink 400
  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFF87171);
  static const Color gridLine = Color(0xFF334155);
  static const Color gridAxis = Color(0xFFF8FAFC);
}

// --- GAME DATA MODELS ---
class LevelData {
  final int id;
  final String shapeKey;
  final List<Offset> points;
  LevelData(this.id, this.shapeKey, this.points);
}

// --- LOCALIZATION ---
final Map<String, Map<String, String>> i18n = {
  'en': {
    'app_title': "SHAPE SHIFTER",
    'tagline': "SPACE ACADEMY: BLUEPRINT RECON",
    'init_btn': "START MISSION",
    'header_subtitle': "Class 9 • COORDINATE GEOMETRY - Plotting Shapes",
    'mission_obj_lbl': 'MISSION OBJECTIVE',
    'mission_simple': 'Plot the coordinates in the exact sequence to reveal and construct the hidden geometric shape.',
    'lab_mission_header': "MISSION PROGRESS",
    'target_label': "Required Coordinates",
    'btn_restart': "Replay Mission",
    'btn_retry': "Reset Shape",
    'msg_awesome': "SHAPE COMPLETE!",
    'mouse_hint': "Drag the graph to pan. Pinch to zoom. Tap the exact coordinates on the grid to plot the points in order.",
    'err_incorrect': "Incorrect Position. Check Coordinates!",
    'build_shape': "Blueprint: {shape}",
    'modal_title': "Mission Complete!",
    'modal_desc': "You have mastered forming shapes on the Cartesian plane.",
    'btn_next': "NEXT SHAPE",
    
    // Dynamic Labels
    'lbl_point': 'Point ',
    'lbl_shape_prog': 'SHAPE ',
    
    // Shape Names
    'shape_square': 'Square',
    'shape_rect': 'Rectangle',
    'shape_tri': 'Triangle',
    'shape_rhom': 'Rhombus',
    'shape_trap': 'Trapezium',
  },
  'hi': {
    'app_title': "आकार परिवर्तक",
    'tagline': "स्पेस अकादमी: ब्लूप्रिंट निर्माण",
    'init_btn': "मिशन शुरू करें",
    'header_subtitle': "कक्षा 9 • निर्देशांक ज्यामिति – आकृतियाँ बनाना",
    'mission_obj_lbl': 'मिशन का उद्देश्य',
    'mission_simple': 'छिपी हुई ज्यामितीय आकृति को प्रकट करने और बनाने के लिए सटीक क्रम में निर्देशांक प्लॉट करें।',
    'lab_mission_header': "मिशन की प्रगति",
    'target_label': "आवश्यक निर्देशांक",
    'btn_restart': "फिर से खेलें",
    'btn_retry': "आकार रीसेट करें",
    'msg_awesome': "आकार पूर्ण!",
    'mouse_hint': "पैन करने के लिए खींचें। ज़ूम करने के लिए पिंच करें। बिंदुओं को क्रम में प्लॉट करने के लिए सटीक निर्देशांक टैप करें।",
    'err_incorrect': "गलत स्थिति। निर्देशांक जांचें!",
    'build_shape': "ब्लूप्रिंट: {shape}",
    'modal_title': "मिशन पूरा हुआ!",
    'modal_desc': "आपने कार्टेशियन तल पर आकृतियाँ बनाने में महारत हासिल कर ली है।",
    'btn_next': "अगला आकार",
    
    // Dynamic Labels
    'lbl_point': 'बिंदु ',
    'lbl_shape_prog': 'आकार ',
    
    // Shape Names
    'shape_square': 'वर्ग',
    'shape_rect': 'आयत',
    'shape_tri': 'त्रिभुज',
    'shape_rhom': 'समचतुर्भुज',
    'shape_trap': 'समलंब',
  },
};

class ShapeShifterApp extends StatelessWidget {
  const ShapeShifterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Shape Shifter',
      debugShowCheckedModeBanner: false,
      home: ShapeShifterScreen(),
    );
  }
}

class ShapeShifterScreen extends StatefulWidget {
  const ShapeShifterScreen({super.key});

  @override
  State<ShapeShifterScreen> createState() => _ShapeShifterScreenState();
}

class _ShapeShifterScreenState extends State<ShapeShifterScreen>
    with TickerProviderStateMixin {
  
  // Core State
  bool _showShutter = true;
  bool _sidebarOpen = true;
  bool missionComplete = false;
  String currentLang = 'en';

  // Game State
  int currentLevelIndex = 0;
  List<Offset> plottedPoints = [];
  bool isShapeComplete = false;

  // View State (Panning & Zooming)
  Offset _panOffset = Offset.zero;
  double _zoomScale = 1.0;
  double _previousZoom = 1.0;

  final List<LevelData> levels = [
    LevelData(1, "shape_square", const [
      Offset(2, 2),
      Offset(2, -2),
      Offset(-2, -2),
      Offset(-2, 2),
    ]),
    LevelData(2, "shape_rect", const [
      Offset(-4, 2),
      Offset(4, 2),
      Offset(4, -1),
      Offset(-4, -1),
    ]),
    LevelData(3, "shape_tri", const [
      Offset(0, 4),
      Offset(3, -2),
      Offset(-3, -2),
    ]),
    LevelData(4, "shape_rhom", const [
      Offset(0, 3),
      Offset(4, 0),
      Offset(0, -3),
      Offset(-4, 0),
    ]),
    LevelData(5, "shape_trap", const [
      Offset(-2, 3),
      Offset(2, 3),
      Offset(4, -2),
      Offset(-4, -2),
    ]),
  ];

  // Overlays
  String? _bannerMessage;
  String? _bannerType;

  // Animations
  late AnimationController _pulseController;
  late AnimationController _celebrationController;
  final ScrollController _hudScrollController = ScrollController();

  String t(String key) => i18n[currentLang]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

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
    super.dispose();
  }

  void _onGridTap(Offset localPosition, Size size) {
    if (missionComplete || isShapeComplete || _showShutter) return;

    double gridSize = math.min(size.width, size.height);
    double unitSize = (gridSize / 22) * _zoomScale; // Scaled unit size
    Offset center = Offset(size.width / 2, size.height / 2) + _panOffset;

    double dx = localPosition.dx - center.dx;
    double dy = center.dy - localPosition.dy; // Invert Y for Cartesian

    // Restricted the bounds to -10 to 10 based on requirements
    int gridX = (dx / unitSize).round().clamp(-10, 10);
    int gridY = (dy / unitSize).round().clamp(-10, 10);

    LevelData currentLevel = levels[currentLevelIndex];
    int expectedIndex = plottedPoints.length;

    if (expectedIndex < currentLevel.points.length) {
      Offset expectedPoint = currentLevel.points[expectedIndex];
      // Allow slight tap tolerance
      if (gridX == expectedPoint.dx.toInt() && gridY == expectedPoint.dy.toInt()) {
        HapticFeedback.heavyImpact();
        _playSound(_fxPlayer, _alertUrl);
        setState(() {
          plottedPoints.add(Offset(gridX.toDouble(), gridY.toDouble()));

          if (plottedPoints.length == currentLevel.points.length) {
            isShapeComplete = true;
            _playSound(_successPlayer, _successUrl);
            _showBanner('success', t('msg_awesome'));
          }
        });
      } else {
        HapticFeedback.vibrate();
        _playSound(_errorPlayer, _errorUrl);
        _showBanner('error', t('err_incorrect'));
      }
    }
  }

  void nextLevel() {
    _playSound(_clickPlayer, _clickUrl);
    if (currentLevelIndex < levels.length - 1) {
      setState(() {
        currentLevelIndex++;
        plottedPoints.clear();
        isShapeComplete = false;
      });
    } else {
      _playSound(_successPlayer, _successUrl);
      setState(() {
        missionComplete = true;
        _celebrationController.forward();
      });
    }
  }

  void resetLevel() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      plottedPoints.clear();
      isShapeComplete = false;
    });
  }

  void hardReset() {
    _playSound(_clickPlayer, _clickUrl);
    setState(() {
      currentLevelIndex = 0;
      missionComplete = false;
      plottedPoints.clear();
      isShapeComplete = false;
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
                    child: _buildMainWorkspace()
                  )
                ),
              ],
            ),

            // Floating HUD - Docked in the Bottom Left
            if (!_sidebarOpen && !_showShutter && !missionComplete)
              _buildFloatingHUD(screenW),

            // Top Left Menu Button - Moved after HUD to ensure highest Z-index
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

  // --- UI COMPONENTS ---

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
            color: active ? AppTheme.bg : Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLabContent() {
    LevelData? currentLevel = currentLevelIndex < levels.length ? levels[currentLevelIndex] : null;

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

        // Status Box
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
                    '${t('lbl_shape_prog')}${currentLevelIndex + 1}/${levels.length}',
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

        // Coordinates List Box
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
              Text(
                currentLevel != null 
                    ? t('build_shape').replaceAll('{shape}', t(currentLevel.shapeKey)) 
                    : t('modal_title'),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white10)),
              
              Text(t('target_label').toUpperCase(), style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 12),

              if (currentLevel != null)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentLevel.points.length,
                  itemBuilder: (context, index) {
                    bool isPlotted = index < plottedPoints.length;
                    bool isNext = index == plottedPoints.length && !isShapeComplete;
                    Offset p = currentLevel.points[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPlotted ? AppTheme.success.withOpacity(0.2) : (isNext ? AppTheme.accent.withOpacity(0.2) : Colors.black45),
                        border: Border.all(
                          color: isPlotted ? AppTheme.success : (isNext ? AppTheme.accent : Colors.white10),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${t('lbl_point')}${index + 1}', style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                          Text('(${p.dx.toInt()}, ${p.dy.toInt()})', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Icon(isPlotted ? Icons.check_circle : Icons.radio_button_unchecked, color: isPlotted ? AppTheme.success : AppTheme.muted, size: 16),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 16),
              
              if (isShapeComplete)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: AppTheme.bg,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: nextLevel,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(t('btn_next'), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                )
              else
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.muted,
                    side: BorderSide(color: AppTheme.muted.withOpacity(0.5)),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    LevelData? currentLevel = currentLevelIndex < levels.length ? levels[currentLevelIndex] : null;
    
    // Exactly 38% width
    double hudWidth = screenW * 0.38;

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
        child: RawScrollbar(
          controller: _hudScrollController,
          thumbColor: AppTheme.accent.withOpacity(0.8),
          radius: const Radius.circular(4),
          thickness: 4,
          thumbVisibility: true,
          child: SingleChildScrollView( 
            controller: _hudScrollController,
            padding: const EdgeInsets.only(right: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t('target_label').toUpperCase(), style: const TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text('${t('lbl_shape_prog')}${currentLevelIndex + 1}/${levels.length}', style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currentLevel != null ? t('build_shape').replaceAll('{shape}', t(currentLevel.shapeKey)) : t('modal_title'),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white10)),
                
                if (currentLevel != null)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentLevel.points.length,
                    itemBuilder: (context, index) {
                      bool isPlotted = index < plottedPoints.length;
                      bool isNext = index == plottedPoints.length && !isShapeComplete;
                      Offset p = currentLevel.points[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isPlotted ? AppTheme.success.withOpacity(0.2) : (isNext ? AppTheme.accent.withOpacity(0.2) : Colors.black45),
                          border: Border.all(color: isPlotted ? AppTheme.success : (isNext ? AppTheme.accent : Colors.white10)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${t('lbl_point')}${index + 1}', style: const TextStyle(color: AppTheme.muted, fontSize: 10)),
                            Text('(${p.dx.toInt()}, ${p.dy.toInt()})', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            Icon(isPlotted ? Icons.check_circle : Icons.radio_button_unchecked, color: isPlotted ? AppTheme.success : AppTheme.muted, size: 14),
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 12),
                
                if (isShapeComplete)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: AppTheme.bg,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: nextLevel,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(t('btn_next'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  )
                else
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.muted,
                      side: BorderSide(color: AppTheme.muted.withOpacity(0.5)),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: resetLevel,
                    icon: const Icon(Icons.refresh),
                    label: Text(t('btn_retry').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainWorkspace() {
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
                onTapDown: (details) => _onGridTap(details.localPosition, Size(constraints.maxWidth, constraints.maxHeight)),
                child: Stack(
                  children: [
                    // Grid & Axes
                    CustomPaint(
                      size: Size.infinite,
                      painter: CartesianShapePainter(
                        panOffset: _panOffset,
                        zoomScale: _zoomScale,
                        points: plottedPoints,
                        isComplete: isShapeComplete,
                      ),
                    ),

                    // Placed Markers
                    ...plottedPoints.map((pos) => _buildMarker(pos, constraints)),

                    // Next Target Highlight (if not complete)
                    if (!missionComplete && !isShapeComplete && currentLevelIndex < levels.length && plottedPoints.length < levels[currentLevelIndex].points.length)
                      _buildTargetHighlight(levels[currentLevelIndex].points[plottedPoints.length], constraints),
                  ],
                ),
              ),
            ),
            
            // Recenter Button
            Positioned(
              bottom: 20,
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

  Widget _buildMarker(Offset pos, BoxConstraints constraints) {
    double gridSize = math.min(constraints.maxWidth, constraints.maxHeight);
    double unitSize = (gridSize / 22) * _zoomScale;
    Offset center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2) + _panOffset;

    double screenX = center.dx + (pos.dx * unitSize);
    double screenY = center.dy - (pos.dy * unitSize);
    double markerSize = unitSize * 0.8;
    markerSize = markerSize.clamp(10.0, 40.0);

    return Positioned(
      left: screenX - (markerSize / 2),
      top: screenY - (markerSize / 2),
      width: markerSize,
      height: markerSize,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.success,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: AppTheme.success.withOpacity(0.5), blurRadius: 10)],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetHighlight(Offset pos, BoxConstraints constraints) {
    double gridSize = math.min(constraints.maxWidth, constraints.maxHeight);
    double unitSize = (gridSize / 22) * _zoomScale;
    Offset center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2) + _panOffset;

    double screenX = center.dx + (pos.dx * unitSize);
    double screenY = center.dy - (pos.dy * unitSize);
    double markerSize = unitSize * 1.5;
    markerSize = markerSize.clamp(20.0, 60.0);

    return Positioned(
      left: screenX - (markerSize / 2),
      top: screenY - (markerSize / 2),
      width: markerSize,
      height: markerSize,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.accent.withOpacity(0.5 + (_pulseController.value * 0.5)),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(color: AppTheme.accent.withOpacity(0.2 * _pulseController.value), blurRadius: 10, spreadRadius: 2),
                ],
              ),
            );
          },
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
                    const Icon(Icons.architecture, color: AppTheme.success, size: 80),
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
                const Icon(Icons.category, size: 80, color: AppTheme.accent),
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

class CartesianShapePainter extends CustomPainter {
  final Offset panOffset;
  final double zoomScale;
  final List<Offset> points;
  final bool isComplete;

  CartesianShapePainter({
    required this.panOffset, 
    required this.zoomScale,
    required this.points,
    required this.isComplete,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double gridSize = math.min(size.width, size.height);
    double unitSize = (gridSize / 22) * zoomScale; 
    Offset center = Offset(size.width / 2, size.height / 2) + panOffset;

    // Softer background grid lines for better readability
    final Paint gridPaint = Paint()
      ..color = AppTheme.gridLine.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
      
    final Paint axisPaintX = Paint()..color = AppTheme.primary..strokeWidth = 3..style = PaintingStyle.stroke;
    final Paint axisPaintY = Paint()..color = AppTheme.secondary..strokeWidth = 3..style = PaintingStyle.stroke;

    // Strict 10x10 bounds
    double gridLimit = 10.5 * unitSize; 

    for (int i = -10; i <= 10; i++) {
      double offset = i * unitSize;
      canvas.drawLine(Offset(center.dx - gridLimit, center.dy + offset), Offset(center.dx + gridLimit, center.dy + offset), i == 0 ? axisPaintX : gridPaint); // Horiz
      canvas.drawLine(Offset(center.dx + offset, center.dy - gridLimit), Offset(center.dx + offset, center.dy + gridLimit), i == 0 ? axisPaintY : gridPaint); // Vert
    }

    // Draw Shape Lines
    if (points.isNotEmpty) {
      final Paint linePaint = Paint()
        ..color = isComplete ? AppTheme.success : AppTheme.accent
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;

      Path path = Path();
      for (int i = 0; i < points.length; i++) {
        double px = center.dx + (points[i].dx * unitSize);
        double py = center.dy - (points[i].dy * unitSize);
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      if (isComplete && points.length > 2) {
        path.close();
        final Paint fillPaint = Paint()
          ..color = AppTheme.success.withOpacity(0.2)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);
      }
      canvas.drawPath(path, linePaint);
    }

    TextStyle textStyle = const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold);

    for (int i = -10; i <= 10; i++) {
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
  bool shouldRepaint(covariant CartesianShapePainter oldDelegate) => oldDelegate.panOffset != panOffset || oldDelegate.zoomScale != zoomScale || oldDelegate.points.length != points.length || oldDelegate.isComplete != isComplete;
}