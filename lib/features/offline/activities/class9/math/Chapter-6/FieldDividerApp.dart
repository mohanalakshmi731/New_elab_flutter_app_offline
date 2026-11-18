// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FieldDividerApp());
}

class FieldDividerApp extends StatelessWidget {
  const FieldDividerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Field Divider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF8b5cf6),
        scaffoldBackgroundColor: const Color(0xFF0f0518),
      ),
      home: const FieldDividerScreen(),
    );
  }
}

class FieldDividerScreen extends StatefulWidget {
  const FieldDividerScreen({super.key});

  @override
  State<FieldDividerScreen> createState() => _FieldDividerScreenState();
}

class _FieldDividerScreenState extends State<FieldDividerScreen> with TickerProviderStateMixin {
  // Application State
  bool isSidebarOpen = true;
  String lang = 'en';
  List<String> langs = ['en', 'hi']; 
  int step = 0; 
  
  // Canvas State
  List<String> selection = [];
  TextEditingController calcController = TextEditingController();
  bool showError = false;

  // Modals & Timers
  bool isFinalSuccessVisible = false;
  String toastMsg = '';
  bool isToastError = false;
  bool isToastVisible = false;
  Timer? toastTimer;

  // Animations
  late AnimationController _pulseController;
  late AnimationController _celebrationController;

  // Audio System
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class9/click.mp3';
  static const String _successUrl = 'audio/class9/success.mp3';
  static const String _errorUrl = 'audio/class9/error.mp3';
  static const String _actionUrl = 'audio/class9/shutter.mp3'; 

  // Base coordinates relative to center
  final Offset pA = const Offset(-150, 0);
  final Offset pB = const Offset(50, 100);
  final Offset pC = const Offset(150, 0);
  final Offset pD = const Offset(0, -50);

