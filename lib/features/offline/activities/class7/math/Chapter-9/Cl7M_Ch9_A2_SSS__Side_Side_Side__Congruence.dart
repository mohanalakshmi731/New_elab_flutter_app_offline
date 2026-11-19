// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZSLVirtualLabApp());
}

class ZSLVirtualLabApp extends StatelessWidget {
  const ZSLVirtualLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geometric Twins: The SSS Blueprint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617), // zslDark
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366f1),
          secondary: Color(0xFF10b981),
          error: Color(0xFFf43f5e),
        ),
      ),
      home: const SSSCongruenceLab(),
    );
  }
}

class SSSCongruenceLab extends StatefulWidget {
  const SSSCongruenceLab({super.key});

  @override
  State<SSSCongruenceLab> createState() => _SSSCongruenceLabState();
}

class _SSSCongruenceLabState extends State<SSSCongruenceLab> with TickerProviderStateMixin {
  // --- Core State ---
  bool _isSidebarOpen = true; 
  bool _showCurtain = true;
  bool _showFinalPopup = false;
  String _lang = 'en';

  // --- Canvas Transform ---
  double _zoom = 1.0;
  Offset _pan = Offset.zero;
  double _baseZoom = 1.0;

  // --- Scenario State ---
  int _scenario = 1;
  int _step = 0;

  // --- Simulation State ---
  List<Rod> _rods = [];
  bool _triangleFormed = false;
  bool _superimposed = false;
  bool _mismatch = false;
  Offset _triPos = Offset.zero;
  int _rotation = 0;
  bool _flipped = false;

  // Scenario 5 Specific
  bool _kiteIdentified = false;
  bool _kiteFly = false;
  double _kiteOffsetY = 0;

  // --- Audio Players (Dedicated & Cached) ---
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Network Audio Sources
  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _alertUrl = 'audio/class7/mixkit_2869.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';

  // --- Animation & Scroll ---
  late AnimationController _curtainAnimCtrl;
  late Animation<double> _curtainAnim;
  late AnimationController _kiteAnimCtrl;
  final ScrollController _sidebarScrollCtrl = ScrollController();

  // --- Interaction State ---
  String? _draggingTool;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _curtainAnimCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _curtainAnim = Tween<double>(begin: 0.0, end: -1.0).animate(
      CurvedAnimation(parent: _curtainAnimCtrl, curve: Curves.easeInOutCubic),
    );

    _kiteAnimCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _kiteAnimCtrl.addListener(() {
      if (_kiteFly) {
        setState(() {
          _kiteOffsetY = -(_kiteAnimCtrl.value * 200);
        });
      }
    });

