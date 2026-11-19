// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AngleBisectionApp());
}

double hypot(double a, double b) => math.sqrt(a * a + b * b);

const Map<String, dynamic> translations = {
  'en': {
    'shutterTitle': 'Angle Bisection: The Art of the Perfect Split',
    'appSubtitle': 'Class 7 • CONSTRUCTIONS AND TILINGS',
    'enterLab': 'Enter Virtual Lab',
    'reset': 'Reset',
    'selectScenario': 'Select Scenario',
    'stepLabel': 'STEP',
    'missionObj': 'Mission Objective',
    'footer': '© ZeroScienceLab - Fall in love with math and Science',
    'hudDefault': 'Select a scenario to begin.',
    'btn_draw_arc': 'DRAW ARC',
    'btn_draw_line': 'DRAW LINE',
    'btnComplete': 'Complete Pattern',
    'btn_unfold': 'UNFOLD',
    'btn_ok': 'OK',
    'finalSuccessTitle': 'Mission: Achieved!',
    's2_hud': [
      "Step 1/4: Snap compass to Vertex V and draw an arc.",
      "Step 2/4: Snap compass to point A or B and draw an arc.",
      "Step 3/4: Snap compass to the other point and draw an arc.",
      "Step 4/4: Select Ruler, connect Vertex V to intersection C1.",
      "Step 1/3: Snap compass to point D or B and draw an arc.",
      "Step 2/3: Snap compass to the other point and draw an arc.",
      "Step 3/3: Select Ruler, connect Vertex V to intersection C2.",
      "Click 'Complete Pattern' to finish the design!"
    ],
    's3_hud': [
      "1/4: Select Compass, snap to P, and click DRAW ARC.",
      "2/4: Snap compass to path intersections and draw arcs.",
      "3/4: Snap compass to the other path intersection and draw arc.",
      "4/4: Select Ruler, align P with new arc intersection, and click DRAW LINE."
    ],
    'canvas': {
      'oldMill': "PATH TO OLD MILL",
      'ship': "PATH TO SUNKEN SHIP",
      'river': "RIVER",
      'eqLine': "LINE OF EQUAL DISTANCE",
      'north': "N",
      'found': "FOUND!",
      'symm': "Perfectly Symmetrical!",
      'confirmed': "Perpendicular Bisector confirmed.",
      'verified90': "Angle Verified: 90°",
      'verifiedLen': "Segments Verified: Equal Lengths"
    },
    'scenarios': [
      {
        'title': "1. The Perfect Pizza Slice",
        'objective': "To learn the fundamental steps of bisecting an acute angle by perfectly splitting a slice of pizza for two people.",
        'steps': [
          { 'text': "The vertex of the pizza slice is glowing. **DRAG** the compass pivot point and **SNAP** it onto the glowing vertex 'O'.", 'hud': "Drag the compass pivot to the pizza vertex." },
          { 'text': "The pencil end of the compass is adjustable. Drag the red handle to adjust radius. Then drag the pencil to draw an arc (or **CLICK 'DRAW ARC'**) to cut across both edges of the pizza slice.", 'hud': "Set radius and draw an arc to cut the crusts." },
          { 'text': "**DRAG** the compass pivot and **SNAP** it onto the new glowing point 'A' on the crust.", 'hud': "Move the compass to point 'A' on the crust." },
          { 'text': "Draw a new arc in the middle of the pizza slice.", 'hud': "Draw an arc from A in the middle of the slice." },
          { 'text': "Now, **DRAG** the compass pivot and **SNAP** it onto the other point 'B' on the crust. Do NOT change the compass radius. Draw another arc that intersects the one you just made.", 'hud': "Move the compass to point 'B' and draw an intersecting arc." },
          { 'text': "Select the **straightedge** tool. **SNAP** it to vertex 'O' and intersection point 'C'. Click **DRAW LINE**.", 'hud': "Use the straightedge to connect points O and C." }
        ]
      },
      {
        'title': "2. Building a Symmetrical Kite",
        'objective': "To apply the bisection skill to construct the central spine of a kite, ensuring its wings are symmetrical.",
        'steps': [
          { 'text': "You are given two kite spars forming an angle (∠XOY). To make the kite fly straight, you must place the main spine exactly in the middle. **DRAG** the compass to the vertex 'O' and draw an arc to cross both spars at points 'A' and 'B'.", 'hud': "Drag compass to vertex O and DRAW an arc." },
          { 'text': "Now, place the compass on point 'A' and draw an arc in the center. Then, place the compass on point 'B' and draw another arc to find the intersection point 'C'.", 'hud': "Draw intersecting arcs from points A and B." },
          { 'text': "Use the **straightedge** tool to connect the vertex 'O' to the intersection point 'C' and complete your kite's central spine.", 'hud': "Connect vertex O to intersection C to form the spine." }
        ]
      },
      {
        'title': "3. The 8-Petal Flower Design",
        'objective': "To create a complex geometric design by repeatedly bisecting angles, starting with a 90° angle. This is based on Figure 6.5 from the textbook.",
        'steps': [
          { 'text': "You have a 90° angle, which is one-quarter of a circle. Your goal is to create an 8-petal flower, which needs 45° angles. Bisect the 90° angle by drawing arcs from the axis intersections and drawing the bisector line.", 'hud': "Bisect the 90° angle using the compass and straightedge." },
          { 'text': "Great! Now you have a 45° angle. To make 8 petals, we need to divide the circle into 8 equal parts. Bisect one of the 45° angles again using the same process.", 'hud': "Bisect the resulting 45° angle." },
          { 'text': "You've found all the guide lines for the flower in this quadrant. Now, CLICK the **'Complete Pattern'** button to see your work replicated around the circle.", 'hud': "Click the 'Complete Pattern' button." }
        ]
      },
      {
        'title': "4. The Treasure Map Challenge (Unsolved)",
        'objective': "To find the location of a hidden treasure by applying the angle bisection construction without step-by-step guidance.",
        'steps': [
          { 'text': "The treasure is buried along a line that is equidistant from the path to the Old Mill and the path to the Sunken Ship. Your tools are on the side. Find the line where the treasure lies.", 'hud': "1. Select Compass & DRAW ARC. 2. Mark intersecting arcs. 3. Select Ruler, align with P, and click DRAW LINE." },
          { 'text': "The final clue says 'The treasure is where the path of equal distance crosses the river.' Select the Shovel tool and drag it to the correct spot on the map to dig.", 'hud': "Step 4: Select Shovel tool. Drag it to where your line crosses the RIVER." },
          { 'text': "You've found the spot! CLICK on the glowing intersection point to dig for the treasure.", 'hud': "Step 5: Click the glowing spot to dig!" }
        ]
      },
      {
        'title': "5. The Origami Fold Challenge (Unsolved)",
        'objective': "To create a crucial fold in a piece of virtual origami paper by first constructing the fold line (an angle bisector) without guidance.",
        'steps': [
          { 'text': "To make this origami bird, you must perform a 'valley fold' along the center line of this corner. But the line isn't drawn! Use your tools to construct the fold line.", 'hud': "Construct the fold line using the Compass and Straightedge." },
          { 'text': "Now that you've drawn the fold line, make the fold. **DRAG** the tip of the paper corner and **FOLD** it over so its edge aligns with the opposite edge of the paper.", 'hud': "Drag the corner to fold the paper along the line." }
        ]
      }
    ]
  },
  'hi': {
    'shutterTitle': 'कोण समद्विभाजन: उत्तम विभाजन की कला',
    'appSubtitle': 'कक्षा 7 • संरचनाएं और टिलिंग',
    'enterLab': 'वर्चुअल लैब में प्रवेश करें',
    'reset': 'रीसेट',
    'selectScenario': 'परिदृश्य चुनें',
    'stepLabel': 'चरण',
    'missionObj': 'मिशन का उद्देश्य',
    'footer': '© ZeroScienceLab - Fall in love with math and Science',
    'hudDefault': 'शुरू करने के लिए एक परिदृश्य चुनें।',
    'btn_draw_arc': 'चाप बनाएं',
    'btn_draw_line': 'रेखा खींचें',
    'btnComplete': 'पैटर्न पूरा करें',
    'btn_unfold': 'खोलें',
    'btn_ok': 'ठीक है',
    'finalSuccessTitle': 'मिशन पूर्ण!',
    's2_hud': [
      "चरण 1/4: कंपास को शीर्ष V पर स्नैप करें और एक चाप बनाएं।",
      "चरण 2/4: कंपास को बिंदु A या B पर स्नैप करें और एक चाप बनाएं।",
      "चरण 3/4: कंपास को दूसरे बिंदु पर स्नैप करें और एक चाप बनाएं।",
      "चरण 4/4: रूलर चुनें, शीर्ष V को प्रतिच्छेदन C1 से जोड़ें।",
      "चरण 1/3: कंपास को बिंदु D या B पर स्नैप करें और एक चाप बनाएं।",
      "चरण 2/3: कंपास को दूसरे बिंदु पर स्नैप करें और एक चाप बनाएं।",
      "चरण 3/3: रूलर चुनें, शीर्ष V को प्रतिच्छेदन C2 से जोड़ें।",
      "डिज़ाइन पूरा करने के लिए 'पैटर्न पूरा करें' पर क्लिक करें!"
    ],
    's3_hud': [
      "1/4: कंपास चुनें, P पर स्नैप करें, और 'चाप बनाएं' पर क्लिक करें।",
      "2/4: कंपास को ऊपरी पथ प्रतिच्छेदन पर ले जाएं। 'चाप बनाएं' पर क्लिक करें।",
      "3/4: कंपास को निचले पथ प्रतिच्छेदन पर ले जाएं। 'चाप बनाएं' पर क्लिक करें।",
      "4/4: रूलर चुनें, P को नए चाप प्रतिच्छेदन के साथ संरेखित करें, 'रेखा खींचें' पर क्लिक करें।"
    ],
    'canvas': {
      'oldMill': "पुरानी मिल का रास्ता",
      'ship': "डूबे हुए जहाज का रास्ता",
      'river': "नदी",
      'eqLine': "समान दूरी की रेखा",
      'north': "उ",
      'found': "मिल गया!",
      'symm': "पूरी तरह से सममित!",
      'confirmed': "लंब समद्विभाजक की पुष्टि की गई।",
      'verified90': "कोण सत्यापित: 90°",
      'verifiedLen': "खंड सत्यापित: समान लंबाई"
    },
    'scenarios': [
      {
        'title': "1. उत्तम पिज्जा स्लाइस",
        'objective': "दो लोगों के लिए पिज्जा के एक टुकड़े को पूरी तरह से विभाजित करके एक तीव्र कोण को समद्विभाजित करने के मूलभूत चरणों को सीखना।",
        'steps': [
          { 'text': "पिज्जा स्लाइस का शीर्ष चमक रहा है। कंपास पिवट पॉइंट को **खींचें (DRAG)** और इसे चमकते शीर्ष 'O' पर स्नैप करें।", 'hud': "कंपास पिवट को पिज्जा शीर्ष पर खींचें।" },
          { 'text': "कंपास का पेंसिल सिरा समायोज्य है। त्रिज्या सेट करने के लिए लाल हैंडल को खींचें। फिर पेंसिल को खींचकर एक चाप बनाएं (या **क्लिक** करें)।", 'hud': "त्रिज्या सेट करें और चाप बनाएं।" },
          { 'text': "कंपास पिवट को **खींचें (DRAG)** और इसे क्रस्ट पर नए चमकते बिंदु 'A' पर स्नैप करें।", 'hud': "कंपास को क्रस्ट पर बिंदु 'A' पर ले जाएं।" },
          { 'text': "स्लाइस के बीच में एक नया चाप खींचने के लिए 'चाप बनाएं' पर **क्लिक** करें।", 'hud': "स्लाइस के बीच में एक चाप बनाएं।" },
          { 'text': "अब, कंपास पिवट को **खींचें (DRAG)** और इसे क्रस्ट पर दूसरे बिंदु 'B' पर स्नैप करें। त्रिज्या को न बदलें। पहले वाले को काटने के लिए 'चाप बनाएं' पर **क्लिक** करें।", 'hud': "कंपास को बिंदु 'B' पर ले जाएं और एक प्रतिच्छेदी चाप बनाएं।" },
          { 'text': "**स्ट्रैटएज (रूलर)** टूल का चयन करें। पिज्जा को पूरी तरह से आधा करने के लिए शीर्ष 'O' और 'C' को जोड़ें ('रेखा खींचें' बटन का उपयोग करें)।", 'hud': "O और C बिंदुओं को जोड़ने के लिए स्ट्रैटएज का उपयोग करें।" }
        ]
      },
      {
        'title': "2. एक सममित पतंग बनाना",
        'objective': "पतंग की केंद्रीय रीढ़ के निर्माण के लिए समद्विभाजन कौशल को लागू करना, यह सुनिश्चित करना कि इसके पंख सममित हैं।",
        'steps': [
          { 'text': "आपको एक कोण (∠XOY) बनाने वाले दो पतंग स्पार्स दिए गए हैं। पतंग को सीधा उड़ाने के लिए, आपको मुख्य रीढ़ को बिल्कुल बीच में रखना होगा। कंपास को शीर्ष 'O' पर **खींचें (DRAG)** और एक चाप **बनाएं (DRAW)** जो बिंदु 'A' और 'B' पर दोनों स्पार्स को पार करता है।", 'hud': "शीर्ष O से दो पतंग स्पार्स के आर-पार एक चाप बनाएं।" },
          { 'text': "अब, कंपास को बिंदु 'A' पर रखें और केंद्र में एक चाप **बनाएं (DRAW)**। फिर, प्रतिच्छेदन बिंदु 'C' खोजने के लिए कंपास को बिंदु 'B' पर रखें और एक और चाप **बनाएं (DRAW)**।", 'hud': "A और B बिंदुओं से प्रतिच्छेदी चाप बनाएं।" },
          { 'text': "शीर्ष 'O' को प्रतिच्छेदन बिंदु 'C' से जोड़ने के लिए स्ट्रैटएज टूल का उपयोग करें। यह आपकी पतंग की केंद्रीय रीढ़ है।", 'hud': "रीढ़ बनाने के लिए शीर्ष O को प्रतिच्छेदन C से जोड़ें।" }
        ]
      },
      {
        'title': "3. 8-पंखुड़ी वाले फूल का डिज़ाइन",
        'objective': "90° के कोण से शुरू करके, बार-बार कोणों को समद्विभाजित करके एक जटिल ज्यामितीय डिज़ाइन बनाना।",
        'steps': [
          { 'text': "आपके पास 90° का कोण है। आपका लक्ष्य 8-पंखुड़ी वाला फूल बनाना है, जिसके लिए 45° के कोण की आवश्यकता है। 90° के कोण को समद्विभाजित करें।", 'hud': "कंपास और रूलर का उपयोग करके 90° के कोण को समद्विभाजित करें।" },
          { 'text': "बहुत बढ़िया! अब आपके पास 45° का कोण है। 8 पंखुड़ियाँ बनाने के लिए, हमें वृत्त को 8 समान भागों में विभाजित करना होगा। 45° के कोण को फिर से समद्विभाजित करें।", 'hud': "परिणामी 45° के कोण को समद्विभाजित करें।" },
          { 'text': "आपने इस चतुर्थांश में फूल के लिए सभी गाइड लाइन ढूंढ ली हैं। अब, अपने काम को वृत्त के चारों ओर दोहराए जाने के लिए **'पैटर्न पूरा करें'** बटन पर क्लिक करें।", 'hud': "'पैटर्न पूरा करें' बटन पर क्लिक करें।" }
        ]
      },
      {
        'title': "4. खजाना मानचित्र चुनौती (अनसुलझी)",
        'objective': "चरण-दर-चरण मार्गदर्शन के बिना कोण समद्विभाजन निर्माण को लागू करके छिपे हुए खजाने का स्थान खोजना।",
        'steps': [
          { 'text': "खजाना उस रेखा के साथ दफन है जो पुरानी मिल के पथ और डूबे हुए जहाज के पथ से समान दूरी पर है। आपके उपकरण किनारे पर हैं। वह रेखा खोजें जहाँ खजाना है।", 'hud': "चरण 1: कंपास चुनें और चाप बनाएं। चरण 2: प्रतिच्छेदी चाप बनाएं। चरण 3: रूलर चुनें, P के साथ संरेखित करें, और 'रेखा खींचें' पर क्लिक करें।" },
          { 'text': "अंतिम सुराग कहता है 'खजाना वहां है जहां समान दूरी का मार्ग नदी को पार करता है।' फावड़ा (Shovel) टूल का चयन करें और इसे खुदाई करने के लिए मानचित्र पर सही स्थान पर खींचें।", 'hud': "चरण 4: फावड़ा (Shovel) चुनें। इसे वहां खींचें जहां आपकी रेखा नदी (RIVER) को पार करती है।" },
          { 'text': "आपको वह स्थान मिल गया है! खजाना खोदने के लिए चमकते प्रतिच्छेदन बिंदु पर **क्लिक** करें।", 'hud': "चरण 5: खजाना खोदने के लिए चमकते स्थान पर क्लिक करें!" }
        ]
      },
      {
        'title': "5. ओरिगेमी फोल्ड चुनौती (अनसुलझी)",
        'objective': "बिना किसी मार्गदर्शन के पहले फोल्ड लाइन (एक कोण समद्विभाजक) का निर्माण करके आभासी ओरिगेमी पेपर के एक टुकड़े में एक महत्वपूर्ण तह बनाना।",
        'steps': [
          { 'text': "इस ओरिगेमी पक्षी को बनाने के लिए, आपको इस कोने की मध्य रेखा के साथ एक 'घाटी की तह (valley fold)' करनी होगी। लेकिन रेखा खींची नहीं गई है! फोल्ड लाइन के निर्माण के लिए अपने टूल का उपयोग करें।", 'hud': "कंपास और स्ट्रैटएज का उपयोग करके फोल्ड लाइन का निर्माण करें।" },
          { 'text': "अब जब आपने फोल्ड लाइन खींच ली है, तो फोल्ड करें। पेपर कॉर्नर की नोक को **खींचें (DRAG)** और इसे इस तरह से फोल्ड करें कि इसका किनारा पूरी तरह से संरेखित हो।", 'hud': "कागज को मोड़ने के लिए कोने को खींचें।" }
        ]
      }
    ]
  },
};