  // Translations
  final Map<String, Map<String, dynamic>> dict = {
    'en': {
      'app_title': "The Field Divider",
      'tagline': "Class 9 • HERON'S FORMULA - Area of Quadrilaterals",
      'header_title': "The Field Divider",
      'header_subtitle': "Class 9 • Heron's Formula",
      'interactive_title': "Action Console",
      'mission_obj': "Mission Objective",
      'procedural_steps': "Procedural Steps",
      'concept_title': "Concept",
      'success_title': "Field Surveyed!",
      'return_btn': "Return to Base",
      'step_label': "Step",
      'obj_desc': "Calculate the area of irregular quadrilateral ABCD by dividing it into two triangles and summing their individual areas.",
      'start_mission': "START MISSION",
      'analyze_complete': "ANALYZE COMPLETE",
      'click_vertices': "Click Vertex A, then C on Canvas",
      'confirm_shapes': "CONFIRM SHAPES",
      'drag_to': "DRAG TO",
      'line_ac': "LINE AC",
      'vertex_b': "VERTEX B",
      'vertex_d': "VERTEX D",
      'enter_area': "Enter Area?",
      'incorrect_value': "Incorrect Value",
      'survey_verified': "SURVEY VERIFIED",
      'total_area_36': "Total Area: 36 sq units",
      'mastery_level': "Mastery Level: 100%",
      'clear': "CLEAR",
      'steps': [
        { 'title': "Inspect Field", 'desc': "Observe the quadrilateral ABCD.", 'concept': "A quadrilateral is a 2D polygon with 4 edges and 4 vertices." },
        { 'title': "Draw Diagonal", 'desc': "Click Vertex A, then Vertex C to draw diagonal AC.", 'concept': "A diagonal connects opposite vertices. It splits the quadrilateral into two distinct triangles." },
        { 'title': "Identify", 'desc': "Confirm the two triangles: ΔABC and ΔADC.", 'concept': "The diagonal AC acts as a shared base (b) for both ΔABC and ΔADC." },
        { 'title': "Measure Base", 'desc': "Drag tape tool to diagonal AC to measure base b.", 'concept': "The length of the diagonal is the base (b) required for our area calculations. Here, b = 12." },
        { 'title': "Measure h₁", 'desc': "Drag tape tool to Vertex B to find altitude h₁.", 'concept': "Altitude (h₁) is the perpendicular distance from vertex B to the base AC." },
        { 'title': "Measure h₂", 'desc': "Drag tape tool to Vertex D to find altitude h₂.", 'concept': "Altitude (h₂) is the perpendicular distance from vertex D to the base AC." },
        { 'title': "Calculate Δ₁", 'desc': "Find Area of ΔABC = ½ × b × h₁.", 'concept': "Area of Triangle = ½ × base × height. Insert values to find ΔABC." },
        { 'title': "Calculate Δ₂", 'desc': "Find Area of ΔADC = ½ × b × h₂.", 'concept': "Repeat the formula for the second triangle using its specific altitude h₂." },
        { 'title': "Total Area", 'desc': "Sum the two areas and input the result.", 'concept': "Total Area = Area(ΔABC) + Area(ΔADC). The additivity postulate of area." },
        { 'title': "Verification", 'desc': "Final review and submission.", 'concept': "Mission accomplished! Splitting irregular shapes into triangles is a core technique in land surveying." }
      ]
    },
    'hi': {
      'app_title': "फ़ील्ड डिवाइडर",
      'tagline': "कक्षा 9 • हीरोन का सूत्र – चतुर्भुजों का क्षेत्रफल",
      'header_title': "फ़ील्ड डिवाइडर",
      'header_subtitle': "कक्षा 9 • हीरोन का सूत्र",
      'interactive_title': "कंसोल",
      'mission_obj': "मिशन उद्देश्य",
      'procedural_steps': "प्रक्रिया",
      'concept_title': "सिद्धांत",
      'success_title': "मैदान का सर्वेक्षण किया गया!",
      'return_btn': "वापस जाएँ",
      'step_label': "चरण",
      'obj_desc': "अनियमित चतुर्भुज ABCD को दो त्रिकोणों में विभाजित करके उनके क्षेत्रफल का योग ज्ञात करें।",
      'start_mission': "मिशन प्रारंभ करें",
      'analyze_complete': "विश्लेषण पूर्ण",
      'click_vertices': "कैनवास पर शीर्ष A, फिर C पर क्लिक करें",
      'confirm_shapes': "आकृतियों की पुष्टि करें",
      'drag_to': "यहाँ खींचें:",
      'line_ac': "रेखा AC",
      'vertex_b': "शीर्ष B",
      'vertex_d': "शीर्ष D",
      'enter_area': "क्षेत्रफल दर्ज करें?",
      'incorrect_value': "गलत मान",
      'survey_verified': "सर्वेक्षण सत्यापित",
      'total_area_36': "कुल क्षेत्रफल: 36 वर्ग इकाई",
      'mastery_level': "महारत स्तर: 100%",
      'clear': "साफ़ करें",
      'steps': [
        { 'title': "निरीक्षण", 'desc': "चतुर्भुज ABCD का निरीक्षण करें।", 'concept': "चतुर्भुज 4 भुजाओं और 4 शीर्षों वाला एक 2D बहुभुज है।" },
        { 'title': "विकर्ण खींचें", 'desc': "विकर्ण AC खींचने के लिए A और फिर C पर क्लिक करें।", 'concept': "एक विकर्ण विपरीत शीर्षों को जोड़ता है और चतुर्भुज को दो त्रिकोणों में विभाजित करता है।" },
        { 'title': "पहचान", 'desc': "दो त्रिकोणों की पुष्टि करें: ΔABC और ΔADC।", 'concept': "विकर्ण AC दोनों त्रिकोणों के लिए एक साझा आधार (b) के रूप में कार्य करता है।" },
        { 'title': "आधार मापें", 'desc': "आधार b मापने के लिए टेप टूल को AC पर खींचें।", 'concept': "विकर्ण की लंबाई आधार (b) है। यहाँ, b = 12।" },
        { 'title': "मापें h₁", 'desc': "लंब h₁ ज्ञात करने के लिए टेप टूल को B पर खींचें।", 'concept': "लंब (h₁) शीर्ष B से आधार AC तक की लंबवत दूरी है।" },
        { 'title': "मापें h₂", 'desc': "लंब h₂ ज्ञात करने के लिए टेप टूल को D पर खींचें।", 'concept': "लंब (h₂) शीर्ष D से आधार AC तक की लंबवत दूरी है।" },
        { 'title': "गणना Δ₁", 'desc': "ΔABC का क्षेत्रफल = ½ × b × h₁ ज्ञात करें।", 'concept': "त्रिकोण का क्षेत्रफल = ½ × आधार × ऊँचाई।" },
        { 'title': "गणना Δ₂", 'desc': "ΔADC का क्षेत्रफल = ½ × b × h₂ ज्ञात करें।", 'concept': "दूसरे त्रिकोण के लिए उसके लंब h₂ का उपयोग करके सूत्र दोहराएं।" },
        { 'title': "कुल क्षेत्रफल", 'desc': "दोनों क्षेत्रों को जोड़ें और दर्ज करें।", 'concept': "कुल क्षेत्रफल = क्षेत्रफल(ΔABC) + क्षेत्रफल(ΔADC)।" },
        { 'title': "सत्यापन", 'desc': "अंतिम समीक्षा।", 'concept': "मिशन पूरा हुआ! अनियमित आकृतियों को त्रिकोणों में विभाजित करना एक मुख्य तकनीक है।" }
      ]
    },
  };

