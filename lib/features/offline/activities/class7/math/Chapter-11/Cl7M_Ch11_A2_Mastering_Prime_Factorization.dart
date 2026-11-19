// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FactorsApp());
}

class FactorsApp extends StatelessWidget {
  const FactorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Prime Factorization Factory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const MasteringPrimeFactorization(),
    );
  }
}

// --- TRANSLATIONS ---
const Map<String, Map<String, String>> translations = {
  'en': {
    'shutterTitle': "The Prime Factorization Factory",
    'appTitle': "The Prime Factorization Factory",
    'appSubtitle': "Class 7 • FINDING COMMON GROUND",
    'enterLab': "Enter Simulation",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'learnLbl': "Observations:",
    'resetBtn': "Reset",
    'lbl_analysis_bin': "ANALYSIS BIN",
    's1_title': "1. The First Crack",
    's1_obj': "Understand how to break a composite number (12) into its prime factors.",
    's1_step1_task': "CLICK the '12' block with the Factor Hammer.",
    's1_step1_out': "The 12 block breaks into 2 and 6. The 2 becomes a Prime Gem!",
    's1_step2_task': "CLICK the '6' block with the Factor Hammer.",
    's1_step2_out': "The 6 block breaks into 2 and 3. Both are now Prime Gems!",
    's1_step3_task': "DRAG each gem into the 'Analysis Bin'.",
    's1_step3_out': "Success! 12 is fully broken down. 12 = 2 x 2 x 3.",
    's1_hud1': "Click the Factor Hammer, then click the 12 block.",
    's1_hud2': "Click the 6 block with the hammer.",
    's1_hud3': "Drag all glowing gems to the bin.",
    's2_title': "2. The Other Path",
    's2_obj': "See that prime factors remain the same even if you start dividing differently.",
    's2_step1_task': "DRAG the '3' Divisor Tool onto the '12' block.",
    's2_step1_out': "The 12 block divides by 3. You get a 3 gem and a 4 block.",
    's2_step2_task': "CLICK the '4' block with the hammer.",
    's2_step2_out': "The 4 block breaks into two 2 gems.",
    's2_step3_task': "DRAG the three Prime Gems into the Analysis Bin.",
    's2_step3_out': "Even starting with 3, you get the same final prime factors: 2 x 2 x 3.",
    's2_hud1': "Drag the '3' tool over the 12 block.",
    's2_hud2': "Select the hammer and break the 4 block.",
    's2_hud3': "Drag all gems to the bin.",
    's3_title': "3. The Big Crate",
    's3_obj': "Apply the factorization process to a larger number, 90.",
    's3_step1_task': "CLICK the '90' block with the Factor Hammer.",
    's3_step1_out': "90 splits into 9 and 10.",
    's3_step2_task': "CLICK the '9' block with the Factor Hammer.",
    's3_step2_out': "9 splits into two 3 gems.",
    's3_step3_task': "CLICK the remaining '10' block with the Factor Hammer.",
    's3_step3_out': "10 splits into a 2 gem and a 5 gem.",
    's3_step4_task': "DRAG all four Prime Gems into the Analysis Bin.",
    's3_step4_out': "Excellent! The unique factorization of 90 is 2 x 3 x 3 x 5.",
    's3_hud1': "Break the 90 block with the hammer.",
    's3_hud2': "Break the 9 block.",
    's3_hud3': "Break the 10 block.",
    's3_hud4': "Collect all gems in the bin.",
    's4_title': "4. Factory Floor Test",
    's4_obj': "Independently find the prime factorization of 84.",
    's4_step1_task': "Break down the '84' block completely.",
    's4_step1_out': "You found all the prime components of 84.",
    's4_step2_task': "DRAG final Prime Gems into the Analysis Bin.",
    's4_step2_out': "Challenge Complete! 84 = 2 x 2 x 3 x 7.",
    's4_hud1': "Use the hammer to break down blocks until only primes remain.",
    's4_hud2': "Collect all gems in the bin to finish.",
    's5_title': "5. The Odd One Out",
    's5_obj': "Factor a number (225) that requires identifying odd prime factors.",
    's5_step1_task': "Break down the '225' block completely.",
    's5_step1_out': "You discovered the prime building blocks of 225.",
    's5_step2_task': "DRAG final Prime Gems into the Analysis Bin.",
    's5_step2_out': "Master Factorizer! 225 = 3 x 3 x 5 x 5.",
    's5_hud1': "Use tools to break down 225 entirely.",
    's5_hud2': "Collect the 4 prime gems to finish."
  },
  'hi': {
    'shutterTitle': "प्राइम फैक्टराइजेशन फैक्ट्री",
    'appTitle': "प्राइम फैक्टराइजेशन फैक्ट्री",
    'appSubtitle': "कक्षा 7 • सामान्य आधार खोजना",
    'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'learnLbl': "अवलोकन:",
    'resetBtn': "रीसेट",
    'lbl_analysis_bin': "विश्लेषण बिन",
    's1_title': "1. पहली दरार",
    's1_obj': "समझें कि एक भाज्य संख्या (12) को उसके अभाज्य गुणनखंडों में कैसे तोड़ा जाए।",
    's1_step1_task': "फैक्टर हैमर से '12' ब्लॉक पर क्लिक करें।",
    's1_step1_out': "12 ब्लॉक 2 और 6 में टूट जाता है। 2 एक प्राइम जेम बन जाता है!",
    's1_step2_task': "फैक्टर हैमर से '6' ब्लॉक पर क्लिक करें।",
    's1_step2_out': "6 ब्लॉक 2 और 3 में टूट जाता है। दोनों अब प्राइम जेम हैं!",
    's1_step3_task': "प्रत्येक जेम को 'विश्लेषण बिन' में खींचें।",
    's1_step3_out': "सफलता! 12 पूरी तरह से टूट गया है। 12 = 2 x 2 x 3.",
    's1_hud1': "फैक्टर हैमर पर क्लिक करें, फिर 12 ब्लॉक पर।",
    's1_hud2': "हैमर से 6 ब्लॉक पर क्लिक करें।",
    's1_hud3': "सभी चमकते रत्नों को बिन में खींचें।",
    's2_title': "2. दूसरा रास्ता",
    's2_obj': "देखें कि अभाज्य गुणनखंड समान रहते हैं, भले ही आप अलग तरह से विभाजित करना शुरू करें।",
    's2_step1_task': "'3' भाजक टूल को '12' ब्लॉक पर खींचें।",
    's2_step1_out': "12 ब्लॉक 3 से विभाजित होता है। आपको 3 जेम और 4 ब्लॉक मिलता है।",
    's2_step2_task': "हैमर से '4' ब्लॉक पर क्लिक करें।",
    's2_step2_out': "4 ब्लॉक दो 2 जेम में टूट जाता है।",
    's2_step3_task': "तीनों प्राइम जेम को विश्लेषण बिन में खींचें।",
    's2_step3_out': "3 से शुरू करने पर भी, आपको वही अंतिम अभाज्य गुणनखंड मिलते हैं: 2 x 2 x 3.",
    's2_hud1': "12 ब्लॉक पर '3' टूल खींचें।",
    's2_hud2': "हैमर चुनें और 4 ब्लॉक को तोड़ें।",
    's2_hud3': "सभी रत्नों को बिन में खींचें।",
    's3_title': "3. बड़ा क्रेट",
    's3_obj': "एक बड़ी संख्या, 90 पर गुणनखंडन प्रक्रिया लागू करें।",
    's3_step1_task': "फैक्टर हैमर से '90' ब्लॉक पर क्लिक करें।",
    's3_step1_out': "90, 9 और 10 में विभाजित होता है।",
    's3_step2_task': "फैक्टर हैमर से '9' ब्लॉक पर क्लिक करें।",
    's3_step2_out': "9 दो 3 जेम में विभाजित होता है।",
    's3_step3_task': "फैक्टर हैमर से शेष '10' ब्लॉक पर क्लिक करें।",
    's3_step3_out': "10 एक 2 जेम और एक 5 जेम में विभाजित होता है।",
    's3_step4_task': "सभी चार प्राइम जेम को विश्लेषण बिन में खींचें।",
    's3_step4_out': "बहुत बढ़िया! 90 का अद्वितीय गुणनखंडन 2 x 3 x 3 x 5 है।",
    's3_hud1': "हैमर से 90 ब्लॉक को तोड़ें।",
    's3_hud2': "9 ब्लॉक को तोड़ें।",
    's3_hud3': "10 ब्लॉक को तोड़ें।",
    's3_hud4': "सभी रत्नों को बिन में इकट्ठा करें।",
    's4_title': "4. फैक्ट्री फ्लोर टेस्ट",
    's4_obj': "84 का अभाज्य गुणनखंड स्वतंत्र रूप से ज्ञात करें।",
    's4_step1_task': "'84' ब्लॉक को पूरी तरह से तोड़ दें।",
    's4_step1_out': "आपने 84 के सभी अभाज्य घटक खोज लिए हैं।",
    's4_step2_task': "अंतिम प्राइम जेम को विश्लेषण बिन में खींचें।",
    's4_step2_out': "चुनौती पूर्ण! 84 = 2 x 2 x 3 x 7.",
    's4_hud1': "ब्लॉकों को तोड़ने के लिए हैमर का उपयोग करें जब तक कि केवल अभाज्य न रह जाएं।",
    's4_hud2': "समाप्त करने के लिए सभी रत्नों को बिन में इकट्ठा करें।",
    's5_title': "5. विषम एक बाहर",
    's5_obj': "एक संख्या (225) का गुणनखंड करें जिसके लिए विषम अभाज्य गुणनखंडों को पहचानने की आवश्यकता है।",
    's5_step1_task': "'225' ब्लॉक को पूरी तरह से तोड़ दें।",
    's5_step1_out': "आपने 225 के अभाज्य निर्माण खंडों की खोज की।",
    's5_step2_task': "अंतिम प्राइम जेम को विश्लेषण बिन में खींचें।",
    's5_step2_out': "मास्टर फैक्टराइज़र! 225 = 3 x 3 x 5 x 5.",
    's5_hud1': "225 को पूरी तरह से तोड़ने के लिए उपकरणों का उपयोग करें।",
    's5_hud2': "समाप्त करने के लिए 4 प्राइम जेम इकट्ठा करें।"
  }
};