class AudioEngine {
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _snapPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _alertUrl = 'audio/class7/mixkit_2869.mp3'; 
  static const String _snapUrl = 'audio/class7/mixkit_392.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';

  static Future<void> playClick() async => _play(_clickPlayer, _clickUrl);
  static Future<void> playSuccess() async => _play(_successPlayer, _successUrl);
  static Future<void> playError() async => _play(_errorPlayer, _errorUrl);
  static Future<void> playWhir() async => _play(_fxPlayer, _alertUrl);
  static Future<void> playSnap() async => _play(_snapPlayer, _snapUrl);
  static Future<void> playPop() async => _play(_snapPlayer, _snapUrl); 
  static Future<void> playShutter() async => _play(_shutterPlayer, _shutterUrl);

  static Future<void> _play(AudioPlayer player, String url) async {
    try {
      if (player.state == PlayerState.playing) {
        await player.stop();
      }
      await player.play(AssetSource(url), volume: 0.5);
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }
}

class SimItem {
  String type; String id; 
  double x, y, z, targetX, targetY, homeX, homeY;
  bool isDragging = false; 
  bool isDraggable, isHidden, isSnapped, glow, isInteractable, hasMovedP1, hasMovedP2, isNearTarget;
  Color color; String label; double offsetX, offsetY;
  Function? onClick; String? targetId; String? snappedTo; bool hasArc = false;
  
  double radius, angle;
  double x1, y1, x2, y2; 
  double r, sa, diff; 
  double width, height, rotation; 
  
  SimItem({
    required this.type, this.id = '', required this.x, required this.y, this.z = 0.0, 
    this.isDraggable = false, this.isHidden = false, this.isSnapped = false, this.glow = false, 
    this.isInteractable = false, this.hasMovedP1 = false, this.hasMovedP2 = false, this.isNearTarget = false, 
    this.label = '', this.color = Colors.blue, this.offsetX = 0.0, this.offsetY = -20.0, this.targetId, this.r = 0.0, 
    this.sa = 0.0, this.diff = 0.0, this.radius = 0.0, this.angle = 0.0, this.width = 0.0, this.rotation = 0.0,
    this.x1 = 0.0, this.y1 = 0.0, this.x2 = 0.0, this.y2 = 0.0, this.height = 0.0
  }) : targetX = x, targetY = y, homeX = x, homeY = y;
}

class SimButton {
  String id; Color color;
  SimButton(this.id, {this.color = Colors.indigo});
}

class Particle {
  double x, y, vx, vy, life;
  Color color;
  Particle(this.x, this.y, this.vx, this.vy, this.life, this.color);
}

class LabState extends ChangeNotifier {
  String lang = 'en';
  bool isSidebarOpen = true;
  bool showIntro = true;
  
  int scenario = 0;
  int step = 0;
  bool simCompleted = false;
  String activeTool = '';

  String hudMessage = "";
  Timer? hudTimer;

  Offset successPopupPos = const Offset(300.0, 100.0);
  bool showSuccessPopup = false;
  Set<int> completedScenarios = {};

  double animProgress = 0.0;
  bool isAnimating = false;
  String animMode = '';
  
  double canvasScale = 1.0;
  Offset canvasPan = Offset.zero;

  List<SimItem> entities = [];
  List<Map<String, dynamic>> arcs = [];
  List<Map<String, dynamic>> freeArcs = [];
  List<Map<String, dynamic>> lines = [];
  List<SimButton> buttons = [];
  List<Particle> particles = [];
  
  String paperState = 'flat'; 
  bool protChecked = false;
  bool rulerChecked = false;
  bool isAdvancing = false;

  // Scenario Specific Variables
  double s0_angleStart = -70 * math.pi / 180;
  double s0_angleEnd = -25 * math.pi / 180;
  double s0_pizzaRadius = 260.0;
  Offset s0_O = const Offset(-120.0, 80.0);
  Offset s0_A = Offset.zero, s0_B = Offset.zero, s0_C = Offset.zero;
  double s0_R = 0.0;
  bool s0_rulerSnapped = false;
  bool s0_pizzaSplit = false;
  double s0_splitAnimTime = 0.0;
  bool s0_bSnapped = false;

  Offset s1_O = const Offset(-100.0, -120.0);
  double s1_ang1 = 15 * math.pi / 180;
  double s1_ang2 = 85 * math.pi / 180;
  Offset s1_A = Offset.zero, s1_B = Offset.zero, s1_C = Offset.zero;
  double s1_R1 = 0.0, s1_R2 = 0.0;
  bool s1_arcA_drawn = false, s1_arcB_drawn = false, s1_rulerSnapped = false, s1_kiteFlying = false;
  double s1_flyAnimTime = 0.0;

  Offset s2_V = const Offset(-150.0, 150.0);
  int s2_subStep = 0;
  double s2_R = 220.0, s2_R2 = 0.0, s2_R3 = 0.0;
  Offset s2_A = Offset.zero, s2_B = Offset.zero, s2_C1 = Offset.zero, s2_D = Offset.zero, s2_C2 = Offset.zero;
  bool s2_45_drawn = false, s2_22_5_drawn = false, s2_animatingPattern = false, s2_rulerSnapped = false;
  bool s2_arcA_drawn = false, s2_arcB_drawn = false, s2_arcD_drawn = false, s2_arcB2_drawn = false;
  double s2_patternAnim = 0.0;

  Offset s3_P = const Offset(-140.0, 60.0);
  double s3_ang1 = -35 * math.pi / 180;
  double s3_ang2 = 25 * math.pi / 180;
  double s3_bisectorAng = (-35 * math.pi / 180 + 25 * math.pi / 180) / 2.0;
  Offset s3_Treasure = Offset.zero;
  bool treasureFound = false;

  Offset s4_O = const Offset(-150.0, 150.0);
  Offset s4_A = const Offset(150.0, 150.0);
  Offset s4_B = const Offset(150.0, -150.0);
  Offset s4_C = const Offset(-150.0, -150.0);
  bool s4_bisectorDrawn = false;
  double s4_birdAnimTime = 0.0;

  String t(String key) {
    final langData = translations[lang] as Map<String, dynamic>?;
    if (langData != null && langData[key] != null) return langData[key].toString();
    final defaultData = translations['en'] as Map<String, dynamic>?;
    return defaultData?[key]?.toString() ?? key;
  }

  String tCanvas(String key) {
    final langData = translations[lang] as Map<String, dynamic>?;
    if (langData != null && langData['canvas'] != null && langData['canvas'][key] != null) {
      return langData['canvas'][key].toString();
    }
    final defaultData = translations['en'] as Map<String, dynamic>?;
    return defaultData?['canvas']?[key]?.toString() ?? key;
  }

  String getScenarioText(int sId, String key) {
    try {
      final scenarios = (translations[lang] as Map<String, dynamic>)['scenarios'] as List;
      return scenarios[sId][key].toString();
    } catch (_) {
      try {
        final defaultScenarios = (translations['en'] as Map<String, dynamic>)['scenarios'] as List;
        return defaultScenarios[sId][key].toString();
      } catch (__) {
        return key;
      }
    }
  }

  String getStepText(int sId, int stId, String key) {
    try {
      final scenarios = (translations[lang] as Map<String, dynamic>)['scenarios'] as List;
      final steps = scenarios[sId]['steps'] as List;
      return steps[stId][key].toString();
    } catch (_) {
      try {
        final defaultScenarios = (translations['en'] as Map<String, dynamic>)['scenarios'] as List;
        final steps = defaultScenarios[sId]['steps'] as List;
        return steps[stId][key].toString();
      } catch (__) {
        return key;
      }
    }
  }

  void setLang(String newLang) {
    lang = newLang;
    AudioEngine.playClick();
    notifyListeners();
  }

  void resetActivity() {
    AudioEngine.playClick();
    completedScenarios.clear();
    lang = 'en';
    showIntro = true; // Returns to shutter screen on reset
    loadScenario(0);
  }

  void toggleSidebar() {
    isSidebarOpen = !isSidebarOpen;
    AudioEngine.playClick();
    notifyListeners();
  }

  void showHUD(String msg) {
    hudMessage = msg;
    notifyListeners();
    hudTimer?.cancel();
    hudTimer = Timer(const Duration(seconds: 4), () {
      hudMessage = "";
      notifyListeners();
    });
  }

  void loadScenario(int sId) {
    scenario = sId;
    step = 0;
    simCompleted = false;
    showSuccessPopup = false;
    isAnimating = false;
    isAdvancing = false;
    activeTool = '';
    
    paperState = 'flat';
    protChecked = false;
    rulerChecked = false;
    
    canvasScale = 1.0;
    canvasPan = Offset.zero;
    
    entities.clear();
    arcs.clear();
    freeArcs.clear();
    lines.clear();
    buttons.clear();
    particles.clear();
    
    _initScenarioData();
    updateContextButtons();
    _updateHUDMessage();
    notifyListeners();
    
    Future.delayed(const Duration(milliseconds: 100), evaluateScenarioState);
  }

  void evaluateScenarioState() {
    if (isAdvancing || simCompleted) return;
    
    var ruler = entities.cast<SimItem?>().firstWhere((e) => e?.type == 'ruler', orElse: () => null);
    var compass = entities.cast<SimItem?>().firstWhere((e) => e?.type == 'compass', orElse: () => null);
    
    bool isDraggingRuler = ruler?.isDragging ?? false;
    bool isDraggingCompass = compass?.isDragging ?? false;
    
    if (scenario == 0) {
      if (step == 0) {
        if (compass != null && hypot(compass.x - s0_O.dx, compass.y - s0_O.dy) < 30 && !isDraggingCompass) {
          isAdvancing = true; Future.delayed(const Duration(milliseconds: 500), advanceStep);
        }
      } else if (step == 2) {
        if (compass != null && hypot(compass.x - s0_A.dx, compass.y - s0_A.dy) < 30 && !isDraggingCompass) {
          isAdvancing = true; Future.delayed(const Duration(milliseconds: 500), advanceStep);
        }
      } else if (step == 4) {
        if (compass != null && hypot(compass.x - s0_B.dx, compass.y - s0_B.dy) < 30 && !isDraggingCompass) {
          s0_bSnapped = true; 
        } else {
          s0_bSnapped = false;
        }
      } else if (step == 5) {
        if (ruler != null && ruler.hasMovedP1 && ruler.hasMovedP2 && !isDraggingRuler) {
           if ((hypot(ruler.x1 - s0_O.dx, ruler.y1 - s0_O.dy) < 30 && hypot(ruler.x2 - s0_C.dx, ruler.y2 - s0_C.dy) < 30) ||
               (hypot(ruler.x2 - s0_O.dx, ruler.y2 - s0_O.dy) < 30 && hypot(ruler.x1 - s0_C.dx, ruler.y1 - s0_C.dy) < 30)) {
             s0_rulerSnapped = true; updateContextButtons();
           } else {
             s0_rulerSnapped = false; updateContextButtons();
           }
        }
      }
    } 
    else if (scenario == 1) {
      if (step == 0) {
        if (compass != null && hypot(compass.x - s1_O.dx, compass.y - s1_O.dy) < 30 && !isDraggingCompass) {
          // Ready to draw
        }
      } else if (step == 2) {
        if (ruler != null && ruler.hasMovedP1 && ruler.hasMovedP2 && !isDraggingRuler) {
           if ((hypot(ruler.x1 - s1_O.dx, ruler.y1 - s1_O.dy) < 30 && hypot(ruler.x2 - s1_C.dx, ruler.y2 - s1_C.dy) < 30) ||
               (hypot(ruler.x2 - s1_O.dx, ruler.y2 - s1_O.dy) < 30 && hypot(ruler.x1 - s1_C.dx, ruler.y1 - s1_C.dy) < 30)) {
             s1_rulerSnapped = true; updateContextButtons();
           } else {
             s1_rulerSnapped = false; updateContextButtons();
           }
        }
      }
    }
    else if (scenario == 2) {
      if (step == 0) {
        if (s2_subStep == 3 && ruler != null && ruler.hasMovedP1 && ruler.hasMovedP2 && !isDraggingRuler) {
           if ((hypot(ruler.x1 - s2_V.dx, ruler.y1 - s2_V.dy) < 30 && hypot(ruler.x2 - s2_C1.dx, ruler.y2 - s2_C1.dy) < 30) ||
               (hypot(ruler.x2 - s2_V.dx, ruler.y2 - s2_V.dy) < 30 && hypot(ruler.x1 - s2_C1.dx, ruler.y1 - s2_C1.dy) < 30)) {
             s2_rulerSnapped = true; updateContextButtons();
           } else {
             s2_rulerSnapped = false; updateContextButtons();
           }
        }
      } else if (step == 1) {
        if (s2_subStep == 6 && ruler != null && ruler.hasMovedP1 && ruler.hasMovedP2 && !isDraggingRuler) {
           if ((hypot(ruler.x1 - s2_V.dx, ruler.y1 - s2_V.dy) < 30 && hypot(ruler.x2 - s2_C2.dx, ruler.y2 - s2_C2.dy) < 30) ||
               (hypot(ruler.x2 - s2_V.dx, ruler.y2 - s2_V.dy) < 30 && hypot(ruler.x1 - s2_C2.dx, ruler.y1 - s2_C2.dy) < 30)) {
             s2_rulerSnapped = true; updateContextButtons();
           } else {
             s2_rulerSnapped = false; updateContextButtons();
           }
        }
      }
    }
    notifyListeners();
  }

  void advanceStep() {
    isAdvancing = false;
    final scenariosData = (translations['en'] as Map<String, dynamic>)['scenarios'] as List;
    int maxSteps = (scenariosData[scenario]['steps'] as List).length;
    if (step < maxSteps - 1) {
      step++;
      AudioEngine.playSuccess();
      
      if (scenario == 0 && step == 5) { selectTool('ruler'); }
      else if (scenario == 0 && step == 0) { selectTool('compass'); }
      else if (scenario == 2 && step == 1) { selectTool('compass'); }
      else if (scenario == 3 && step == 1) { selectTool('shovel'); }

      updateContextButtons();
      _updateHUDMessage();
      notifyListeners();
    }
  }

