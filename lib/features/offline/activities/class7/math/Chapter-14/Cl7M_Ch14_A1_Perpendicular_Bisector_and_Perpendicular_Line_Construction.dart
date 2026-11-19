// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LineOfBalanceApp());
}

double hypot(double a, double b) => math.sqrt(a * a + b * b);

const Map<String, Map<String, dynamic>> translations = {
  'en': {
    'shutterTitle': 'The Line of Balance: Constructing Perpendicular Bisectors',
    'appSubtitle': 'Class 7 • CONSTRUCTIONS AND TILINGS',
    'enterLab': 'Enter Virtual Lab',
    'reset': 'Reset',
    'selectScenario': 'Select Scenario',
    'stepLabel': 'STEP',
    'missionObj': 'Mission Objective',
    'footer': '© ZEROSCIENCELAB | Fall in Love with Math and Science',
    'hudDefault': 'Select a scenario to begin.',
    'btn_draw_arc': 'DRAW ARC',
    'btn_unfold': 'UNFOLD',
    'btn_mark_pt': 'MARK POINT',
    'btn_ok': 'OK',
    'finalSuccessTitle': 'Construction Complete!',

    'scenarios': [
      {
        'title': "1. The Symmetrical Eye",
        'objective': "To visually discover that the line of symmetry for an 'eye' shape is formed by points that are all equidistant from the eye's corners.",
        'steps': [
          { 'text': "You see two points, X and Y, the corners of an eye. A special 'Distance Probe' is active. **DRAG** the probe around the screen. Notice how it draws two lines to X and Y and displays their lengths.", 'hud': "Drag the Distance Probe around the screen." },
          { 'text': "Your goal is to find a point that is the *exact same distance* from both X and Y. **DRAG** the probe until the lengths of the two lines are equal. Find a point **above** the line segment XY. CLICK to mark the point.", 'hud': "Find an equidistant point ABOVE the line and mark it." },
          { 'text': "Great! Now find another such point, but this time, find one **below** the line segment XY. **DRAG** the probe and CLICK when the distances are equal again.", 'hud': "Find an equidistant point BELOW the line and mark it." },
          { 'text': "You have found two special points, A and B. Now, select the **Ruler** tool from the toolbox and **CONNECT** points A and B.", 'hud': "Select Ruler tool and connect points A and B." },
          { 'text': "This line is the 'line of symmetry' or the **Perpendicular Bisector**. Any point on this line is equidistant from X and Y. Now, **DRAG** the two glowing yellow centers of the arcs and snap them onto the green dots (A and B) to form a perfectly symmetrical eye.", 'hud': "Drag the glowing yellow centers to snap onto A and B." }
        ]
      },
      {
        'title': "2. The Classic Construction",
        'objective': "To learn the standard compass and ruler method for constructing a perpendicular bisector of a given line segment.",
        'steps': [
          { 'text': "Here is a line segment PQ. Select the **Compass** tool from the toolbox and DRAG its metal tip directly onto point P.", 'hud': "Select Compass tool and place tip on P." },
          { 'text': "Now, adjust the compass radius. **DRAG** the pencil end to make the radius clearly more than half the length of PQ. The segment will glow green when ready.", 'hud': "Set compass radius greater than half of PQ." },
          { 'text': "With the correct radius set, **CLICK** the 'DRAW ARC' button to draw a large arc.", 'hud': "Click DRAW ARC." },
          { 'text': "Without changing the radius, **DRAG** the compass metal tip onto point Q.", 'hud': "Drag compass tip to point Q." },
          { 'text': "**CLICK** the 'DRAW ARC' button again to draw a second arc. Notice the two intersection points.", 'hud': "Click DRAW ARC again." },
          { 'text': "Finally, select the **Ruler** tool and **CONNECT** the two intersection points to construct the perpendicular bisector.", 'hud': "Select Ruler tool and connect the intersection points." }
        ]
      },
      {
        'title': "3. The Fair Fence",
        'objective': "To apply the perpendicular bisector construction to solve a practical problem of dividing a property.",
        'steps': [
          { 'text': "Two farmers share a straight boundary line between their fields, marked by Post X and Post Y. They want to build a fence that starts on this boundary, is exactly in the middle, and is perpendicular to it. First, **DRAG** the compass to Post X.", 'hud': "Drag the compass to Post X." },
          { 'text': "Set the compass radius to be more than half the distance to Post Y, then **CLICK** to DRAW an arc on your side of the boundary.", 'hud': "Set radius > half, then click DRAW ARC." },
          { 'text': "Now, **DRAG** the compass to Post Y without changing the radius, and **DRAW** another arc that intersects the first one.", 'hud': "Move compass to Y and click DRAW ARC." },
          { 'text': "We need a point on the boundary line itself. We know the midpoint is on the perpendicular bisector. Let's find it. **DRAG** the Ruler to connect intersection point A to the boundary line such that it forms a 90° angle. The ruler will snap into place when it's perfectly perpendicular.", 'hud': "Use the ruler to find the 90° midpoint." },
          { 'text': "You've found the center point O! A fence post appears. Now you can build the fence. **CLICK** on the center post to automatically build the perpendicular fence.", 'hud': "Click the center post O to build the fence." }
        ]
      },
      {
        'title': "4. The Treasure of Equidistance",
        'objective': "To independently use the perpendicular bisector construction to find a location based on a clue.",
        'steps': [
          { 'text': "An old map shows two landmarks: the Ancient Oak (A) and the Sunken Ship (B). The treasure clue reads: \"My gold lies at a place that is as far from the Oak as it is from the Ship.\" Use your tools to draw the line that represents all possible locations for the treasure.", 'hud': "Construct the perpendicular bisector of AB using your tools." },
          { 'text': "A second clue is revealed: \"From the depths of the Gator Swamp (C), walk a straight line to the Dragon's Peak (D). The treasure is where your path crosses the line of equidistance.\" Draw the path from the swamp to the peak and find the treasure.", 'hud': "Use Ruler tool to connect C and D." },
          { 'text': "You've found the spot! CLICK on the glowing intersection point to dig for the treasure.", 'hud': "Click the intersection to dig." }
        ]
      },
      {
        'title': "5. The Perfect Fold",
        'objective': "To understand the physical meaning of a perpendicular bisector through the action of folding.",
        'steps': [
          { 'text': "Here is a virtual piece of paper with a line segment XY. Discover the perpendicular bisector by folding. **DRAG** point X and DROP it precisely on top of point Y.", 'hud': "Fold the paper by dragging X onto Y." },
          { 'text': "**CLICK** the 'UNFOLD' button to open the paper back up and reveal the crease.", 'hud': "Click UNFOLD." },
          { 'text': "Is the crease the perpendicular bisector? Select the **Protractor** and **Ruler** tools to verify the 90° angle and equal lengths around point O.", 'hud': "Use the Protractor and Ruler to verify." }
        ]
      }
    ]
  },
  'hi': {
    'shutterTitle': 'संतुलन की रेखा: लंब समद्विभाजक का निर्माण',
    'appSubtitle': 'कक्षा 7 • संरचनाएं और टिलिंग',
    'enterLab': 'वर्चुअल लैब में प्रवेश करें',
    'reset': 'रीसेट',
    'selectScenario': 'परिदृश्य चुनें',
    'stepLabel': 'चरण',
    'missionObj': 'मिशन का उद्देश्य',
    'footer': '© ZEROSCIENCELAB | Fall in Love with Math and Science',
    'hudDefault': 'शुरू करने के लिए एक परिदृश्य चुनें।',
    'btn_draw_arc': 'चाप बनाएं',
    'btn_unfold': 'खोलें',
    'btn_mark_pt': 'बिंदु चिह्नित करें',
    'btn_ok': 'ठीक है',
    'finalSuccessTitle': 'रचना पूरी हुई!',

    'scenarios': [
      { 'title': "1. सममित आंख", 'objective': "यह दृष्टिगत रूप से खोजना कि 'आंख' के आकार के लिए समरूपता की रेखा उन बिंदुओं से बनती है जो आंख के कोनों से समान दूरी पर होते हैं।",
        'steps': [
          { 'text': "आप दो बिंदु, X और Y, एक आंख के कोने देखते हैं। एक विशेष 'दूरी जांच' उपकरण सक्रिय है। जांच को स्क्रीन के चारों ओर **खींचें**। ध्यान दें कि यह X और Y तक दो रेखाएं कैसे खींचता है और उनकी लंबाई प्रदर्शित करता है।", 'hud': "X और Y से दूरी मापने के लिए दूरी जांच खींचें।" },
          { 'text': "आपका लक्ष्य एक ऐसा बिंदु खोजना है जो X और Y दोनों से *बिल्कुल समान दूरी* पर हो। लंबाई समान होने तक जांच को **खींचें**। रेखाखंड XY के **ऊपर** एक बिंदु खोजें। इसे चिह्नित करने के लिए क्लिक करें।", 'hud': "रेखा के ऊपर एक समान दूरी वाला बिंदु खोजें और क्लिक करें।" },
          { 'text': "बहुत बढ़िया! अब एक और ऐसा बिंदु खोजें, लेकिन इस बार, रेखाखंड XY के **नीचे** खोजें। जांच को **खींचें** और दूरी फिर से समान होने पर क्लिक करें।", 'hud': "रेखा के नीचे एक समान दूरी वाला बिंदु खोजें और क्लिक करें।" },
          { 'text': "आपने दो विशेष बिंदु, A और B खोजे हैं। अब, टूलबॉक्स से **रूलर** टूल चुनें और बिंदु A और B को **जोड़ें**।", 'hud': "रूलर टूल चुनें और A और B को जोड़ें।" },
          { 'text': "यह रेखा 'समरूपता की रेखा' या **लंब समद्विभाजक** है। इस रेखा पर कोई भी बिंदु X और Y से समान दूरी पर है। अब, सममित आंख बनाने के लिए दो चमकते पीले केंद्रों को **खींचें (DRAG)** और उन्हें हरे बिंदुओं (A और B) पर स्नैप करें।", 'hud': "चमकते पीले केंद्रों को A और B पर खींचें।" }
        ]
      },
      { 'title': "2. क्लासिक निर्माण", 'objective': "दिए गए रेखाखंड का लंब समद्विभाजक बनाने के लिए मानक प्रकार (कंपास) और रूलर विधि सीखना।",
        'steps': [
          { 'text': "यहाँ एक रेखाखंड PQ है। टूलबॉक्स से **कंपास** टूल चुनें और इसकी धातु की नोक को सीधे बिंदु P पर खींचें।", 'hud': "कंपास टूल चुनें और नोक को P पर रखें।" },
          { 'text': "अब, कंपास त्रिज्या समायोजित करें। त्रिज्या को PQ की लंबाई के आधे से अधिक करने के लिए पेंसिल के सिरे को **खींचें**। तैयार होने पर खंड हरा चमकेगा।", 'hud': "कंपास त्रिज्या को PQ के आधे से अधिक सेट करें।" },
          { 'text': "सही त्रिज्या सेट होने के साथ, एक बड़ा चाप खींचने के लिए 'चाप बनाएं' बटन पर **क्लिक** करें।", 'hud': "'चाप बनाएं' पर क्लिक करें।" },
          { 'text': "त्रिज्या को बदले बिना, कंपास की धातु की नोक को बिंदु Q पर **खींचें**।", 'hud': "कंपास की नोक को बिंदु Q पर खींचें।" },
          { 'text': "दूसरा चाप खींचने के लिए 'चाप बनाएं' बटन पर फिर से **क्लिक** करें। दो प्रतिच्छेदन बिंदुओं पर ध्यान दें।", 'hud': "फिर से 'चाप बनाएं' पर क्लिक करें।" },
          { 'text': "अंत में, **रूलर** टूल चुनें और लंब समद्विभाजक बनाने के लिए दो प्रतिच्छेदन बिंदुओं को **जोड़ें**।", 'hud': "रूलर टूल चुनें और प्रतिच्छेदन बिंदुओं को जोड़ें।" }
        ]
      },
      { 'title': "3. निष्पक्ष बाड़", 'objective': "संपत्ति को विभाजित करने की व्यावहारिक समस्या को हल करने के लिए लंब समद्विभाजक निर्माण को लागू करना।",
        'steps': [
          { 'text': "दो किसान एक सीमा रेखा XY साझा करते हैं। वे बिल्कुल बीच में एक बाड़ बनाना चाहते हैं। **कंपास** टूल चुनें और इसे पोस्ट X पर रखें।", 'hud': "कंपास टूल चुनें और पोस्ट X पर रखें।" },
          { 'text': "त्रिज्या को आधी से अधिक दूरी पर सेट करें, फिर 'चाप बनाएं' पर **क्लिक** करें।", 'hud': "त्रिज्या सेट करें > आधा, फिर 'चाप बनाएं' क्लिक करें।" },
          { 'text': "अब, त्रिज्या को बदले बिना कंपास को पोस्ट Y पर **खींचें** और प्रतिच्छेदन बिंदु A खोजने के लिए 'चाप बनाएं' पर **क्लिक** करें।", 'hud': "कंपास को Y पर ले जाएं और 'चाप बनाएं' क्लिक करें।" },
          { 'text': "**रूलर** टूल चुनें। 90° कोण खोजने के लिए चौराहे बिंदु A को सीमा रेखा से जोड़ने के लिए रूलर को खींचें।", 'hud': "90° मध्यबिंदु खोजने के लिए रूलर का उपयोग करें।" },
          { 'text': "आपने केंद्र बिंदु O खोज लिया है! लंबवत बाड़ को स्वचालित रूप से बनाने के लिए O पर नए बाड़ पोस्ट पर **क्लिक** करें।", 'hud': "बाड़ बनाने के लिए केंद्र पोस्ट O पर क्लिक करें।" }
        ]
      },
      { 'title': "4. समान दूरी का खजाना", 'objective': "सुराग के आधार पर स्थान खोजने के लिए स्वतंत्र रूप से लंब समद्विभाजक निर्माण का उपयोग करना।",
        'steps': [
          { 'text': "एक पुराने नक्शे में दो स्थल हैं: प्राचीन ओक (A) और डूबा हुआ जहाज (B)। सुराग है: 'सोना उस स्थान पर है जो ओक और जहाज से समान दूरी पर है।' खजाने के सभी संभावित स्थानों को दर्शाने वाली रेखा खींचने के लिए अपने टूल का उपयोग करें।", 'hud': "अपने टूल का उपयोग करके AB का लंब समद्विभाजक बनाएं।" },
          { 'text': "दूसरा सुराग: 'गेटर स्वैम्प (C) से, ड्रैगन पीक (D) तक एक सीधी रेखा में चलें। खजाना वहाँ है जहाँ आपका रास्ता समान दूरी की रेखा को पार करता है।' दलदल से चोटी तक का रास्ता बनाएं और खजाना खोजें।", 'hud': "C और D को जोड़ने के लिए रूलर टूल का उपयोग करें।" },
          { 'text': "आपको वह स्थान मिल गया है! खजाना खोदने के लिए चमकते प्रतिच्छेदन बिंदु पर **क्लिक** करें।", 'hud': "खोदने के लिए प्रतिच्छेदन पर क्लिक करें।" }
        ]
      },
      { 'title': "5. परफेक्ट फोल्ड", 'objective': "मడత చర్య ద్వారా లంబ ద్విఖండన రేఖ యొక్క భౌతిక అర్థాన్ని అర్థం చేసుకోవడం.",
        'steps': [
          { 'text': "यहाँ एक रेखाखंड XY के साथ कागज का एक आभासी टुकड़ा है। मोड़कर लंब समद्विभाजक की खोज करें। बिंदु X को **खींचें** और इसे ठीक बिंदु Y के ऊपर छोड़ दें।", 'hud': "X को Y पर खींचकर कागज को मोड़ें।" },
          { 'text': "कागज को वापस खोलने और क्रीज प्रकट करने के लिए 'खोलें' बटन पर **क्लिक** करें।", 'hud': "'खोलें' क्लिक करें।" },
          { 'text': "क्या क्रीज लंब समद्विभाजक है? कोण को सत्यापित करने के लिए **चांदा (Protractor)** और **रूलर** टूल चुनें।", 'hud': "सत्यापित करने के लिए चांदा और रूलर का उपयोग करें।" }
        ]
      }
    ]
  }
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
  double x, y, z, homeX, homeY, targetX, targetY;
  bool isDragging = false; 
  bool isDraggable, isHidden, isSnapped, glow, isInteractable, hasMovedP1, hasMovedP2, isNearTarget;
  Color color; String label; double offsetY;
  Function? onClick; String? targetId; String? snappedTo; bool hasArc = false;
  
  double radius, angle;
  double x1, y1, x2, y2; 
  double r, sa, diff; 
  double width, height, targetHeight, rotation; 
  
  SimItem({
    required this.type, this.id = '', required this.x, required this.y, this.z = 0, 
    this.isDraggable = false, this.isHidden = false, this.isSnapped = false, this.glow = false, 
    this.isInteractable = false, this.hasMovedP1 = false, this.hasMovedP2 = false, this.isNearTarget = false, 
    this.label = '', this.color = Colors.blue, this.offsetY = -20, this.targetId, this.r = 0, 
    this.sa = 0, this.diff = 0, this.radius = 0, this.angle = 0, this.width = 0, this.rotation = 0,
    this.x1 = 0, this.y1 = 0, this.x2 = 0, this.y2 = 0, this.height = 0, this.targetHeight = 0
  }) : homeX = x, homeY = y, targetX = x, targetY = y;
}

