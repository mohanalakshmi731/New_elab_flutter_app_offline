// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math';
import 'dart:ui'; // Required for PathMetric
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FramingAndSolvingLinearEquationsApp());
}

class FramingAndSolvingLinearEquationsApp extends StatelessWidget {
  const FramingAndSolvingLinearEquationsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Balance of Equations',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Forced Dark Theme for the Lab
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const FramingAndSolvingLinearEquationsScreen(),
    );
  }
}

// --- Data Models ---

class GameEntity {
  String id;
  String type; // 'box', 'weight', 'weight_bundle', 'ghost_weight'
  double val;
  String? pan; // 'left', 'right', 'shelf', 'bin', null
  double x;
  double y;
  double targetX;
  double targetY;
  double? homeX;
  double? homeY;
  bool isDraggable;
  bool glow;
  bool isHidden;
  bool isDisposing;
  bool isRevealed;
  bool isReturning;
  double scale;
  double returnProgress;
  double returnStartX;
  double returnStartY;
  String? returnPan;
  double disposeTargetX;
  double disposeTargetY;
  Function? onClick;

  GameEntity({
    required this.id,
    required this.type,
    this.val = 1,
    this.pan,
    this.x = 0,
    this.y = 0,
    this.targetX = 0,
    this.targetY = 0,
    this.homeX,
    this.homeY,
    this.isDraggable = false,
    this.glow = false,
    this.isHidden = false,
    this.isDisposing = false,
    this.isRevealed = false,
    this.isReturning = false,
    this.scale = 1.0,
    this.returnProgress = 0,
    this.returnStartX = 0,
    this.returnStartY = 0,
    this.returnPan,
    this.disposeTargetX = 0,
    this.disposeTargetY = 0,
    this.onClick,
  });
}

class DistPile {
  double x, y, val;
  String boxId;
  DistPile({required this.x, required this.y, required this.val, required this.boxId});
}

class Particle {
  double x, y, vx, vy, life;
  Color color;
  Particle(this.x, this.y, this.vx, this.vy, this.life, this.color);
}

// --- Translation Data ---