  void completeScenario() {
    if (simCompleted) return;
    simCompleted = true;
    isAdvancing = false;
    showIntro = false; // Strictly guarantees shutter screen does not trigger here
    activeTool = '';
    buttons.clear();
    AudioEngine.playSuccess();
    
    completedScenarios.add(scenario);
    if (completedScenarios.length == 5) {
      showSuccessPopup = true;
    }
    _updateHUDMessage();
    notifyListeners();
  }

  void _updateHUDMessage() {
    if (simCompleted) {
       hudMessage = lang == 'hi' ? "शाबाश! आपने यह निर्माण सफलतापूर्वक पूरा कर लिया है।" : 
                    lang == 'te' ? "బాగా చేసారు! మీరు ఈ నిర్మాణాన్ని విజయవంతంగా పూర్తి చేసారు." : 
                    "Mission: Achieved! Great job completing this construction.";
       return;
    }

    String defaultHud = getStepText(scenario, step, 'hud');
    if (scenario == 2) {
      final langData = translations[lang] as Map<String, dynamic>?;
      final defaultData = translations['en'] as Map<String, dynamic>?;
      List<String> subHuds = ((langData?['s2_hud'] ?? defaultData?['s2_hud']) as List).map((e) => e.toString()).toList();
      if (step == 0) {
        if (s2_subStep == 0) hudMessage = subHuds[0];
        else if (s2_subStep == 1) hudMessage = subHuds[1];
        else if (s2_subStep == 2) hudMessage = subHuds[2];
        else if (s2_subStep == 3) hudMessage = subHuds[3];
      } else if (step == 1) {
        if (s2_subStep == 4) hudMessage = subHuds[4];
        else if (s2_subStep == 5) hudMessage = subHuds[5];
        else if (s2_subStep == 6) hudMessage = subHuds[6];
      } else if (step == 2) {
        hudMessage = subHuds[7];
      }
    } else if (scenario == 3 && step == 0) {
      final langData = translations[lang] as Map<String, dynamic>?;
      final defaultData = translations['en'] as Map<String, dynamic>?;
      List<String> s3Huds = ((langData?['s3_hud'] ?? defaultData?['s3_hud']) as List).map((e) => e.toString()).toList();
      int arcCount = arcs.length;
      if (arcCount == 0) hudMessage = s3Huds[0];
      else if (arcCount == 1) hudMessage = s3Huds[1];
      else if (arcCount == 2) hudMessage = s3Huds[2];
      else hudMessage = s3Huds[3];
    } else {
      hudMessage = defaultHud;
    }
  }

  void _initScenarioData() {
    s0_rulerSnapped = false; s0_pizzaSplit = false; s0_splitAnimTime = 0.0; s0_bSnapped = false;
    s1_rulerSnapped = false; s1_kiteFlying = false; s1_flyAnimTime = 0.0; s1_arcA_drawn = false; s1_arcB_drawn = false;
    treasureFound = false;

    if (scenario == 0) {
      entities.add(SimItem(type: 'point', id: 'O', x: s0_O.dx, y: s0_O.dy, label: 'O', color: Colors.yellowAccent, offsetY: 25.0, glow: true));
    } 
    else if (scenario == 1) {
      entities.add(SimItem(type: 'point', id: 'O', x: s1_O.dx, y: s1_O.dy, label: 'O', color: Colors.yellowAccent, offsetY: -25.0, glow: true));
    }
    else if (scenario == 2) {
      s2_subStep = 0; s2_45_drawn = false; s2_22_5_drawn = false; s2_animatingPattern = false; s2_patternAnim = 0.0;
      s2_arcA_drawn = false; s2_arcB_drawn = false; s2_arcD_drawn = false; s2_arcB2_drawn = false;
      entities.add(SimItem(type: 'point', id: 'V', x: s2_V.dx, y: s2_V.dy, label: 'V', color: Colors.blue, offsetY: 20.0, offsetX: -20.0, glow: true));
    }
    else if (scenario == 3) {
      s3_Treasure = Offset(140.0, s3_P.dy + (140.0 - s3_P.dx) * math.tan(s3_bisectorAng));
      entities.add(SimItem(type: 'point', id: 'P', x: s3_P.dx, y: s3_P.dy, label: 'P', color: Colors.brown, offsetY: 25.0));
    }
    else if (scenario == 4) {
      paperState = 'flat'; s4_bisectorDrawn = false; s4_birdAnimTime = 0.0;
      entities.add(SimItem(type: 'point', id: 'O', x: -150.0, y: 150.0, label: 'O', color: Colors.yellowAccent, offsetX: -15.0, offsetY: 20.0));
      entities.add(SimItem(type: 'paper_corner', id: 'paper_corner', x: 150.0, y: 150.0, z: 10.0, isDraggable: true, isHidden: true));
    }
  }

  void updateContextButtons() {
    buttons.clear();
    if (simCompleted || isAnimating) return;

    var compass = entities.cast<SimItem?>().firstWhere((e) => e?.type == 'compass', orElse: () => null);
    var ruler = entities.cast<SimItem?>().firstWhere((e) => e?.type == 'ruler', orElse: () => null);
    bool showDrawArc = compass != null && !compass.isHidden;
    bool showDrawLine = ruler != null && !ruler.isHidden;

    if (scenario == 0) {
      if ((step == 1 || step == 3 || step == 4) && showDrawArc) { buttons.add(SimButton('btn_draw_arc')); }
      if (step == 5 && s0_rulerSnapped) { buttons.add(SimButton('btn_draw_line')); }
    } else if (scenario == 1) {
      if ((step == 0 || step == 1) && showDrawArc) { buttons.add(SimButton('btn_draw_arc')); }
      if (step == 2 && s1_rulerSnapped) { buttons.add(SimButton('btn_draw_line')); }
    } else if (scenario == 2) {
      if (step == 0 && s2_subStep == 3 && s2_rulerSnapped) { buttons.add(SimButton('btn_draw_line')); }
      else if (step == 1 && s2_subStep == 6 && s2_rulerSnapped) { buttons.add(SimButton('btn_draw_line')); }
      else if ((step == 0 && s2_subStep < 3) || (step == 1 && s2_subStep < 6)) {
          if (showDrawArc) buttons.add(SimButton('btn_draw_arc')); 
      }
      else if (step == 2) { buttons.add(SimButton('btnComplete')); }
    } else if (scenario == 3) {
      if (step == 0 && showDrawArc) { buttons.add(SimButton('btn_draw_arc')); }
      else if (step == 0 && showDrawLine) { buttons.add(SimButton('btn_draw_line')); }
    } else if (scenario == 4) {
      if (step == 0 && showDrawArc) { buttons.add(SimButton('btn_draw_arc')); }
      else if (step == 0 && showDrawLine) { buttons.add(SimButton('btn_draw_line')); }
      else if (step == 1) { buttons.add(SimButton('btn_unfold')); }
    }
  }

  void updateDynamicIntersections() {
    entities.removeWhere((e) => e.id.startsWith('dyn_int_'));
    int idCounter = 0;
    
    // Generate arc-arc intersections
    for (int i = 0; i < arcs.length; i++) {
      for (int j = i + 1; j < arcs.length; j++) {
         var a1 = arcs[i]; var a2 = arcs[j];
         double dx = a2['x'] - a1['x']; double dy = a2['y'] - a1['y']; double d = hypot(dx, dy);
         if (d < a1['r'] + a2['r'] && d > (a1['r'] - a2['r']).abs() && d > 0) {
           double a = (a1['r'] * a1['r'] - a2['r'] * a2['r'] + d * d) / (2.0 * d);
           double term = math.max<double>(0.0, a1['r'] * a1['r'] - a * a);
           double h = math.sqrt(term);
           double cx = a1['x'] + a * (dx/d); double cy = a1['y'] + a * (dy/d);
           double int1x = cx + h * (dy/d); double int1y = cy - h * (dx/d);
           double int2x = cx - h * (dy/d); double int2y = cy + h * (dx/d);
           
           entities.add(SimItem(type: 'intersection', id: 'dyn_int_${idCounter++}', x: int1x, y: int1y, label: '', offsetX: 0.0, offsetY: 0.0));
           entities.add(SimItem(type: 'intersection', id: 'dyn_int_${idCounter++}', x: int2x, y: int2y, label: '', offsetX: 0.0, offsetY: 0.0));
         }
      }
    }
    
    // Generate specific arc-line intersections for Scenarios 3 and 4
    if (scenario == 3) {
       for (var a in arcs) {
          if (hypot(a['x'] - s3_P.dx, a['y'] - s3_P.dy) < 5) {
             entities.add(SimItem(type: 'intersection', id: 'dyn_int_${idCounter++}', x: s3_P.dx + a['r'] * math.cos(s3_ang1), y: s3_P.dy + a['r'] * math.sin(s3_ang1), label: ''));
             entities.add(SimItem(type: 'intersection', id: 'dyn_int_${idCounter++}', x: s3_P.dx + a['r'] * math.cos(s3_ang2), y: s3_P.dy + a['r'] * math.sin(s3_ang2), label: ''));
          }
       }
    } else if (scenario == 4) {
       for (var a in arcs) {
          if (hypot(a['x'] - s4_O.dx, a['y'] - s4_O.dy) < 5) {
             entities.add(SimItem(type: 'intersection', id: 'dyn_int_${idCounter++}', x: s4_O.dx + a['r'], y: s4_O.dy, label: ''));
             entities.add(SimItem(type: 'intersection', id: 'dyn_int_${idCounter++}', x: s4_O.dx, y: s4_O.dy - a['r'], label: ''));
          }
       }
    }
  }

  void drawArcAction() {
    var compass = entities.cast<SimItem?>().firstWhere((e) => e?.type == 'compass', orElse: () => null);
    if (compass == null) return;
    
    if (scenario == 0) {
      if (step == 1) {
        if (compass.radius < 50 || compass.radius > 250) { AudioEngine.playError(); showHUD(t('hudDefault')); return; }
        freeArcs.clear(); AudioEngine.playWhir(); compass.isDraggable = false; s0_R = compass.radius;
        double startAng = s0_angleStart - 0.15; double endAng = s0_angleEnd + 0.15; compass.angle = startAng;
        arcs.add({'x': s0_O.dx, 'y': s0_O.dy, 'r': compass.radius, 'sa': startAng, 'ea': startAng, 'targetEa': endAng, 'p': 0.0});
        s0_A = Offset(s0_O.dx + compass.radius * math.cos(s0_angleStart), s0_O.dy + compass.radius * math.sin(s0_angleStart));
        s0_B = Offset(s0_O.dx + compass.radius * math.cos(s0_angleEnd), s0_O.dy + compass.radius * math.sin(s0_angleEnd));
        isAnimating = true; animMode = 's0_arc_O'; animProgress = 0.0; buttons.clear();
      } else if (step == 3) {
        freeArcs.clear(); AudioEngine.playWhir(); compass.isDraggable = false; compass.radius = s0_R;
        double midAng = (s0_angleStart + s0_angleEnd) / 2.0;
        Offset P = Offset(s0_O.dx + 300.0 * math.cos(midAng), s0_O.dy + 300.0 * math.sin(midAng));
        double angFromA = math.atan2(P.dy - s0_A.dy, P.dx - s0_A.dx);
        double startAng = angFromA - 0.4; double endAng = angFromA + 0.6; compass.angle = startAng;
        arcs.add({'x': s0_A.dx, 'y': s0_A.dy, 'r': compass.radius, 'sa': startAng, 'ea': startAng, 'targetEa': endAng, 'p': 0.0});
        isAnimating = true; animMode = 's0_arc_A'; animProgress = 0.0; buttons.clear();
      } else if (step == 4) {
        if (!s0_bSnapped) { AudioEngine.playError(); return; }
        freeArcs.clear(); AudioEngine.playWhir(); compass.isDraggable = false; compass.radius = s0_R;
        double midAng = (s0_angleStart + s0_angleEnd) / 2.0;
        Offset P = Offset(s0_O.dx + 300.0 * math.cos(midAng), s0_O.dy + 300.0 * math.sin(midAng));
        double angFromB = math.atan2(P.dy - s0_B.dy, P.dx - s0_B.dx);
        double startAng = angFromB - 0.6; double endAng = angFromB + 0.4; compass.angle = startAng;
        arcs.add({'x': s0_B.dx, 'y': s0_B.dy, 'r': compass.radius, 'sa': startAng, 'ea': startAng, 'targetEa': endAng, 'p': 0.0});
        
        double OC_length = 2.0 * s0_R * math.cos((s0_angleEnd - s0_angleStart).abs() / 2.0);
        s0_C = Offset(s0_O.dx + OC_length * math.cos(midAng), s0_O.dy + OC_length * math.sin(midAng));
        isAnimating = true; animMode = 's0_arc_B'; animProgress = 0.0; buttons.clear();
      }
    } 
    else if (scenario == 1) {
      if (step == 0) {
        if (compass.radius < 50 || compass.radius > 220) { AudioEngine.playError(); return; }
        if (hypot(compass.x - s1_O.dx, compass.y - s1_O.dy) > 30) { AudioEngine.playError(); return; }
        freeArcs.clear(); AudioEngine.playWhir(); compass.isDraggable = false; s1_R1 = compass.radius;
        s1_A = Offset(s1_O.dx + compass.radius * math.cos(s1_ang1), s1_O.dy + compass.radius * math.sin(s1_ang1));
        s1_B = Offset(s1_O.dx + compass.radius * math.cos(s1_ang2), s1_O.dy + compass.radius * math.sin(s1_ang2));
        double startAng = s1_ang1 - 0.2; double endAng = s1_ang2 + 0.2; compass.angle = startAng;
        arcs.add({'x': s1_O.dx, 'y': s1_O.dy, 'r': compass.radius, 'sa': startAng, 'ea': startAng, 'targetEa': endAng, 'p': 0.0});
        isAnimating = true; animMode = 's1_arc_O'; animProgress = 0.0; buttons.clear();
      } else if (step == 1) {
        double distA = hypot(compass.x - s1_A.dx, compass.y - s1_A.dy);
        double distB = hypot(compass.x - s1_B.dx, compass.y - s1_B.dy);
        String pivotPt = '';
        if (distA < 30 && !s1_arcA_drawn) pivotPt = 'A';
        else if (distB < 30 && !s1_arcB_drawn) pivotPt = 'B';
        if (pivotPt == '') { AudioEngine.playError(); showHUD("Snap the compass to the glowing point first!"); return; }

        double alpha = (s1_ang1 - s1_ang2).abs() / 2.0;
        double safeMinRadius = s1_R1 * math.sin(alpha) + 20.0;
        if (compass.radius < safeMinRadius) compass.radius = safeMinRadius;

        if (s1_arcA_drawn || s1_arcB_drawn) { compass.radius = s1_R2; } else { s1_R2 = compass.radius; }
        
        freeArcs.clear(); AudioEngine.playWhir(); compass.isDraggable = false;
        double midAng = (s1_ang1 + s1_ang2) / 2.0;
        Offset expectedC = Offset(s1_O.dx + (s1_R1 + s1_R2*0.8) * math.cos(midAng), s1_O.dy + (s1_R1 + s1_R2*0.8) * math.sin(midAng));
        Offset pt = pivotPt == 'A' ? s1_A : s1_B;
        double sweepCenter = math.atan2(expectedC.dy - pt.dy, expectedC.dx - pt.dx);
        double startAng = sweepCenter - 0.8; double endAng = sweepCenter + 0.8; compass.angle = startAng;
        arcs.add({'x': pt.dx, 'y': pt.dy, 'r': s1_R2, 'sa': startAng, 'ea': startAng, 'targetEa': endAng, 'p': 0.0});
        isAnimating = true; animMode = 's1_arc_$pivotPt'; animProgress = 0.0; buttons.clear();
      }
    }
    else if (scenario == 2) {
      if (step == 0) {
        if (s2_subStep == 0) {
          if (hypot(compass.x - s2_V.dx, compass.y - s2_V.dy) > 15) { AudioEngine.playError(); return; }
          double rc = compass.radius; if (rc < 150) { rc = 150.0; compass.radius = rc; } if (rc > 300) { rc = 300.0; compass.radius = rc; }
          s2_R = rc; freeArcs.clear(); AudioEngine.playWhir(); compass.isDraggable = false;
          s2_A = Offset(s2_V.dx, s2_V.dy - rc); s2_B = Offset(s2_V.dx + rc, s2_V.dy);
          double startAng = -math.pi/2; double endAng = 0.0; compass.angle = startAng;
          arcs.add({'x': s2_V.dx, 'y': s2_V.dy, 'r': compass.radius, 'sa': startAng, 'ea': startAng, 'targetEa': endAng, 'p': 0.0});
          isAnimating = true; animMode = 's2_arc1'; animProgress = 0.0; buttons.clear();
        } else if (s2_subStep == 1 || s2_subStep == 2) {
          double distA = hypot(compass.x - s2_A.dx, compass.y - s2_A.dy);
          double distB = hypot(compass.x - s2_B.dx, compass.y - s2_B.dy);
          String pivotPt = '';
          if (distA < 40 && !s2_arcA_drawn) pivotPt = 'A';
          else if (distB < 40 && !s2_arcB_drawn) pivotPt = 'B';
          if (pivotPt == '') { AudioEngine.playError(); showHUD("Snap the compass to the glowing point (A or B)!"); return; }
          
          double rc = compass.radius; double R = s2_R; double alpha = math.pi/4;
          double term = R * math.sin(alpha);
          double safeMinRadius = term + 20.0; if (rc < safeMinRadius) { rc = safeMinRadius; compass.radius = rc; }
          if (s2_arcA_drawn || s2_arcB_drawn) compass.radius = s2_R2; else s2_R2 = compass.radius;
          
          freeArcs.clear(); AudioEngine.playWhir(); compass.isDraggable = false;
          double disc = s2_R2*s2_R2 - (term * term);
          double distToC1 = R * math.cos(alpha) + math.sqrt(disc);
          s2_C1 = Offset(s2_V.dx + distToC1 * math.cos(-math.pi/4), s2_V.dy + distToC1 * math.sin(-math.pi/4));
          
          Offset pt = pivotPt == 'A' ? s2_A : s2_B;
          double sweepCenter = math.atan2(s2_C1.dy - pt.dy, s2_C1.dx - pt.dx);
          double startAng = sweepCenter - 0.8; double endAng = sweepCenter + 0.8; compass.angle = startAng;
          arcs.add({'x': pt.dx, 'y': pt.dy, 'r': compass.radius, 'sa': startAng, 'ea': startAng, 'targetEa': endAng, 'p': 0.0});
          isAnimating = true; animMode = 's2_arc_$pivotPt'; animProgress = 0.0; buttons.clear();
        }
      } else if (step == 1) {
        if (s2_subStep == 4 || s2_subStep == 5) {
          double distD = hypot(compass.x - s2_D.dx, compass.y - s2_D.dy);
          double distB = hypot(compass.x - s2_B.dx, compass.y - s2_B.dy);
          String pivotPt = '';
          if (distD < 40 && !s2_arcD_drawn) pivotPt = 'D';
          else if (distB < 40 && !s2_arcB2_drawn) pivotPt = 'B2';
          if (pivotPt == '') { AudioEngine.playError(); showHUD("Snap the compass to the glowing point (D or B)!"); return; }
          
          double rc = compass.radius; double R = s2_R; double alpha = math.pi/8;
          double term = R * math.sin(alpha);
          double safeMinRadius = term + 20.0; if (rc < safeMinRadius) { rc = safeMinRadius; compass.radius = rc; }
          if (s2_arcD_drawn || s2_arcB2_drawn) compass.radius = s2_R3; else s2_R3 = compass.radius;
          
          freeArcs.clear(); AudioEngine.playWhir(); compass.isDraggable = false;
          double disc = s2_R3*s2_R3 - (term * term);
          double distToC2 = R * math.cos(alpha) + math.sqrt(disc);
          s2_C2 = Offset(s2_V.dx + distToC2 * math.cos(-math.pi/8), s2_V.dy + distToC2 * math.sin(-math.pi/8));
          
          Offset pt = pivotPt == 'D' ? s2_D : s2_B;
          double sweepCenter = math.atan2(s2_C2.dy - pt.dy, s2_C2.dx - pt.dx);
          double startAng = sweepCenter - 0.8; double endAng = sweepCenter + 0.8; compass.angle = startAng;
          arcs.add({'x': pt.dx, 'y': pt.dy, 'r': compass.radius, 'sa': startAng, 'ea': startAng, 'targetEa': endAng, 'p': 0.0});
          isAnimating = true; animMode = 's2_arc_$pivotPt'; animProgress = 0.0; buttons.clear();
        }
      }
    }
    else if (scenario == 3 || scenario == 4) {
       freeArcs.clear(); AudioEngine.playWhir(); compass.isDraggable = false; 
       double startAng = 0.0; double endAng = math.pi * 2;
       compass.angle = startAng;
       arcs.add({'x': compass.x, 'y': compass.y, 'r': compass.radius, 'sa': startAng, 'ea': startAng, 'targetEa': endAng, 'p': 0.0});
       isAnimating = true; animMode = 'full_circle'; animProgress = 0.0; buttons.clear();
    }
    notifyListeners();
  }