class DropZone {
  String id; double x, y, r;
  DropZone({required this.id, required this.x, required this.y, required this.r});
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

  bool showSuccessPopup = false;
  Set<int> completedScenarios = {};

  double animProgress = 0.0;
  bool isAnimating = false;
  String animMode = '';
  
  double canvasScale = 1.0;
  Offset canvasPan = Offset.zero;

  List<SimItem> entities = [];
  List<DropZone> dropzones = [];
  List<Map<String, dynamic>> arcs = [];
  List<Map<String, dynamic>> lines = [];
  List<Map<String, dynamic>> marks = [];
  List<Particle> particles = [];
  
  String paperState = 'flat'; 
  bool protChecked = false;
  bool rulerChecked = false;
  bool isAdvancing = false;
  bool arcJustDrawn = false;

  String t(String key) {
    if (translations[lang] != null && translations[lang]!.containsKey(key)) return translations[lang]![key];
    return translations['en']?[key] ?? key;
  }

  String getScenarioText(int sId, String key) {
    try { return translations[lang]!['scenarios'][sId][key]; } catch (_) { return translations['en']!['scenarios'][sId][key] ?? key; }
  }

  String getStepText(int sId, int stId, String key) {
    try { return translations[lang]!['scenarios'][sId]['steps'][stId][key]; } catch (_) { return translations['en']!['scenarios'][sId]['steps'][stId][key] ?? key; }
  }

  String get hudMessage {
    if (simCompleted) {
       return lang == 'hi' ? "शाबाश! आपने यह निर्माण सफलतापूर्वक पूरा कर लिया है।" : 
              lang == 'te' ? "బాగా చేసారు! మీరు ఈ నిర్మాణాన్ని విజయవంతంగా పూర్తి చేసారు." : 
              "Success! Great job completing this construction.";
    }
    try {
      return getStepText(scenario, step, 'hud');
    } catch (_) {
      return t('hudDefault');
    }
  }
  
  bool get isProbeEquidistant {
    var probe = entities.cast<SimItem?>().firstWhere((e) => e?.type == 'probe', orElse: () => null);
    var ptX = entities.cast<SimItem?>().firstWhere((e) => e?.id == 'X', orElse: () => null);
    var ptY = entities.cast<SimItem?>().firstWhere((e) => e?.id == 'Y', orElse: () => null);
    if (probe != null && ptX != null && ptY != null) {
      double dX = hypot(probe.x - ptX.x, probe.y - ptX.y);
      double dY = hypot(probe.x - ptY.x, probe.y - ptY.y);
      if ((dX - dY).abs() < 15) {
        if (step == 1 && probe.y < -20) return true;
        if (step == 2 && probe.y > 20) return true;
      }
    }
    return false;
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
    showIntro = true;
    loadScenario(0);
  }

