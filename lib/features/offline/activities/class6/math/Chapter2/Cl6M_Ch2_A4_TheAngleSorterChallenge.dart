// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Angle Sorter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const Cl6M_Ch2_A4_TheAngleSorterChallenge(),
    ),
  );
}

// ==========================================
// LOCALIZATION (i18n) DICTIONARY
// ==========================================
const Map<String, Map<String, String>> kTranslations = {
  'en': {
    'appTitle': 'The Angle Sorter Challenge',
    'appSubtitle': 'Class 6 • Classifying Angles',
    'enterLab': 'Enter Simulation',
    'settings': 'Settings',
    'selectScenario': 'Select Scenario',
    'stepLabel': 'STEP',
    'doneBtn': 'Done',
    'learnLbl': 'Objective / Concept:',
    'summaryTitle': 'Goal Reached!',
    'resetBtn': 'Reset',
    'finishLab': 'Finish Lab',
    'nextScenario': 'Next Scenario',
    'finalDesc':
        'You have successfully classified acute, right, and obtuse angles!',
    'lbl_acute': 'ACUTE',
    'lbl_right': 'RIGHT',
    'lbl_obtuse': 'OBTUSE',
    'lbl_machine': 'Angle Sorter',
    's1_title': '1. The Sharp Key',
    's1_obj':
        "Understand that an acute angle is 'sharper' or smaller than a right angle.",
    's1_hud1': 'Drag the sharp key towards the machine.',
    's1_hud2': 'Try dropping it in the Right Angle slot.',
    's1_hud3': 'Now fit it in the Acute Angle slot.',
    's1_hud4': 'Observe the classification.',
    's1_t1': 'Drag the sharp Angle Key towards the Angle Sorter.',
    's1_o1': 'You picked up an Angle Key.',
    's1_t2': "Try to FIT the key into the middle 'Right Angle' slot.",
    's1_o2': "It bounces off! It's too sharp to fit.",
    's1_t3': "DRAG and FIT the key into the first 'Acute' slot.",
    's1_o3': 'It fits perfectly!',
    's1_t4': 'Observe the learning.',
    's1_o4': 'Angles sharper than a square corner (<90°) are Acute Angles.',
    's2_title': '2. The Corner Key',
    's2_obj': "Identify a right angle as a perfect 'square corner'.",
    's2_hud1': 'Drag the corner key to the machine.',
    's2_hud2': 'Try Acute or Obtuse slots.',
    's2_hud3': 'Fit in the Right Angle slot.',
    's2_hud4': 'Observe.',
    's2_t1': 'Drag the new square corner Angle Key.',
    's2_o1': 'You picked up the corner key.',
    's2_t2': "Try fitting it in the 'Acute' or 'Obtuse' slots.",
    's2_o2': "It bounces! It's not sharp or wide enough.",
    's2_t3': "FIT it into the middle 'Right Angle' slot.",
    's2_o3': 'It fits perfectly with a square mark!',
    's2_t4': 'Observe the learning.',
    's2_o4':
        'Angles that form a perfect square corner (=90°) are Right Angles.',
    's3_title': '3. The Wide Key',
    's3_obj':
        "Understand that an obtuse angle is 'wider' or larger than a right angle.",
    's3_hud1': 'Drag the wide key to the machine.',
    's3_hud2': 'Try Acute or Right slots.',
    's3_hud3': 'Fit in the Obtuse slot.',
    's3_hud4': 'Observe.',
    's3_t1': 'Drag the wide Angle Key.',
    's3_o1': 'You picked up the wide key.',
    's3_t2': "Try fitting it in the 'Acute' or 'Right' slots.",
    's3_o2': "It bounces! It's too wide.",
    's3_t3': "FIT it into the last 'Obtuse' slot.",
    's3_o3': 'It fits perfectly!',
    's3_t4': 'Observe the learning.',
    's3_o4': 'Angles wider than a square corner (>90°) are Obtuse Angles.',
    's4_title': '4. The Sorting Lineup',
    's4_obj':
        'Classify a set of acute, right, and obtuse angles without guidance.',
    's4_hud1': 'Sort all three keys into their correct slots.',
    's4_hud2': 'Great Job!',
    's4_t1': 'DRAG each key and DROP it into the correct slot.',
    's4_o1': 'Challenge Complete! All angles are correctly sorted.',
    's5_title': '5. Real-World Angle Hunt',
    's5_obj': 'Identify and classify angles on everyday objects.',
    's5_hud1': 'Click the pizza to extract an angle, then sort it.',
    's5_hud2': 'Click the book to extract an angle, then sort it.',
    's5_hud3': 'Click the laptop to extract an angle, then sort it.',
    's5_hud4': 'Great Job, Angle Detective!',
    's5_t1': 'CLICK the pizza slice to get an angle, then sort it.',
    's5_o1': 'Pizza sorted (Acute).',
    's5_t2': 'CLICK the book to get an angle, then sort it.',
    's5_o2': 'Book sorted (Right).',
    's5_t3': 'CLICK the laptop to get an angle, then sort it.',
    's5_o3': 'Laptop sorted (Obtuse). Angle Detective complete!',
  },
  'hi': {
    'appTitle': 'कोण छँटाई चुनौती',
    'appSubtitle': 'कक्षा 6 • कोणों का वर्गीकरण',
    'enterLab': 'सिमुलेशन दर्ज करें',
    'settings': 'सेटिंग्स',
    'selectScenario': 'परिदृश्य चुनें',
    'stepLabel': 'चरण',
    'doneBtn': 'पूर्ण',
    'learnLbl': 'उद्देश्य:',
    'summaryTitle': 'लक्ष्य प्राप्त हुआ!',
    'resetBtn': 'रीसेट',
    'finishLab': 'समाप्त करें',
    'nextScenario': 'अगला परिदृश्य',
    'finalDesc':
        'आपने सफलतापूर्वक न्यून, समकोण और अधिक कोणों का वर्गीकरण किया है!',
    'lbl_acute': 'न्यून कोण',
    'lbl_right': 'समकोण',
    'lbl_obtuse': 'अधिक कोण',
    'lbl_machine': 'कोण सॉर्टर',
    's1_title': '1. तीखी चाबी (न्यून कोण)',
    's1_obj': "समझें कि न्यून कोण समकोण से 'तीखा' या छोटा होता है।",
    's1_hud1': 'तीखी चाबी को मशीन की ओर खींचें।',
    's1_hud2': 'इसे समकोण स्लॉट में डालने का प्रयास करें।',
    's1_hud3': 'अब इसे न्यून कोण स्लॉट में फिट करें।',
    's1_hud4': 'वर्गीकरण का निरीक्षण करें।',
    's1_t1': 'तीखी चाबी को खींचें।',
    's1_o1': 'आपने न्यून कोण चाबी उठाई।',
    's1_t2': "इसे बीच वाले 'समकोण' स्लॉट में फिट करने का प्रयास करें।",
    's1_o2': 'यह उछल कर वापस आ जाती है! यह बहुत तीखी है।',
    's1_t3': "इसे पहले 'न्यून कोण' स्लॉट में फिट करें।",
    's1_o3': 'यह पूरी तरह से फिट हो गई!',
    's1_t4': 'सीख का निरीक्षण करें।',
    's1_o4': 'समकोण से छोटे कोणों (<90°) को न्यून कोण कहते हैं।',
    's2_title': '2. कोने वाली चाबी (समकोण)',
    's2_obj': "समकोण को एक पूर्ण 'चौकोर कोने' के रूप में पहचानें।",
    's2_hud1': 'चौकोर चाबी को मशीन की ओर खींचें।',
    's2_hud2': 'न्यून या अधिक कोण स्लॉट आज़माएं।',
    's2_hud3': 'समकोण स्लॉट में फिट करें।',
    's2_hud4': 'निरीक्षण करें।',
    's2_t1': 'चौकोर कोने वाली चाबी खींचें।',
    's2_o1': 'आपने समकोण चाबी उठाई।',
    's2_t2': "'न्यून' या 'अधिक' स्लॉट में इसे फिट करने का प्रयास करें।",
    's2_o2': 'यह उछल जाती है! यह सही आकार नहीं है।',
    's2_t3': "इसे बीच वाले 'समकोण' स्लॉट में फिट करें।",
    's2_o3': 'यह एक चौकोर चिह्न के साथ पूरी तरह फिट हो गई!',
    's2_t4': 'सीख का निरीक्षण करें।',
    's2_o4': 'एक पूर्ण चौकोर कोना बनाने वाले कोणों (=90°) को समकोण कहते हैं।',
    's3_title': '3. चौड़ी चाबी (अधिक कोण)',
    's3_obj': "समझें कि अधिक कोण समकोण से 'चौड़ा' या बड़ा होता है।",
    's3_hud1': 'चौड़ी चाबी को मशीन की ओर खींचें।',
    's3_hud2': 'न्यून या समकोण स्लॉट आज़माएं।',
    's3_hud3': 'अधिक कोण स्लॉट में फिट करें।',
    's3_hud4': 'निरीक्षण करें।',
    's3_t1': 'चौड़ी चाबी खींचें।',
    's3_o1': 'आपने अधिक कोण चाबी उठाई।',
    's3_t2': "'न्यून' या 'समकोण' स्लॉट में फिट करने का प्रयास करें।",
    's3_o2': 'यह उछल जाती है! यह बहुत चौड़ी है।',
    's3_t3': "इसे अंतिम 'अधिक कोण' स्लॉट में फिट करें।",
    's3_o3': 'यह पूरी तरह से फिट हो गई!',
    's3_t4': 'सीख का निरीक्षण करें।',
    's3_o4': 'समकोण से चौड़े कोणों (>90°) को अधिक कोण कहते हैं।',
    's4_title': '4. छँटाई लाइनअप',
    's4_obj': 'बिना किसी मार्गदर्शन के कोणों के एक समूह को वर्गीकृत करें।',
    's4_hud1': 'तीनों चाबियों को उनके सही स्लॉट में छाँटें।',
    's4_hud2': 'बहुत बढ़िया!',
    's4_t1': 'प्रत्येक चाबी को उसके सही स्लॉट में खींचें और छोड़ें।',
    's4_o1': 'चुनौती पूरी हुई! सभी कोण सही ढंग से छांटे गए।',
    's5_title': '5. वास्तविक दुनिया में कोण की खोज',
    's5_obj': 'रोजमर्रा की वस्तुओं पर कोणों को पहचानें और वर्गीकृत करें।',
    's5_hud1': 'पिज्जा से कोण निकालने के लिए क्लिक करें, फिर छाँटें।',
    's5_hud2': 'किताब पर क्लिक करें, फिर छाँटें।',
    's5_hud3': 'लैपटॉप पर क्लिक करें, फिर छाँटें।',
    's5_hud4': 'बहुत बढ़िया, कोण जासूस!',
    's5_t1': 'पिज्जा स्लाइस पर क्लिक करें और उसे छाँटें।',
    's5_o1': 'पिज्जा छांटा गया (न्यून)।',
    's5_t2': 'किताब पर क्लिक करें और उसे छाँटें।',
    's5_o2': 'किताब छांटी गई (समकोण)।',
    's5_t3': 'लैपटॉप पर क्लिक करें और उसे छाँटें।',
    's5_o3': 'लैपटॉप छांटा गया (अधिक)।',
  },
};