// --- AUDIO ENGINE ---
class AudioEngine {
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _snapUrl = 'audio/class7/mixkit_2869.mp3'; 
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';

  static void enter() => _playSound(_shutterPlayer, _shutterUrl);
  static void tick() => _playSound(_clickPlayer, _clickUrl);
  static void snap() => _playSound(_fxPlayer, _snapUrl);
  static void success() => _playSound(_successPlayer, _successUrl);
  static void error() => _playSound(_errorPlayer, _errorUrl);
  static void pop() => _playSound(_clickPlayer, _clickUrl);

  static void _playSound(AudioPlayer player, String url) async {
    try {
      if (player.state == PlayerState.playing) await player.stop();
      await player.play(AssetSource(url));
    } catch (_) {}
  }
}

// --- DATA MODELS ---
class Block {
  int id;
  int val;
  double x;
  double targetX;
  double y;
  bool isPrime;
  Block(this.id, this.val, this.x, this.targetX, this.y, this.isPrime);
}

class SimState {
  int target = 12;
  List<Block> blocks = [];
  List<int> binItems = [];
  List<String> allowedTools = [];
  List<int> allowedDivisors = [];
  String? activeTool;
  int? dragDivisor;
  int? dragGem;
  double dragX = 0;
  double dragY = 0;
  int nextId = 1;
}