const Map<String, dynamic> i18n = {
  'en': {
    'title': "The Balance of Equations",
    'subtitle': "Class 7 • FINDING THE UNKNOWN",
    'enterLab': "Enter Virtual Lab",
    'selectScenario': "Select Scenario",
    'missionObj': "Mission Steps",
    'hudDefault': "Select a scenario to begin.",
    'msgBin': "REMOVAL BIN",
    'msgDist': "DISTRIBUTION ZONE",
    'footer': "© ZeroScienceLab - Fall in love with math and Science",
    'btnConvert': "Convert Units",
    'btnValidate': "Validate Model",
    'scenarios': [
      {
        'title': "1. The Lone Mystery",
        'objective': "Understand equality where an unknown is directly balanced by a known value.",
        'steps': [
          {'text': "Observe the balanced scale. The equation is x = 3. CLICK the glowing Mystery Box to reveal its weight.", 'hud': "Click the glowing box to reveal." },
          {'text': "The scale is balanced. This means the left side equals the right side. The weight of one mystery box (x) is equal to 3 kg. The solution is x = 3.", 'hud': "Equation Solved: x = 3!" }
        ]
      },
      {
        'title': "2. Isolating the Unknown",
        'objective': "Isolate the unknown variable by subtracting the same amount from both sides.",
        'steps': [
          {'text': "The scale is balanced: x + 2 = 5. DRAG one 1kg weight from the left pan and drop it into the Removal Bin.", 'hud': "Remove 1kg from the left pan." },
          {'text': "Keep balancing! Now DRAG the second 1kg weight from the left pan to the bin.", 'hud': "Remove the second 1kg from the left pan." },
          {'text': "To find the value of 'x', we removed the extra 2kg from the left side. To keep the balance, we had to remove 2kg from the right side too. Now we can see that x = 3.", 'hud': "Concept Discovered: Balanced Subtraction." }
        ]
      },
      {
        'title': "3. Sharing the Weight",
        'objective': "Learn to solve equations like ax = b by visually representing division.",
        'steps': [
          {'text': "Observe the balanced scale. The left pan holds two identical Mystery Boxes ('x'). The right pan holds six 1kg weights. The equation 2x = 6 is displayed above.", 'hud': "Observe the balanced scale." },
          {'text': "DRAG the group of six weights from the right pan and DROP them onto the 'Distribution Zone' between the two pans.", 'hud': "Drag the 6kg bundle to the Distribution Zone." },
          {'text': "CLICK on one of the Mystery Boxes to see its value.", 'hud': "Click a box to reveal its weight." },
          {'text': "When 2 boxes equal 6kg, we can find the weight of one box by dividing the 6kg equally. Each box must weigh 3kg. The solution is x = 3.", 'hud': "Equation Solved: 2x = 6  →  x = 3." }
        ]
      },
      {
        'title': "4. Two-Step Balance",
        'objective': "Combine subtraction and division principles to solve a two-step equation.",
        'steps': [
          {'text': "Observe the balanced scale. The left pan holds three Mystery Boxes ('x') and one 1kg weight. The right pan holds seven 1kg weights. The equation 3x + 1 = 7 is displayed. Your mission is to find the weight of one box.", 'hud': "Observe the balanced scale." },
          {'text': "First, get the Mystery Boxes by themselves. DRAG the extra 1kg weight from the left pan to the 'Removal Zone'.", 'hud': "Remove the extra 1kg from the left pan." },
          {'text': "Now, find the weight of a single box. DRAG the group of six weights from the right pan to the 'Distribution Zone'.", 'hud': "Drag the 6kg bundle to the Distribution Zone." },
          {'text': "You solved a two-step equation! x = 2.", 'hud': "Challenge Complete: 3x + 1 = 7  →  x = 2." }
        ]
      },
      {
        'title': "5. Balancing Both Sides",
        'objective': "Solve an equation with variables on both sides of the scale.",
        'steps': [
          {'text': "Solve 2x + 3 = x + 5. First, get boxes on one side. DRAG the Mystery Box from the right pan to the bin.", 'hud': "Remove the 'x' box from the right pan." },
          {'text': "Now we have x + 3 = 5. Isolate the final box by DRAGGING the 3kg bundle from the left pan to the bin.", 'hud': "Remove the 3kg bundle from the left pan." },
          {'text': "Brilliant! You simplified a complex equation step-by-step. x = 2.", 'hud': "Ultimate Challenge Complete: x = 2." }
        ]
      }
    ]
  },
  'hi': {
    'title': "समीकरणों का संतुलन",
    'subtitle': "कक्षा 7 • अज्ञात का पता लगाना",
    'enterLab': "वर्चुअल लैब में प्रवेश करें",
    'selectScenario': "परिदृश्य चुनें",
    'missionObj': "मिशन के चरण",
    'hudDefault': "शुरू करने के लिए एक परिदृश्य चुनें।",
    'msgBin': "कचरे का डिब्बा",
    'msgDist': "वितरण क्षेत्र",
    'footer': "© ZeroScienceLab - Fall in love with math and Science",
    'btnConvert': "इकाइयां बदलें",
    'btnValidate': "मॉडल सत्यापित करें",
    'scenarios': [
      {
        'title': "1. पहला रहस्य",
        'objective': "समानता को समझें जहां एक अज्ञात को ज्ञात मान द्वारा सीधे संतुलित किया जाता है।",
        'steps': [
          {'text': "संतुलित पैमाने को देखें। समीकरण x = 3 है। वजन देखने के लिए चमकते मिस्ट्री बॉक्स पर क्लिक करें।", 'hud': "वजन देखने के लिए चमकते बॉक्स पर क्लिक करें।" },
          {'text': "पैमाना संतुलित है। इसका मतलब है कि बायां पक्ष दाएं पक्ष के बराबर है। एक मिस्ट्री बॉक्स (x) का वजन 3 किलोग्राम के बराबर है। समाधान x = 3 है।", 'hud': "समीकरण हल हुआ: x = 3!" }
        ]
      },
      {
        'title': "2. अज्ञात को अलग करना",
        'objective': "दोनों पक्षों से समान मात्रा घटाकर अज्ञात चर को अलग करें।",
        'steps': [
          {'text': "पैमाना संतुलित है: x + 2 = 5। बाएं पलड़े से 1 किग्रा वजन को कचरे के डिब्बे में खींचें।", 'hud': "बाएं पलड़े से 1 किग्रा निकालें।" },
          {'text': "संतुलन बनाए रखें! अब बाएं पलड़े से दूसरे 1 किग्रा वजन को डिब्बे में खींचें।", 'hud': "बाएं पलड़े से दूसरा 1 किग्रा निकालें।" },
          {'text': "'x' का मान ज्ञात करने के लिए, हमने बाईं ओर से अतिरिक्त 2 किग्रा हटा दिया। संतुलन बनाए रखने के लिए, हमें दाईं ओर से भी 2 किग्रा हटाना पड़ा। अब हम देख सकते हैं कि x = 3।", 'hud': "अवधारणा खोजी गई: संतुलित घटाव।" }
        ]
      },
      {
        'title': "3. भार साझा करना",
        'objective': "विभाजन को दृष्टिगत रूप से दर्शाकर ax = b जैसे समीकरणों को हल करना सीखें।",
        'steps': [
          {'text': "संतुलित पैमाने को देखें। बाएं पलड़े में दो समान मिस्ट्री बॉक्स ('x') हैं। दाएं पलड़े में 1 किग्रा के छह वजन हैं। समीकरण 2x = 6 ऊपर प्रदर्शित है।", 'hud': "संतुलित पैमाने को देखें।" },
          {'text': "दाएं पलड़े से छह वजनों के समूह को खींचें और उन्हें दोनों पलड़ों के बीच 'वितरण क्षेत्र' पर छोड़ें।", 'hud': "6 किग्रा बंडल को वितरण क्षेत्र में खींचें।" },
          {'text': "इसका मान देखने के लिए मिस्ट्री बॉक्स में से किसी एक पर क्लिक करें।", 'hud': "वजन देखने के लिए बॉक्स पर क्लिक करें।" },
          {'text': "जब 2 बक्सों का वजन 6 किग्रा के बराबर होता है, तो हम 6 किग्रा को समान रूप से विभाजित करके एक बॉक्स का वजन ज्ञात कर सकते हैं। प्रत्येक बॉक्स का वजन 3 किग्रा होना चाहिए। समाधान x = 3 है।", 'hud': "समीकरण हल हुआ: 2x = 6 → x = 3." }
        ]
      },
      {
        'title': "4. दो-चरणीय संतुलन",
        'objective': "दो-चरणीय समीकरण को हल करने के लिए घटाव और विभाजन को मिलाएं।",
        'steps': [
          {'text': "संतुलित पैमाने को देखें। बाएं पलड़े में तीन मिस्ट्री बॉक्स ('x') और एक 1 किग्रा वजन है। दाएं पलड़े में 1 किग्रा के सात वजन हैं। समीकरण 3x + 1 = 7 प्रदर्शित है। आपका मिशन एक बॉक्स का वजन ज्ञात करना है।", 'hud': "संतुलित पैमाने को देखें।" },
          {'text': "पहले, बक्सों को अलग करें। बाएं पलड़े से अतिरिक्त 1 किग्रा वजन को 'कचरे के डिब्बे' में खींचें।", 'hud': "बाएं पलड़े से अतिरिक्त 1 किग्रा निकालें।" },
          {'text': "अब, एक बॉक्स का वजन ज्ञात करें। दाएं पलड़े से छह वजनों के समूह को 'वितरण क्षेत्र' में खींचें।", 'hud': "6 किग्रा बंडल को वितरण क्षेत्र में खींचें।" },
          {'text': "आपने दो-चरणीय समीकरण हल कर लिया! x = 2.", 'hud': "चुनौती पूर्ण: 3x + 1 = 7 → x = 2." }
        ]
      },
      {
        'title': "5. दोनों पक्षों को संतुलित करना",
        'objective': "पैमाने के दोनों किनारों पर चर वाले समीकरण को हल करें।",
        'steps': [
          {'text': "2x + 3 = x + 5 को हल करें। पहले बक्सों को एक तरफ करें। दाएं पलड़े से बॉक्स को डिब्बे में खींचें।", 'hud': "दाएं पलड़े से 'x' बॉक्स निकालें।" },
          {'text': "अब हमारे पास x + 3 = 5 है। बाएं पलड़े से 3 किग्रा बंडल को डिब्बे में खींचकर अंतिम बॉक्स को अलग करें।", 'hud': "बाएं पलड़े से 3 किग्रा बंडल निकालें।" },
          {'text': "शानदार! आपने चरण-दर-चरण एक जटिल समीकरण को सरल बनाया। x = 2.", 'hud': "अंतिम चुनौती पूर्ण: x = 2." }
        ]
      }
    ]
  }
};

// --- Main Screen ---

class FramingAndSolvingLinearEquationsScreen extends StatefulWidget {
  const FramingAndSolvingLinearEquationsScreen({super.key});

  @override
  State<FramingAndSolvingLinearEquationsScreen> createState() => _FramingAndSolvingLinearEquationsScreenState();
}