  void drawLineAction() {
    if (scenario == 0) {
      AudioEngine.playSuccess();
      lines.add({'x1': s0_O.dx, 'y1': s0_O.dy, 'x2': s0_C.dx, 'y2': s0_C.dy, 'color': Colors.red, 'w': 4.0});
      entities.removeWhere((e) => e.type == 'ruler');
      s0_pizzaSplit = true; s0_splitAnimTime = 0.0;
      completeScenario();
    } else if (scenario == 1) {
      AudioEngine.playSuccess();
      lines.add({'x1': s1_O.dx, 'y1': s1_O.dy, 'x2': s1_C.dx, 'y2': s1_C.dy, 'color': Colors.white, 'w': 6.0});
      entities.removeWhere((e) => e.type == 'ruler');
      s1_kiteFlying = true;
      completeScenario();
    } else if (scenario == 2) {
      if (step == 0 && s2_subStep == 3) {
        AudioEngine.playSuccess();
        lines.add({'x1': s2_V.dx, 'y1': s2_V.dy, 'x2': s2_C1.dx, 'y2': s2_C1.dy, 'color': Colors.red, 'w': 4.0, 'dashed': true});
        s2_45_drawn = true;
        s2_D = Offset(s2_V.dx + s2_R * math.cos(-math.pi/4), s2_V.dy + s2_R * math.sin(-math.pi/4));
        entities.add(SimItem(type: 'point', id: 'D', x: s2_D.dx, y: s2_D.dy, label: 'D', color: Colors.lightBlue, glow: true, offsetY: -20.0));
        
        var pB = entities.cast<SimItem?>().firstWhere((e) => e?.id == 'B', orElse: () => null);
        if (pB != null) pB.glow = true;

        entities.removeWhere((e) => e.type == 'ruler');
        s2_subStep = 4; advanceStep();
      } else if (step == 1 && s2_subStep == 6) {
        AudioEngine.playSuccess();
        lines.add({'x1': s2_V.dx, 'y1': s2_V.dy, 'x2': s2_C2.dx, 'y2': s2_C2.dy, 'color': Colors.red, 'w': 4.0, 'dashed': true});
        s2_22_5_drawn = true;
        entities.removeWhere((e) => e.type == 'ruler');
        advanceStep();
      }
    } else if (scenario == 3) {
      var ruler = entities.firstWhere((e) => e.type == 'ruler', orElse: ()=>SimItem(type:'',x:0.0,y:0.0));
      if (step == 0 && ruler.id.isNotEmpty) {
        double dx = ruler.x2 - ruler.x1; double dy = ruler.y2 - ruler.y1;
        double len = hypot(dx, dy);
        if (len == 0) return;
        
        // Use dot product validation to prevent math.pi wrapping bugs
        double rx = dx / len; double ry = dy / len;
        double ex = math.cos(s3_bisectorAng); double ey = math.sin(s3_bisectorAng);
        double dot = (rx * ex + ry * ey).abs();
        
        double distToP = (dy*s3_P.dx - dx*s3_P.dy + ruler.x2*ruler.y1 - ruler.y2*ruler.x1).abs() / len;

        if (dot > 0.98 && distToP < 30) {
          AudioEngine.playSuccess();
          lines.add({'x1': s3_P.dx, 'y1': s3_P.dy, 'x2': s3_P.dx + 400.0 * math.cos(s3_bisectorAng), 'y2': s3_P.dy + 400.0 * math.sin(s3_bisectorAng), 'color': Colors.yellowAccent, 'w': 6.0, 'glow': true});
          entities.removeWhere((e) => e.type == 'ruler' || e.type == 'compass' || e.id.startsWith('dyn_int_'));
          isAdvancing = true; Future.delayed(const Duration(milliseconds: 1500), advanceStep);
        } else {
          AudioEngine.playError(); showHUD("That line doesn't bisect the angle correctly. Try again.");
        }
      }
    } else if (scenario == 4) {
      var ruler = entities.firstWhere((e) => e.type == 'ruler', orElse: ()=>SimItem(type:'',x:0.0,y:0.0));
      if (step == 0 && ruler.id.isNotEmpty) {
        double dx = ruler.x2 - ruler.x1; double dy = ruler.y2 - ruler.y1;
        double len = hypot(dx, dy);
        if (len == 0) return;
        
        // Robust point-to-line distance validation for O and C
        double distToO = (dy*(s4_O.dx) - dx*(s4_O.dy) + ruler.x2*ruler.y1 - ruler.y2*ruler.x1).abs() / len;
        double distToC = (dy*(s4_C.dx) - dx*(s4_C.dy) + ruler.x2*ruler.y1 - ruler.y2*ruler.x1).abs() / len;

        if (distToO < 30 && distToC < 30) {
          AudioEngine.playSuccess();
          s4_bisectorDrawn = true;
          entities.removeWhere((e) => e.type == 'ruler' || e.type == 'compass' || e.id.startsWith('dyn_int_'));
          var corner = entities.firstWhere((e) => e.type == 'paper_corner', orElse: () => SimItem(type:'', x:0.0,y:0.0));
          if(corner.id.isNotEmpty) corner.isHidden = false;
          isAdvancing = true; Future.delayed(const Duration(milliseconds: 1500), advanceStep);
        } else {
          AudioEngine.playError(); showHUD("Incorrect fold line. It must pass straight through O and C.");
        }
      }
    }
    notifyListeners();
  }

  void completePatternAction() {
    AudioEngine.playSuccess();
    entities.removeWhere((e) => e.type == 'ruler' || e.type == 'compass' || e.type == 'point' || e.type == 'intersection');
    s2_animatingPattern = true;
    if (!isAdvancing) { isAdvancing = true; Future.delayed(const Duration(milliseconds: 3500), completeScenario); }
    notifyListeners();
  }

  void unfoldAction() {
    AudioEngine.playPop();
    var corner = entities.firstWhere((e) => e.type == 'paper_corner', orElse: () => SimItem(type:'',x:0.0,y:0.0));
    if (corner.id.isNotEmpty) { corner.x = s4_B.dx; corner.y = s4_B.dy; corner.isDraggable = false; corner.isHidden = true; }
    paperState = 'unfolded';
    advanceStep();
  }

  void selectTool(String toolName) {
    AudioEngine.playClick();
    activeTool = toolName;
    
    double cx = -canvasPan.dx / canvasScale;
    double cy = -canvasPan.dy / canvasScale;

    var tool = entities.cast<SimItem?>().firstWhere((e) => e?.type == toolName, orElse: () => null);
    if (tool == null) {
      if (toolName == 'ruler') entities.add(SimItem(type: 'ruler', id: 'ruler', x: cx, y: cy-150.0/canvasScale, x1: cx-100.0, y1: cy-150.0/canvasScale, x2: cx+100.0, y2: cy-150.0/canvasScale, z: 9.0, isDraggable: true));
      if (toolName == 'compass') entities.add(SimItem(type: 'compass', id: 'compass', x: cx, y: cy-150.0/canvasScale, radius: 100.0, angle: math.pi/4, z: 10.0, isDraggable: true));
      if (toolName == 'protractor') entities.add(SimItem(type: 'protractor', id: 'protractor', x: cx, y: cy-150.0/canvasScale, z: 9.0, isDraggable: true));
      if (toolName == 'shovel') entities.add(SimItem(type: 'shovel', id: 'shovel', x: cx, y: cy-150.0/canvasScale, z: 10.0, isDraggable: true));
    } else {
      tool.isHidden = false;
      tool.x = cx; tool.y = cy - 150.0/canvasScale;
      tool.targetX = cx; tool.targetY = cy - 150.0/canvasScale;
    }
    
    for (var e in entities) {
      if ((e.type == 'ruler' || e.type == 'compass' || e.type == 'protractor' || e.type == 'shovel') && e.type != toolName) {
        e.isHidden = true; 
      }
    }
    updateContextButtons();
    notifyListeners();
  }

  void createParticles(double x, double y, Color color) {
    for (int i=0; i<20; i++) {
      particles.add(Particle(x, y, (math.Random().nextDouble()-0.5)*10.0, (math.Random().nextDouble()-0.5)*10.0 - 5.0, 1.0, color));
    }
  }
}

class AngleBisectionApp extends StatelessWidget {
  const AngleBisectionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Angle Bisection',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.white)),
      ),
      home: const AngleBisectionSimulation(),
    );
  }
}

class AngleBisectionSimulation extends StatefulWidget {
  const AngleBisectionSimulation({Key? key}) : super(key: key);
  @override
  State<AngleBisectionSimulation> createState() => _AngleBisectionSimulationState();
}

class _AngleBisectionSimulationState extends State<AngleBisectionSimulation> with TickerProviderStateMixin {
  final LabState _state = LabState();
  late AnimationController _animCtrl;
  
  final ScrollController _sidebarScrollCtrl = ScrollController();

  bool _isDraggingAnItem = false;
  bool _isPanningCanvas = false;
  double _startScale = 1.0;
  Offset _startPan = Offset.zero;
  Offset _startFocal = Offset.zero;
  SimItem? _draggedItem;
  String _dragPart = '';
  double _sweptAngle = 0.0;
  bool _arcValidated = false;
  
  double _dragOffsetX = 0.0;
  double _dragOffsetY = 0.0;
  double _dragRulerX1 = 0.0;
  double _dragRulerY1 = 0.0;
  double _dragRulerX2 = 0.0;
  double _dragRulerY2 = 0.0;
  
