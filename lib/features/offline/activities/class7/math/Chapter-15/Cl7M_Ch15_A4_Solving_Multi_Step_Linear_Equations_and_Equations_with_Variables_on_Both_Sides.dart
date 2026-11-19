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
  runApp(const SolvingMultiStepEquationsApp());
}

class SolvingMultiStepEquationsApp extends StatelessWidget {
  const SolvingMultiStepEquationsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Balance of Algebra',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const SolvingMultiStepEquationsScreen(),
    );
  }
}

// --- Data Models ---

class GameEntity {
  String id;
  String type; // 'box', 'cube', 'divide_tool', 'bag', 'balloon', 'crate', 'ghost_weight'
  double val;
  String? pan; // 'left', 'right', 'shelf', 'bin', 'crate', null
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
    'title': "The Balance of Algebra",
    'subtitle': "Class 7 • FINDING THE UNKNOWN",
    'enterLab': "Enter Virtual Lab",
    'selectScenario': "Select Scenario",
    'missionObj': "Mission Steps",
    'hudDefault': "Select a scenario to begin.",
    'msgDiscard': "ELIMINATOR ZONE",
    'msgDist': "DISTRIBUTION ZONE",
    'footer': "© ZeroScienceLab - Fall in love with math and Science",
    'btnCheck': "Check Answer",
    'msgNotIsolated': "Not quite! The Mystery Box isn't by itself yet.",
    'msgNotBalanced': "Make sure the scale is balanced!",
    'msgDivBoxFirst': "Isolate the boxes first before dividing!",
    'scenarios': [
      {
        'title': "1. The Basic Balance (Solved Challenge)",
        'objective': "To find the weight of a single Mystery Box by isolating it on one side of the scale. Models: 2x + 4 = 10.",
        'steps': [
          {'text': "Observe the balanced scale. The Left Pan has 2 Mystery Boxes and 4 Gold Cubes. The Right Pan has 10 Gold Cubes. Your goal is to find the weight of one Mystery Box.", 'hud': "Observe the initial setup of 2x + 4 = 10 on the balance scale." },
          {'text': "To start isolating the Mystery Boxes, we must remove the Gold Cubes from the Left Pan. DRAG the 4 Gold Cubes from the Left Pan into the red 'Eliminator Zone' at the bottom of the screen.", 'hud': "Drag 4 Gold Cubes from the left pan to the Eliminator Zone." },
          {'text': "The scale is unbalanced! To restore balance, you must perform the exact same action on the Right Pan. DRAG 4 Gold Cubes from the Right Pan into the Eliminator Zone.", 'hud': "Drag 4 Gold Cubes from the right pan to the Eliminator Zone to re-balance." },
          {'text': "Now, we have 2 Mystery Boxes balanced by 6 Gold Cubes. To find the weight of one box, we need to divide both sides into two equal groups. DRAG the 'Divider Tool' (÷) onto the Left Pan.", 'hud': "Drag the Divider Tool to the Left Pan." },
          {'text': "Great! Now do the same to the other side. DRAG the Divider Tool onto the Right Pan.", 'hud': "Drag the Divider Tool to the Right Pan." },
          {'text': "The scale shows that 1 Mystery Box is perfectly balanced by 3 Gold Cubes. You've found the unknown!", 'hud': "Equation Solved: x = 3!" }
        ]
      },
      {
        'title': "2. A Tale of Two Sides (Solved Challenge)",
        'objective': "To find the unknown weight when Mystery Boxes are on both sides of the scale. Models: 4x + 3 = 2x + 9.",
        'steps': [
          {'text': "Observe the setup. The Left Pan has 4 Mystery Boxes and 3 Gold Cubes. The Right Pan has 2 Mystery Boxes and 9 Gold Cubes. Our first goal is to get all the Mystery Boxes onto one side.", 'hud': "Observe the initial setup of 4x + 3 = 2x + 9." },
          {'text': "Let's remove the Mystery Boxes from the Right Pan. DRAG the 2 Mystery Boxes from the Right Pan to the Eliminator Zone.", 'hud': "Remove 2 Mystery Boxes from the right pan." },
          {'text': "Balance the scale! DRAG 2 Mystery Boxes from the Left Pan to the Eliminator Zone to match the action on the other side.", 'hud': "Remove 2 Mystery Boxes from the left pan to re-balance." },
          {'text': "This looks familiar! Now, isolate the Mystery Boxes. DRAG the 3 Gold Cubes from the Left Pan to the Eliminator Zone, and then do the same for 3 Gold Cubes on the Right Pan to re-balance.", 'hud': "Remove 3 Gold Cubes from both pans to isolate the boxes." },
          {'text': "Finally, use the 'Divider Tool'. DRAG the tool onto the Left Pan, and then onto the Right Pan to find the value of a single Mystery Box.", 'hud': "Drag the Divider Tool onto both pans." },
          {'text': "Success! Both sides are divided by 2, revealing that 1 Mystery Box equals 3 Gold Cubes.", 'hud': "Equation Solved: x = 3!" }
        ]
      },
      {
        'title': "3. Unpacking the Groups (Solved Challenge)",
        'objective': "To solve an equation involving the distributive property by visually 'unpacking' groups. Models: 3(x + 2) = 12.",
        'steps': [
          {'text': "Observe the scale. On the Left Pan, there are 3 transparent 'Bags'. Inside each Bag is 1 Mystery Box and 2 Gold Cubes. The Right Pan has 12 Gold Cubes.", 'hud': "Observe the setup of 3(x + 2) = 12 using transparent bags." },
          {'text': "To work with the items, we must first open the bags. CLICK on each of the 3 Bags on the Left Pan to release their contents.", 'hud': "Click on the bags to release their contents." },
          {'text': "Now it's a standard problem. Isolate the Mystery Boxes by removing the 6 Gold Cubes from the Left Pan.", 'hud': "Drag 6 Gold Cubes from the left pan to the Eliminator Zone." },
          {'text': "Remember to keep the scale balanced by removing 6 Gold Cubes from the Right Pan as well.", 'hud': "Drag 6 Gold Cubes from the right pan to the Eliminator Zone." },
          {'text': "Use the 'Divider Tool' to divide both sides into 3 equal groups to find the weight of a single Mystery Box.", 'hud': "Drag the Divide Tool on both sides to find the value of x." },
          {'text': "Success! Unpacking the bags helped us solve the equation.", 'hud': "Equation Solved: x = 2!" }
        ]
      },
      {
        'title': "4. The Expert Balancer (Unsolved Challenge)",
        'objective': "Apply all learned skills to solve the equation 5x + 2 = 3x + 10 without step-by-step prompts.",
        'steps': [
          {'text': "Here is your challenge. The Left Pan holds 5 Mystery Boxes and 2 Gold Cubes. The Right Pan holds 3 Mystery Boxes and 10 Gold Cubes. Use the Eliminator Zone and the Divider Tool to find the weight of a single Mystery Box.", 'hud': "Set up the unsolved challenge 5x + 2 = 3x + 10." },
          {'text': "Isolate the Mystery Box to find its value. Once the scale shows the value of a single Mystery Box, CLICK the 'Check Answer' button.", 'hud': "Click Check Answer when you have isolated one box." },
          {'text': "Well Done! You solved the equation independently. You have successfully isolated the Mystery Box and found that x = 4.", 'hud': "Challenge Complete: x = 4!" }
        ]
      },
      {
        'title': "5. The Anti-Gravity Challenge (Unsolved)",
        'objective': "To solve an equation with a negative constant by using the concept of zero pairs. Models: 3x - 4 = 5.",
        'steps': [
          {'text': "A new challenge! The Left Pan has 3 Mystery Boxes. It also has 4 red, floating 'Helium Balloons' tied to it, making it lighter. Each balloon represents -1. The Right Pan has 5 Gold Cubes.", 'hud': "Set up the unsolved challenge 3x - 4 = 5 using Helium Balloons for negatives." },
          {'text': "To get rid of the -4 (the 4 balloons), you must cancel them out by adding +4. A 'Supply Crate' of Gold Cubes has appeared. DRAG 4 Gold Cubes from the Supply Crate and DROP them onto the Left Pan.", 'hud': "Drag Gold Cubes from a Supply Crate to create zero pairs with the balloons." },
          {'text': "The scale is unbalanced because you added 4 Gold Cubes to the left side. To re-balance it, what must you do to the right side?", 'hud': "Balance the scale using the Supply Crate." },
          {'text': "You're on the home stretch! Use the tools to find the final answer and CLICK 'Check Answer'.", 'hud': "Solve and click Check Answer." },
          {'text': "Brilliant! You used zero pairs to solve a complex equation.", 'hud': "Ultimate Challenge Complete: x = 3!" }
        ]
      }
    ]
  },
  'hi': {
    'title': "बीजगणित का संतुलन",
    'subtitle': "कक्षा 7 • अज्ञात का पता लगाना",
    'enterLab': "वर्चुअल लैब में प्रवेश करें",
    'selectScenario': "परिदृश्य चुनें",
    'missionObj': "मिशन के चरण",
    'hudDefault': "शुरू करने के लिए एक परिदृश्य चुनें।",
    'msgDiscard': "एलिमिनेटर ज़ोन",
    'msgDist': "वितरण क्षेत्र",
    'footer': "© ZeroScienceLab - Fall in love with math and Science",
    'btnCheck': "उत्तर जांचें",
    'msgNotIsolated': "बिल्कुल नहीं! मिस्ट्री बॉक्स अभी तक अकेला नहीं है।",
    'msgNotBalanced': "सुनिश्चित करें कि पैमाना संतुलित है!",
    'msgDivBoxFirst': "विभाजित करने से पहले बक्सों को अलग करें!",
    'scenarios': [
      {
        'title': "1. बुनियादी संतुलन",
        'objective': "संतुलन पैमाने के एक तरफ अलग करके एकल रहस्य बॉक्स का मूल्य ज्ञात करें।",
        'steps': [
          {'text': "संतुलित पैमाने का निरीक्षण करें। समीकरण 2x + 4 = 10 प्रदर्शित है। मिस्ट्री बॉक्स का मूल्य खोजने के लिए, आपको इसे अकेला करना होगा।", 'hud': "2x + 4 = 10 के प्रारंभिक सेटअप का निरीक्षण करें।" },
          {'text': "बाएं पलड़े से 4 गोल्ड क्यूब्स को लाल 'एलिमिनेटर ज़ोन' में खींचें।", 'hud': "बाएं पलड़े से 4 गोल्ड क्यूब्स को ज़ोन में खींचें।" },
          {'text': "पैमाना असंतुलित है! संतुलन बहाल करने के लिए, आपको दूसरी तरफ भी वही क्रिया करनी होगी। दाएं पलड़े से 4 गोल्ड क्यूब्स को 'एलिमिनेटर ज़ोन' में खींचें।", 'hud': "दाएं पलड़े से 4 गोल्ड क्यूब्स को ज़ोन में खींचें।" },
          {'text': "अब, हमारे पास 6 गोल्ड क्यूब्स द्वारा संतुलित 2 मिस्ट्री बॉक्स हैं। एक बॉक्स का वजन खोजने के लिए, हमें दोनों पक्षों को विभाजित करना होगा। 'डिवाइड टूल' (÷) को बाएं पैन पर खींचें।", 'hud': "डिवाइड टूल को बाएं पैन पर खींचें।" },
          {'text': "बढ़िया! अब दूसरी तरफ भी ऐसा ही करें। डिवाइड टूल को दाएं पैन पर खींचें।", 'hud': "डिवाइड टूल को दाएं पैन पर खींचें।" },
          {'text': "पैमाना दिखाता है कि 1 मिस्ट्री बॉक्स 3 गोल्ड क्यूब्स द्वारा पूरी तरह से संतुलित है। आपने अज्ञात को खोज लिया है!", 'hud': "समीकरण हल हुआ: x = 3!" }
        ]
      },
      {
        'title': "2. दो पक्षों की कहानी",
        'objective': "अज्ञात वजन का पता लगाना जब रहस्य बक्से पैमाने के दोनों किनारों पर हों।",
        'steps': [
          {'text': "सेटअप का निरीक्षण करें। बाएं पैन में 4 मिस्ट्री बॉक्स और 3 गोल्ड क्यूब्स हैं। दाएं पैन में 2 मिस्ट्री बॉक्स और 9 गोल्ड क्यूब्स हैं।", 'hud': "4x + 3 = 2x + 9 के प्रारंभिक सेटअप का निरीक्षण करें।" },
          {'text': "आइए दाएं पैन से मिस्ट्री बॉक्स हटा दें। दाएं पैन से 2 मिस्ट्री बॉक्स को एलिमिनेटर ज़ोन में खींचें।", 'hud': "दाएं पैन से 2 मिस्ट्री बॉक्स हटा दें।" },
          {'text': "पैमाने को संतुलित करें! दूसरी तरफ की गई कार्रवाई से मिलान करने के लिए बाएं पैन से 2 मिस्ट्री बॉक्स को एलिमिनेटर ज़ोन में खींचें।", 'hud': "बाएं पैन से 2 मिस्ट्री बॉक्स हटा दें।" },
          {'text': "यह परिचित लगता है! अब, मिस्ट्री बॉक्स को अलग करें। बाएं पैन से 3 गोल्ड क्यूब्स को एलिमिनेटर ज़ोन में खींचें, और फिर फिर से संतुलित करने के लिए दाएं पैन पर 3 गोल्ड क्यूब्स के लिए भी ऐसा ही करें।", 'hud': "बक्सों को अलग करने के लिए दोनों पैन से 3 गोल्ड क्यूब्स हटा दें।" },
          {'text': "अंत में, 'डिवाइड टूल' का उपयोग करें। एकल मिस्ट्री बॉक्स का मूल्य खोजने के लिए उपकरण को दोनों पैन पर खींचें।", 'hud': "दोनों पैन पर डिवाइड टूल का उपयोग करें।" },
          {'text': "सफलता! दोनों पक्षों को 2 से विभाजित किया गया है, जिससे पता चलता है कि 1 मिस्ट्री बॉक्स 3 गोल्ड क्यूब्स के बराबर है।", 'hud': "समीकरण हल हुआ: x = 3!" }
        ]
      },
      {
        'title': "3. समूहों को खोलना",
        'objective': "समूहों को 'खोलकर' वितरण संपत्ति से जुड़े समीकरण को हल करना।",
        'steps': [
          {'text': "पैमाने का निरीक्षण करें। बाएं पैन पर 3 पारदर्शी 'बैग' हैं। प्रत्येक बैग के अंदर 1 मिस्ट्री बॉक्स और 2 गोल्ड क्यूब्स हैं। दाएं पैन में 12 गोल्ड क्यूब्स हैं।", 'hud': "पारदर्शी बैग का निरीक्षण करें।" },
          {'text': "वस्तुओं के साथ काम करने के लिए, हमें पहले बैग खोलने होंगे। सामग्री जारी करने के लिए बाएं पैन पर 3 बैग में से प्रत्येक पर क्लिक करें।", 'hud': "उन्हें खोलने के लिए 3 बैग पर क्लिक करें।" },
          {'text': "अब यह एक मानक समस्या है। बाएं पैन से 6 गोल्ड क्यूब्स हटाकर मिस्ट्री बॉक्स को अलग करें।", 'hud': "बाएं पैन से 6 गोल्ड क्यूब्स को ज़ोन में खींचें।" },
          {'text': "दाएं पैन से 6 गोल्ड क्यूब्स हटाकर भी पैमाने को संतुलित रखें।", 'hud': "दाएं पैन से 6 गोल्ड क्यूब्स को ज़ोन में खींचें।" },
          {'text': "एक मिस्ट्री बॉक्स का वजन खोजने के लिए दोनों पक्षों को 3 समान समूहों में विभाजित करने के लिए 'डिवाइड टूल' का उपयोग करें।", 'hud': "दोनों पैन पर डिवाइड टूल का उपयोग करें।" },
          {'text': "सफलता! बैग खोलने से हमें समीकरण हल करने में मदद मिली।", 'hud': "समीकरण हल हुआ: x = 2!" }
        ]
      },
      {
        'title': "4. विशेषज्ञ बैलेंसर",
        'objective': "चरण-दर-चरण संकेतों के बिना समीकरण 5x + 2 = 3x + 10 को हल करने के लिए सभी सीखे गए कौशल लागू करें।",
        'steps': [
          {'text': "यहाँ आपकी चुनौती है। बाएं पलड़े पर 5 मिस्ट्री बॉक्स और 2 गोल्ड क्यूब्स हैं। दाएं पलड़े पर 3 मिस्ट्री बॉक्स और 10 गोल्ड क्यूब्स हैं। हल करने के लिए डिस्कार्ड ज़ोन और डिवाइड टूल का उपयोग करें।", 'hud': "उपकरणों का उपयोग करके समीकरण को हल करें।" },
          {'text': "मिस्ट्री बॉक्स का मूल्य ज्ञात करने के लिए उसे अलग करें। एक बार जब पैमाना एक मिस्ट्री बॉक्स का मूल्य दिखाता है, तो 'उत्तर जांचें' बटन पर क्लिक करें।", 'hud': "जब आप एक बॉक्स को अलग कर लें तो उत्तर जांचें पर क्लिक करें।" },
          {'text': "बहुत बढ़िया! आपने स्वतंत्र रूप से समीकरण को हल किया। आपने मिस्ट्री बॉक्स को सफलतापूर्वक अलग कर दिया है और पाया है कि x = 4।", 'hud': "चुनौती पूर्ण: x = 4!" }
        ]
      },
      {
        'title': "5. एंटी-ग्रेविटी चुनौती",
        'objective': "शून्य जोड़े की अवधारणा का उपयोग करके नकारात्मक स्थिरांक वाले समीकरण को हल करना।",
        'steps': [
          {'text': "एक नई चुनौती! बाएं पैन में 3 मिस्ट्री बॉक्स और 4 लाल 'हीलियम गुब्बारे' (-1 प्रत्येक) हैं। दाएं पैन में 5 गोल्ड क्यूब्स हैं।", 'hud': "तैरते हुए गुब्बारों का निरीक्षण करें।" },
          {'text': "-4 गुब्बारों से छुटकारा पाने के लिए, +4 जोड़कर उन्हें रद्द करें। आपूर्ति क्रेट से 4 गोल्ड क्यूब्स को बाएं पैन में खींचें।", 'hud': "गुब्बारों को फोड़ने के लिए क्रेट से 4 क्यूब्स बाएं पैन में खींचें।" },
          {'text': "पैमाना असंतुलित है! इसे फिर से संतुलित करने के लिए, आपको दाईं ओर क्या करना चाहिए?", 'hud': "आपूर्ति क्रेट का उपयोग करके पैमाने को संतुलित करें।" },
          {'text': "आप अंतिम चरण में हैं! अंतिम उत्तर खोजने के लिए डिवाइड टूल का उपयोग करें और 'उत्तर जांचें' पर क्लिक करें।", 'hud': "हल करें और उत्तर जांचें पर क्लिक करें।" },
          {'text': "शानदार! आपने एक जटिल समीकरण को हल करने के लिए शून्य जोड़े का उपयोग किया।", 'hud': "अंतिम चुनौती पूर्ण: x = 3!" }
        ]
      }
    ]
  }
};