class _FramingAndSolvingLinearEquationsScreenState extends State<FramingAndSolvingLinearEquationsScreen>
    with SingleTickerProviderStateMixin {
  
  // State
  String lang = 'en';
  bool _isSidebarOpen = true;
  bool showShutter = true;
  int currentScenario = 0;
  int currentStep = 0;

  // Physics & Canvas State
  late Ticker _ticker;
  List<GameEntity> entities = [];
  List<DistPile> distPiles = [];
  List<Particle> particles = [];
  
  double beamAngle = 0.0;
  double targetBeamAngle = 0.0;
  double leftWeight = 0.0;
  double rightWeight = 0.0;
  double boxTrueWeight = 3.0;
  bool forceBalance = false;
  String currentEquation = "";
  
  double animationTime = 0.0;
  bool isAdvancing = false;

  // Camera
  double camX = 0;
  double camY = 0;
  double camScale = 1.0;

  // Drag State
  GameEntity? draggedEntity;
  GameEntity? pairedEntity;
  double dragOffsetX = 0;
  double dragOffsetY = 0;
  String? originalPan;
  String? hoverZone;
  Offset lastPanPos = Offset.zero;
  bool isPanning = false;
  double _startCamScale = 1.0;

  // Audio Players
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker(_tick)..start();
    _loadScenario(0);
  }

  @override
  void dispose() {
    _ticker.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playClick() => _clickPlayer.play(AssetSource(_clickUrl));
  void _playSuccess() => _successPlayer.play(AssetSource(_successUrl));
  void _playError() => _errorPlayer.play(AssetSource(_errorUrl));
  void _playShutter() => _shutterPlayer.play(AssetSource(_shutterUrl));

  void _enterLab() {
    _playShutter();
    setState(() {
      showShutter = false;
    });
  }

  void _resetApp() {
    _playClick();
    _loadScenario(0);
    setState(() {
      showShutter = true;
      _isSidebarOpen = true;
      lang = 'en'; 
    });
  }

  void _toggleLanguage() {
    _playClick();
    setState(() {
      if (lang == 'en') {
        lang = 'hi';
      } else {
        lang = 'en';
      }
    });
  }

  String _getInitialEquation(int scenIdx) {
    return ["x = 3", "x + 2 = 5", "2x = 6", "3x + 1 = 7", "2x + 3 = x + 5"][scenIdx];
  }

  void _tick(Duration elapsed) {
    setState(() {
      animationTime += 0.05;

      // Physics Interpolation
      beamAngle += (targetBeamAngle - beamAngle) * 0.1;
      _positionPanItems();

      // Entity Animations
      for (var ent in entities) {
        if (ent.isHidden) continue;

        if (ent.isDisposing) {
          ent.x += (ent.disposeTargetX - ent.x) * 0.15;
          ent.y += (ent.disposeTargetY - ent.y) * 0.15;
          ent.scale *= 0.85;
          if (ent.scale < 0.05) {
            ent.isHidden = true;
            ent.isDisposing = false;
            _createParticles(ent.disposeTargetX, ent.disposeTargetY, Colors.redAccent);
          }
        } else if (ent.isReturning) {
          ent.returnProgress += 0.1;
          if (ent.returnProgress >= 1) {
            ent.isReturning = false;
            ent.pan = ent.returnPan;
            ent.x = ent.targetX;
            ent.y = ent.targetY;
            _calculateWeights();
          } else {
            double t = ent.returnProgress;
            double easeT = 1 - pow(1 - t, 3).toDouble();
            ent.x = ent.returnStartX + (ent.targetX - ent.returnStartX) * easeT;
            ent.y = ent.returnStartY + (ent.targetY - ent.returnStartY) * easeT;
          }
        } else if (ent != draggedEntity &&
            (ent.pan == 'left' || ent.pan == 'right')) {
          ent.x += (ent.targetX - ent.x) * 0.4;
          ent.y += (ent.targetY - ent.y) * 0.4;
        }
      }

      // Particles
      for (int i = particles.length - 1; i >= 0; i--) {
        var p = particles[i];
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.5;
        p.life -= 0.03;
        if (p.life <= 0) particles.removeAt(i);
      }

      _evaluateScenarioState();
    });
  }

  void _createParticles(double x, double y, Color color) {
    final rand = Random();
    for (int i = 0; i < 20; i++) {
      particles.add(Particle(x, y, (rand.nextDouble() - 0.5) * 10,
          (rand.nextDouble() - 0.5) * 10 - 5, 1.0, color));
    }
  }

  void _loadScenario(int index) {
    currentScenario = index;
    currentStep = 0;
    entities.clear();
    distPiles.clear();
    isAdvancing = false;
    forceBalance = false;
    beamAngle = 0;
    targetBeamAngle = 0;
    
    List<double> weights = [3, 3, 3, 2, 2];
    boxTrueWeight = weights[index];

    if (index == 0) { // S1
      entities.add(GameEntity(id: 'bL1', type: 'box', pan: 'left', glow: true, onClick: () {
        _playSuccess();
        var b = entities.firstWhere((e) => e.id == 'bL1');
        b.isRevealed = true;
        b.glow = false;
        _createParticles(-150, 100, Colors.greenAccent);
        _advanceStep();
      }));
      entities.add(GameEntity(id: 'wR1', type: 'weight', pan: 'right', val: 1));
      entities.add(GameEntity(id: 'wR2', type: 'weight', pan: 'right', val: 1));
      entities.add(GameEntity(id: 'wR3', type: 'weight', pan: 'right', val: 1));
    } else if (index == 1) { // S2
      entities.add(GameEntity(id: 'bL1', type: 'box', pan: 'left'));
      entities.add(GameEntity(id: 'wL1', type: 'weight', pan: 'left', val: 1, isDraggable: true, glow: true));
      entities.add(GameEntity(id: 'wL2', type: 'weight', pan: 'left', val: 1, isDraggable: false));
      for (int i = 1; i <= 5; i++) {
        entities.add(GameEntity(id: 'wR$i', type: 'weight', pan: 'right', val: 1));
      }
    } else if (index == 2) { // S3
      entities.add(GameEntity(id: 'bL1', type: 'box', pan: 'left'));
      entities.add(GameEntity(id: 'bL2', type: 'box', pan: 'left'));
      for (int i = 1; i <= 6; i++) {
        entities.add(GameEntity(id: 'wR$i', type: 'weight', pan: 'right', val: 1));
      }
    } else if (index == 3) { // S4
      entities.add(GameEntity(id: 'bL1', type: 'box', pan: 'left'));
      entities.add(GameEntity(id: 'bL2', type: 'box', pan: 'left'));
      entities.add(GameEntity(id: 'bL3', type: 'box', pan: 'left'));
      entities.add(GameEntity(id: 'wL1', type: 'weight', pan: 'left', val: 1, isDraggable: false, glow: false));
      for (int i = 1; i <= 7; i++) {
        entities.add(GameEntity(id: 'wR$i', type: 'weight', pan: 'right', val: 1));
      }
    } else if (index == 4) { // S5
      entities.add(GameEntity(id: 'bL1', type: 'box', pan: 'left'));
      entities.add(GameEntity(id: 'bL2', type: 'box', pan: 'left'));
      entities.add(GameEntity(id: 'wbL3', type: 'weight_bundle', pan: 'left', val: 3, isDraggable: false));
      
      entities.add(GameEntity(id: 'bR1', type: 'box', pan: 'right', isDraggable: true, glow: true));
      entities.add(GameEntity(id: 'wbR5', type: 'weight_bundle', pan: 'right', val: 5, isDraggable: false));
    }

    currentEquation = _getInitialEquation(index);
    _calculateWeights();
  }

  void _calculateWeights() {
    leftWeight = 0;
    rightWeight = 0;

    for (var e in entities) {
      if (e.isHidden || e.isDisposing || e.pan == null) continue;
      double w = (e.type == 'box') ? boxTrueWeight : e.val;
      if (e.pan == 'left') leftWeight += w;
      if (e.pan == 'right') rightWeight += w;
    }

    double diff = rightWeight - leftWeight;
    targetBeamAngle = forceBalance ? 0 : max(-0.3, min(0.3, diff * 0.04));
  }

  void _positionPanItems() {
    double beamLength = 150;
    double pivotY = -50;
    double leftPinY = pivotY - sin(beamAngle) * beamLength;
    double rightPinY = pivotY + sin(beamAngle) * beamLength;

    double leftPanY = leftPinY + 140;
    double rightPanY = rightPinY + 140;

    List<GameEntity> leftItems = entities.where((e) => e.pan == 'left' && !e.isHidden && e != draggedEntity).toList();
    List<GameEntity> rightItems = entities.where((e) => e.pan == 'right' && !e.isHidden && e != draggedEntity).toList();

    void posItems(List<GameEntity> items, double panCenterX, double panY) {
      var boxes = items.where((e) => e.type == 'box').toList();
      var weights = items.where((e) => e.type != 'box').toList();
      
      double yOffset = panY - 20;

      for (int i = 0; i < boxes.length; i++) {
        var e = boxes[i];
        int row = 0;
        double colOffset = 0;
        if (boxes.length == 1) { row = 0; colOffset = 0; }
        else if (boxes.length == 2) { row = 0; colOffset = (i == 0) ? -22 : 22; }
        else if (boxes.length == 3) {
          if (i < 2) { row = 0; colOffset = (i == 0) ? -22 : 22; }
          else { row = 1; colOffset = 0; }
        } else {
          row = i ~/ 2;
          bool isSingle = (i == boxes.length - 1 && boxes.length % 2 != 0);
          colOffset = isSingle ? 0 : (i % 2 == 0 ? -22 : 22);
        }
        e.targetX = panCenterX + colOffset;
        e.targetY = yOffset - (row * 42);
        if (e.x == 0 && e.y == 0) { e.x = e.targetX; e.y = e.targetY; }
      }

      if (boxes.isNotEmpty) {
        yOffset -= (((boxes.length + 1) ~/ 2) - 1) * 42 + 42;
      }

      for (int i = 0; i < weights.length; i++) {
        var e = weights[i];
        int row = i ~/ 3;
        int col = i % 3;
        int itemsInRow = min(3, weights.length - row * 3);
        double colOffset = 0;
        if (itemsInRow == 1) colOffset = 0;
        else if (itemsInRow == 2) colOffset = (col == 0) ? -18 : 18;
        else if (itemsInRow == 3) colOffset = (col - 1) * 32.0;
        
        e.targetX = panCenterX + colOffset;
        e.targetY = yOffset - (row * 32);
        if (e.x == 0 && e.y == 0) { e.x = e.targetX; e.y = e.targetY; }
      }
    }

    posItems(leftItems, -150, leftPanY);
    posItems(rightItems, 150, rightPanY);
  }

  void _evaluateScenarioState() {
    if (isAdvancing) return;
    var scen = i18n[lang]['scenarios'][currentScenario];
    if (currentStep == scen['steps'].length - 1) return;

    if (currentScenario == 1) {
      if (currentStep == 0) {
        var wL1 = entities.where((e) => e.id == 'wL1').firstOrNull;
        if (wL1 != null && (wL1.isHidden || wL1.isDisposing)) {
          isAdvancing = true;
          currentEquation = "x + 1 = 4";
          Future.delayed(const Duration(milliseconds: 1000), _advanceStep);
        }
      } else if (currentStep == 1) {
        var wL2 = entities.where((e) => e.id == 'wL2').firstOrNull;
        if (wL2 != null && (wL2.isHidden || wL2.isDisposing)) {
          isAdvancing = true;
          currentEquation = "x = 3";
          Future.delayed(const Duration(milliseconds: 1000), _advanceStep);
        }
      }
    } else if (currentScenario == 2 && currentStep == 0) {
      isAdvancing = true;
      Future.delayed(const Duration(milliseconds: 4000), _advanceStep);
    } else if (currentScenario == 3 && currentStep == 0) {
      isAdvancing = true;
      Future.delayed(const Duration(milliseconds: 4000), _advanceStep);
    } else if (currentScenario == 3 && currentStep == 1) {
      var wL1 = entities.where((e) => e.id == 'wL1').firstOrNull;
      if (wL1 != null && (wL1.isHidden || wL1.isDisposing)) {
        isAdvancing = true;
        currentEquation = "3x = 6";
        entities.removeWhere((e) => e.pan == 'right' && e.type == 'weight' && !e.isDisposing);
        entities.add(GameEntity(id: 'wbR6', type: 'weight_bundle', pan: 'right', val: 6, isDraggable: true, glow: true));
        _calculateWeights();
        Future.delayed(const Duration(milliseconds: 1000), _advanceStep);
      }
    } else if (currentScenario == 4) {
      if (currentStep == 0) {
        var bR1 = entities.where((e) => e.id == 'bR1').firstOrNull;
        if (bR1 != null && (bR1.isHidden || bR1.isDisposing)) {
          isAdvancing = true;
          currentEquation = "x + 3 = 5";
          Future.delayed(const Duration(milliseconds: 1000), _advanceStep);
        }
      } else if (currentStep == 1) {
        var wbL3 = entities.where((e) => e.id == 'wbL3').firstOrNull;
        if (wbL3 != null && (wbL3.isHidden || wbL3.isDisposing)) {
          isAdvancing = true;
          currentEquation = "x = 2";
          Future.delayed(const Duration(milliseconds: 1000), _advanceStep);
        }
      }
    }
  }

  void _advanceStep() {
    var scen = i18n[lang]['scenarios'][currentScenario];
    if (currentStep < scen['steps'].length - 1) {
      _playSuccess();
      setState(() {
        currentStep++;
        isAdvancing = false;

        if (currentScenario == 1 && currentStep == 1) {
          var wL2 = entities.where((e) => e.id == 'wL2').firstOrNull;
          if (wL2 != null) { wL2.isDraggable = true; wL2.glow = true; }
        } else if (currentScenario == 2 && currentStep == 1) {
          entities.removeWhere((e) => e.pan == 'right' && e.type == 'weight');
          entities.add(GameEntity(id: 'wbR6', type: 'weight_bundle', pan: 'right', val: 6, isDraggable: true, glow: true));
          _calculateWeights();
        } else if (currentScenario == 3 && currentStep == 1) {
          var wL1 = entities.where((e) => e.id == 'wL1').firstOrNull;
          if (wL1 != null) { wL1.isDraggable = true; wL1.glow = true; }
        } else if (currentScenario == 4 && currentStep == 1) {
          var wbL3 = entities.where((e) => e.id == 'wbL3').firstOrNull;
          if (wbL3 != null) { wbL3.isDraggable = true; wbL3.glow = true; }
        }
      });
    }
  }

  // --- Interaction Methods ---

  Offset _screenToWorld(Offset screenPos, Size size) {
    return Offset(
      (screenPos.dx - size.width / 2 - camX) / camScale,
      (screenPos.dy - size.height / 2 - camY) / camScale,
    );
  }

  void _onTapUp(TapUpDetails details, BoxConstraints constraints) {
    Size size = Size(constraints.maxWidth, constraints.maxHeight);
    Offset worldPos = _screenToWorld(details.localPosition, size);

    for (int i = entities.length - 1; i >= 0; i--) {
      var ent = entities[i];
      if (ent.isHidden) continue;

      bool hit = false;
      if (ent.type == 'box') {
        hit = (worldPos.dx >= ent.x - 35 && worldPos.dx <= ent.x + 35 && worldPos.dy >= ent.y - 35 && worldPos.dy <= ent.y + 35);
      } else if (ent.type == 'weight') {
        hit = (worldPos.dx >= ent.x - 25 && worldPos.dx <= ent.x + 25 && worldPos.dy >= ent.y - 25 && worldPos.dy <= ent.y + 25);
      } else if (ent.type == 'weight_bundle') {
        hit = (worldPos.dx >= ent.x - 35 && worldPos.dx <= ent.x + 35 && worldPos.dy >= ent.y - 30 && worldPos.dy <= ent.y + 30);
      }

      if (hit && ent.onClick != null) {
        setState(() {
          ent.onClick!();
        });
        return;
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details, BoxConstraints constraints) {
    Size size = Size(constraints.maxWidth, constraints.maxHeight);
    
    if (details.pointerCount == 1) {
      Offset worldPos = _screenToWorld(details.localFocalPoint, size);

      for (int i = entities.length - 1; i >= 0; i--) {
        var ent = entities[i];
        if (ent.isHidden) continue;

        bool hit = false;
        if (ent.type == 'box') {
          hit = (worldPos.dx >= ent.x - 35 && worldPos.dx <= ent.x + 35 && worldPos.dy >= ent.y - 35 && worldPos.dy <= ent.y + 35);
        } else if (ent.type == 'weight') {
          hit = (worldPos.dx >= ent.x - 25 && worldPos.dx <= ent.x + 25 && worldPos.dy >= ent.y - 25 && worldPos.dy <= ent.y + 25);
        } else if (ent.type == 'weight_bundle') {
          hit = (worldPos.dx >= ent.x - 35 && worldPos.dx <= ent.x + 35 && worldPos.dy >= ent.y - 30 && worldPos.dy <= ent.y + 30);
        }

        if (hit && ent.isDraggable) {
          _playClick();
          setState(() {
            originalPan = ent.pan;
            ent.pan = null;
            
            GameEntity? partner;
            if (currentScenario == 1) {
              if (ent.id == 'wL1') partner = entities.where((e) => e.id == 'wR1').firstOrNull;
              else if (ent.id == 'wL2') partner = entities.where((e) => e.id == 'wR2').firstOrNull;
            } else if (currentScenario == 3) {
              if (ent.id == 'wL1') partner = entities.where((e) => e.id == 'wR1').firstOrNull;
            } else if (currentScenario == 4) {
              if (ent.id == 'bR1') partner = entities.where((e) => e.id == 'bL2').firstOrNull;
              else if (ent.id == 'wbL3') partner = entities.where((e) => e.id == 'wbR5').firstOrNull;
            }

            draggedEntity = ent;
            pairedEntity = partner;
            if (partner != null) partner.glow = true;

            dragOffsetX = ent.x - worldPos.dx;
            dragOffsetY = ent.y - worldPos.dy;
            _calculateWeights();
          });
          return;
        }
      }
    }

    setState(() {
      isPanning = true;
      lastPanPos = details.localFocalPoint;
      _startCamScale = camScale;
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details, BoxConstraints constraints) {
    if (draggedEntity != null && details.pointerCount == 1) {
      Size size = Size(constraints.maxWidth, constraints.maxHeight);
      Offset worldPos = _screenToWorld(details.localFocalPoint, size);

      setState(() {
        draggedEntity!.x = worldPos.dx + dragOffsetX;
        draggedEntity!.y = worldPos.dy + dragOffsetY;

        hoverZone = null;
        bool canDropBin = (currentScenario > 0 && currentScenario != 2);
        if (canDropBin && worldPos.dx >= -360 && worldPos.dx <= -130 && worldPos.dy >= 140 && worldPos.dy <= 320) hoverZone = 'bin';
        else if (worldPos.dx >= -180 && worldPos.dx <= 180 && worldPos.dy >= 180 && worldPos.dy <= 350 && (currentScenario == 2 || currentScenario == 3)) hoverZone = 'dist';
        
        if (pairedEntity != null && hoverZone == 'bin') {
          pairedEntity!.y -= 2; // Visual tug
        }
      });
    } else if (isPanning) {
      setState(() {
        camX += details.localFocalPoint.dx - lastPanPos.dx;
        camY += details.localFocalPoint.dy - lastPanPos.dy;
        lastPanPos = details.localFocalPoint;
        camScale = max(0.1, min(_startCamScale * details.scale, 2.0));
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (draggedEntity != null) {
      var ent = draggedEntity!;
      String? droppedOnPan;

      bool canDropBin = (currentScenario > 0 && currentScenario != 2);
      if (canDropBin && ent.x >= -360 && ent.x <= -130 && ent.y >= 140 && ent.y <= 320) droppedOnPan = 'bin';
      else if (ent.x >= -180 && ent.x <= 180 && ent.y >= 180 && ent.y <= 350 && (currentScenario == 2 || currentScenario == 3)) droppedOnPan = 'dist';

      setState(() {
        bool isValidDrop = false;

        if (droppedOnPan == 'bin' && pairedEntity != null) {
          isValidDrop = true;
          _playClick();
          
          var counterpart = pairedEntity!;
          ent.isDisposing = true;
          ent.disposeTargetX = -240;
          ent.disposeTargetY = 220;
          ent.pan = null;

          if (currentScenario == 4 && currentStep == 1 && ent.id == 'wbL3') {
            counterpart.val = 2; // Right had 5, reduce by 3
            counterpart.glow = false;
            entities.add(GameEntity(id: 'ghost1', type: 'ghost_weight', x: counterpart.x, y: counterpart.y, val: 3, isDisposing: true, disposeTargetX: -240, disposeTargetY: 220));
          } else {
            counterpart.isDisposing = true;
            counterpart.disposeTargetX = -240;
            counterpart.disposeTargetY = 220;
            counterpart.pan = null;
          }
          
          _calculateWeights();
          Future.delayed(const Duration(milliseconds: 800), _evaluateScenarioState);
        } else if (droppedOnPan == 'dist' && ent.type == 'weight_bundle') {
          if ((currentScenario == 2 && currentStep == 1) || (currentScenario == 3 && currentStep == 2)) {
            isValidDrop = true;
            _playClick();
            ent.isHidden = true;
            ent.pan = null;

            var boxes = entities.where((e) => e.type == 'box' && e.pan == 'left' && !e.isHidden).toList();
            int nBoxes = boxes.length;
            double valPerPile = ent.val / nBoxes;

            distPiles.clear();
            double spacing = 120;
            double startX = 0 - ((nBoxes - 1) * spacing) / 2;

            for (int i = 0; i < nBoxes; i++) {
              distPiles.add(DistPile(x: startX + i * spacing, y: 260, val: valPerPile, boxId: boxes[i].id));
            }

            currentEquation = "x = ${ent.val.toInt()} ÷ $nBoxes";
            forceBalance = true;
            _calculateWeights();

            Future.delayed(const Duration(milliseconds: 1500), () {
              if (currentScenario == 2) {
                for (var b in boxes) {
                  b.glow = true;
                  b.onClick = () {
                    if (b.isRevealed) return;
                    _playSuccess();
                    setState(() {
                      b.isRevealed = true;
                      b.glow = false;
                      _createParticles(b.x, b.y, Colors.greenAccent);
                      if (currentStep == 2 && !isAdvancing) {
                        currentEquation = "x = ${valPerPile.toInt()}";
                        isAdvancing = true;
                        Future.delayed(const Duration(milliseconds: 1500), _advanceStep);
                      }
                    });
                  };
                }
                _advanceStep();
              } else if (currentScenario == 3) {
                setState(() {
                  currentEquation = "x = ${valPerPile.toInt()}";
                  _playSuccess();
                  for (var bx in boxes) {
                    bx.isRevealed = true;
                    _createParticles(bx.x, bx.y, Colors.greenAccent);
                  }
                  distPiles.clear();
                  _advanceStep();
                });
              }
            });
          }
        }

        if (!isValidDrop) {
          _playError();
          if (pairedEntity != null) pairedEntity!.glow = false;
          ent.isReturning = true;
          ent.returnStartX = ent.x;
          ent.returnStartY = ent.y;
          ent.targetX = ent.x - dragOffsetX; 
          ent.targetY = ent.y - dragOffsetY;
          ent.returnPan = originalPan;
          ent.returnProgress = 0;
          _calculateWeights();
        }
        
        draggedEntity = null;
        pairedEntity = null;
        hoverZone = null;
      });
    }
    setState(() {
      isPanning = false;
    });
  }

  void _zoom(double factor) {
    _playClick();
    setState(() {
      camScale = max(0.1, min(camScale * factor, 2.0));
    });
  }

  void _fitToScreen() {
    _playClick();
    setState(() {
      camX = 0;
      camY = -60; // Offset down slightly to avoid top equation
      camScale = 1.0;
    });
  }

  // --- Build UI ---

  @override
  Widget build(BuildContext context) {
    var tr = i18n[lang];
    var scen = tr['scenarios'][currentScenario];
    bool isLastStep = currentStep == scen['steps'].length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: LayoutBuilder(builder: (context, constraints) {
          double sidebarWidth = constraints.maxWidth * 0.30;
          if (sidebarWidth < 300) sidebarWidth = 300;

          return Stack(
            children: [
              // Main Canvas Area
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _isSidebarOpen ? sidebarWidth : 0,
                top: 0,
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      LayoutBuilder(
                        builder: (context, canvasConstraints) {
                          return GestureDetector(
                            onTapUp: (d) => _onTapUp(d, canvasConstraints),
                            onScaleStart: (d) => _onScaleStart(d, canvasConstraints),
                            onScaleUpdate: (d) => _onScaleUpdate(d, canvasConstraints),
                            onScaleEnd: _onScaleEnd,
                            child: CustomPaint(
                              painter: LabPainter(
                                entities: entities,
                                distPiles: distPiles,
                                particles: particles,
                                beamAngle: beamAngle,
                                camX: camX,
                                camY: camY,
                                camScale: camScale,
                                currentScenario: currentScenario,
                                hoverZone: hoverZone,
                                animationTime: animationTime,
                                boxTrueWeight: boxTrueWeight,
                                tr: tr,
                              ),
                              size: Size.infinite,
                            ),
                          );
                        }
                      ),

                      // Fixed Equation Display
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.indigoAccent.withOpacity(0.5), width: 2),
                              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))],
                            ),
                            child: Text(
                              currentEquation,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigoAccent,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Mini Toolbar (Zoom) moved down
                      Positioned(
                        top: 100,
                        right: 20,
                        child: Column(
                          children: [
                            _ToolBtn(Icons.zoom_in, () => _zoom(1.2)),
                            const SizedBox(height: 8),
                            _ToolBtn(Icons.zoom_out, () => _zoom(1 / 1.2)),
                            const SizedBox(height: 8),
                            _ToolBtn(Icons.fit_screen, _fitToScreen),
                          ],
                        ),
                      ),

                      // Floating Mission Card (Shown when sidebar is collapsed)
                      if (!_isSidebarOpen)
                        Positioned(
                          bottom: 20,
                          left: 80, // Offset to not overlap the menu button if it were at bottom, but it's top left
                          right: 20,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.7),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.indigoAccent.withOpacity(0.3)),
                                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      scen['steps'][currentStep]['text'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => _playClick(),
                                          icon: const Icon(Icons.calculate, size: 16),
                                          label: Text(tr['btnConvert']),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton.icon(
                                          onPressed: () => _playClick(),
                                          icon: const Icon(Icons.verified, size: 16),
                                          label: Text(tr['btnValidate']),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                      // Bottom HUD Message Overlay (Shown when sidebar is open)
                      if (_isSidebarOpen)
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                ),
                                child: isLastStep
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.check_circle, color: Colors.green),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  scen['steps'][currentStep]['hud'],
                                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            scen['steps'][currentStep]['text'],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 14, color: Colors.white70),
                                          )
                                        ],
                                      )
                                    : Text(
                                        scen['steps'][currentStep]['hud'],
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                      ),
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),

              // LEFT SIDEBAR
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _isSidebarOpen ? 0 : -sidebarWidth,
                top: 0,
                bottom: 0,
                width: sidebarWidth,
                child: Material(
                  elevation: 16,
                  color: const Color(0xFF1E293B).withOpacity(0.95),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Header (Title, Subtitle, Lang, Reset)
                        Container(
                          padding: const EdgeInsets.only(left: 64, right: 16, top: 20, bottom: 16),
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2)))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.balance, color: Colors.amber),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tr['title'],
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          tr['subtitle'],
                                          style: const TextStyle(fontSize: 10, color: Colors.white54),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _toggleLanguage,
                                      icon: const Icon(Icons.translate, size: 16),
                                      label: Text(lang.toUpperCase(), style: const TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigoAccent.withOpacity(0.2),
                                        foregroundColor: Colors.indigoAccent,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _resetApp,
                                      icon: const Icon(Icons.refresh, size: 16),
                                      label: const Text("Reset", style: TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent.withOpacity(0.2),
                                        foregroundColor: Colors.redAccent,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 2. Scenario Selector
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tr['selectScenario'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF1E293B),
                                    value: currentScenario,
                                    items: List.generate(
                                      tr['scenarios'].length,
                                      (idx) => DropdownMenuItem(
                                        value: idx,
                                        child: Text(
                                          tr['scenarios'][idx]['title'],
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      if (val != null) {
                                        _playClick();
                                        _loadScenario(val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 3. Content / Steps
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr['missionObj'],
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigoAccent),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                scen['objective'],
                                style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white),
                              ),
                              const SizedBox(height: 24),
                              ...List.generate(
                                scen['steps'].length,
                                (idx) {
                                  if (idx > currentStep) return const SizedBox.shrink();
                                  bool isCurrent = idx == currentStep;
                                  bool isLastStepOfScenario = idx == scen['steps'].length - 1;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                    ),
                                    child: Opacity(
                                      opacity: (isCurrent || isLastStepOfScenario) ? 1.0 : 0.5,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            (isCurrent && !isLastStepOfScenario) ? Icons.adjust : Icons.check_circle,
                                            color: (isCurrent && !isLastStepOfScenario) ? Colors.indigoAccent : Colors.green,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              scen['steps'][idx]['text'],
                                              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // 4. Footer
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 24),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2)))),
                          child: Text(
                            tr['footer'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Menu Button (Fixed Top Left)
              Positioned(
                top: 16,
                left: 16, // Fixed position, won't slide with sidebar
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

              // Full Screen Shutter Overlay
              AnimatedPositioned(
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeInOutCubicEmphasized,
                top: showShutter ? 0 : -constraints.maxHeight,
                left: 0,
                right: 0,
                height: constraints.maxHeight,
                child: Container(
                  color: const Color(0xFF020617),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.balance, size: 80, color: Colors.amber),
                        const SizedBox(height: 24),
                        Text(
                          tr['title'],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr['subtitle'],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 48),
                        ElevatedButton(
                          onPressed: _enterLab,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 10,
                          ),
                          child: Text(
                            tr['enterLab'],
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ToolBtn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

// --- Canvas CustomPainter ---

class LabPainter extends CustomPainter {
  final List<GameEntity> entities;
  final List<DistPile> distPiles;
  final List<Particle> particles;
  final double beamAngle;
  final double camX;
  final double camY;
  final double camScale;
  final int currentScenario;
  final String? hoverZone;
  final double animationTime;
  final double boxTrueWeight;
  final Map<String, dynamic> tr;

  LabPainter({
    required this.entities,
    required this.distPiles,
    required this.particles,
    required this.beamAngle,
    required this.camX,
    required this.camY,
    required this.camScale,
    required this.currentScenario,
    required this.hoverZone,
    required this.animationTime,
    required this.boxTrueWeight,
    required this.tr,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + camX, size.height / 2 + camY);
    canvas.scale(camScale, camScale);

    _drawBackgroundElements(canvas);
    _drawScale(canvas);
    _drawEntities(canvas);
    _drawParticles(canvas);

    canvas.restore();
  }

  void _drawBackgroundElements(Canvas canvas) {
    if (currentScenario > 0 && currentScenario != 2) {
      // Bin
      canvas.save();
      canvas.translate(-240, 220);

      if (hoverZone == 'bin') {
        var glowPaint = Paint()
          ..color = Colors.redAccent.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
        canvas.drawOval(const Rect.fromLTRB(-45, -30, 45, 40), glowPaint);
      }

      var paint = Paint()..color = const Color(0xFF0F172A);
      canvas.drawOval(const Rect.fromLTRB(-35, -32, 35, -8), paint);

      var gradPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF334155), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(const Rect.fromLTRB(-35, -20, 35, 30));
      Path body = Path()
        ..moveTo(-35, -20)
        ..lineTo(35, -20)
        ..lineTo(25, 30)
        ..lineTo(-25, 30)
        ..close();
      canvas.drawPath(body, gradPaint);

      paint.color = const Color(0xFF1E293B);
      Path frontLip = Path()..addArc(const Rect.fromLTRB(-35, -32, 35, -8), 0, pi);
      canvas.drawPath(frontLip, paint);

      paint.color = Colors.black;
      canvas.drawOval(const Rect.fromLTRB(-28, -28, 28, -12), paint);

      TextPainter tp = TextPainter(
        text: TextSpan(
          text: tr['msgBin'],
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, 45 - tp.height / 2));

      canvas.restore();
    }

    if (currentScenario == 2 || currentScenario == 3) {
      // Dist Zone
      canvas.save();
      canvas.translate(0, 260);
      if (hoverZone == 'dist') {
        var glowPaint = Paint()
          ..color = Colors.blueAccent.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
        canvas.drawRRect(RRect.fromLTRBR(-160, -55, 160, 55, const Radius.circular(10)), glowPaint);
      }

      _drawDashedRect(canvas, const Rect.fromLTRB(-160, -55, 160, 55), 10, 10);
      
      var fillPaint = Paint()..color = Colors.lightBlueAccent.withOpacity(0.05);
      canvas.drawRRect(RRect.fromLTRBR(-160, -55, 160, 55, const Radius.circular(10)), fillPaint);
      
      TextPainter tp = TextPainter(
        text: TextSpan(
          text: tr['msgDist'],
          style: const TextStyle(
            color: Colors.lightBlueAccent,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, 75 - tp.height / 2));

      canvas.restore();
    }
  }

  void _drawDashedRect(Canvas canvas, Rect rect, double dash, double space) {
    Path path = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)));
    for (PathMetric measurePath in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        Path extractPath = measurePath.extractPath(distance, distance + dash);
        canvas.drawPath(extractPath, Paint()..color = Colors.lightBlueAccent.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 2);
        distance += dash + space;
      }
    }
  }

  void _drawScale(Canvas canvas) {
    canvas.save();

    // Base
    var paint = Paint()..color = const Color(0xFF334155);
    canvas.drawRRect(RRect.fromLTRBR(-70, 190, 70, 200, const Radius.circular(4)), paint);
    paint.color = const Color(0xFF1E293B);
    canvas.drawRRect(RRect.fromLTRBR(-90, 200, 90, 215, const Radius.circular(6)), paint);

    // Pillar
    var pillarPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E293B), Color(0xFF475569), Color(0xFF0F172A)]
      ).createShader(const Rect.fromLTRB(-10, 0, 10, 0));
    canvas.drawRect(const Rect.fromLTRB(-10, -50, 10, 190), pillarPaint);

    // Dial Arch
    paint.color = const Color(0xFF1E293B);
    Path dial = Path()..addArc(const Rect.fromLTRB(-40, -90, 40, -10), pi, pi);
    canvas.drawPath(dial, paint);

    paint
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (double a = -pi; a <= 0.01; a += pi / 6) {
      canvas.drawLine(
        Offset(cos(a) * 35, -50 + sin(a) * 35),
        Offset(cos(a) * 40, -50 + sin(a) * 40),
        paint,
      );
    }
    paint.style = PaintingStyle.fill;

    // Beam
    canvas.translate(0, -50);
    canvas.rotate(beamAngle);

    bool isBalanced = beamAngle.abs() < 0.01; 
    Color beamColor = isBalanced ? const Color(0xFF10B981) : const Color(0xFF64748B);

    if (isBalanced && currentScenario >= 0) {
      var glowPaint = Paint()
        ..color = const Color(0xFF10B981)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRRect(RRect.fromLTRBR(-160, -6, 160, 6, const Radius.circular(6)), glowPaint);
    }

    paint.color = beamColor;
    canvas.drawRRect(RRect.fromLTRBR(-160, -6, 160, 6, const Radius.circular(6)), paint);

    // Needle
    paint.color = Colors.redAccent;
    Path needle = Path()..moveTo(-4, 0)..lineTo(4, 0)..lineTo(0, -35)..close();
    canvas.drawPath(needle, paint);

    // Pans
    _drawPan(canvas, -150);
    _drawPan(canvas, 150);

    // Pivot Hub
    paint.color = Colors.amber.shade700;
    canvas.drawCircle(Offset.zero, 12, paint);
    paint.color = Colors.amber.shade400;
    canvas.drawCircle(Offset.zero, 6, paint);

    canvas.restore();
  }

  void _drawPan(Canvas canvas, double xOffset) {
    canvas.save();
    canvas.translate(xOffset, 0);
    canvas.rotate(-beamAngle); 

    var strokePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(Offset.zero, const Offset(-55, 140), strokePaint);
    canvas.drawLine(Offset.zero, const Offset(55, 140), strokePaint);
    canvas.drawLine(Offset.zero, const Offset(0, 140), strokePaint);

    var fillPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawOval(const Rect.fromLTRB(-60, 125, 60, 155), fillPaint);
    fillPaint.color = const Color(0xFF1E293B);
    canvas.drawOval(const Rect.fromLTRB(-55, 130, 55, 150), fillPaint);

    canvas.restore();
  }

  void _drawEntities(Canvas canvas) {
    var resting = entities.where((e) => !e.isHidden).toList();
    resting.sort((a, b) => a.y.compareTo(b.y));

    for (var ent in resting) {
      canvas.save();
      canvas.translate(ent.x, ent.y);
      if (ent.scale != 1.0) canvas.scale(ent.scale, ent.scale);

      if (ent.glow) {
        double p = 0.8 + sin(animationTime * 5) * 0.2;
        var glowPaint = Paint()
          ..color = Colors.amberAccent
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 * p);
        canvas.drawCircle(Offset.zero, 25, glowPaint);
      }

      if (ent.type == 'box') {
        if (ent.isRevealed) {
          var gradPaint = Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFF34D399), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(const Rect.fromLTRB(-20, -20, 20, 20));
          canvas.drawRRect(RRect.fromLTRBR(-20, -20, 20, 20, const Radius.circular(6)), gradPaint);
          _drawText(canvas, "${boxTrueWeight.toInt()}kg", Colors.white, 14, dy: -2);
        } else {
          var paint = Paint()..color = const Color(0xFFB45309);
          canvas.drawRect(const Rect.fromLTRB(-20, -20, 20, 20), paint);
          paint.color = const Color(0xFF78350F);
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = 3;
          canvas.drawRect(const Rect.fromLTRB(-20, -20, 20, 20), paint);
          canvas.drawLine(const Offset(-20, -20), const Offset(20, 20), paint);
          canvas.drawLine(const Offset(20, -20), const Offset(-20, 20), paint);
          paint.style = PaintingStyle.fill;
          _drawText(canvas, "x", Colors.white, 24, dy: 0);
        }
      } else if (ent.type == 'weight' || ent.type == 'ghost_weight') {
        if (ent.type == 'ghost_weight') canvas.saveLayer(null, Paint()..color = Colors.white.withOpacity(0.5));
        
        var ringPaint = Paint()
          ..color = const Color(0xFF94A3B8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawCircle(const Offset(0, -18), 5, ringPaint);

        var gradPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF475569), Color(0xFF94A3B8), Color(0xFF334155)],
          ).createShader(const Rect.fromLTRB(-16, -12, 16, 16));
        Path wBody = Path()
          ..moveTo(-10, -12)
          ..lineTo(10, -12)
          ..lineTo(16, 16)
          ..lineTo(-16, 16)
          ..close();
        canvas.drawPath(wBody, gradPaint);

        var highlight = Paint()..color = Colors.white10;
        Path hPath = Path()..moveTo(-10, -12)..lineTo(0, -12)..lineTo(0, 16)..lineTo(-16, 16)..close();
        canvas.drawPath(hPath, highlight);

        String valText = "${ent.val.toInt()}kg";
        _drawText(canvas, valText, Colors.white, 12, dy: 4);
        
        if (ent.type == 'ghost_weight') canvas.restore();
      } else if (ent.type == 'weight_bundle') {
        var ringPaint = Paint()
          ..color = Colors.blueAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
        canvas.drawCircle(const Offset(0, -22), 6, ringPaint);

        var gradPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF60A5FA), Color(0xFF1D4ED8)],
          ).createShader(const Rect.fromLTRB(-26, -15, 26, 20));
        Path wBody = Path()
          ..moveTo(-18, -15)
          ..lineTo(18, -15)
          ..lineTo(26, 20)
          ..lineTo(-26, 20)
          ..close();
        canvas.drawPath(wBody, gradPaint);

        var highlight = Paint()..color = Colors.white10;
        Path hPath = Path()..moveTo(-18, -15)..lineTo(0, -15)..lineTo(0, 20)..lineTo(-26, 20)..close();
        canvas.drawPath(hPath, highlight);

        String valText = "${ent.val.toInt()}kg";
        _drawText(canvas, valText, Colors.white, 16, dy: 5);
      }

      canvas.restore();
    }

    // Draw Distribution Piles
    for (var pile in distPiles) {
      canvas.save();
      canvas.translate(pile.x, pile.y);
      
      double h = 30;
      for (int i = 0; i < pile.val; i++) {
        canvas.save();
        canvas.translate(0, -i * h + (pile.val - 1) * h / 2);
        
        var ringPaint = Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 2;
        canvas.drawCircle(const Offset(0, -14), 5, ringPaint);
        
        var gradPaint = Paint()
          ..shader = const LinearGradient(colors: [Color(0xFF475569), Color(0xFF94A3B8), Color(0xFF334155)]).createShader(const Rect.fromLTRB(-16, -12, 16, 12));
        Path wBody = Path()..moveTo(-12, -12)..lineTo(12, -12)..lineTo(16, 12)..lineTo(-16, 12)..close();
        canvas.drawPath(wBody, gradPaint);
        
        _drawText(canvas, "1kg", Colors.white, 12, dy: 0);
        canvas.restore();
      }
      canvas.restore();

      var box = entities.where((e) => e.id == pile.boxId && !e.isHidden).firstOrNull;
      if (box != null) {
        canvas.save();
        var arrowPaint = Paint()
          ..color = Colors.lightBlueAccent.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        
        double beamLength = 150;
        double pivotY = -50;
        double leftPinX = -cos(beamAngle) * beamLength;
        
        double absX = leftPinX + (box.targetX - (-150));
        double absY = box.y; 

        double startX = pile.x;
        double startY = pile.y - 45;
        double endX = absX;
        double endY = absY + 25;     
        double cpX = (startX + endX) / 2;
        double cpY = startY - 50;    

        Path curve = Path()..moveTo(startX, startY)..quadraticBezierTo(cpX, cpY, endX, endY);
        
        for (PathMetric measurePath in curve.computeMetrics()) {
          double distance = 0.0;
          while (distance < measurePath.length) {
            Path extractPath = measurePath.extractPath(distance, distance + 8);
            canvas.drawPath(extractPath, arrowPaint);
            distance += 8 + 8;
          }
        }
        
        double arrowAngle = atan2(endY - cpY, endX - cpX);
        canvas.translate(endX, endY);
        canvas.rotate(arrowAngle);
        arrowPaint.style = PaintingStyle.fill;
        Path arrowhead = Path()..moveTo(0,0)..lineTo(-12,-6)..lineTo(-12,6)..close();
        canvas.drawPath(arrowhead, arrowPaint);
        canvas.restore();
      }
    }
  }

  void _drawText(Canvas canvas, String text, Color color, double size, {double dy = 0}) {
    TextPainter tpShadow = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.black45, fontSize: size, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpShadow.paint(canvas, Offset(-tpShadow.width / 2, -tpShadow.height / 2 + dy + 1));

    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2 + dy));
  }

  void _drawParticles(Canvas canvas) {
    for (var p in particles) {
      var paint = Paint()..color = p.color.withOpacity(p.life.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x, p.y), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}