// ==========================================
// MODELS & CONFIG
// ==========================================
class ScenarioStep {
  final String hud;
  final String task;
  final String outcome;
  ScenarioStep({required this.hud, required this.task, required this.outcome});
}

class ScenarioConfig {
  final String title;
  final String objective;
  final List<ScenarioStep> steps;
  ScenarioConfig({
    required this.title,
    required this.objective,
    required this.steps,
  });
}

ScenarioConfig getScenarioConfig(int id, String lang) {
  String t(String key) =>
      kTranslations[lang]?[key] ?? kTranslations['en']![key]!;
  int numSteps = (id == 4)
      ? 1
      : (id == 5)
      ? 3
      : 4;
  List<ScenarioStep> steps = [];
  for (int i = 1; i <= numSteps; i++) {
    steps.add(
      ScenarioStep(
        hud: t('s${id}_hud$i'),
        task: t('s${id}_t$i'),
        outcome: t('s${id}_o$i'),
      ),
    );
  }
  return ScenarioConfig(
    title: t('s${id}_title'),
    objective: t('s${id}_obj'),
    steps: steps,
  );
}

class AngleKey {
  final String id;
  final String type; // 'acute', 'right', 'obtuse'
  final double deg;
  final Color color;
  final Offset basePos;
  final bool isTransparent;
  double x;
  double y;
  bool slotted;

