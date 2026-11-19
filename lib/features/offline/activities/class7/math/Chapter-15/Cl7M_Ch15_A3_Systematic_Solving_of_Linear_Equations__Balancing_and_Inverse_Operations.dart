// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SystematicSolvingLinearEquationsApp());
}

class SystematicSolvingLinearEquationsApp extends StatelessWidget {
  const SystematicSolvingLinearEquationsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Equation Balancer',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const SystematicSolvingLinearEquationsScreen(),
    );
  }
}

// --- Data Models ---

class GameEntity {
  String id;
  String type; // 'box', 'unit', 'divide_tool', 'ghost_weight'
  double val;
  String? pan; // 'left', 'right', 'shelf', 'bin', null
  double x;
  double y;
  double targetX;
  double targetY;
  double panTargetX;
  double panTargetY;
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
    this.panTargetX = 0,
    this.panTargetY = 0,
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

class Particle {
  double x, y, vx, vy, life;
  Color color;
  Particle(this.x, this.y, this.vx, this.vy, this.life, this.color);
}

// --- Translation Data ---

const Map<String, dynamic> i18n = {
  'en': {
    'title': "The Equation Balancer",
    'subtitle': "Class 7 • FINDING THE UNKNOWN",
    'enterLab': "Enter Virtual Lab",
    'selectScenario': "Select Scenario",
    'missionObj': "Mission Steps",
    'hudDefault': "Select a scenario to begin.",
    'msgDiscard': "DISCARD ZONE",
    'footer': "© ZeroScienceLab - Fall in love with math and Science",
    'btnConvert': "Convert Units",
    'btnValidate': "Validate Model",
    'btnCheck': "Check Answer",
    'msgNotIsolated': "Not quite! The Mystery Box isn't by itself yet.",
    'msgNotBalanced': "Make sure the scale is balanced!",
    'msgDivBoxFirst': "Divide the Mystery Boxes first!",
    'scenarios': [
      {
        'title': "1. Isolating the Unknown",
        'objective': "Find the value of the single mystery box by isolating it on one side of the balance scale.",
        'steps': [
          {'text': "Observe the balanced scale. The equation x + 3 = 7 is displayed.\n\nTo find the value of the Mystery Box, you must get it by itself. DRAG 3 Unit Weights from the left pan into the red 'Discard Zone' at the bottom of the screen.", 'hud': "Drag 3 Unit Weights from the left pan to the Discard Zone." },
          {'text': "The scale is unbalanced! To restore the balance, you must perform the same action on the other side. DRAG 3 Unit Weights from the right pan into the 'Discard Zone'.", 'hud': "Drag 3 Unit Weights from the right pan to the Discard Zone." },
          {'text': "The scale is now balanced, showing 1 Mystery Box on the left and 4 Unit Weights on the right. CLICK the Mystery Box to reveal its contents.", 'hud': "Click the Mystery Box to reveal its contents." },
          {'text': "Success! The Mystery Box contains 4 Unit Weights, visually confirming that x = 4.", 'hud': "Equation Solved: x = 4!" }
        ]
      },
      {
        'title': "2. Finding the Unit Value",
        'objective': "Find the value of a single mystery box when there are several of them on the scale.",
        'steps': [
          {'text': "Observe the balanced scale. The equation 3x = 12 is displayed.\n\nWe need to find the value of just one Mystery Box. To do this, we must divide each side into 3 equal groups. DRAG the 'Divide Tool' (÷) onto the left pan.", 'hud': "Drag the Divide Tool to the left pan." },
          {'text': "To keep the scale balanced, you must do the same to the right side. DRAG the 'Divide Tool' onto the right pan.", 'hud': "Drag the Divide Tool to the right pan." },
          {'text': "By dividing both sides into 3 equal groups, we can clearly see that 1 Mystery Box equals 4 Unit Weights.", 'hud': "Equation Solved: x = 4!" }
        ]
      },
      {
        'title': "3. The Two-Step Solution",
        'objective': "Combine the skills from the first two challenges to solve a two-step equation.",
        'steps': [
          {'text': "Observe the balanced scale. The equation 2x + 4 = 10 is displayed.\n\nFirst, isolate the Mystery Boxes. Remove the 4 Unit Weights from the left pan, and then immediately balance the scale by doing the same on the right pan.", 'hud': "Remove 4 Unit Weights from both pans." },
          {'text': "Now, find the value of a single Mystery Box. Use the 'Divide Tool' on both sides of the scale to find the answer.", 'hud': "Use the Divide Tool on both pans." },
          {'text': "Success! 1 Mystery Box is balanced with 3 Unit Weights. x = 3.", 'hud': "Pattern Discovered: Two-Step Solving!" }
        ]
      },
      {
        'title': "4. Unsolved Challenge 1",
        'objective': "You are on your own! Find the value of the Mystery Box by applying the principles of balancing.",
        'steps': [
          {'text': "The scale represents the equation 3x + 2 = 11. Your mission is to find the value of 'x'. Use the 'Discard Zone' and the 'Divide Tool' to solve the puzzle.\n\nOnce the scale shows the value of a single Mystery Box, CLICK the 'Check Answer' button.", 'hud': "Solve the equation and click Check Answer." },
          {'text': "Well Done! You solved the equation independently: x = 3.", 'hud': "Challenge Complete: x = 3!" }
        ]
      },
      {
        'title': "5. Variables on Both Sides",
        'objective': "This is the ultimate challenge! Isolate the Mystery Boxes on one side and the Unit Weights on the other to find the solution.",
        'steps': [
          {'text': "The scale represents the equation 4x + 1 = 2x + 7. Your mission is to find the value of 'x'. Remember, you can remove any item from both sides to keep the balance.\n\nFind the value of a single Mystery Box and CLICK the 'Check Answer' button.", 'hud': "Isolate one box and click Check Answer." },
          {'text': "Incredible! You successfully navigated a complex equation with variables on both sides. x = 3.", 'hud': "Ultimate Challenge Complete: x = 3!" }
        ]
      }
    ]
  },
  'hi': {
    'title': "समीकरण संतुलनकर्ता",
    'subtitle': "कक्षा 7 • अज्ञात का पता लगाना",
    'enterLab': "वर्चुअल लैब में प्रवेश करें",
    'selectScenario': "परिदृश्य चुनें",
    'missionObj': "मिशन के चरण",
    'hudDefault': "शुरू करने के लिए एक परिदृश्य चुनें।",
    'msgDiscard': "कचरे का डिब्बा",
    'footer': "© ZeroScienceLab - Fall in love with math and Science",
    'btnConvert': "इकाइयां बदलें",
    'btnValidate': "मॉडल सत्यापित करें",
    'btnCheck': "उत्तर जांचें",
    'msgNotIsolated': "बिल्कुल नहीं! मिस्ट्री बॉक्स अभी तक अकेला नहीं है।",
    'msgNotBalanced': "सुनिश्चित करें कि पैमाना संतुलित है!",
    'msgDivBoxFirst': "पहले मिस्ट्री बॉक्स को विभाजित करें!",
    'scenarios': [
      {
        'title': "1. अज्ञात को अलग करना",
        'objective': "संतुलन पैमाने के एक तरफ अलग करके एकल रहस्य बॉक्स का मूल्य ज्ञात करें।",
        'steps': [
          {'text': "संतुलित पैमाने का निरीक्षण करें। समीकरण x + 3 = 7 प्रदर्शित है।\n\nमिस्ट्री बॉक्स का मूल्य खोजने के लिए, आपको इसे अकेला करना होगा। बाएं पलड़े से 3 यूनिट वेट को लाल 'कचरे के डिब्बे' में खींचें।", 'hud': "बाएं पलड़े से 3 यूनिट वेट को डिब्बे में खींचें।" },
          {'text': "पैमाना असंतुलित है! संतुलन बहाल करने के लिए, आपको दूसरी तरफ भी वही क्रिया करनी होगी। दाएं पलड़े से 3 यूनिट वेट को 'डिब्बे' में खींचें।", 'hud': "दाएं पलड़े से 3 यूनिट वेट को डिब्बे में खींचें।" },
          {'text': "पैमाना अब संतुलित है, बाईं ओर 1 मिस्ट्री बॉक्स और दाईं ओर 4 यूनिट वेट दिखा रहा है। सामग्री प्रकट करने के लिए मिस्ट्री बॉक्स पर क्लिक करें।", 'hud': "सामग्री प्रकट करने के लिए मिस्ट्री बॉक्स पर क्लिक करें।" },
          {'text': "सफलता! मिस्ट्री बॉक्स में 4 यूनिट वेट हैं, जो पुष्टि करता है कि x = 4।", 'hud': "समीकरण हल हुआ: x = 4!" }
        ]
      },
      {
        'title': "2. इकाई मान खोजना",
        'objective': "जब पैमाने पर कई रहस्य बक्से हों तो एक का मूल्य ज्ञात करें।",
        'steps': [
          {'text': "संतुलित पैमाने का निरीक्षण करें। समीकरण 3x = 12 प्रदर्शित है।\n\nहमें सिर्फ एक मिस्ट्री बॉक्स का मूल्य खोजना है। ऐसा करने के लिए, हमें प्रत्येक पक्ष को 3 समान समूहों में विभाजित करना होगा। 'डिवाइड टूल' (÷) को बाएं पैन पर खींचें।", 'hud': "डिवाइड टूल को बाएं पैन पर खींचें।" },
          {'text': "पैमाने को संतुलित रखने के लिए, आपको दाईं ओर भी ऐसा ही करना होगा। 'डिवाइड टूल' को दाएं पैन पर खींचें।", 'hud': "डिवाइड टूल को दाएं पैन पर खींचें।" },
          {'text': "दोनों पक्षों को 3 समान समूहों में विभाजित करके, हम स्पष्ट रूप से देख सकते हैं कि 1 मिस्ट्री बॉक्स 4 यूनिट वेट के बराबर है।", 'hud': "समीकरण हल हुआ: x = 4!" }
        ]
      },
      {
        'title': "3. दो-चरणीय समाधान",
        'objective': "दो-चरणीय समीकरण को हल करने के लिए पहले दो चुनौतियों से कौशल को मिलाएं।",
        'steps': [
          {'text': "संतुलित पैमाने का निरीक्षण करें। समीकरण 2x + 4 = 10 प्रदर्शित है।\n\nपहले, मिस्ट्री बॉक्स को अलग करें। बाएं पैन से 4 यूनिट वेट हटाने के लिए सही क्रिया करें, और फिर दाईं ओर वही क्रिया करके पैमाने को संतुलित करें।", 'hud': "दोनों पैन से 4 यूनिट वेट हटाएं।" },
          {'text': "अब, एक मिस्ट्री बॉक्स का मूल्य ज्ञात करें। उत्तर खोजने के लिए पैमाने के दोनों किनारों पर 'डिवाइड टूल' का उपयोग करें।", 'hud': "दोनों पैन पर डिवाइड टूल का उपयोग करें।" },
          {'text': "सफलता! 1 मिस्ट्री बॉक्स 3 यूनिट वेट के साथ संतुलित है। x = 3।", 'hud': "पैटर्न खोजा गया: दो-चरणीय समाधान!" }
        ]
      },
      {
        'title': "4. अनसुलझी चुनौती 1",
        'objective': "संतुलन के सिद्धांतों को लागू करके रहस्य बॉक्स का मूल्य ज्ञात करें।",
        'steps': [
          {'text': "पैमाना समीकरण 3x + 2 = 11 का प्रतिनिधित्व करने के लिए स्थापित किया गया है। आपका मिशन 'x' का मूल्य खोजना है। पहेली को हल करने के लिए 'कचरे के डिब्बे' और 'डिवाइड टूल' का उपयोग करें।\n\nएक बार जब पैमाना एक मिस्ट्री बॉक्स का मूल्य दिखाता है, तो 'उत्तर जांचें' बटन पर क्लिक करें।", 'hud': "उपकरणों का उपयोग करके समीकरण को हल करें और उत्तर जांचें।" },
          {'text': "बहुत बढ़िया! आपने समीकरण को स्वतंत्र रूप से हल किया: x = 3।", 'hud': "चुनौती पूर्ण: x = 3!" }
        ]
      },
      {
        'title': "5. दोनों पक्षों पर चर",
        'objective': "समाधान खोजने के लिए एक तरफ रहस्य बक्से और दूसरी तरफ इकाई वजन को अलग करें।",
        'steps': [
          {'text': "पैमाना समीकरण 4x + 1 = 2x + 7 के लिए स्थापित किया गया है। याद रखें, आप संतुलन बनाए रखने के लिए दोनों पक्षों से किसी भी प्रकार की वस्तु हटा सकते हैं।\n\nएक मिस्ट्री बॉक्स का मूल्य ज्ञात करें और अपने समाधान की पुष्टि करने के लिए 'उत्तर जांचें' बटन पर क्लिक करें।", 'hud': "एक बॉक्स को अलग करें और उत्तर जांचें।" },
          {'text': "अविश्वसनीय! आपने दोनों पक्षों पर चर के साथ एक जटिल समीकरण को सफलतापूर्वक हल किया। x = 3।", 'hud': "अंतिम चुनौती पूर्ण: x = 3!" }
        ]
      }
    ]
  }
};

// --- Main Screen ---

class SystematicSolvingLinearEquationsScreen extends StatefulWidget {
  const SystematicSolvingLinearEquationsScreen({super.key});