    _loadScenario(1, playSound: false);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _curtainAnimCtrl.dispose();
    _kiteAnimCtrl.dispose();
    _sidebarScrollCtrl.dispose();
    super.dispose();
  }

  // --- Audio Helpers ---
  void _playClick() { try { _clickPlayer.play(AssetSource(_clickUrl)); } catch (_) {} }
  void _playSuccess() { try { _successPlayer.play(AssetSource(_successUrl)); } catch (_) {} }
  void _playError() { try { _errorPlayer.play(AssetSource(_errorUrl)); } catch (_) {} }
  void _playFx() { try { _fxPlayer.play(AssetSource(_alertUrl)); } catch (_) {} }
  void _playShutter() { try { _shutterPlayer.play(AssetSource(_shutterUrl)); } catch (_) {} }

  // --- Translations ---
  String t(String key) {
    Map<String, Map<String, String>> translations = {
      'en': {
        'appTitle': 'Geometric Twins: The SSS Blueprint',
        'appSubtitle': 'Class 7 • GEOMETRIC TWINS',
        'enterLab': 'Enter Lab',
        'selectScenario': 'SELECT SCENARIO',
        'learnLbl': 'What We Learn:',
        'stepLabel': 'STEP',
        'footer': '© ZeroScienceLab - Fall in love with math and Science',
        'congruentLbl': 'CONGRUENT!',
        'mismatchLbl': 'MISMATCH',
        'lblConstZone': 'Construction Zone',
        'lblTarget': 'Target Blueprint',
        'lblPartsBin': 'Parts Bin',
        'summaryTitle': 'Discovery Made!',
        'nextScenario': 'Next Scenario',
        'finishLab': 'Finish Lab',
        'labCompleted': 'Lab Completed!',
        'finalDesc': 'You have successfully mastered the SSS congruence criterion! You verified that triangles with exact matching side lengths are always congruent.',
        'resetBtn': 'Reset Activity',
        's1_title': '1. The Perfect Copy',
        's1_obj': 'Construct a triangle using three given side lengths and observe how identical lengths guarantee an identical shape.',
        's1_hud1': 'DRAG the longest segment (8) into the Construction Zone.',
        's1_step1_task': 'Drag the longest green segment (length 8) into the Construction Zone to form the base.',
        's1_step1_out': 'The base is fixed. This sets the structural foundation.',
        's1_hud2': 'DRAG segments 5 and 7 and CONNECT one to each endpoint.',
        's1_step2_task': 'Attach the 5 and 7 unit segments to each endpoint of the base.',
        's1_step2_out': 'They act like hinges. You can swing them, but their lengths are strictly fixed.',
        's1_hud3': 'DRAG the free ends towards each other until they snap.',
        's1_step3_task': 'Drag the free ends towards each other until they meet.',
        's1_step3_out': 'Shape is locked! Only ONE unique triangle can be formed with these lengths.',
        's1_hud4': 'DROP your rigid triangle onto the target blueprint.',
        's1_step4_task': 'Superimpose your constructed triangle onto the blue target blueprint.',
        's1_step4_out': 'Perfect Match! If three sides equal three sides, they are identical (SSS Congruence).',
        's1_sum': 'Perfect Match! SSS Congruence Confirmed. Three exactly matching sides guarantee the triangles are identical.',
        's2_title': '2. The Flipped Twin',
        's2_obj': 'Understand that changing orientation (flipping/rotating) does not change congruence.',
        's2_hud1': 'Assemble the 6, 8, and 10 unit segments into a triangle.',
        's2_step1_task': 'Drag the 10-unit base, attach 6 and 8 unit sides to build it.',
        's2_step1_out': 'You constructed a rigid triangle.',
        's2_hud2': 'DRAG the triangle towards the blue blueprint.',
        's2_step2_task': 'Drag your assembled triangle over to the target blueprint.',
        's2_step2_out': 'It doesn\'t fit! The target has identical lengths but different orientation.',
        's2_hud3': 'Use Rotate and Flip tools to match target\'s orientation.',
        's2_step3_task': 'Use the floating Rotate and Flip tools on your triangle.',
        's2_step3_out': 'Transforming shape in space doesn\'t alter its fixed side lengths.',
        's2_hud4': 'DRAG your re-oriented triangle onto the blueprint.',
        's2_step4_task': 'Once orientation visually matches, drag it onto the blueprint.',
        's2_step4_out': 'It superimposes perfectly! Congruence holds regardless of flip/turn.',
        's2_sum': 'Orientation Independence: Congruent shapes remain congruent even if flipped or rotated.',
        's3_title': '3. The Near Miss',
        's3_obj': 'Visually prove that having even one incorrect side length breaks congruence.',
        's3_hud1': 'Assemble a triangle with lengths 11, 5, and 9.',
        's3_step1_task': 'Build triangle using 11 unit base, attach 5 and 9 unit segments.',
        's3_step1_out': 'You formed a valid triangle, but base is slightly longer than blueprint.',
        's3_hud2': 'DRAG the 11-5-9 triangle over the 10-5-9 blueprint.',
        's3_step2_task': 'Blueprint requires 10-5-9. Drag your 11-5-9 over it to test.',
        's3_step2_out': 'Red mismatch indicator appears. Lengths do not align.',
        's3_hud3': 'Notice the MISMATCH. Congruence requires EXACT lengths.',
        's3_step3_task': 'Observe the failure of shapes to superimpose.',
        's3_step3_out': 'Even one differing side alters shape. SSS requires exact matches.',
        's3_sum': 'Exact Matching Required: If all three sides are not identical pairs, triangles are not congruent.',
        's4_title': '4. Bridge Blueprint Assembly',
        's4_obj': 'Apply SSS to select correct structural components for a rigid engineering truss.',
        's4_hud1': 'Assemble exactly 10, 7, and 7 in the Construction Zone.',
        's4_step1_task': 'Drag correct three rods from Parts Bin and snap them together.',
        's4_step1_out': 'You must select right materials to fulfill the requirement.',
        's4_hud2': 'Use the red Dismantle tool if you made a mistake.',
        's4_step2_task': 'Ensure triangle is exactly 10-7-7.',
        's4_step2_out': 'Fixed side lengths lock truss into a stable shape.',
        's4_hud3': 'DRAG the completed truss to the blueprint.',
        's4_step3_task': 'Place constructed truss onto the blueprint.',
        's4_step3_out': 'Perfect SSS match. Engineers rely on SSS for pre-manufactured parts.',
        's4_sum': 'Structural Rigidity: SSS is used heavily in engineering because fixed lengths guarantee specific, unbending shapes.',
        's5_title': '5. The Kite Symmetry',
        's5_obj': 'Identify hidden SSS congruent triangles within a larger geometric structure.',
        's5_hud1': 'CLICK the triangle that mirrors the empty frame.',
        's5_step1_task': 'Click the highlighted triangle perfectly mirroring the empty frame on right.',
        's5_step1_out': 'Clicking reveals its hidden side lengths: 9, 12, 15.',
        's5_hud2': 'Assemble 15, 12, and 9 in Construction Zone.',
        's5_step2_task': 'Drag 15, 12, and 9 rods from Parts Bin and assemble.',
        's5_step2_out': 'Materials are locked into 15-12-9 configuration.',
        's5_hud3': 'DRAG completed triangle into empty frame to fly kite!',
        's5_step3_task': 'Use Flip/Rotate tools, then place into empty frame.',
        's5_step3_out': 'Kite complete! Central diagonal shared by both triangles satisfies SSS.',
        's5_sum': 'Shared Sides Count! A shared boundary acts as an equal length for both triangles, fulfilling SSS.'
      },
      'hi': {
        'appTitle': 'ज्यामितीय जुड़वाँ: SSS ब्लूप्रिंट',
        'appSubtitle': 'कक्षा 7 • ज्यामितीय जुड़वाँ',
        'enterLab': 'लैब में प्रवेश करें',
        'selectScenario': 'परिदृश्य चुनें',
        'learnLbl': 'हम क्या सीखते हैं:',
        'stepLabel': 'चरण',
        'footer': '© ZeroScienceLab - Fall in love with math and Science',
        'congruentLbl': 'सर्वांगसम!',
        'mismatchLbl': 'बेमेल',
        'lblConstZone': 'निर्माण क्षेत्र',
        'lblTarget': 'लक्ष्य ब्लूप्रिंट',
        'lblPartsBin': 'पार्ट्स बिन',
        'summaryTitle': 'खोज की गई!',
        'nextScenario': 'अगला परिदृश्य',
        'finishLab': 'लैब समाप्त करें',
        'labCompleted': 'लैब पूर्ण!',
        'finalDesc': 'आपने SSS सर्वांगसमता मानदंड में महारत हासिल कर ली है! आपने सत्यापित किया है कि सटीक समान भुजाओं की लंबाई वाले त्रिभुज हमेशा सर्वांगसम होते हैं।',
        'resetBtn': 'गतिविधि रीसेट करें',
        's1_title': '1. एकदम सही प्रतिलिपि',
        's1_obj': 'दी गई तीन भुजाओं की लंबाई का उपयोग करके एक त्रिभुज बनाना।',
        's1_hud1': 'सबसे लंबे खंड (8) को निर्माण क्षेत्र में खींचें।',
        's1_step1_task': 'आधार बनाने के लिए सबसे लंबे खंड को खींचें।',
        's1_step1_out': 'आधार तय हो गया है।',
        's1_hud2': '5 और 7 के खंडों को प्रत्येक छोर से जोड़ें।',
        's1_step2_task': '5 और 7 इकाई के खंडों को आधार के छोर से संलग्न करें।',
        's1_step2_out': 'वे टिका (hinge) की तरह कार्य करते हैं।',
        's1_hud3': 'स्वतंत्र सिरों को एक दूसरे की ओर तब तक खींचें जब तक वे जुड़ न जाएं।',
        's1_step3_task': 'स्वतंत्र सिरों को एक-दूसरे की ओर खींचें।',
        's1_step3_out': 'आकार लॉक हो गया है! केवल एक अद्वितीय त्रिभुज बन सकता है।',
        's1_hud4': 'त्रिभुज को लक्ष्य ब्लूप्रिंट पर छोड़ें।',
        's1_step4_task': 'नवनिर्मित त्रिभुज को नीले लक्ष्य ब्लूप्रिंट पर आरोपित करें।',
        's1_step4_out': 'एकदम सही मेल! (SSS सर्वांगसमता)',
        's1_sum': 'एकदम सही मेल! SSS सर्वांगसमता की पुष्टि।',
        's2_title': '2. पलटा हुआ जुड़वां',
        's2_obj': 'समझना कि दिशा बदलने से सर्वांगसमता नहीं बदलती।',
        's2_hud1': '6, 8, 10 इकाई के खंडों को इकट्ठा करें।',
        's2_step1_task': '10 का आधार लें, 6 और 8 की भुजाओं को संलग्न करें।',
        's2_step1_out': 'कठोर त्रिभुज का निर्माण किया।',
        's2_hud2': 'त्रिभुज को नीले लक्ष्य की ओर खींचें।',
        's2_step2_task': 'त्रिभुज को लक्ष्य ब्लूप्रिंट के ऊपर खींचें।',
        's2_step2_out': 'यह फिट नहीं होता! दिशा अलग है।',
        's2_hud3': 'रोटेट और फ्लिप टूल का उपयोग करें।',
        's2_step3_task': 'रोटेट और फ्लिप टूल से दिशा बदलें।',
        's2_step3_out': 'आकार बदलने से लंबाई नहीं बदलती।',
        's2_hud4': 'त्रिभुज को ब्लूप्रिंट पर खींचें।',
        's2_step4_task': 'दिशा मिलने पर, ब्लूप्रिंट पर छोड़ें।',
        's2_step4_out': 'पूरी तरह फिट! सर्वांगसमता सत्य है।',
        's2_sum': 'दिशा स्वतंत्रता: आकार पलटने या घुमाने पर भी सर्वांगसम रहते हैं।',
        's3_title': '3. लगभग चूक',
        's3_obj': 'गलत भुजा से सर्वांगसमता टूटती है।',
        's3_hud1': '11, 5, 9 से त्रिभुज बनाएं।',
        's3_step1_task': '11 के आधार पर 5 और 9 संलग्न करें।',
        's3_step1_out': 'वैध त्रिभुज, लेकिन आधार लंबा है।',
        's3_hud2': '11-5-9 त्रिभुज को 10-5-9 पर खींचें।',
        's3_step2_task': '11-5-9 त्रिभुज को 10-5-9 लक्ष्य पर जांचें।',
        's3_step2_out': 'लाल बेमेल संकेतक।',
        's3_hud3': 'सर्वांगसमता के लिए सटीक लंबाई चाहिए।',
        's3_step3_task': 'आरोपित होने में विफलता देखें।',
        's3_step3_out': 'SSS के लिए तीनों जोड़ियों का मेल आवश्यक है।',
        's3_sum': 'सटीक मिलान आवश्यक: तीनों भुजाएँ समान होनी चाहिए।',
        's4_title': '4. ब्रिज ब्लूप्रिंट',
        's4_obj': 'इंजीनियरिंग ट्रस के लिए सही घटकों का चयन।',
        's4_hud1': '10, 7, 7 को इकट्ठा करें।',
        's4_step1_task': 'पार्ट्स बिन से सही छड़ें चुनें।',
        's4_step1_out': 'सही सामग्री चुनना जरूरी।',
        's4_hud2': 'गलती पर डिसमेंटल टूल उपयोग करें।',
        's4_step2_task': 'सुनिश्चित करें त्रिभुज 10-7-7 है।',
        's4_step2_out': 'निश्चित भुजाओं की लंबाई आकार लॉक करती है।',
        's4_hud3': 'पूर्ण ट्रस को ब्लूप्रिंट पर खींचें।',
        's4_step3_task': 'ट्रस को ब्लूप्रिंट पर रखें।',
        's4_step3_out': 'इंजीनियर SSS पर भरोसा करते हैं।',
        's4_sum': 'संरचनात्मक कठोरता: SSS निश्चित आकार की गारंटी देती है।',
        's5_title': '5. पतंग समरूपता',
        's5_obj': 'छिपे हुए SSS सर्वांगसम त्रिभुजों की पहचान।',
        's5_hud1': 'दर्पण-छवि त्रिभुज पर क्लिक करें।',
        's5_step1_task': 'खाली फ्रेम के अक्स वाले त्रिभुज पर क्लिक करें।',
        's5_step1_out': 'छिपी हुई भुजाओं का पता चलता है (9, 12, 15)।',
        's5_hud2': '15, 12, 9 को इकट्ठा करें।',
        's5_step2_task': '15, 12, 9 छड़ों को इकट्ठा करें।',
        's5_step2_out': 'सामग्री 15-12-9 में लॉक हो गई।',
        's5_hud3': 'त्रिभुज को खाली फ्रेम में खींचें!',
        's5_step3_task': 'दिशा बदलें और खाली फ्रेम में रखें।',
        's5_step3_out': 'पतंग पूरी हो गई! साझा विकर्ण SSS को संतुष्ट करता है।',
        's5_sum': 'साझा भुजाएँ मायने रखती हैं! साझा सीमा SSS शर्त पूरी करती है।'
      }
    };
    return translations[_lang]?[key] ?? translations['en']![key] ?? key;
  }

  // --- Scenario Setup ---
  void _resetToShutter() {
    _playShutter();
    setState(() {
      _lang = 'en';
      _showCurtain = true;
      _showFinalPopup = false;
      _curtainAnimCtrl.value = 0.0; // Reset animation to start
    });
    _loadScenario(1, playSound: false);
  }

  void _loadScenario(int id, {bool playSound = true}) {
    setState(() {
      if (playSound) _playClick();
      _scenario = id;
      _step = 0;
      _triangleFormed = false;
      _superimposed = false;
      _mismatch = false;
      _rotation = 0;
      _flipped = false;
      _triPos = Offset.zero;
      _kiteIdentified = false;
      _kiteFly = false;
      _kiteOffsetY = 0;
      _showFinalPopup = false;
      _zoom = 1.0;
      _pan = Offset.zero;
      _kiteAnimCtrl.reset();

      if (id == 1) {
        _rods = [
          Rod(id: 1, len: 8, ox: 220, oy: -100),
          Rod(id: 2, len: 5, ox: 220, oy: -20),
          Rod(id: 3, len: 7, ox: 220, oy: 60),
        ];
      } else if (id == 2) {
        _rods = [
          Rod(id: 1, len: 10, ox: 220, oy: -100),
          Rod(id: 2, len: 6, ox: 220, oy: -20),
          Rod(id: 3, len: 8, ox: 220, oy: 60),
        ];
      } else if (id == 3) {
        _rods = [
          Rod(id: 1, len: 11, ox: 280, oy: -100),
          Rod(id: 2, len: 5, ox: 280, oy: -20),
          Rod(id: 3, len: 9, ox: 280, oy: 60),
        ];
      } else if (id == 4) {
        _rods = [
          Rod(id: 1, len: 10, ox: 310, oy: -150),
          Rod(id: 2, len: 7, ox: 310, oy: -80),
          Rod(id: 3, len: 7, ox: 310, oy: -10),
          Rod(id: 4, len: 8, ox: 310, oy: 60),
          Rod(id: 5, len: 12, ox: 310, oy: 130),
        ];
      } else if (id == 5) {
        _rods = [
          Rod(id: 1, len: 15, ox: 320, oy: -150),
          Rod(id: 2, len: 12, ox: 320, oy: -80),
          Rod(id: 3, len: 9, ox: 320, oy: -10),
          Rod(id: 4, len: 13, ox: 320, oy: 60),
          Rod(id: 5, len: 5, ox: 320, oy: 130),
        ];
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_sidebarScrollCtrl.hasClients) {
        _sidebarScrollCtrl.animateTo(
          _sidebarScrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _advanceStep() {
    setState(() {
      _step++;
    });
    _scrollToBottom();
  }

  void _checkSuccess() {
    if (_step == 1 && _scenario == 4) _step++; // Skip manual dismantle step on success
    _advanceStep();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_mismatch) _playError(); else _playSuccess();
    });
  }

  // --- Interaction Logic ---
  Offset _getScreenToWorld(Offset screenPoint, Size canvasSize) {
    Matrix4 transform = Matrix4.identity()
      ..translate(canvasSize.width / 2 + _pan.dx, canvasSize.height / 2 + _pan.dy)
      ..scale(_zoom);
    return MatrixUtils.transformPoint(Matrix4.inverted(transform), screenPoint);
  }

  void _onScaleStart(ScaleStartDetails details, Size canvasSize) {
    _baseZoom = _zoom;
    _draggingTool = null;

    if (details.pointerCount >= 2) return; // Dedicated to pan/zoom gesture

    Offset pt = _getScreenToWorld(details.localFocalPoint, canvasSize);
    double scale = (_scenario >= 4) ? (_scenario == 4 ? 20.0 : 15.0) : 25.0;
    if (_scenario == 2) scale = 20.0;
    if (_scenario == 4) scale = 20.0;

    // Special Kite Tap for Scenario 5, Step 0
    if (_scenario == 5 && _step == 0) {
      double kcx = -120;
      double kcy = -20 + _kiteOffsetY;
      double kTopY = kcy - 112.5;
      double kBotY = kcy + 112.5;
      double kLeftX = kcx - 108;

      if (pt.dx > kLeftX - 30 && pt.dx < kcx + 10 && pt.dy > kTopY - 30 && pt.dy < kBotY + 30) {
        setState(() {
          _kiteIdentified = true;
          _playSuccess();
          _advanceStep();
        });
        return;
      }
    }

    if (!_triangleFormed) {
      for (var r in _rods) {
        double rW = r.len * scale;
        
        // Base / Straight Rod interaction
        if ((r.state == 0 || r.state == 1) && _hitTestLine(r.cx, r.cy, r.cx + rW, r.cy, pt)) {
          _draggingTool = 'rod_${r.id}';
          _dragOffset = Offset(r.cx - pt.dx, r.cy - pt.dy);
          _playClick();
          break;
        } 
        // Angled Rod Interaction (state 2 or 3)
        else if (r.state == 2 || r.state == 3) {
          Offset endPt = Offset(r.cx + rW * math.cos(r.angle), r.cy + rW * math.sin(r.angle));
          
          // Touch target for rotating the hinge
          if ((pt - endPt).distance < 80) {
            _draggingTool = r.state == 2 ? 'p_left' : 'p_right';
            _playClick();
            break;
          } 
          // Dragging the rod itself to dismantle/move
          else if (_hitTestLine(r.cx, r.cy, endPt.dx, endPt.dy, pt)) {
            _draggingTool = 'rod_${r.id}';
            _dragOffset = Offset(r.cx - pt.dx, r.cy - pt.dy);
            _playClick();
            break;
          }
        }
      }
    } else if (!_superimposed) {
      // Dragging formed triangle
      Offset centroid = _getTriangleCentroid();
      if ((pt - centroid).distance < 200) {
        _draggingTool = 'tri';
        _dragOffset = Offset(_triPos.dx - pt.dx, _triPos.dy - pt.dy);
        _playClick();
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details, Size canvasSize) {
    if (_draggingTool == null) {
      // Canvas Pan & Zoom
      setState(() {
        _pan += details.focalPointDelta;
        if (details.scale != 1.0) {
          _zoom = (_baseZoom * details.scale).clamp(0.3, 3.0);
        }
      });
      return;
    }
    
    // Using tools/rods
    Offset pt = _getScreenToWorld(details.localFocalPoint, canvasSize);
    setState(() {
      if (_draggingTool == 'tri') {
        _triPos = Offset(pt.dx + _dragOffset.dx, pt.dy + _dragOffset.dy);
      } else if (_draggingTool!.startsWith('rod_')) {
        int id = int.parse(_draggingTool!.split('_')[1]);
        Rod? r = _rods.where((x) => x.id == id).firstOrNull;
        if (r != null) {
          r.cx = pt.dx + _dragOffset.dx;
          r.cy = pt.dy + _dragOffset.dy;
        }
      } else if (_draggingTool == 'p_left') {
        Rod? r = _rods.where((x) => x.state == 2).firstOrNull;
        double wx = (_scenario >= 4) ? (_scenario == 4 ? 20 : 60) : -30;
        double wy = (_scenario >= 4) ? 150 : 120;
        if (r != null) {
          r.angle = math.atan2(pt.dy - wy, pt.dx - wx);
        }
      } else if (_draggingTool == 'p_right') {
        Rod? b = _rods.where((x) => x.state == 1).firstOrNull;
        Rod? r = _rods.where((x) => x.state == 3).firstOrNull;
        double scale = (_scenario >= 4) ? (_scenario == 4 ? 20.0 : 15.0) : 25.0;
        if (_scenario == 2) scale = 20.0;
        if (_scenario == 4) scale = 20.0;
        double wx = (_scenario >= 4) ? (_scenario == 4 ? 20 : 60) : -30;
        double wy = (_scenario >= 4) ? 150 : 120;
        if (b != null && r != null) {
          r.angle = math.atan2(pt.dy - wy, pt.dx - (wx + b.len * scale));
        }
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_draggingTool == null) return;
    String tool = _draggingTool!;
    _draggingTool = null;

    double wx = (_scenario >= 4) ? (_scenario == 4 ? 20 : 60) : -30;
    double wy = (_scenario >= 4) ? 150 : 120;
    double scale = (_scenario >= 4) ? (_scenario == 4 ? 20.0 : 15.0) : 25.0;
    if (_scenario == 2) scale = 20.0;
    if (_scenario == 4) scale = 20.0;
    double snapRadius = 150.0; // Increased radius for better touch targeting

    setState(() {
      if (tool.startsWith('rod_')) {
        int id = int.parse(tool.split('_')[1]);
        Rod? r = _rods.where((x) => x.id == id).firstOrNull;
        if (r != null) {
          Rod? b = _rods.where((x) => x.state == 1).firstOrNull;
          if (b == null) {
            // Snap to base
            if ((Offset(r.cx, r.cy) - Offset(wx, wy)).distance < snapRadius ||
                (Offset(r.cx + r.len * scale, r.cy) - Offset(wx, wy)).distance < snapRadius) {
              r.state = 1;
              r.cx = wx;
              r.cy = wy;
              r.angle = 0;
              _playFx();
              if (_scenario < 4 && _step == 0) _advanceStep();
            }
          } else if (r.state != 1) {
            // Snap to legs
            double dL = (Offset(r.cx, r.cy) - Offset(wx, wy)).distance;
            double dR = (Offset(r.cx + r.len * scale, r.cy) - Offset(wx, wy)).distance;
            double dL_R = (Offset(r.cx, r.cy) - Offset(wx + b.len * scale, wy)).distance;
            double dR_R = (Offset(r.cx + r.len * scale, r.cy) - Offset(wx + b.len * scale, wy)).distance;

            bool hasL = _rods.any((x) => x.state == 2);
            bool hasR = _rods.any((x) => x.state == 3);

            if (!hasL && (dL < snapRadius || dR < snapRadius)) {
              r.state = 2;
              r.cx = wx;
              r.cy = wy;
              r.angle = -math.pi / 2;
              _playFx();
            } else if (!hasR && (dL_R < snapRadius || dR_R < snapRadius)) {
              r.state = 3;
              r.cx = wx + b.len * scale;
              r.cy = wy;
              r.angle = -math.pi / 2;
              _playFx();
            }
            if (_scenario < 4 && _step == 1 && _rods.where((x) => x.state == 2 || x.state == 3).length == 2) {
              _advanceStep();
            }
          }
        }
      } else if (tool == 'p_left' || tool == 'p_right') {
        Rod? b = _rods.where((x) => x.state == 1).firstOrNull;
        Rod? r2 = _rods.where((x) => x.state == 2).firstOrNull;
        Rod? r3 = _rods.where((x) => x.state == 3).firstOrNull;
        if (b != null && r2 != null && r3 != null) {
          Offset eL = Offset(wx + r2.len * scale * math.cos(r2.angle), wy + r2.len * scale * math.sin(r2.angle));
          Offset eR = Offset(wx + b.len * scale + r3.len * scale * math.cos(r3.angle), wy + r3.len * scale * math.sin(r3.angle));
          if ((eL - eR).distance < snapRadius) {
            if (r2.len + r3.len > b.len && (r2.len - r3.len).abs() < b.len) {
              _triangleFormed = true;
              _triPos = Offset(wx, wy);
              double bL = b.len * scale;
              double lL = r2.len * scale;
              double rL = r3.len * scale;
              double cosLeft = (lL * lL + bL * bL - rL * rL) / (2 * lL * bL);
              r2.angle = -math.acos(cosLeft);
              double cosRight = (rL * rL + bL * bL - lL * lL) / (2 * rL * bL);
              r3.angle = math.pi + math.acos(cosRight);
              _playFx();
              if (_scenario < 4 && _step == 2) _advanceStep();
              else if (_scenario == 4 && _step == 0) _advanceStep();
              else if (_scenario == 5 && _step == 1) _advanceStep();
            } else {
              _playError();
            }
          }
        }
      } else if (tool == 'tri') {
        _checkSuperimpose();
      }
    });
  }

  void _checkSuperimpose() {
    double scale = (_scenario >= 4) ? (_scenario == 4 ? 20.0 : 15.0) : 25.0;
    if (_scenario == 2) scale = 20.0;
    if (_scenario == 4) scale = 20.0;
    double wx = (_scenario >= 4) ? (_scenario == 4 ? 20 : 60) : -30;
    double wy = (_scenario >= 4) ? 150 : 120;
    double tx = (_scenario >= 4) ? (_scenario == 4 ? -200 : -120) : -250;
    double ty = (_scenario >= 4) ? (_scenario == 4 ? 80 : -20) : -60;
    if (_scenario == 2) { tx = -250; ty = -100; }
    if (_scenario == 5) { ty = -20; }

    Rod b = _rods.firstWhere((x) => x.state == 1);
    Rod r2 = _rods.firstWhere((x) => x.state == 2);
    
    List<Offset> pts = [
      const Offset(0, 0),
      Offset(b.len * scale, 0),
      Offset(r2.len * scale * math.cos(r2.angle), r2.len * scale * math.sin(r2.angle))
    ];
    Offset centroid = _getTriangleCentroid();

    Offset targetCentroid;
    List<Offset> targetPts = [];

    if (_scenario == 1) {
      targetCentroid = Offset(tx + 100, ty - 35);
    } else if (_scenario == 2) {
      targetCentroid = Offset(tx - 32, ty + 90);
      targetPts = [Offset(tx, ty), Offset(tx, ty + 200), Offset(tx - 96, ty + 72)];
    } else if (_scenario == 3) {
      targetCentroid = Offset(tx + 125, ty - 35);
    } else if (_scenario == 4) {
      targetCentroid = Offset(tx + 100, ty - 40);
      targetPts = [Offset(tx, ty), Offset(tx + 200, ty), Offset(tx + 100, ty - 98)];
    } else if (_scenario == 5) {
      double kcx = -120; double kcy = -20 + _kiteOffsetY;
      double kTopY = kcy - 112.5; double kBotY = kcy + 112.5;
      double crossY = kTopY + 81; double kRightX = kcx + 108;
      targetCentroid = Offset(kcx + 36, crossY + 21);
      targetPts = [Offset(kcx, kTopY), Offset(kRightX, crossY), Offset(kcx, kBotY)];
    } else {
      targetCentroid = Offset.zero;
    }

    if (_scenario == 2 || _scenario == 4 || _scenario == 5) {
      if (_matchVertices(_getUserTriWorld(pts, _triPos), targetPts)) {
        if (_scenario == 4 && (b.len != 10 || r2.len != 7 || _rods.firstWhere((x)=>x.state==3).len != 7)) {
          _mismatch = true;
          _triPos = Offset(wx, wy);
          _playError();
        } else if (_scenario == 5 && (_rods.where((r) => r.state > 0 && (r.len == 9 || r.len == 12 || r.len == 15)).length != 3)) {
          _mismatch = true;
          _triPos = Offset(wx, wy);
          _playError();
        } else {
          _triPos = Offset(tx, ty);
          _superimposed = true;
          if (_scenario == 5) {
            _kiteFly = true;
            _kiteAnimCtrl.forward();
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) setState(() { _showFinalPopup = true; });
            });
          }
          _checkSuccess();
        }
      } else if ((centroid - targetCentroid).distance < 200) {
        _triPos = Offset(wx, wy);
        if (_scenario == 4) _mismatch = true;
        _playError();
        if (_scenario == 2 && _step == 1) _advanceStep();
      }
    } else {
      if ((centroid - targetCentroid).distance < 180) {
        _triPos = Offset(tx, ty);
        _superimposed = true;
        if (_scenario == 3) _mismatch = true;
        _checkSuccess();
      }
    }
  }

  bool _matchVertices(List<Offset> t1, List<Offset> t2) {
    if (t1.isEmpty || t2.isEmpty) return false;
    List<bool> matched = [false, false, false];
    for (int i = 0; i < 3; i++) {
      bool found = false;
      for (int j = 0; j < 3; j++) {
        if (!matched[j] && (t1[i] - t2[j]).distance < 60) {
          matched[j] = true;
          found = true;
          break;
        }
      }
      if (!found) return false;
    }
    return true;
  }

  Offset _getTriangleCentroid() {
    Rod b = _rods.firstWhere((x) => x.state == 1);
    Rod r2 = _rods.firstWhere((x) => x.state == 2);
    double scale = (_scenario >= 4) ? (_scenario == 4 ? 20.0 : 15.0) : 25.0;
    if (_scenario == 2) scale = 20.0;
    if (_scenario == 4) scale = 20.0;
    List<Offset> pts = [
      const Offset(0, 0),
      Offset(b.len * scale, 0),
      Offset(r2.len * scale * math.cos(r2.angle), r2.len * scale * math.sin(r2.angle))
    ];
    return _getUserTriWorldCentroid(pts, _triPos);
  }

  List<Offset> _getUserTriWorld(List<Offset> pts, Offset triPos) {
    double cx = (pts[0].dx + pts[1].dx + pts[2].dx) / 3;
    double cy = (pts[0].dy + pts[1].dy + pts[2].dy) / 3;
    double ang = _rotation * math.pi / 2;
    return pts.map((p) {
      double nx = (p.dx - cx) * (_flipped ? -1 : 1);
      double ny = p.dy - cy;
      double rx = nx * math.cos(ang) - ny * math.sin(ang);
      double ry = nx * math.sin(ang) + ny * math.cos(ang);
      return Offset(triPos.dx + rx + cx, triPos.dy + ry + cy);
    }).toList();
  }

  Offset _getUserTriWorldCentroid(List<Offset> pts, Offset triPos) {
    double cx = (pts[0].dx + pts[1].dx + pts[2].dx) / 3;
    double cy = (pts[0].dy + pts[1].dy + pts[2].dy) / 3;
    return Offset(triPos.dx + cx, triPos.dy + cy);
  }

  bool _hitTestLine(double x1, double y1, double x2, double y2, Offset pt) {
    double cx = (x1 + x2) / 2;
    double cy = (y1 + y2) / 2;
    double len = (Offset(x2, y2) - Offset(x1, y1)).distance;
    return (pt - Offset(cx, cy)).distance < math.max(len / 2, 30.0) + 40.0; // Increased padding
  }

  // --- Dynamic Tools ---
  void _toolRotate() {
    setState(() {
      _rotation = (_rotation + 1) % 4;
      _playClick();
    });
  }

  void _toolFlip() {
    setState(() {
      _flipped = !_flipped;
      _playClick();
    });
  }

  void _toolDismantle() {
    setState(() {
      _triangleFormed = false;
      _superimposed = false;
      _mismatch = false;
      _rotation = 0;
      _flipped = false;
      for (var r in _rods) {
        if (r.state != 0) {
          r.state = 0;
          r.cx = r.ox;
          r.cy = r.oy;
        }
      }
      _step = (_scenario == 5) ? 1 : 0;
      _playClick();
    });
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    double sidebarW = math.max(300.0, sw * 0.38);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // 1. Layout using Row
            Row(
              children: [
                // Sidebar Area
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  width: _isSidebarOpen ? sidebarW : 0,
                  child: ClipRect(child: _buildSidebar()),
                ),
                
                // Canvas Area (Clipped strictly to prevent drawing over sidebar)
                Expanded(
                  child: ClipRect(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                        return Stack(
                          children: [
                            Listener(
                              onPointerSignal: (pointerSignal) {
                                if (pointerSignal is PointerScrollEvent) {
                                  setState(() {
                                    _zoom -= pointerSignal.scrollDelta.dy * 0.001;
                                    _zoom = _zoom.clamp(0.3, 3.0);
                                  });
                                }
                              },
                              child: GestureDetector(behavior: HitTestBehavior.opaque, 
                                onScaleStart: (d) => _onScaleStart(d, canvasSize),
                                onScaleUpdate: (d) => _onScaleUpdate(d, canvasSize),
                                onScaleEnd: _onScaleEnd,
                                child: CustomPaint(
                                  size: canvasSize,
                                  painter: CanvasPainter(
                                    zoom: _zoom,
                                    pan: _pan,
                                    scenario: _scenario,
                                    step: _step,
                                    rods: _rods,
                                    triFormed: _triangleFormed,
                                    triPos: _triPos,
                                    rotation: _rotation,
                                    flipped: _flipped,
                                    superimposed: _superimposed,
                                    mismatch: _mismatch,
                                    kiteIdentified: _kiteIdentified,
                                    kiteOffsetY: _kiteOffsetY,
                                    lang: _lang,
                                    t: t,
                                  ),
                                ),
                              ),
                            ),
                            // Floating Tools (Dynamic) over Canvas
                            if (_triangleFormed && !_superimposed)
                              ..._buildDynamicTools(canvasSize),
                          ]
                        );
                      }
                    ),
                  ),
                ),
              ],
            ),

            // 2. Menu Icon (Top Left - Absolute position)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _playClick();
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.orange.withOpacity(0.8)),
                  ),
                ),
              ),
            ),

            // 3. HUD (Bottom Center - adjusts visually to remaining space)
            if (_step < _getScenarioSteps(_scenario).length)
              Positioned(
                bottom: 20,
                left: (_isSidebarOpen ? sidebarW : 0) + (sw - (_isSidebarOpen ? sidebarW : 0)) / 2 - math.min((sw - (_isSidebarOpen ? sidebarW : 0)) * 0.8, 600) / 2,
                width: math.min((sw - (_isSidebarOpen ? sidebarW : 0)) * 0.8, 600),
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0f172a).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: const Border(top: BorderSide(color: Color(0xFF6366f1), width: 4)),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF818cf8), size: 30),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            t('s${_scenario}_hud${_step + 1}'),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 4. Final Success Popup (Only Scenario 5)
            if (_showFinalPopup && _scenario == 5)
              _buildSuccessPopup(),

            // 5. Intro Curtain
            if (_showCurtain)
              AnimatedBuilder(
                animation: _curtainAnim,
                builder: (context, child) {
                  return Positioned.fill(
                    top: _curtainAnim.value * sh,
                    child: Container(
                      color: const Color(0xFF020617),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.change_history, size: 100, color: Color(0xFF6366f1)),
                          const SizedBox(height: 20),
                          Text(t('appTitle'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 10),
                          Text(t('appSubtitle'), style: const TextStyle(fontSize: 18, color: Colors.grey)),
                          const SizedBox(height: 40),
                          ElevatedButton.icon(
                            onPressed: () {
                              _playShutter();
                              _curtainAnimCtrl.forward().then((_) => setState(() => _showCurtain = false));
                            },
                            icon: const Icon(Icons.play_circle_fill, size: 28, color: Colors.white,),
                            label: Text(t('enterLab'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366f1),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDynamicTools(Size canvasSize) {
    if (_step < 1 && _scenario != 4 && _scenario != 5) return []; 
    Offset centroid = _getTriangleCentroid();
    Matrix4 transform = Matrix4.identity()
      ..translate(canvasSize.width / 2 + _pan.dx, canvasSize.height / 2 + _pan.dy)
      ..scale(_zoom);
    Offset exactScreenPos = MatrixUtils.transformPoint(transform, centroid);

    List<Widget> tools = [];
    if (_scenario == 2 || (_scenario == 5 && _step == 2)) {
      tools.add(
        Positioned(
          left: exactScreenPos.dx - 60,
          top: exactScreenPos.dy - 100,
          child: Row(
            children: [
              _ActionBtn(icon: Icons.rotate_right, color: Colors.indigo, onTap: _toolRotate),
              const SizedBox(width: 12),
              _ActionBtn(icon: Icons.flip, color: Colors.indigo, onTap: _toolFlip),
            ],
          ),
        ),
      );
    }
    if (_scenario == 4 || (_scenario == 5 && _step >= 1)) {
      tools.add(
        Positioned(
          left: exactScreenPos.dx + 40,
          top: exactScreenPos.dy + 30,
          child: _ActionBtn(icon: Icons.link_off, color: Colors.red, onTap: _toolDismantle),
        ),
      );
    }
    return tools;
  }

  Widget _buildSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0f172a), // Opaque color matching ZSL HTML standard panel
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(5, 0))],
      ),
      child: SingleChildScrollView(
        controller: _sidebarScrollCtrl,
        padding: const EdgeInsets.all(20).copyWith(top: 80), // Padding below absolute menu icon
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.change_history, color: Color(0xFF6366f1), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('appTitle'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), overflow: TextOverflow.ellipsis),
                      Text(t('appSubtitle'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Language Toggle and Reset Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Language Globe Toggle
                GestureDetector(behavior: HitTestBehavior.opaque, 
                  onTap: () {
                    _playClick();
                    setState(() {
                      if (_lang == 'en') _lang = 'hi'; else _lang = 'en';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1e293b),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.language, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(_lang.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                // Reset Button
                ElevatedButton.icon(
                  onPressed: _resetToShutter,
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                  label: Text(t('resetBtn'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf43f5e),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),

            Text(t('selectScenario'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _scenario,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1e293b),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  items: [1, 2, 3, 4, 5].map((i) {
                    return DropdownMenuItem(value: i, child: Text(t('s${i}_title')));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) _loadScenario(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1e293b).withOpacity(0.8), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [const Icon(Icons.lightbulb_outline, color: Color(0xFFf43f5e), size: 20), const SizedBox(width: 8), Text(t('learnLbl'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white))]),
                  const SizedBox(height: 8),
                  Text(t('s${_scenario}_obj'), style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ..._buildSteps(),
            
            // Inline Next Scenario Notification
            if (_step >= _getScenarioSteps(_scenario).length && _superimposed)
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _scenario == 3 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  border: Border.all(color: _scenario == 3 ? Colors.red : Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(children: [Icon(_scenario == 3 ? Icons.warning : Icons.check_circle, color: _scenario == 3 ? Colors.red : Colors.green), const SizedBox(width: 8), Text(t('summaryTitle'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _scenario == 3 ? Colors.redAccent : Colors.greenAccent))]),
                    const SizedBox(height: 8),
                    Text(t('s${_scenario}_sum'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                    if (_scenario < 5) ...[
                      const SizedBox(height: 16),
                      const Text("✅ Scenario Completed! Please select the next scenario from the dropdown above.", style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                    ]
                  ],
                ),
              ),
            
            const SizedBox(height: 30),
            // Footer inline with scrollable view
            SizedBox(
              width: double.infinity,
              child: Text(
                t('footer'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSteps() {
    List<Map<String, String>> stepsConfig = _getScenarioSteps(_scenario);
    return List.generate(stepsConfig.length, (i) {
      bool isActive = i == _step;
      bool isPast = i < _step;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6366f1).withOpacity(0.15) : (isPast ? Colors.white.withOpacity(0.05) : Colors.transparent),
          border: Border.all(color: isActive ? const Color(0xFF6366f1) : (isPast ? Colors.white24 : Colors.transparent)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPast) const Icon(Icons.check_circle, color: Color(0xFF10b981), size: 28)
            else if (isActive) Container(width: 28, height: 28, decoration: const BoxDecoration(color: Color(0xFF6366f1), shape: BoxShape.circle), alignment: Alignment.center, child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
            else Container(width: 28, height: 28, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), alignment: Alignment.center, child: Text('${i + 1}', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${t('stepLabel')} ${i + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  Text(stepsConfig[i]['task']!, style: TextStyle(color: isActive ? const Color(0xFF818cf8) : Colors.white70, fontSize: 14)),
                  if (isPast) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _scenario == 3 && i == 1 ? Colors.red.withOpacity(0.2) : const Color(0xFF10b981).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(stepsConfig[i]['out']!, style: TextStyle(color: _scenario == 3 && i == 1 ? Colors.redAccent : const Color(0xFF34d399), fontSize: 13)),
                    )
                  ]
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _buildSuccessPopup() {
    return Container(
      color: Colors.black87,
      alignment: Alignment.center,
      child: Center(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: 500,
              constraints: const BoxConstraints(maxHeight: 400),
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30, offset: Offset(0, 15))],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFF10b981), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF10b981).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))]), child: const Icon(Icons.flag, color: Colors.white, size: 40)),
                    const SizedBox(height: 24),
                    Text(t('labCompleted'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 16),
                    Text(t('finalDesc'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _resetToShutter,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: Text(t('resetBtn'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366f1), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    )
                  ],
                ),
              ),
            ),
            // Close Button
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 28),
                onPressed: () {
                  _playClick();
                  setState(() {
                    _showFinalPopup = false;
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getScenarioSteps(int id) {
    int numSteps = (id == 3 || id == 4 || id == 5) ? 3 : 4;
    List<Map<String, String>> steps = [];
    for (int i = 1; i <= numSteps; i++) {
      steps.add({
        'task': t('s${id}_step${i}_task'),
        'out': t('s${id}_step${i}_out'),
      });
    }
    return steps;
  }
}

// --- Canvas Rendering ---
class CanvasPainter extends CustomPainter {
  final double zoom;
  final Offset pan;
  final int scenario;
  final int step;
  final List<Rod> rods;
  final bool triFormed;
  final Offset triPos;
  final int rotation;
  final bool flipped;
  final bool superimposed;
  final bool mismatch;
  final bool kiteIdentified;
  final double kiteOffsetY;
  final String lang;
  final Function(String) t;

  CanvasPainter({
    required this.zoom, required this.pan, required this.scenario, required this.step, 
    required this.rods, required this.triFormed, required this.triPos,
    required this.rotation, required this.flipped, required this.superimposed, required this.mismatch,
    required this.kiteIdentified, required this.kiteOffsetY, required this.lang, required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fill deep dark background directly on canvas
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF020617));

    canvas.save();
    canvas.translate(size.width / 2 + pan.dx, size.height / 2 + pan.dy); // Canvas transform
    canvas.scale(zoom);

    // Subtle grid
    Paint gridPaint = Paint()..color = const Color(0xFF1e293b).withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (double i = -1000; i < 1000; i += 20) {
      canvas.drawLine(Offset(i, -1000), Offset(i, 1000), gridPaint);
      canvas.drawLine(Offset(-1000, i), Offset(1000, i), gridPaint);
    }
    
    // Scenario Drawing
    if (scenario == 1) _drawS1(canvas);
    if (scenario == 2) _drawS2(canvas);
    if (scenario == 3) _drawS3(canvas);
    if (scenario == 4) _drawS4(canvas);
    if (scenario == 5) _drawS5(canvas);

    canvas.restore();
  }

  void _drawS1(Canvas canvas) {
    double scale = 25.0;
    double tW = 8 * scale; double tL = 5 * scale; double tR = 7 * scale;
    double angA = math.acos((25 + 64 - 49) / 80);
    double tCx = math.cos(-angA) * tL; double tCy = math.sin(-angA) * tL;
    double tx = -250, ty = -60; double wx = -30, wy = 120;

    _drawPanel(canvas, tx - 30, ty - 150, 260, 200);
    _drawTarget(canvas, tx, ty, tW, tCx, tCy, superimposed, 'lblTarget', '8', '5', '7', 'A', 'B', 'C');
    
    bool isZoneActive = (step == 0 && !superimposed);
    _drawConstructionZone(canvas, wx, wy, tW, isZoneActive);

    double bx = wx, by = wy;
    if (superimposed) { bx = tx; by = ty; } else if (triFormed) { bx = triPos.dx; by = triPos.dy; }

    if (triFormed) {
      _drawAssembledTriangle(canvas, bx, by, tW, tCx, tCy, tW, tL, tR, superimposed ? Colors.green : Colors.green.withOpacity(0.5));
    } else {
      Rod? r8 = rods.where((r) => r.id == 1).firstOrNull;
      Rod? r5 = rods.where((r) => r.id == 2).firstOrNull;
      Rod? r7 = rods.where((r) => r.id == 3).firstOrNull;

      if (r8 != null) _drawRod(canvas, r8, scale, Colors.green);
      if (r5 != null) _drawRod(canvas, r5, scale, Colors.green);
      if (r7 != null) _drawRod(canvas, r7, scale, Colors.green);
      
      // Hinges
      if (step == 1 && r8?.state == 1) {
        if (r5?.state == 0) _drawPoint(canvas, wx, wy, Colors.amber);
        if (r7?.state == 0) _drawPoint(canvas, wx + tW, wy, Colors.amber);
      }
      if (step == 2 && r5?.state == 1 && r7?.state == 1) {
        Offset p1 = Offset(wx + r5!.len*scale*math.cos(r5.angle), wy + r5.len*scale*math.sin(r5.angle));
        Offset p2 = Offset(wx + tW + r7!.len*scale*math.cos(r7.angle), wy + r7.len*scale*math.sin(r7.angle));
        if ((p1 - p2).distance < 100) canvas.drawLine(p1, p2, Paint()..color = Colors.amber..strokeWidth=3);
      }
    }
  }

  void _drawS2(Canvas canvas) {
    double scale = 20.0;
    double tW = 10 * scale; double tL = 6 * scale; double tR = 8 * scale;
    double angA = math.acos((36 + 100 - 64) / 120);
    double tCx = math.cos(-angA) * tL; double tCy = math.sin(-angA) * tL;
    double tx = -250, ty = -100; double wx = -30, wy = 120;

    _drawPanel(canvas, tx - 70, ty - 60, 160, 320);
    
    // Target is rotated visually
    Path targetPath = Path()..moveTo(tx, ty)..lineTo(tx, ty + 200)..lineTo(tx - 96, ty + 72)..close();
    if (superimposed) {
      canvas.drawPath(targetPath, Paint()..color=Colors.green.withOpacity(0.4)..style=PaintingStyle.fill);
      canvas.drawPath(targetPath, Paint()..color=Colors.green..style=PaintingStyle.stroke..strokeWidth=4);
      _drawText(canvas, t('congruentLbl'), tx - 48, ty + 100, 24, Colors.greenAccent, bold: true);
    } else {
      canvas.drawPath(targetPath, Paint()..color=Colors.blue.withOpacity(0.15)..style=PaintingStyle.fill);
      canvas.drawPath(targetPath, Paint()..color=Colors.blue..style=PaintingStyle.stroke..strokeWidth=4);
    }
    _drawText(canvas, '10', tx + 15, ty + 100, 14, Colors.white, bold: true);
    _drawText(canvas, '6', tx - 63, ty + 36, 14, Colors.white, bold: true);
    _drawText(canvas, '8', tx - 63, ty + 146, 14, Colors.white, bold: true);

    bool isZoneActive = (step == 0 && !triFormed);
    _drawConstructionZone(canvas, wx, wy, tW, isZoneActive);

    double bx = wx, by = wy;
    if (superimposed) return; 
    else if (triFormed) { bx = triPos.dx; by = triPos.dy; }

    if (triFormed) {
      _drawAssembledTriangle(canvas, bx, by, tW, tCx, tCy, tW, tL, tR, Colors.green);
    } else {
      for (var r in rods) _drawRod(canvas, r, scale, Colors.green);
      if (step == 0) {
        Rod? r10 = rods.where((r) => r.id == 1).firstOrNull;
        if (r10?.state == 1) {
          if (rods[1].state == 0) _drawPoint(canvas, wx, wy, Colors.amber);
          if (rods[2].state == 0) _drawPoint(canvas, wx + tW, wy, Colors.amber);
        }
        if (rods[1].state == 1 && rods[2].state == 1) {
          Offset p1 = Offset(wx + tL*math.cos(rods[1].angle), wy + tL*math.sin(rods[1].angle));
          Offset p2 = Offset(wx + tW + tR*math.cos(rods[2].angle), wy + tR*math.sin(rods[2].angle));
          if ((p1 - p2).distance < 100) canvas.drawLine(p1, p2, Paint()..color = Colors.amber..strokeWidth=3);
        }
      }
    }
  }

  void _drawS3(Canvas canvas) {
    double scale = 25.0;
    double tW = 10 * scale; double tL = 5 * scale; double tR = 9 * scale;
    double angA = math.acos((25 + 100 - 81) / 100);
    double tCx = math.cos(-angA) * tL; double tCy = math.sin(-angA) * tL;
    
    double uW = 11 * scale;
    double uAngA = math.acos((25 + 121 - 81) / 110);
    double uCx = math.cos(-uAngA) * tL; double uCy = math.sin(-uAngA) * tL;

    double tx = -250, ty = -60; double wx = -30, wy = 120;

    _drawPanel(canvas, tx - 40, ty - 150, 320, 200);
    _drawTarget(canvas, tx, ty, tW, tCx, tCy, false, 'lblTarget', '10', '5', '9', '', '', '');
    
    bool isZoneActive = (step == 0 && !superimposed);
    _drawConstructionZone(canvas, wx, wy, uW, isZoneActive);

    double bx = wx, by = wy;
    if (superimposed) { bx = tx; by = ty; } else if (triFormed) { bx = triPos.dx; by = triPos.dy; }

    if (triFormed) {
      _drawAssembledTriangle(canvas, bx, by, uW, uCx, uCy, uW, tL, tR, mismatch ? Colors.red : Colors.green);
      if (mismatch) _drawText(canvas, t('mismatchLbl'), tx + uW, ty + 60, 24, Colors.red, bold: true);
    } else {
      for (var r in rods) _drawRod(canvas, r, scale, Colors.green);
      if (step == 0) {
        Rod? r11 = rods.where((r) => r.id == 1).firstOrNull;
        if (r11?.state == 1) {
          if (rods[1].state == 0) _drawPoint(canvas, wx, wy, Colors.amber);
          if (rods[2].state == 0) _drawPoint(canvas, wx + uW, wy, Colors.amber);
        }
        if (rods[1].state == 1 && rods[2].state == 1) {
          Offset p1 = Offset(wx + tL*math.cos(rods[1].angle), wy + tL*math.sin(rods[1].angle));
          Offset p2 = Offset(wx + uW + tR*math.cos(rods[2].angle), wy + tR*math.sin(rods[2].angle));
          if ((p1 - p2).distance < 100) canvas.drawLine(p1, p2, Paint()..color = Colors.amber..strokeWidth=3);
        }
      }
    }
  }

  void _drawS4(Canvas canvas) {
    double scale = 20.0;
    double tW = 10 * scale; double tL = 7 * scale; double tR = 7 * scale;
    double angA = math.acos((49 + 100 - 49) / 140);
    double tCx = math.cos(-angA) * tL; double tCy = math.sin(-angA) * tL;
    double tx = -200, ty = 80; double wx = 20, wy = 150;

    _drawPanel(canvas, tx - 40, ty - 180, 280, 240);
    _drawTarget(canvas, tx, ty, tW, tCx, tCy, superimposed, 'lblTarget', '10', '7', '7', '', '', '');
    
    bool isZoneActive = !superimposed;
    _drawConstructionZone(canvas, wx, wy, tW, isZoneActive);
    _drawPartsBin(canvas, 270, -250);

    double bx = wx, by = wy;
    if (superimposed) { bx = tx; by = ty; } else if (triFormed) { bx = triPos.dx; by = triPos.dy; }

    if (triFormed && !superimposed) {
      Rod b = rods.firstWhere((r) => r.state == 1);
      Rod rL = rods.firstWhere((r) => r.state == 2);
      Rod rR = rods.firstWhere((r) => r.state == 3);
      _drawAssembledTriangle(canvas, bx, by, b.len*scale, rL.len*scale*math.cos(rL.angle), rL.len*scale*math.sin(rL.angle), b.len*scale, rL.len*scale, rR.len*scale, mismatch ? Colors.red : Colors.green);
      if (mismatch) _drawText(canvas, t('mismatchLbl'), tx + tW/2, ty + 60, 24, Colors.red, bold: true);
    } else if (!superimposed) {
      for (var r in rods) {
        Color c = mismatch && r.state > 0 ? Colors.red : Colors.green;
        _drawRod(canvas, r, scale, c);
      }
    }
  }

  void _drawS5(Canvas canvas) {
    double scale = 15.0;
    double kcx = -120; double kcy = -20 + kiteOffsetY;
    
    double kTopY = kcy - 112.5;
    double kBotY = kcy + 112.5;
    double crossY = kTopY + 81;
    double kLeftX = kcx - 108;
    double kRightX = kcx + 108;

    Offset topPt = Offset(kcx, kTopY);
    Offset botPt = Offset(kcx, kBotY);
    Offset leftPt = Offset(kLeftX, crossY);
    Offset rightPt = Offset(kRightX, crossY);
    
    // Kite Base Structure
    Path kitePath = Path()..moveTo(topPt.dx, topPt.dy)..lineTo(rightPt.dx, rightPt.dy)..lineTo(botPt.dx, botPt.dy)..lineTo(leftPt.dx, leftPt.dy)..close();
    canvas.drawPath(kitePath, Paint()..color=const Color(0xFF334155)..style=PaintingStyle.stroke..strokeWidth=8);
    canvas.drawLine(topPt, botPt, Paint()..color=const Color(0xFF6366f1)..strokeWidth=6);
    canvas.drawLine(leftPt, rightPt, Paint()..color=const Color(0xFF6366f1)..strokeWidth=6);

    // Triangles
    _drawPoly(canvas, [topPt, leftPt, Offset(kcx, crossY)], Colors.lightBlue.withOpacity(0.4));
    _drawPoly(canvas, [topPt, rightPt, Offset(kcx, crossY)], Colors.lightBlue.withOpacity(0.4));
    
    Color blColor = (!kiteIdentified && step == 0) ? Colors.green.withOpacity(0.6) : Colors.green.withOpacity(0.4);
    _drawPoly(canvas, [Offset(kcx, crossY), leftPt, botPt], blColor);

    // Target empty frame (Right Side)
    Path targetPath = Path()..moveTo(topPt.dx, topPt.dy)..lineTo(rightPt.dx, rightPt.dy)..lineTo(botPt.dx, botPt.dy)..close();
    if (superimposed) {
      canvas.drawPath(targetPath, Paint()..color=Colors.green.withOpacity(0.4)..style=PaintingStyle.fill);
      canvas.drawPath(targetPath, Paint()..color=Colors.green..style=PaintingStyle.stroke..strokeWidth=4);
    } else {
      canvas.drawPath(targetPath, Paint()..color=Colors.redAccent..style=PaintingStyle.stroke..strokeWidth=4);
    }

    if (kiteIdentified) {
      // Draw mathematically placed side labels
      _drawText(canvas, '9', (kcx + kLeftX) / 2 - 15, (kTopY + crossY) / 2 - 15, 16, Colors.white, bold: true);
      _drawText(canvas, '12', (kcx + kLeftX) / 2 - 15, (kBotY + crossY) / 2 + 15, 16, Colors.white, bold: true);
      _drawText(canvas, '15', kcx + 20, kcy, 16, Colors.white, bold: true);
    }

    if (step >= 1) {
      double wx = 60, wy = 150;
      bool isZoneActive = !superimposed;
      _drawConstructionZone(canvas, wx, wy, 200, isZoneActive);
      _drawPartsBin(canvas, 280, -250);

      double bx = wx, by = wy;
      if (triFormed && !superimposed) {
        bx = triPos.dx; by = triPos.dy;
        Rod b = rods.firstWhere((r) => r.state == 1);
        Rod rL = rods.firstWhere((r) => r.state == 2);
        Rod rR = rods.firstWhere((r) => r.state == 3);
        _drawAssembledTriangle(canvas, bx, by, b.len*scale, rL.len*scale*math.cos(rL.angle), rL.len*scale*math.sin(rL.angle), b.len*scale, rL.len*scale, rR.len*scale, mismatch ? Colors.red : Colors.green);
        if (mismatch) _drawText(canvas, t('mismatchLbl'), kcx + 90, crossY + 60, 24, Colors.red, bold: true);
      } else if (!superimposed) {
        for (var r in rods) {
          Color c = mismatch && r.state > 0 ? Colors.red : Colors.green;
          _drawRod(canvas, r, scale, c);
        }
      }
    }
  }

  // --- Helper Draw Methods ---
  void _drawPoly(Canvas canvas, List<Offset> pts, Color color) {
    Path p = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i=1; i<pts.length; i++) p.lineTo(pts[i].dx, pts[i].dy);
    p.close();
    canvas.drawPath(p, Paint()..color=color..style=PaintingStyle.fill);
    canvas.drawPath(p, Paint()..color=Colors.white.withOpacity(0.3)..style=PaintingStyle.stroke..strokeWidth=2);
  }

  void _drawPanel(Canvas canvas, double x, double y, double w, double h) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(8)), Paint()..color = const Color(0xFF1e293b));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(8)), Paint()..color = const Color(0xFF334155)..style=PaintingStyle.stroke..strokeWidth=1);
  }

  void _drawTarget(Canvas canvas, double tx, double ty, double tW, double tCx, double tCy, bool glow, String titleKey, String l1, String l2, String l3, String p1, String p2, String p3) {
    Path p = Path()..moveTo(tx, ty)..lineTo(tx + tW, ty)..lineTo(tx + tCx, ty + tCy)..close();
    if (glow) {
      canvas.drawPath(p, Paint()..color = Colors.green.withOpacity(0.4)..style = PaintingStyle.fill);
      canvas.drawPath(p, Paint()..color = Colors.green..style = PaintingStyle.stroke..strokeWidth = 4..strokeJoin = StrokeJoin.round);
      _drawText(canvas, t('congruentLbl'), tx + tW/2, ty - 80, 24, Colors.greenAccent, bold: true);
    } else {
      canvas.drawPath(p, Paint()..color = Colors.blue.withOpacity(0.15)..style = PaintingStyle.fill);
      canvas.drawPath(p, Paint()..color = Colors.blue..style = PaintingStyle.stroke..strokeWidth = 4..strokeJoin = StrokeJoin.round);
    }
    _drawText(canvas, t(titleKey), tx + tW/2, ty - 120, 16, Colors.blue, bold: true);
    _drawText(canvas, l1, tx + tW/2, ty + 20, 14, Colors.white, bold: true);
    _drawText(canvas, l2, tx + tCx/2 - 15, ty + tCy/2 - 5, 14, Colors.white, bold: true);
    _drawText(canvas, l3, tx + tW - (tW - tCx)/2 + 15, ty + tCy/2 - 5, 14, Colors.white, bold: true);
    if (p1.isNotEmpty) {
      _drawText(canvas, p1, tx - 15, ty + 10, 16, Colors.white);
      _drawText(canvas, p2, tx + tW + 15, ty + 10, 16, Colors.white);
      _drawText(canvas, p3, tx + tCx, ty + tCy - 15, 16, Colors.white);
    }
  }

  void _drawConstructionZone(Canvas canvas, double wx, double wy, double width, bool active) {
    _drawPanel(canvas, wx - 30, wy - 180, width + 60, 240);
    Paint linePaint = Paint()..color = active ? Colors.green : const Color(0xFF334155)..strokeWidth = active ? 6 : 4..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(wx, wy), Offset(wx + width, wy), linePaint);
    _drawText(canvas, t('lblConstZone'), wx + width/2, wy + 30, 14, active ? Colors.green : Colors.white, bold: true);
  }

  void _drawPartsBin(Canvas canvas, double x, double y) {
    _drawPanel(canvas, x, y, 150, 500);
    _drawText(canvas, t('lblPartsBin'), x + 75, y + 30, 16, Colors.white, bold: true);
  }

  void _drawRod(Canvas canvas, Rod r, double scale, Color c) {
    Offset p1 = Offset(r.cx, r.cy);
    Offset p2 = Offset(r.cx + r.len * scale * math.cos(r.angle), r.cy + r.len * scale * math.sin(r.angle));
    canvas.drawLine(p1, p2, Paint()..color = c..strokeWidth = 10..strokeCap = StrokeCap.round);
    _drawPoint(canvas, p1.dx, p1.dy, Colors.white, radius: 4);
    _drawPoint(canvas, p2.dx, p2.dy, Colors.white, radius: 4);
    if (r.state == 2 || r.state == 3) _drawPoint(canvas, p2.dx, p2.dy, Colors.redAccent, radius: 8);
    _drawText(canvas, '${r.len.toInt()}', (p1.dx + p2.dx)/2, (p1.dy + p2.dy)/2, 14, Colors.white, bold: true);
  }

  void _drawAssembledTriangle(Canvas canvas, double bx, double by, double w, double cx, double cy, double l1, double l2, double l3, Color c) {
    canvas.save();
    canvas.translate(bx, by);
    double cntX = (0 + w + cx)/3; double cntY = (0 + 0 + cy)/3;
    canvas.translate(cntX, cntY);
    canvas.rotate(rotation * math.pi/2);
    if (flipped) canvas.scale(-1, 1);
    canvas.translate(-cntX, -cntY);

    Path p = Path()..moveTo(0, 0)..lineTo(w, 0)..lineTo(cx, cy)..close();
    canvas.drawPath(p, Paint()..color = c.withOpacity(0.2)..style = PaintingStyle.fill);
    canvas.drawPath(p, Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = 2);

    _drawRodLocal(canvas, const Offset(0, 0), Offset(w, 0), l1, c);
    _drawRodLocal(canvas, const Offset(0, 0), Offset(cx, cy), l2, c);
    _drawRodLocal(canvas, Offset(w, 0), Offset(cx, cy), l3, c);
    canvas.restore();
  }

  void _drawRodLocal(Canvas canvas, Offset p1, Offset p2, double label, Color c) {
    canvas.drawLine(p1, p2, Paint()..color = c..strokeWidth = 10..strokeCap = StrokeCap.round);
    _drawPoint(canvas, p1.dx, p1.dy, Colors.white, radius: 4);
    _drawPoint(canvas, p2.dx, p2.dy, Colors.white, radius: 4);
    
    // Auto-rotate text back to screen orientation for readability
    canvas.save();
    canvas.translate((p1.dx+p2.dx)/2, (p1.dy+p2.dy)/2);
    if (flipped) canvas.scale(-1, 1);
    canvas.rotate(-rotation * math.pi/2);
    _drawText(canvas, '${label.toInt()}', 0, 0, 14, Colors.white, bold: true);
    canvas.restore();
  }

  void _drawPoint(Canvas canvas, double x, double y, Color color, {double radius = 5}) {
    canvas.drawCircle(Offset(x, y), radius, Paint()..color = color);
    canvas.drawCircle(Offset(x, y), radius, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth=1.5);
  }

  void _drawText(Canvas canvas, String text, double x, double y, double size, Color color, {bool bold = false}) {
    TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- Data Models ---
class Rod {
  int id;
  double len;
  double ox, oy;
  double cx, cy;
  double angle;
  int state;

  Rod({required this.id, required this.len, required this.ox, required this.oy, this.angle = 0, this.state = 0})
      : cx = ox, cy = oy;
}

// --- UI Components ---
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(behavior: HitTestBehavior.opaque, 
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1e293b),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