  // Animation props
  bool isAnimating = false;
  Offset startPos = Offset.zero;
  Offset targetPos = Offset.zero;
  double animProgress = 0.0;

  AngleKey({
    required this.id,
    required this.type,
    required this.deg,
    required this.color,
    required this.basePos,
    required this.x,
    required this.y,
    this.slotted = false,
    this.isTransparent = false,
  });
}

class WorldObject {
  final String id;
  final String type;
  final double x;
  final double y;
  bool extracted;
  bool hover;

  WorldObject({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.extracted = false,
    this.hover = false,
  });
}

class GameState {
  int scenario = 1;
  int step = 0;
  List<AngleKey> keys = [];
  List<WorldObject> objects = [];

  double zoom = 1.0;
  double panX = 0.0;
  double panY = 0.0;

  AngleKey? activeDrag;
  String? hoverSlot;
  bool showSuccessPopup = false;
}

// ==========================================
// AUDIO ENGINE
// ==========================================
class SoundEngine {
  static final AudioPlayer _player = AudioPlayer();
  static final Map<String, String> _sounds = {
    'tick': 'audio/class6/math/click.mp3',
    'snap': 'audio/class6/math/error.mp3',
    'success': 'audio/class6/math/mixkit_2013.mp3',
    'error': 'audio/class6/math/mixkit_2955.mp3',
    'pop': 'audio/class6/math/mixkit_2570.mp3',
  };

  static void play(String type) async {
    try {
      if (_sounds.containsKey(type)) {
        await _player.play(AssetSource(_sounds[type]!));
      }
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }
}

// ==========================================
// MAIN APP WIDGET
// ==========================================
class Cl6M_Ch2_A4_TheAngleSorterChallenge extends StatefulWidget {
  const Cl6M_Ch2_A4_TheAngleSorterChallenge({super.key});

