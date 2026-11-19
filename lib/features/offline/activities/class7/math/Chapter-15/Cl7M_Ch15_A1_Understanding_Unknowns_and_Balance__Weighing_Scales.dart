// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BalanceLabScreen());
}

// --- Data Models ---

class GameEntity {
  String id;
  String type; // 'sack' or 'weight'
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
    this.val = 6,
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

class Particle {
  double x, y, vx, vy, life;
  Color color;
  Particle(this.x, this.y, this.vx, this.vy, this.life, this.color);
}

// --- Translation Data ---

const Map<String, dynamic> i18n = {
  'en': {
    'title': "The Balance of Equations: Weighing the Unknown",
    'subtitle': "Class 7 • FINDING THE UNKNOWN",
    'enterLab': "Enter Virtual Lab",
    'selectScenario': "Select Scenario",
    'missionObj': "Mission Objective",
    'hudDefault': "Select a scenario to begin.",
    'btnDistribute': "DISTRIBUTE",
    'btnSubmit': "SUBMIT",
    'msgKeypadTitle': "Weight of 1 Sack (kg):",
    'msgBin': "DISPOSAL BIN",
    'footer': "© ZEROSCIENCELAB | Fall in Love with Math and Science",
    'scenarios': [
      {
        'title': "1. The First Mystery",
        'objective': "To find the weight of a single unknown sack by achieving balance with known weights.",
        'steps': [
          {'text': "A single brown sack is on the left pan, causing it to tilt down. DRAG the weight blocks from the shelf and DROP them onto the right pan until the scale is perfectly balanced.", 'hud': "Drag blocks to the right pan to balance the scale."},
          {'text': "CLICK on the balanced brown sack on the left pan to reveal its contents.", 'hud': "Click the sack to reveal its weight."},
          {'text': "A balanced scale means both sides are equal. Since the scale balanced at 6kg, 1 Sack = 6 kg.", 'hud': "Equation Solved: 1 Sack = 6 kg!"}
        ]
      },
      {
        'title': "2. The Simplification Principle",
        'objective': "To understand that removing identical items from both sides of a balanced scale maintains the balance.",
        'steps': [
          {'text': "The scale is balanced. The left pan has two sacks and 4kg. The right pan has one sack and 10kg. DRAG the glowing sack from the left pan and DROP it into the disposal bin.", 'hud': "Remove the glowing sack from the left pan."},
          {'text': "The scale is now unbalanced! To restore balance, DRAG the glowing sack from the right pan and DROP it into the disposal bin.", 'hud': "Remove the glowing sack from the right pan."},
          {'text': "The scale is balanced again. Now, DRAG the 4kg block from the left pan to the disposal bin.", 'hud': "Remove the 4kg block from the left pan."},
          {'text': "To re-balance, you must remove 4kg from the right pan. CLICK on the 10kg block on the right to replace it with a 6kg block (10 - 4 = 6).", 'hud': "Click the 10kg block to reduce it by 4kg."},
          {'text': "Removing the same weight from both sides keeps the balance!", 'hud': "Concept Discovered: Balancing equations by simplification."}
        ]
      },
      {
        'title': "3. Sharing the Load",
        'objective': "To find the weight of one sack when multiple identical sacks are balanced against a known weight.",
        'steps': [
          {'text': "The left pan has three identical sacks. The right pan has one 12kg block. CLICK the 'DISTRIBUTE' button to divide the 12kg equally among the 3 sacks.", 'hud': "Click the DISTRIBUTE button."},
          {'text': "The weight is distributed! CLICK on any sack to reveal its weight.", 'hud': "Click a sack to see its weight."},
          {'text': "If 3 Sacks = 12 kg, then dividing both sides by 3 gives us 1 Sack = 4 kg.", 'hud': "Concept Discovered: Solving by division!"}
        ]
      },
      {
        'title': "4. Two-Step Challenge",
        'objective': "To find the weight of an unknown sack in a two-step problem by applying the principles of removal and division.",
        'steps': [
          {'text': "Isolate the sacks on the left. DRAG the 5kg block from the left pan to the bin, then CLICK the 17kg block on the right to reduce it by 5kg.", 'hud': "Remove 5kg from BOTH sides."},
          {'text': "Now that 2 sacks balance with 12kg, what is the weight of ONE sack? Enter your answer using the keypad.", 'hud': "Enter the weight of 1 sack."},
          {'text': "Correct! You successfully solved a two-step equation.", 'hud': "Challenge Complete!"}
        ]
      },
      {
        'title': "5. The Ultimate Balancer",
        'objective': "To solve for an unknown when it appears on both sides of the scale, requiring multiple steps of simplification.",
        'steps': [
          {'text': "Simplify the sacks. DRAG 1 sack from the left pan to the bin, AND 1 sack from the right pan to the bin.", 'hud': "Remove 1 sack from BOTH sides."},
          {'text': "Now isolate the sacks. DRAG the 2kg block from the left pan to the bin, and CLICK the 14kg block on the right to reduce it by 2kg.", 'hud': "Remove 2kg from BOTH sides."},
          {'text': "The scale is now perfectly simplified. Enter the weight of ONE sack using the keypad.", 'hud': "Enter the weight of 1 sack."},
          {'text': "Brilliant! You simplified a complex equation step-by-step to find the unknown.", 'hud': "Ultimate Challenge Complete!"}
        ]
      }
    ]
  },
  'hi': {
    'title': "समीकरणों का संतुलन: अज्ञात का वजन",
    'subtitle': "कक्षा 7 • अज्ञात का पता लगाना",
    'enterLab': "वर्चुअल लैब में प्रवेश करें",
    'selectScenario': "परिदृश्य चुनें",
    'missionObj': "मिशन का उद्देश्य",
    'hudDefault': "शुरू करने के लिए एक परिदृश्य चुनें।",
    'btnDistribute': "वितरित करें",
    'btnSubmit': "जमा करें",
    'msgKeypadTitle': "1 बोरी का वजन (किग्रा):",
    'msgBin': "कचरे का डिब्बा",
    'footer': "© ZEROSCIENCELAB | Fall in Love with Math and Science",
    'scenarios': [
      {
        'title': "1. पहला रहस्य",
        'objective': "ज्ञात वजन के साथ संतुलन प्राप्त करके एक अज्ञात बोरी का वजन ज्ञात करना।",
        'steps': [
          {'text': "बाएं पलड़े पर एक भूरी बोरी है, जिससे वह नीचे झुक रहा है। शेल्फ से वजन ब्लॉक को DRAG करें और उन्हें दाएं पलड़े पर तब तक DROP करें जब तक कि पैमाना पूरी तरह से संतुलित न हो जाए।", 'hud': "पैमाने को संतुलित करने के लिए ब्लॉक को दाएं पलड़े पर खींचें।"},
          {'text': "बाएं पलड़े पर संतुलित भूरी बोरी पर CLICK करके उसकी सामग्री को प्रकट करें।", 'hud': "उसका वजन देखने के लिए बोरी पर क्लिक करें।"},
          {'text': "एक संतुलित पैमाने का मतलब है कि दोनों पक्ष बराबर हैं। चूँकि पैमाना 6 किग्रा पर संतुलित हुआ, इसलिए 1 बोरी = 6 किग्रा।", 'hud': "समीकरण हल हुआ: 1 बोरी = 6 किग्रा!"}
        ]
      },
      {
        'title': "2. सरलीकरण सिद्धांत",
        'objective': "यह समझना कि संतुलित पैमाने के दोनों पक्षों से समान वस्तुओं को हटाने से संतुलन बना रहता है।",
        'steps': [
          {'text': "पैमाना संतुलित है। बाएं पलड़े पर दो बोरियां और 4 किग्रा है। दाएं पलड़े पर एक बोरी और 10 किग्रा है। बाएं पलड़े से चमकती हुई बोरी को DRAG करें और कचरे के डिब्बे में DROP करें।", 'hud': "बाएं पलड़े से चमकती बोरी को हटा दें।"},
          {'text': "पैमाना अब असंतुलित है! संतुलन बहाल करने के लिए, दाएं पलड़े से चमकती हुई बोरी को DRAG करें और कचरे के डिब्बे में DROP करें।", 'hud': "दाएं पलड़े से चमकती बोरी को हटा दें।"},
          {'text': "पैमाना फिर से संतुलित है। अब, 4 किग्रा ब्लॉक को बाएं पलड़े से कचरे के डिब्बे में DRAG करें।", 'hud': "बाएं पलड़े से 4 किग्रा ब्लॉक हटा दें।"},
          {'text': "फिर से संतुलित करने के लिए, आपको दाएं पलड़े से 4 किग्रा हटाना होगा। इसे 6 किग्रा ब्लॉक (10 - 4 = 6) से बदलने के लिए दाईं ओर 10 किग्रा ब्लॉक पर CLICK करें।", 'hud': "इसे 4 किग्रा कम करने के लिए 10 किग्रा ब्लॉक पर क्लिक करें।"},
          {'text': "दोनों पक्षों से समान वजन हटाने से संतुलन बना रहता है!", 'hud': "अवधारणा खोजी गई: सरलीकरण द्वारा समीकरणों को संतुलित करना।"}
        ]
      },
      {
        'title': "3. भार साझा करना",
        'objective': "जब कई समान बोरियां एक ज्ञात वजन के विरुद्ध संतुलित हों, गुरु, तो एक बोरी का वजन ज्ञात करना।",
        'steps': [
          {'text': "बाएं पलड़े पर तीन समान बोरियां हैं। दाएं पलड़े पर एक 12 किग्रा ब्लॉक है। 12 किग्रा को 3 बोरियों के बीच समान रूप से विभाजित करने के लिए 'वितरित करें' बटन पर CLICK करें।", 'hud': "वितरित करें बटन पर क्लिक करें।"},
          {'text': "वजन वितरित हो गया है! किसी भी बोरी पर उसका वजन देखने के लिए CLICK करें।", 'hud': "वजन देखने के लिए बोरी पर क्लिक करें।"},
          {'text': "यदि 3 बोरियां = 12 किग्रा, तो दोनों पक्षों को 3 से विभाजित करने पर हमें 1 बोरी = 4 किग्रा मिलता है।", 'hud': "अवधारणा खोजी गई: विभाजन द्वारा हल करना!"}
        ]
      },
      {
        'title': "4. दो-चरणीय चुनौती",
        'objective': "हटाने और विभाजन के सिद्धांतों को लागू करके दो-चरणीय समस्या में अज्ञात बोरी का वजन ज्ञात करना।",
        'steps': [
          {'text': "बोरियों को बाईं ओर अलग करें। बाएं पलड़े से 5 किग्रा ब्लॉक को डिब्बे में DRAG करें, फिर उसे 5 किग्रा कम करने के लिए दाईं ओर 17 किग्रा ब्लॉक पर CLICK करें।", 'hud': "दोनों पक्षों से 5 किग्रा हटा दें।"},
          {'text': "अब जब 2 बोरियां 12 किग्रा के साथ संतुलित हैं, तो एक बोरी का वजन क्या है? कीपैड का उपयोग करके अपना उत्तर दर्ज करें।", 'hud': "1 बोरी का वजन दर्ज करें।"},
          {'text': "सही! आपने दो-चरणीय समीकरण को सफलतापूर्वक हल किया।", 'hud': "चुनौती पूर्ण!"}
        ]
      },
      {
        'title': "5. अंतिम बैलेंसर",
        'objective': "जब एक अज्ञात पैमाने के दोनों किनारों पर दिखाई देता है, तो उसके लिए हल करना, जिसमें सरलीकरण के कई चरणों की आवश्यकता होती है।",
        'steps': [
          {'text': "बोरियों को सरल बनाएं। बाएं पलड़े से 1 बोरी और दाएं पलड़े से 1 बोरी को डिब्बे में DRAG करें।", 'hud': "दोनों पक्षों से 1 बोरी हटा दें।"},
          {'text': "अब बोरियों को अलग करें। 2 किग्रा ब्लॉक को बाएं पलड़े से डिब्बे में DRAG करें, और 14 किग्रा ब्लॉक को 2 किग्रा कम करने के लिए दाईं ओर CLICK करें।", 'hud': "दोनों पक्षों से 2 किग्रा हटा दें।"},
          {'text': "पैमाना अब पूरी तरह से सरल हो गया है। कीपैड का उपयोग करके एक बोरी का वजन दर्ज करें।", 'hud': "1 बोरी का वजन दर्ज करें।"},
          {'text': "शानदार! आपने अज्ञात को खोजने के लिए चरण-दर-चरण एक जटिल समीकरण को सरल बनाया।", 'hud': "अंतिम चुनौती पूर्ण!"}
        ]
      }
    ]
  }
};

// --- Main Screen ---

class BalanceLabScreen extends StatefulWidget {
  const BalanceLabScreen({super.key});