final Map<int, List<int>> hammerSplits = {
  12: [2, 6], 6: [2, 3], 4: [2, 2], 90: [9, 10], 10: [2, 5], 9: [3, 3],
  84: [2, 42], 42: [2, 21], 21: [3, 7], 225: [5, 45], 45: [5, 9]
};

bool isPrime(int num) {
  if (num <= 1) return false;
  for (int i = 2; i <= sqrt(num); i++) {
    if (num % i == 0) return false;
  }
  return true;
}

// --- MAIN WIDGET ---

class MasteringPrimeFactorization extends StatefulWidget {
  const MasteringPrimeFactorization({super.key});

  @override
  State<MasteringPrimeFactorization> createState() => _MasteringPrimeFactorizationState();
}

class _MasteringPrimeFactorizationState extends State<MasteringPrimeFactorization> with SingleTickerProviderStateMixin {
  bool _showCurtain = true;
  bool _isSidebarOpen = true;
  double _sidebarWidthRatio = 0.38;
  String _lang = 'en';
  final List<String> _langs = ['en', 'hi'];

  int _scenario = 1;
  int _step = 0;

  double _zoom = 1.0;
  double _panX = 0.0;
  double _panY = 0.0;
  
  final SimState _sim = SimState();
  late Ticker _ticker;
  final GlobalKey _canvasKey = GlobalKey();