  Offset _floatingStepPos = const Offset(20.0, 80.0); // Tucked to top-left
  Offset _successPopupPos = const Offset(100.0, 100.0);
  int _lastStep = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _state.addListener(() {
      if (!mounted) return;
      if (_state.step != _lastStep) {
        _lastStep = _state.step;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_sidebarScrollCtrl.hasClients) {
            double offset = _state.step * 120.0;
            _sidebarScrollCtrl.animateTo(
              math.min<double>(offset, _sidebarScrollCtrl.position.maxScrollExtent),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      }
      setState(() {});
    });
    
    _state.loadScenario(0);
    AudioEngine.playShutter();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 16))..repeat();
    _animCtrl.addListener(_updatePhysics);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _animCtrl.dispose();
    _sidebarScrollCtrl.dispose();
    _state.dispose();
    super.dispose();
  }

  void _updatePhysics() {
    bool needsRender = false;
    for (var d in _state.entities) {
      if (!d.isDragging) {
        if ((d.x - d.targetX).abs() > 0.5 || (d.y - d.targetY).abs() > 0.5) {
          d.x += (d.targetX - d.x) * 0.2; d.y += (d.targetY - d.y) * 0.2;
          needsRender = true;
        }
      }
    }

    if (_state.isAnimating) {
      _state.animProgress += 0.02;
      double p = math.min<double>(1.0, _state.animProgress);
      
      if (_state.animMode.startsWith('s0_') || _state.animMode.startsWith('s1_') || _state.animMode.startsWith('s2_') || _state.animMode == 'full_circle') {
        if (_state.arcs.isNotEmpty) {
          var arc = _state.arcs.last;
          arc['ea'] = arc['sa'] + (arc['targetEa'] - arc['sa']) * p;
          arc['p'] = p;
          var comp = _state.entities.cast<SimItem?>().firstWhere((e) => e?.type == 'compass', orElse: () => null);
          if (comp != null) comp.angle = arc['ea'];
        }
        if (p >= 1) {
          _state.isAnimating = false;
          var comp = _state.entities.cast<SimItem?>().firstWhere((e) => e?.type == 'compass', orElse: () => null);
          if (comp != null) comp.isDraggable = true;
          
          if (_state.animMode == 'full_circle') {
             _state.updateDynamicIntersections();
          } else if (_state.animMode == 's0_arc_O') {
            _state.entities.add(SimItem(type: 'point', id: 'A', x: _state.s0_A.dx, y: _state.s0_A.dy, label: 'A', color: Colors.orange, glow: true, offsetX: -20.0, offsetY: -20.0));
            _state.entities.add(SimItem(type: 'point', id: 'B', x: _state.s0_B.dx, y: _state.s0_B.dy, label: 'B', color: Colors.orange, glow: false, offsetX: 20.0, offsetY: 20.0));
            _state.isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _state.advanceStep);
          } else if (_state.animMode == 's0_arc_A') {
            var pA = _state.entities.cast<SimItem?>().firstWhere((e) => e?.id == 'A', orElse: () => null); if(pA!=null) pA.glow = false;
            var pB = _state.entities.cast<SimItem?>().firstWhere((e) => e?.id == 'B', orElse: () => null); if(pB!=null) pB.glow = true;
            _state.isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _state.advanceStep);
          } else if (_state.animMode == 's0_arc_B') {
            var pB = _state.entities.cast<SimItem?>().firstWhere((e) => e?.id == 'B', orElse: () => null); if(pB!=null) pB.glow = false;
            _state.entities.add(SimItem(type: 'intersection', id: 'C', x: _state.s0_C.dx, y: _state.s0_C.dy, label: 'C', color: Colors.orange, glow: true, offsetX: 20.0));
            _state.isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _state.advanceStep);
          } else if (_state.animMode == 's1_arc_O') {
             _state.entities.add(SimItem(type: 'point', id: 'A', x: _state.s1_A.dx, y: _state.s1_A.dy, label: 'A', color: Colors.orange, glow: true, offsetX: -20.0, offsetY: 20.0));
             _state.entities.add(SimItem(type: 'point', id: 'B', x: _state.s1_B.dx, y: _state.s1_B.dy, label: 'B', color: Colors.orange, glow: true, offsetX: 20.0, offsetY: 20.0));
             _state.isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _state.advanceStep);
          } else if (_state.animMode == 's1_arc_A' || _state.animMode == 's1_arc_B') {
             if (_state.animMode == 's1_arc_A') { _state.s1_arcA_drawn = true; var pA = _state.entities.cast<SimItem?>().firstWhere((e) => e?.id == 'A', orElse: () => null); if(pA!=null) pA.glow = false; }
             if (_state.animMode == 's1_arc_B') { _state.s1_arcB_drawn = true; var pB = _state.entities.cast<SimItem?>().firstWhere((e) => e?.id == 'B', orElse: () => null); if(pB!=null) pB.glow = false; }
             if (_state.s1_arcA_drawn && _state.s1_arcB_drawn) {
                 double alpha = (_state.s1_ang1 - _state.s1_ang2).abs() / 2.0;
                 double midAng = (_state.s1_ang1 + _state.s1_ang2) / 2.0;
                 double term1 = _state.s1_R1 * math.sin(alpha);
                 double ocDist = _state.s1_R1 * math.cos(alpha) + math.sqrt(_state.s1_R2*_state.s1_R2 - (term1 * term1));
                 _state.s1_C = Offset(_state.s1_O.dx + ocDist * math.cos(midAng), _state.s1_O.dy + ocDist * math.sin(midAng));
                 _state.entities.add(SimItem(type: 'intersection', id: 'C', x: _state.s1_C.dx, y: _state.s1_C.dy, label: 'C', color: Colors.purple[300]!, glow: true, offsetY: -30.0));
                 _state.isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), _state.advanceStep);
             }
          } else if (_state.animMode == 's2_arc1') {
             _state.entities.add(SimItem(type: 'point', id: 'A', x: _state.s2_A.dx, y: _state.s2_A.dy, label: 'A', color: Colors.lightBlue, glow: true, offsetY: -20.0));
             _state.entities.add(SimItem(type: 'point', id: 'B', x: _state.s2_B.dx, y: _state.s2_B.dy, label: 'B', color: Colors.lightBlue, glow: true, offsetX: 20.0));
             _state.s2_subStep = 1; var pV = _state.entities.cast<SimItem?>().firstWhere((e) => e?.id == 'V', orElse: () => null); if(pV!=null) pV.glow = false;
          } else if (_state.animMode.startsWith('s2_arc_A') || _state.animMode.startsWith('s2_arc_B') && _state.s2_subStep < 3) {
             if (_state.animMode == 's2_arc_A') { _state.s2_arcA_drawn = true; var pA = _state.entities.cast<SimItem?>().firstWhere((e) => e?.id == 'A', orElse: () => null); if(pA!=null) pA.glow = false; }
             if (_state.animMode == 's2_arc_B') { _state.s2_arcB_drawn = true; var pB = _state.entities.cast<SimItem?>().firstWhere((e) => e?.id == 'B', orElse: () => null); if(pB!=null) pB.glow = false; }
             if (_state.s2_arcA_drawn && _state.s2_arcB_drawn) {
                 _state.entities.add(SimItem(type: 'intersection', id: 'C1', x: _state.s2_C1.dx, y: _state.s2_C1.dy, label: 'C1', color: Colors.orange, glow: true, offsetY: -20.0, offsetX: 15.0));
                 _state.s2_subStep = 3; _state.selectTool('ruler'); 
             } else {
                 _state.s2_subStep = 2; // Wait for other arc
             }
          } else if (_state.animMode == 's2_arc_D' || (_state.animMode == 's2_arc_B2')) {
             if (_state.animMode == 's2_arc_D') { _state.s2_arcD_drawn = true; var pD = _state.entities.cast<SimItem?>().firstWhere((e) => e?.id == 'D', orElse: () => null); if(pD!=null) pD.glow = false; }
             if (_state.animMode == 's2_arc_B2') { _state.s2_arcB2_drawn = true; var pB = _state.entities.cast<SimItem?>().firstWhere((e) => e?.id == 'B', orElse: () => null); if(pB!=null) pB.glow = false; }
             if (_state.s2_arcD_drawn && _state.s2_arcB2_drawn) {
                 _state.entities.add(SimItem(type: 'intersection', id: 'C2', x: _state.s2_C2.dx, y: _state.s2_C2.dy, label: 'C2', color: Colors.orange, glow: true, offsetY: -20.0, offsetX: 15.0));
                 _state.s2_subStep = 6; _state.selectTool('ruler'); 
             } else {
                 _state.s2_subStep = 5;
             }
          }

          _state.evaluateScenarioState();
          _state.updateContextButtons(); // This guarantees UI updates like DRAW ARC button reappearing
          needsRender = true;
        }
      }
      needsRender = true;
    }
    
    if (_state.particles.isNotEmpty) {
      for (int i = _state.particles.length - 1; i >= 0; i--) {
        var p = _state.particles[i];
        p.x += p.vx; p.y += p.vy; p.vy += 0.5; p.life -= 0.03;
        if (p.life <= 0.0) _state.particles.removeAt(i);
      }
      needsRender = true;
    }
    
    if (needsRender && mounted) setState(() {});
  }

  void _handlePointerDown(PointerDownEvent event, BoxConstraints consts) {
    if (_state.simCompleted || _state.isAnimating || _state.showIntro) return;

    double canvasWidth = consts.maxWidth;
    double localCanvasX = event.localPosition.dx;
    double localCanvasY = event.localPosition.dy;

    double worldX = (localCanvasX - canvasWidth / 2.0 - _state.canvasPan.dx) / _state.canvasScale;
    double worldY = (localCanvasY - consts.maxHeight / 2.0 - _state.canvasPan.dy) / _state.canvasScale;

    _sweptAngle = 0.0;
    _arcValidated = false;
    _state.freeArcs.clear();

    for (int i = _state.entities.length - 1; i >= 0; i--) {
      var d = _state.entities[i];
      if (d.isHidden || d.onClick == null) continue;
      if (hypot(worldX - d.x, worldY - d.y) < 40.0) {
        AudioEngine.playClick();
        d.onClick!(); 
        return;
      }
    }
  }

  void _handleScaleStart(ScaleStartDetails details, BoxConstraints consts) {
    if (_state.simCompleted || _state.isAnimating || _state.showIntro) return;

    double canvasWidth = consts.maxWidth;
    double localCanvasX = details.localFocalPoint.dx;
    double localCanvasY = details.localFocalPoint.dy;

    double worldX = (localCanvasX - canvasWidth / 2.0 - _state.canvasPan.dx) / _state.canvasScale;
    double worldY = (localCanvasY - consts.maxHeight / 2.0 - _state.canvasPan.dy) / _state.canvasScale;

    _startPan = _state.canvasPan;
    _startScale = _state.canvasScale;
    _startFocal = details.localFocalPoint;

    _sweptAngle = 0.0;
    _arcValidated = false;
    _state.freeArcs.clear();

    for (int i = _state.entities.length - 1; i >= 0; i--) {
      var d = _state.entities[i];
      if (d.isHidden) continue;
      bool hit = false;
      String part = '';

      if (d.type == 'compass') { 
        double pX = d.x + d.radius * math.cos(d.angle); double pY = d.y + d.radius * math.sin(d.angle);
        double midX = d.x + (d.radius/2.0) * math.cos(d.angle); double midY = d.y + (d.radius/2.0) * math.sin(d.angle);
        if (hypot(worldX - d.x, worldY - d.y) < 50.0) { hit = true; part = 'pivot'; } 
        else if (hypot(worldX - midX, worldY - midY) < 50.0) { hit = true; part = 'pencil_resize'; }
        else if (hypot(worldX - pX, worldY - pY) < 50.0) { hit = true; part = 'pencil_tip'; } 
      } 
      else if (d.type == 'ruler') { 
        if (hypot(worldX - d.x1, worldY - d.y1) < 60.0) { hit = true; part = 'p1'; } 
        else if (hypot(worldX - d.x2, worldY - d.y2) < 60.0) { hit = true; part = 'p2'; } 
        else {
          double l2 = (d.x2 - d.x1) * (d.x2 - d.x1) + (d.y2 - d.y1) * (d.y2 - d.y1); 
          if (l2 > 0.0) { 
            double t = ((worldX - d.x1) * (d.x2 - d.x1) + (worldY - d.y1) * (d.y2 - d.y1)) / l2; 
            t = math.max<double>(0.0, math.min<double>(1.0, t)); 
            double projX = d.x1 + t * (d.x2 - d.x1); double projY = d.y1 + t * (d.y2 - d.y1); 
            if (hypot(worldX - projX, worldY - projY) < 60.0) { hit = true; part = 'body'; } 
          }
        }
      } 
      else if (d.type == 'protractor') { if (hypot(worldX - d.x, worldY - d.y) < 80.0) hit = true; } 
      else if (d.type == 'shovel') { if (hypot(worldX - d.x, worldY - d.y) < 80.0) hit = true; } 
      else if (d.type == 'paper_corner' && d.isDraggable) { if (hypot(worldX - d.x, worldY - d.y) < 80.0) hit = true; } 
      
      if (hit) {
        if (!d.isDraggable && d.type != 'compass' && d.type != 'ruler' && d.type != 'protractor' && d.type != 'paper_corner' && d.type != 'shovel') continue;
        AudioEngine.playClick();
        
        _isDraggingAnItem = true; _draggedItem = d; _dragPart = part;
        d.isDragging = true;
        
        if (d.type == 'compass' && part == 'pivot') { _dragOffsetX = d.x - worldX; _dragOffsetY = d.y - worldY; }
        else if (d.type == 'ruler') { 
            _dragRulerX1 = d.x1; _dragRulerY1 = d.y1; 
            _dragRulerX2 = d.x2; _dragRulerY2 = d.y2; 
            _dragOffsetX = worldX; _dragOffsetY = worldY; 
        }
        else if (d.type == 'shovel' || d.type == 'paper_corner' || d.type == 'protractor' || d.type == 'point' || d.type == 'intersection') {
            _dragOffsetX = d.x - worldX; _dragOffsetY = d.y - worldY;
        }

        _state.entities.removeAt(i); _state.entities.add(d);
        setState((){}); return;
      }
    }
    _isPanningCanvas = true;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, BoxConstraints consts) {
    if (_state.simCompleted || _state.isAnimating || _state.showIntro) return;

    double canvasWidth = consts.maxWidth;
    double localCanvasX = details.localFocalPoint.dx;
    double localCanvasY = details.localFocalPoint.dy;
    
    double worldX = (localCanvasX - canvasWidth / 2.0 - _state.canvasPan.dx) / _state.canvasScale;
    double worldY = (localCanvasY - consts.maxHeight / 2.0 - _state.canvasPan.dy) / _state.canvasScale;

    double dx = details.focalPointDelta.dx / _state.canvasScale;
    double dy = details.focalPointDelta.dy / _state.canvasScale;

    if (_isDraggingAnItem && _draggedItem != null) {
      var d = _draggedItem!;
      if (d.type == 'compass') {
        if (_dragPart == 'pivot') { d.targetX = worldX + _dragOffsetX; d.targetY = worldY + _dragOffsetY; d.x = worldX + _dragOffsetX; d.y = worldY + _dragOffsetY; }
        else if (_dragPart == 'pencil_resize') { d.radius = math.max<double>(20.0, hypot(worldX - d.x, worldY - d.y)); d.angle = math.atan2(worldY - d.y, worldX - d.x); }
        else if (_dragPart == 'pencil_tip') {
            double oldAngle = d.angle;
            double newAngle = math.atan2(worldY - d.y, worldX - d.x);
            d.angle = newAngle;
            double delta = newAngle - oldAngle;
            if (delta > math.pi) delta -= math.pi * 2.0;
            if (delta < -math.pi) delta += math.pi * 2.0;
            _sweptAngle += delta.abs();
            if (_sweptAngle > 0.4) _arcValidated = true;
            
            double a1 = oldAngle; double a2 = newAngle;
            if ((a1 - a2).abs() < 0.5) {
                _state.freeArcs.add({'x': d.x, 'y': d.y, 'r': d.radius, 'sa': math.min<double>(a1, a2), 'ea': math.max<double>(a1, a2), 'color': Colors.lightBlue});
            }
        }
      } else if (d.type == 'ruler') {
        if (_dragPart == 'body') { 
          d.x1 = _dragRulerX1 + (worldX - _dragOffsetX); d.y1 = _dragRulerY1 + (worldY - _dragOffsetY); 
          d.x2 = _dragRulerX2 + (worldX - _dragOffsetX); d.y2 = _dragRulerY2 + (worldY - _dragOffsetY); 
        }
        else if (_dragPart == 'p1') { d.x1 = worldX; d.y1 = worldY; }
        else if (_dragPart == 'p2') { d.x2 = worldX; d.y2 = worldY; }
      } else if (d.type == 'paper_corner') {
        d.targetX = worldX + _dragOffsetX; d.targetY = worldY + _dragOffsetY; d.x = worldX + _dragOffsetX; d.y = worldY + _dragOffsetY;
        if (hypot(d.x - _state.s4_B.dx, d.y - _state.s4_B.dy) < 100.0) d.isNearTarget = true; else d.isNearTarget = false;
        _state.paperState = 'folding';
      } else if (d.type == 'shovel') {
         d.targetX = worldX + _dragOffsetX; d.targetY = worldY + _dragOffsetY; d.x = worldX + _dragOffsetX; d.y = worldY + _dragOffsetY;
      } else {
        d.targetX = worldX + _dragOffsetX; d.targetY = worldY + _dragOffsetY; d.x = worldX + _dragOffsetX; d.y = worldY + _dragOffsetY;
      }
    } else if (_isPanningCanvas) {
      _state.canvasPan = _startPan + (details.localFocalPoint - _startFocal);
      _state.canvasScale = (_startScale * details.scale).clamp(0.2, 3.0);
    }
    setState((){});
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _isPanningCanvas = false;
    if (!_isDraggingAnItem || _draggedItem == null) return;
    _isDraggingAnItem = false;

    var d = _draggedItem!;
    d.isDragging = false; 

    if (d.type == 'compass' && _dragPart == 'pivot') {
      bool snapped = false;
      for (var p in _state.entities.where((e) => (e.type == 'point' || e.type == 'intersection') && !e.isHidden)) {
        if (hypot(d.x - p.x, d.y - p.y) < 30.0) { d.targetX = p.x; d.targetY = p.y; d.x = p.x; d.y = p.y; snapped = true; break; }
      }
      if (snapped) AudioEngine.playSnap(); else { AudioEngine.playError(); }
      _state.evaluateScenarioState();
    } else if (d.type == 'compass' && _dragPart == 'pencil_tip') {
      if (_arcValidated && !_state.isAdvancing) {
          _state.freeArcs.clear();
          _state.drawArcAction();
      } else {
          _state.freeArcs.clear();
      }
      _state.evaluateScenarioState();
    } else if (d.type == 'ruler') {
      bool p1S = false, p2S = false;
      var points = _state.entities.where((e) => (e.type == 'point' || e.type == 'intersection') && !e.isHidden);
      
      for (var p in points) {
        if ((_dragPart == 'p1' || _dragPart == 'body') && !p1S) { if (hypot(d.x1 - p.x, d.y1 - p.y) < 40.0) { d.x1 = p.x; d.y1 = p.y; p1S = true; d.hasMovedP1 = true; } }
        if ((_dragPart == 'p2' || _dragPart == 'body') && !p2S) { if (hypot(d.x2 - p.x, d.y2 - p.y) < 40.0) { d.x2 = p.x; d.y2 = p.y; p2S = true; d.hasMovedP2 = true; } }
      }
      
      if (_state.scenario == 2 && _state.step == 0 && _state.s2_subStep == 3) {
         var pA = _state.entities.cast<SimItem?>().firstWhere((e) => e?.id == 'V', orElse: () => null);
         var pC1 = _state.entities.cast<SimItem?>().firstWhere((e) => e?.id == 'C1', orElse: () => null);
         if (pA != null && pC1 != null) {
           if (hypot(d.x1 - pA.x, d.y1 - pA.y) < 40.0 && !p1S) { d.x1 = pA.x; d.y1 = pA.y; p1S = true; d.hasMovedP1 = true; }
           if (hypot(d.x2 - pC1.x, d.y2 - pC1.y) < 40.0 && !p2S) { d.x2 = pC1.x; d.y2 = pC1.y; p2S = true; d.hasMovedP2 = true; }
         }
      } else if (_state.scenario == 4 && _state.step == 0) {
         var snapPoints = [_state.s4_O, _state.s4_B, _state.s4_A, _state.s4_C];
         for (var p in snapPoints) {
            if (hypot(d.x1 - p.dx, d.y1 - p.dy) < 50.0 && !p1S) { d.x1 = p.dx; d.y1 = p.dy; p1S = true; d.hasMovedP1 = true; }
            if (hypot(d.x2 - p.dx, d.y2 - p.dy) < 50.0 && !p2S) { d.x2 = p.dx; d.y2 = p.dy; p2S = true; d.hasMovedP2 = true; }
         }
         if (p1S && p2S) _state.rulerChecked = true;
      }

      if (p1S || p2S) { AudioEngine.playSnap(); _state.evaluateScenarioState(); }
    } else if (d.type == 'shovel') {
       if (_state.scenario == 3 && _state.step == 1) {
          if (hypot(d.x - _state.s3_Treasure.dx, d.y - _state.s3_Treasure.dy) < 60.0) { // Increased hit box tolerance to 60.0
              AudioEngine.playSuccess(); d.isHidden = true; _state.treasureFound = true;
              _state.createParticles(_state.s3_Treasure.dx, _state.s3_Treasure.dy, Colors.yellow);
              _state.isAdvancing = true; Future.delayed(const Duration(milliseconds: 2500), _state.completeScenario);
          } else {
              AudioEngine.playError(); 
              // Snap back to the treasure so it doesn't disappear if zoomed in
              d.targetX = _state.s3_Treasure.dx; d.targetY = _state.s3_Treasure.dy - 150.0; 
              d.x = _state.s3_Treasure.dx; d.y = _state.s3_Treasure.dy - 150.0;
              _state.showHUD("Nothing here! Try digging at the intersection of the river and your line.");
          }
       }
    } else if (d.type == 'paper_corner') {
      if (d.isNearTarget && _state.s4_bisectorDrawn) { 
        d.targetX = _state.s4_B.dx; d.targetY = _state.s4_B.dy; d.x = _state.s4_B.dx; d.y = _state.s4_B.dy; 
        AudioEngine.playSnap(); _state.paperState = 'bird'; 
        _state.isAdvancing = true; Future.delayed(const Duration(milliseconds: 3000), _state.completeScenario);
      } else { 
        AudioEngine.playError(); d.targetX = d.homeX; d.targetY = d.homeY; d.x = d.homeX; d.y = d.homeY; _state.paperState = 'flat';
        if(!_state.s4_bisectorDrawn) _state.showHUD("You must construct the fold line first!");
      }
    }

    _draggedItem = null; _dragPart = '';
    setState((){});
  }
  
  List<TextSpan> _parseBoldText(String text) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;
    for (var match in exp.allMatches(text)) {
      if (match.start > lastMatchEnd) spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start), style: const TextStyle(fontWeight: FontWeight.normal)));
      spans.add(TextSpan(text: match.group(1), style: const TextStyle(fontWeight: FontWeight.bold)));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) spans.add(TextSpan(text: text.substring(lastMatchEnd), style: const TextStyle(fontWeight: FontWeight.normal)));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeData.dark(); 
    double sidebarWidth = MediaQuery.of(context).size.width * 0.30;
    if (sidebarWidth < 300) sidebarWidth = 300.0;
    if (sidebarWidth > 400) sidebarWidth = 400.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // Responsive Interactive Canvas (Takes remaining space beside sidebar)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _state.isSidebarOpen ? sidebarWidth : 0.0,
              right: 0.0, top: 0.0, bottom: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
                    _state.scenario == 3 ? const Color(0xFFFEF3C7) : 
                    _state.scenario == 4 ? const Color(0xFFE0F2FE) : const Color(0xFF0F172A), 
                    _state.scenario == 3 ? const Color(0xFFFEF3C7) : 
                    _state.scenario == 4 ? const Color(0xFFF0F9FF) : const Color(0xFF1E1B4B)
                  ])
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Listener(
                      onPointerDown: (e) => _handlePointerDown(e, constraints),
                      child: GestureDetector(
                        onScaleStart: (d) => _handleScaleStart(d, constraints),
                        onScaleUpdate: (d) => _handleScaleUpdate(d, constraints),
                        onScaleEnd: _handleScaleEnd,
                        child: ClipRect(
                          child: CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: LabPainter(_state),
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),
            
            // HUD Overlay on Canvas (Compact Mini-Bubble / Glass Pill)
            if (!_state.showIntro && _state.hudMessage.isNotEmpty)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _state.isSidebarOpen ? sidebarWidth : 0.0, right: 0.0, bottom: 24.0,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20.0),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        constraints: const BoxConstraints(maxWidth: 500.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(color: Colors.black12),
                          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10.0, offset: Offset(0.0, 4.0))]
                        ),
                        child: _state.simCompleted 
                           ? Row(mainAxisSize: MainAxisSize.min, children: [
                               const Icon(Icons.check_circle, color: Colors.green, size: 20.0), const SizedBox(width: 8.0),
                               Flexible(child: Text(_state.hudMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.green, fontSize: 14.0, fontWeight: FontWeight.bold))),
                             ])
                           : Text(_state.hudMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87, fontSize: 14.0, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ),

            // Canvas Action Buttons
            if (!_state.showIntro && !_state.simCompleted && _state.buttons.isNotEmpty)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _state.isSidebarOpen ? sidebarWidth : 0.0, right: 0.0, bottom: 100.0,
                child: Center(
                  child: Wrap(
                    spacing: 12.0,
                    children: _state.buttons.map((b) => ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), elevation: 8.0),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        if (b.id == 'btn_draw_arc') _state.drawArcAction();
                        else if (b.id == 'btn_draw_line') _state.drawLineAction();
                        else if (b.id == 'btn_unfold') _state.unfoldAction();
                        else if (b.id == 'btnComplete') _state.completePatternAction();
                      },
                      icon: Icon(b.id == 'btn_draw_line' ? Icons.straighten : b.id == 'btn_unfold' ? Icons.unfold_more : b.id == 'btnComplete' ? Icons.auto_awesome : Icons.edit), 
                      label: Text(_state.t(b.id), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                    )).toList(),
                  ),
                ),
              ),

            // Tools Selection Panel
            if (!_state.showIntro && !_state.simCompleted)
              Positioned(
                top: 100.0, right: 24.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: Colors.indigoAccent.withOpacity(0.5)),
                        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10.0, offset: Offset(0.0, 4.0))]
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_state.scenario == 0 && _state.step <= 4 || _state.scenario == 1 || _state.scenario == 2 && _state.step <= 1 || _state.scenario == 3 && _state.step == 0 || _state.scenario == 4 && _state.step == 0)
                            _toolBtn(Icons.architecture, 'compass'),
                          if (_state.scenario == 0 && _state.step == 5 || _state.scenario == 1 && _state.step == 2 || _state.scenario == 2 && (_state.s2_subStep == 3 || _state.s2_subStep == 6) || _state.scenario == 3 && _state.step == 0 || _state.scenario == 4 && _state.step == 0)
                            _toolBtn(Icons.straighten, 'ruler'),
                          if (_state.scenario == 4 && _state.step >= 2)
                            _toolBtn(Icons.speed, 'protractor'),
                          if (_state.scenario == 3 && _state.step == 1)
                            _toolBtn(Icons.construction, 'shovel'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _state.isSidebarOpen ? 0.0 : -sidebarWidth,
              top: 0.0, bottom: 0.0, width: sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.95),
                  border: Border(right: BorderSide(color: Colors.indigo.withOpacity(0.3))),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 15.0, offset: Offset(5.0,0.0))]
                ),
                child: ListView(
                  controller: _sidebarScrollCtrl,
                  padding: EdgeInsets.zero,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.only(top: 24.0, left: 20.0, right: 20.0, bottom: 20.0),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40.0), // Space for toggle button
                          Text(_state.t('shutterTitle'), style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.indigoAccent, height: 1.2)),
                          const SizedBox(height: 6.0),
                          Text(_state.t('appSubtitle'), style: const TextStyle(fontSize: 11.0, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    
                    // Controls
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      decoration: const BoxDecoration(color: Color(0xFF1E293B), border: Border(bottom: BorderSide(color: Colors.white24))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              List<String> langs = ['en', 'hi'];
                              int idx = langs.indexOf(_state.lang);
                              _state.setLang(langs[(idx + 1) % langs.length]);
                            },
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              height: 32.0, padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8.0), border: Border.all(color: Colors.indigoAccent.withOpacity(0.5))),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.language, color: Colors.indigoAccent, size: 16.0), const SizedBox(width: 8.0), Text(_state.lang.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0, color: Colors.white))]),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _state.resetActivity, icon: const Icon(Icons.refresh, size: 14.0), label: Text(_state.t('reset'), style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8.0), minimumSize: const Size(0.0, 32.0)),
                          )
                        ],
                      ),
                    ),
                    
                    // Scenario Dropdown
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_state.t('selectScenario').toUpperCase(), style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                          const SizedBox(height: 8.0),
                          DropdownButtonFormField<int>(
                            isExpanded: true, dropdownColor: const Color(0xFF1E293B), value: _state.scenario,
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)),
                            items: [0,1,2,3,4].map((i) => DropdownMenuItem(value: i, child: Text(_state.getScenarioText(i, 'title'), style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (v) { if (v != null) _state.loadScenario(v); },
                          ),
                        ],
                      ),
                    ),
                      
                    // Mission Objective Target Output
                    Container(
                      margin: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0), padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(8.0), border: Border.all(color: Colors.indigo.withOpacity(0.3))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(_state.t('missionObj'), style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                          const SizedBox(height: 4.0),
                          Text(_state.getScenarioText(_state.scenario, 'objective'), style: const TextStyle(fontSize: 13.0, color: Colors.white)),
                        ]
                      )
                    ),
                    
                    // Generated Steps
                    ...List.generate(
                      ((translations['en'] as Map<String, dynamic>)['scenarios'] as List)[_state.scenario]['steps'].length,
                      (i) {
                        bool isPast = i < _state.step;
                        bool isCurrent = i == _state.step && !_state.simCompleted;
                        return Opacity(
                          opacity: (isPast || isCurrent || _state.simCompleted) ? 1.0 : 0.4,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12.0, left: 20.0, right: 20.0), padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: isCurrent ? Colors.indigoAccent : Colors.white24, width: isCurrent ? 2.0 : 1.0),
                              borderRadius: BorderRadius.circular(8.0), color: isCurrent ? Colors.indigo.withOpacity(0.1) : const Color(0xFF0F172A)
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isCurrent) const Padding(padding: EdgeInsets.only(top: 2.0, right: 8.0), child: Icon(Icons.adjust, color: Colors.indigoAccent, size: 16.0))
                                else const Padding(padding: EdgeInsets.only(top: 2.0, right: 8.0), child: Icon(Icons.check_circle, color: Colors.green, size: 16.0)),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(fontSize: 13.0, color: isCurrent ? Colors.white : Colors.white70, fontFamily: 'Plus Jakarta Sans', height: 1.4),
                                      children: _parseBoldText(_state.getStepText(_state.scenario, i, 'text'))
                                    )
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    ),
                    
                    const SizedBox(height: 20.0),
                    
                    // Sidebar Footer
                    Container(padding: const EdgeInsets.all(12.0), color: Colors.black26, width: double.infinity, child: Text(_state.t('footer'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: Colors.grey)))
                  ],
                ),
              ),
            ),

            // Floating Active Step (when sidebar is closed)
            if (!_state.isSidebarOpen && !_state.showIntro && !_state.simCompleted)
              Positioned(
                left: _floatingStepPos.dx, top: _floatingStepPos.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _floatingStepPos = Offset(
                        (_floatingStepPos.dx + details.delta.dx).clamp(0.0, MediaQuery.of(context).size.width - 280.0),
                        (_floatingStepPos.dy + details.delta.dy).clamp(0.0, MediaQuery.of(context).size.height - 150.0)
                      );
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        width: 280.0,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.indigoAccent.withOpacity(0.5)),
                          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10.0, offset: Offset(0.0, 4.0))]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${_state.t('stepLabel')} ${_state.step + 1}", style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                                const Icon(Icons.drag_indicator, color: Colors.white54, size: 16.0)
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 13.0, color: Colors.white, fontFamily: 'Plus Jakarta Sans', height: 1.4),
                                children: _parseBoldText(_state.getStepText(_state.scenario, _state.step, 'text'))
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ),

            // Floating Top-Left Sidebar Toggle Button
            Positioned(
              top: 16.0, left: 16.0, 
              child: IconButton(
                icon: Icon(_state.isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent, iconSize: 28.0,
                onPressed: () { HapticFeedback.lightImpact(); _state.toggleSidebar(); },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0), side: BorderSide(color: Colors.orange.withOpacity(0.8))),
                ),
              ),
            ),
            
            // Big Success Popup (only after ALL scenarios completed)
            if (_state.showSuccessPopup)
              Positioned(
                left: _successPopupPos.dx, top: _successPopupPos.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _successPopupPos = Offset(
                        (_successPopupPos.dx + details.delta.dx).clamp(0.0, MediaQuery.of(context).size.width - 320.0),
                        (_successPopupPos.dy + details.delta.dy).clamp(0.0, MediaQuery.of(context).size.height - 250.0)
                      );
                    });
                  },
                  child: Container(
                    width: 320.0, padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.95), borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: Colors.amber, width: 3.0), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15.0, offset: Offset(5.0, 5.0))],
                    ),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.amber, size: 50.0), const SizedBox(height: 12.0),
                              Text(_state.t('finalSuccessTitle'), style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                              const SizedBox(height: 8.0),
                              const Text("You've mastered Angle Bisections!", textAlign: TextAlign.center, style: TextStyle(color: Colors.amber, fontStyle: FontStyle.italic, fontSize: 13.0)),
                              const SizedBox(height: 20.0),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0)),
                                onPressed: () { setState(() => _state.showSuccessPopup = false); _state.resetActivity(); },
                                icon: const Icon(Icons.refresh, size: 18.0),
                                label: const Text("Restart Lab", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ),
                        Positioned(
                          top: -10.0, right: -10.0,
                          child: IconButton(icon: const Icon(Icons.close, color: Colors.white), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => setState(() => _state.showSuccessPopup = false)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Shutter Screen Overlay (Re-introduced full-screen sliding shutter)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: _state.showIntro ? 0 : -MediaQuery.of(context).size.height,
              left: 0, right: 0, height: MediaQuery.of(context).size.height,
              child: Container(
                color: const Color(0xFF0F172A),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.call_split, color: Colors.indigoAccent, size: 80.0),
                      const SizedBox(height: 20.0),
                      Text(_state.t('shutterTitle'), style: const TextStyle(color: Colors.white, fontSize: 32.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 10.0),
                      Text(_state.t('appSubtitle'), style: const TextStyle(color: Colors.indigo, fontSize: 18.0)),
                      const SizedBox(height: 40.0),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0)),
                        onPressed: () { AudioEngine.playSuccess(); setState(() => _state.showIntro = false); },
                        icon: const Icon(Icons.play_circle, size: 28.0),
                        label: Text(_state.t('enterLab'), style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolBtn(IconData icon, String type) {
    bool active = _state.activeTool == type;
    return GestureDetector(
      onTap: () => _state.selectTool(type),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        width: 48.0, height: 48.0, 
        decoration: BoxDecoration(color: active ? Colors.indigo : Colors.white10, shape: BoxShape.circle, boxShadow: active ? [const BoxShadow(color: Colors.indigoAccent, blurRadius: 10.0)] : []),
        child: Icon(icon, color: Colors.white, size: 24.0),
      ),
    );
  }
}