  dynamic tr(String key) {
    if (dict[lang]?[key] != null) return dict[lang]![key];
    if (dict['en']?[key] != null) return dict['en']![key];
    return key;
  }

  void playSound(String type) async {
    try {
      switch (type) {
        case 'click':
          SystemSound.play(SystemSoundType.click);
          HapticFeedback.lightImpact();
          await _clickPlayer.play(AssetSource(_clickUrl));
          break;
        case 'success':
          HapticFeedback.heavyImpact();
          await _successPlayer.play(AssetSource(_successUrl));
          break;
        case 'error':
          HapticFeedback.vibrate();
          await _errorPlayer.play(AssetSource(_errorUrl));
          break;
        case 'action':
          HapticFeedback.selectionClick();
          await _fxPlayer.play(AssetSource(_actionUrl));
          break;
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _celebrationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
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
    calcController.dispose();
    toastTimer?.cancel();
    super.dispose();
  }

  void _globalReset() {
    playSound('click');
    setState(() {
      lang = 'en'; // Reset language to english
      step = 0;
      selection.clear();
      calcController.clear();
      isFinalSuccessVisible = false;
      showError = false;
    });
  }

  void _cycleLanguage() {
    playSound('click');
    setState(() {
      int idx = langs.indexOf(lang);
      lang = langs[(idx + 1) % langs.length];
    });
  }

  void _nextStep() {
    if (step < 10) {
      setState(() {
        step++;
        selection.clear();
        calcController.clear();
        showError = false;
      });
      if (step == 10) {
        playSound('success');
        setState(() => isFinalSuccessVisible = true);
      }
    }
  }

  void _handleVertexClick(String vertex, Size canvasSize) {
    if (step != 2) return;
    if ((vertex == 'A' || vertex == 'C') && !selection.contains(vertex)) {
      playSound('click');
      setState(() {
        selection.add(vertex);
        if (selection.length == 2) {
          playSound('success');
          Future.delayed(const Duration(milliseconds: 600), _nextStep);
        }
      });
    }
  }

  void _checkAnswer() {
    double? val = double.tryParse(calcController.text);
    double target = 0;
    if (step == 7) target = 24;
    else if (step == 8) target = 12;
    else if (step == 9) target = 36;

    if (val == target) {
      playSound('success');
      _nextStep();
    } else {
      playSound('error');
      setState(() => showError = true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => showError = false);
      });
    }
  }