  double _time = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMilliseconds.toDouble();
        _updateBlocksAnim();
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    super.dispose();
  }

  String t(String key) => translations[_lang]?[key] ?? translations['en']![key] ?? key;

  void _startLab() {
    AudioEngine.enter();
    setState(() { _showCurtain = false; });
    _loadScenario(1);
  }

  void _toggleLang() {
    AudioEngine.pop();
    setState(() { 
      int idx = _langs.indexOf(_lang);
      _lang = _langs[(idx + 1) % _langs.length];
    });
  }

  void _resetLab() {
    AudioEngine.pop();
    setState(() {
      _lang = 'en';
      _showCurtain = true;
      _scenario = 1;
      _step = 0;
      _panX = 0;
      _panY = 0;
      _zoom = 1.0;
      _loadScenario(1);
    });
  }

  void _recalculateTargets() {
    double spacing = 80;
    double totalW = (_sim.blocks.length - 1) * spacing;
    double startX = -25 - totalW / 2;
    for (int i = 0; i < _sim.blocks.length; i++) {
      _sim.blocks[i].targetX = startX + i * spacing;
    }
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;
      _panX = 0;
      _panY = 0;
      _zoom = 1.0;
      
      _sim.binItems.clear();
      _sim.activeTool = null;
      _sim.dragDivisor = null;
      _sim.dragGem = null;
      _sim.nextId = 1;

      if (id == 1) {
        _sim.target = 12;
        _sim.blocks = [Block(_sim.nextId++, 12, -150, -150, 20, false)];
        _sim.allowedTools = ['hammer'];
        _sim.allowedDivisors = [];
      } else if (id == 2) {
        _sim.target = 12;
        _sim.blocks = [Block(_sim.nextId++, 12, -150, -150, 20, false)];
        _sim.allowedTools = ['hammer'];
        _sim.allowedDivisors = [3];
      } else if (id == 3) {
        _sim.target = 90;
        _sim.blocks = [Block(_sim.nextId++, 90, -150, -150, 20, false)];
        _sim.allowedTools = ['hammer'];
        _sim.allowedDivisors = [];
      } else if (id == 4) {
        _sim.target = 84;
        _sim.blocks = [Block(_sim.nextId++, 84, -150, -150, 20, false)];
        _sim.allowedTools = ['hammer'];
        _sim.allowedDivisors = [];
      } else if (id == 5) {
        _sim.target = 225;
        _sim.blocks = [Block(_sim.nextId++, 225, -150, -150, 20, false)];
        _sim.allowedTools = ['hammer'];
        _sim.allowedDivisors = [2, 3, 5, 7];
      }
      _recalculateTargets();
    });
    AudioEngine.pop();
  }

  void _advanceStep() {
    int maxSteps = _getScenarioStepsCount();
    if (_step < maxSteps) {
      setState(() { _step++; });
    }
  }

  int _getScenarioStepsCount() {
    if (_scenario == 1) return 3;
    if (_scenario == 2) return 3;
    if (_scenario == 3) return 4;
    if (_scenario == 4) return 2;
    return 2;
  }

  void _checkStepProgression() {
    bool advanced = false;
    do {
      advanced = false;
      int c = _scenario;
      int st = _step;
      var s = _sim;
      bool targetMet = false;

      if (c == 1) {
        if (st == 0 && (s.blocks.any((b) => b.val == 6) || s.blocks.any((b) => b.val == 3) || s.binItems.contains(3))) targetMet = true;
        if (st == 1 && s.blocks.every((b) => b.isPrime) && (s.blocks.length + s.binItems.length == 3)) targetMet = true;
        if (st == 2 && s.binItems.length == 3) targetMet = true;
      } else if (c == 2) {
        if (st == 0 && (s.blocks.any((b) => b.val == 4) || s.blocks.where((b) => b.val == 2).length + s.binItems.where((i) => i == 2).length >= 2)) targetMet = true;
        if (st == 1 && s.blocks.every((b) => b.isPrime) && (s.blocks.length + s.binItems.length == 3)) targetMet = true;
        if (st == 2 && s.binItems.length == 3) targetMet = true;
      } else if (c == 3) {
        if (st == 0 && (s.blocks.any((b) => b.val == 9) || s.blocks.where((b) => b.val == 3).length + s.binItems.where((i) => i == 3).length >= 2)) targetMet = true;
        if (st == 1 && (s.blocks.where((b) => b.val == 3).length + s.binItems.where((i) => i == 3).length >= 2)) targetMet = true;
        if (st == 2 && s.blocks.every((b) => b.isPrime) && (s.blocks.length + s.binItems.length == 4)) targetMet = true;
        if (st == 3 && s.binItems.length == 4) targetMet = true;
      } else if (c == 4) {
        if (st == 0 && s.blocks.every((b) => b.isPrime) && (s.blocks.length + s.binItems.length == 4)) targetMet = true;
        if (st == 1 && s.binItems.length == 4) targetMet = true;
      } else if (c == 5) {
        if (st == 0 && s.blocks.every((b) => b.isPrime) && (s.blocks.length + s.binItems.length == 4)) targetMet = true;
        if (st == 1 && s.binItems.length == 4) targetMet = true;
      }

      if (targetMet && _step < _getScenarioStepsCount()) {
        _advanceStep();
        AudioEngine.success();
        advanced = true;
      }
    } while (advanced);
  }

  void _breakBlock(int id, int? forcedDivisor) {
    int idx = _sim.blocks.indexWhere((x) => x.id == id);
    if (idx == -1) return;
    Block b = _sim.blocks[idx];
    if (b.isPrime) return;

    List<int> parts = [];
    if (forcedDivisor != null && b.val % forcedDivisor == 0) {
      parts = [forcedDivisor, b.val ~/ forcedDivisor];
    } else {
      List<int>? predef = hammerSplits[b.val];
      if (predef != null) {
        parts = List.from(predef);
      } else {
        for (int i = 2; i < b.val; i++) {
          if (b.val % i == 0) {
            parts = [i, b.val ~/ i];
            break;
          }
        }
      }
    }

    if (parts.length == 2) {
      setState(() {
        _sim.blocks.removeAt(idx);
        _sim.blocks.add(Block(_sim.nextId++, parts[0], b.x, 0, b.y, isPrime(parts[0])));
        _sim.blocks.add(Block(_sim.nextId++, parts[1], b.x, 0, b.y, isPrime(parts[1])));
        _recalculateTargets();
      });
      AudioEngine.snap();
      _checkStepProgression();
    } else {
      AudioEngine.error();
    }
  }

  void _updateBlocksAnim() {
    for (var b in _sim.blocks) {
      b.x += (b.targetX - b.x) * 0.15;
    }
  }

  Point<double> _screenToWorld(Offset focalPoint) {
    final RenderBox? box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return const Point(0, 0);
    final Offset local = box.globalToLocal(focalPoint);
    final double wX = (local.dx - box.size.width / 2 - _panX) / _zoom;
    final double wY = (local.dy - box.size.height / 2 - _panY) / _zoom;
    return Point(wX, wY);
  }

  bool _hitTestBox(double x, double y, double w, double h, Point<double> pt) {
    return pt.x > x && pt.x < x + w && pt.y > y && pt.y < y + h;
  }

  // --- TOUCH HANDLERS ---
  void _onPointerDown(PointerDownEvent e) {
    final pt = _screenToWorld(e.position);
    
    double rackX = -200, rackY = 160;
    
    if (_hitTestBox(rackX + 20, rackY + 30, 50, 50, pt) && _sim.allowedTools.contains('hammer')) {
      setState(() {
        _sim.activeTool = _sim.activeTool == 'hammer' ? null : 'hammer';
      });
      AudioEngine.tick();
      return;
    }

    for (int i = 0; i < _sim.allowedDivisors.length; i++) {
      double bx = rackX + 90 + i * 60;
      if (_hitTestBox(bx, rackY + 30, 50, 50, pt)) {
        setState(() {
          _sim.dragDivisor = _sim.allowedDivisors[i];
          _sim.dragX = pt.x; _sim.dragY = pt.y;
        });
        AudioEngine.tick();
        return;
      }
    }

    int clickedIdx = _sim.blocks.indexWhere((b) => _hitTestBox(b.x - 30, b.y - 30, 60, 60, pt));
    if (clickedIdx != -1) {
      Block b = _sim.blocks[clickedIdx];
      if (b.isPrime) {
        setState(() {
          _sim.dragGem = b.id;
          _sim.dragX = pt.x; _sim.dragY = pt.y;
        });
        AudioEngine.tick();
      } else if (_sim.activeTool == 'hammer') {
        _breakBlock(b.id, null);
      }
    }
  }

  void _onPointerMove(PointerMoveEvent e) {
    final pt = _screenToWorld(e.position);
    if (_sim.dragDivisor != null || _sim.dragGem != null) {
      setState(() {
        _sim.dragX = pt.x;
        _sim.dragY = pt.y;
      });
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    if (_sim.dragDivisor != null) {
      int droppedIdx = _sim.blocks.indexWhere((b) => !b.isPrime && _hitTestBox(b.x - 30, b.y - 30, 60, 60, Point(_sim.dragX, _sim.dragY)));
      if (droppedIdx != -1) {
        Block droppedOn = _sim.blocks[droppedIdx];
        if (droppedOn.val % _sim.dragDivisor! == 0) {
          _breakBlock(droppedOn.id, _sim.dragDivisor);
        } else {
          AudioEngine.error();
        }
      } else {
        AudioEngine.pop();
      }
      setState(() { _sim.dragDivisor = null; });
    }

    if (_sim.dragGem != null) {
      int idx = _sim.blocks.indexWhere((x) => x.id == _sim.dragGem);
      if (idx != -1) {
        Block b = _sim.blocks[idx];
        if (_hitTestBox(150, -150, 200, 250, Point(_sim.dragX, _sim.dragY))) {
          setState(() {
            _sim.blocks.removeAt(idx);
            _sim.binItems.add(b.val);
            _sim.binItems.sort();
            _recalculateTargets();
          });
          AudioEngine.snap();
          _checkStepProgression();
        } else {
          AudioEngine.pop();
        }
      }
      setState(() { _sim.dragGem = null; });
    }
  }

  // --- WIDGET TREE ---

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double currentSidebarWidth = screenWidth * _sidebarWidthRatio;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: Stack(
          children: [
            // Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _isSidebarOpen ? currentSidebarWidth : 0,
              top: 0,
              right: 0,
              bottom: 0,
              child: ClipRect(
                child: Listener(
                  onPointerDown: _onPointerDown,
                  onPointerMove: _onPointerMove,
                  onPointerUp: _onPointerUp,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                onScaleUpdate: (details) {
                      if (_sim.dragDivisor != null || _sim.dragGem != null) return;
                      setState(() {
                        _panX += details.focalPointDelta.dx;
                        _panY += details.focalPointDelta.dy;
                        if (details.scale != 1.0) {
                          _zoom = (_zoom * details.scale).clamp(0.4, 3.0);
                        }
                      });
                    },
                    child: Container(
                      key: _canvasKey,
                      color: const Color(0xFF0F172A),
                      child: CustomPaint(
                        painter: LabPainter(
                          sim: _sim,
                          scenario: _scenario,
                          step: _step,
                          maxSteps: _getScenarioStepsCount(),
                          zoom: _zoom,
                          panX: _panX,
                          panY: _panY,
                          t: t,
                          time: _time,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Left Sidebar - Fully Scrollable
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _isSidebarOpen ? 0 : -currentSidebarWidth,
              top: 0,
              bottom: 0,
              width: currentSidebarWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(right: BorderSide(color: Colors.white10, width: 2)),
                  boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(5, 0))],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const SizedBox(height: 60), // Padding to avoid collision with absolute Menu button
                      
                      // Header Content
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F172A),
                          border: Border(bottom: BorderSide(color: Colors.white10)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.dashboard_customize, color: Color(0xFF6366F1), size: 36),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t('appTitle'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), softWrap: true,),
                                      const SizedBox(height: 4),
                                      Text(t('appSubtitle'), style: const TextStyle(fontSize: 11, color: Colors.white70), softWrap: true,),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.language, size: 16, color: Colors.white),
                                    label: Text(_lang == 'en' ? 'English' : 'हिंदी', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF334155),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                    minimumSize: const Size(0, 32),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: _toggleLang,
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                                  label: Text(t('resetBtn'), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF4444),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                    minimumSize: const Size(0, 32),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: _resetLab,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Body Content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t('selectScenario').toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _scenario,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1E293B),
                                  items: [1, 2, 3, 4, 5].map((id) {
                                    return DropdownMenuItem(
                                      value: id,
                                      child: Text(
                                        t('s${id}_title'), 
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (v) { if (v != null) _loadScenario(v); },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.track_changes, color: Colors.pinkAccent, size: 18),
                                      const SizedBox(width: 8),
                                      Text(t('learnLbl'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(t('s${_scenario}_obj'), style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            ...List.generate(_getScenarioStepsCount(), (index) {
                              bool isCompleted = index < _step;
                              bool isActive = index == _step;
                              bool isFuture = index > _step;
                              
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFF6366F1).withOpacity(0.15) : (isCompleted ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF334155).withOpacity(0.3)),
                                  border: Border.all(color: isActive ? const Color(0xFF6366F1) : (isCompleted ? const Color(0xFF10B981).withOpacity(0.5) : Colors.transparent)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24, height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isActive ? const Color(0xFF6366F1) : (isCompleted ? const Color(0xFF10B981) : const Color(0xFF475569)),
                                      ),
                                      child: Center(
                                        child: isCompleted 
                                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                                          : Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Opacity(
                                        opacity: isFuture ? 0.5 : 1.0,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('${t('stepLabel')} ${index + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54)),
                                            const SizedBox(height: 4),
                                            Text(t('s${_scenario}_step${index+1}_task'), style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontSize: 13, height: 1.3)),
                                            if (isCompleted) ...[
                                              const SizedBox(height: 8),
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF10B981).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                                                ),
                                                child: Text(t('s${_scenario}_step${index+1}_out'), style: const TextStyle(color: Color(0xFF6EE7B7), fontSize: 12, height: 1.3)),
                                              )
                                            ]
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      
                      // Footer Content (at bottom of scroll view)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        width: double.infinity,
                        color: const Color(0xFF020617),
                        child: const Text('© ZeroScienceLab - Fall in love with math and Science', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.white54)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Sidebar Drag Resizer Handle
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _isSidebarOpen ? currentSidebarWidth - 10 : -20,
              top: 0,
              bottom: 0,
              width: 20,
              child: GestureDetector(
               behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  setState(() {
                    double newWidth = currentSidebarWidth + details.delta.dx;
                    _sidebarWidthRatio = (newWidth / screenWidth).clamp(0.25, 0.6);
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                        width: 4, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Menu Button (Top Left, Fixed)
            Positioned(
              top: 16,
              left: 16, 
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  AudioEngine.tick();
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

            // HUD
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _isSidebarOpen ? currentSidebarWidth : 0,
              right: 0,
              bottom: (_step < _getScenarioStepsCount()) ? 30 : -150, // Slide out when done
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6), // Prevent overflow
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: const Border(top: BorderSide(color: Color(0xFF6366F1), width: 3)),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, 5))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF818CF8)),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          _step < _getScenarioStepsCount() ? t('s${_scenario}_hud${_step + 1}') : "",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Curtain Screen
            if (_showCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0.8, end: 1.1),
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                            builder: (context, val, child) => Transform.scale(scale: val, child: child),
                            child: Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF6366F1), width: 3),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [BoxShadow(color: Color(0x666366F1), blurRadius: 20)],
                              ),
                              child: const Icon(Icons.grid_on, size: 60, color: Color(0xFF6366F1)),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(t('shutterTitle'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                          const SizedBox(height: 12),
                          Text(t('appSubtitle'), style: const TextStyle(fontSize: 18, color: Colors.white54, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 48),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                              elevation: 10,
                              shadowColor: const Color(0xFF6366F1),
                            ),
                            onPressed: _startLab,
                            icon: const Icon(Icons.play_circle_fill, size: 28, color: Colors.white),
                            label: Text(t('enterLab'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER ---

class LabPainter extends CustomPainter {
  final SimState sim;
  final int scenario;
  final int step;
  final int maxSteps;
  final double zoom;
  final double panX;
  final double panY;
  final String Function(String) t;
  final double time;

  LabPainter({
    required this.sim,
    required this.scenario,
    required this.step,
    required this.maxSteps,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.t,
    required this.time,
  });

  final Color outlineColor = const Color(0xFF0F172A);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    // Factory Background Walls
    canvas.drawRect(const Rect.fromLTWH(-2000, -2000, 4000, 2100), Paint()..color = const Color(0xFF1E293B));
    canvas.drawRect(const Rect.fromLTWH(-2000, 100, 4000, 2000), Paint()..color = const Color(0xFF0F172A));
    _drawLine(canvas, -2000, 100, 2000, 100, outlineColor, 6);

    // Background Gears (Animated)
    canvas.save(); 
    canvas.translate(-250, -80);
    canvas.rotate(time * 0.0005);
    _drawGear(canvas, 0, 0, 80, 130, 20, 12); 
    canvas.restore();

    canvas.save(); 
    canvas.translate(150, 60);
    canvas.rotate(-time * 0.0007);
    _drawGear(canvas, 0, 0, 40, 70, 15, 8); 
    canvas.restore();

    _drawRobot(canvas, -400, 30, 1.0);
    _drawConveyor(canvas, -320, 50, 640);
    _drawAnalysisBinMachine(canvas, 250, 0, sim.binItems, sim.target);

    // Tools Rack
    double rackX = -200, rackY = 160, rackW = 400, rackH = 90;
    _drawRRect(canvas, rackX, rackY, rackW, rackH, 10, const Color(0xFF1E293B), outlineColor, 4);
    _drawText(canvas, 'Tools', rackX + 50, rackY + 15, 12, const Color(0xFF94A3B8), Colors.transparent, 0);

    if (sim.allowedTools.contains('hammer')) {
      bool isHActive = sim.activeTool == 'hammer';
      _drawRRect(canvas, rackX + 20, rackY + 30, 50, 50, 8, isHActive ? const Color(0xFFFACC15) : const Color(0xFFCBD5E1), outlineColor, 3);
      _drawFactorHammer(canvas, rackX + 45, rackY + 55, 0.7, -pi/4);
    }

    for(int i = 0; i < sim.allowedDivisors.length; i++) {
      int d = sim.allowedDivisors[i];
      double bx = rackX + 90 + i * 60;
      if (sim.dragDivisor == d) {
        _drawRRect(canvas, bx, rackY + 30, 50, 50, 8, const Color(0xFF334155), outlineColor, 2);
      } else {
        _drawRRect(canvas, bx, rackY + 30, 50, 50, 8, const Color(0xFF93C5FD), outlineColor, 3);
        _drawText(canvas, d.toString(), bx + 25, rackY + 55, 24, const Color(0xFF0F172A), Colors.transparent, 0, TextAlign.center, 'monospace');
      }
    }

    // Blocks
    for (var b in sim.blocks) {
      if (b.id == sim.dragGem) continue;

      if (b.isPrime) {
        _drawPrimeGem(canvas, b.x, b.y, b.val);
      } else {
        _drawCompositeBlock(canvas, b.x, b.y, b.val);
      }
    }

    // Drags
    if (sim.dragGem != null) {
      int idx = sim.blocks.indexWhere((x) => x.id == sim.dragGem);
      if (idx != -1) {
        _drawPrimeGem(canvas, sim.dragX, sim.dragY, sim.blocks[idx].val);
      }
    }
    if (sim.dragDivisor != null) {
      _drawDivisorTool(canvas, sim.dragX, sim.dragY, sim.dragDivisor!);
    }

    // Draw Summary Overlay if scenario is completed
    if (step >= maxSteps) {
      canvas.save();
      _drawRRect(canvas, -250, -80, 500, 160, 16, const Color(0xE60F172A), outlineColor, 4);
      _drawText(canvas, t('s${scenario}_title') + " - Complete!", 0, -30, 22, const Color(0xFF4ADE80), Colors.transparent, 0);
      _drawText(canvas, t('s${scenario}_step${maxSteps}_out'), 0, 20, 16, Colors.white, Colors.transparent, 0, TextAlign.center);
      canvas.restore();
    }

    canvas.restore();
  }

  void _drawRRect(Canvas canvas, double x, double y, double w, double h, double r, Color fill, Color stroke, [double lw = 1]) {
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    if (fill != Colors.transparent) canvas.drawRRect(rect, Paint()..color = fill..style = PaintingStyle.fill);
    if (stroke != Colors.transparent && lw > 0) canvas.drawRRect(rect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = lw..strokeJoin = StrokeJoin.round);
  }

  void _drawLine(Canvas canvas, double x1, double y1, double x2, double y2, Color color, double width) {
    final paint = Paint()..color = color..strokeWidth = width..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }

  void _drawText(Canvas canvas, String text, double x, double y, double fontSize, Color fill, Color stroke, [double lw = 3, TextAlign align = TextAlign.center, String fontFamily = 'sans-serif']) {
    final lines = text.split('\n');
    final double lineHeight = fontSize * 1.2;
    double startY = y - ((lines.length - 1) * lineHeight) / 2;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (lw > 0 && stroke != Colors.transparent) {
        final tpStroke = TextPainter(
          text: TextSpan(text: line, style: TextStyle(fontFamily: fontFamily, fontSize: fontSize, fontWeight: FontWeight.bold, foreground: Paint()..style=PaintingStyle.stroke..strokeWidth=lw..color=stroke..strokeJoin=StrokeJoin.round)),
          textDirection: TextDirection.ltr, textAlign: align,
        )..layout();
        double px = align == TextAlign.left ? x : x - tpStroke.width / 2;
        tpStroke.paint(canvas, Offset(px, startY + i * lineHeight - tpStroke.height / 2));
      }

      final tpFill = TextPainter(
        text: TextSpan(text: line, style: TextStyle(fontFamily: fontFamily, fontSize: fontSize, fontWeight: FontWeight.bold, color: fill)),
        textDirection: TextDirection.ltr, textAlign: align,
      )..layout();
      double px = align == TextAlign.left ? x : x - tpFill.width / 2;
      tpFill.paint(canvas, Offset(px, startY + i * lineHeight - tpFill.height / 2));
    }
  }

  void _drawGear(Canvas canvas, double x, double y, double innerRadius, double outerRadius, double toothHeight, int teethCount) {
    canvas.save();
    canvas.translate(x, y);
    
    final path = Path();
    for (int i = 0; i < teethCount; i++) {
      double angle = (i * pi * 2) / teethCount;
      double p1Angle = angle - 0.1;
      double p2Angle = angle + 0.1;
      
      if (i == 0) path.moveTo(cos(p1Angle)*outerRadius, sin(p1Angle)*outerRadius);
      else path.lineTo(cos(p1Angle)*outerRadius, sin(p1Angle)*outerRadius);
      
      path.lineTo(cos(p1Angle)*(outerRadius+toothHeight), sin(p1Angle)*(outerRadius+toothHeight));
      path.lineTo(cos(p2Angle)*(outerRadius+toothHeight), sin(p2Angle)*(outerRadius+toothHeight));
      path.lineTo(cos(p2Angle)*outerRadius, sin(p2Angle)*outerRadius);
      
      double nextAngle = ((i + 1) * pi * 2) / teethCount;
      double p3Angle = nextAngle - 0.1;
      path.arcToPoint(Offset(cos(p3Angle)*outerRadius, sin(p3Angle)*outerRadius), radius: Radius.circular(outerRadius));
    }
    path.close();
    path.addOval(Rect.fromCircle(center: Offset.zero, radius: innerRadius));
    path.fillType = PathFillType.evenOdd;
    
    canvas.drawPath(path, Paint()..color = const Color(0xFF334155)..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 5);
    
    canvas.restore();
  }

  void _drawRobot(Canvas canvas, double x, double y, double scale) {
    canvas.save(); canvas.translate(x, y); canvas.scale(scale, scale);
    
    Color outline = const Color(0xFF94A3B8);
    Color bodyColor = const Color(0xFF7DD3FC); 
    Color darkGrey = const Color(0xFF64748B);
    Color lightGrey = const Color(0xFFCBD5E1);

    // Antenna
    _drawLine(canvas, 0, -65, 0, -85, outline, 4);
    canvas.drawCircle(const Offset(0, -85), 6, Paint()..color = const Color(0xFFFACC15));
    canvas.drawCircle(const Offset(0, -85), 6, Paint()..color = outline..style = PaintingStyle.stroke..strokeWidth = 2);

    // Ears
    canvas.drawPath(Path()..addArc(Rect.fromCircle(center: const Offset(-22, -45), radius: 6), pi/2, -pi), Paint()..color = darkGrey);
    canvas.drawPath(Path()..addArc(Rect.fromCircle(center: const Offset(22, -45), radius: 6), -pi/2, pi), Paint()..color = darkGrey);

    // Arms
    final armsPaint = Paint()..color = outline..style = PaintingStyle.stroke..strokeWidth = 4;
    canvas.drawPath(Path()..moveTo(-20, -10)..quadraticBezierTo(-45, -20, -40, -40), armsPaint);
    canvas.drawPath(Path()..moveTo(20, -10)..quadraticBezierTo(45, -20, 40, -40), armsPaint);
    
    // Legs
    _drawRRect(canvas, -15, 20, 8, 20, 0, darkGrey, outline, 2);
    _drawRRect(canvas, 7, 20, 8, 20, 0, darkGrey, outline, 2);
    
    // Feet
    canvas.drawPath(Path()..addArc(Rect.fromCircle(center: const Offset(-11, 40), radius: 8), pi, pi), Paint()..color = lightGrey);
    canvas.drawPath(Path()..addArc(Rect.fromCircle(center: const Offset(-11, 40), radius: 8), pi, pi), Paint()..color = outline..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawPath(Path()..addArc(Rect.fromCircle(center: const Offset(11, 40), radius: 8), pi, pi), Paint()..color = lightGrey);
    canvas.drawPath(Path()..addArc(Rect.fromCircle(center: const Offset(11, 40), radius: 8), pi, pi), Paint()..color = outline..style = PaintingStyle.stroke..strokeWidth = 2);

    // Head
    _drawRRect(canvas, -22, -65, 44, 38, 8, bodyColor, outline, 3);
    
    // Eyes
    final eyePaint = Paint()..color = outline..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawPath(Path()..addArc(Rect.fromCircle(center: const Offset(-10, -50), radius: 4), pi, pi), eyePaint);
    canvas.drawPath(Path()..addArc(Rect.fromCircle(center: const Offset(10, -50), radius: 4), pi, pi), eyePaint);
    
    // Mouth
    canvas.drawPath(Path()..addArc(Rect.fromCircle(center: const Offset(0, -42), radius: 6), 0, pi), eyePaint);

    // Neck
    _drawRRect(canvas, -8, -27, 16, 5, 0, darkGrey, outline, 2);

    // Body
    _drawRRect(canvas, -25, -22, 50, 42, 10, bodyColor, outline, 3);

    // Screen
    _drawRRect(canvas, -15, -12, 30, 20, 4, const Color(0xFF1E293B), outline, 2);
    final beatPaint = Paint()..color = const Color(0xFF4ADE80)..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawPath(Path()..moveTo(-10, -2)..lineTo(-5, -2)..lineTo(-2, -8)..lineTo(2, 4)..lineTo(5, -2)..lineTo(10, -2), beatPaint);

    canvas.restore();
  }

  void _drawConveyor(Canvas canvas, double x, double y, double width) {
    _drawRRect(canvas, x, y, width, 40, 20, const Color(0xFF334155), outlineColor, 4);
    _drawRRect(canvas, x + 5, y + 5, width - 10, 30, 15, const Color(0xFF1E293B), Colors.transparent, 0);
    for(double wx = x + 25; wx < x + width - 15; wx += 35) {
      canvas.drawCircle(Offset(wx, y + 20), 10, Paint()..color = const Color(0xFF64748B));
      canvas.drawCircle(Offset(wx, y + 20), 10, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawCircle(Offset(wx, y + 20), 3, Paint()..color = const Color(0xFFCBD5E1));
    }
    _drawLine(canvas, x + 50, y + 40, x + 50, y + 100, const Color(0xFF475569), 8);
    _drawLine(canvas, x + width - 50, y + 40, x + width - 50, y + 100, const Color(0xFF475569), 8);
  }

  void _drawFactorHammer(Canvas canvas, double x, double y, double scale, double angle) {
    canvas.save(); canvas.translate(x, y); canvas.scale(scale, scale); canvas.rotate(angle);
    _drawRRect(canvas, -5, -20, 10, 50, 5, const Color(0xFFD97706), outlineColor, 2);
    _drawRRect(canvas, -20, -30, 40, 20, 4, const Color(0xFF3B82F6), outlineColor, 2);
    _drawRRect(canvas, -25, -28, 5, 16, 0, const Color(0xFF94A3B8), outlineColor, 1);
    _drawRRect(canvas, 20, -28, 5, 16, 0, const Color(0xFF94A3B8), outlineColor, 1);
    canvas.restore();
  }

  void _drawPrimeGem(Canvas canvas, double x, double y, int val, [double scale = 1.0]) {
    canvas.save();
    canvas.translate(x, y); canvas.scale(scale, scale);
    
    final path = Path()..moveTo(-15, -10)..lineTo(15, -10)..lineTo(25, 5)..lineTo(0, 35)..lineTo(-25, 5)..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFA855F7)..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = const Color(0xFFF8FAFC)..style = PaintingStyle.stroke..strokeWidth = 2);
    
    canvas.drawPath(Path()..moveTo(-15, -10)..lineTo(0, 5)..lineTo(15, -10), Paint()..color = const Color(0xFFF8FAFC)..style = PaintingStyle.stroke..strokeWidth = 1);
    canvas.drawPath(Path()..moveTo(-25, 5)..lineTo(0, 5)..lineTo(25, 5), Paint()..color = const Color(0xFFF8FAFC)..style = PaintingStyle.stroke..strokeWidth = 1);
    canvas.drawPath(Path()..moveTo(0, 5)..lineTo(0, 35), Paint()..color = const Color(0xFFF8FAFC)..style = PaintingStyle.stroke..strokeWidth = 1);
    
    _drawText(canvas, val.toString(), 0, -25, 22, const Color(0xFFF8FAFC), const Color(0xFF0F172A), 3);
    canvas.restore();
  }

  void _drawCompositeBlock(Canvas canvas, double x, double y, int val, [double scale = 1.0]) {
    canvas.save(); canvas.translate(x, y); canvas.scale(scale, scale);
    _drawRRect(canvas, -30, -30, 60, 60, 8, const Color(0xFF94A3B8), outlineColor, 4);
    _drawRRect(canvas, -25, -25, 50, 45, 4, const Color(0xFFCBD5E1), Colors.transparent, 0);
    _drawText(canvas, val.toString(), 0, 0, 28, const Color(0xFF0F172A), Colors.transparent, 0);
    canvas.restore();
  }

  void _drawAnalysisBinMachine(Canvas canvas, double x, double y, List<int> binItems, int target) {
    canvas.save(); canvas.translate(x, y);
    _drawRRect(canvas, -100, -150, 200, 250, 10, const Color(0xFF94A3B8), outlineColor, 4);
    _drawRRect(canvas, -90, -130, 180, 80, 5, const Color(0xFF1E293B), outlineColor, 3);
    _drawText(canvas, t('lbl_analysis_bin').toUpperCase(), 0, -110, 12, const Color(0xFFCBD5E1), Colors.transparent, 0);
    
    if (binItems.isNotEmpty) {
      String eqStr = "$target = " + binItems.join(' x ');
      _drawText(canvas, eqStr, 0, -80, 16, const Color(0xFF38BDF8), Colors.transparent, 0, TextAlign.center, 'monospace');
    }
    
    _drawRRect(canvas, -60, 10, 120, 80, 5, const Color(0xFF334155), outlineColor, 4);
    canvas.drawRect(const Rect.fromLTWH(-55, 15, 110, 70), Paint()..color = const Color(0xFF0F172A)); 
    
    for (int i = 0; i < binItems.length; i++) {
      int r = i ~/ 2; int c = i % 2;
      _drawPrimeGem(canvas, -20 + c * 40.0, 35 + r * 35.0, binItems[i], 0.45);
    }
    canvas.restore();
  }

  void _drawDivisorTool(Canvas canvas, double x, double y, int val) {
    canvas.save();
    canvas.translate(x, y);
    canvas.drawCircle(Offset.zero, 20, Paint()..color = const Color(0xFF60A5FA));
    canvas.drawCircle(Offset.zero, 20, Paint()..color = outlineColor..style = PaintingStyle.stroke..strokeWidth = 3);
    for(int i=0; i<6; i++) {
      canvas.rotate(pi/3);
      _drawRRect(canvas, -5, -24, 10, 4, 0, const Color(0xFF60A5FA), outlineColor, 1);
    }
    _drawText(canvas, val.toString(), 0, 0, 18, const Color(0xFF0F172A), Colors.transparent, 0);
    canvas.restore();
  }

  @override
  bool shouldRepaint(LabPainter oldDelegate) => true;
}