  @override
  State<SystematicSolvingLinearEquationsScreen> createState() => _SystematicSolvingLinearEquationsScreenState();
}

class _SystematicSolvingLinearEquationsScreenState extends State<SystematicSolvingLinearEquationsScreen>
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
  List<Particle> particles = [];
  
  double beamAngle = 0.0;
  double targetBeamAngle = 0.0;
  double leftWeight = 0.0;
  double rightWeight = 0.0;
  double boxTrueWeight = 0.0;
  String currentEquation = "";
  
  bool forceBalance = false;
  bool dividedLeft = false;
  bool dividedRight = false;
  int groupsCount = 1;
  bool isZoomed = false;
  
  double animationTime = 0.0;
  bool isAdvancing = false;
  String? tempHintMsg;
  Timer? hintTimer;

  // Camera
  double camX = 0;
  double camY = 0;
  double camScale = 1.0;

  // Drag State
  GameEntity? draggedEntity;
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
    hintTimer?.cancel();
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
      tempHintMsg = null;
    });
  }

  String _getInitialEquation(int scenIdx) {
    return ["x + 3 = 7", "3x = 12", "2x + 4 = 10", "3x + 2 = 11", "4x + 1 = 2x + 7"][scenIdx];
  }

  void _showHint(String msg) {
    setState(() {
      tempHintMsg = msg;
    });
    hintTimer?.cancel();
    hintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          tempHintMsg = null;
        });
      }
    });
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
          ent.x += (ent.panTargetX - ent.x) * 0.4;
          ent.y += (ent.panTargetY - ent.y) * 0.4;
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
    isAdvancing = false;
    forceBalance = false;
    dividedLeft = false;
    dividedRight = false;
    isZoomed = false;
    groupsCount = 1;
    beamAngle = 0;
    targetBeamAngle = 0;
    tempHintMsg = null;
    
    List<double> weights = [4, 4, 3, 3, 3];
    boxTrueWeight = weights[index];

    if (index == 0) { // S1: x + 3 = 7
      entities.add(GameEntity(id: 'bL1', type: 'box', pan: 'left', isRevealed: false));
      for (int i = 1; i <= 3; i++) {
        entities.add(GameEntity(id: 'wL$i', type: 'unit', pan: 'left', isDraggable: true, glow: true));
      }
      for (int i = 1; i <= 7; i++) {
        entities.add(GameEntity(id: 'wR$i', type: 'unit', pan: 'right', isDraggable: false));
      }
    } else if (index == 1) { // S2: 3x = 12
      for (int i = 1; i <= 3; i++) entities.add(GameEntity(id: 'bL$i', type: 'box', pan: 'left'));
      for (int i = 1; i <= 12; i++) entities.add(GameEntity(id: 'wR$i', type: 'unit', pan: 'right'));
      entities.add(GameEntity(id: 'div', type: 'divide_tool', x: 0, y: -180, isDraggable: true, glow: true));
    } else if (index == 2) { // S3: 2x + 4 = 10
      entities.add(GameEntity(id: 'bL1', type: 'box', pan: 'left'));
      entities.add(GameEntity(id: 'bL2', type: 'box', pan: 'left'));
      for (int i = 1; i <= 4; i++) entities.add(GameEntity(id: 'wL$i', type: 'unit', pan: 'left', isDraggable: true, glow: true));
      for (int i = 1; i <= 10; i++) entities.add(GameEntity(id: 'wR$i', type: 'unit', pan: 'right', isDraggable: true, glow: true));
      entities.add(GameEntity(id: 'div', type: 'divide_tool', x: 0, y: -180, isDraggable: false, isHidden: true));
    } else if (index == 3) { // S4: 3x + 2 = 11
      entities.add(GameEntity(id: 'bL1', type: 'box', pan: 'left', isDraggable: true));
      entities.add(GameEntity(id: 'bL2', type: 'box', pan: 'left', isDraggable: true));
      entities.add(GameEntity(id: 'bL3', type: 'box', pan: 'left', isDraggable: true));
      for (int i = 1; i <= 2; i++) entities.add(GameEntity(id: 'wL$i', type: 'unit', pan: 'left', isDraggable: true));
      for (int i = 1; i <= 11; i++) entities.add(GameEntity(id: 'wR$i', type: 'unit', pan: 'right', isDraggable: true));
      entities.add(GameEntity(id: 'div', type: 'divide_tool', x: 0, y: -180, isDraggable: true));
    } else if (index == 4) { // S5: 4x + 1 = 2x + 7
      for (int i = 1; i <= 4; i++) entities.add(GameEntity(id: 'bL$i', type: 'box', pan: 'left', isDraggable: true));
      entities.add(GameEntity(id: 'wL1', type: 'unit', pan: 'left', isDraggable: true));
      for (int i = 1; i <= 2; i++) entities.add(GameEntity(id: 'bR$i', type: 'box', pan: 'right', isDraggable: true));
      for (int i = 1; i <= 7; i++) entities.add(GameEntity(id: 'wR$i', type: 'unit', pan: 'right', isDraggable: true));
      entities.add(GameEntity(id: 'div', type: 'divide_tool', x: 0, y: -180, isDraggable: true));
    }

    currentEquation = _getInitialEquation(index);
    _calculateWeights();
  }

  void _calculateWeights() {
    if (isZoomed) return;
    leftWeight = 0;
    rightWeight = 0;

    for (var e in entities) {
      if (e.isHidden || e.isDisposing || (e.pan == null && e != draggedEntity)) continue;
      String? p = e.pan;
      if (e == draggedEntity) p = originalPan;
      
      double w = (e.type == 'box') ? boxTrueWeight : 1;
      if (p == 'left') leftWeight += w;
      if (p == 'right') rightWeight += w;
    }

    double diff = rightWeight - leftWeight;
    targetBeamAngle = forceBalance ? 0 : max(-0.2, min(0.2, diff * 0.05));

    if (_isBalanced() && draggedEntity == null && entities.every((e) => !e.isReturning)) {
      _updateEquationDisplay();
    }
  }

  bool _isBalanced() {
    return (leftWeight - rightWeight).abs() < 0.1;
  }

  void _updateEquationDisplay() {
    List<String> lStr = [];
    List<String> rStr = [];

    if (isZoomed) {
      bool isLeftBoxes = entities.where((e) => e.pan == 'left' && e.type == 'box' && !e.isHidden).isNotEmpty;
      if (isLeftBoxes) {
        lStr.add("x");
        int ur = entities.where((e) => e.pan == 'right' && e.type == 'unit' && !e.isHidden && !e.isDisposing).length;
        rStr.add("${ur ~/ groupsCount}");
      } else {
        rStr.add("x");
        int ul = entities.where((e) => e.pan == 'left' && e.type == 'unit' && !e.isHidden && !e.isDisposing).length;
        lStr.add("${ul ~/ groupsCount}");
      }
    } else {
      int lb = entities.where((e) => e.pan == 'left' && e.type == 'box' && !e.isHidden && !e.isDisposing).length;
      int lu = entities.where((e) => e.pan == 'left' && e.type == 'unit' && !e.isHidden && !e.isDisposing).length;
      int rb = entities.where((e) => e.pan == 'right' && e.type == 'box' && !e.isHidden && !e.isDisposing).length;
      int ru = entities.where((e) => e.pan == 'right' && e.type == 'unit' && !e.isHidden && !e.isDisposing).length;

      if (lb > 0) lStr.add(lb == 1 ? "x" : "${lb}x");
      if (lu > 0) lStr.add("$lu");
      if (rb > 0) rStr.add(rb == 1 ? "x" : "${rb}x");
      if (ru > 0) rStr.add("$ru");
    }

    String left = lStr.isNotEmpty ? lStr.join(" + ") : "0";
    String right = rStr.isNotEmpty ? rStr.join(" + ") : "0";
    currentEquation = "$left = $right";
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

    if (isZoomed) {
      bool lBox = leftItems.where((u) => u.type == 'box').isNotEmpty;
      if (lBox) {
        var leftBoxes = leftItems.where((e) => e.type == 'box').toList();
        for (int i = 0; i < leftBoxes.length; i++) {
          leftBoxes[i].panTargetX = -60; leftBoxes[i].panTargetY = 50;
        }
        var unitsOnThisSide = rightItems.where((u) => u.type == 'unit').toList();
        int unitsPerGroup = unitsOnThisSide.length ~/ groupsCount;
        for (int i = 0; i < unitsOnThisSide.length; i++) {
          if (i < unitsPerGroup) {
            unitsOnThisSide[i].panTargetX = 60; unitsOnThisSide[i].panTargetY = 80 - i * 30.0;
          }
        }
      } else {
        var rightBoxes = rightItems.where((e) => e.type == 'box').toList();
        for (int i = 0; i < rightBoxes.length; i++) {
          rightBoxes[i].panTargetX = 60; rightBoxes[i].panTargetY = 50;
        }
        var unitsOnThisSide = leftItems.where((u) => u.type == 'unit').toList();
        int unitsPerGroup = unitsOnThisSide.length ~/ groupsCount;
        for (int i = 0; i < unitsOnThisSide.length; i++) {
          if (i < unitsPerGroup) {
            unitsOnThisSide[i].panTargetX = -60; unitsOnThisSide[i].panTargetY = 80 - i * 30.0;
          }
        }
      }
      return;
    }

    void posItems(List<GameEntity> items, double panCenterX, double panY, bool isLeft) {
      var boxes = items.where((e) => e.type == 'box').toList();
      var units = items.where((e) => e.type == 'unit').toList();
      
      double yOffset = panY - 20;

      if ((isLeft && dividedLeft && boxes.isNotEmpty) || (!isLeft && dividedRight && boxes.isNotEmpty)) {
        for (int i = 0; i < boxes.length; i++) {
          boxes[i].panTargetX = panCenterX + (i - (boxes.length - 1) / 2) * 50;
          boxes[i].panTargetY = yOffset;
          if (boxes[i].x == 0 && boxes[i].y == 0) { boxes[i].x = boxes[i].panTargetX; boxes[i].y = boxes[i].panTargetY; }
        }
        yOffset -= 40;
      } else {
        for (int i = 0; i < boxes.length; i++) {
          int row = i ~/ 2;
          double colOffset = (i == boxes.length - 1 && boxes.length % 2 != 0) ? 0 : (i % 2 == 0 ? -22 : 22);
          boxes[i].panTargetX = panCenterX + colOffset;
          boxes[i].panTargetY = yOffset - (row * 42);
          if (boxes[i].x == 0 && boxes[i].y == 0) { boxes[i].x = boxes[i].panTargetX; boxes[i].y = boxes[i].panTargetY; }
        }
        if (boxes.isNotEmpty) yOffset -= (((boxes.length + 1) ~/ 2) - 1) * 42 + 42;
      }

      if ((isLeft && dividedLeft && units.isNotEmpty) || (!isLeft && dividedRight && units.isNotEmpty)) {
        int unitsPerGroup = units.length ~/ groupsCount;
        for (int i = 0; i < units.length; i++) {
          int groupIdx = i ~/ unitsPerGroup;
          int inGroupIdx = i % unitsPerGroup;
          units[i].panTargetX = panCenterX + (groupIdx - (groupsCount - 1) / 2) * 50;
          units[i].panTargetY = yOffset - inGroupIdx * 30;
          if (units[i].x == 0 && units[i].y == 0) { units[i].x = units[i].panTargetX; units[i].y = units[i].panTargetY; }
        }
      } else {
        for (int i = 0; i < units.length; i++) {
          int row = i ~/ 3;
          int col = i % 3;
          int itemsInThisRow = min(3, units.length - row * 3);
          double colOffset = itemsInThisRow == 1 ? 0 : (itemsInThisRow == 2 ? (col == 0 ? -18 : 18) : (col - 1) * 28.0);
          units[i].panTargetX = panCenterX + colOffset;
          units[i].panTargetY = yOffset - (row * 30);
          if (units[i].x == 0 && units[i].y == 0) { units[i].x = units[i].panTargetX; units[i].y = units[i].panTargetY; }
        }
      }
    }

    posItems(leftItems, -150, leftPanY, true);
    posItems(rightItems, 150, rightPanY, false);
  }

  void _evaluateScenarioState() {
    if (isAdvancing) return;
    var scen = i18n[lang]['scenarios'][currentScenario];
    if (currentStep == scen['steps'].length - 1) return;

    if (currentScenario == 0) {
      if (currentStep == 0) {
        int ul = entities.where((e) => e.pan == 'left' && e.type == 'unit' && !e.isHidden && !e.isDisposing).length;
        if (ul == 0) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep); }
      } else if (currentStep == 1) {
        int ur = entities.where((e) => e.pan == 'right' && e.type == 'unit' && !e.isHidden && !e.isDisposing).length;
        if (ur == 4 && _isBalanced()) { isAdvancing = true; _updateEquationDisplay(); Future.delayed(const Duration(milliseconds: 1000), _advanceStep); }
      }
    } else if (currentScenario == 1) {
      if (currentStep == 0) {
        if (dividedLeft) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep); }
      } else if (currentStep == 1) {
        if (dividedRight) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 2000), _advanceStep); }
      }
    } else if (currentScenario == 2) {
      if (currentStep == 0) {
        int ul = entities.where((e) => e.pan == 'left' && e.type == 'unit' && !e.isHidden && !e.isDisposing).length;
        int ur = entities.where((e) => e.pan == 'right' && e.type == 'unit' && !e.isHidden && !e.isDisposing).length;
        if (ul == 0 && ur == 6 && _isBalanced()) {
          isAdvancing = true;
          var divTool = entities.where((e) => e.type == 'divide_tool').firstOrNull;
          if (divTool != null) { divTool.isHidden = false; divTool.isDraggable = true; divTool.glow = true; }
          Future.delayed(const Duration(milliseconds: 1000), _advanceStep);
        }
      } else if (currentStep == 1) {
        if (isZoomed) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 2000), _advanceStep); }
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

        if (currentScenario == 0) {
          if (currentStep == 1) {
            int count = 0;
            for (var e in entities) {
              if (e.pan == 'right' && e.type == 'unit' && !e.isHidden && count < 3) {
                e.isDraggable = true; e.glow = true; count++;
              }
            }
          } else if (currentStep == 2) {
            var box = entities.where((e) => e.type == 'box').firstOrNull;
            if (box != null) {
              box.glow = true;
              box.onClick = () {
                _playSuccess();
                setState(() {
                  box.isRevealed = true; box.glow = false;
                  _createParticles(box.x, box.y, const Color(0xFF10B981));
                  isAdvancing = true;
                });
                Future.delayed(const Duration(milliseconds: 1000), _advanceStep);
              };
            }
            for (var e in entities) {
              if (e.pan == 'right' && e.type == 'unit') { e.isDraggable = false; e.glow = false; }
            }
          }
        } else if (currentScenario == 1) {
          if (currentStep == 1) {
            var divTool = entities.where((e) => e.type == 'divide_tool').firstOrNull;
            if (divTool != null) divTool.isDraggable = true;
          }
        } else if (currentScenario == 2) {
          if (currentStep == 1) {
            for (var e in entities.where((e) => e.type == 'unit')) e.isDraggable = false;
          } else if (currentStep == 2) {
            var divTool = entities.where((e) => e.type == 'divide_tool').firstOrNull;
            if (divTool != null) divTool.isDraggable = false;
          }
        }
      });
    }
  }

  void _checkAnswer() {
    var tr = i18n[lang];
    if (!_isBalanced()) {
      _playError(); _showHint(tr['msgNotBalanced']); return;
    }

    int bl = entities.where((e) => e.pan == 'left' && e.type == 'box' && !e.isHidden).length;
    int ul = entities.where((e) => e.pan == 'left' && e.type == 'unit' && !e.isHidden).length;
    int br = entities.where((e) => e.pan == 'right' && e.type == 'box' && !e.isHidden).length;
    int ur = entities.where((e) => e.pan == 'right' && e.type == 'unit' && !e.isHidden).length;

    if (isZoomed) {
      if ((bl > 0 && ul == 0 && br == 0 && ur > 0) || (br > 0 && ur == 0 && bl == 0 && ul > 0)) {
        _playSuccess(); isAdvancing = true; _advanceStep();
      } else {
        _playError(); _showHint(tr['msgNotIsolated']);
      }
    } else {
      if ((bl > 1 && ul == 0 && br == 0 && ur > 0) || (br > 1 && ur == 0 && bl == 0 && ul > 0)) {
        _playError(); _showHint(tr['msgDivBoxFirst']);
      } else if ((bl == 1 && ul == 0 && br == 0 && ur > 0) || (br == 1 && ur == 0 && bl == 0 && ul > 0)) {
        _playSuccess(); isAdvancing = true; _advanceStep();
      } else {
        _playError(); _showHint(tr['msgNotIsolated']);
      }
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
      if (ent.isHidden || (!ent.isDraggable && ent.onClick == null)) continue;

      bool hit = false;
      if (ent.type == 'box') {
        hit = (worldPos.dx >= ent.x - 30 && worldPos.dx <= ent.x + 30 && worldPos.dy >= ent.y - 30 && worldPos.dy <= ent.y + 30);
      } else if (ent.type == 'unit') {
        hit = (worldPos.dx >= ent.x - 20 && worldPos.dx <= ent.x + 20 && worldPos.dy >= ent.y - 20 && worldPos.dy <= ent.y + 20);
      } else if (ent.type == 'divide_tool') {
        hit = (sqrt(pow(ent.x - worldPos.dx, 2) + pow(ent.y - worldPos.dy, 2)) < 30);
      }

      if (hit && ent.onClick != null) {
        _playClick();
        setState(() { ent.onClick!(); });
        return;
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details, BoxConstraints constraints) {
    if (isZoomed) return;
    Size size = Size(constraints.maxWidth, constraints.maxHeight);
    
    if (details.pointerCount == 1) {
      Offset worldPos = _screenToWorld(details.localFocalPoint, size);

      for (int i = entities.length - 1; i >= 0; i--) {
        var ent = entities[i];
        if (ent.isHidden || !ent.isDraggable) continue;

        bool hit = false;
        if (ent.type == 'box') {
          hit = (worldPos.dx >= ent.x - 30 && worldPos.dx <= ent.x + 30 && worldPos.dy >= ent.y - 30 && worldPos.dy <= ent.y + 30);
        } else if (ent.type == 'unit') {
          hit = (worldPos.dx >= ent.x - 20 && worldPos.dx <= ent.x + 20 && worldPos.dy >= ent.y - 20 && worldPos.dy <= ent.y + 20);
        } else if (ent.type == 'divide_tool') {
          hit = (sqrt(pow(ent.x - worldPos.dx, 2) + pow(ent.y - worldPos.dy, 2)) < 30);
        }

        if (hit && ent.isDraggable) {
          _playClick();
          setState(() {
            originalPan = ent.pan;
            if (ent.type != 'divide_tool') ent.pan = null;
            
            draggedEntity = ent;
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
        if (draggedEntity!.type == 'divide_tool') {
          if (worldPos.dx < 0) hoverZone = 'left_pan';
          else hoverZone = 'right_pan';
        } else {
          if (worldPos.dx >= -200 && worldPos.dx <= 200 && worldPos.dy >= 200 && worldPos.dy <= 320) hoverZone = 'bin';
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
    var tr = i18n[lang];
    if (draggedEntity != null) {
      var ent = draggedEntity!;
      double wX = ent.x; double wY = ent.y;
      
      bool droppedOnBin = (wX >= -200 && wX <= 200 && wY >= 200 && wY <= 320);
      bool droppedOnLeft = (wX < 0 && wY < 100);
      bool droppedOnRight = (wX > 0 && wY < 100);

      setState(() {
        if (ent.type == 'divide_tool') {
          bool validDrop = false;
          int bl = entities.where((e) => e.pan == 'left' && e.type == 'box' && !e.isHidden && !e.isDisposing).length;
          int ul = entities.where((e) => e.pan == 'left' && e.type == 'unit' && !e.isHidden && !e.isDisposing).length;
          int br = entities.where((e) => e.pan == 'right' && e.type == 'box' && !e.isHidden && !e.isDisposing).length;
          int ur = entities.where((e) => e.pan == 'right' && e.type == 'unit' && !e.isHidden && !e.isDisposing).length;

          if (droppedOnLeft) {
            if (bl > 1 && ul == 0 && !dividedLeft) { groupsCount = bl; dividedLeft = true; validDrop = true; }
            else if (ul > 0 && bl == 0 && groupsCount > 1 && ul % groupsCount == 0 && !dividedLeft) { dividedLeft = true; validDrop = true; }
            else if (br > 1 && !dividedRight) { _showHint(tr['msgDivBoxFirst']); }
          } else if (droppedOnRight) {
            if (br > 1 && ur == 0 && !dividedRight) { groupsCount = br; dividedRight = true; validDrop = true; }
            else if (ur > 0 && br == 0 && groupsCount > 1 && ur % groupsCount == 0 && !dividedRight) { dividedRight = true; validDrop = true; }
            else if (bl > 1 && !dividedLeft) { _showHint(tr['msgDivBoxFirst']); }
          }

          if (validDrop) {
            _playClick();
            _createParticles(wX, wY, Colors.lightBlueAccent);
            ent.x = ent.homeX ?? 0; ent.y = ent.homeY ?? -180;
            
            if (dividedLeft && dividedRight) {
              Future.delayed(const Duration(milliseconds: 1000), () {
                setState(() {
                  isZoomed = true;
                  _playSuccess();
                  _updateEquationDisplay();
                  _fitToScreen();
                  _evaluateScenarioState();
                });
              });
            } else {
              _evaluateScenarioState();
            }
          } else {
            _playError();
            ent.x = ent.homeX ?? 0; ent.y = ent.homeY ?? -180;
          }
        } else {
          if (droppedOnBin) {
            _playClick();
            ent.isDisposing = true;
            ent.disposeTargetX = 0;
            ent.disposeTargetY = 260;
            ent.pan = null;
            _calculateWeights();
            Future.delayed(const Duration(milliseconds: 800), _evaluateScenarioState);
          } else {
            _playError();
            ent.isReturning = true;
            ent.returnStartX = ent.x;
            ent.returnStartY = ent.y;
            ent.targetX = ent.x - dragOffsetX; // Appx start
            ent.targetY = ent.y - dragOffsetY;
            ent.returnPan = originalPan;
            ent.returnProgress = 0;
            _calculateWeights();
          }
        }
        
        draggedEntity = null;
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
    setState(() {
      camX = 0;
      camY = isZoomed ? 0 : -60; // Offset down slightly to avoid top equation
      camScale = isZoomed ? 1.4 : 1.0;
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
                                particles: particles,
                                beamAngle: beamAngle,
                                camX: camX,
                                camY: camY,
                                camScale: camScale,
                                currentScenario: currentScenario,
                                hoverZone: hoverZone,
                                animationTime: animationTime,
                                boxTrueWeight: boxTrueWeight,
                                isZoomed: isZoomed,
                                dividedLeft: dividedLeft,
                                dividedRight: dividedRight,
                                groupsCount: groupsCount,
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
                          left: 80, 
                          right: 20,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.8,
                                maxHeight: constraints.maxHeight * 0.4,
                              ),
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.indigoAccent.withOpacity(0.3)),
                                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
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
                                            const SizedBox(height: 6),
                                            Text(
                                              scen['steps'][currentStep]['text'].replaceAll('**', ''),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 14, color: Colors.white70),
                                            )
                                          ],
                                        )
                                      : Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              tempHintMsg ?? scen['steps'][currentStep]['hud'],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: tempHintMsg != null ? Colors.redAccent : Colors.white, 
                                                fontSize: 14, 
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            if ((currentScenario == 3 || currentScenario == 4) && currentStep < scen['steps'].length - 1)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10.0),
                                                child: ElevatedButton.icon(
                                                  onPressed: _checkAnswer,
                                                  icon: const Icon(Icons.check_circle, size: 16),
                                                  label: Text(tr['btnCheck']),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green, 
                                                    foregroundColor: Colors.white,
                                                    minimumSize: const Size(0, 36)
                                                  ),
                                                ),
                                              )
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                      // Check Answer action button at bottom when open
                      if (_isSidebarOpen && (currentScenario == 3 || currentScenario == 4) && currentStep < scen['steps'].length - 1)
                        Positioned(
                          bottom: 100,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ElevatedButton.icon(
                              onPressed: _checkAnswer,
                              icon: const Icon(Icons.check_circle),
                              label: Text(tr['btnCheck']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigoAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 8,
                                shadowColor: Colors.indigoAccent.withOpacity(0.5),
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
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.8,
                                maxHeight: constraints.maxHeight * 0.35,
                              ),
                              child: SingleChildScrollView(
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
                                              scen['steps'][currentStep]['text'].replaceAll('**', ''),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 14, color: Colors.white70),
                                            )
                                          ],
                                        )
                                      : Text(
                                          tempHintMsg ?? scen['steps'][currentStep]['hud'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: tempHintMsg != null ? Colors.redAccent : Colors.white,
                                          ),
                                        ),
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
                        // Header
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
                        // Scenario Selector
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
                        // Content / Steps
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
                                              scen['steps'][idx]['text'].replaceAll('**', ''),
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
                        // Footer
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
  final List<Particle> particles;
  final double beamAngle;
  final double camX;
  final double camY;
  final double camScale;
  final int currentScenario;
  final String? hoverZone;
  final double animationTime;
  final double boxTrueWeight;
  final bool isZoomed;
  final bool dividedLeft;
  final bool dividedRight;
  final int groupsCount;
  final Map<String, dynamic> tr;

  LabPainter({
    required this.entities,
    required this.particles,
    required this.beamAngle,
    required this.camX,
    required this.camY,
    required this.camScale,
    required this.currentScenario,
    required this.hoverZone,
    required this.animationTime,
    required this.boxTrueWeight,
    required this.isZoomed,
    required this.dividedLeft,
    required this.dividedRight,
    required this.groupsCount,
    required this.tr,
  });

  static final Map<String, TextPainter> _tpCache = {};

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + camX, size.height / 2 + camY);
    canvas.scale(camScale, camScale);

    if (!isZoomed) {
      _drawBackgroundElements(canvas);
      _drawScale(canvas);
    }
    
    _drawEntities(canvas);
    _drawParticles(canvas);

    canvas.restore();
  }

  void _drawBackgroundElements(Canvas canvas) {
    // Bin
    canvas.save();
    canvas.translate(0, 260);

    if (hoverZone == 'bin') {
      var glowPaint = Paint()
        ..color = Colors.redAccent.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawOval(const Rect.fromLTRB(-45, -30, 45, 40), glowPaint);
    }

    var paint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawOval(const Rect.fromLTRB(-45, -20, 45, 0), paint);

    var gradPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF334155), Color(0xFF0F172A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTRB(-45, -20, 45, 40));
    Path body = Path()
      ..moveTo(-45, -10)
      ..lineTo(45, -10)
      ..lineTo(35, 30)
      ..lineTo(-35, 30)
      ..close();
    canvas.drawPath(body, gradPaint);

    paint.color = const Color(0xFF1E293B);
    Path frontLip = Path()..addArc(const Rect.fromLTRB(-45, -20, 45, 0), 0, pi);
    canvas.drawPath(frontLip, paint);

    paint.color = const Color(0xFF020617);
    canvas.drawOval(const Rect.fromLTRB(-38, -16, 38, -4), paint);

    _drawText(canvas, tr['msgDiscard'], const Color(0xFFCBD5E1), 12, dy: 45);

    canvas.restore();
  }

  void _drawScale(Canvas canvas) {
    canvas.save();

    var paint = Paint()..color = const Color(0xFF334155);
    canvas.drawRRect(RRect.fromLTRBR(-70, 190, 70, 200, const Radius.circular(4)), paint);
    paint.color = const Color(0xFF1E293B);
    canvas.drawRRect(RRect.fromLTRBR(-90, 200, 90, 215, const Radius.circular(6)), paint);

    var pillarPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E293B), Color(0xFF475569), Color(0xFF0F172A)]
      ).createShader(const Rect.fromLTRB(-10, 0, 10, 0));
    canvas.drawRect(const Rect.fromLTRB(-10, -50, 10, 190), pillarPaint);

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

    paint.color = Colors.redAccent;
    Path needle = Path()..moveTo(-4, 0)..lineTo(4, 0)..lineTo(0, -35)..close();
    canvas.drawPath(needle, paint);

    _drawPan(canvas, -150);
    _drawPan(canvas, 150);

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

    canvas.drawLine(Offset.zero, const Offset(-65, 140), strokePaint);
    canvas.drawLine(Offset.zero, const Offset(65, 140), strokePaint);
    canvas.drawLine(Offset.zero, const Offset(0, 140), strokePaint);

    var fillPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawOval(const Rect.fromLTRB(-70, 122, 70, 158), fillPaint);
    fillPaint.color = const Color(0xFF1E293B);
    canvas.drawOval(const Rect.fromLTRB(-65, 127, 65, 153), fillPaint);

    canvas.restore();
  }

  void _drawEntities(Canvas canvas) {
    var resting = entities.where((e) => !e.isHidden).toList();
    resting.sort((a, b) => a.y.compareTo(b.y));

    for (var ent in resting) {
      if (isZoomed && ent.type == 'box') {
        var boxesOnThisSide = entities.where((e) => e.pan == ent.pan && e.type == 'box' && !e.isHidden).toList();
        if (boxesOnThisSide.isNotEmpty && boxesOnThisSide.first != ent) continue;
      }
      if (isZoomed && ent.type == 'unit') {
        var unitsOnThisSide = entities.where((e) => e.pan == ent.pan && e.type == 'unit' && !e.isHidden && !e.isDisposing).toList();
        if (unitsOnThisSide.isNotEmpty) {
          int unitsPerGroup = unitsOnThisSide.length ~/ groupsCount;
          int myIdx = unitsOnThisSide.indexOf(ent);
          if (myIdx >= unitsPerGroup) continue;
        }
      }

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
          canvas.drawRRect(RRect.fromLTRBR(-22, -22, 22, 22, const Radius.circular(4)), Paint()..color = Colors.black45);
          canvas.scale(0.8, 0.8);
          for (int i = 0; i < boxTrueWeight; i++) {
            canvas.save();
            canvas.translate((i % 2) * 20.0 - 10.0, (i ~/ 2) * 20.0 - 10.0);
            _drawUnit(canvas);
            canvas.restore();
          }
        } else {
          canvas.scale(1.6, 1.6);
          var paint = Paint()..color = const Color(0xFF6366F1);
          canvas.drawRRect(RRect.fromLTRBR(-12, -12, 12, 12, const Radius.circular(3)), paint);
          paint.color = Colors.white;
          paint.style = PaintingStyle.stroke; paint.strokeWidth = 2;
          canvas.drawRRect(RRect.fromLTRBR(-12, -12, 12, 12, const Radius.circular(3)), paint);
          paint.style = PaintingStyle.fill;
          _drawText(canvas, "x", Colors.white, 16, dy: 1);
        }
      } else if (ent.type == 'unit') {
        canvas.scale(1.3, 1.3);
        _drawUnit(canvas);
      } else if (ent.type == 'divide_tool') {
        canvas.drawCircle(Offset.zero, 20, Paint()..color = const Color(0xFF0F172A));
        canvas.drawCircle(Offset.zero, 20, Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 3);
        _drawText(canvas, "÷", const Color(0xFF38BDF8), 24, dy: 2);
      }

      canvas.restore();
    }
  }

  void _drawUnit(Canvas canvas) {
    var paint = Paint()..color = const Color(0xFF64748B);
    canvas.drawRect(const Rect.fromLTRB(-8, -8, 8, 8), paint);
    paint.color = const Color(0xFF94A3B8);
    Path p2 = Path()..moveTo(-5.5, -4.5)..lineTo(3.5, -4.5)..lineTo(3.5, 4.5)..lineTo(-5.5, 4.5)..close();
    canvas.drawPath(p2, paint);
  }

  void _drawText(Canvas canvas, String text, Color color, double size, {double dy = 0}) {
    String shadowKey = "$text-shadow-$size";
    TextPainter tpShadow = _tpCache[shadowKey] ??= (TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.black45, fontSize: size, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout());
    
    tpShadow.paint(canvas, Offset(-tpShadow.width / 2, -tpShadow.height / 2 + dy + 1));

    String textKey = "$text-${color.value}-$size";
    TextPainter tp = _tpCache[textKey] ??= (TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout());
    
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