class LabPainter extends CustomPainter {
  final LabState state;
  LabPainter(this.state) : super(repaint: state);

  void _drawPizzaSlice(Canvas canvas, double cx, double cy, double r, double startAng, double endAng, double offsetDistance) {
    double midAng = (startAng + endAng) / 2.0;
    double normL = midAng - math.pi / 2.0;
    double normR = midAng + math.pi / 2.0;
    double ox = cx, oy = cy;
    if (offsetDistance != 0.0) {
      if (startAng == state.s0_angleStart) { ox = cx + offsetDistance * math.cos(normL); oy = cy + offsetDistance * math.sin(normL); }
      else { ox = cx + offsetDistance * math.cos(normR); oy = cy + offsetDistance * math.sin(normR); }
    }
    canvas.save();
    canvas.translate(ox, oy);

    Path base = Path()..moveTo(0.0,0.0)..arcTo(Rect.fromCircle(center: Offset.zero, radius: r + 15.0), startAng, endAng - startAng, false)..close();
    canvas.drawPath(base, Paint()..color = Colors.amber[700]!);
    canvas.drawPath(base, Paint()..color = const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=4.0);
    
    Path cheese = Path()..moveTo(0.0,0.0)..arcTo(Rect.fromCircle(center: Offset.zero, radius: r), startAng, endAng - startAng, false)..close();
    canvas.drawPath(cheese, Paint()..color = Colors.yellow[400]!);
    canvas.drawPath(cheese, Paint()..color = const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=4.0);

    canvas.drawCircle(Offset(r*0.3 * math.cos(startAng + 0.2), r*0.3 * math.sin(startAng + 0.2)), 4.0, Paint()..color = Colors.amber[600]!);
    canvas.drawCircle(Offset(r*0.6 * math.cos(endAng - 0.2), r*0.6 * math.sin(endAng - 0.2)), 4.0, Paint()..color = Colors.amber[600]!);

    var pepps = [
        {'pr': r*0.4, 'pa': state.s0_angleStart + (state.s0_angleEnd - state.s0_angleStart)*0.3},
        {'pr': r*0.7, 'pa': state.s0_angleStart + (state.s0_angleEnd - state.s0_angleStart)*0.7},
        {'pr': r*0.8, 'pa': state.s0_angleStart + (state.s0_angleEnd - state.s0_angleStart)*0.2},
        {'pr': r*0.5, 'pa': state.s0_angleStart + (state.s0_angleEnd - state.s0_angleStart)*0.8}
    ];
    for (var p in pepps) {
        if (p['pa']! >= startAng && p['pa']! <= endAng) {
            double px = p['pr']! * math.cos(p['pa']!); double py = p['pr']! * math.sin(p['pa']!);
            canvas.drawCircle(Offset(px, py), 15.0, Paint()..color = Colors.red[500]!);
            canvas.drawCircle(Offset(px, py), 15.0, Paint()..color = const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=2.0);
            canvas.drawCircle(Offset(px - 4.0, py - 4.0), 3.0, Paint()..color = Colors.red[900]!);
            canvas.drawCircle(Offset(px + 4.0, py + 3.0), 2.0, Paint()..color = Colors.red[900]!);
        }
    }
    
    var mushs = [
        {'pr': r*0.55, 'pa': state.s0_angleStart + (state.s0_angleEnd - state.s0_angleStart)*0.5, 'rot': 0.5},
        {'pr': r*0.85, 'pa': state.s0_angleStart + (state.s0_angleEnd - state.s0_angleStart)*0.8, 'rot': -0.2}
    ];
    for (var m in mushs) {
        if (m['pa']! >= startAng && m['pa']! <= endAng) {
            canvas.save();
            canvas.translate(m['pr']! * math.cos(m['pa']!), m['pr']! * math.sin(m['pa']!)); canvas.rotate(m['rot']!);
            canvas.drawRect(const Rect.fromLTRB(-4.0, 0.0, 4.0, 10.0), Paint()..color=Colors.blueGrey[50]!);
            canvas.drawRect(const Rect.fromLTRB(-4.0, 0.0, 4.0, 10.0), Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=2.0);
            canvas.drawArc(const Rect.fromLTRB(-10.0, -10.0, 10.0, 10.0), math.pi, math.pi, true, Paint()..color=Colors.blueGrey[50]!);
            canvas.drawArc(const Rect.fromLTRB(-10.0, -10.0, 10.0, 10.0), math.pi, math.pi, true, Paint()..color=const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=2.0);
            canvas.restore();
        }
    }
    canvas.restore();
  }