  void toggleSidebar() {
    isSidebarOpen = !isSidebarOpen;
    AudioEngine.playClick();
    notifyListeners();
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
    dropzones.clear();
    arcs.clear();
    lines.clear();
    marks.clear();
    particles.clear();
    
    _initScenarioData();
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 100), evaluateScenarioState);
  }

  void advanceStep() {
    isAdvancing = false;
    int maxSteps = (translations['en']!['scenarios'] as List)[scenario]['steps'].length;
    if (step < maxSteps - 1) {
      step++;
      AudioEngine.playSuccess();
      
      // Auto-Visual transitions based exactly on HTML logic
      if (scenario == 0 && step == 3) {
        var probe = entities.cast<SimItem?>().firstWhere((e) => e?.type == 'probe', orElse: () => null);
        if (probe != null) probe.isHidden = true;
      } 
      else if (scenario == 0 && step == 4) {
        var pA = entities.firstWhere((e) => e.id == 'A'); var pB = entities.firstWhere((e) => e.id == 'B');
        var pX = entities.firstWhere((e) => e.id == 'X'); var pY = entities.firstWhere((e) => e.id == 'Y');
        
        double rA = hypot(pA.x - pX.x, pA.y - pX.y);
        double saA = math.atan2(pX.y - pA.y, pX.x - pA.x); double eaA = math.atan2(pY.y - pA.y, pY.x - pA.x);
        double diffA = eaA - saA;
        while (diffA < -math.pi) diffA += 2 * math.pi; while (diffA > math.pi) diffA -= 2 * math.pi;
        
        double rB = hypot(pB.x - pX.x, pB.y - pX.y);
        double saB = math.atan2(pX.y - pB.y, pX.x - pB.x); double eaB = math.atan2(pY.y - pB.y, pY.x - pB.x);
        double diffB = eaB - saB;
        while (diffB < -math.pi) diffB += 2 * math.pi; while (diffB > math.pi) diffB -= 2 * math.pi;
        
        entities.add(SimItem(type: 'eye_arc', id: 'arcA', x: -160, y: -160, z: 8, r: rA, sa: saA, diff: diffA, targetId: 'A', isDraggable: true, glow: true));
        entities.add(SimItem(type: 'eye_arc', id: 'arcB', x: 160, y: 160, z: 8, r: rB, sa: saB, diff: diffB, targetId: 'B', isDraggable: true, glow: true));
        activeTool = '';
      } 
      else if (scenario == 2 && step == 3) {
        selectTool('ruler');
        entities.add(SimItem(type: 'point', id: 'center_snap', x: 0, y: 0, isHidden: true)); // Target snap point for boundary
      } 
      else if (scenario == 3 && step == 1) {
        selectTool('ruler');
      } 
      else if (scenario == 4 && step == 2) {
        selectTool('ruler');
      }

      notifyListeners();
    }
  }

  void completeScenario() {
    if (simCompleted) return;
    simCompleted = true;
    isAdvancing = false;
    activeTool = '';
    AudioEngine.playSuccess();
    
    completedScenarios.add(scenario);
    if (completedScenarios.length == 5) {
      showSuccessPopup = true;
    }
    notifyListeners();
  }

  void evaluateScenarioState() {
    if (isAdvancing || simCompleted) return;
    
    var ruler = entities.cast<SimItem?>().firstWhere((e) => e?.type == 'ruler', orElse: () => null);
    var compass = entities.cast<SimItem?>().firstWhere((e) => e?.type == 'compass', orElse: () => null);
    
    bool isDraggingRuler = ruler?.isDragging ?? false;
    bool isDraggingCompass = compass?.isDragging ?? false;
    
    if (scenario == 0) {
      if (step == 0) {
        var probe = entities.cast<SimItem?>().firstWhere((e) => e?.type == 'probe', orElse: () => null);
        if (probe != null && (probe.x.abs() > 20 || (probe.y + 150).abs() > 20)) {
           isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), advanceStep);
        }
      } else if (step == 3) {
        if (isDraggingRuler) return;
        if (ruler != null && ruler.hasMovedP1 && ruler.hasMovedP2) {
          var pA = entities.firstWhere((e) => e.id == 'A'); var pB = entities.firstWhere((e) => e.id == 'B');
          if ((hypot(ruler.x1 - pA.x, ruler.y1 - pA.y) < 30 && hypot(ruler.x2 - pB.x, ruler.y2 - pB.y) < 30) || 
              (hypot(ruler.x2 - pA.x, ruler.y2 - pA.y) < 30 && hypot(ruler.x1 - pB.x, ruler.y1 - pB.y) < 30)) {
            isAdvancing = true; AudioEngine.playSuccess();
            lines.add({'x1': pA.x, 'y1': pA.y, 'x2': pB.x, 'y2': pB.y, 'color': Colors.lightBlue, 'w': 4.0});
            entities.removeWhere((e) => e.type == 'ruler');
            Future.delayed(const Duration(milliseconds: 2000), advanceStep);
          }
        }
      } else if (step == 4) {
        var arcA = entities.cast<SimItem?>().firstWhere((e) => e?.id == 'arcA', orElse: () => null);
        var arcB = entities.cast<SimItem?>().firstWhere((e) => e?.id == 'arcB', orElse: () => null);
        if (arcA != null && arcB != null && arcA.isSnapped && arcB.isSnapped && arcA.snappedTo != arcB.snappedTo) {
          isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), completeScenario);
        }
      }
    } 
    else if (scenario == 1) {
      var ptP = entities.cast<SimItem?>().firstWhere((e) => e?.id == 'P', orElse: () => null);
      var ptQ = entities.cast<SimItem?>().firstWhere((e) => e?.id == 'Q', orElse: () => null);
      
      if (step == 0) {
        if (compass != null && ptP != null && hypot(compass.x - ptP.x, compass.y - ptP.y) < 5) {
          isAdvancing = true; Future.delayed(const Duration(milliseconds: 500), advanceStep);
        }
      } else if (step == 1) {
        if (compass != null && ptP != null && compass.radius > 110 && hypot(compass.x - ptP.x, compass.y - ptP.y) < 5) {
          if (isDraggingCompass) return;
          lines[0]['color'] = Colors.green; isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), advanceStep);
        }
      } else if (step == 2) {
        if (arcs.length == 1 && arcJustDrawn) { arcJustDrawn = false; isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), advanceStep); }
      } else if (step == 3) {
        if (compass != null && ptQ != null && hypot(compass.x - ptQ.x, compass.y - ptQ.y) < 5) {
          isAdvancing = true; Future.delayed(const Duration(milliseconds: 500), advanceStep);
        }
      } else if (step == 4) {
        if (arcs.length == 2 && arcJustDrawn) {
          arcJustDrawn = false; isAdvancing = true;
          double R = arcs[0]['r']; double yInt = math.sqrt(R*R - 10000);
          entities.add(SimItem(type: 'intersection', id: 'R', x: 0, y: -yInt, label: 'R'));
          entities.add(SimItem(type: 'intersection', id: 'S', x: 0, y: yInt, label: 'S'));
          Future.delayed(const Duration(milliseconds: 1500), advanceStep);
        }
      } else if (step == 5) {
        if (isDraggingRuler) return;
        var pR = entities.cast<SimItem?>().firstWhere((e) => e?.id == 'R', orElse: () => null);
        var pS = entities.cast<SimItem?>().firstWhere((e) => e?.id == 'S', orElse: () => null);
        if (ruler != null && ruler.hasMovedP1 && ruler.hasMovedP2 && pR != null && pS != null) {
          if ((hypot(ruler.x1 - pR.x, ruler.y1 - pR.y) < 30 && hypot(ruler.x2 - pS.x, ruler.y2 - pS.y) < 30) || 
              (hypot(ruler.x2 - pR.x, ruler.y2 - pR.y) < 30 && hypot(ruler.x1 - pS.x, ruler.y1 - pS.y) < 30)) {
            isAdvancing = true; AudioEngine.playSuccess();
            lines.add({'x1': pR.x, 'y1': pR.y, 'x2': pS.x, 'y2': pS.y, 'color': Colors.lightBlue, 'w': 4.0});
            entities.removeWhere((e) => e.type == 'ruler' || e.type == 'compass');
            Future.delayed(const Duration(milliseconds: 2000), completeScenario);
          }
        }
      }
    }
    else if (scenario == 2) {
      if (step == 0 || step == 1 || step == 2) {
        var ptX = entities.cast<SimItem?>().firstWhere((e) => e?.id == 'X', orElse: () => null);
        if (step == 0 && compass != null && ptX != null && hypot(compass.x - ptX.x, compass.y - ptX.y) < 5) {
          isAdvancing = true; Future.delayed(const Duration(milliseconds: 500), advanceStep);
        }
        if (step == 1 && arcs.length == 1 && arcJustDrawn) { arcJustDrawn = false; isAdvancing = true; Future.delayed(const Duration(milliseconds: 1000), advanceStep); }
        if (step == 2 && arcs.length == 2 && arcJustDrawn) {
          arcJustDrawn = false; isAdvancing = true;
          var a1 = arcs[0]; var a2 = arcs[1];
          double dx = a2['x'] - a1['x']; double dy = a2['y'] - a1['y']; double d = hypot(dx, dy);
          if (d <= a1['r'] + a2['r'] && d >= (a1['r'] - a2['r']).abs() && d > 0) {
            double a = (a1['r']*a1['r'] - a2['r']*a2['r'] + d*d) / (2*d);
            double h = math.sqrt(a1['r']*a1['r'] - a*a);
            double cx = a1['x'] + a * (dx/d); double cy = a1['y'] + a * (dy/d);
            double int1y = cy - h * (dx/d); double int2y = cy + h * (dx/d);
            double finalY = int1y < 0 ? int1y : int2y;
            entities.add(SimItem(type: 'intersection', id: 'A', x: 0, y: finalY, label: 'A'));
            AudioEngine.playPop();
          }
          Future.delayed(const Duration(milliseconds: 1500), advanceStep);
        }
      } else if (step == 3) {
        if (isDraggingRuler) return;
        var pA = entities.cast<SimItem?>().firstWhere((e) => e?.id == 'A', orElse: () => null);
        if (ruler != null && ruler.hasMovedP1 && ruler.hasMovedP2 && pA != null) {
          if ((hypot(ruler.x1 - pA.x, ruler.y1 - pA.y) < 5 && hypot(ruler.x2, ruler.y2) < 5) || 
              (hypot(ruler.x2 - pA.x, ruler.y2 - pA.y) < 5 && hypot(ruler.x1, ruler.y1) < 5)) {
            isAdvancing = true; AudioEngine.playSuccess();
            ruler.isDraggable = false;
            entities.add(SimItem(type: 'point', id: 'O', x: 0, y: 0, z: 20, label: 'Post O', color: Colors.green, isInteractable: true, glow: true)
              ..onClick = () { if (!isAdvancing) buildFenceAction(); });
            Future.delayed(const Duration(milliseconds: 1500), advanceStep);
          }
        }
      }
    }
    else if (scenario == 3) {
      if (step == 0) {
        var pR = entities.cast<SimItem?>().firstWhere((e) => e?.id == 'R', orElse: () => null);
        var pS = entities.cast<SimItem?>().firstWhere((e) => e?.id == 'S', orElse: () => null);
        if (pR != null && pS != null) {
          if (isDraggingRuler) return;
          if (ruler != null && ruler.hasMovedP1 && ruler.hasMovedP2 &&
             ((hypot(ruler.x1 - pR.x, ruler.y1 - pR.y) < 30 && hypot(ruler.x2 - pS.x, ruler.y2 - pS.y) < 30) || 
              (hypot(ruler.x2 - pR.x, ruler.y2 - pR.y) < 30 && hypot(ruler.x1 - pS.x, ruler.y1 - pS.y) < 30))) {
            isAdvancing = true; AudioEngine.playSuccess();
            lines.add({'x1': pR.x, 'y1': pR.y, 'x2': pS.x, 'y2': pS.y, 'color': Colors.orange[800], 'w': 4.0});
            entities.removeWhere((e) => e.type == 'ruler' || e.type == 'compass');
            entities.add(SimItem(type: 'point', id: 'C', x: -120, y: -160, label: 'Swamp C', color: Colors.green[800]!));
            entities.add(SimItem(type: 'point', id: 'D', x: 160, y: 180, label: 'Peak D', color: Colors.orange));
            Future.delayed(const Duration(milliseconds: 1500), advanceStep);
          }
        } else if (arcs.length == 2 && arcJustDrawn) {
          arcJustDrawn = false;
          var a1 = arcs[0]; var a2 = arcs[1];
          double dx = a2['x'] - a1['x']; double dy = a2['y'] - a1['y']; double d = hypot(dx, dy);
          if (d <= a1['r'] + a2['r'] && d >= (a1['r'] - a2['r']).abs() && d > 0) {
            double a = (a1['r']*a1['r'] - a2['r']*a2['r'] + d*d) / (2*d);
            double h = math.sqrt(a1['r']*a1['r'] - a*a);
            double cx = a1['x'] + a * (dx/d); double cy = a1['y'] + a * (dy/d);
            entities.add(SimItem(type: 'intersection', id: 'R', x: cx + h * (dy/d), y: cy - h * (dx/d), label: ''));
            entities.add(SimItem(type: 'intersection', id: 'S', x: cx - h * (dy/d), y: cy + h * (dx/d), label: ''));
            AudioEngine.playPop();
          }
        }
      } else if (step == 1) {
        if (isDraggingRuler) return;
        var pC = entities.cast<SimItem?>().firstWhere((e) => e?.id == 'C', orElse: () => null);
        var pD = entities.cast<SimItem?>().firstWhere((e) => e?.id == 'D', orElse: () => null);
        if (ruler != null && ruler.hasMovedP1 && ruler.hasMovedP2 && pC != null && pD != null &&
           ((hypot(ruler.x1 - pC.x, ruler.y1 - pC.y) < 30 && hypot(ruler.x2 - pD.x, ruler.y2 - pD.y) < 30) || 
            (hypot(ruler.x2 - pC.x, ruler.y2 - pC.y) < 30 && hypot(ruler.x1 - pD.x, ruler.y1 - pD.y) < 30))) {
          isAdvancing = true; AudioEngine.playSuccess();
          lines.add({'x1': pC.x, 'y1': pC.y, 'x2': pD.x, 'y2': pD.y, 'color': Colors.brown, 'w': 4.0});
          entities.removeWhere((e) => e.type == 'ruler');
          
          double tX = 0, tY = 0;
          if (lines.length >= 2) {
            var l1 = lines[0]; var l2 = lines[1];
            double det = (l1['x1'] - l1['x2'])*(l2['y1'] - l2['y2']) - (l1['y1'] - l1['y2'])*(l2['x1'] - l2['x2']);
            if (det != 0) {
              tX = ((l1['x1']*l1['y2'] - l1['y1']*l1['x2'])*(l2['x1'] - l2['x2']) - (l1['x1'] - l1['x2'])*(l2['x1']*l2['y2'] - l2['y1']*l2['x2'])) / det;
              tY = ((l1['x1']*l1['y2'] - l1['y1']*l1['x2'])*(l2['y1'] - l2['y2']) - (l1['y1'] - l1['y2'])*(l2['x1']*l2['y2'] - l2['y1']*l2['x2'])) / det;
            }
          }
          
          entities.add(SimItem(type: 'point', id: 'Target', x: tX, y: tY, label: 'Dig Here!', color: Colors.yellow, glow: true, isInteractable: true)
            ..onClick = () {
              if (!isAdvancing && step == 2) {
                AudioEngine.playSuccess(); isAdvancing = true;
                var target = entities.firstWhere((e) => e.id == 'Target');
                target.isHidden = true;
                entities.add(SimItem(type: 'treasure', id: 'treasure', x: tX, y: tY, z: 20));
                createParticles(tX, tY, Colors.yellow);
                Future.delayed(const Duration(milliseconds: 2500), completeScenario);
              }
            });
          Future.delayed(const Duration(milliseconds: 1500), advanceStep);
        }
      }
    }
    else if (scenario == 4) {
      if (step == 2) {
        if (protChecked && rulerChecked && !isAdvancing) {
          isAdvancing = true; AudioEngine.playSuccess();
          Future.delayed(const Duration(milliseconds: 1000), completeScenario);
        }
      }
    }
    notifyListeners();
  }

  void _initScenarioData() {
    if (scenario == 0) {
      lines.add({'x1': -100.0, 'y1': 0.0, 'x2': 100.0, 'y2': 0.0, 'color': Colors.grey, 'w': 3.0});
      entities.add(SimItem(type: 'point', id: 'X', x: -100, y: 0, label: 'X', color: Colors.yellowAccent[100]!, offsetY: 20));
      entities.add(SimItem(type: 'point', id: 'Y', x: 100, y: 0, label: 'Y', color: Colors.yellowAccent[100]!, offsetY: 20));
      entities.add(SimItem(type: 'probe', id: 'probe', x: 0, y: -150, z: 10, isDraggable: true));
    } 
    else if (scenario == 1) {
      lines.add({'x1': -100.0, 'y1': 0.0, 'x2': 100.0, 'y2': 0.0, 'color': Colors.grey, 'w': 3.0});
      entities.add(SimItem(type: 'point', id: 'P', x: -100, y: 0, label: 'P', color: Colors.yellowAccent[100]!));
      entities.add(SimItem(type: 'point', id: 'Q', x: 100, y: 0, label: 'Q', color: Colors.yellowAccent[100]!));
    }
    else if (scenario == 2) {
      entities.add(SimItem(type: 'point', id: 'X', x: -140, y: 0, label: 'Post X', color: Colors.amber));
      entities.add(SimItem(type: 'point', id: 'Y', x: 140, y: 0, label: 'Post Y', color: Colors.amber));
    }
    else if (scenario == 3) {
      entities.add(SimItem(type: 'point', id: 'A', x: -80, y: 20, label: 'Oak A', color: Colors.green));
      entities.add(SimItem(type: 'point', id: 'B', x: 80, y: 120, label: 'Ship B', color: Colors.blue));
    }
    else if (scenario == 4) {
      paperState = 'flat';
      entities.add(SimItem(type: 'point', id: 'X', x: -150, y: 0, label: 'X', color: Colors.yellowAccent[100]!));
      entities.add(SimItem(type: 'point', id: 'Y', x: 150, y: 0, label: 'Y', color: Colors.yellowAccent[100]!));
      entities.add(SimItem(type: 'paper_corner', id: 'paper_corner', x: -150, y: 0, z: 10, isDraggable: true));
    }
  }

  void markPointAction() {
    if (!isProbeEquidistant) return;
    var probe = entities.firstWhere((e) => e.type == 'probe');
    
    if (step == 1) {
      AudioEngine.playSuccess(); entities.add(SimItem(type: 'point', id: 'A', x: 0, y: probe.y, label: 'A', color: Colors.green, offsetY: -20));
      isAdvancing = true; advanceStep();
    } else if (step == 2) {
      AudioEngine.playSuccess(); entities.add(SimItem(type: 'point', id: 'B', x: 0, y: probe.y, label: 'B', color: Colors.green, offsetY: 20));
      isAdvancing = true; advanceStep();
    }
  }

  void drawArcAction() {
    var compass = entities.cast<SimItem?>().firstWhere((e) => e?.type == 'compass', orElse: () => null);
    if (compass == null) return;
    
    SimItem? ptP, ptQ;
    if (scenario == 1) { ptP = entities.cast<SimItem?>().firstWhere((e)=>e?.id=='P', orElse: ()=>null); ptQ = entities.cast<SimItem?>().firstWhere((e)=>e?.id=='Q', orElse: ()=>null); }
    else if (scenario == 2) { ptP = entities.cast<SimItem?>().firstWhere((e)=>e?.id=='X', orElse: ()=>null); ptQ = entities.cast<SimItem?>().firstWhere((e)=>e?.id=='Y', orElse: ()=>null); }
    else if (scenario == 3) { ptP = entities.cast<SimItem?>().firstWhere((e)=>e?.id=='A', orElse: ()=>null); ptQ = entities.cast<SimItem?>().firstWhere((e)=>e?.id=='B', orElse: ()=>null); }
    
    if (ptP == null || ptQ == null) return;
    
    double distPQ = hypot(ptP.x - ptQ.x, ptP.y - ptQ.y);
    bool isOnP = hypot(compass.x - ptP.x, compass.y - ptP.y) < 20;
    bool isOnQ = hypot(compass.x - ptQ.x, compass.y - ptQ.y) < 20;
    
    bool validPlacement = false;
    if (scenario == 1) {
      if (step == 2 && isOnP) validPlacement = true;
      if (step == 4 && isOnQ) validPlacement = true;
    } else if (scenario == 2) {
      if (step == 1 && isOnP) validPlacement = true;
      if (step == 2 && isOnQ) validPlacement = true;
    } else if (scenario == 3) {
      if (step == 0) validPlacement = true;
    }

    if (!validPlacement) { AudioEngine.playError(); return; }
    
    if (isOnP || isOnQ) {
      if (compass.radius > distPQ / 2) {
        AudioEngine.playWhir(); compass.isDraggable = false;
        SimItem targetPt = isOnP ? ptQ : ptP;
        double baseAngle = math.atan2(targetPt.y - compass.y, targetPt.x - compass.x);
        double sweep = math.pi / 2.5; double startAng = baseAngle - sweep; double endAng = baseAngle + sweep;
        
        compass.angle = startAng;
        
        bool exists = arcs.any((a) => (a['x'] - compass.x).abs() < 5 && (a['y'] - compass.y).abs() < 5);
        if (!exists) {
          arcs.add({'x': compass.x, 'y': compass.y, 'r': compass.radius, 'sa': startAng, 'ea': startAng, 'targetEa': endAng, 'p': 0.0});
          isAnimating = true; animMode = 'draw_arc'; animProgress = 0.0;
        } else {
          AudioEngine.playError(); compass.isDraggable = true;
        }
      } else {
        AudioEngine.playError();
      }
    } else {
      AudioEngine.playError();
    }
    notifyListeners();
  }

  void unfoldAction() {
    AudioEngine.playPop();
    paperState = 'unfolded';
    var corner = entities.cast<SimItem?>().firstWhere((e) => e?.type == 'paper_corner', orElse: () => null);
    if (corner != null) { corner.x = -150; corner.y = 0; corner.isDraggable = false; corner.isHidden = true; }
    entities.add(SimItem(type: 'point', id: 'O', x: 0, y: 0, label: 'O', color: Colors.green, offsetY: -25));
    advanceStep();
  }

  void selectTool(String toolName) {
    AudioEngine.playClick();
    activeTool = toolName;
    
    double cx = -canvasPan.dx / canvasScale;
    double cy = -canvasPan.dy / canvasScale;

    var tool = entities.cast<SimItem?>().firstWhere((e) => e?.type == toolName, orElse: () => null);
    if (tool == null) {
      if (toolName == 'ruler') entities.add(SimItem(type: 'ruler', id: 'ruler', x: cx, y: cy-150, x1: cx-50, y1: cy-150, x2: cx+50, y2: cy-150, z: 9, isDraggable: true));
      if (toolName == 'compass') entities.add(SimItem(type: 'compass', id: 'compass', x: cx, y: cy-150, radius: 150, angle: math.pi/2.5, z: 10, isDraggable: true));
      if (toolName == 'protractor') entities.add(SimItem(type: 'protractor', id: 'protractor', x: cx, y: cy-150, z: 9, isDraggable: true));
    } else {
      tool.isHidden = false;
    }
    
    for (var e in entities) {
      if ((e.type == 'ruler' || e.type == 'compass' || e.type == 'protractor') && e.type != toolName) {
        if (!(scenario == 4 && step == 2)) e.isHidden = true; 
      }
    }
    notifyListeners();
  }

  void buildFenceAction() {
    AudioEngine.playSuccess();
    entities.removeWhere((e) => e.type == 'ruler' || e.type == 'compass' || e.type == 'protractor' || e.id == 'O' || e.id == 'A');
    entities.add(SimItem(type: 'fence', id: 'fence', x: 0, y: 0, z: 2, height: 0, targetHeight: 400));
    entities.add(SimItem(type: 'point', id: 'O', x: 0, y: 0, label: 'O', isInteractable: false, z: 3));
    entities.add(SimItem(type: 'farmer', id: 'f1', x: -80, y: -60, z: 6, label: '👨‍🌾👍'));
    entities.add(SimItem(type: 'farmer', id: 'f2', x: 80, y: -60, z: 6, label: '👩‍🌾👍'));
    
    if (!isAdvancing) {
      isAdvancing = true;
      Future.delayed(const Duration(milliseconds: 2500), completeScenario);
    }
    notifyListeners();
  }

  void createParticles(double x, double y, Color color) {
    for (int i=0; i<20; i++) {
      particles.add(Particle(x, y, (math.Random().nextDouble()-0.5)*10, (math.Random().nextDouble()-0.5)*10 - 5, 1.0, color));
    }
  }
}