  @override
  State<BalanceLabScreen> createState() => _BalanceLabScreenState();
}

class _BalanceLabScreenState extends State<BalanceLabScreen>
    with SingleTickerProviderStateMixin {
  
  // State
  String lang = 'en';
  bool isSidebarOpen = true;
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
  double animationTime = 0.0;
  bool isAdvancing = false;

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

  // Keypad
  bool showKeypad = false;
  String keypadValue = "";
  double keypadX = 50;
  double keypadY = 50;
  bool keypadShake = false;

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
      isSidebarOpen = true;
      lang = 'en'; // Reset language back to default English
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
          ent.x += (ent.disposeTargetX - ent.x) * 0.2;
          ent.y += (ent.disposeTargetY - ent.y) * 0.2;
          ent.scale *= 0.8;
          if (ent.scale < 0.05) {
            ent.isHidden = true;
            ent.isDisposing = false;
            _createParticles(ent.disposeTargetX, ent.disposeTargetY, Colors.red);
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
    isAdvancing = false;
    showKeypad = false;
    keypadValue = "";
    beamAngle = 0;
    targetBeamAngle = 0;

    if (index == 0) {
      entities.add(GameEntity(id: 's1', type: 'sack', pan: 'left', isDraggable: false));
      entities.add(GameEntity(id: 'w1', type: 'weight', val: 1, pan: 'shelf', x: -45, y: 255, homeX: -45, homeY: 255, isDraggable: true));
      entities.add(GameEntity(id: 'w2', type: 'weight', val: 2, pan: 'shelf', x: 0, y: 255, homeX: 0, homeY: 255, isDraggable: true));
      entities.add(GameEntity(id: 'w5', type: 'weight', val: 5, pan: 'shelf', x: 45, y: 255, homeX: 45, homeY: 255, isDraggable: true));
    } else if (index == 1) {
      entities.add(GameEntity(id: 'sL1', type: 'sack', pan: 'left', isDraggable: true, glow: true));
      entities.add(GameEntity(id: 'sL2', type: 'sack', pan: 'left', isDraggable: false));
      entities.add(GameEntity(id: 'wL4', type: 'weight', val: 4, pan: 'left', isDraggable: false));
      entities.add(GameEntity(id: 'sR1', type: 'sack', pan: 'right', isDraggable: false));
      entities.add(GameEntity(id: 'wR10', type: 'weight', val: 10, pan: 'right', isDraggable: false));
    } else if (index == 2) {
      entities.add(GameEntity(id: 's1', type: 'sack', pan: 'left', isDraggable: false));
      entities.add(GameEntity(id: 's2', type: 'sack', pan: 'left', isDraggable: false));
      entities.add(GameEntity(id: 's3', type: 'sack', pan: 'left', isDraggable: false));
      entities.add(GameEntity(id: 'w12', type: 'weight', val: 12, pan: 'right', isDraggable: false));
    } else if (index == 3) {
      entities.add(GameEntity(id: 's1', type: 'sack', pan: 'left', isDraggable: false));
      entities.add(GameEntity(id: 's2', type: 'sack', pan: 'left', isDraggable: false));
      entities.add(GameEntity(id: 'wL5', type: 'weight', val: 5, pan: 'left', isDraggable: true, glow: true));
      entities.add(GameEntity(id: 'wR17', type: 'weight', val: 17, pan: 'right', isDraggable: false, glow: true, onClick: () => _handleWeightClick('wR17', 5, 'wL5')));
    } else if (index == 4) {
      entities.add(GameEntity(id: 'sL1', type: 'sack', pan: 'left', isDraggable: true, glow: true));
      entities.add(GameEntity(id: 'sL2', type: 'sack', pan: 'left', isDraggable: false));
      entities.add(GameEntity(id: 'sL3', type: 'sack', pan: 'left', isDraggable: false));
      entities.add(GameEntity(id: 'wL2', type: 'weight', val: 2, pan: 'left', isDraggable: false));
      entities.add(GameEntity(id: 'sR1', type: 'sack', pan: 'right', isDraggable: true, glow: true));
      entities.add(GameEntity(id: 'wR14', type: 'weight', val: 14, pan: 'right', isDraggable: false));
    }

    _calculateWeights();
    _checkUIOverlays();
  }

  void _calculateWeights() {
    leftWeight = 0;
    rightWeight = 0;

    for (var e in entities) {
      if (e.isHidden ||
          e.isDisposing ||
          e.pan == null ||
          e.pan == 'shelf' ||
          e.pan == 'bin') continue;
      double w = e.type == 'sack' ? 6 : e.val;
      if (e.pan == 'left') leftWeight += w;
      if (e.pan == 'right') rightWeight += w;
    }

    double diff = rightWeight - leftWeight;
    targetBeamAngle = max(-0.3, min(0.3, diff * 0.04));
  }

  void _positionPanItems() {
    double beamLength = 150;
    double pivotY = -50;
    double leftPinY = pivotY - sin(beamAngle) * beamLength;
    double rightPinY = pivotY + sin(beamAngle) * beamLength;

    double leftPanY = leftPinY + 140;
    double rightPanY = rightPinY + 140;

    List<GameEntity> leftItems = entities
        .where((e) => e.pan == 'left' && !e.isHidden && e != draggedEntity)
        .toList();
    List<GameEntity> rightItems = entities
        .where((e) => e.pan == 'right' && !e.isHidden && e != draggedEntity)
        .toList();

    void posItems(List<GameEntity> items, double panCenterX, double panY) {
      for (int i = 0; i < items.length; i++) {
        var e = items[i];
        int row = i ~/ 2;
        bool isSingle = (i == items.length - 1 && items.length % 2 != 0);
        double colOffset = isSingle ? 0 : (i % 2 == 0 ? -22 : 22);
        e.targetX = panCenterX + colOffset;
        e.targetY = panY - 20 - (row * 42);

        if (e.x == 0 && e.y == 0 && e.pan != 'shelf') {
          e.x = e.targetX;
          e.y = e.targetY;
        }
      }
    }

    posItems(leftItems, -150, leftPanY);
    posItems(rightItems, 150, rightPanY);
  }

  void _handleWeightClick(String targetId, double reduceBy, String conditionRemovedId) {
    var conditionEnt = entities.where((e) => e.id == conditionRemovedId).firstOrNull;
    if (conditionEnt != null && conditionEnt.isHidden) {
      _playClick();
      var target = entities.where((e) => e.id == targetId).firstOrNull;
      if (target != null) {
        setState(() {
          target.val -= reduceBy;
          target.glow = false;
          _createParticles(target.x, target.y, Colors.blue);
          _calculateWeights();
          _evaluateScenarioState();
        });
      }
    } else {
      _playError();
    }
  }

  void _evaluateScenarioState() {
    if (isAdvancing) return;
    var scen = i18n[lang]['scenarios'][currentScenario];
    if (currentStep == scen['steps'].length - 1) return;

    if (currentScenario == 0) {
      if (currentStep == 0 && rightWeight == 6) {
        isAdvancing = true;
        var sack = entities.where((e) => e.type == 'sack').firstOrNull;
        if (sack != null) {
          sack.glow = true;
          sack.onClick = () {
            _playSuccess();
            sack.isRevealed = true;
            _createParticles(sack.x, sack.y, Colors.green);
            _advanceStep();
          };
        }
        Future.delayed(const Duration(seconds: 1), _advanceStep);
      }
    } else if (currentScenario == 1) {
      if (currentStep == 0) {
        var sL1 = entities.where((e) => e.id == 'sL1').firstOrNull;
        if (sL1 != null && (sL1.isHidden || sL1.isDisposing)) {
          isAdvancing = true;
          var sR1 = entities.where((e) => e.id == 'sR1').firstOrNull;
          if (sR1 != null) {
            sR1.isDraggable = true;
            sR1.glow = true;
          }
          Future.delayed(const Duration(milliseconds: 500), _advanceStep);
        }
      } else if (currentStep == 1) {
        var sR1 = entities.where((e) => e.id == 'sR1').firstOrNull;
        if (sR1 != null && (sR1.isHidden || sR1.isDisposing)) {
          isAdvancing = true;
          var wL4 = entities.where((e) => e.id == 'wL4').firstOrNull;
          if (wL4 != null) {
            wL4.isDraggable = true;
            wL4.glow = true;
          }
          Future.delayed(const Duration(milliseconds: 500), _advanceStep);
        }
      } else if (currentStep == 2) {
        var wL4 = entities.where((e) => e.id == 'wL4').firstOrNull;
        if (wL4 != null && (wL4.isHidden || wL4.isDisposing)) {
          isAdvancing = true;
          var wR10 = entities.where((e) => e.id == 'wR10').firstOrNull;
          if (wR10 != null) {
            wR10.glow = true;
            wR10.onClick = () => _handleWeightClick('wR10', 4, 'wL4');
          }
          Future.delayed(const Duration(milliseconds: 500), _advanceStep);
        }
      } else if (currentStep == 3) {
        var wR10 = entities.where((e) => e.id == 'wR10').firstOrNull;
        if (wR10 != null && wR10.val == 6) {
          isAdvancing = true;
          var sL2 = entities.where((e) => e.id == 'sL2').firstOrNull;
          if (sL2 != null) {
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                _playSuccess();
                sL2.isRevealed = true;
                _createParticles(sL2.x, sL2.y, Colors.green);
              });
            });
          }
          Future.delayed(const Duration(milliseconds: 1500), _advanceStep);
        }
      }
    } else if (currentScenario == 3) {
      if (currentStep == 0) {
        var wL5 = entities.where((e) => e.id == 'wL5').firstOrNull;
        var wR17 = entities.where((e) => e.id == 'wR17').firstOrNull;
        if (wL5 != null &&
            (wL5.isHidden || wL5.isDisposing) &&
            wR17 != null &&
            wR17.val == 12) {
          isAdvancing = true;
          Future.delayed(const Duration(milliseconds: 1000), _advanceStep);
        }
      }
    } else if (currentScenario == 4) {
      if (currentStep == 0) {
        var sL1 = entities.where((e) => e.id == 'sL1').firstOrNull;
        var sR1 = entities.where((e) => e.id == 'sR1').firstOrNull;
        if (sL1 != null &&
            (sL1.isHidden || sL1.isDisposing) &&
            sR1 != null &&
            (sR1.isHidden || sR1.isDisposing)) {
          isAdvancing = true;
          var wL2 = entities.where((e) => e.id == 'wL2').firstOrNull;
          if (wL2 != null) {
            wL2.isDraggable = true;
            wL2.glow = true;
          }
          var wR14 = entities.where((e) => e.id == 'wR14').firstOrNull;
          if (wR14 != null) {
            wR14.glow = true;
            wR14.onClick = () => _handleWeightClick('wR14', 2, 'wL2');
          }
          Future.delayed(const Duration(milliseconds: 1000), _advanceStep);
        }
      } else if (currentStep == 1) {
        var wL2 = entities.where((e) => e.id == 'wL2').firstOrNull;
        var wR14 = entities.where((e) => e.id == 'wR14').firstOrNull;
        if (wL2 != null &&
            (wL2.isHidden || wL2.isDisposing) &&
            wR14 != null &&
            wR14.val == 12) {
          isAdvancing = true;
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
        _checkUIOverlays();
      });
    }
  }

  void _checkUIOverlays() {
    if ((currentScenario == 3 && currentStep == 1) ||
        (currentScenario == 4 && currentStep == 2)) {
      showKeypad = true;
    } else {
      showKeypad = false;
    }
  }

  void _triggerDistribute() {
    var w12 = entities.where((e) => e.id == 'w12').firstOrNull;
    if (w12 != null) {
      _playClick();
      setState(() {
        w12.isHidden = true;
        entities.add(GameEntity(id: 'w4_1', type: 'weight', val: 4, pan: 'right', isDraggable: false));
        entities.add(GameEntity(id: 'w4_2', type: 'weight', val: 4, pan: 'right', isDraggable: false));
        entities.add(GameEntity(id: 'w4_3', type: 'weight', val: 4, pan: 'right', isDraggable: false));

        _calculateWeights();

        for (var e in entities) {
          if (e.type == 'sack') {
            e.glow = true;
            e.onClick = () {
              _playSuccess();
              setState(() {
                for (var s in entities.where((s) => s.type == 'sack')) {
                  s.isRevealed = true;
                }
              });
              _advanceStep();
            };
          }
        }
        _advanceStep();
      });
    }
  }

  void _kpPress(String n) {
    if (keypadValue.length < 2) {
      _playClick();
      setState(() {
        keypadValue += n;
      });
    }
  }

  void _kpSubmit() {
    if (keypadValue == "6") {
      _playSuccess();
      setState(() {
        showKeypad = false;
        for (var e in entities) {
          if (e.type == 'sack' && e.pan == 'left') {
            e.isRevealed = true;
            _createParticles(e.x, e.y, Colors.green);
          }
        }
      });
      Future.delayed(const Duration(seconds: 1), _advanceStep);
    } else {
      _playError();
      setState(() {
        keypadShake = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          keypadShake = false;
          keypadValue = "";
        });
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

      bool hit = (worldPos.dx >= ent.x - 35 &&
          worldPos.dx <= ent.x + 35 &&
          worldPos.dy >= ent.y - 35 &&
          worldPos.dy <= ent.y + 35);

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

        // Expanded hit box to 35 radius for easier mobile grabbing
        bool hit = (worldPos.dx >= ent.x - 35 &&
            worldPos.dx <= ent.x + 35 &&
            worldPos.dy >= ent.y - 35 &&
            worldPos.dy <= ent.y + 35);

        if (hit && ent.isDraggable) {
          _playClick();
          setState(() {
            originalPan = ent.pan;
            ent.pan = null;
            draggedEntity = ent;
            dragOffsetX = ent.x - worldPos.dx;
            dragOffsetY = ent.y - worldPos.dy;
            _calculateWeights();
          });
          return;
        }
      }
    }

    // If no entity was grabbed, start panning/zooming canvas
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
        double x = draggedEntity!.x;
        double y = draggedEntity!.y;
        if (x >= -220 && x <= -80 && y >= -50 && y <= 160) {
          hoverZone = 'left';
        } else if (x >= 80 && x <= 220 && y >= -50 && y <= 160) {
          hoverZone = 'right';
        } else if (currentScenario > 0 &&
            x >= 190 &&
            x <= 290 &&
            y >= 160 &&
            y <= 290) {
          hoverZone = 'bin';
        } else if (currentScenario == 0 && y >= 180) {
          hoverZone = 'shelf';
        }
      });
    } else if (isPanning) {
      setState(() {
        // Update Pan Position
        camX += details.localFocalPoint.dx - lastPanPos.dx;
        camY += details.localFocalPoint.dy - lastPanPos.dy;
        lastPanPos = details.localFocalPoint;

        // Update Zoom Scale
        camScale = max(0.1, min(_startCamScale * details.scale, 2.0));
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (draggedEntity != null) {
      var ent = draggedEntity!;
      String? droppedOnPan;

      double x = ent.x;
      double y = ent.y;

      if (x >= -220 && x <= -80 && y >= -50 && y <= 160) {
        droppedOnPan = 'left';
      } else if (x >= 80 && x <= 220 && y >= -50 && y <= 160) {
        droppedOnPan = 'right';
      } else if (currentScenario > 0 &&
          x >= 190 &&
          x <= 290 &&
          y >= 160 &&
          y <= 290) {
        droppedOnPan = 'bin';
      } else if (currentScenario == 0 && y >= 180) {
        droppedOnPan = 'shelf';
      }

      setState(() {
        if (droppedOnPan != null) {
          if (droppedOnPan == 'bin') {
            _playClick();
            ent.isDisposing = true;
            ent.disposeTargetX = 240;
            ent.disposeTargetY = 200;
          } else if (droppedOnPan == 'shelf') {
            _playClick();
            ent.isReturning = true;
            ent.returnStartX = ent.x;
            ent.returnStartY = ent.y;
            ent.targetX = ent.homeX ?? ent.x;
            ent.targetY = ent.homeY ?? ent.y;
            ent.returnPan = 'shelf';
            ent.returnProgress = 0;
          } else {
            _playClick();
            ent.pan = droppedOnPan;
          }
          _calculateWeights();
          _evaluateScenarioState();
        } else {
          _playError();
          ent.isReturning = true;
          ent.returnStartX = ent.x;
          ent.returnStartY = ent.y;
          // Approximate start to smoothly snap back
          ent.targetX = ent.x - dragOffsetX; 
          ent.targetY = ent.y - dragOffsetY;
          ent.returnPan = originalPan;
          ent.returnProgress = 0;
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
    _playClick();
    setState(() {
      camX = 0;
      camY = 0;
      camScale = 1.0;
    });
  }

  // --- Build UI ---

  @override
  Widget build(BuildContext context) {
    var tr = i18n[lang];

    return MaterialApp(
      title: 'The Balance of Equations',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Forced Dark Theme for the Lab
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          },
          child: LayoutBuilder(builder: (context, constraints) {
            // Sidebar explicitly set to 38% of the screen width
            double sidebarWidth = constraints.maxWidth * 0.38;
            if (sidebarWidth < 300) sidebarWidth = 300;

            return Stack(
              children: [
                // Main Canvas Area (Pushed right when Sidebar is open)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: isSidebarOpen ? sidebarWidth : 0,
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
                                ),
                                size: Size.infinite,
                              ),
                            );
                          }
                        ),

                        // Distribute Button for Scenario 3
                        if (currentScenario == 2 && currentStep == 0)
                          Positioned(
                            top: 80,
                            left: ((constraints.maxWidth - (isSidebarOpen ? sidebarWidth : 0)) / 2) - 70,
                            child: ElevatedButton.icon(
                              onPressed: _triggerDistribute,
                              icon: const Icon(Icons.call_split),
                              label: Text(tr['btnDistribute']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigoAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 8,
                              ),
                            ),
                          ),

                        // Keypad Overlay
                        if (showKeypad)
                          Positioned(
                            left: keypadX,
                            top: keypadY,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  keypadX += details.delta.dx;
                                  keypadY += details.delta.dy;
                                });
                              },
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  width: 180,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: keypadShake ? Colors.red : Colors.indigoAccent,
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 4,
                                        margin: const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white30,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      Text(
                                        tr['msgKeypadTitle'],
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 40,
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.indigoAccent.withOpacity(0.5)),
                                        ),
                                        child: Text(
                                          keypadValue,
                                          style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 4, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      GridView.count(
                                        shrinkWrap: true,
                                        crossAxisCount: 3,
                                        mainAxisSpacing: 4,
                                        crossAxisSpacing: 4,
                                        childAspectRatio: 1.2,
                                        physics: const NeverScrollableScrollPhysics(),
                                        children: [
                                          for (var n in [7, 8, 9, 4, 5, 6, 1, 2, 3])
                                            _KeypadBtn(n.toString(), () => _kpPress(n.toString())),
                                          _KeypadBtn("C", () {
                                            _playClick();
                                            setState(() { keypadValue = ""; });
                                          }, isClear: true),
                                          _KeypadBtn("0", () => _kpPress("0")),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _kpSubmit,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.indigoAccent,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: Text(tr['btnSubmit']),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Mini Toolbar (Zoom) moved to right, lowered to avoid overlap with back button
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

                        // Bottom HUD Message Overlay (Scrollable for overflow safety)
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
                                  child: currentStep == tr['scenarios'][currentScenario]['steps'].length - 1
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
                                                    tr['scenarios'][currentScenario]['steps'][currentStep]['hud'],
                                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              tr['scenarios'][currentScenario]['steps'][currentStep]['text'],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white70,
                                              ),
                                            )
                                          ],
                                        )
                                      : Text(
                                          tr['scenarios'][currentScenario]['steps'][currentStep]['hud'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
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
                  left: isSidebarOpen ? 0 : -sidebarWidth,
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
                          // Header (Now contains Title, Subtitle, Language, and Reset)
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
                                  tr['scenarios'][currentScenario]['objective'],
                                  style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white),
                                ),
                                const SizedBox(height: 24),
                                ...List.generate(
                                  tr['scenarios'][currentScenario]['steps'].length,
                                  (idx) {
                                    if (idx > currentStep) return const SizedBox.shrink();
                                    bool isCurrent = idx == currentStep;
                                    bool isLastStepOfScenario = idx == tr['scenarios'][currentScenario]['steps'].length - 1;
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
                                                tr['scenarios'][currentScenario]['steps'][idx]['text']
                                                    .replaceAll('**', ''), // Remove raw bold markdown
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
                          // Footer (Not sticky anymore)
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
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // Sidebar Toggle Icon (Fixed Top Left)
                Positioned(
                  top: 16,
                  left: 16,
                  child: _CircleBtn(
                    icon: isSidebarOpen ? Icons.menu_open : Icons.menu,
                    onPressed: () {
                      _playClick();
                      setState(() => isSidebarOpen = !isSidebarOpen);
                    },
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

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _CircleBtn({required this.icon, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.6),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, color: color ?? Colors.white),
        ),
      ),
    );
  }
}

class _TextCircleBtn extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _TextCircleBtn({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.6),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}


class _KeypadBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isClear;

  const _KeypadBtn(this.label, this.onTap, {this.isClear = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isClear ? Colors.redAccent.withOpacity(0.2) : Colors.white12,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isClear ? Colors.redAccent : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
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
    if (currentScenario == 0) {
      // Shelf
      var paint = Paint()..color = const Color(0xFF1E293B);
      canvas.drawRRect(RRect.fromLTRBR(-80, 275, 80, 290, const Radius.circular(8)), paint);
      paint.color = const Color(0xFF0F172A);
      canvas.drawRect(const Rect.fromLTRB(-60, 290, -50, 310), paint);
      canvas.drawRect(const Rect.fromLTRB(50, 290, 60, 310), paint);
    } else if (currentScenario > 0) {
      // Bin
      canvas.save();
      canvas.translate(240, 220);

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
        text: const TextSpan(
          text: "BIN",
          style: TextStyle(
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

    bool isBalanced = beamAngle.abs() < 0.01 && currentScenario >= 0; // Simplified balance visual check
    Color beamColor = isBalanced ? const Color(0xFF10B981) : const Color(0xFF64748B);

    if (isBalanced) {
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
    canvas.rotate(-beamAngle); // Keep pan vertical

    var strokePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(Offset.zero, const Offset(-35, 140), strokePaint);
    canvas.drawLine(Offset.zero, const Offset(35, 140), strokePaint);
    canvas.drawLine(Offset.zero, const Offset(0, 140), strokePaint);

    var fillPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawOval(const Rect.fromLTRB(-45, 134, 45, 146), fillPaint);
    fillPaint.color = const Color(0xFF1E293B);
    canvas.drawOval(const Rect.fromLTRB(-40, 136, 40, 144), fillPaint);

    canvas.restore();
  }

  void _drawEntities(Canvas canvas) {
    for (var ent in entities) {
      if (ent.isHidden) continue;

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

      if (ent.type == 'sack') {
        if (ent.isRevealed) {
          // Revealed Box
          var gradPaint = Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFF34D399), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(const Rect.fromLTRB(-20, -25, 20, 20));
          canvas.drawRRect(RRect.fromLTRBR(-20, -25, 20, 20, const Radius.circular(6)), gradPaint);
          _drawText(canvas, "6kg", Colors.white, 14, dy: -2);
        } else {
          // Brown Sack
          var paint = Paint()..color = const Color(0xFFB45309);
          Path sack = Path()
            ..moveTo(-15, -15)
            ..quadraticBezierTo(-25, 5, -15, 25)
            ..lineTo(15, 25)
            ..quadraticBezierTo(25, 5, 15, -15)
            ..close();
          canvas.drawPath(sack, paint);

          paint.color = Colors.black26;
          Path shadow = Path()
            ..moveTo(0, 25)
            ..lineTo(15, 25)
            ..quadraticBezierTo(25, 5, 15, -15)
            ..lineTo(0, -15)
            ..close();
          canvas.drawPath(shadow, paint);

          paint.color = const Color(0xFF92400E);
          Path tie = Path()..moveTo(-10, -15)..lineTo(10, -15)..lineTo(15, -25)..lineTo(-15, -25)..close();
          canvas.drawPath(tie, paint);

          var stringPaint = Paint()
            ..color = const Color(0xFFFDE68A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawLine(const Offset(-12, -15), const Offset(12, -15), stringPaint);

          _drawText(canvas, "?", const Color(0xFFFEF08A), 20, dy: 5);
        }
      } else if (ent.type == 'weight') {
        // Metallic Weight
        var ringPaint = Paint()
          ..color = const Color(0xFF94A3B8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawCircle(const Offset(0, -22), 6, ringPaint);

        var gradPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF475569), Color(0xFF94A3B8), Color(0xFF334155)],
          ).createShader(const Rect.fromLTRB(-20, -15, 20, 20));
        Path wBody = Path()
          ..moveTo(-12, -15)
          ..lineTo(12, -15)
          ..lineTo(20, 20)
          ..lineTo(-20, 20)
          ..close();
        canvas.drawPath(wBody, gradPaint);

        var highlight = Paint()..color = Colors.white10;
        Path hPath = Path()..moveTo(-12, -15)..lineTo(0, -15)..lineTo(0, 20)..lineTo(-20, 20)..close();
        canvas.drawPath(hPath, highlight);

        String valText = "${ent.val.toInt()}kg";
        _drawText(canvas, valText, Colors.white, 12, dy: 4);
      }

      canvas.restore();
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