  void _drawWoodStick(Canvas canvas, Offset p1, Offset p2) {
    canvas.drawLine(Offset(p1.dx+5.0, p1.dy+5.0), Offset(p2.dx+5.0, p2.dy+5.0), Paint()..color=Colors.black.withOpacity(0.4)..strokeWidth=14.0..strokeCap=StrokeCap.round);
    canvas.drawLine(p1, p2, Paint()..color=Colors.brown[800]!..strokeWidth=12.0..strokeCap=StrokeCap.round);
    canvas.drawLine(p1, p2, Paint()..color=Colors.brown[600]!..strokeWidth=8.0..strokeCap=StrokeCap.round);
    canvas.drawLine(p1, p2, Paint()..color=Colors.orange[600]!..strokeWidth=2.0..strokeCap=StrokeCap.round);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2.0 + state.canvasPan.dx, size.height / 2.0 + state.canvasPan.dy);
    canvas.scale(state.canvasScale);

    if (state.scenario != 3 && state.scenario != 4) {
      final gridPaint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth=1.0;
      for (double i = -1500.0; i < 1500.0; i += 40.0) {
        canvas.drawLine(Offset(i, -1500.0), Offset(i, 1500.0), gridPaint);
        canvas.drawLine(Offset(-1500.0, i), Offset(1500.0, i), gridPaint);
      }
    }

    _drawScenarioGeometry(canvas);

    var sorted = List<SimItem>.from(state.entities);
    sorted.sort((a,b) => (a.isDragging ? 100 : a.z).compareTo(b.isDragging ? 100 : b.z));
    
    for (var d in sorted) {
      if (d.isHidden) continue;
      if (state.scenario == 0 && state.s0_pizzaSplit) continue;
      if (state.scenario == 1 && state.s1_kiteFlying) continue;
      if (state.scenario == 4 && d.type == 'paper_corner' && state.paperState != 'flat') continue;
      
      canvas.save();
      if (d.type != 'eye_arc') canvas.translate(d.x, d.y);
      if (d.isDragging && d.type != 'ruler' && d.type != 'knife') canvas.scale(1.1);
      
      if (d.type == 'point' || d.type == 'intersection') {
        if (d.glow) {
          canvas.drawCircle(Offset.zero, 25.0, Paint()..color=Colors.orangeAccent.withOpacity(0.4)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 10.0));
        }
        canvas.drawCircle(Offset.zero, 5.0, Paint()..color = Colors.white);
        canvas.drawCircle(Offset.zero, 5.0, Paint()..color = const Color(0xFF0F172A)..style=PaintingStyle.stroke..strokeWidth=2.0);
        _drawText(canvas, d.label, d.offsetX, d.offsetY, color: Colors.white, size: 16.0, weight: FontWeight.bold);
      } 
      else if (d.type == 'compass') _drawCompass(canvas, d);
      else if (d.type == 'ruler') _drawRuler(canvas, d);
      else if (d.type == 'protractor') _drawProtractor(canvas, d);
      else if (d.type == 'shovel') _drawShovel(canvas, d);
      else if (d.type == 'paper_corner') {
        canvas.drawCircle(Offset.zero, 30.0, Paint()..color = Colors.indigo.withOpacity(0.5));
        canvas.drawCircle(Offset.zero, 10.0, Paint()..color = Colors.white);
      }
      else if (d.type == 'treasure') {
        canvas.drawRect(const Rect.fromLTRB(-20.0, -15.0, 20.0, 10.0), Paint()..color = Colors.brown);
        canvas.drawArc(const Rect.fromLTRB(-20.0, -35.0, 20.0, 5.0), math.pi, math.pi, true, Paint()..color = Colors.brown[800]!);
      }
      