class LineOfBalanceApp extends StatelessWidget {
  const LineOfBalanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Line of Balance',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.white)),
      ),
      home: const PerpendicularBisectorandPerpendicularLineConstruction(),
    );
  }
}

class PerpendicularBisectorandPerpendicularLineConstruction extends StatefulWidget {
  const PerpendicularBisectorandPerpendicularLineConstruction({Key? key}) : super(key: key);
  @override
  State<PerpendicularBisectorandPerpendicularLineConstruction> createState() => _PerpendicularBisectorandPerpendicularLineConstructionState();
}

class _PerpendicularBisectorandPerpendicularLineConstructionState extends State<PerpendicularBisectorandPerpendicularLineConstruction> with TickerProviderStateMixin {
  final LabState _state = LabState();
  late AnimationController _animCtrl;
  
  bool _isDraggingAnItem = false;
  bool _isPanningCanvas = false;
  double _startScale = 1.0;
  Offset _startPan = Offset.zero;
  Offset _startFocal = Offset.zero;
  SimItem? _draggedItem;
  String _dragPart = '';
  
  Offset _floatingStepPos = const Offset(60, 60);
  Offset _successPopupPos = const Offset(100, 100);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _state.addListener(() {
      if (!mounted) return;
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
      if (d.type == 'fence') {
        if ((d.height - d.targetHeight).abs() > 0.5) {
          d.height += (d.targetHeight - d.height) * 0.1;
          needsRender = true;
        }
      }
    }

    if (_state.isAnimating) {
      _state.animProgress += 0.02;
      double p = _state.animProgress;
      
      if (_state.animMode == 'draw_arc') {
        if (_state.arcs.isNotEmpty) {
          var arc = _state.arcs.last;
          arc['ea'] = arc['sa'] + (arc['targetEa'] - arc['sa']) * math.min(1.0, p);
          arc['p'] = math.min(1.0, p);
          var comp = _state.entities.cast<SimItem?>().firstWhere((e) => e?.type == 'compass', orElse: () => null);
          if (comp != null) comp.angle = arc['ea'];
        }
        if (p >= 1) {
          _state.isAnimating = false;
          _state.arcJustDrawn = true;
          var comp = _state.entities.cast<SimItem?>().firstWhere((e) => e?.type == 'compass', orElse: () => null);
          if (comp != null) { comp.isDraggable = true; }
          _state.evaluateScenarioState();
        }
      }
      needsRender = true;
    }
    
    if (_state.particles.isNotEmpty) {
      for (int i = _state.particles.length - 1; i >= 0; i--) {
        var p = _state.particles[i];
        p.x += p.vx; p.y += p.vy; p.vy += 0.5; p.life -= 0.03;
        if (p.life <= 0) _state.particles.removeAt(i);
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

    double worldX = (localCanvasX - canvasWidth / 2 - _state.canvasPan.dx) / _state.canvasScale;
    double worldY = (localCanvasY - consts.maxHeight / 2 - _state.canvasPan.dy) / _state.canvasScale;

    for (int i = _state.entities.length - 1; i >= 0; i--) {
      var d = _state.entities[i];
      if (d.isHidden || d.onClick == null) continue;
      if (hypot(worldX - d.x, worldY - d.y) < 40) {
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

    double worldX = (localCanvasX - canvasWidth / 2 - _state.canvasPan.dx) / _state.canvasScale;
    double worldY = (localCanvasY - consts.maxHeight / 2 - _state.canvasPan.dy) / _state.canvasScale;

    _startPan = _state.canvasPan;
    _startScale = _state.canvasScale;
    _startFocal = details.localFocalPoint;

    for (int i = _state.entities.length - 1; i >= 0; i--) {
      var d = _state.entities[i];
      if (d.isHidden) continue;
      bool hit = false;
      String part = '';

      if (d.type == 'probe') { if (hypot(worldX - d.x, worldY - d.y) < 80) hit = true; } 
      else if (d.type == 'compass') { 
        if (hypot(worldX - d.x, worldY - d.y) < 80) { hit = true; part = 'pivot'; } 
        else { 
          double pX = d.x + d.radius * math.cos(d.angle); double pY = d.y + d.radius * math.sin(d.angle); 
          if (hypot(worldX - pX, worldY - pY) < 80) { hit = true; part = 'pencil'; } 
        } 
      } 
      else if (d.type == 'ruler') { 
        if (hypot(worldX - d.x1, worldY - d.y1) < 60) { hit = true; part = 'p1'; } 
        else if (hypot(worldX - d.x2, worldY - d.y2) < 60) { hit = true; part = 'p2'; } 
        else {
          double l2 = math.pow(d.x2 - d.x1, 2).toDouble() + math.pow(d.y2 - d.y1, 2).toDouble(); 
          if (l2 > 0) { 
            double t = ((worldX - d.x1) * (d.x2 - d.x1) + (worldY - d.y1) * (d.y2 - d.y1)) / l2; 
            t = math.max(0.0, math.min(1.0, t)); 
            double projX = d.x1 + t * (d.x2 - d.x1); double projY = d.y1 + t * (d.y2 - d.y1); 
            if (hypot(worldX - projX, worldY - projY) < 60) { hit = true; part = 'body'; } 
          }
        }
      } 
      else if (d.type == 'protractor') { if (hypot(worldX - d.x, worldY - d.y) < 80) hit = true; } 
      else if (d.type == 'eye_arc') { if (hypot(worldX - d.x, worldY - d.y) < 80) hit = true; } 
      else if (d.type == 'paper_corner' && d.isDraggable) { if (hypot(worldX - d.x, worldY - d.y) < 80) hit = true; } 
      
      if (hit) {
        if (!d.isDraggable && d.type != 'compass' && d.type != 'ruler' && d.type != 'probe' && d.type != 'protractor' && d.type != 'eye_arc' && d.type != 'paper_corner') continue;
        AudioEngine.playClick();
        
        _isDraggingAnItem = true; _draggedItem = d; _dragPart = part;
        d.isDragging = true;
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
    
    double worldX = (localCanvasX - canvasWidth / 2 - _state.canvasPan.dx) / _state.canvasScale;
    double worldY = (localCanvasY - consts.maxHeight / 2 - _state.canvasPan.dy) / _state.canvasScale;

    double startWorldX = (_startFocal.dx - canvasWidth / 2 - _startPan.dx) / _startScale;
    double startWorldY = (_startFocal.dy - consts.maxHeight / 2 - _startPan.dy) / _startScale;

    double dx = worldX - startWorldX;
    double dy = worldY - startWorldY;

    if (_isDraggingAnItem && _draggedItem != null) {
      var d = _draggedItem!;
      if (d.type == 'compass') {
        if (_dragPart == 'pivot') { d.targetX = worldX; d.targetY = worldY; d.x = worldX; d.y = worldY; }
        else if (_dragPart == 'pencil') { d.radius = math.max(10.0, hypot(worldX - d.x, worldY - d.y)); d.angle = math.atan2(worldY - d.y, worldX - d.x); }
      } else if (d.type == 'ruler') {
        if (_dragPart == 'body') { 
          d.x1 += dx * 0.1; d.y1 += dy * 0.1; d.x2 += dx * 0.1; d.y2 += dy * 0.1; 
        }
        else if (_dragPart == 'p1') { d.x1 = worldX; d.y1 = worldY; }
        else if (_dragPart == 'p2') { d.x2 = worldX; d.y2 = worldY; }
      } else if (d.type == 'paper_corner') {
        d.targetX = worldX; d.targetY = worldY; d.x = worldX; d.y = worldY;
        var pY = _state.entities.firstWhere((e) => e.id == 'Y', orElse: () => SimItem(type: '', x:0, y:0));
        if (pY.id.isNotEmpty && hypot(d.x - pY.x, d.y - pY.y) < 100) d.isNearTarget = true; else d.isNearTarget = false;
      } else {
        d.targetX = worldX; d.targetY = worldY; d.x = worldX; d.y = worldY;
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

    if (_state.scenario == 0 && d.type == 'probe') {
      _state.evaluateScenarioState();
    } else if (d.type == 'compass' && _dragPart == 'pivot') {
      bool snapped = false;
      for (var p in _state.entities.where((e) => e.type == 'point')) {
        if (hypot(d.x - p.x, d.y - p.y) < 30) { d.targetX = p.x; d.targetY = p.y; d.x = p.x; d.y = p.y; snapped = true; break; }
      }
      if (snapped) AudioEngine.playSnap(); else { AudioEngine.playError(); }
      _state.evaluateScenarioState();
    } else if (d.type == 'compass' && _dragPart == 'pencil') {
      _state.evaluateScenarioState();
    } else if (d.type == 'ruler') {
      bool p1S = false, p2S = false;
      var points = _state.entities.where((e) => e.type == 'point' || e.type == 'intersection');
      
      for (var p in points) {
        if ((_dragPart == 'p1' || _dragPart == 'body') && !p1S) { if (hypot(d.x1 - p.x, d.y1 - p.y) < 40) { d.x1 = p.x; d.y1 = p.y; p1S = true; d.hasMovedP1 = true; } }
        if ((_dragPart == 'p2' || _dragPart == 'body') && !p2S) { if (hypot(d.x2 - p.x, d.y2 - p.y) < 40) { d.x2 = p.x; d.y2 = p.y; p2S = true; d.hasMovedP2 = true; } }
      }
      
      if (_state.scenario == 2 && _state.step == 3) {
         var pA = _state.entities.cast<SimItem?>().firstWhere((e) => e?.id == 'A', orElse: () => null);
         if (pA != null) {
           if (hypot(d.x1 - pA.x, d.y1 - pA.y) < 60 && !p1S) { d.x1 = pA.x; d.y1 = pA.y; p1S = true; d.hasMovedP1 = true; }
           if (hypot(d.x2 - pA.x, d.y2 - pA.y) < 60 && !p2S) { d.x2 = pA.x; d.y2 = pA.y; p2S = true; d.hasMovedP2 = true; }
           
           if (p1S && hypot(d.x2, d.y2) < 60) { d.x2 = 0; d.y2 = 0; p2S = true; d.hasMovedP2 = true; }
           else if (p2S && hypot(d.x1, d.y1) < 60) { d.x1 = 0; d.y1 = 0; p1S = true; d.hasMovedP1 = true; }
         }
      } else if (_state.scenario == 4 && _state.step == 2) {
         var snapPoints = points.where((e) => e.id == 'X' || e.id == 'Y' || e.id == 'O');
         for (var p in snapPoints) {
            if (hypot(d.x1 - p.x, d.y1 - p.y) < 50 && !p1S) { d.x1 = p.x; d.y1 = p.y; p1S = true; d.hasMovedP1 = true; }
            if (hypot(d.x2 - p.x, d.y2 - p.y) < 50 && !p2S) { d.x2 = p.x; d.y2 = p.y; p2S = true; d.hasMovedP2 = true; }
         }
         if (p1S && p2S) _state.rulerChecked = true;
      }

      if (p1S || p2S) { AudioEngine.playSnap(); _state.evaluateScenarioState(); }
    } else if (d.type == 'eye_arc') {
      var pA = _state.entities.firstWhere((e) => e.id == 'A', orElse: () => SimItem(type: '', x:0, y:0));
      var pB = _state.entities.firstWhere((e) => e.id == 'B', orElse: () => SimItem(type: '', x:0, y:0));
      SimItem? sTo;
      if (d.targetId == 'A' && pA.id.isNotEmpty && !pA.hasArc && hypot(d.x - pA.x, d.y - pA.y) < 40) { d.targetX = pA.x; d.targetY = pA.y; d.x = pA.x; d.y = pA.y; sTo = pA; }
      else if (d.targetId == 'B' && pB.id.isNotEmpty && !pB.hasArc && hypot(d.x - pB.x, d.y - pB.y) < 40) { d.targetX = pB.x; d.targetY = pB.y; d.x = pB.x; d.y = pB.y; sTo = pB; }
      
      if (d.snappedTo != null && d.snappedTo != sTo?.id) {
         var oldP = _state.entities.cast<SimItem?>().firstWhere((e) => e?.id == d.snappedTo, orElse: () => null);
         if (oldP != null) oldP.hasArc = false;
      }
      
      if (sTo != null) { AudioEngine.playSnap(); sTo.hasArc = true; d.snappedTo = sTo.id; d.glow = false; d.isDraggable = false; d.isSnapped = true; _state.evaluateScenarioState(); }
      else { AudioEngine.playError(); d.targetX = d.homeX; d.targetY = d.homeY; d.glow = true; d.isSnapped = false; d.snappedTo = null; }
    } else if (d.type == 'paper_corner') {
      if (d.isNearTarget) { d.targetX = 150; d.targetY = 0; d.x = 150; d.y = 0; AudioEngine.playSnap(); _state.paperState = 'folded'; _state.advanceStep(); }
      else { AudioEngine.playError(); d.targetX = d.homeX; d.targetY = d.homeY; }
    } else if (d.type == 'protractor') {
      if (_state.scenario == 4 && _state.step == 2) {
        if (hypot(d.x, d.y) < 50) { 
          d.targetX = 0; d.targetY = 0; d.x = 0; d.y = 0; d.angle = 0; 
          _state.protChecked = true; AudioEngine.playSnap(); _state.evaluateScenarioState(); 
        }
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
    double sidebarWidth = MediaQuery.of(context).size.width * 0.35;
    if (sidebarWidth < 300) sidebarWidth = 300;
    if (sidebarWidth > 400) sidebarWidth = 400;

    bool showDrawArcBtn = _state.activeTool == 'compass' &&
                          ((_state.scenario == 1 && (_state.step == 2 || _state.step == 4)) ||
                           (_state.scenario == 2 && (_state.step == 1 || _state.step == 2)) ||
                           (_state.scenario == 3 && _state.step == 0));
    
    bool showUnfoldBtn = _state.scenario == 4 && _state.step == 1;
    bool showMarkPointBtn = _state.scenario == 0 && (_state.step == 1 || _state.step == 2) && _state.isProbeEquidistant;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // Responsive Interactive Canvas 
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _state.isSidebarOpen ? sidebarWidth : 0,
              right: 0, top: 0, bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)])
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
            
            // HUD Overlay on Canvas (Compact Mini-Bubble)
            if (!_state.showIntro)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _state.isSidebarOpen ? sidebarWidth : 0, right: 0, bottom: 20,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black12),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))]
                    ),
                    child: _state.simCompleted 
                       ? Row(mainAxisSize: MainAxisSize.min, children: [
                           const Icon(Icons.check_circle, color: Colors.green, size: 20), const SizedBox(width: 8),
                           Flexible(child: Text(_state.hudMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold))),
                         ])
                       : Text(_state.hudMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),

            // Canvas Action Buttons
            if (!_state.showIntro && !_state.simCompleted)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _state.isSidebarOpen ? sidebarWidth : 0, right: 0, bottom: 80,
                child: Center(
                  child: Wrap(
                    spacing: 12,
                    children: [
                      if (showDrawArcBtn)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), elevation: 8),
                          onPressed: () { HapticFeedback.lightImpact(); _state.drawArcAction(); },
                          icon: const Icon(Icons.edit), label: Text(_state.t('btn_draw_arc'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      if (showUnfoldBtn)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), elevation: 8),
                          onPressed: () { HapticFeedback.lightImpact(); _state.unfoldAction(); },
                          icon: const Icon(Icons.unfold_more), label: Text(_state.t('btn_unfold'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      if (showMarkPointBtn)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), elevation: 8),
                          onPressed: () { HapticFeedback.lightImpact(); _state.markPointAction(); },
                          icon: const Icon(Icons.add_location_alt), label: Text(_state.t('btn_mark_pt'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                    ],
                  ),
                ),
              ),

            // Tools Selection Panel
            if (!_state.showIntro && !_state.simCompleted)
              Positioned(
                top: 100, right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.indigoAccent.withOpacity(0.5)),
                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))]
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_state.scenario >= 1 && _state.scenario <= 3)
                        _toolBtn(Icons.architecture, 'compass'),
                      if ((_state.scenario == 0 && _state.step >= 3) || (_state.scenario >= 1 && _state.scenario <= 3) || (_state.scenario == 4 && _state.step >= 2))
                        _toolBtn(Icons.straighten, 'ruler'),
                      if (_state.scenario == 4 && _state.step >= 2)
                        _toolBtn(Icons.speed, 'protractor'),
                    ],
                  ),
                ),
              ),

            // Sidebar (Restructured to purely use ListView to completely prevent overflow)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _state.isSidebarOpen ? 0 : -sidebarWidth,
              top: 0, bottom: 0, width: sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.95),
                  border: Border(right: BorderSide(color: Colors.indigo.withOpacity(0.3))),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(5,0))]
                ),
                child: ListView(
                  padding: EdgeInsets.zero, // Important to span up correctly without safe area
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 20),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40), // Provide visual padding below floating toggle icon
                          Text(_state.t('shutterTitle'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigoAccent, height: 1.2)),
                          const SizedBox(height: 6),
                          Text(_state.t('appSubtitle'), style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    
                    // Controls
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 32, padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.indigoAccent.withOpacity(0.5))),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.language, color: Colors.indigoAccent, size: 16), const SizedBox(width: 8), Text(_state.lang.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white))]),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _state.resetActivity, icon: const Icon(Icons.refresh, size: 14), label: Text(_state.t('reset'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 32)),
                          )
                        ],
                      ),
                    ),
                    
                    // Scenario Dropdown
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_state.t('selectScenario').toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            isExpanded: true, dropdownColor: const Color(0xFF1E293B), value: _state.scenario,
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                            items: [0,1,2,3,4].map((i) => DropdownMenuItem(value: i, child: Text(_state.getScenarioText(i, 'title'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (v) { if (v != null) _state.loadScenario(v); },
                          ),
                        ],
                      ),
                    ),
                      
                    // Mission Objective Target Output
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10), padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.indigo.withOpacity(0.3))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(_state.t('missionObj'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                          const SizedBox(height: 4),
                          Text(_state.getScenarioText(_state.scenario, 'objective'), style: const TextStyle(fontSize: 13, color: Colors.white)),
                        ]
                      )
                    ),
                    
                    // Generated Steps
                    ...List.generate(
                      (translations['en']!['scenarios'] as List)[_state.scenario]['steps'].length,
                      (i) {
                        bool isPast = i < _state.step;
                        bool isCurrent = i == _state.step && !_state.simCompleted;
                        return Opacity(
                          opacity: (isPast || isCurrent || _state.simCompleted) ? 1.0 : 0.4,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20), padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: isCurrent ? Colors.indigoAccent : Colors.white24, width: isCurrent ? 2 : 1),
                              borderRadius: BorderRadius.circular(8), color: isCurrent ? Colors.indigo.withOpacity(0.1) : const Color(0xFF0F172A)
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isCurrent) const Padding(padding: EdgeInsets.only(top: 2, right: 8), child: Icon(Icons.adjust, color: Colors.indigoAccent, size: 16))
                                else const Padding(padding: EdgeInsets.only(top: 2, right: 8), child: Icon(Icons.check_circle, color: Colors.green, size: 16)),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(fontSize: 13, color: isCurrent ? Colors.white : Colors.white70, fontFamily: 'Plus Jakarta Sans', height: 1.4),
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
                    
                    const SizedBox(height: 20), // Bottom spacer
                    
                    // Sidebar Footer
                    Container(padding: const EdgeInsets.all(12), color: Colors.black26, width: double.infinity, child: Text(_state.t('footer'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)))
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
                        (_floatingStepPos.dx + details.delta.dx).clamp(0, MediaQuery.of(context).size.width - 280),
                        (_floatingStepPos.dy + details.delta.dy).clamp(0, MediaQuery.of(context).size.height - 150)
                      );
                    });
                  },
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigoAccent),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${_state.t('stepLabel')} ${_state.step + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                            const Icon(Icons.drag_indicator, color: Colors.white54, size: 16)
                          ],
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 13, color: Colors.white, fontFamily: 'Plus Jakarta Sans', height: 1.4),
                            children: _parseBoldText(_state.getStepText(_state.scenario, _state.step, 'text'))
                          )
                        ),
                      ],
                    ),
                  ),
                )
              ),

            // Floating Top-Left Sidebar Toggle Button (Always accessible & Fixed to Menu Lines)
            Positioned(
              top: 16, left: 16, 
              child: IconButton(
                icon: Icon(_state.isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.white, iconSize: 28,
                onPressed: () { HapticFeedback.lightImpact(); _state.toggleSidebar(); },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: const CircleBorder(),
                  shadowColor: Colors.black54,
                  elevation: 6,
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
                        (_successPopupPos.dx + details.delta.dx).clamp(0, MediaQuery.of(context).size.width - 320),
                        (_successPopupPos.dy + details.delta.dy).clamp(0, MediaQuery.of(context).size.height - 250)
                      );
                    });
                  },
                  child: Container(
                    width: 320, padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.95), borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber, width: 3), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(5, 5))],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.amber, size: 50), const SizedBox(height: 12),
                            Text(_state.t('finalSuccessTitle'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            const Text("All missions completed!\nYou've mastered Perpendicular Bisectors.", textAlign: TextAlign.center, style: TextStyle(color: Colors.amber, fontStyle: FontStyle.italic, fontSize: 13)),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                              onPressed: () { setState(() => _state.showSuccessPopup = false); _state.resetActivity(); },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text("Restart Lab", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        Positioned(
                          top: -10, right: -10,
                          child: IconButton(icon: const Icon(Icons.close, color: Colors.white), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => setState(() => _state.showSuccessPopup = false)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Shutter Screen Overlay
            if (_state.showIntro)
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: _state.showIntro ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, val, child) {
                    return Transform.translate(
                      offset: Offset(0, -MediaQuery.of(context).size.height * (1-val)),
                      child: Container(
                        color: const Color(0xFF0F172A),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.architecture, color: Colors.indigoAccent, size: 80),
                              const SizedBox(height: 20),
                              Text(_state.t('shutterTitle'), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              const SizedBox(height: 10),
                              Text(_state.t('appSubtitle'), style: const TextStyle(color: Colors.indigo, fontSize: 18)),
                              const SizedBox(height: 40),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
                                onPressed: () { AudioEngine.playSuccess(); setState(() => _state.showIntro = false); },
                                icon: const Icon(Icons.play_circle, size: 28),
                                label: Text(_state.t('enterLab'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
        margin: const EdgeInsets.symmetric(vertical: 4),
        width: 48, height: 48, 
        decoration: BoxDecoration(color: active ? Colors.indigo : Colors.white10, shape: BoxShape.circle, boxShadow: active ? [const BoxShadow(color: Colors.indigoAccent, blurRadius: 10)] : []),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class LabPainter extends CustomPainter {
  final LabState state;
  LabPainter(this.state) : super(repaint: state);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + state.canvasPan.dx, size.height / 2 + state.canvasPan.dy);
    canvas.scale(state.canvasScale);

    // Draw Background Grid
    final gridPaint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth=1;
    for (double i = -1500; i < 1500; i += 40) {
      canvas.drawLine(Offset(i, -1500), Offset(i, 1500), gridPaint);
      canvas.drawLine(Offset(-1500, i), Offset(1500, i), gridPaint);
    }

    _drawScenarioGeometry(canvas);

    // Draw Entities
    var sorted = List<SimItem>.from(state.entities);
    sorted.sort((a,b) => (a.isDragging ? 100 : a.z).compareTo(b.isDragging ? 100 : b.z));
    
    for (var d in sorted) {
      if (d.isHidden) continue;
      if (state.scenario == 4 && d.type == 'paper_corner' && state.paperState != 'flat') continue;

      canvas.save();
      if (d.type != 'eye_arc') canvas.translate(d.x, d.y);
      if (d.isDragging && d.type != 'ruler') canvas.scale(1.1);
      
      if (d.type == 'point' || d.type == 'intersection') {
        if (d.id == 'A' && state.scenario == 2) {
          canvas.drawCircle(Offset.zero, 6, Paint()..color = Colors.lightBlue);
          _drawText(canvas, d.label, 0, -20, color: Colors.white, size: 16, weight: FontWeight.bold);
        } else if (d.id == 'O' || d.id == 'X' || d.id == 'Y') {
          if (d.id == 'O') {
            canvas.drawCircle(Offset.zero, 6, Paint()..color = Colors.green);
            _drawText(canvas, d.label, -35, -20, color: Colors.white, size: 18, weight: FontWeight.bold);
          } else {
            canvas.drawCircle(Offset.zero, 6, Paint()..color = d.color);
            canvas.drawCircle(Offset.zero, 6, Paint()..color = Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
            _drawText(canvas, d.label, d.id == 'X' ? -35 : 35, -20, color: Colors.white, size: 18, weight: FontWeight.bold);
          }
        } else {
          // Normal point draw - ensure the hidden snapping points aren't visibly interfering when they have no label
          if (d.id == 'center_snap') { canvas.restore(); continue; }
          
          canvas.drawCircle(Offset.zero, 6, Paint()..color = d.color);
          canvas.drawCircle(Offset.zero, 6, Paint()..color = Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
          
          if (state.scenario == 3) {
            _drawText(canvas, d.label, 0, -25, color: Colors.white, size: 18, weight: FontWeight.bold);
          } else {
            _drawText(canvas, d.label, 0, d.offsetY, color: Colors.white, size: 16, weight: FontWeight.bold);
          }
        }
      } 
      else if (d.type == 'probe') {
        var ptX = state.entities.cast<SimItem?>().firstWhere((e) => e?.id == 'X', orElse: () => null);
        var ptY = state.entities.cast<SimItem?>().firstWhere((e) => e?.id == 'Y', orElse: () => null);
        if (ptX != null && ptY != null) {
          canvas.drawLine(Offset.zero, Offset(ptX.x - d.x, ptX.y - d.y), Paint()..color=Colors.yellow..strokeWidth=2..style=PaintingStyle.stroke);
          canvas.drawLine(Offset.zero, Offset(ptY.x - d.x, ptY.y - d.y), Paint()..color=Colors.yellow..strokeWidth=2..style=PaintingStyle.stroke);
          double dX = hypot(d.x - ptX.x, d.y - ptX.y); double dY = hypot(d.x - ptY.x, d.y - ptY.y);
          bool isEqual = (dX - dY).abs() < 15;
          _drawText(canvas, isEqual ? ((dX+dY)/2).toStringAsFixed(1) : dX.toStringAsFixed(1), (ptX.x - d.x)/2, (ptX.y - d.y)/2 - 10, color: isEqual ? Colors.green : Colors.white);
          _drawText(canvas, isEqual ? ((dX+dY)/2).toStringAsFixed(1) : dY.toStringAsFixed(1), (ptY.x - d.x)/2, (ptY.y - d.y)/2 - 10, color: isEqual ? Colors.green : Colors.white);
        }
        
        // Indicate to user they hit the spot
        if (state.isProbeEquidistant) {
          canvas.drawCircle(Offset.zero, 18, Paint()..color = Colors.greenAccent.withOpacity(0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
        }

        canvas.drawCircle(Offset.zero, 10, Paint()..color = Colors.red);
        canvas.drawCircle(Offset.zero, 15, Paint()..color = Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
        canvas.drawLine(const Offset(-20, 0), const Offset(20, 0), Paint()..color=Colors.white..strokeWidth=2);
        canvas.drawLine(const Offset(0, -20), const Offset(0, 20), Paint()..color=Colors.white..strokeWidth=2);
      }
      else if (d.type == 'compass') _drawCompass(canvas, d);
      else if (d.type == 'ruler') _drawRuler(canvas, d);
      else if (d.type == 'protractor') _drawProtractor(canvas, d);
      else if (d.type == 'eye_arc') {
        canvas.drawArc(Rect.fromCircle(center: Offset(d.x, d.y), radius: d.r), d.sa, d.diff, false, Paint()..color=Colors.lightBlue..strokeWidth=4..style=PaintingStyle.stroke);
        if (d.glow) {
          canvas.drawCircle(Offset(d.x, d.y), 8, Paint()..color = Colors.amber..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
        }
        canvas.drawCircle(Offset(d.x, d.y), 8, Paint()..color = Colors.orange);
      }
      else if (d.type == 'paper_corner') {
        canvas.drawCircle(Offset.zero, 30, Paint()..color = Colors.indigo.withOpacity(0.5));
        canvas.drawCircle(Offset.zero, 10, Paint()..color = Colors.white);
      }
      else if (d.type == 'fence') {
        double halfH = d.height / 2;
        canvas.drawRect(Rect.fromLTRB(-6, -halfH, 6, halfH), Paint()..color = Colors.brown);
        canvas.drawRect(Rect.fromLTRB(-2, -halfH, 2, halfH), Paint()..color = Colors.brown[800]!);
      }
      else if (d.type == 'treasure') {
        canvas.drawRect(const Rect.fromLTRB(-20, -15, 20, 10), Paint()..color = Colors.brown);
        canvas.drawArc(const Rect.fromLTRB(-20, -35, 20, 5), math.pi, math.pi, true, Paint()..color = Colors.brown[800]!);
      }
      else if (d.type == 'farmer') {
        canvas.drawCircle(const Offset(0, -15), 10, Paint()..color = Colors.yellow[600]!);
        canvas.drawRect(const Rect.fromLTRB(-10, -5, 10, 20), Paint()..color = d.label.contains('👨') ? Colors.blue : Colors.red);
        _drawText(canvas, d.label, 0, -15, size: 16);
      }
      
      canvas.restore();
    }
    
    // Draw Particles
    for (var p in state.particles) {
      canvas.drawCircle(Offset(p.x, p.y), 4, Paint()..color = p.color.withOpacity(p.life));
    }
    
    // S5 Verify Status
    if (state.scenario == 4 && state.step == 2) {
      canvas.save();
      canvas.translate(0, 100);
      if (state.protChecked && state.rulerChecked) {
        _drawText(canvas, "Perpendicular Bisector confirmed.", 0, 0, color: Colors.green, size: 24, weight: FontWeight.bold);
      } else if (state.protChecked) {
        _drawText(canvas, "Angle Verified: 90°", 0, 0, color: Colors.lightBlue, size: 20, weight: FontWeight.bold);
      } else if (state.rulerChecked) {
        _drawText(canvas, "Segments Verified: Equal Lengths", 0, 0, color: Colors.lightBlue, size: 20, weight: FontWeight.bold);
      }
      canvas.restore();
    }

    canvas.restore();
  }

  void _drawScenarioGeometry(Canvas canvas) {
    if (state.scenario == 0) {
      if (state.step == 4 && state.simCompleted) {
        Path eyePath = Path();
        eyePath.addArc(Rect.fromCircle(center: const Offset(0, 160), radius: 212), math.pi*1.25, math.pi*0.5);
        eyePath.addArc(Rect.fromCircle(center: const Offset(0, -160), radius: 212), math.pi*0.25, math.pi*0.5);
        canvas.drawPath(eyePath, Paint()..color=Colors.lightBlue.withOpacity(0.3));
        canvas.drawCircle(Offset.zero, 30, Paint()..color=Colors.black87);
        canvas.drawCircle(Offset.zero, 15, Paint()..color=Colors.white70);
      } else {
        canvas.drawLine(const Offset(-100, 0), const Offset(100, 0), Paint()..color = Colors.white..strokeWidth=3);
      }
    } else if (state.scenario == 1) {
      canvas.drawLine(const Offset(-100, 0), const Offset(100, 0), Paint()..color = Colors.white..strokeWidth=3);
    } else if (state.scenario == 2) {
      canvas.drawRect(const Rect.fromLTRB(-1000, -500, 1000, 500), Paint()..color = const Color(0xFF166534));
      canvas.drawRect(const Rect.fromLTRB(-1000, -500, 0, 500), Paint()..color = const Color(0xFF4ADE80));
      canvas.drawLine(const Offset(-1000, 0), const Offset(1000, 0), Paint()..color = Colors.white70..strokeWidth = 4);
    } else if (state.scenario == 3) {
      canvas.drawRect(const Rect.fromLTRB(-1000, -1000, 1000, 1000), Paint()..color = const Color(0xFFFEF3C7));
      for(double i=-1000; i<1000; i+=100) {
        canvas.drawLine(Offset(i, -1000), Offset(i, 1000), Paint()..color=Colors.amber.withOpacity(0.3)..strokeWidth=2);
        canvas.drawLine(Offset(-1000, i), Offset(1000, i), Paint()..color=Colors.amber.withOpacity(0.3)..strokeWidth=2);
      }
      canvas.save();
      canvas.translate(-220, -200);
      canvas.drawCircle(Offset.zero, 30, Paint()..color=Colors.amber[700]!..style=PaintingStyle.stroke..strokeWidth=3);
      canvas.drawLine(const Offset(0, -40), const Offset(0, 40), Paint()..color=Colors.amber[700]!..strokeWidth=3);
      canvas.drawLine(const Offset(-40, 0), const Offset(40, 0), Paint()..color=Colors.amber[700]!..strokeWidth=3);
      _drawText(canvas, "N", 0, -50, color: Colors.amber[700]!, size: 16, weight: FontWeight.bold);
      canvas.restore();
    } else if (state.scenario == 4) {
      canvas.drawRect(const Rect.fromLTRB(-1000, -1000, 1000, 1000), Paint()..color = const Color(0xFF1E293B));
      var corner = state.entities.cast<SimItem?>().firstWhere((e) => e?.type == 'paper_corner', orElse: () => null);
      
      if (state.paperState == 'flat') {
        if (corner != null && corner.isDragging) {
          double fx = (-200 + corner.x) / 2;
          canvas.drawRect(Rect.fromLTRB(fx, -140, 200, 140), Paint()..color = Colors.white);
          canvas.save(); canvas.clipRect(Rect.fromLTRB(fx, -140, 200, 140));
          canvas.drawLine(const Offset(-150, 0), const Offset(150, 0), Paint()..color=Colors.indigo..strokeWidth=4);
          canvas.drawCircle(const Offset(150, 0), 6, Paint()..color=Colors.indigo);
          canvas.restore();
          
          Path flap = Path()..moveTo(fx, -140)..lineTo(corner.x, corner.y - 140)..lineTo(corner.x, corner.y + 140)..lineTo(fx, 140)..close();
          canvas.drawPath(flap, Paint()..color = Colors.grey[200]!);
          canvas.save(); canvas.clipPath(flap);
          canvas.drawLine(Offset(corner.x - 50, corner.y), Offset(fx, 0), Paint()..color=Colors.indigo..strokeWidth=4);
          canvas.drawCircle(Offset(corner.x - 50, corner.y), 6, Paint()..color=Colors.indigo);
          canvas.restore();
        } else {
          canvas.drawRect(const Rect.fromLTRB(-200, -140, 200, 140), Paint()..color = Colors.white);
          canvas.drawLine(const Offset(-150, 0), const Offset(150, 0), Paint()..color=Colors.indigo..strokeWidth=4);
          canvas.drawCircle(const Offset(-150, 0), 6, Paint()..color=Colors.indigo);
          canvas.drawCircle(const Offset(150, 0), 6, Paint()..color=Colors.indigo);
        }
      } else if (state.paperState == 'folded') {
        canvas.drawRect(const Rect.fromLTRB(0, -140, 200, 140), Paint()..color = Colors.white);
        canvas.drawRect(const Rect.fromLTRB(0, -140, 20, 140), Paint()..color = Colors.black12);
        canvas.drawLine(const Offset(0, 0), const Offset(150, 0), Paint()..color=Colors.indigo..strokeWidth=4);
        canvas.drawCircle(const Offset(150, 0), 6, Paint()..color=Colors.indigo);
      } else if (state.paperState == 'unfolded') {
        canvas.drawRect(const Rect.fromLTRB(-200, -140, 200, 140), Paint()..color = Colors.white);
        canvas.drawLine(const Offset(0, -140), const Offset(0, 140), Paint()..color=Colors.grey..strokeWidth=2);
        canvas.drawLine(const Offset(-150, 0), const Offset(150, 0), Paint()..color=Colors.indigo..strokeWidth=4);
        canvas.drawCircle(const Offset(-150, 0), 6, Paint()..color=Colors.indigo);
        canvas.drawCircle(const Offset(150, 0), 6, Paint()..color=Colors.indigo);
      }
    }

    for (var l in state.lines) {
      if (state.scenario == 4 && state.paperState == 'folded') continue;
      canvas.drawLine(Offset(l['x1'], l['y1']), Offset(l['x2'], l['y2']), Paint()..color = l['color']..strokeWidth = l['w']);
    }
    for (var a in state.arcs) {
      double p = a.containsKey('p') ? a['p'] : 1.0;
      double sweep = a['ea'] - a['sa'];
      if (sweep != 0) {
        canvas.drawArc(Rect.fromCircle(center: Offset(a['x'], a['y']), radius: a['r']), a['sa'], sweep * p, false, Paint()..color=Colors.lightBlue..strokeWidth=2..style=PaintingStyle.stroke);
      }
    }
  }

  void _drawCompass(Canvas canvas, SimItem d) {
    canvas.save();
    canvas.rotate(d.angle);
    double hx = d.radius / 2; double hy = -100;
    canvas.drawLine(Offset.zero, Offset(hx, hy), Paint()..color=Colors.grey..strokeWidth=4..strokeCap=StrokeCap.round);
    canvas.drawLine(Offset(d.radius, 0), Offset(hx, hy), Paint()..color=Colors.grey..strokeWidth=4..strokeCap=StrokeCap.round);
    canvas.drawCircle(Offset(hx, hy), 8, Paint()..color=Colors.blueGrey);
    canvas.drawCircle(Offset.zero, 15, Paint()..color=Colors.lightBlue.withOpacity(0.8));
    canvas.drawCircle(Offset(d.radius, 0), 15, Paint()..color=Colors.lightBlue.withOpacity(0.8));
    if (d.isDragging) {
      canvas.save(); canvas.rotate(-d.angle); _drawText(canvas, "r=${d.radius.round()}", 30, -30, color: Colors.green, weight: FontWeight.bold); canvas.restore();
    }
    canvas.restore();
  }

  void _drawRuler(Canvas canvas, SimItem d) {
    canvas.save();
    canvas.translate(-d.x, -d.y);
    double dx = d.x2 - d.x1; double dy = d.y2 - d.y1; double dist = hypot(dx, dy); double angle = math.atan2(dy, dx);
    canvas.translate(d.x1, d.y1); canvas.rotate(angle);
    canvas.drawRRect(RRect.fromLTRBR(0, -20, dist, 20, const Radius.circular(6)), Paint()..color=Colors.white.withOpacity(0.15));
    canvas.drawRRect(RRect.fromLTRBR(0, -20, dist, 20, const Radius.circular(6)), Paint()..color=Colors.grey..style=PaintingStyle.stroke..strokeWidth=2);
    canvas.drawCircle(Offset.zero, 10, Paint()..color=Colors.lightBlue);
    canvas.drawCircle(Offset(dist, 0), 10, Paint()..color=Colors.lightBlue);
    
    if (state.scenario == 4 && state.rulerChecked) {
       canvas.save();
       canvas.rotate(-angle);
       _drawText(canvas, "Length 1: 5.0 cm     Length 2: 5.0 cm", dist/2, 25, weight: FontWeight.bold, size: 14);
       canvas.restore();
    }
    canvas.restore();
  }

  void _drawProtractor(Canvas canvas, SimItem d) {
    canvas.save();
    canvas.rotate(d.angle);
    canvas.drawArc(const Rect.fromLTRB(-80, -80, 80, 80), math.pi, math.pi, true, Paint()..color=Colors.indigo.withOpacity(0.2));
    canvas.drawArc(const Rect.fromLTRB(-80, -80, 80, 80), math.pi, math.pi, true, Paint()..color=Colors.indigo..style=PaintingStyle.stroke..strokeWidth=2);
    
    final linePaint = Paint()..color = Colors.white..strokeWidth=1;
    for(int i=0; i<=180; i+=10) {
      double angle = math.pi + i * math.pi/180;
      double r1 = i % 90 == 0 ? 70 : 75;
      canvas.drawLine(Offset(r1*math.cos(angle), r1*math.sin(angle)), Offset(80*math.cos(angle), 80*math.sin(angle)), linePaint);
    }
    
    if (state.scenario == 4 && state.protChecked) {
      canvas.drawRect(const Rect.fromLTRB(0, -15, 15, 0), Paint()..color = Colors.indigo..style = PaintingStyle.stroke..strokeWidth = 2);
      _drawText(canvas, "90°", 30, -30, color: Colors.white, weight: FontWeight.bold, size: 16);
    } else {
      _drawText(canvas, "90°", 0, -40, color: Colors.white, weight: FontWeight.bold, size: 16);
    }
    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, double x, double y, {Color color = Colors.white, double size = 12, FontWeight weight = FontWeight.normal, double maxW = 300, FontStyle style = FontStyle.normal}) {
    final tp = TextPainter(text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: weight, fontStyle: style, fontFamily: 'Plus Jakarta Sans')), textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: maxW); tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}