  // --- UI Layout ---
  Color get themeAccent => const Color(0xFFd946ef); // pink-purple
  Color get themePrimary => const Color(0xFF8b5cf6); // violet
  Color get themeSuccess => const Color(0xFF4ade80); // green
  Color get themeError => const Color(0xFFf43f5e);   // rose
  Color get bgBase => const Color(0xFF0f0518);
  Color get panelBg => const Color(0xF21e1b4b);
  Color get panelBorder => const Color(0x4Dd946ef);
  Color get textBase => const Color(0xFFf8fafc);

  Widget _buildSidebar(double width) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isSidebarOpen ? width * 0.30 : 0,
      constraints: BoxConstraints(minWidth: isSidebarOpen ? 300 : 0, maxWidth: 450),
      decoration: BoxDecoration(
        color: panelBg,
        border: Border(right: BorderSide(color: panelBorder, width: 2)),
        boxShadow: isSidebarOpen ? [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)] : [],
      ),
      child: isSidebarOpen ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48), // Padding for floating menu button
              
              // Header
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: themeAccent, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.draw, color: textBase),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('header_title'), style: TextStyle(color: textBase, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(tr('header_subtitle'), style: TextStyle(color: themePrimary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _sidebarBtn(Icons.language, lang.toUpperCase(), _cycleLanguage, themePrimary),
                  _sidebarBtn(Icons.refresh, '', _globalReset, themeError),
                ],
              ),
              const SizedBox(height: 24),

              if (step > 0) ...[
                // Dynamic Step Status Title
                Container(
                  padding: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: panelBorder))),
                  child: Row(
                    children: [
                      Icon(Icons.directions_walk, color: themeAccent),
                      const SizedBox(width: 8),
                      Text("${tr('step_label').toString().toUpperCase()} $step/10", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2.0, fontSize: 14, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Mission Objective
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(12), border: Border.all(color: panelBorder)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.track_changes, color: themePrimary, size: 16),
                          const SizedBox(width: 8),
                          Text(tr('mission_obj').toString().toUpperCase(), style: TextStyle(color: themePrimary, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(tr('obj_desc'), style: TextStyle(color: textBase.withOpacity(0.9), fontSize: 13, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Procedural Steps
                Row(
                  children: [
                    Icon(Icons.checklist, color: themeAccent, size: 16),
                    const SizedBox(width: 8),
                    Text(tr('procedural_steps').toString().toUpperCase(), style: TextStyle(color: themeAccent, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(12), border: Border.all(color: panelBorder)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate((tr('steps') as List).length, (index) {
                      var s = (tr('steps') as List)[index];
                      bool isCurrent = (index + 1) == step;
                      bool isDone = (index + 1) < step;
                      Color cColor = isCurrent ? themeAccent : (isDone ? themeSuccess : textBase.withOpacity(0.4));
                      IconData cIcon = isCurrent ? Icons.circle : (isDone ? Icons.check_circle : Icons.radio_button_unchecked);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(cIcon, size: 16, color: cColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(color: cColor, fontSize: 13, height: 1.4, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
                                  children: [
                                    TextSpan(text: "${s['title']}: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: s['desc'] ?? s['desc:']),
                                  ]
                                )
                              )
                            )
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),

                // Dynamic Concept Area
                Container(
                  decoration: BoxDecoration(border: Border(left: BorderSide(color: themeSuccess, width: 4))),
                  padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('concept_title').toString().toUpperCase(), style: TextStyle(color: themeSuccess, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text((tr('steps') as List)[step - 1]['concept'] ?? '', style: TextStyle(color: textBase.withOpacity(0.9), fontSize: 13, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Footer
              Center(
                child: Text(
                  "© ZeroScienceLab - Fall in love with math and Science",
                  style: TextStyle(color: textBase.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ) : const SizedBox.shrink(),
    );
  }

  Widget _sidebarBtn(IconData icon, String text, VoidCallback onTap, Color iconColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            if (text.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(text, style: TextStyle(color: textBase, fontWeight: FontWeight.bold, fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas(double width) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isSidebarOpen ? width * 0.7 : width,
      decoration: BoxDecoration(color: bgBase), // explicitly set the dark background
      child: Column(
        children: [
          // Upper area for the Canvas Geometry
          Expanded(
            child: Stack(
              children: [
                // Background grid
                Positioned.fill(
                  child: CustomPaint(painter: GridPainter()),
                ),
                
                // Main Field Graphics
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: FieldPainter(
                              step: step,
                              selection: selection,
                              pulseValue: _pulseController.value,
                              themeAccent: themeAccent,
                              themePrimary: themePrimary,
                              themeSuccess: themeSuccess,
                              pA: pA, pB: pB, pC: pC, pD: pD,
                            ),
                            size: Size.infinite,
                          );
                        }
                      );
                    }
                  ),
                ),

                // Interactive Drag Targets & Clicks
                if (step > 0)
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double cx = constraints.maxWidth / 2;
                        double cy = constraints.maxHeight / 2;
                        
                        // Adjusted scaling logic to make geometry bigger
                        double s = math.max(0.4, math.min(constraints.maxWidth / 350, constraints.maxHeight / 250) * 1.0);
                        
                        // Added y-offset (-25) to properly center the asymmetric shape bounds vertically.
                        // Y bounds are roughly [-50, 100], so center is +25. Subtracting 25 centers it perfectly.
                        Offset getScreenPos(Offset local) => Offset(cx + local.dx * s, cy + (local.dy - 25) * s);
                        
                        return Stack(
                          children: [
                            if (step == 2) ...[
                              Positioned(
                                left: getScreenPos(pA).dx - 30, top: getScreenPos(pA).dy - 30,
                                width: 60, height: 60,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: (_) => _handleVertexClick('A', constraints.biggest),
                                ),
                              ),
                              Positioned(
                                left: getScreenPos(pC).dx - 30, top: getScreenPos(pC).dy - 30,
                                width: 60, height: 60,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: (_) => _handleVertexClick('C', constraints.biggest),
                                ),
                              ),
                            ],
                            if (step == 4) 
                              Positioned(
                                left: getScreenPos(const Offset(0, 0)).dx - 40, top: getScreenPos(const Offset(0, 0)).dy - 40,
                                width: 80, height: 80,
                                child: DragTarget<String>(
                                  builder: (context, candidateData, rejectedData) => Container(color: Colors.transparent),
                                  onAccept: (data) { if(data == 'tape') { playSound('success'); _nextStep(); } },
                                ),
                              ),
                            if (step == 5)
                              Positioned(
                                left: getScreenPos(pB).dx - 40, top: getScreenPos(pB).dy - 40,
                                width: 80, height: 80,
                                child: DragTarget<String>(
                                  builder: (context, candidateData, rejectedData) => Container(color: Colors.transparent),
                                  onAccept: (data) { if(data == 'tape') { playSound('success'); _nextStep(); } },
                                ),
                              ),
                            if (step == 6)
                              Positioned(
                                left: getScreenPos(pD).dx - 40, top: getScreenPos(pD).dy - 40,
                                width: 80, height: 80,
                                child: DragTarget<String>(
                                  builder: (context, candidateData, rejectedData) => Container(color: Colors.transparent),
                                  onAccept: (data) { if(data == 'tape') { playSound('success'); _nextStep(); } },
                                ),
                              ),
                          ],
                        );
                      }
                    ),
                  ),
              ],
            ),
          ),
          
          // Lower area for the Action Console (compacted padding & sizes)
          if (step > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
              child: Container(
                width: 320,
                decoration: BoxDecoration(color: panelBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: panelBorder), boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20)]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black26, border: Border(bottom: BorderSide(color: panelBorder))),
                      child: Row(
                        children: [
                          Icon(Icons.gamepad, color: themeAccent, size: 14),
                          const SizedBox(width: 8),
                          Text(tr('interactive_title').toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: _buildActionContent(),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionContent() {
    if (step == 1) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: themeAccent, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 36), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () { playSound('click'); _nextStep(); },
        child: Text(tr('analyze_complete').toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
      );
    } else if (step == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) => Icon(Icons.touch_app, size: 18, color: themeAccent.withOpacity(0.5 + _pulseController.value * 0.5)),
          ),
          const SizedBox(width: 8),
          Flexible(child: Text(tr('click_vertices'), style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 11), textAlign: TextAlign.center)),
        ],
      );
    } else if (step == 3) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: panelBg, borderRadius: BorderRadius.circular(4), border: Border.all(color: panelBorder)), child: const Text("ΔABC", style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12))),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: panelBg, borderRadius: BorderRadius.circular(4), border: Border.all(color: panelBorder)), child: const Text("ΔADC", style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: themePrimary, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 36), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () { playSound('click'); _nextStep(); },
            child: Text(tr('confirm_shapes').toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
          ),
        ],
      );
    } else if (step == 4 || step == 5 || step == 6) {
      String targetKey = step == 4 ? 'line_ac' : (step == 5 ? 'vertex_b' : 'vertex_d');
      return Column(
        children: [
          Draggable<String>(
            data: 'tape',
            feedback: Material(color: Colors.transparent, child: Container(width: 40, height: 40, decoration: BoxDecoration(color: themeAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: themeAccent.withOpacity(0.5), blurRadius: 15)]), child: const Icon(Icons.straighten, color: Colors.white, size: 20))),
            childWhenDragging: Container(width: 36, height: 36, decoration: BoxDecoration(color: themeAccent.withOpacity(0.3), shape: BoxShape.circle)),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: themeAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: themeAccent.withOpacity(0.4), blurRadius: 10)]),
              child: const Icon(Icons.straighten, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(height: 8),
          Text("${tr('drag_to')} ${tr(targetKey).toUpperCase()}", style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
        ],
      );
    } else if (step == 7 || step == 8 || step == 9) {
      String eqn = step == 7 ? "Area₁ = ½(12)(4)" : (step == 8 ? "Area₂ = ½(12)(2)" : "Total = 24 + 12");
      return Column(
        children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8), border: Border.all(color: panelBorder)),
            child: Text(eqn, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: calcController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: tr('enter_area'), hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                    filled: true, fillColor: panelBg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: themeAccent, width: 2)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: themeAccent, width: 2)),
                  ),
                  onSubmitted: (_) => _checkAnswer(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: themeAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: _checkAnswer,
                child: const Icon(Icons.check, size: 18),
              )
            ],
          ),
          AnimatedOpacity(
            opacity: showError ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(tr('incorrect_value'), style: TextStyle(color: themeError, fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          )
        ],
      );
    } else if (step == 10) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: themeSuccess, size: 18),
          const SizedBox(width: 8),
          Text(tr('survey_verified').toUpperCase(), style: TextStyle(color: themeSuccess, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Row(
              children: [
                _buildSidebar(screenWidth),
                Expanded(child: _buildCanvas(screenWidth)),
              ],
            ),

            // Top Left Menu Button
            Positioned(
              top: 16, left: 16,
              child: IconButton(
                icon: Icon(isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.white,
                onPressed: () {
                  playSound('click');
                  setState(() => isSidebarOpen = !isSidebarOpen);
                },
                style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),

            // Toast Message
            if (isToastVisible)
              Positioned(
                top: 24, left: 0, right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: isToastVisible ? 1.0 : 0.0, duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(color: isToastError ? Colors.red.shade900.withOpacity(0.9) : Colors.green.shade900.withOpacity(0.9), borderRadius: BorderRadius.circular(30), border: Border.all(color: isToastError ? Colors.red : Colors.green, width: 2), boxShadow: [BoxShadow(color: (isToastError ? Colors.red : Colors.green).withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 4))]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isToastError ? Icons.warning : Icons.check_circle, color: isToastError ? Colors.redAccent : Colors.greenAccent),
                          const SizedBox(width: 8),
                          Text(toastMsg, style: TextStyle(color: isToastError ? Colors.red.shade100 : Colors.green.shade100, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Start Overlay (Curtain)
            if (step == 0)
              Positioned.fill(
                child: Container(
                  color: bgBase,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) => Container(
                                  width: 150 + _pulseController.value * 30, height: 150 + _pulseController.value * 30,
                                  decoration: BoxDecoration(color: themeAccent.withOpacity(0.3), shape: BoxShape.circle),
                                ),
                              ),
                              Container(
                                width: 120, height: 120,
                                decoration: BoxDecoration(gradient: LinearGradient(colors: [themeAccent, themePrimary]), borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20)]),
                                child: const Icon(Icons.architecture, size: 60, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(tr('app_title').toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2.0), textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          Text(tr('tagline').toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 3.0, fontFamily: 'monospace'), textAlign: TextAlign.center),
                          const SizedBox(height: 48),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: bgBase, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 10),
                            onPressed: () { playSound('success'); _nextStep(); },
                            child: Text(tr('start_mission'), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, fontSize: 16)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Final Success Popup
            if (isFinalSuccessVisible)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.85),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      constraints: BoxConstraints(maxWidth: 400, maxHeight: MediaQuery.of(context).size.height * 0.85),
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: panelBg, borderRadius: BorderRadius.circular(32), border: Border.all(color: themeSuccess, width: 4), boxShadow: [BoxShadow(color: themeSuccess.withOpacity(0.3), blurRadius: 60)]),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 100, height: 100,
                                    decoration: BoxDecoration(color: themeSuccess, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)]),
                                    child: const Icon(Icons.emoji_events, size: 50, color: Colors.black),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(tr('success_title').toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: themeSuccess, fontSize: 28, fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 16),
                                  Text(tr('total_area_36'), style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text(tr('mastery_level'), style: TextStyle(color: Colors.white.withOpacity(0.6), fontFamily: 'monospace', fontSize: 12, letterSpacing: 2.0)),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: themeSuccess, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: _globalReset, child: Text(tr('return_btn').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2.0))),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Painters ---
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    double spacing = 25.0; 

    Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), Paint()..color = Colors.white.withOpacity(0.1)..strokeWidth = 1);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), Paint()..color = Colors.white.withOpacity(0.1)..strokeWidth = 1);

    for (double i = center.dx % spacing; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = center.dy % spacing; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FieldPainter extends CustomPainter {
  final int step;
  final List<String> selection;
  final double pulseValue;
  final Color themeAccent;
  final Color themePrimary;
  final Color themeSuccess;
  final Offset pA, pB, pC, pD;

  FieldPainter({
    required this.step,
    required this.selection,
    required this.pulseValue,
    required this.themeAccent,
    required this.themePrimary,
    required this.themeSuccess,
    required this.pA, required this.pB, required this.pC, required this.pD
  });

  @override
  void paint(Canvas canvas, Size size) {
    double px = size.width / 2;
    double py = size.height / 2;
    // Adjusted scaling up for better visual presence on small screens
    double s = math.max(0.4, math.min(size.width / 350, size.height / 250) * 1.0);
    
    canvas.save();
    canvas.translate(px, py);
    canvas.scale(s, s);
    canvas.translate(0, -25); // Push up 25 points relative to scale to explicitly center geometry bounding box

    // Coordinate points
    Offset A = pA; Offset B = pB; Offset C = pC; Offset D = pD;

    // Filled Areas (Steps 7 & 8)
    if (step >= 7) {
      canvas.drawPath(Path()..moveTo(A.dx, A.dy)..lineTo(B.dx, B.dy)..lineTo(C.dx, C.dy)..close(), Paint()..color = themeSuccess.withOpacity(0.2)..style = PaintingStyle.fill);
    }
    if (step >= 8) {
      canvas.drawPath(Path()..moveTo(A.dx, A.dy)..lineTo(C.dx, C.dy)..lineTo(D.dx, D.dy)..close(), Paint()..color = const Color(0xFF06b6d4).withOpacity(0.2)..style = PaintingStyle.fill);
    }

    // Base Quad Borders
    Path quadPath = Path()..moveTo(A.dx, A.dy)..lineTo(B.dx, B.dy)..lineTo(C.dx, C.dy)..lineTo(D.dx, D.dy)..close();
    canvas.drawPath(quadPath, Paint()..color = const Color(0xFFe2e8f0)..strokeWidth = 3..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke);

    // Diagonal
    if (step >= 3 || selection.length == 2) {
      final Paint diagPaint = Paint()..color = themePrimary..strokeWidth = 3..style = PaintingStyle.stroke;
      _drawDashedLine(canvas, Path()..moveTo(A.dx, A.dy)..lineTo(C.dx, C.dy), diagPaint, [8, 4]);
      
      if (step >= 5) {
        _drawText(canvas, "b=12", Offset(0, 20), TextStyle(color: themePrimary, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'));
      }
    }

    // Altitudes
    if (step >= 5) {
      Offset h1Base = const Offset(50, 0); // Projection of B(50,100) onto AC
      final Paint altPaint = Paint()..color = themeAccent..strokeWidth = 2..style = PaintingStyle.stroke;
      _drawDashedLine(canvas, Path()..moveTo(B.dx, B.dy)..lineTo(h1Base.dx, h1Base.dy), altPaint, [5, 5]);
      if (step >= 6) {
        _drawText(canvas, "h₁=4", Offset(B.dx + 15, (B.dy + h1Base.dy) / 2), TextStyle(color: themeAccent, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'));
      }
    }
    
    if (step >= 6) {
      Offset h2Base = const Offset(0, 0); // Projection of D(0,-50) onto AC
      final Paint altPaint = Paint()..color = themeAccent..strokeWidth = 2..style = PaintingStyle.stroke;
      _drawDashedLine(canvas, Path()..moveTo(D.dx, D.dy)..lineTo(h2Base.dx, h2Base.dy), altPaint, [5, 5]);
      if (step >= 7) {
        _drawText(canvas, "h₂=2", Offset(D.dx + 15, (D.dy + h2Base.dy) / 2), TextStyle(color: themeAccent, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'));
      }
    }

    // Draw Nodes
    void drawNode(Offset pos, String label, bool isSelected) {
      double r = isSelected ? 8 : 6;
      
      if (step == 2 && (label == 'A' || label == 'C') && !isSelected) {
        r = 8 + pulseValue * 4;
        canvas.drawCircle(pos, r + 5, Paint()..color = themeAccent.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      }

      canvas.drawCircle(pos, r, Paint()..color = isSelected ? themeAccent : const Color(0xFF0ea5e9));
      
      double ox = label == 'A' ? -22 : label == 'C' ? 12 : 12;
      double oy = label == 'B' ? 22 : label == 'D' ? -12 : -12;
      
      TextPainter tp = TextPainter(text: TextSpan(text: label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(pos.dx + ox, pos.dy + oy));
    }

    drawNode(A, "A", selection.contains('A'));
    drawNode(B, "B", false);
    drawNode(C, "C", selection.contains('C'));
    drawNode(D, "D", false);

    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    tp.layout();
    tp.paint(canvas, Offset(offset.dx - tp.width / 2, offset.dy - tp.height / 2));
  }

  void _drawDashedLine(Canvas canvas, Path path, Paint paint, List<double> dashArray) {
    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      int dashIndex = 0;
      bool draw = true;
      while (distance < pathMetric.length) {
        double len = dashArray[dashIndex % dashArray.length];
        if (draw) canvas.drawPath(pathMetric.extractPath(distance, distance + len), paint);
        distance += len;
        draw = !draw;
        dashIndex++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant FieldPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.pulseValue != pulseValue || oldDelegate.selection.length != selection.length;
  }
}