// --- Main Screen ---

class SolvingMultiStepEquationsScreen extends StatefulWidget {
  const SolvingMultiStepEquationsScreen({super.key});

  @override
  State<SolvingMultiStepEquationsScreen> createState() => _SolvingMultiStepEquationsScreenState();
}

class _SolvingMultiStepEquationsScreenState extends State<SolvingMultiStepEquationsScreen>
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
  int currentDivisor = 0;
  int groupsCount = 1;
  bool isZoomed = false;
  String preDivideLeftStr = "";
  String preDivideRightStr = "";
  
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
  void _playPop() => _successPlayer.play(AssetSource('audio/class7/mixkit_2568.mp3')); // Using click as pop

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
    return ["2x + 4 = 10", "4x + 3 = 2x + 9", "3(x + 2) = 12", "5x + 2 = 3x + 10", "3x - 4 = 5"][scenIdx];
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
    currentDivisor = 0;
    isZoomed = false;
    groupsCount = 1;
    beamAngle = 0;
    targetBeamAngle = 0;
    tempHintMsg = null;
    
    List<double> weights = [3, 3, 2, 4, 3];
    boxTrueWeight = weights[index];

    if (index == 0) { // S1: 2x + 4 = 10
      for(int i=0; i<2; i++) entities.add(GameEntity(id: 'bL$i', type: 'box', pan: 'left', isRevealed: false));
      for(int i=0; i<4; i++) entities.add(GameEntity(id: 'cL$i', type: 'cube', pan: 'left'));
      for(int i=0; i<10; i++) entities.add(GameEntity(id: 'cR$i', type: 'cube', pan: 'right'));
      entities.add(GameEntity(id: 'div', type: 'divide_tool', x: 0, y: -180, isHidden: true));
    } else if (index == 1) { // S2: 4x + 3 = 2x + 9
      for(int i=0; i<4; i++) entities.add(GameEntity(id: 'bL$i', type: 'box', pan: 'left'));
      for(int i=0; i<3; i++) entities.add(GameEntity(id: 'cL$i', type: 'cube', pan: 'left'));
      for(int i=0; i<2; i++) entities.add(GameEntity(id: 'bR$i', type: 'box', pan: 'right', isDraggable: true, glow: true));
      for(int i=0; i<9; i++) entities.add(GameEntity(id: 'cR$i', type: 'cube', pan: 'right'));
      entities.add(GameEntity(id: 'div', type: 'divide_tool', x: 0, y: -180, isHidden: true));
    } else if (index == 2) { // S3: 3(x + 2) = 12
      for(int i=0; i<3; i++) {
        var bag = GameEntity(id: 'bag$i', type: 'bag', pan: 'left', isDraggable: false);
        bag.onClick = () { _clickBag(bag); };
        entities.add(bag);
      }
      for(int i=0; i<12; i++) entities.add(GameEntity(id: 'cR$i', type: 'cube', pan: 'right'));
      entities.add(GameEntity(id: 'div', type: 'divide_tool', x: 0, y: -180, isHidden: true));
    } else if (index == 3) { // S4: 5x + 2 = 3x + 10
      for(int i=0; i<5; i++) entities.add(GameEntity(id: 'bL$i', type: 'box', pan: 'left', isDraggable: true));
      for(int i=0; i<2; i++) entities.add(GameEntity(id: 'cL$i', type: 'cube', pan: 'left', isDraggable: true));
      for(int i=0; i<3; i++) entities.add(GameEntity(id: 'bR$i', type: 'box', pan: 'right', isDraggable: true));
      for(int i=0; i<10; i++) entities.add(GameEntity(id: 'cR$i', type: 'cube', pan: 'right', isDraggable: true));
      entities.add(GameEntity(id: 'div', type: 'divide_tool', x: 0, y: -180, isDraggable: true));
    } else if (index == 4) { // S5: 3x - 4 = 5
      for(int i=0; i<3; i++) entities.add(GameEntity(id: 'bL$i', type: 'box', pan: 'left', isDraggable: true));
      for(int i=0; i<4; i++) entities.add(GameEntity(id: 'bal$i', type: 'balloon', pan: 'left', val: -1));
      for(int i=0; i<5; i++) entities.add(GameEntity(id: 'cR$i', type: 'cube', pan: 'right', isDraggable: true));
      entities.add(GameEntity(id: 'crate', type: 'crate', x: -220, y: 240, isDraggable: true));
      entities.add(GameEntity(id: 'div', type: 'divide_tool', x: 0, y: -180, isDraggable: true));
    }

    currentEquation = _getInitialEquation(index);
    _calculateWeights();
  }

  void _clickBag(GameEntity bag) {
    _playPop();
    setState(() {
      bag.isHidden = true;
      bag.isDisposing = true;
      bag.pan = null;
      _createParticles(bag.x, bag.y, Colors.white);
      
      entities.add(GameEntity(id: 'b_${bag.id}', type: 'box', pan: 'left', x: bag.x, y: bag.y));
      entities.add(GameEntity(id: 'c1_${bag.id}', type: 'cube', pan: 'left', x: bag.x - 20, y: bag.y + 20));
      entities.add(GameEntity(id: 'c2_${bag.id}', type: 'cube', pan: 'left', x: bag.x + 20, y: bag.y + 20));
      
      _calculateWeights();
      _evaluateScenarioState();
    });
  }

  String _buildSideStr(String pan) {
    int b = entities.where((e) => e.pan == pan && e.type == 'box' && !e.isHidden && !e.isDisposing).length;
    int c = entities.where((e) => e.pan == pan && e.type == 'cube' && !e.isHidden && !e.isDisposing).length;
    int bg = entities.where((e) => e.pan == pan && e.type == 'bag' && !e.isHidden && !e.isDisposing).length;
    int bal = entities.where((e) => e.pan == pan && e.type == 'balloon' && !e.isHidden && !e.isDisposing).length;
    
    List<String> parts = [];
    if (bg > 0) parts.add("$bg(x + 2)");
    if (b > 0) parts.add(b == 1 ? "x" : "${b}x");
    if (c > 0) parts.add("$c");
    if (bal > 0) parts.add("- $bal");
    
    if (parts.isEmpty) return "0";
    String res = parts.join(" + ");
    res = res.replaceAll("+ -", "- ");
    return res;
  }

  void _calculateWeights() {
    if (isZoomed) return;
    leftWeight = 0;
    rightWeight = 0;

    for (var e in entities) {
      if (e.isHidden || e.isDisposing || (e.pan == null && e != draggedEntity)) continue;
      String? p = e.pan;
      if (e == draggedEntity) p = originalPan;
      
      double w = 0;
      if (e.type == 'box') w = boxTrueWeight;
      else if (e.type == 'cube') w = 1;
      else if (e.type == 'bag') w = boxTrueWeight + 2;
      else if (e.type == 'balloon') w = -1;

      if (p == 'left') leftWeight += w;
      if (p == 'right') rightWeight += w;
    }

    double diff = rightWeight - leftWeight;
    if (currentDivisor > 0 || forceBalance) {
      diff = 0;
    }
    targetBeamAngle = max(-0.25, min(0.25, diff * 0.05));

    if ((_isBalanced() || currentDivisor > 0 || forceBalance) && draggedEntity == null && entities.every((e) => !e.isReturning)) {
      _updateEquationDisplay();
    }
  }

  bool _isBalanced() {
    return (leftWeight - rightWeight).abs() < 0.1;
  }

  void _updateEquationDisplay() {
    String left = _buildSideStr('left');
    String right = _buildSideStr('right');
    String eqSign = (_isBalanced() || currentDivisor > 0 || forceBalance) ? "=" : "≠";

    if (currentDivisor > 0) {
      if (dividedLeft && !dividedRight) {
        left = "($preDivideLeftStr) / $currentDivisor";
        right = preDivideRightStr;
      } else if (!dividedLeft && dividedRight) {
        left = preDivideLeftStr;
        right = "($preDivideRightStr) / $currentDivisor";
      }
    }

    String newEq = "$left $eqSign $right";
    currentEquation = newEq;
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
        var unitsOnThisSide = rightItems.where((u) => u.type == 'cube').toList();
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
        var unitsOnThisSide = leftItems.where((u) => u.type == 'cube').toList();
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
      var cubes = items.where((e) => e.type == 'cube').toList();
      var bags = items.where((e) => e.type == 'bag').toList();
      var balloons = items.where((e) => e.type == 'balloon').toList();
      
      double yOffset = panY - 15;

      for (int i = 0; i < boxes.length; i++) {
        int row = i ~/ 2;
        double colOffset = (i == boxes.length - 1 && boxes.length % 2 != 0) ? 0 : (i % 2 == 0 ? -18 : 18);
        boxes[i].panTargetX = panCenterX + colOffset;
        boxes[i].panTargetY = yOffset - (row * 35);
        if (boxes[i].x == 0 && boxes[i].y == 0) { boxes[i].x = boxes[i].panTargetX; boxes[i].y = boxes[i].panTargetY; }
      }
      if (boxes.isNotEmpty) yOffset -= ((boxes.length + 1) ~/ 2) * 35;

      for (int i = 0; i < bags.length; i++) {
        int row = i ~/ 2;
        double colOffset = (i == bags.length - 1 && bags.length % 2 != 0) ? 0 : (i % 2 == 0 ? -22 : 22);
        bags[i].panTargetX = panCenterX + colOffset;
        bags[i].panTargetY = yOffset - (row * 45);
        if (bags[i].x == 0 && bags[i].y == 0) { bags[i].x = bags[i].panTargetX; bags[i].y = bags[i].panTargetY; }
      }
      if (bags.isNotEmpty) yOffset -= ((bags.length + 1) ~/ 2) * 45;

      for (int i = 0; i < cubes.length; i++) {
        int row = i ~/ 3;
        int col = i % 3;
        int itemsInThisRow = min(3, cubes.length - row * 3);
        double colOffset = itemsInThisRow == 1 ? 0 : (itemsInThisRow == 2 ? (col == 0 ? -15 : 15) : (col - 1) * 22.0);
        cubes[i].panTargetX = panCenterX + colOffset;
        cubes[i].panTargetY = yOffset - (row * 24);
        if (cubes[i].x == 0 && cubes[i].y == 0) { cubes[i].x = cubes[i].panTargetX; cubes[i].y = cubes[i].panTargetY; }
      }

      for (int i = 0; i < balloons.length; i++) {
        double colOffset = (i - (balloons.length - 1) / 2) * 20;
        balloons[i].panTargetX = panCenterX + colOffset;
        balloons[i].panTargetY = panY - 100 + sin(animationTime * 2 + i) * 5;
        if (balloons[i].x == 0 && balloons[i].y == 0) { balloons[i].x = balloons[i].panTargetX; balloons[i].y = balloons[i].panTargetY; }
      }
    }

    posItems(leftItems, -150, leftPanY, true);
    posItems(rightItems, 150, rightPanY, false);
  }

  int _countEntities(String pan, String type) {
    return entities.where((e) => e.pan == pan && e.type == type && !e.isHidden && !e.isDisposing).length;
  }

  void _evaluateScenarioState() {
    if (isAdvancing) return;
    var scen = i18n[lang]['scenarios'][currentScenario];
    if (currentStep == scen['steps'].length - 1) return;

    if (currentScenario == 0) {
      if (currentStep == 0) {
        isAdvancing = true; Future.delayed(const Duration(milliseconds: 2000), _advanceStep);
      } else if (currentStep == 1) {
        if (_countEntities('left', 'cube') == 0) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep); }
      } else if (currentStep == 2) {
        if (_countEntities('right', 'cube') == 6 && _isBalanced()) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep); }
      } else if (currentStep == 3) {
        if (dividedLeft) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep); }
      } else if (currentStep == 4) {
        if (dividedRight) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep); }
      }
    } else if (currentScenario == 1) {
      if (currentStep == 0) {
        isAdvancing = true; Future.delayed(const Duration(milliseconds: 2000), _advanceStep);
      } else if (currentStep == 1) {
        if (_countEntities('right', 'box') == 0) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep); }
      } else if (currentStep == 2) {
        if (_countEntities('left', 'box') == 2 && _isBalanced()) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep); }
      } else if (currentStep == 3) {
        if (_countEntities('left', 'cube') == 0 && _countEntities('right', 'cube') == 9) {
          int c = 0;
          for (var e in entities) {
            if (e.pan == 'right' && e.type == 'cube' && !e.isHidden && !e.isDraggable && c < 3) {
              e.isDraggable = true; e.glow = true; c++;
            }
          }
        }
        if (_countEntities('left', 'cube') == 0 && _countEntities('right', 'cube') == 6 && _isBalanced()) {
          isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep);
        }
      } else if (currentStep == 4) {
        if (dividedLeft && dividedRight) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep); }
      }
    } else if (currentScenario == 2) {
      if (currentStep == 0) {
        isAdvancing = true; Future.delayed(const Duration(milliseconds: 2000), _advanceStep);
      } else if (currentStep == 1) {
        if (_countEntities('left', 'bag') == 0) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep); }
      } else if (currentStep == 2) {
        if (_countEntities('left', 'cube') == 0) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep); }
      } else if (currentStep == 3) {
        if (_countEntities('right', 'cube') == 6 && _isBalanced()) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep); }
      } else if (currentStep == 4) {
        if (dividedLeft && dividedRight) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep); }
      }
    } else if (currentScenario == 3) {
      if (currentStep == 0) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 2000), _advanceStep); }
    } else if (currentScenario == 4) {
      if (currentStep == 0) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 2000), _advanceStep); }
      else if (currentStep == 1) { if (_countEntities('left', 'balloon') == 0) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep); } }
      else if (currentStep == 2) { if (_countEntities('right', 'cube') == 9 && _isBalanced()) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _advanceStep); } }
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
            for (var e in entities) { if (e.pan == 'left' && e.type == 'cube') { e.isDraggable = true; e.glow = true; } }
          } else if (currentStep == 2) {
            int c = 0; for (var e in entities) { if (e.pan == 'right' && e.type == 'cube' && !e.isHidden && c < 4) { e.isDraggable = true; e.glow = true; c++; } }
          } else if (currentStep == 3) {
            var divTool = entities.where((e) => e.type == 'divide_tool').firstOrNull;
            if (divTool != null) { divTool.isHidden = false; divTool.isDraggable = true; divTool.glow = true; }
            for (var e in entities) { if (e.type == 'cube') { e.isDraggable = false; e.glow = false; } }
          } else if (currentStep == 5) {
            for (var e in entities) { if (e.type == 'box') { e.isRevealed = true; _createParticles(e.x, e.y, const Color(0xFF10B981)); } }
          }
        } else if (currentScenario == 1) {
          if (currentStep == 1) {
            int c = 0; for (var e in entities) { if (e.pan == 'right' && e.type == 'box' && !e.isHidden && c < 2) { e.isDraggable = true; e.glow = true; c++; } }
          } else if (currentStep == 2) {
            int c = 0; for (var e in entities) { if (e.pan == 'left' && e.type == 'box' && !e.isHidden && c < 2) { e.isDraggable = true; e.glow = true; c++; } }
          } else if (currentStep == 3) {
            int c = 0; for (var e in entities) { if (e.pan == 'left' && e.type == 'cube' && !e.isHidden && c < 3) { e.isDraggable = true; e.glow = true; c++; } }
          } else if (currentStep == 4) {
            var divTool = entities.where((e) => e.type == 'divide_tool').firstOrNull;
            if (divTool != null) { divTool.isHidden = false; divTool.isDraggable = true; divTool.glow = true; }
          } else if (currentStep == 6) {
            for (var e in entities) { if (e.type == 'box') { e.isRevealed = true; _createParticles(e.x, e.y, const Color(0xFF10B981)); } }
          }
        } else if (currentScenario == 2) {
          if (currentStep == 1) {
            for (var e in entities) { if (e.type == 'bag') e.glow = true; }
          } else if (currentStep == 2) {
            int c = 0; for (var e in entities) { if (e.pan == 'left' && e.type == 'cube' && !e.isHidden && c < 6) { e.isDraggable = true; e.glow = true; c++; } }
          } else if (currentStep == 3) {
            int c = 0; for (var e in entities) { if (e.pan == 'right' && e.type == 'cube' && !e.isHidden && c < 6) { e.isDraggable = true; e.glow = true; c++; } }
          } else if (currentStep == 4) {
            var divTool = entities.where((e) => e.type == 'divide_tool').firstOrNull;
            if (divTool != null) { divTool.isHidden = false; divTool.isDraggable = true; divTool.glow = true; }
          } else if (currentStep == 5) {
            for (var e in entities) { if (e.type == 'box') { e.isRevealed = true; _createParticles(e.x, e.y, const Color(0xFF10B981)); } }
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

    int bL = _countEntities('left', 'box');
    int cL = _countEntities('left', 'cube');
    int balL = _countEntities('left', 'balloon');
    int bgL = _countEntities('left', 'bag');
    
    int bR = _countEntities('right', 'box');
    int cR = _countEntities('right', 'cube');
    int balR = _countEntities('right', 'balloon');
    int bgR = _countEntities('right', 'bag');

    bool isolatedLeft = (bL == 1 && cL == 0 && balL == 0 && bgL == 0 && bR == 0 && cR > 0 && balR == 0 && bgR == 0);
    bool isolatedRight = (bR == 1 && cR == 0 && balR == 0 && bgR == 0 && bL == 0 && cL > 0 && balL == 0 && bgL == 0);

    if (isolatedLeft || isolatedRight) {
      _playSuccess();
      setState(() {
        for (var e in entities) { if (e.type == 'box') { e.isRevealed = true; _createParticles(e.x, e.y, const Color(0xFF10B981)); } }
        for (int i = 0; i < 50; i++) {
          _createParticles((Random().nextDouble() - 0.5) * 600, (Random().nextDouble() - 0.5) * 200, Colors.amber);
        }
        isAdvancing = true;
        var scen = tr['scenarios'][currentScenario];
        currentStep = scen['steps'].length - 2; 
        _advanceStep();
      });
    } else {
      _playError();
      if (bL > 1 || bR > 1) {
        _showHint(tr['msgDivBoxFirst']);
      } else {
        _showHint(tr['msgNotIsolated']);
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
      if (ent.type == 'crate') {
        hit = (worldPos.dx >= ent.x - 70 && worldPos.dx <= ent.x + 70 && worldPos.dy >= ent.y - 70 && worldPos.dy <= ent.y + 60);
      } else if (ent.type == 'box') {
        hit = (worldPos.dx >= ent.x - 50 && worldPos.dx <= ent.x + 50 && worldPos.dy >= ent.y - 50 && worldPos.dy <= ent.y + 50);
      } else if (ent.type == 'cube') {
        hit = (worldPos.dx >= ent.x - 40 && worldPos.dx <= ent.x + 40 && worldPos.dy >= ent.y - 40 && worldPos.dy <= ent.y + 40);
      } else if (ent.type == 'divide_tool') {
        hit = (sqrt(pow(ent.x - worldPos.dx, 2) + pow(ent.y - worldPos.dy, 2)) < 55);
      } else if (ent.type == 'bag') {
        hit = (worldPos.dx >= ent.x - 45 && worldPos.dx <= ent.x + 45 && worldPos.dy >= ent.y - 50 && worldPos.dy <= ent.y + 50);
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
        if (ent.isHidden || (!ent.isDraggable && ent.onClick == null)) continue;

        bool hit = false;
        if (ent.type == 'crate') {
          hit = (worldPos.dx >= ent.x - 70 && worldPos.dx <= ent.x + 70 && worldPos.dy >= ent.y - 70 && worldPos.dy <= ent.y + 60);
        } else if (ent.type == 'box') {
          hit = (worldPos.dx >= ent.x - 50 && worldPos.dx <= ent.x + 50 && worldPos.dy >= ent.y - 50 && worldPos.dy <= ent.y + 50);
        } else if (ent.type == 'cube') {
          hit = (worldPos.dx >= ent.x - 40 && worldPos.dx <= ent.x + 40 && worldPos.dy >= ent.y - 40 && worldPos.dy <= ent.y + 40);
        } else if (ent.type == 'divide_tool') {
          hit = (sqrt(pow(ent.x - worldPos.dx, 2) + pow(ent.y - worldPos.dy, 2)) < 55);
        } else if (ent.type == 'bag') {
          hit = (worldPos.dx >= ent.x - 45 && worldPos.dx <= ent.x + 45 && worldPos.dy >= ent.y - 50 && worldPos.dy <= ent.y + 50);
        }

        if (hit) {
          if (ent.type == 'crate') {
            _playPop();
            setState(() {
              var newCube = GameEntity(id: 'c_spawn_${DateTime.now().millisecondsSinceEpoch}', type: 'cube', pan: null, x: worldPos.dx, y: worldPos.dy, isDraggable: true);
              entities.add(newCube);
              originalPan = 'crate';
              draggedEntity = newCube;
              dragOffsetX = 0;
              dragOffsetY = 0;
              _calculateWeights();
            });
            return;
          }
          if (ent.onClick != null && !ent.isDraggable) {
            _playClick();
            setState(() { ent.onClick!(); });
            return;
          }
          if (ent.isDraggable) {
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
          if (worldPos.dx >= -120 && worldPos.dx <= 120 && worldPos.dy >= 200 && worldPos.dy <= 340) hoverZone = 'bin';
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

  bool _attemptDivide(String pan) {
    int boxes = _countEntities(pan, 'box');
    int cubes = _countEntities(pan, 'cube');
    int bags = _countEntities(pan, 'bag');
    int balloons = _countEntities(pan, 'balloon');

    if (bags > 0 || balloons > 0) {
      _showHint("Simplify the items first before dividing!");
      return false;
    }

    if (currentDivisor > 0) {
      if (pan == 'left' && dividedLeft) return false;
      if (pan == 'right' && dividedRight) return false;

      if (boxes % currentDivisor == 0 && cubes % currentDivisor == 0) {
        _dividePan(pan, currentDivisor);
        if (pan == 'left') dividedLeft = true;
        if (pan == 'right') dividedRight = true;
        
        if (dividedLeft && dividedRight) {
          currentDivisor = 0;
          var dTool = entities.where((e) => e.type == 'divide_tool').firstOrNull;
          if (dTool != null) dTool.glow = false;
        }
        return true;
      } else {
        _showHint("Cannot divide evenly by $currentDivisor");
        return false;
      }
    } else {
      int div = boxes;
      if (div > 1 && cubes % div == 0) {
        currentDivisor = div;
        preDivideLeftStr = _buildSideStr('left');
        preDivideRightStr = _buildSideStr('right');
        _dividePan(pan, div);
        if (pan == 'left') dividedLeft = true;
        if (pan == 'right') dividedRight = true;
        return true;
      } else if (div <= 1) {
        _showHint(i18n[lang]['msgDivBoxFirst']);
        return false;
      } else {
        _showHint("The Gold Cubes cannot be divided evenly.");
        return false;
      }
    }
  }

  void _dividePan(String pan, int divisor) {
    var boxes = entities.where((e) => e.pan == pan && e.type == 'box' && !e.isHidden && !e.isDisposing).toList();
    var cubes = entities.where((e) => e.pan == pan && e.type == 'cube' && !e.isHidden && !e.isDisposing).toList();
    int keepBoxes = boxes.length ~/ divisor;
    int keepCubes = cubes.length ~/ divisor;
    
    for (int i = keepBoxes; i < boxes.length; i++) {
      boxes[i].isDisposing = true;
      boxes[i].disposeTargetX = (Random().nextDouble() - 0.5) * 60;
      boxes[i].disposeTargetY = 260;
    }
    for (int i = keepCubes; i < cubes.length; i++) {
      cubes[i].isDisposing = true;
      cubes[i].disposeTargetX = (Random().nextDouble() - 0.5) * 60;
      cubes[i].disposeTargetY = 260;
    }
    _calculateWeights();
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (draggedEntity != null) {
      var ent = draggedEntity!;
      double wX = ent.x; double wY = ent.y;
      
      bool droppedOnBin = (wX >= -120 && wX <= 120 && wY >= 200 && wY <= 340);
      bool droppedOnLeft = (wX >= -240 && wX <= -60 && wY >= -50 && wY <= 180);
      bool droppedOnRight = (wX >= 60 && wX <= 240 && wY >= -50 && wY <= 180);

      setState(() {
        if (ent.type == 'divide_tool') {
          bool validDrop = false;
          if (droppedOnLeft) validDrop = _attemptDivide('left');
          else if (droppedOnRight) validDrop = _attemptDivide('right');

          if (validDrop) {
            _playClick();
            _createParticles(wX, wY, Colors.lightBlueAccent);
            ent.x = ent.homeX ?? 0; ent.y = ent.homeY ?? -180;
            
            if (dividedLeft && dividedRight) {
              forceBalance = true;
              Future.delayed(const Duration(milliseconds: 500), () {
                setState(() {
                  _playSuccess();
                  forceBalance = false;
                  _updateEquationDisplay();
                  _evaluateScenarioState();
                  if (currentScenario < 3) {
                    for (var e in entities) {
                      if (e.type == 'box') { e.isRevealed = true; _createParticles(e.x, e.y, const Color(0xFF10B981)); }
                    }
                  }
                });
              });
            } else {
              _updateEquationDisplay();
              _evaluateScenarioState();
            }
          } else {
            _playError();
            ent.isReturning = true;
            ent.returnStartX = ent.x; ent.returnStartY = ent.y;
            ent.targetX = ent.x - dragOffsetX; 
            ent.targetY = ent.y - dragOffsetY;
            ent.returnProgress = 0;
          }
        } else if (ent.type == 'cube' && originalPan == 'crate') {
          if (droppedOnLeft || droppedOnRight) {
            String panStr = droppedOnLeft ? 'left' : 'right';
            ent.pan = panStr;
            var balloons = entities.where((e) => e.pan == panStr && e.type == 'balloon' && !e.isHidden && !e.isDisposing).toList();
            if (balloons.isNotEmpty) {
              var b = balloons[0];
              b.isDisposing = true; b.disposeTargetX = ent.x; b.disposeTargetY = ent.y;
              ent.isDisposing = true; ent.disposeTargetX = b.x; ent.disposeTargetY = b.y;
              _playPop();
            } else {
              _playClick();
            }
            _calculateWeights();
            _evaluateScenarioState();
          } else {
            ent.isHidden = true;
            _playError();
          }
        } else {
          if (droppedOnBin) {
            if (currentScenario < 3) {
              _playClick();
              ent.isDisposing = true;
              ent.disposeTargetX = 0;
              ent.disposeTargetY = 260;
              ent.pan = null;
              _calculateWeights();
              Future.delayed(const Duration(milliseconds: 800), _evaluateScenarioState);
            } else {
              _playClick();
              ent.isDisposing = true;
              ent.disposeTargetX = 0;
              ent.disposeTargetY = 260;
              ent.pan = null;
              _calculateWeights();
              _evaluateScenarioState();
            }
          } else if (droppedOnLeft || droppedOnRight) {
            _playClick();
            ent.pan = droppedOnLeft ? 'left' : 'right';
            _calculateWeights();
            _evaluateScenarioState();
          } else {
            _playError();
            ent.isReturning = true;
            ent.returnStartX = ent.x;
            ent.returnStartY = ent.y;
            ent.targetX = ent.x - dragOffsetX; 
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
      camY = isZoomed ? 0 : -60; 
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

                      // Mini Toolbar (Zoom)
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
                                maxWidth: constraints.maxWidth * 0.7,
                                maxHeight: constraints.maxHeight * 0.4,
                              ),
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                                                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    scen['steps'][currentStep]['hud'],
                                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              scen['steps'][currentStep]['text'].replaceAll('**', ''),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 12, color: Colors.white70),
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
                                            if ((currentScenario == 3 && currentStep == 1) || (currentScenario == 4 && currentStep == 3))
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
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
                                              ),
                                          ],
                                        ),
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
                              
                              // Inline Check Answer Button when appropriate
                              if ((currentScenario == 3 && currentStep == 1) || (currentScenario == 4 && currentStep == 3))
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
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
    // Bin / Eliminator
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

    _drawText(canvas, tr['msgDiscard'] ?? "ELIMINATOR ZONE", const Color(0xFFCBD5E1), 12, dy: 45);

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
      if (isZoomed && ent.type == 'cube') {
        continue;
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
          canvas.drawRRect(RRect.fromLTRBR(-15, -15, 15, 15, const Radius.circular(4)), Paint()..color = Colors.black45);
          canvas.scale(0.6, 0.6);
          for (int i = 0; i < boxTrueWeight; i++) {
            canvas.save();
            canvas.translate((i % 2) * 20.0 - 10.0, (i ~/ 2) * 20.0 - 10.0);
            _drawCube(canvas);
            canvas.restore();
          }
        } else {
          canvas.scale(1.6, 1.6);
          var paint = Paint()..color = const Color(0xFF6366F1);
          canvas.drawRRect(RRect.fromLTRBR(-12, -12, 12, 12, const Radius.circular(3)), paint);
          paint.color = Colors.white;
          paint.style = PaintingStyle.stroke; paint.strokeWidth = 1.5;
          canvas.drawRRect(RRect.fromLTRBR(-12, -12, 12, 12, const Radius.circular(3)), paint);
          paint.style = PaintingStyle.fill;
          _drawText(canvas, "x", Colors.white, 16, dy: 1);
        }
      } else if (ent.type == 'cube') {
        canvas.scale(1.3, 1.3);
        _drawCube(canvas);
      } else if (ent.type == 'bag') {
        canvas.drawRRect(RRect.fromLTRBR(-22, -25, 22, 25, const Radius.circular(8)), Paint()..color = Colors.white.withOpacity(0.2)..style = PaintingStyle.fill);
        canvas.drawRRect(RRect.fromLTRBR(-22, -25, 22, 25, const Radius.circular(8)), Paint()..color = Colors.white.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 2);
        canvas.save();
        canvas.scale(0.5, 0.5);
        canvas.translate(0, -20);
        // Box
        canvas.save(); canvas.translate(-12, -12);
        canvas.drawRRect(RRect.fromLTRBR(-12, -12, 12, 12, const Radius.circular(3)), Paint()..color = const Color(0xFF6366F1));
        canvas.drawRRect(RRect.fromLTRBR(-12, -12, 12, 12, const Radius.circular(3)), Paint()..color = Colors.white..style=PaintingStyle.stroke..strokeWidth=1.5);
        _drawText(canvas, "x", Colors.white, 16, dy: 1);
        canvas.restore();
        // Cubes
        canvas.save(); canvas.translate(-3, 47); _drawCube(canvas); canvas.restore();
        canvas.save(); canvas.translate(27, 47); _drawCube(canvas); canvas.restore();
        canvas.restore();
        canvas.drawRRect(RRect.fromLTRBR(-10, -30, 10, -24, const Radius.circular(2)), Paint()..color = const Color(0xFF94A3B8));
      } else if (ent.type == 'balloon') {
        canvas.drawLine(const Offset(0, 15), const Offset(0, 50), Paint()..color = Colors.white.withOpacity(0.5)..strokeWidth = 1);
        var grad = Paint()..shader = const RadialGradient(colors: [Color(0xFFFCA5A5), Color(0xFFEF4444)], center: Alignment(-0.3, -0.3), radius: 0.8).createShader(const Rect.fromLTRB(-15, -15, 15, 15));
        canvas.drawCircle(Offset.zero, 15, grad);
        canvas.drawPath(Path()..moveTo(-4, 14)..lineTo(4, 14)..lineTo(0, 20)..close(), Paint()..color = const Color(0xFFEF4444));
        _drawText(canvas, "-1", Colors.white, 14, dy: 0);
      } else if (ent.type == 'crate') {
        canvas.drawRRect(RRect.fromLTRBR(-40, -25, 40, 25, const Radius.circular(4)), Paint()..color = const Color(0xFFB45309));
        canvas.drawRect(const Rect.fromLTRB(-40, -5, 40, 5), Paint()..color = const Color(0xFF78350F));
        _drawText(canvas, "CUBES", const Color(0xFFFEF08A), 12, dy: 15);
        canvas.save(); canvas.translate(-25, -35); canvas.scale(0.8, 0.8); _drawCube(canvas); canvas.restore();
        canvas.save(); canvas.translate(-5, -30); canvas.scale(0.8, 0.8); _drawCube(canvas); canvas.restore();
      } else if (ent.type == 'divide_tool') {
        canvas.drawCircle(Offset.zero, 20, Paint()..color = const Color(0xFF0F172A));
        canvas.drawCircle(Offset.zero, 20, Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 3);
        _drawText(canvas, "÷", const Color(0xFF38BDF8), 24, dy: 2);
      }

      canvas.restore();
    }
  }

  void _drawCube(Canvas canvas) {
    canvas.save();
    canvas.translate(-12, -12);
    var paint = Paint()..color = const Color(0xFFFACC15);
    Path p1 = Path()..moveTo(0,6)..lineTo(12,12)..lineTo(12,24)..lineTo(0,18)..close();
    Path p2 = Path()..moveTo(12,12)..lineTo(24,6)..lineTo(24,18)..lineTo(12,24)..close();
    Path p3 = Path()..moveTo(24,6)..lineTo(12,0)..lineTo(0,6)..lineTo(12,12)..close();
    canvas.drawPath(p1, paint);
    canvas.drawPath(p2, paint);
    canvas.drawPath(p3, paint);
    paint.color = Colors.white; paint.style = PaintingStyle.stroke; paint.strokeWidth = 1.5;
    Path p4 = Path()..moveTo(12,0)..lineTo(12,12)..moveTo(0,6)..lineTo(24,6)..moveTo(12,24)..lineTo(12,12)..moveTo(0,18)..lineTo(24,18);
    canvas.drawPath(p4, paint);
    canvas.restore();
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