      canvas.restore();
    }
    
    for (var p in state.particles) {
      canvas.drawCircle(Offset(p.x, p.y), 4.0, Paint()..color = p.color.withOpacity(p.life));
    }
    
    if (state.scenario == 4 && state.step == 2) {
      canvas.save();
      canvas.translate(0.0, 100.0);
      if (state.protChecked && state.rulerChecked) {
        _drawText(canvas, state.tCanvas('confirmed'), 0.0, 0.0, color: Colors.green, size: 24.0, weight: FontWeight.bold);
      } else if (state.protChecked) {
        _drawText(canvas, state.tCanvas('verified90'), 0.0, 0.0, color: Colors.lightBlue, size: 20.0, weight: FontWeight.bold);
      } else if (state.rulerChecked) {
        _drawText(canvas, state.tCanvas('verifiedLen'), 0.0, 0.0, color: Colors.lightBlue, size: 20.0, weight: FontWeight.bold);
      }
      canvas.restore();
    }

    canvas.restore();
  }

  void _drawScenarioGeometry(Canvas canvas) {
    if (state.scenario == 0) {
      canvas.drawCircle(Offset.zero, 320.0, Paint()..color=const Color(0xFF1E293B));
      double splitDist = 0.0;
      if (state.s0_pizzaSplit) {
         state.s0_splitAnimTime += 0.02; if (state.s0_splitAnimTime > 1.0) state.s0_splitAnimTime = 1.0;
         splitDist = 20.0 * (1.0 - math.pow(1.0 - state.s0_splitAnimTime, 3).toDouble());
      }
      double midAng = (state.s0_angleStart + state.s0_angleEnd) / 2.0;
      
      if (state.s0_pizzaSplit) {
         _drawPizzaSlice(canvas, state.s0_O.dx, state.s0_O.dy, state.s0_pizzaRadius, state.s0_angleStart, midAng, splitDist);
         _drawPizzaSlice(canvas, state.s0_O.dx, state.s0_O.dy, state.s0_pizzaRadius, midAng, state.s0_angleEnd, splitDist);
      } else {
         _drawPizzaSlice(canvas, state.s0_O.dx, state.s0_O.dy, state.s0_pizzaRadius, state.s0_angleStart, state.s0_angleEnd, 0.0);
         if (state.s0_A != Offset.zero && state.s0_B != Offset.zero && state.step >= 1 && state.step <= 4) {
             canvas.drawLine(state.s0_O, state.s0_A, Paint()..color=Colors.white.withOpacity(0.5)..strokeWidth=2.0..style=PaintingStyle.stroke);
             canvas.drawLine(state.s0_O, state.s0_B, Paint()..color=Colors.white.withOpacity(0.5)..strokeWidth=2.0..style=PaintingStyle.stroke);
         }
      }
    } 
    else if (state.scenario == 1) {
      var O = state.s1_O; var ang1 = state.s1_ang1; var ang2 = state.s1_ang2; double midAng = (ang1 + ang2) / 2.0; double sparLen = 220.0;
      var X = Offset(O.dx + sparLen * math.cos(ang1), O.dy + sparLen * math.sin(ang1)); var Y = Offset(O.dx + sparLen * math.cos(ang2), O.dy + sparLen * math.sin(ang2));
      double tailLen = 380.0; var T = Offset(O.dx + tailLen * math.cos(midAng), O.dy + tailLen * math.sin(midAng)); var M = Offset((X.dx + Y.dx)/2.0, (X.dy + Y.dy)/2.0);

      canvas.drawRect(const Rect.fromLTRB(-2000.0, -2000.0, 2000.0, 2000.0), Paint()..color=Colors.brown[800]!);
      for(double i=-1000.0; i<1000.0; i+=80.0) { canvas.drawLine(Offset(-1000.0, i), Offset(1000.0, i), Paint()..color=Colors.brown[900]!..strokeWidth=3.0); }

      canvas.save();
      if (state.s1_kiteFlying) {
         state.s1_flyAnimTime += 0.03; double flyY = -state.s1_flyAnimTime * 40.0; double flyX = -state.s1_flyAnimTime * 20.0; double wobble = math.sin(state.s1_flyAnimTime * 2.0) * 0.05;
         double kiteCX = (O.dx + T.dx) / 2.0; double kiteCY = (O.dy + T.dy) / 2.0;
         canvas.translate(kiteCX + flyX, kiteCY + flyY); canvas.rotate(wobble); canvas.translate(-kiteCX, -kiteCY);
      }
      
      if (state.s1_kiteFlying) {
         Path redP = Path()..moveTo(X.dx, X.dy)..lineTo(O.dx, O.dy)..lineTo(M.dx, M.dy)..close(); canvas.drawPath(redP, Paint()..color=Colors.red);
         Path blueP1 = Path()..moveTo(Y.dx, Y.dy)..lineTo(O.dx, O.dy)..lineTo(M.dx, M.dy)..close(); canvas.drawPath(blueP1, Paint()..color=Colors.blue);
         Path blueP2 = Path()..moveTo(X.dx, X.dy)..lineTo(T.dx, T.dy)..lineTo(M.dx, M.dy)..close(); canvas.drawPath(blueP2, Paint()..color=Colors.blue);
         Path redP2 = Path()..moveTo(Y.dx, Y.dy)..lineTo(T.dx, T.dy)..lineTo(M.dx, M.dy)..close(); canvas.drawPath(redP2, Paint()..color=Colors.red);
         canvas.drawLine(O, T, Paint()..color=Colors.white..strokeWidth=6.0..strokeCap=StrokeCap.round);
         canvas.drawLine(X, Y, Paint()..color=Colors.white..strokeWidth=6.0..strokeCap=StrokeCap.round);
      } else {
         _drawWoodStick(canvas, O, X); _drawWoodStick(canvas, O, Y);
         _drawText(canvas, "O", O.dx, O.dy - 30.0, color: Colors.yellow[100]!, size: 20.0);
         _drawText(canvas, "X", X.dx - 20.0, X.dy + 20.0, color: Colors.yellow[100]!, size: 20.0);
         _drawText(canvas, "Y", Y.dx + 20.0, Y.dy + 20.0, color: Colors.yellow[100]!, size: 20.0);
      }
      canvas.restore();
    } 
    else if (state.scenario == 2) {
      if (state.s2_animatingPattern) {
         state.s2_patternAnim += 0.008; if (state.s2_patternAnim > 1.0) state.s2_patternAnim = 1.0;
         double ease = 1.0 - math.pow(1.0 - state.s2_patternAnim, 3).toDouble();
         canvas.translate(state.s2_V.dx * (1.0-ease), state.s2_V.dy * (1.0-ease));
         if (ease > 0.1) { canvas.drawCircle(Offset.zero, state.s2_R, Paint()..color=Colors.lightBlue.withOpacity(ease*0.3)..style=PaintingStyle.stroke); }
         int numLines = (ease * 8.0).floor();
         for (int i=0; i<numLines; i++) {
             canvas.drawLine(Offset.zero, Offset(state.s2_R*1.2*math.cos(i*math.pi/4.0), state.s2_R*1.2*math.sin(i*math.pi/4.0)), Paint()..color=Colors.red..strokeWidth=2.0);
             canvas.drawLine(Offset.zero, Offset(-state.s2_R*1.2*math.cos(i*math.pi/4.0), -state.s2_R*1.2*math.sin(i*math.pi/4.0)), Paint()..color=Colors.red..strokeWidth=2.0);
         }
         if (ease > 0.5) {
             double petalEase = (ease - 0.5) * 2.0;
             for (int i=0; i<8; i++) {
                 canvas.save(); canvas.rotate(i*math.pi/4.0);
                 double petalLen = state.s2_R * petalEase; double cpOff = (state.s2_R * 0.35) * petalEase;
                 Path p = Path()..moveTo(0.0,0.0)..quadraticBezierTo(petalLen/2.0, cpOff, petalLen, 0.0)..quadraticBezierTo(petalLen/2.0, -cpOff, 0.0, 0.0);
                 canvas.drawPath(p, Paint()..color=Colors.yellow.withOpacity(0.4));
                 canvas.drawPath(p, Paint()..color=Colors.lightBlue..style=PaintingStyle.stroke..strokeWidth=4.0);
                 canvas.drawLine(Offset.zero, Offset(petalLen*0.8, 0.0), Paint()..color=Colors.amber..strokeWidth=3.0);
                 canvas.restore();
             }
         }
      } else {
         canvas.drawLine(state.s2_V, Offset(state.s2_V.dx + 350.0, state.s2_V.dy), Paint()..color=Colors.lightBlue..strokeWidth=4.0..strokeCap=StrokeCap.round);
         canvas.drawLine(state.s2_V, Offset(state.s2_V.dx, state.s2_V.dy - 350.0), Paint()..color=Colors.lightBlue..strokeWidth=4.0..strokeCap=StrokeCap.round);
         canvas.drawArc(Rect.fromCircle(center: state.s2_V, radius: 40.0), -math.pi/2.0, math.pi/2.0, false, Paint()..color=Colors.blueGrey..strokeWidth=2.0..style=PaintingStyle.stroke);
         _drawText(canvas, "90°", state.s2_V.dx + 15.0, state.s2_V.dy - 15.0, color: Colors.white, size: 18.0);
         if (state.s2_45_drawn) {
             canvas.drawArc(Rect.fromCircle(center: state.s2_V, radius: 70.0), -math.pi/4.0, math.pi/4.0, false, Paint()..color=Colors.blueGrey..strokeWidth=2.0..style=PaintingStyle.stroke);
         }
      }
    } 
    else if (state.scenario == 3) {
      canvas.drawRect(const Rect.fromLTRB(-1000.0, -1000.0, 2000.0, 2000.0), Paint()..color=const Color(0xFFFEF3C7));
      for (double i = -500.0; i <= 500.0; i += 40.0) {
         canvas.drawLine(Offset(i, -500.0), Offset(i, 500.0), Paint()..color=Colors.brown[700]!.withOpacity(0.1));
         canvas.drawLine(Offset(-500.0, i), Offset(500.0, i), Paint()..color=Colors.brown[700]!.withOpacity(0.1));
      }
      var P = state.s3_P; var T = state.s3_Treasure;
      Path river = Path();
      for (double y = -400.0; y <= 400.0; y += 20.0) {
         double x = T.dx + math.sin((y - T.dy)*0.02)*40.0 + (y - T.dy)*0.2;
         if (y == -400.0) river.moveTo(x, y); else river.lineTo(x, y);
      }
      canvas.drawPath(river, Paint()..color=Colors.lightBlue..strokeWidth=25.0..strokeJoin=StrokeJoin.round..style=PaintingStyle.stroke);
      canvas.drawLine(P, Offset(P.dx + 180.0 * math.cos(state.s3_ang1), P.dy + 180.0 * math.sin(state.s3_ang1)), Paint()..color=Colors.brown[700]!..strokeWidth=4.0);
      canvas.drawLine(P, Offset(P.dx + 180.0 * math.cos(state.s3_ang2), P.dy + 180.0 * math.sin(state.s3_ang2)), Paint()..color=Colors.brown[700]!..strokeWidth=4.0);
      
      canvas.save(); canvas.translate(P.dx + 100.0 * math.cos(state.s3_ang1), P.dy + 100.0 * math.sin(state.s3_ang1) - 15.0); canvas.rotate(state.s3_ang1); _drawText(canvas, state.tCanvas('oldMill'), 0.0, 0.0, color: Colors.brown[900]!, size: 14.0); canvas.restore();
      canvas.save(); canvas.translate(P.dx + 100.0 * math.cos(state.s3_ang2), P.dy + 100.0 * math.sin(state.s3_ang2) + 20.0); canvas.rotate(state.s3_ang2); _drawText(canvas, state.tCanvas('ship'), 0.0, 0.0, color: Colors.brown[900]!, size: 14.0); canvas.restore();
    }
    else if (state.scenario == 4) {
      canvas.drawRect(const Rect.fromLTRB(-1000.0, -1000.0, 2000.0, 2000.0), Paint()..color=const Color(0xFFE0F2FE));
      var O = state.s4_O; var C = state.s4_C;
      
      if (state.paperState == 'flat') {
         var corner = state.entities.firstWhere((e)=>e.type=='paper_corner', orElse:()=>SimItem(type:'',x:0.0,y:0.0));
         if (corner.id.isNotEmpty && (corner.isDragging || state.paperState == 'folding')) {
             Path p = Path()..moveTo(-150.0, -150.0)..lineTo(150.0, -150.0)..lineTo(corner.x, corner.y)..lineTo(-150.0, 150.0)..close();
             canvas.drawPath(p, Paint()..color=Colors.white);
             canvas.drawPath(p, Paint()..color=Colors.indigo..strokeWidth=4.0..style=PaintingStyle.stroke);
         } else {
             canvas.drawRect(const Rect.fromLTRB(-150.0, -150.0, 150.0, 150.0), Paint()..color=Colors.white);
             canvas.drawLine(const Offset(-150.0, 150.0), const Offset(150.0, 150.0), Paint()..color=Colors.indigo..strokeWidth=4.0);
             canvas.drawLine(const Offset(-150.0, 150.0), const Offset(-150.0, -150.0), Paint()..color=Colors.indigo..strokeWidth=4.0);
         }
      } else if (state.paperState == 'folded') {
         canvas.drawRect(const Rect.fromLTRB(-150.0, -150.0, 150.0, 150.0), Paint()..color=Colors.white);
         Path folded = Path()..moveTo(-150.0, 150.0)..lineTo(150.0, -150.0)..lineTo(-150.0, -150.0)..close();
         canvas.drawPath(folded, Paint()..color=Colors.black12);
      } else if (state.paperState == 'bird') {
         state.s4_birdAnimTime += 0.02; double bt = math.min<double>(1.0, state.s4_birdAnimTime);
         double flyX = bt * 200.0; double flyY = -bt * 200.0; double scl = 1.0 - bt * 0.4;
         canvas.translate(flyX, flyY); canvas.scale(scl, scl);
         Path p1 = Path()..moveTo(0.0,0.0)..lineTo(-40.0,-100.0)..lineTo(30.0,-50.0)..close(); canvas.drawPath(p1, Paint()..color=Colors.blue[400]!);
         Path p2 = Path()..moveTo(-50.0,40.0)..lineTo(0.0,0.0)..lineTo(50.0,20.0)..lineTo(80.0,0.0)..lineTo(40.0,-20.0)..close(); canvas.drawPath(p2, Paint()..color=Colors.green[400]!);
      }

      if (state.s4_bisectorDrawn && state.paperState != 'bird') {
         canvas.drawLine(O, C, Paint()..color=Colors.black..strokeWidth=2.0);
      }
    }

    for (var l in state.lines) {
      if (state.scenario == 0 && state.s0_pizzaSplit) continue;
      if (state.scenario == 1 && state.s1_kiteFlying) continue;
      if (state.scenario == 2 && state.s2_animatingPattern) continue;
      Paint p = Paint()..color = l['color']..strokeWidth = l['w']..strokeCap=StrokeCap.round;
      canvas.drawLine(Offset(l['x1'], l['y1']), Offset(l['x2'], l['y2']), p);
    }
    
    for (var a in state.freeArcs) {
      if (state.scenario == 0 && state.s0_pizzaSplit) continue;
      if (state.scenario == 1 && state.s1_kiteFlying) continue;
      if (state.scenario == 4 && state.s4_bisectorDrawn) continue;
      canvas.drawArc(Rect.fromCircle(center: Offset(a['x'], a['y']), radius: a['r']), a['sa'], a['ea'] - a['sa'], false, Paint()..color=a['color']..strokeWidth=2.0..style=PaintingStyle.stroke);
    }

    for (var a in state.arcs) {
      if (state.scenario == 0 && state.s0_pizzaSplit) continue;
      if (state.scenario == 1 && state.s1_kiteFlying) continue;
      if (state.scenario == 2 && state.s2_animatingPattern) continue;
      if (state.scenario == 4 && state.s4_bisectorDrawn) continue;
      double p = a.containsKey('p') ? a['p'] : 1.0;
      double sweep = a['targetEa'] - a['sa'];
      if (sweep != 0.0) {
        canvas.drawArc(Rect.fromCircle(center: Offset(a['x'], a['y']), radius: a['r']), a['sa'], sweep * p, false, Paint()..color=Colors.lightBlue..strokeWidth=2.0..style=PaintingStyle.stroke);
      }
    }
  }

  void _drawCompass(Canvas canvas, SimItem d) {
    canvas.save();
    canvas.rotate(d.angle);
    double hx = d.radius / 2.0; double hy = -100.0;
    canvas.drawLine(Offset.zero, Offset(hx, hy), Paint()..color=Colors.blueGrey[400]!..strokeWidth=4.0..strokeCap=StrokeCap.round);
    canvas.drawLine(Offset(d.radius, 0.0), Offset(hx, hy), Paint()..color=Colors.blueGrey[400]!..strokeWidth=4.0..strokeCap=StrokeCap.round);
    
    // Needle
    canvas.drawLine(Offset.zero, Offset(hx/2.0, hy/2.0), Paint()..color=Colors.grey..strokeWidth=2.0);
    // Pencil body
    canvas.save(); canvas.translate(d.radius, 0.0); canvas.rotate(math.pi/2.0 + math.atan2(hy, hx - d.radius));
    canvas.drawRect(const Rect.fromLTRB(-6.0, -55.0, 6.0, -15.0), Paint()..color=Colors.yellow[600]!);
    Path pTip = Path()..moveTo(-6.0, -15.0)..lineTo(6.0, -15.0)..lineTo(0.0,0.0)..close(); canvas.drawPath(pTip, Paint()..color=Colors.yellow[200]!);
    Path gTip = Path()..moveTo(-2.0, -5.0)..lineTo(2.0, -5.0)..lineTo(0.0,0.0)..close(); canvas.drawPath(gTip, Paint()..color=Colors.blueGrey[800]!);
    canvas.restore();
    
    // Handle
    canvas.drawRect(Rect.fromLTRB(hx-6.0, hy-30.0, hx+6.0, hy), Paint()..color=Colors.red);
    canvas.drawCircle(Offset(hx, hy), 8.0, Paint()..color=Colors.blueGrey[200]!);

    canvas.drawCircle(Offset(hx, hy), 25.0, Paint()..color=Colors.white.withOpacity(0.01)); // drag hit area

    if (d.isDragging) {
      canvas.save(); canvas.rotate(-d.angle); _drawText(canvas, "r=${d.radius.round()}", 30.0, -30.0, color: Colors.green, weight: FontWeight.bold); canvas.restore();
    }
    canvas.restore();
  }

  void _drawRuler(Canvas canvas, SimItem d) {
    canvas.save();
    canvas.translate(-d.x, -d.y);
    double dx = d.x2 - d.x1; double dy = d.y2 - d.y1; double dist = hypot(dx, dy); double angle = math.atan2(dy, dx);
    canvas.translate(d.x1, d.y1); canvas.rotate(angle);
    canvas.drawRRect(RRect.fromLTRBR(-20.0, -15.0, dist+40.0, 15.0, const Radius.circular(8.0)), Paint()..color=Colors.white.withOpacity(0.85));
    canvas.drawRRect(RRect.fromLTRBR(-20.0, -15.0, dist+40.0, 15.0, const Radius.circular(8.0)), Paint()..color=Colors.blueGrey..style=PaintingStyle.stroke..strokeWidth=2.0);
    for (double i=0.0; i<=dist; i+=10.0) canvas.drawRect(Rect.fromLTRB(i, -15.0, i+1.0, i%50.0==0.0?-5.0:-10.0), Paint()..color=Colors.black);
    canvas.drawCircle(Offset.zero, 6.0, Paint()..color=Colors.red);
    canvas.drawCircle(Offset(dist, 0.0), 6.0, Paint()..color=Colors.red);
    canvas.restore();
  }

  void _drawProtractor(Canvas canvas, SimItem d) {
    canvas.save();
    canvas.rotate(d.angle);
    canvas.drawArc(const Rect.fromLTRB(-80.0, -80.0, 80.0, 80.0), math.pi, math.pi, true, Paint()..color=Colors.indigo.withOpacity(0.2));
    canvas.drawArc(const Rect.fromLTRB(-80.0, -80.0, 80.0, 80.0), math.pi, math.pi, true, Paint()..color=Colors.indigo..style=PaintingStyle.stroke..strokeWidth=2.0);
    
    final linePaint = Paint()..color = Colors.white..strokeWidth=1.0;
    for(int i=0; i<=180; i+=10) {
      double angle = math.pi + i * math.pi/180.0;
      double r1 = i % 90 == 0 ? 70.0 : 75.0;
      canvas.drawLine(Offset(r1*math.cos(angle), r1*math.sin(angle)), Offset(80.0*math.cos(angle), 80.0*math.sin(angle)), linePaint);
    }
    
    if (state.scenario == 4 && state.protChecked) {
      canvas.drawRect(const Rect.fromLTRB(0.0, -15.0, 15.0, 0.0), Paint()..color = Colors.indigo..style = PaintingStyle.stroke..strokeWidth = 2.0);
      _drawText(canvas, "90°", 30.0, -30.0, color: Colors.white, weight: FontWeight.bold, size: 16.0);
    } else {
      _drawText(canvas, "90°", 0.0, -40.0, color: Colors.white, weight: FontWeight.bold, size: 16.0);
    }
    canvas.restore();
  }

  void _drawShovel(Canvas canvas, SimItem d) {
    canvas.save(); 
    // Fix: Removed canvas.translate(d.x, d.y) which was causing double translation
    canvas.drawRect(const Rect.fromLTRB(-4.0, -40.0, 4.0, 0.0), Paint()..color=Colors.orange[700]!);
    Path blade = Path()..moveTo(-15.0,0.0)..lineTo(15.0,0.0)..lineTo(10.0,20.0)..lineTo(-10.0,20.0)..close();
    canvas.drawPath(blade, Paint()..color=Colors.blueGrey);
    canvas.drawRect(const Rect.fromLTRB(-10.0, -45.0, 10.0, -40.0), Paint()..color=Colors.brown[800]!);
    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, double x, double y, {Color color = Colors.white, double size = 12.0, FontWeight weight = FontWeight.normal, double maxW = 300.0, FontStyle style = FontStyle.normal}) {
    final tp = TextPainter(text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: weight, fontStyle: style, fontFamily: 'Plus Jakarta Sans')), textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: maxW); tp.paint(canvas, Offset(x - tp.width / 2.0, y - tp.height / 2.0));
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}