  @override
  State<Cl6M_Ch2_A4_TheAngleSorterChallenge> createState() =>
      _Cl6M_Ch2_A4_TheAngleSorterChallengeState();
}

class _Cl6M_Ch2_A4_TheAngleSorterChallengeState
    extends State<Cl6M_Ch2_A4_TheAngleSorterChallenge>
    with SingleTickerProviderStateMixin {
  String _lang = 'en';
  bool _sidebarOpen = true;

  // Curtain State Variables
  bool _showCurtain = true;
  bool _curtainSlideOut = false;

  final GameState _state = GameState();
  final GlobalKey _canvasKey = GlobalKey();

  late AnimationController _ticker;
  double _initialZoom = 1.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _ticker.addListener(_gameLoop);

    _loadScenario(1);
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

  String t(String key) =>
      kTranslations[_lang]?[key] ?? kTranslations['en']![key]!;

  void _toggleLanguage() {
    setState(() {
      _lang = _lang == 'en' ? 'hi' : 'en';
    });
    SoundEngine.play('pop');
  }

  void _resetLab() {
    SoundEngine.play('error');
    setState(() {
      _showCurtain = true;
    });

    // Allow the framework to build the curtain widget first, then snap it down.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _curtainSlideOut = false;
      });
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _loadScenario(1);
    });
  }

  void _loadScenario(int id) {
    setState(() {
      if (id == 1) _showCurtain = true;
      _state.scenario = id;
      _state.step = 0;
      _state.keys.clear();
      _state.objects.clear();
      _state.activeDrag = null;
      _state.hoverSlot = null;
      _state.showSuccessPopup = false;

      double ySpawn = 180;

      if (id == 1) {
        _state.keys.add(
          AngleKey(
            id: '1',
            type: 'acute',
            deg: 45,
            color: const Color(0xFFEF4444),
            x: 0,
            y: ySpawn,
            basePos: Offset(0, ySpawn),
          ),
        );
      } else if (id == 2) {
        _state.keys.add(
          AngleKey(
            id: '1',
            type: 'right',
            deg: 90,
            color: const Color(0xFF3B82F6),
            x: 0,
            y: ySpawn,
            basePos: Offset(0, ySpawn),
          ),
        );
      } else if (id == 3) {
        _state.keys.add(
          AngleKey(
            id: '1',
            type: 'obtuse',
            deg: 135,
            color: const Color(0xFF8B5CF6),
            x: 0,
            y: ySpawn,
            basePos: Offset(0, ySpawn),
          ),
        );
      } else if (id == 4) {
        _state.keys.add(
          AngleKey(
            id: '1',
            type: 'acute',
            deg: 45,
            color: const Color(0xFFEF4444),
            x: -200,
            y: ySpawn,
            basePos: Offset(-200, ySpawn),
          ),
        );
        _state.keys.add(
          AngleKey(
            id: '2',
            type: 'right',
            deg: 90,
            color: const Color(0xFF3B82F6),
            x: 0,
            y: ySpawn,
            basePos: Offset(0, ySpawn),
          ),
        );
        _state.keys.add(
          AngleKey(
            id: '3',
            type: 'obtuse',
            deg: 135,
            color: const Color(0xFF8B5CF6),
            x: 200,
            y: ySpawn,
            basePos: Offset(200, ySpawn),
          ),
        );
      } else if (id == 5) {
        _state.objects.add(
          WorldObject(id: '1', type: 'acute', x: -250, y: ySpawn),
        );
        _state.objects.add(
          WorldObject(id: '2', type: 'right', x: 0, y: ySpawn),
        );
        _state.objects.add(
          WorldObject(id: '3', type: 'obtuse', x: 250, y: ySpawn),
        );
      }

      _state.panX = 0;
      _state.panY = -30;
      _state.zoom = 1.0;
    });
  }

  void _advanceStep() {
    setState(() {
      _state.step++;
    });
  }

  // Completes the entire sequence, waits 2 seconds, and shows popup.
  void _triggerSuccessSequence() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          ScenarioConfig conf = getScenarioConfig(_state.scenario, _lang);
          _state.step = conf.steps.length; // Force marks all steps complete
          _state.showSuccessPopup = true;
        });
        SoundEngine.play('success');
      }
    });
  }

  void _animateKey(AngleKey key, Offset target, {VoidCallback? onComplete}) {
    key.startPos = Offset(key.x, key.y);
    key.targetPos = target;
    key.animProgress = 0.0;
    key.isAnimating = true;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          key.isAnimating = false;
          key.x = target.dx;
          key.y = target.dy;
        });
        if (onComplete != null) onComplete();
      }
    });
  }

  void _gameLoop() {
    bool needsRepaint = false;
    for (var key in _state.keys) {
      if (key.isAnimating) {
        key.animProgress += 0.05; // Roughly 300ms total
        if (key.animProgress > 1.0) key.animProgress = 1.0;
        double ease =
            1 - math.pow(1 - key.animProgress, 3).toDouble(); // Cubic out
        key.x = key.startPos.dx + (key.targetPos.dx - key.startPos.dx) * ease;
        key.y = key.startPos.dy + (key.targetPos.dy - key.startPos.dy) * ease;
        needsRepaint = true;
      }
    }
    if (needsRepaint) setState(() {});
  }

  String? _checkSlotHover(double worldX, double worldY) {
    double mY = -80;
    double sy = mY + 110;
    if (math.pow(-250 - worldX, 2) + math.pow(sy - worldY, 2) < 4900) {
      return 'acute';
    }
    if (math.pow(0 - worldX, 2) + math.pow(sy - worldY, 2) < 4900) {
      return 'right';
    }
    if (math.pow(250 - worldX, 2) + math.pow(sy - worldY, 2) < 4900) {
      return 'obtuse';
    }
    return null;
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (_state.showSuccessPopup || _showCurtain) return;
    final RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    Offset localPos = box.globalToLocal(details.focalPoint);
    double cw = box.size.width;
    double ch = box.size.height;

    double worldX = (localPos.dx - cw / 2 - _state.panX) / _state.zoom;
    double worldY = (localPos.dy - ch / 2 - _state.panY) / _state.zoom;

    _initialZoom = _state.zoom;

    // Check Keys
    for (int i = _state.keys.length - 1; i >= 0; i--) {
      var k = _state.keys[i];
      if (!k.slotted &&
          math.pow(k.x - worldX, 2) + math.pow(k.y - worldY, 2) < 4900) {
        setState(() {
          _state.activeDrag = k;
          SoundEngine.play('tick');
        });
        if (_state.scenario == 1 && _state.step == 0) _advanceStep();
        if (_state.scenario == 2 && _state.step == 0) _advanceStep();
        if (_state.scenario == 3 && _state.step == 0) _advanceStep();
        return;
      }
    }

    // Check Objects (S5)
    if (_state.scenario == 5) {
      for (var obj in _state.objects) {
        if (!obj.extracted &&
            math.pow(obj.x - worldX, 2) + math.pow(obj.y - worldY, 2) < 6400) {
          setState(() {
            obj.extracted = true;
            SoundEngine.play('pop');

            double deg = obj.type == 'acute'
                ? 45
                : obj.type == 'right'
                ? 90
                : 135;
            Color color = obj.type == 'acute'
                ? const Color(0xFFEF4444)
                : obj.type == 'right'
                ? const Color(0xFF3B82F6)
                : const Color(0xFF8B5CF6);

            var newKey = AngleKey(
              id: 'k_${obj.id}',
              type: obj.type,
              deg: deg,
              color: color,
              x: obj.x,
              y: obj.y,
              basePos: Offset(obj.x, obj.y),
              isTransparent: true,
            );
            _state.keys.add(newKey);
            _state.activeDrag = newKey;
          });
          return;
        }
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_state.showSuccessPopup || _showCurtain) return;
    if (_state.activeDrag != null) {
      final RenderBox? box =
          _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) return;
      Offset localPos = box.globalToLocal(details.focalPoint);
      double worldX =
          (localPos.dx - box.size.width / 2 - _state.panX) / _state.zoom;
      double worldY =
          (localPos.dy - box.size.height / 2 - _state.panY) / _state.zoom;

      setState(() {
        _state.activeDrag!.x = worldX;
        _state.activeDrag!.y = worldY;
        _state.hoverSlot = _checkSlotHover(worldX, worldY);
      });
    } else {
      // Pan and Zoom
      setState(() {
        _state.panX += details.focalPointDelta.dx;
        _state.panY += details.focalPointDelta.dy;
        if (details.scale != 1.0) {
          _state.zoom = (_initialZoom * details.scale).clamp(0.4, 2.5);
        }
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_state.activeDrag != null) {
      var k = _state.activeDrag!;
      var targetSlot = _state.hoverSlot;

      bool valid = false;
      bool advStep = false;

      if (targetSlot != null) {
        if (_state.scenario == 1) {
          if (targetSlot == 'right' && _state.step == 1) {
            _advanceStep();
          } else if (targetSlot == 'acute' && _state.step >= 1) {
            valid = true;
            if (_state.step < 3) _state.step = 3;
            advStep = true;
          }
        } else if (_state.scenario == 2) {
          if ((targetSlot == 'acute' || targetSlot == 'obtuse') &&
              _state.step == 1) {
            _advanceStep();
          } else if (targetSlot == 'right' && _state.step >= 1) {
            valid = true;
            if (_state.step < 3) _state.step = 3;
            advStep = true;
          }
        } else if (_state.scenario == 3) {
          if ((targetSlot == 'acute' || targetSlot == 'right') &&
              _state.step == 1) {
            _advanceStep();
          } else if (targetSlot == 'obtuse' && _state.step >= 1) {
            valid = true;
            if (_state.step < 3) _state.step = 3;
            advStep = true;
          }
        } else {
          if (k.type == targetSlot) valid = true;
        }

        if (valid) {
          SoundEngine.play('snap');
          k.slotted = true;
          double sx = targetSlot == 'acute'
              ? -250
              : targetSlot == 'right'
              ? 0
              : 250;
          double sy = -80 + 110;

          _animateKey(
            k,
            Offset(sx, sy),
            onComplete: () {
              if (advStep) {
                _triggerSuccessSequence();
              }
              _checkS4S5Success();
            },
          );
        } else {
          SoundEngine.play('error');
          _animateKey(k, k.basePos);
        }
      } else {
        SoundEngine.play('error');
        _animateKey(k, k.basePos);
      }

      setState(() {
        _state.activeDrag = null;
        _state.hoverSlot = null;
      });
    }
  }

  void _checkS4S5Success() {
    if (_state.scenario == 4) {
      bool allSlotted =
          _state.keys.isNotEmpty && _state.keys.every((k) => k.slotted);
      if (allSlotted && _state.step == 0) {
        setState(() => _state.step = 1);
        _triggerSuccessSequence();
      }
    } else if (_state.scenario == 5) {
      int slottedCount = _state.keys.where((k) => k.slotted).length;
      if (slottedCount == 1 && _state.step == 0) {
        setState(() => _state.step = 1);
      } else if (slottedCount == 2 && _state.step == 1) {
        setState(() => _state.step = 2);
      } else if (slottedCount == 3 && _state.step == 2) {
        setState(() => _state.step = 3);
        _triggerSuccessSequence();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    double sidebarWidth = math.max(300.0, sw * 0.35);
    ScenarioConfig config = getScenarioConfig(_state.scenario, _lang);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // CANVAS AREA
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? sidebarWidth : 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                onScaleEnd: _handleScaleEnd,
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: CustomPaint(
                    key: _canvasKey,
                    painter: AngleSorterPainter(
                      state: _state,
                      lang: _lang,
                      translations: kTranslations,
                    ),
                  ),
                ),
              ),
            ),

            // HUD OVERLAY (Follows canvas)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? sidebarWidth : 0,
              right: 0,
              bottom: 40,
              child: IgnorePointer(child: _buildHUD(config)),
            ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _sidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              top: 0,
              bottom: 0,
              child: _buildSidebar(config),
            ),

            // MENU BUTTON (Fixed at Top-Left)
            Positioned(
              left: 10,
              top: 10,
              child: Material(
                color: const Color(0xCC1E293B),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    setState(() => _sidebarOpen = !_sidebarOpen);
                    SoundEngine.play('tick');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      _sidebarOpen ? Icons.menu_open : Icons.menu,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),

            // SUCCESS POPUP
            if (_state.showSuccessPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Container(
                    width: 450,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF334155),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x6610B981),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.flag,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          t('summaryTitle'),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _state.scenario == 5
                              ? t('finalDesc')
                              : config.steps.last.outcome,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _state.scenario < 5
                                ? const Color(0xFF4F46E5)
                                : const Color(0xFFD97706),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            if (_state.scenario < 5) {
                              _loadScenario(_state.scenario + 1);
                            } else {
                              _resetLab(); // Complete Reset
                            }
                          },
                          icon: Icon(
                            _state.scenario < 5
                                ? Icons.arrow_forward
                                : Icons.refresh,
                            color: Colors.white,
                          ),
                          label: Text(
                            _state.scenario < 5
                                ? t('nextScenario')
                                : t('finishLab'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // CURTAIN SCREEN (INTRO)
            if (_showCurtain)
              AnimatedSlide(
                offset: _curtainSlideOut ? const Offset(0, -1) : Offset.zero,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOutCubic,
                child: Container(
                  color: const Color(0xFF0F172A),
                  width: sw,
                  height: sh,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      constraints: BoxConstraints(minHeight: sh),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x666366F1),
                                  blurRadius: 40,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.architecture,
                              size: 80,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            t('appTitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('appSubtitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              elevation: 10,
                              shadowColor: const Color(0x666366F1),
                            ),
                            onPressed: () {
                              SoundEngine.play('pop');
                              setState(() => _curtainSlideOut = true);
                              Future.delayed(
                                const Duration(milliseconds: 1000),
                                () {
                                  if (mounted) {
                                    setState(() => _showCurtain = false);
                                  }
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.play_circle_fill,
                              size: 28,
                              color: Colors.white,
                            ),
                            label: Text(
                              t('enterLab'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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

  Widget _buildHUD(ScenarioConfig config) {
    if (_state.step >= config.steps.length) return const SizedBox.shrink();
    String hudText = config.steps[_state.step].hud;

    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xE60F172A),
          borderRadius: BorderRadius.circular(20),
          border: const Border(
            top: BorderSide(color: Color(0xFF4F46E5), width: 4),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0x334F46E5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFF818CF8),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                hudText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(ScenarioConfig config) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(right: BorderSide(color: Color(0xFF334155))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      // Shifted left padding to account for the fixed menu icon
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 64,
                        bottom: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F172A),
                        border: Border(
                          bottom: BorderSide(color: Color(0xFF334155)),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.architecture,
                                color: Color(0xFF6366F1),
                                size: 30,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t('appTitle'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      t('appSubtitle'),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white70,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: Row(
                                  children: [
                                    const Icon(
                                      Icons.language,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      _lang.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: _toggleLanguage,
                                tooltip: 'Toggle Language',
                              ),
                              IconButton(
                                icon: Row(
                                  children: [
                                    const Icon(
                                      Icons.refresh,
                                      color: Colors.redAccent,
                                    ),
                                    Text(
                                      t('resetBtn').toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: _resetLab,
                                tooltip: 'Reset',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              t('selectScenario').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF334155),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _state.scenario,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1E293B),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items: [1, 2, 3, 4, 5]
                                      .map(
                                        (id) => DropdownMenuItem(
                                          value: id,
                                          child: Text(t('s${id}_title')),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) _loadScenario(val);
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0x1A6366F1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0x4D6366F1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.radar,
                                        color: Color(0xFFF43F5E),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        t('learnLbl'),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    config.objective,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),
                            ...config.steps.asMap().entries.map(
                              (entry) => _buildStepCard(
                                entry.key,
                                entry.value,
                                config.steps.length,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFF020617),
                      alignment: Alignment.center,
                      child: const Text(
                        '© ZeroScienceLab | Fall in Love with Math and Science',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepCard(int index, ScenarioStep step, int totalSteps) {
    bool isCompleted = index < _state.step;
    bool isActive = index == _state.step;

    Color bgColor = isActive
        ? const Color(0x334F46E5)
        : (isCompleted ? const Color(0x1A10B981) : const Color(0x1AFFFFFF));
    Color borderColor = isActive
        ? const Color(0xFF6366F1)
        : (isCompleted ? const Color(0xFF10B981) : const Color(0x1AFFFFFF));
    Color iconColor = isActive
        ? Colors.white
        : (isCompleted ? const Color(0xFF10B981) : Colors.white54);

    return Opacity(
      opacity: (isCompleted || isActive) ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCompleted)
              const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28)
            else
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFF334155),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${t('stepLabel')} ${index + 1}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step.task,
                    style: TextStyle(
                      fontSize: 14,
                      color: isActive ? Colors.white : Colors.white70,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0x3310B981),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        step.outcome,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6EE7B7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PAINTER FOR CANVAS
// ==========================================
class AngleSorterPainter extends CustomPainter {
  final GameState state;
  final String lang;
  final Map<String, Map<String, String>> translations;

  AngleSorterPainter({
    required this.state,
    required this.lang,
    required this.translations,
  });

  String t(String key) => translations[lang]?[key] ?? translations['en']![key]!;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + state.panX, size.height / 2 + state.panY);
    canvas.scale(state.zoom, state.zoom);

    _drawMachine(canvas);

    // Draw S5 Objects
    if (state.scenario == 5) {
      for (var obj in state.objects) {
        if (obj.type == 'acute') {
          _drawPizza(canvas, obj.x, obj.y, obj.hover);
        } else if (obj.type == 'right') {
          _drawBook(canvas, obj.x, obj.y, obj.hover);
        } else if (obj.type == 'obtuse') {
          _drawLaptop(canvas, obj.x, obj.y, obj.hover);
        }

        // Draw checkmark if extracted and slotted
        if (state.keys.any((k) => k.id == 'k_${obj.id}' && k.slotted)) {
          final paint = Paint()
            ..color = const Color(0xFF22C55E)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(obj.x + 50, obj.y - 50), 20, paint);
          paint
            ..color = const Color(0xFF0F172A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawCircle(Offset(obj.x + 50, obj.y - 50), 20, paint);

          final path = Path()
            ..moveTo(obj.x + 40, obj.y - 50)
            ..lineTo(obj.x + 48, obj.y - 42)
            ..lineTo(obj.x + 60, obj.y - 58);
          canvas.drawPath(
            path,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..strokeCap = StrokeCap.round,
          );
        }
      }
    }

    // Draw Keys
    AngleKey? draggedKey;
    for (var k in state.keys) {
      if (k == state.activeDrag) {
        draggedKey = k;
      } else {
        _drawAngleKey(
          canvas,
          k.x,
          k.y,
          k.deg,
          k.color,
          k.isTransparent,
          k.slotted,
          false,
        );
      }
    }
    // Draw dragged key on top
    if (draggedKey != null) {
      _drawAngleKey(
        canvas,
        draggedKey.x,
        draggedKey.y,
        draggedKey.deg,
        draggedKey.color,
        draggedKey.isTransparent,
        draggedKey.slotted,
        true,
      );
    }

    canvas.restore();
  }

  void _drawMachine(Canvas canvas) {
    double mY = -80;
    double mW = 800;
    double mH = 240;
    double mX = -400;

    // Base Gradient
    final rect = Rect.fromLTWH(mX, mY, mW, mH);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF475569), Color(0xFF1E293B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(20)),
      paint,
    );

    // Outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(20)),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    // Inner Panel
    final innerRect = Rect.fromLTWH(mX + 15, mY + 15, mW - 30, mH - 30);
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(10)),
      Paint()..color = const Color(0xFF334155),
    );

    _drawText(
      canvas,
      t('lbl_machine').toUpperCase(),
      0,
      mY - 30,
      24,
      Colors.white,
      true,
    );

    var slots = [
      {'id': 'acute', 'cx': -250.0, 'deg': 45.0, 'lbl': '< 90°'},
      {'id': 'right', 'cx': 0.0, 'deg': 90.0, 'lbl': '= 90°'},
      {'id': 'obtuse', 'cx': 250.0, 'deg': 135.0, 'lbl': '> 90°'},
    ];

    for (var slot in slots) {
      double sx = slot['cx'] as double;
      double sy = mY + 110;
      double deg = slot['deg'] as double;
      String id = slot['id'] as String;

      bool isHovered = state.hoverSlot == id;

      // LED Light
      canvas.drawCircle(
        Offset(sx, sy - 75),
        6,
        Paint()
          ..color = isHovered
              ? const Color(0xFF22C55E)
              : const Color(0xFF0F172A),
      );
      if (isHovered) {
        canvas.drawCircle(
          Offset(sx, sy - 75),
          10,
          Paint()
            ..color = const Color(0x664ADE80)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
      canvas.drawCircle(
        Offset(sx, sy - 75),
        6,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Cutout Base
      final cutRect = Rect.fromLTWH(sx - 80, sy - 60, 160, 140);
      canvas.drawRRect(
        RRect.fromRectAndRadius(cutRect, const Radius.circular(12)),
        Paint()..color = const Color(0xFF1E293B),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(cutRect, const Radius.circular(12)),
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );

      // Guide lines
      canvas.save();
      canvas.translate(sx, sy + 10);
      canvas.rotate(math.pi); // Point upwards

      double radius = 55;
      double startAngle = -math.pi / 2 - (deg * math.pi / 180) / 2;
      double endAngle = -math.pi / 2 + (deg * math.pi / 180) / 2;

      final guidePaint = Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      _drawDashedLine(
        canvas,
        Offset.zero,
        Offset(radius * math.cos(startAngle), radius * math.sin(startAngle)),
        guidePaint,
      );
      _drawDashedLine(
        canvas,
        Offset.zero,
        Offset(radius * math.cos(endAngle), radius * math.sin(endAngle)),
        guidePaint,
      );

      final markPaint = Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      if (deg == 90.0) {
        double p1x = 15 * math.cos(startAngle), p1y = 15 * math.sin(startAngle);
        double p2x = 15 * math.cos(endAngle), p2y = 15 * math.sin(endAngle);
        final p = Path()
          ..moveTo(p1x, p1y)
          ..lineTo(p1x + p2x, p1y + p2y)
          ..lineTo(p2x, p2y);
        canvas.drawPath(p, markPaint);
      } else {
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: 20),
          startAngle,
          endAngle - startAngle,
          false,
          markPaint,
        );
      }
      canvas.restore();

      String label = id == 'acute'
          ? t('lbl_acute')
          : id == 'right'
          ? t('lbl_right')
          : t('lbl_obtuse');
      _drawText(canvas, label, sx, sy + 115, 16, Colors.white, true);
      _drawText(
        canvas,
        slot['lbl'] as String,
        sx,
        sy + 138,
        14,
        const Color(0xFF818CF8),
        true,
      );
    }
  }

  void _drawAngleKey(
    Canvas canvas,
    double x,
    double y,
    double deg,
    Color color,
    bool isTrans,
    bool isSlotted,
    bool isDragged,
  ) {
    canvas.save();
    canvas.translate(x, y);

    if (isDragged) {
      canvas.scale(1.15, 1.15);
      // Shadow
      canvas.drawCircle(
        const Offset(0, 15),
        50,
        Paint()
          ..color = Colors.black45
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    if (isSlotted) {
      canvas.translate(0, 10);
      canvas.rotate(math.pi);
    } else if (!isDragged && !isSlotted) {
      canvas.rotate(math.pi / 4);
    }

    double radius = 55;
    double startAngle = -math.pi / 2 - (deg * math.pi / 180) / 2;
    double sweepAngle = (deg * math.pi / 180);
    double endAngle = startAngle + sweepAngle;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(radius * math.cos(startAngle), radius * math.sin(startAngle))
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        startAngle,
        sweepAngle,
        false,
      )
      ..close();

    final fillPaint = Paint()
      ..color = color.withOpacity(isTrans ? 0.4 : 1.0)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    if (!isTrans) {
      // 3D Bevel Highlight
      canvas.drawLine(
        Offset.zero,
        Offset(
          (radius - 6) * math.cos(startAngle + 0.05),
          (radius - 6) * math.sin(startAngle + 0.05),
        ),
        Paint()
          ..color = Colors.white30
          ..strokeWidth = 4,
      );
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius - 4),
        startAngle + 0.1,
        sweepAngle - 0.2,
        false,
        Paint()
          ..color = Colors.white30
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    } else {
      _drawDashedPath(
        canvas,
        path,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Mark
    final markPaint = Paint()
      ..color = isTrans ? Colors.white : const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    if (deg == 90) {
      double p1x = 15 * math.cos(startAngle), p1y = 15 * math.sin(startAngle);
      double p2x = 15 * math.cos(endAngle), p2y = 15 * math.sin(endAngle);
      canvas.drawPath(
        Path()
          ..moveTo(p1x, p1y)
          ..lineTo(p1x + p2x, p1y + p2y)
          ..lineTo(p2x, p2y),
        markPaint,
      );
    } else {
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 20),
        startAngle,
        sweepAngle,
        false,
        markPaint,
      );
    }

    canvas.restore();
  }

  void _drawPizza(Canvas canvas, double x, double y, bool isHovered) {
    canvas.save();
    canvas.translate(x, y);
    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 25), width: 90, height: 20),
      Paint()..color = Colors.black26,
    );
    canvas.rotate(-math.pi / 6);

    // Crust
    final crustP = Path()
      ..addArc(
        Rect.fromCircle(center: const Offset(0, -60), radius: 40),
        math.pi,
        -math.pi,
      );
    canvas.drawPath(crustP, Paint()..color = const Color(0xFFB45309));
    canvas.drawPath(
      crustP,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Cheese
    final cheeseP = Path()
      ..moveTo(-35, -60)
      ..lineTo(0, 40)
      ..lineTo(35, -60)
      ..close();
    canvas.drawPath(cheeseP, Paint()..color = const Color(0xFFFACC15));
    canvas.drawPath(
      cheeseP,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Pepperoni
    final pepP = Paint()..color = const Color(0xFFEF4444);
    final outP = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    void dr(double cx, double cy, double r) {
      canvas.drawCircle(Offset(cx, cy), r, pepP);
      canvas.drawCircle(Offset(cx, cy), r, outP);
    }

    dr(-10, -30, 8);
    dr(15, -45, 8);
    dr(0, -10, 6);

    if (isHovered) {
      canvas.drawPath(
        cheeseP,
        Paint()
          ..color = const Color(0xFF6366F1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeJoin = StrokeJoin.round,
      );
    }
    canvas.restore();
  }

  void _drawBook(Canvas canvas, double x, double y, bool isHovered) {
    canvas.save();
    canvas.translate(x, y);
    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 35), width: 110, height: 30),
      Paint()..color = Colors.black26,
    );

    final outP = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    // Cover
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-50, -40, 100, 80),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF3B82F6),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-50, -40, 100, 80),
        const Radius.circular(4),
      ),
      outP,
    );
    // Pages
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-45, -35, 90, 70),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFF8FAFC),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-45, -35, 90, 70),
        const Radius.circular(2),
      ),
      outP..strokeWidth = 2,
    );
    // Binding
    canvas.drawRect(
      const Rect.fromLTWH(-50, -40, 10, 80),
      Paint()..color = const Color(0xFF1D4ED8),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-50, -40, 10, 80),
      outP..strokeWidth = 3,
    );

    if (isHovered) {
      canvas.drawPath(
        Path()
          ..moveTo(-45, -35)
          ..lineTo(45, -35)
          ..lineTo(45, 35),
        Paint()
          ..color = const Color(0xFF6366F1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeJoin = StrokeJoin.round,
      );
    }
    canvas.restore();
  }

  void _drawLaptop(Canvas canvas, double x, double y, bool isHovered) {
    canvas.save();
    canvas.translate(x, y);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 30), width: 130, height: 30),
      Paint()..color = Colors.black26,
    );

    final outP = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    // Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-60, 20, 120, 10),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF94A3B8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-60, 20, 120, 10),
        const Radius.circular(2),
      ),
      outP,
    );

    // Screen
    canvas.rotate(-math.pi / 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-60, -70, 120, 80),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFCBD5E1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-60, -70, 120, 80),
        const Radius.circular(4),
      ),
      outP,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-55, -65, 110, 70),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF334155),
    );
    canvas.rotate(math.pi / 6);

    if (isHovered) {
      double sx = -60 * math.cos(-math.pi / 6) - -70 * math.sin(-math.pi / 6);
      double sy = -60 * math.sin(-math.pi / 6) + -70 * math.cos(-math.pi / 6);
      canvas.drawPath(
        Path()
          ..moveTo(sx, sy)
          ..lineTo(-60, 20)
          ..lineTo(60, 20),
        Paint()
          ..color = const Color(0xFF6366F1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeJoin = StrokeJoin.round,
      );
    }
    canvas.restore();
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color color,
    bool bold,
  ) {
    final textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy);
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 8.0;
    double distance = 0.0;
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant AngleSorterPainter oldDelegate) => true;
}
