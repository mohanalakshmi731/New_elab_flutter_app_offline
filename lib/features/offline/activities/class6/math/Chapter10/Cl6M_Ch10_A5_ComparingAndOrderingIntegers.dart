// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Cl6M_Ch10_A5_ComparingAndOrderingIntegers(),
    ),
  );
}

// ============================================================================
// LOCALIZATION (i18n)
// ============================================================================
const Map<String, Map<String, String>> i18n = {
  'en': {
    'shutterTitle':
        "Comparing and Ordering Integers (The Integer Tower Challenge)",
    'appTitle': "Comparing & Ordering Integers",
    'appSubtitle': "Class 6 • THE OTHER SIDE OF ZERO",
    'enterLab': "Enter Simulation",
    'settings': "Settings",
    'theme': "Theme",
    'darkMode': "Switch to Dark Mode",
    'lightMode': "Switch to Light Mode",
    'boardFontSize': "Text Size",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'doneBtn': "Done",
    'learnLbl': "Objective:",
    'closeBtn': "Close",
    'summaryTitle': "Goal Reached!",
    'resetBtn': "Reset Lab",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'labCompleted': "Lab Completed!",
    'finalDesc':
        "You have successfully learned how to compare and order integers!",
    'lbl_mission': "Mission:",
    'lbl_floor': "Floor",
    'lbl_int_tower': "Integer Tower",
    'lbl_lowest': "Lowest\nFloor",
    'lbl_2nd': "2nd\nLowest",
    'lbl_3rd': "3rd\nLowest",
    'lbl_highest': "Highest\nFloor",
    'lbl_finish': "Finish",
    's3_summary_msg':
        "Ordering integers is like lining people up from the lowest floor to the highest!",

    // Scenarios
    's1_title': "1. Higher Ground: Comparing Positive and Negative",
    's1_obj':
        "Visually understand and compare a positive integer with a negative integer by placing characters on different floors.",
    's1_step1_task': "DRAG Jay into the lift.",
    's1_step1_out':
        "Jay is placed inside the lift, ready to travel to a positive floor.",
    's1_step2_task': "TAP the '+' button two times to send Jay to Floor +2.",
    's1_step2_out':
        "The lift elevates Jay to Floor +2, representing a positive value.",
    's1_step3_task': "DRAG Aman into the lift.",
    's1_step3_out':
        "Aman is placed inside the lift, ready to travel to a negative floor.",
    's1_step4_task': "TAP the '-' button one time to send Aman to Floor -1.",
    's1_step4_out':
        "The lift descends Aman to Floor -1, representing a negative value.",
    's1_step5_task':
        "Compare the positions. DRAG the correct symbol ('>', '<', '=') into the box.",
    's1_step5_out':
        "Jay is on a higher floor than Aman. So, +2 is GREATER THAN -1. Positive numbers are always greater than negative numbers!",
    's1_step6_task': "Review the summary.",
    's1_step6_out': "Comparison completed.",
    's1_hud1': "Drag Jay (Green character) into the lift.",
    's1_hud2': "Tap '+' 2 times on the control panel.",
    's1_hud3': "Drag Aman (Orange character) into the lift.",
    's1_hud4': "Tap '-' 1 time on the control panel.",
    's1_hud5': "Drag the correct math symbol into the comparison box.",
    's1_hud6': "Challenge Completed!",

    's2_title': "2. Deeper Down: Comparing Two Negatives",
    's2_obj':
        "Understand the concept that for negative numbers, the one with the larger absolute value is smaller.",
    's2_step1_task': "Aman is still on Floor -1. DRAG Binnu into the lift.",
    's2_step1_out': "Binnu enters the lift, ready to go deeper underground.",
    's2_step2_task':
        "TAP the '-' button three times to send Binnu to Floor -3.",
    's2_step2_out':
        "The lift descends past Aman, placing Binnu at a lower position.",
    's2_step3_task':
        "Compare the positions. DRAG the correct symbol into the box.",
    's2_step3_out':
        "Binnu is on a lower floor than Aman. So, -3 is LESS THAN -1. The further you go below ground, the smaller the number becomes!",
    's2_step4_task': "Review the summary.",
    's2_step4_out': "Comparison completed.",
    's2_hud1': "Drag Binnu (Pink character) into the lift.",
    's2_hud2': "Tap '-' 3 times on the control panel.",
    's2_hud3': "Drag the correct math symbol into the comparison box.",
    's2_hud4': "Challenge Completed!",

    's3_title': "3. Line Them Up: Ordering Integers",
    's3_obj':
        "Order a set of four integers from least to greatest by placing them on their floors and arranging them.",
    's3_step1_task':
        "DRAG and DROP each character onto their correct floor: Asin (+5), Aman (-1), Bela (0), Binnu (-3).",
    's3_step1_out':
        "All characters are accurately positioned, visualising their numerical distance from Floor 0.",
    's3_step2_task':
        "DRAG the icon for each character into the slots from Lowest to Highest Floor.",
    's3_step2_out':
        "Ordering integers is like lining people up from the lowest floor to the highest! -3 < -1 < 0 < +5",
    's3_step3_task': "Review summary, tap 'Finish'.",
    's3_step3_out': "Scenario completed.",
    's3_hud1': "Drag each character to their labeled floor level.",
    's3_hud2': "Drag the character icons to the sorting slots at the bottom.",
    's3_hud3': "Tap Finish.",

    's4_title': "4. The Lowest Level (Challenge)",
    's4_obj': "Given a set of four integers, identify the smallest one.",
    's4_step1_task':
        "Identify who is on the lowest floor among Dev (-2), Sita (-5), Ravi (+1), Priya (-4). DRAG that character to the chest.",
    's4_step1_out': "-5 is the smallest number. Sita opens the chest!",
    's4_hud1':
        "Find the character with the smallest integer and drag them to the chest on Floor -5.",
    's4_find_me': "Find me!",
    's4_success': "SUCCESS!\nSita (-5) is correct!\n-5 is the lowest floor!",
    's4_retry': "retry...",

    's5_title': "5. The Tower Race (Challenge)",
    's5_obj':
        "Given a set of three integers, order them from greatest to least.",
    's5_step1_task':
        "Award the medals! Ken (+4), Maria (+1), Leo (-2). The highest floor gets 1st place. DRAG racers to the podium.",
    's5_step1_out': "Ken is 1st (+4), Maria is 2nd (+1), Leo is 3rd (-2).",
    's5_hud1': "Drag each racer to the 1st, 2nd, or 3rd place podium spot.",
  },
  'hi': {
    'shutterTitle':
        "पूर्णांकों की तुलना करना और क्रमबद्ध करना (इंटीजर टावर चुनौती)",
    'appTitle': "पूर्णांकों की तुलना और क्रम",
    'appSubtitle': "कक्षा 6 • शून्य की दूसरी ओर",
    'enterLab': "सिमुलेशन दर्ज करें",
    'settings': "सेटिंग्स",
    'theme': "थीम",
    'darkMode': "डार्क मोड",
    'lightMode': "लाइट मोड",
    'boardFontSize': "टेक्स्ट आकार",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'doneBtn': "पूर्ण",
    'learnLbl': "उद्देश्य:",
    'closeBtn': "बंद करें",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'resetBtn': "रीसेट करें",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'labCompleted': "लैब पूर्ण!",
    'finalDesc':
        "आपने पूर्णांकों की तुलना करना और उन्हें क्रम में रखना सफलतापूर्वक सीख लिया है!",
    'lbl_mission': "मिशन:",
    'lbl_floor': "मंजिल",
    'lbl_int_tower': "पूर्णांक टावर",
    'lbl_lowest': "सबसे निचली\nमंजिल",
    'lbl_2nd': "दूसरी\nनिचली",
    'lbl_3rd': "तीसरी\nनिचली",
    'lbl_highest': "सबसे ऊँची\nमंजिल",
    'lbl_finish': "समाप्त",
    's3_summary_msg':
        "पूर्णांकों को क्रमित करना लोगों को सबसे निचली मंजिल से सबसे ऊँची मंजिल तक खड़ा करने जैसा है!",

    's1_title': "1. ऊँचा मैदान: धनात्मक और ऋणात्मक की तुलना",
    's1_obj':
        "पात्रों को विभिन्न मंजिलों पर रखकर धनात्मक और ऋणात्मक पूर्णांक को दृष्टिगत रूप से समझें और तुलना करें।",
    's1_step1_task': "जय को लिफ्ट में खींचें।",
    's1_step1_out':
        "जय को लिफ्ट के अंदर रखा गया है, जो सकारात्मक मंजिल की यात्रा के लिए तैयार है।",
    's1_step2_task':
        "जय को मंजिल +2 पर भेजने के लिए '+' बटन पर दो बार टैप करें।",
    's1_step2_out':
        "लिफ्ट जय को मंजिल +2 पर ले जाती है, जो एक सकारात्मक मूल्य का प्रतिनिधित्व करता है।",
    's1_step3_task': "अमन को लिफ्ट में खींचें।",
    's1_step3_out':
        "अमन को लिफ्ट के अंदर रखा गया है, जो नकारात्मक मंजिल की यात्रा के लिए तैयार है।",
    's1_step4_task':
        "अमन को मंजिल -1 पर भेजने के लिए '-' बटन पर एक बार टैप करें।",
    's1_step4_out':
        "लिफ्ट अमन को मंजिल -1 पर नीचे लाती है, जो एक नकारात्मक मूल्य का प्रतिनिधित्व करता है।",
    's1_step5_task':
        "स्थितियों की तुलना करें। बॉक्स में सही चिह्न ('>', '<', '=') खींचें।",
    's1_step5_out':
        "जय अमन से ऊँची मंजिल पर है। अतः, +2, -1 से बड़ा है। धनात्मक संख्याएँ हमेशा ऋणात्मक संख्याओं से बड़ी होती हैं!",
    's1_step6_task': "सारांश की समीक्षा करें।",
    's1_step6_out': "तुलना पूरी हुई।",
    's1_hud1': "जय (हरा पात्र) को लिफ्ट में खींचें।",
    's1_hud2': "कंट्रोल पैनल पर '+' को 2 बार टैप करें।",
    's1_hud3': "अमन (नारंगी पात्र) को लिफ्ट में खींचें।",
    's1_hud4': "कंट्रोल पैनल पर '-' को 1 बार टैप करें।",
    's1_hud5': "तुलना बॉक्स में सही गणित का चिह्न खींचें।",
    's1_hud6': "चुनौती पूरी हुई!",

    's2_title': "2. और गहरा: दो ऋणात्मक की तुलना",
    's2_obj':
        "इस अवधारणा को समझें कि ऋणात्मक संख्याओं के लिए, बड़े पूर्ण मान वाली संख्या छोटी होती है।",
    's2_step1_task': "अमन अभी भी मंजिल -1 पर है। बिन्नू को लिफ्ट में खींचें।",
    's2_step1_out':
        "बिन्नू लिफ्ट में प्रवेश करती है, और गहराई में जाने के लिए तैयार है।",
    's2_step2_task':
        "बिन्नू को मंजिल -3 पर भेजने के लिए '-' बटन पर तीन बार टैप करें।",
    's2_step2_out':
        "लिफ्ट अमन के नीचे जाती है, और बिन्नू को निचली स्थिति में रखती है।",
    's2_step3_task': "स्थितियों की तुलना करें। बॉक्स में सही चिह्न खींचें।",
    's2_step3_out':
        "बिन्नू अमन से नीची मंजिल पर है। अतः, -3, -1 से छोटा है। आप जितना नीचे जाएंगे, संख्या उतनी ही छोटी होती जाएगी!",
    's2_step4_task': "सारांश की समीक्षा करें।",
    's2_step4_out': "तुलना पूरी हुई।",
    's2_hud1': "बिन्नू (गुलाबी पात्र) को लिफ्ट में खींचें।",
    's2_hud2': "कंट्रोल पैनल पर '-' को 3 बार टैप करें।",
    's2_hud3': "तुलना बॉक्स में सही गणित का चिह्न खींचें।",
    's2_hud4': "चुनौती पूरी हुई!",

    's3_title': "3. पंक्ति में लगाएँ: पूर्णांकों को क्रमित करना",
    's3_obj':
        "चार पूर्णांकों के एक सेट को उनकी मंजिलों पर रखकर सबसे छोटे से सबसे बड़े के क्रम में लगाएँ।",
    's3_step1_task':
        "प्रत्येक पात्र को उसकी सही मंजिल पर खींचें और छोड़ें: असिन (+5), अमन (-1), बेला (0), बिन्नू (-3)।",
    's3_step1_out':
        "सभी पात्र सटीक रूप से स्थित हैं, जो मंजिल 0 से उनकी दूरी को दर्शाते हैं।",
    's3_step2_task':
        "प्रत्येक पात्र के आइकन को 'सबसे निचली' से 'सबसे ऊँची' मंजिल के स्लॉट में खींचें।",
    's3_step2_out':
        "पूर्णांकों को क्रमित करना लोगों को सबसे निचली मंजिल से सबसे ऊँची मंजिल तक खड़ा करने जैसा है! -3 < -1 < 0 < +5",
    's3_step3_task': "सारांश की समीक्षा करें, 'समाप्त' पर टैप करें।",
    's3_step3_out': "परिदृश्य पूरा हुआ।",
    's3_hud1': "प्रत्येक पात्र को उनके लेबल वाले मंजिल स्तर पर खींचें।",
    's3_hud2': "पात्र चिह्नों को नीचे छँटाई स्लॉट में खींचें।",
    's3_hud3': "समाप्त पर टैप करें।",

    's4_title': "4. सबसे निचला स्तर (चुनौती)",
    's4_obj':
        "चार पूर्णांकों के दिए गए सेट में से, सबसे छोटी संख्या की पहचान करें।",
    's4_step1_task':
        "पहचानें कि देव (-2), सीता (-5), रवि (+1), प्रिया (-4) में से सबसे निचली मंजिल पर कौन है। उस पात्र को संदूक तक खींचें।",
    's4_step1_out': "-5 सबसे छोटी संख्या है। सीता संदूक खोलती है!",
    's4_hud1':
        "सबसे छोटे पूर्णांक वाले पात्र को खोजें और उन्हें मंजिल -5 पर संदूक तक खींचें।",
    's4_find_me': "मुझे ढूंढो!",
    's4_success': "सफल!\nसीता (-5) सही है!\n-5 सबसे निचली मंजिल है!",
    's4_retry': "पुनः प्रयास करें...",

    's5_title': "5. टावर रेस (चुनौती)",
    's5_obj':
        "तीन पूर्णांकों के दिए गए सेट को, सबसे बड़े से सबसे छोटे के क्रम में लगाएँ।",
    's5_step1_task':
        "पदक प्रदान करें! केन (+4), मारिया (+1), लियो (-2)। सबसे ऊँची मंजिल वाले को प्रथम स्थान मिलता है। रेसर्स को पोडियम पर खींचें।",
    's5_step1_out': "केन प्रथम (+4), मारिया द्वितीय (+1), लियो तृतीय (-2) है।",
    's5_hud1':
        "प्रत्येक रेसर को प्रथम, द्वितीय, या तृतीय स्थान के पोडियम स्पॉट पर खींचें.",
  },
};

String t(String key, String lang) {
  return i18n[lang]?[key] ?? i18n['en']?[key] ?? key;
}

// ============================================================================
// AUDIO ENGINE
// ============================================================================
class AudioEngine {
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _pagePlayer = AudioPlayer();
  static final AudioPlayer _dropdownPlayer = AudioPlayer();

  // 1. Play a click sound
  static Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  // 2. Play a sound when a new page opens (Swoosh/Chime)
  static Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  // 3. Play the Dropdown sound
  static Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  // 4. Play an error sound (Soft thud)
  static Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  // 5. Play curtain screen entrance sound
  static Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================
class ScenarioConfig {
  final int id;
  final String titleKey;
  final String objKey;
  final int numSteps;

  ScenarioConfig(this.id, this.titleKey, this.objKey, this.numSteps);
}

class SimChar {
  String id;
  String name;
  double val;
  Color color;
  String sign;
  String state;
  double target;
  double floor;
  bool showLabel;

  SimChar({
    required this.id,
    required this.name,
    required this.val,
    required this.color,
    this.sign = '',
    this.state = 'hidden',
    this.target = 0,
    this.floor = 0,
    this.showLabel = false,
  });
}

class DragItem {
  String id;
  String type;
  double x, y, hx, hy;
  String val;
  SimChar? charRef;
  bool dropped;

  DragItem({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.hx,
    required this.hy,
    this.val = '',
    this.charRef,
    this.dropped = false,
  });
}

class DropZone {
  double x, y, w, h;
  String? expectedId;
  String? expectedVal;
  String? filledWith;

  DropZone({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.expectedId,
    this.expectedVal,
    this.filledWith,
  });
}

class Confetti {
  double x, y, vx, vy;
  Color color;
  Confetti({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
  });
}

class RetryAnim {
  double x, y, opacity;
  String text;
  RetryAnim({
    required this.x,
    required this.y,
    required this.opacity,
    required this.text,
  });
}

// ============================================================================
// MAIN APP COMPONENT
// ============================================================================
class Cl6M_Ch10_A5_ComparingAndOrderingIntegers extends StatefulWidget {
  const Cl6M_Ch10_A5_ComparingAndOrderingIntegers({super.key});

  @override
  State<Cl6M_Ch10_A5_ComparingAndOrderingIntegers> createState() =>
      _Cl6M_Ch10_A5_ComparingAndOrderingIntegersState();
}

class _Cl6M_Ch10_A5_ComparingAndOrderingIntegersState
    extends State<Cl6M_Ch10_A5_ComparingAndOrderingIntegers>
    with TickerProviderStateMixin {
  bool _showCurtain = true;
  late AnimationController _pulseCtrl;

  String lang = 'en';
  bool sidebarOpen = true;
  double sidebarWidth = 350.0;

  double panX = 0;
  double panY = 0;
  double zoom = 1.0;
  double _initialZoom = 1.0;

  int scenario = 1;
  int step = 0;
  bool successPopupVisible = false;

  late AnimationController _loop;
  final GlobalKey _canvasKey = GlobalKey();

  bool animatingLift = false;
  double liftFloor = 0;
  double liftVisualFloor = 0;
  double targetFloor = 0;
  List<SimChar> characters = [];
  List<DragItem> dragItems = [];
  List<DropZone> dropZones = [];
  String? comparisonResult;
  int itemsProcessed = 0;
  List<Confetti> confetti = [];
  RetryAnim? retryAnim;
  String? activeDrag;

  final Map<int, ScenarioConfig> configs = {
    1: ScenarioConfig(1, 's1_title', 's1_obj', 6),
    2: ScenarioConfig(2, 's2_title', 's2_obj', 4),
    3: ScenarioConfig(3, 's3_title', 's3_obj', 3),
    4: ScenarioConfig(4, 's4_title', 's4_obj', 1),
    5: ScenarioConfig(5, 's5_title', 's5_obj', 1),
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _loop.addListener(_onFrame);
    _loadScenario(1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _toolFitScreen();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pulseCtrl.dispose();
    _loop.dispose();
    super.dispose();
  }

  void _onFrame() {
    if (animatingLift) {
      double diff = targetFloor - liftFloor;
      if (diff.abs() < 0.05) {
        liftFloor = targetFloor;
        animatingLift = false;
        _checkLiftArrival();
      } else {
        liftFloor += diff * 0.1;
      }
      liftVisualFloor = liftFloor;
    }

    if (confetti.isNotEmpty) {
      for (var c in confetti) {
        c.x += c.vx;
        c.y += c.vy;
        c.vy += 0.4;
      }
      confetti.removeWhere((c) => c.y > 800);
    }

    if (retryAnim != null) {
      retryAnim!.opacity -= 0.02;
      retryAnim!.y -= 1;
      if (retryAnim!.opacity <= 0) retryAnim = null;
    }

    if (!_showCurtain) setState(() {});
  }

  void _toggleLanguage() {
    AudioEngine.playDropdown();
    setState(() {
      lang = lang == 'en' ? 'hi' : 'en';
    });
  }

  void _loadScenario(int id) {
    setState(() {
      if (id == 1) _showCurtain = true;
      scenario = id;
      step = 0;
      animatingLift = false;
      itemsProcessed = 0;
      confetti = [];
      successPopupVisible = false;
      comparisonResult = null;

      if (id == 1) {
        liftFloor = 0;
        liftVisualFloor = 0;
        characters = [
          SimChar(
            id: 'jay',
            name: 'Jay',
            val: 0,
            color: const Color(0xFF22C55E),
            target: 2,
            state: 'waiting',
          ),
          SimChar(
            id: 'aman',
            name: 'Aman',
            val: 0,
            color: const Color(0xFFF97316),
            target: -1,
            state: 'hidden',
          ),
        ];
      } else if (id == 2) {
        liftFloor = -1;
        liftVisualFloor = -1;
        characters = [
          SimChar(
            id: 'aman',
            name: 'Aman',
            val: 0,
            floor: -1,
            color: const Color(0xFFF97316),
            target: -1,
            state: 'dropped',
          ),
          SimChar(
            id: 'binnu',
            name: 'Binnu',
            val: 0,
            floor: 0,
            color: const Color(0xFFEC4899),
            target: -3,
            state: 'waiting',
          ),
        ];
      } else if (id == 3) {
        liftFloor = 0;
        liftVisualFloor = 0;
        characters = [
          SimChar(
            id: 'asin',
            name: 'Asin',
            val: 5,
            color: const Color(0xFFDB2777),
            sign: '+5',
            state: 'hidden',
            floor: 0,
          ),
          SimChar(
            id: 'aman',
            name: 'Aman',
            val: -1,
            color: const Color(0xFFF97316),
            sign: '-1',
            state: 'hidden',
            floor: 0,
          ),
          SimChar(
            id: 'bela',
            name: 'Bela',
            val: 0,
            color: const Color(0xFFF59E0B),
            sign: '0',
            state: 'hidden',
            floor: 0,
          ),
          SimChar(
            id: 'binnu',
            name: 'Binnu',
            val: -3,
            color: const Color(0xFFEC4899),
            sign: '-3',
            state: 'hidden',
            floor: 0,
          ),
        ];
      } else if (id == 4) {
        liftFloor = 0;
        liftVisualFloor = 0;
        characters = [
          SimChar(
            id: 'dev',
            name: 'Dev',
            val: -2,
            color: const Color(0xFF3B82F6),
            sign: '-2',
            state: 'hidden',
            floor: -2,
          ),
          SimChar(
            id: 'sita',
            name: 'Sita',
            val: -5,
            color: const Color(0xFFEC4899),
            sign: '-5',
            state: 'hidden',
            floor: -5,
          ),
          SimChar(
            id: 'ravi',
            name: 'Ravi',
            val: 1,
            color: const Color(0xFFF59E0B),
            sign: '+1',
            state: 'hidden',
            floor: 1,
          ),
          SimChar(
            id: 'priya',
            name: 'Priya',
            val: -4,
            color: const Color(0xFF8B5CF6),
            sign: '-4',
            state: 'hidden',
            floor: -4,
          ),
        ];
      } else if (id == 5) {
        liftFloor = 0;
        liftVisualFloor = 0;
        characters = [
          SimChar(
            id: 'ken',
            name: 'Ken',
            val: 4,
            color: const Color(0xFF3B82F6),
            sign: '+4',
            state: 'hidden',
            floor: 0,
          ),
          SimChar(
            id: 'maria',
            name: 'Maria',
            val: 1,
            color: const Color(0xFFEC4899),
            sign: '+1',
            state: 'hidden',
            floor: 0,
          ),
          SimChar(
            id: 'leo',
            name: 'Leo',
            val: -2,
            color: const Color(0xFFF59E0B),
            sign: '-2',
            state: 'hidden',
            floor: 0,
          ),
        ];
      }
      _setupDraggables();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _toolFitScreen());
  }

  void _setupDraggables() {
    dragItems.clear();
    dropZones.clear();

    double zeroY = 0;
    double bldX = -150;
    double floorHeight = 80;

    if (scenario == 1) {
      if (step == 0) {
        dragItems.add(
          DragItem(id: 'jay', type: 'char', x: -250, y: 140, hx: -250, hy: 140),
        );
        dropZones.add(
          DropZone(x: -50, y: -50, w: 200, h: 200, expectedId: 'jay'),
        );
      } else if (step == 2) {
        dragItems.add(
          DragItem(
            id: 'aman',
            type: 'char',
            x: -250,
            y: 140,
            hx: -250,
            hy: 140,
          ),
        );
        dropZones.add(
          DropZone(x: -50, y: -50, w: 200, h: 200, expectedId: 'aman'),
        );
      } else if (step == 4) {
        comparisonResult = null;
        double tx = 150, ty = 320;
        dragItems.add(
          DragItem(
            id: 'sym1',
            type: 'symbol',
            x: tx - 60,
            y: ty,
            hx: tx - 60,
            hy: ty,
            val: '>',
          ),
        );
        dragItems.add(
          DragItem(
            id: 'sym2',
            type: 'symbol',
            x: tx,
            y: ty,
            hx: tx,
            hy: ty,
            val: '<',
          ),
        );
        dragItems.add(
          DragItem(
            id: 'sym3',
            type: 'symbol',
            x: tx + 60,
            y: ty,
            hx: tx + 60,
            hy: ty,
            val: '=',
          ),
        );
        dropZones.add(
          DropZone(x: 150 - 25, y: 200 - 25, w: 50, h: 50, expectedVal: '>'),
        );
      }
    } else if (scenario == 2) {
      if (step == 0) {
        dragItems.add(
          DragItem(
            id: 'binnu',
            type: 'char',
            x: -300,
            y: 140,
            hx: -300,
            hy: 140,
          ),
        );
        dropZones.add(
          DropZone(x: -50, y: -50, w: 200, h: 200, expectedId: 'binnu'),
        );
      } else if (step == 2) {
        comparisonResult = null;
        double tx = 150, ty = zeroY - (-2) * floorHeight + 150;
        dragItems.add(
          DragItem(
            id: 'sym1',
            type: 'symbol',
            x: tx - 60,
            y: ty,
            hx: tx - 60,
            hy: ty,
            val: '>',
          ),
        );
        dragItems.add(
          DragItem(
            id: 'sym2',
            type: 'symbol',
            x: tx,
            y: ty,
            hx: tx,
            hy: ty,
            val: '<',
          ),
        );
        dragItems.add(
          DragItem(
            id: 'sym3',
            type: 'symbol',
            x: tx + 60,
            y: ty,
            hx: tx + 60,
            hy: ty,
            val: '=',
          ),
        );
        dropZones.add(
          DropZone(
            x: 150 - 25,
            y: zeroY - (-2) * floorHeight - 25,
            w: 50,
            h: 50,
            expectedVal: '<',
          ),
        );
      }
    } else if (scenario == 3) {
      if (step == 0) {
        double sx = -240, sy = 320;
        List<String> ids = ['asin', 'aman', 'bela', 'binnu'];
        for (int i = 0; i < ids.length; i++) {
          var char = characters.firstWhere((c) => c.id == ids[i]);
          dragItems.add(
            DragItem(
              id: char.id,
              type: 'char_sign',
              x: sx + i * 160,
              y: sy,
              hx: sx + i * 160,
              hy: sy,
              charRef: char,
            ),
          );
          double dzY = zeroY - char.val * floorHeight;
          dropZones.add(
            DropZone(
              x: bldX,
              y: dzY - floorHeight,
              w: 160,
              h: floorHeight,
              expectedId: char.id,
            ),
          );
        }
      } else if (step == 1) {
        List<String> ids = ['asin', 'aman', 'bela', 'binnu'];
        List<String> sorted = ['binnu', 'aman', 'bela', 'asin'];
        double pY = 180;
        for (int i = 0; i < 4; i++) {
          dropZones.add(
            DropZone(
              x: -220 + i * 110.0,
              y: pY + 20,
              w: 100,
              h: 120,
              expectedId: sorted[i],
            ),
          );
        }
        for (int i = 0; i < 4; i++) {
          var char = characters.firstWhere((c) => c.id == ids[i]);
          dragItems.add(
            DragItem(
              id: char.id,
              type: 'icon',
              x: -150 + i * 100.0,
              y: pY + 180,
              hx: -150 + i * 100.0,
              hy: pY + 180,
              charRef: char,
            ),
          );
        }
      }
    } else if (scenario == 4) {
      if (step == 0) {
        double sx = -200, sy = zeroY + 120;
        for (int i = 0; i < characters.length; i++) {
          dragItems.add(
            DragItem(
              id: characters[i].id,
              type: 'char_sign',
              x: sx + i * 140,
              y: sy,
              hx: sx + i * 140,
              hy: sy,
              charRef: characters[i],
            ),
          );
          characters[i].state = 'hidden';
        }
        double cx = bldX + 180, cy = zeroY - (-5) * floorHeight;
        dropZones.add(
          DropZone(x: cx - 50, y: cy - 80, w: 100, h: 100, expectedId: 'sita'),
        );
      }
    } else if (scenario == 5) {
      if (step == 0) {
        double sx = -150, sy = 150;
        for (int i = 0; i < characters.length; i++) {
          dragItems.add(
            DragItem(
              id: characters[i].id,
              type: 'char_sign',
              x: sx + i * 150,
              y: sy,
              hx: sx + i * 150,
              hy: sy,
              charRef: characters[i],
            ),
          );
          characters[i].state = 'hidden';
        }
        double pY = 150;
        dropZones.add(
          DropZone(x: -60, y: pY - 160 - 80, w: 120, h: 80, expectedId: 'ken'),
        );
        dropZones.add(
          DropZone(
            x: -160,
            y: pY - 100 - 80,
            w: 100,
            h: 80,
            expectedId: 'maria',
          ),
        );
        dropZones.add(
          DropZone(x: 60, y: pY - 70 - 80, w: 100, h: 80, expectedId: 'leo'),
        );
      }
    }
  }

  void _advanceStep() {
    int maxSteps = configs[scenario]!.numSteps;
    setState(() {
      step++;
      itemsProcessed = 0;
      if (step >= maxSteps) {
        _checkScenarioSuccess();
      } else {
        _setupDraggables();
        _toolFitScreen();
      }
    });
  }

  void _checkScenarioSuccess() {
    setState(() {
      step = configs[scenario]!.numSteps;
      if (scenario == 5) {
        Future.delayed(const Duration(seconds: 1), _showFinalPopup);
      }
    });
  }

  void _showFinalPopup() {
    setState(() {
      successPopupVisible = true;
    });
  }

  void _triggerLiftAction(int dir) {
    if (animatingLift) return;
    AudioEngine.playClick();
    setState(() {
      targetFloor = liftFloor + dir;
      animatingLift = true;
    });
  }

  void _checkLiftArrival() {
    itemsProcessed++;
    int req = 0;
    if (scenario == 1 && step == 1) req = 2;
    if (scenario == 1 && step == 3) req = 1;
    if (scenario == 2 && step == 1) req = 3;

    if (itemsProcessed == req) {
      try {
        var char = characters.firstWhere((c) => c.state == 'in_lift');
        char.state = 'dropped';
      } catch (_) {}
      AudioEngine.playPageOpen();
      Future.delayed(const Duration(milliseconds: 1500), _advanceStep);
    }
  }

  void _processDrop(DragItem item, DropZone dz) {
    if (scenario == 1 || scenario == 2) {
      if (item.type == 'char') {
        item.dropped = true;
        var char = characters.firstWhere((c) => c.id == item.id);
        char.state = 'in_lift';
        AudioEngine.playPageOpen();
        Future.delayed(const Duration(milliseconds: 1500), _advanceStep);
      } else if (item.type == 'symbol') {
        item.dropped = true;
        dz.filledWith = item.id;
        comparisonResult = item.val;
        dragItems.clear();
        AudioEngine.playPageOpen();
        Future.delayed(const Duration(milliseconds: 2500), _advanceStep);
      }
    } else if (scenario == 3) {
      item.dropped = true;
      dz.filledWith = item.id;
      if (step == 0) {
        var char = characters.firstWhere((c) => c.id == item.id);
        char.state = 'dropped';
        char.floor = char.val;
      } else if (step == 1) {
        item.x = dz.x + dz.w / 2;
        item.y = dz.y + dz.h / 2;
      }
      AudioEngine.playClick();
      if (dropZones.every((z) => z.filledWith != null)) {
        AudioEngine.playPageOpen();
        Future.delayed(const Duration(milliseconds: 1500), _advanceStep);
      }
    } else if (scenario == 4) {
      item.dropped = true;
      dz.filledWith = item.id;
      confetti.clear();
      List<Color> colors = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.purple,
      ];
      for (int i = 0; i < 60; i++) {
        confetti.add(
          Confetti(
            x: dz.x + dz.w / 2,
            y: dz.y + 20,
            vx: (Random().nextDouble() - 0.5) * 15,
            vy: (Random().nextDouble() - 1) * 15 - 5,
            color: colors[Random().nextInt(colors.length)],
          ),
        );
      }
      AudioEngine.playPageOpen();
      _advanceStep();
      Future.delayed(const Duration(milliseconds: 3500), _checkScenarioSuccess);
    } else if (scenario == 5) {
      item.dropped = true;
      dz.filledWith = item.id;
      item.x = dz.x + dz.w / 2;
      item.y = dz.y + dz.h;
      var char = characters.firstWhere((c) => c.id == item.id);
      char.state = 'dropped';
      AudioEngine.playClick();

      if (dropZones.every((z) => z.filledWith != null)) {
        AudioEngine.playPageOpen();
        confetti.clear();
        List<Color> colors = [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.purple,
        ];
        for (int i = 0; i < 100; i++) {
          confetti.add(
            Confetti(
              x: 0,
              y: -100,
              vx: (Random().nextDouble() - 0.5) * 20,
              vy: (Random().nextDouble() - 1) * 20 - 5,
              color: colors[Random().nextInt(colors.length)],
            ),
          );
        }
        Future.delayed(const Duration(milliseconds: 2500), _advanceStep);
      }
    }
  }

  // --- Gestures & Math ---
  Offset _screenToWorld(Offset screenPos) {
    if (_canvasKey.currentContext == null) return Offset.zero;
    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset local = box.globalToLocal(screenPos);
    double cx = box.size.width / 2;
    double cy = box.size.height / 2;
    return Offset((local.dx - cx - panX) / zoom, (local.dy - cy - panY) / zoom);
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  // Pure click handler for buttons that instantly triggers
  void _handleTapDown(TapDownDetails details) {
    Offset wPt = _screenToWorld(details.globalPosition);

    if (!animatingLift) {
      double zeroY = 0;
      double fh = 80;

      // Handle UI buttons instantly
      if (scenario == 1 || scenario == 2) {
        if (scenario == 1 && step == 1) {
          if (_hitTestBox(-350 - 40, -50 - 60 - 40, 80, 80, wPt)) {
            _triggerLiftAction(1);
            return;
          }
        } else if (scenario == 1 && step == 3) {
          if (_hitTestBox(-350 - 40, -50 + 40 - 40, 80, 80, wPt)) {
            _triggerLiftAction(-1);
            return;
          }
        } else if (scenario == 2 && step == 1) {
          if (_hitTestBox(350 - 40, -50 + 40 - 40, 80, 80, wPt)) {
            _triggerLiftAction(-1);
            return;
          }
        } else if (scenario == 1 && step == 5) {
          if (_hitTestBox(150 - 90, 0 + 250, 180, 60, wPt)) {
            AudioEngine.playClick();
            _advanceStep();
            return;
          }
        } else if (scenario == 2 && step == 3) {
          if (_hitTestBox(150 - 90, zeroY - (-2) * fh + 250, 180, 60, wPt)) {
            AudioEngine.playClick();
            _advanceStep();
            return;
          }
        }
      } else if (scenario == 3 && step == 2) {
        if (_hitTestBox(-90, 80 + 130, 180, 70, wPt)) {
          AudioEngine.playClick();
          _advanceStep();
          return;
        }
      }
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _initialZoom = zoom;
    Offset wPt = _screenToWorld(details.focalPoint);

    if (!animatingLift) {
      // Check drag items for grabbing/moving logic
      for (var item in dragItems.reversed) {
        if (!item.dropped) {
          double hitY = item.y;
          double r = 40;
          if (item.type == 'char' || item.type == 'char_sign') {
            hitY -= 30;
            r = 60;
          }
          if ((wPt.dx - item.x).abs() < r && (wPt.dy - hitY).abs() < r) {
            AudioEngine.playClick();
            setState(() {
              activeDrag = item.id;
            });
            return;
          }
        }
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (activeDrag != null) {
      Offset wPt = _screenToWorld(details.focalPoint);
      setState(() {
        var item = dragItems.firstWhere((i) => i.id == activeDrag);
        item.x = wPt.dx;
        item.y = wPt.dy;
      });
    } else {
      setState(() {
        panX += details.focalPointDelta.dx;
        panY += details.focalPointDelta.dy;
        zoom = (_initialZoom * details.scale).clamp(0.2, 3.0);
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (activeDrag != null) {
      var item = dragItems.firstWhere((i) => i.id == activeDrag);
      DropZone? droppedOn;
      bool incorrectDrop = false;

      for (var dz in dropZones) {
        if (scenario == 5 || scenario == 4) {
          if (_hitTestBox(dz.x, dz.y, dz.w, dz.h, Offset(item.x, item.y))) {
            if (dz.expectedId == item.id && dz.filledWith == null) {
              droppedOn = dz;
            } else {
              incorrectDrop = true;
            }
            break;
          }
        } else {
          if (_hitTestBox(dz.x, dz.y, dz.w, dz.h, Offset(item.x, item.y))) {
            if ((dz.expectedId != null && dz.expectedId == item.id) ||
                (dz.expectedVal != null && dz.expectedVal == item.val)) {
              if (dz.filledWith == null) {
                droppedOn = dz;
                break;
              }
            }
          }
        }
      }

      setState(() {
        if (droppedOn != null) {
          _processDrop(item, droppedOn);
        } else if (incorrectDrop) {
          AudioEngine.playError();
          retryAnim = RetryAnim(
            x: item.x,
            y: item.y - 60,
            opacity: 1.0,
            text: t('s4_retry', lang),
          );
          item.x = item.hx;
          item.y = item.hy;
        } else {
          AudioEngine.playClick();
          item.x = item.hx;
          item.y = item.hy;
        }
        activeDrag = null;
      });
    }
  }

  void _toolFitScreen() {
    if (_canvasKey.currentContext == null) return;
    final RenderBox box =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    double w = box.size.width;
    double h = box.size.height;
    if (w == 0) return;

    double ew = w - 20;
    double eh = h - 160;

    setState(() {
      if (scenario == 1) {
        if (step == 0 || step == 2) {
          zoom = max(0.6, min(2.0, min(ew / 800, eh / 700)));
          panX = 0;
          panY = 150 * zoom;
        } else if (step == 1 || step == 3) {
          zoom = max(0.6, min(2.0, min(ew / 800, eh / 600)));
          panX = 200 * zoom;
          panY = 100 * zoom;
        } else {
          zoom = max(0.6, min(2.0, min(ew / 600, eh / 800)));
          panX = -50 * zoom;
          panY = 100 * zoom;
        }
      } else if (scenario == 2) {
        if (step == 0) {
          zoom = max(0.6, min(2.0, min(ew / 800, eh / 700)));
          panX = 0;
          panY = 150 * zoom;
        } else if (step == 1) {
          zoom = max(0.6, min(2.0, min(ew / 800, eh / 600)));
          panX = -150 * zoom;
          panY = 100 * zoom;
        } else {
          zoom = max(0.6, min(2.0, min(ew / 600, eh / 800)));
          panX = -50 * zoom;
          panY = -150 * zoom;
        }
      } else if (scenario == 3) {
        zoom = max(0.4, min(1.2, min(ew / 800, eh / 900)));
        panX = 0;
        panY = 100 * zoom;
      } else if (scenario == 4) {
        zoom = max(0.4, min(1.2, min(ew / 800, eh / 900)));
        panX = 0;
        panY = -200 * zoom;
      } else if (scenario == 5) {
        zoom = max(0.4, min(1.2, min(ew / 800, eh / 600)));
        panX = 0;
        panY = -50 * zoom;
      } else {
        zoom = 1.0;
        panX = 0;
        panY = 0;
      }
    });
  }

  // --- UI Builders ---
  Widget _buildCurtain() {
    return Container(
      color: const Color(0xFF0F172A),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseCtrl.value * 0.1),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6366F1,
                            ).withOpacity(0.6 * _pulseCtrl.value),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.architecture,
                        size: 60,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                t('shutterTitle', 'en'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF8FAFC),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t('appSubtitle', 'en'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  AudioEngine.curtainScreen();
                  setState(() {
                    _showCurtain = false;
                  });
                },
                icon: const Icon(Icons.play_circle_fill, size: 28),
                label: Text(
                  t('enterLab', 'en'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                  shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimulation() {
    return Stack(
      children: [
        // Canvas Wrapper
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          left: sidebarOpen ? sidebarWidth : 0,
          top: 0,
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onScaleEnd: _handleScaleEnd,
            child: Container(
              key: _canvasKey,
              color: const Color(0xFF0F172A),
              child: CustomPaint(
                painter: LabPainter(
                  panX: panX,
                  panY: panY,
                  zoom: zoom,
                  scenario: scenario,
                  step: step,
                  liftVisualFloor: liftVisualFloor,
                  liftFloor: liftFloor,
                  characters: characters,
                  dragItems: dragItems,
                  dropZones: dropZones,
                  comparisonResult: comparisonResult,
                  confetti: confetti,
                  retryAnim: retryAnim,
                  activeDrag: activeDrag,
                  lang: lang,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),

        // Sidebar
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          left: sidebarOpen ? 0 : -sidebarWidth,
          top: 0,
          bottom: 0,
          width: sidebarWidth,
          child: Container(
            width: sidebarWidth,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              border: Border(
                right: BorderSide(color: Colors.white.withOpacity(0.15)),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 15,
                  offset: Offset(5, 0),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Block (Added left padding so it does not overlap the static top-left menu icon)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 64,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.architecture,
                          color: Color(0xFF6366F1),
                          size: 36,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t('appTitle', lang),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t('appSubtitle', lang),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _toggleLanguage,
                                    icon: const Icon(
                                      Icons.translate,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      lang.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white12,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      minimumSize: Size.zero,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      AudioEngine.playDropdown();
                                      _loadScenario(1);
                                    },
                                    icon: const Icon(
                                      Icons.refresh,
                                      size: 16,
                                      color: Colors.redAccent,
                                    ),
                                    label: const Text(
                                      'Reset',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white12,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      minimumSize: Size.zero,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(color: Colors.white.withOpacity(0.1), height: 1),

                  // Interactive Elements Block
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('selectScenario', lang).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white54,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: scenario,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1E293B),
                              icon: const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white70,
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              items: [1, 2, 3, 4, 5]
                                  .map(
                                    (id) => DropdownMenuItem(
                                      value: id,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(t('s${id}_title', lang)),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  AudioEngine.playDropdown();
                                  _loadScenario(val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.my_location,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    t('learnLbl', lang),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t(configs[scenario]!.objKey, lang),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(configs[scenario]!.numSteps, (i) {
                          bool isPast = i < step;
                          bool isCurrent =
                              i == step && step != configs[scenario]!.numSteps;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? const Color(0xFF6366F1).withOpacity(0.15)
                                  : (isPast
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.white.withOpacity(0.05)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrent
                                    ? const Color(0xFF6366F1)
                                    : (isPast
                                          ? Colors.green.withOpacity(0.3)
                                          : Colors.transparent),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                isPast
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : CircleAvatar(
                                        radius: 12,
                                        backgroundColor: isCurrent
                                            ? const Color(0xFF6366F1)
                                            : Colors.white24,
                                        child: Text(
                                          '${i + 1}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${t('stepLabel', lang)} ${i + 1}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white54,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isCurrent
                                                ? Colors.white
                                                : Colors.white70,
                                            height: 1.4,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: "Action: ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: t(
                                                's${scenario}_step${i + 1}_task',
                                                lang,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isPast) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.greenAccent,
                                                height: 1.4,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      "${t('learnLbl', lang)} ",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: t(
                                                    's${scenario}_step${i + 1}_out',
                                                    lang,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    color: const Color(0xFF020617),
                    child: const Text(
                      '© ZEROSCIENCELAB | Fall in Love with Math and Science',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Sidebar Resizer Handle
        if (sidebarOpen)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: sidebarWidth - 10,
            top: 0,
            bottom: 0,
            width: 20,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                setState(() {
                  sidebarWidth += details.delta.dx;
                  sidebarWidth = sidebarWidth.clamp(
                    300.0,
                    MediaQuery.of(context).size.width * 0.6,
                  );
                  _toolFitScreen();
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

        // Menu Toggle Button (Fixed Position to Top Left)
        Positioned(
          left: 16,
          top: 16,
          child: SafeArea(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 8),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  AudioEngine.playDropdown();
                  setState(() {
                    sidebarOpen = !sidebarOpen;
                  });
                },
              ),
            ),
          ),
        ),

        // Bottom HUD
        if (step < configs[scenario]!.numSteps &&
            t('s${scenario}_hud${step + 1}', lang).isNotEmpty)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: sidebarOpen ? sidebarWidth : 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info, color: Color(0xFF6366F1), size: 28),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        t('s${scenario}_hud${step + 1}', lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Next Scenario Button (Only for successful scenarios < 5)
        if (step == configs[scenario]!.numSteps &&
            scenario < 5 &&
            !successPopupVisible)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: sidebarOpen ? sidebarWidth : 0,
            right: 24,
            bottom: 24,
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  AudioEngine.playPageOpen();
                  _loadScenario(scenario + 1);
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(t('nextScenario', lang)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),

        // Success Popup (Scenario 5 End)
        if (successPopupVisible)
          Positioned.fill(
            child: Container(
              color: Colors.black87,
              child: Center(
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        t('summaryTitle', lang),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t('finalDesc', lang),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          AudioEngine.playDropdown();
                          setState(() {
                            successPopupVisible = false;
                          });
                          _loadScenario(1);
                        },
                        icon: const Icon(Icons.flag),
                        label: Text(t('finishLab', lang)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        body: _showCurtain ? _buildCurtain() : _buildSimulation(),
      ),
    );
  }
}

// ============================================================================
// CUSTOM PAINTER
// ============================================================================
class LabPainter extends CustomPainter {
  final double panX, panY, zoom;
  final int scenario, step;
  final double liftVisualFloor;
  final double liftFloor;
  final List<SimChar> characters;
  final List<DragItem> dragItems;
  final List<DropZone> dropZones;
  final String? comparisonResult;
  final List<Confetti> confetti;
  final RetryAnim? retryAnim;
  final String? activeDrag;
  final String lang;

  LabPainter({
    required this.panX,
    required this.panY,
    required this.zoom,
    required this.scenario,
    required this.step,
    required this.liftVisualFloor,
    required this.liftFloor,
    required this.characters,
    required this.dragItems,
    required this.dropZones,
    this.comparisonResult,
    required this.confetti,
    this.retryAnim,
    this.activeDrag,
    required this.lang,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario == 1) {
      if (step == 0 || step == 2)
        _drawS1Facade(canvas);
      else if (step == 1 || step == 3)
        _drawS1Interior(canvas);
      else
        _drawS1FullTower(canvas);
    } else if (scenario == 2) {
      if (step == 0)
        _drawS2Facade(canvas);
      else if (step == 1)
        _drawS2Interior(canvas);
      else
        _drawS2FullTower(canvas);
    } else if (scenario == 3) {
      _drawS3View(canvas);
    } else if (scenario == 4) {
      _drawS4View(canvas);
    } else if (scenario == 5) {
      _drawS5View(canvas);
    } else {
      _drawBuilding3D(canvas, -5, 5);
    }

    _drawDraggables(canvas);

    canvas.restore();
  }

  // --- DRAWING HELPERS ---
  void _drawRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    Color fill, [
    Color? stroke,
    double strokeW = 2,
  ]) {
    if (fill != Colors.transparent) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w, h),
          const Radius.circular(4),
        ),
        Paint()..color = fill,
      );
    }
    if (stroke != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w, h),
          const Radius.circular(4),
        ),
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
    }
  }

  void _drawCircle(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    Color fill, [
    Color? stroke,
    double strokeW = 2,
  ]) {
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = fill);
    if (stroke != null)
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
  }

  void _drawLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double width, {
    bool dashed = false,
  }) {
    Paint p = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    if (dashed) {
      double dashWidth = 10, dashSpace = 10;
      double dx = x2 - x1, dy = y2 - y1;
      double dist = sqrt(dx * dx + dy * dy);
      double dashes = dist / (dashWidth + dashSpace);
      for (int i = 0; i < dashes; i++) {
        double startX = x1 + (dx / dashes) * i;
        double startY = y1 + (dy / dashes) * i;
        double endX = startX + (dx / dist) * dashWidth;
        double endY = startY + (dy / dist) * dashWidth;
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), p);
      }
    } else {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), p);
    }
  }

  void _drawPoly(
    Canvas canvas,
    List<Offset> pts,
    Color fill,
    Color stroke, [
    double strokeW = 2,
  ]) {
    Path p = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) p.lineTo(pts[i].dx, pts[i].dy);
    p.close();
    canvas.drawPath(p, Paint()..color = fill);
    canvas.drawPath(
      p,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeJoin = StrokeJoin.round,
    );
  }

  // UPDATED: Added maxWidth argument to correctly wrap overflowing text
  void _drawTextWithOutline(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color fill,
    Color stroke, {
    double strokeW = 3,
    TextAlign align = TextAlign.center,
    FontWeight weight = FontWeight.bold,
    double? maxWidth,
  }) {
    TextPainter tpStroke = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          fontFamily: 'Plus Jakarta Sans',
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeW
            ..color = stroke,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: maxWidth ?? double.infinity);
    TextPainter tpFill = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          fontFamily: 'Plus Jakarta Sans',
          color: fill,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: maxWidth ?? double.infinity);

    double dx = align == TextAlign.center
        ? x - tpFill.width / 2
        : (align == TextAlign.right ? x - tpFill.width : x);
    double dy = y - tpFill.height / 2;

    if (strokeW > 0) tpStroke.paint(canvas, Offset(dx, dy));
    tpFill.paint(canvas, Offset(dx, dy));
  }

  Color _shade(Color c, int p) {
    int r = (c.red * (100 + p) ~/ 100).clamp(0, 255);
    int g = (c.green * (100 + p) ~/ 100).clamp(0, 255);
    int b = (c.blue * (100 + p) ~/ 100).clamp(0, 255);
    return Color.fromARGB(c.alpha, r, g, b);
  }

  String _fmt(double n) => n > 0 ? '+${n.toInt()}' : '${n.toInt()}';

  // --- CHARACTERS ---
  void _drawJay(Canvas canvas, double x, double y, double scale) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    canvas.translate(0, -60);
    _drawRect(
      canvas,
      -12,
      10,
      24,
      30,
      const Color(0xFF22C55E),
      const Color(0xFF166534),
      2,
    );
    _drawRect(
      canvas,
      -12,
      40,
      10,
      20,
      const Color(0xFF3B82F6),
      const Color(0xFF1D4ED8),
      2,
    );
    _drawRect(
      canvas,
      2,
      40,
      10,
      20,
      const Color(0xFF3B82F6),
      const Color(0xFF1D4ED8),
      2,
    );
    _drawLine(canvas, -12, 15, -20, 30, const Color(0xFF22C55E), 6);
    _drawLine(canvas, 12, 15, 20, 30, const Color(0xFF22C55E), 6);
    _drawCircle(canvas, -20, 30, 4, const Color(0xFFFCA5A5));
    _drawCircle(canvas, 20, 30, 4, const Color(0xFFFCA5A5));
    _drawCircle(canvas, 0, -5, 12, const Color(0xFFFCA5A5), Colors.black, 1);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, -8), radius: 13),
      pi,
      pi,
      true,
      Paint()..color = const Color(0xFF451A03),
    );
    _drawCircle(canvas, -4, -5, 1.5, const Color(0xFF0F172A));
    _drawCircle(canvas, 4, -5, 1.5, const Color(0xFF0F172A));
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 2), radius: 4),
      0,
      pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.restore();
  }

  void _drawAman(Canvas canvas, double x, double y, double scale) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    canvas.translate(0, -60);
    _drawRect(
      canvas,
      -12,
      10,
      24,
      30,
      const Color(0xFFF97316),
      const Color(0xFFC2410C),
      2,
    );
    _drawRect(
      canvas,
      -12,
      40,
      10,
      20,
      const Color(0xFF475569),
      const Color(0xFF1E293B),
      2,
    );
    _drawRect(
      canvas,
      2,
      40,
      10,
      20,
      const Color(0xFF475569),
      const Color(0xFF1E293B),
      2,
    );
    _drawLine(canvas, -12, 15, -20, 30, const Color(0xFFF97316), 6);
    _drawLine(canvas, 12, 15, 20, 30, const Color(0xFFF97316), 6);
    _drawCircle(canvas, -20, 30, 4, const Color(0xFFB45309));
    _drawCircle(canvas, 20, 30, 4, const Color(0xFFB45309));
    _drawCircle(canvas, 0, -5, 12, const Color(0xFFFCA5A5), Colors.black, 1);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, -10), radius: 12),
      pi,
      pi,
      true,
      Paint()..color = const Color(0xFF78350F),
    );
    _drawRect(
      canvas,
      -13,
      -10,
      26,
      6,
      const Color(0xFF78350F),
      const Color(0xFF451A03),
      1,
    );
    _drawCircle(canvas, -4, -3, 1.5, const Color(0xFF0F172A));
    _drawCircle(canvas, 4, -3, 1.5, const Color(0xFF0F172A));
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 3), radius: 4),
      0,
      pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.restore();
  }

  void _drawAvatar(
    Canvas canvas,
    double x,
    double y,
    double scale,
    Color color,
    String name,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    canvas.translate(0, -60);
    Color shadow = _shade(color, -20);
    _drawRect(canvas, -12, 10, 24, 30, color, shadow, 2);
    _drawRect(
      canvas,
      -10,
      40,
      8,
      20,
      const Color(0xFF475569),
      const Color(0xFF1E293B),
      2,
    );
    _drawRect(
      canvas,
      2,
      40,
      8,
      20,
      const Color(0xFF475569),
      const Color(0xFF1E293B),
      2,
    );
    _drawLine(canvas, -12, 15, -20, 30, color, 6);
    _drawLine(canvas, 12, 15, 20, 30, color, 6);
    _drawCircle(canvas, -20, 30, 4, const Color(0xFFFCA5A5));
    _drawCircle(canvas, 20, 30, 4, const Color(0xFFFCA5A5));
    _drawCircle(canvas, 0, -5, 12, const Color(0xFFFCA5A5), Colors.black, 1);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, -8), radius: 14),
      pi,
      pi,
      true,
      Paint()..color = const Color(0xFF0F172A),
    );
    _drawCircle(canvas, -4, -3, 1.5, const Color(0xFF0F172A));
    _drawCircle(canvas, 4, -3, 1.5, const Color(0xFF0F172A));
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 2), radius: 4),
      0,
      pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    if (name.isNotEmpty)
      _drawTextWithOutline(
        canvas,
        name,
        0,
        -35,
        12,
        Colors.white,
        const Color(0xFF0F172A),
      );
    canvas.restore();
  }

  void _drawCharWithSign(
    Canvas canvas,
    double x,
    double y,
    double scale,
    Color color,
    String signText,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    canvas.translate(0, -60);
    Color shadow = _shade(color, -20);
    _drawRect(canvas, -12, 10, 24, 30, color, shadow, 2);
    _drawRect(
      canvas,
      -10,
      40,
      8,
      20,
      const Color(0xFF475569),
      const Color(0xFF1E293B),
      2,
    );
    _drawRect(
      canvas,
      2,
      40,
      8,
      20,
      const Color(0xFF475569),
      const Color(0xFF1E293B),
      2,
    );
    _drawCircle(canvas, 0, -5, 12, const Color(0xFFFCA5A5), Colors.black, 1);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, -8), radius: 14),
      pi,
      pi,
      true,
      Paint()..color = const Color(0xFF0F172A),
    );
    _drawCircle(canvas, -4, -3, 1.5, const Color(0xFF0F172A));
    _drawCircle(canvas, 4, -3, 1.5, const Color(0xFF0F172A));
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 2), radius: 4),
      0,
      pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _drawRect(
      canvas,
      -20,
      15,
      40,
      25,
      Colors.white,
      const Color(0xFF0F172A),
      2,
    );
    _drawTextWithOutline(
      canvas,
      signText,
      0,
      27.5,
      16,
      const Color(0xFF0F172A),
      Colors.transparent,
      strokeW: 0,
    );
    _drawLine(canvas, -12, 15, -20, 25, color, 6);
    _drawLine(canvas, 12, 15, 20, 25, color, 6);
    canvas.restore();
  }

  void _drawSign(Canvas canvas, double x, double y, String text) {
    canvas.save();
    canvas.translate(x, y);
    _drawLine(canvas, -10, 20, -10, 50, const Color(0xFFD97706), 4);
    _drawRect(
      canvas,
      -30,
      -10,
      60,
      30,
      Colors.white,
      const Color(0xFF94A3B8),
      2,
    );
    _drawTextWithOutline(
      canvas,
      text,
      0,
      5,
      12,
      const Color(0xFF0F172A),
      Colors.transparent,
      strokeW: 0,
    );
    canvas.restore();
  }

  void _drawFaceIcon(Canvas canvas, double x, double y, double r, Color color) {
    canvas.save();
    canvas.translate(x, y);
    _drawCircle(canvas, 0, 0, r, color, const Color(0xFF0F172A), 3);
    double fScale = r / 18;
    canvas.scale(fScale, fScale);
    canvas.translate(0, 3);
    _drawCircle(canvas, 0, 0, 12, const Color(0xFFFCA5A5), Colors.black, 1);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, -3), radius: 14),
      pi,
      pi,
      true,
      Paint()..color = const Color(0xFF0F172A),
    );
    _drawCircle(canvas, -4, 2, 1.5, const Color(0xFF0F172A));
    _drawCircle(canvas, 4, 2, 1.5, const Color(0xFF0F172A));
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 7), radius: 4),
      0,
      pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.restore();
  }

  void _drawSpeechBubble(
    Canvas canvas,
    String text,
    double x,
    double y,
    double w,
    double h,
  ) {
    _drawRect(canvas, x, y, w, h, Colors.white, const Color(0xFF0F172A), 3);
    Path p = Path()
      ..moveTo(x + w / 2 - 10, y + h)
      ..lineTo(x + w / 2, y + h + 15)
      ..lineTo(x + w / 2 + 10, y + h);
    canvas.drawPath(p, Paint()..color = Colors.white);
    canvas.drawLine(
      Offset(x + w / 2 - 10, y + h),
      Offset(x + w / 2, y + h + 15),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(x + w / 2 + 10, y + h),
      Offset(x + w / 2, y + h + 15),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 3,
    );
    _drawTextWithOutline(
      canvas,
      text,
      x + w / 2,
      y + h / 2,
      14,
      const Color(0xFF0F172A),
      Colors.transparent,
      strokeW: 0,
      maxWidth: w - 20,
    ); // UPDATED maxWidth
  }

  // --- CORE TOWER LOGIC ---
  void _drawBuilding3D(Canvas canvas, int minF, int maxF) {
    double dx = 25, dy = -15;
    double rx = -150;
    double rw = 160;
    double bx = rx + rw;
    double sw = 90;
    double fh = 80;
    double zeroY = 0;

    List<Color> fColors = [
      const Color(0xFFE5E7EB),
      const Color(0xFFBFDBFE),
      const Color(0xFFFECACA),
      const Color(0xFFCBD5E1),
      const Color(0xFFFED7AA),
      const Color(0xFFF1F5F9),
      const Color(0xFFD9F99D),
      const Color(0xFFFBCFE8),
      const Color(0xFFBAE6FD),
      const Color(0xFFE9D5FF),
      const Color(0xFFFEF08A),
    ];

    for (int l = maxF; l >= minF; l--) {
      double y = zeroY - l * fh;
      Color backCol = fColors[l + 5];
      Color leftCol = _shade(backCol, -10);
      Color floorCol = _shade(backCol, -20);
      Color strokeCol = const Color(0xFF475569);

      _drawPoly(
        canvas,
        [
          Offset(rx + dx, y + dy),
          Offset(bx + dx, y + dy),
          Offset(bx + dx, y - fh + dy),
          Offset(rx + dx, y - fh + dy),
        ],
        backCol,
        strokeCol,
      );
      _drawPoly(
        canvas,
        [
          Offset(rx, y),
          Offset(rx + dx, y + dy),
          Offset(rx + dx, y - fh + dy),
          Offset(rx, y - fh),
        ],
        leftCol,
        strokeCol,
      );
      _drawPoly(
        canvas,
        [
          Offset(rx, y),
          Offset(bx, y),
          Offset(bx + dx, y + dy),
          Offset(rx + dx, y + dy),
        ],
        floorCol,
        strokeCol,
      );
      _drawTextWithOutline(
        canvas,
        _fmt(l.toDouble()),
        rx - 20,
        y - fh / 2,
        18,
        Colors.white,
        Colors.transparent,
        strokeW: 0,
        align: TextAlign.right,
      );
    }

    double shaftBot = zeroY - minF * fh + fh;
    double shaftTop = zeroY - maxF * fh - fh;
    _drawPoly(
      canvas,
      [
        Offset(bx + dx, shaftBot + dy),
        Offset(bx + sw + dx, shaftBot + dy),
        Offset(bx + sw + dx, shaftTop + dy),
        Offset(bx + dx, shaftTop + dy),
      ],
      const Color(0xFFF1F5F9),
      const Color(0xFF475569),
      2,
    );

    double liftY = zeroY - liftVisualFloor * fh;
    double lw = sw - 16;
    double lh = fh - 10;
    double lx = bx + 8;

    _drawPoly(
      canvas,
      [
        Offset(lx + dx, liftY + dy),
        Offset(lx + lw + dx, liftY + dy),
        Offset(lx + lw + dx, liftY - lh + dy),
        Offset(lx + dx, liftY - lh + dy),
      ],
      Colors.white.withOpacity(0.4),
      const Color(0xFF0EA5E9),
    );
    _drawPoly(
      canvas,
      [
        Offset(lx, liftY),
        Offset(lx + lw, liftY),
        Offset(lx + lw + dx, liftY + dy),
        Offset(lx + dx, liftY + dy),
      ],
      const Color(0xFFCBD5E1),
      const Color(0xFF0EA5E9),
    );

    for (var char in characters) {
      if (char.state == 'in_lift') {
        double charY = liftY + dy / 2;
        if (char.id == 'jay')
          _drawJay(canvas, lx + lw / 2 + dx / 2, charY, 0.7);
        else if (char.id == 'aman')
          _drawAman(canvas, lx + lw / 2 + dx / 2, charY, 0.7);
        else
          _drawAvatar(
            canvas,
            lx + lw / 2 + dx / 2,
            charY,
            0.7,
            char.color,
            char.name,
          );
      }
    }

    _drawPoly(
      canvas,
      [
        Offset(lx, liftY),
        Offset(lx + lw, liftY),
        Offset(lx + lw, liftY - lh),
        Offset(lx, liftY - lh),
      ],
      Colors.white.withOpacity(0.4),
      const Color(0xFF0EA5E9),
    );
    _drawPoly(
      canvas,
      [
        Offset(lx + lw, liftY),
        Offset(lx + lw + dx, liftY + dy),
        Offset(lx + lw + dx, liftY - lh + dy),
        Offset(lx + lw, liftY - lh),
      ],
      Colors.white.withOpacity(0.5),
      const Color(0xFF0EA5E9),
    );

    _drawPoly(
      canvas,
      [
        Offset(bx, shaftBot),
        Offset(bx + sw, shaftBot),
        Offset(bx + sw, shaftTop),
        Offset(bx, shaftTop),
      ],
      const Color(0xFFBAE6FD).withOpacity(0.1),
      const Color(0xFF0369A1),
      3,
    );
    _drawPoly(
      canvas,
      [
        Offset(bx + sw, shaftBot),
        Offset(bx + sw + dx, shaftBot + dy),
        Offset(bx + sw + dx, shaftTop + dy),
        Offset(bx + sw, shaftTop),
      ],
      const Color(0xFFBAE6FD).withOpacity(0.15),
      const Color(0xFF0369A1),
      3,
    );

    for (int l = maxF; l >= minF; l--) {
      double y = zeroY - l * fh;
      _drawLine(canvas, bx, y, bx + sw, y, const Color(0xFF0369A1), 3);
      _drawLine(
        canvas,
        bx + sw,
        y,
        bx + sw + dx,
        y + dy,
        const Color(0xFF0369A1),
        3,
      );
    }

    for (var char in characters) {
      if (char.state == 'waiting' || char.state == 'dropped') {
        double cy = zeroY - char.floor * fh;
        double drawY = cy + dy / 2;
        if (char.sign.isNotEmpty)
          _drawCharWithSign(
            canvas,
            rx + rw / 2 + dx / 2,
            drawY,
            0.75,
            char.color,
            char.sign,
          );
        else if (char.id == 'jay')
          _drawJay(canvas, rx + rw / 2 + dx / 2, drawY, 0.7);
        else if (char.id == 'aman')
          _drawAman(canvas, rx + rw / 2 + dx / 2, drawY, 0.7);
        else
          _drawAvatar(
            canvas,
            rx + rw / 2 + dx / 2,
            drawY,
            0.7,
            char.color,
            char.name,
          );
      }
    }
  }

  // --- SCENARIO RENDERERS ---
  void _drawS1Facade(Canvas canvas) {
    _drawRect(canvas, -800, 150, 1600, 400, const Color(0xFF1E293B));
    _drawLine(canvas, -800, 150, 800, 150, const Color(0xFF0F172A), 4);
    double ew = 200, eh = 300, ex = 50, ey = 150;
    _drawRect(
      canvas,
      ex - ew / 2 - 10,
      ey - eh - 10,
      ew + 20,
      eh + 10,
      const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      4,
    );
    _drawRect(canvas, ex - ew / 2, ey - eh, ew, eh, const Color(0xFF64748B));
    _drawRect(
      canvas,
      ex - ew / 2 - 40,
      ey - eh,
      40,
      eh,
      const Color(0xFFBAE6FD).withOpacity(0.4),
      const Color(0xFF0284C7),
      2,
    );
    _drawRect(
      canvas,
      ex + ew / 2,
      ey - eh,
      40,
      eh,
      const Color(0xFFBAE6FD).withOpacity(0.4),
      const Color(0xFF0284C7),
      2,
    );
    _drawRect(
      canvas,
      ex + ew / 2 + 30,
      ey - eh / 2 - 20,
      30,
      60,
      const Color(0xFFCBD5E1),
      const Color(0xFF475569),
      2,
    );
    _drawCircle(
      canvas,
      ex + ew / 2 + 45,
      ey - eh / 2 - 5,
      8,
      const Color(0xFF22C55E),
    );
    _drawCircle(
      canvas,
      ex + ew / 2 + 45,
      ey - eh / 2 + 15,
      8,
      const Color(0xFFEF4444),
    );
    _drawRect(
      canvas,
      ex - 40,
      ey - eh - 50,
      80,
      30,
      const Color(0xFF0F172A),
      Colors.white,
      2,
    );
    _drawTextWithOutline(
      canvas,
      "0",
      ex,
      ey - eh - 35,
      18,
      const Color(0xFF22C55E),
      Colors.transparent,
      strokeW: 0,
    );

    if (dropZones.isNotEmpty) {
      _drawRect(
        canvas,
        dropZones[0].x,
        dropZones[0].y,
        dropZones[0].w,
        dropZones[0].h,
        const Color(0xFFFACC15).withOpacity(0.3),
        const Color(0xFFFACC15),
        3,
      );
    }
  }

  void _drawS1Interior(Canvas canvas) {
    _drawLine(canvas, -200, -800, -200, 800, const Color(0xFF94A3B8), 4);
    _drawLine(canvas, 200, -800, 200, 800, const Color(0xFF94A3B8), 4);
    _drawRect(canvas, -800, 200, 1600, 400, const Color(0xFF94A3B8));
    _drawLine(canvas, -800, 200, 800, 200, const Color(0xFF0F172A), 4);

    if (step == 1)
      _drawJay(canvas, 0, 200, 2.5);
    else
      _drawAman(canvas, 0, 200, 2.5);

    double cx = -350, cy = -50, cw = 160, ch = 240;
    _drawRect(
      canvas,
      cx - cw / 2,
      cy - ch / 2,
      cw,
      ch,
      const Color(0xFFF8FAFC),
      const Color(0xFF475569),
      4,
    );

    double btnR = 30;
    Color plusColor = step == 1
        ? const Color(0xFF22C55E)
        : const Color(0xFF94A3B8);
    _drawCircle(
      canvas,
      cx,
      cy - 60,
      btnR,
      plusColor,
      const Color(0xFF0F172A),
      4,
    );
    _drawLine(canvas, cx - 15, cy - 60, cx + 15, cy - 60, Colors.white, 6);
    _drawLine(canvas, cx, cy - 60 - 15, cx, cy - 60 + 15, Colors.white, 6);

    Color minColor = step == 3
        ? const Color(0xFFEF4444)
        : const Color(0xFF94A3B8);
    _drawCircle(
      canvas,
      cx,
      cy + 40,
      btnR,
      minColor,
      const Color(0xFF0F172A),
      4,
    );
    _drawLine(canvas, cx - 15, cy + 40, cx + 15, cy + 40, Colors.white, 6);

    _drawRect(
      canvas,
      -60,
      -250,
      120,
      50,
      const Color(0xFF0F172A),
      const Color(0xFF334155),
      4,
    );
    _drawTextWithOutline(
      canvas,
      _fmt(liftFloor),
      0,
      -225,
      36,
      const Color(0xFF22C55E),
      Colors.transparent,
      strokeW: 0,
    );
  }

  void _drawS1FullTower(Canvas canvas) {
    _drawBuilding3D(canvas, -2, 3);
    double y2 = -160, ym1 = 80;
    double cx = 150, cy = 0, w = 300, h = 100;
    _drawLine(
      canvas,
      -50,
      y2,
      cx - w / 2,
      y2,
      const Color(0xFF0F172A),
      2,
      dashed: true,
    );
    _drawLine(
      canvas,
      -50,
      ym1,
      cx - w / 2,
      ym1,
      const Color(0xFF0F172A),
      2,
      dashed: true,
    );

    _drawRect(
      canvas,
      cx - w / 2,
      cy - h / 2,
      w,
      h,
      Colors.white,
      const Color(0xFF94A3B8),
      3,
    );
    _drawRect(
      canvas,
      cx - 100,
      cy - 25,
      60,
      50,
      const Color(0xFF0F172A),
      const Color(0xFF334155),
      2,
    );
    _drawTextWithOutline(
      canvas,
      "+2",
      cx - 70,
      cy,
      24,
      Colors.white,
      Colors.transparent,
      strokeW: 0,
    );
    _drawRect(
      canvas,
      cx + 40,
      cy - 25,
      60,
      50,
      const Color(0xFF0F172A),
      const Color(0xFF334155),
      2,
    );
    _drawTextWithOutline(
      canvas,
      "-1",
      cx + 70,
      cy,
      24,
      Colors.white,
      Colors.transparent,
      strokeW: 0,
    );

    if (comparisonResult != null) {
      _drawTextWithOutline(
        canvas,
        comparisonResult!,
        cx,
        cy,
        36,
        const Color(0xFF6366F1),
        Colors.transparent,
        strokeW: 0,
      );
      if (step >= 5) {
        _drawRect(
          canvas,
          cx - 220,
          cy + 100,
          440,
          120,
          const Color(0xFF22C55E),
          const Color(0xFF14532D),
          4,
        );
        // UPDATED: Added maxWidth argument to fit text completely
        _drawTextWithOutline(
          canvas,
          t('s1_step5_out', lang),
          cx,
          cy + 160,
          16,
          Colors.white,
          Colors.transparent,
          strokeW: 0,
          maxWidth: 400,
        );
        _drawRect(
          canvas,
          cx - 80,
          cy + 260,
          160,
          40,
          const Color(0xFFFDE047),
          const Color(0xFFCA8A04),
          3,
        );
        _drawTextWithOutline(
          canvas,
          "CONTINUE",
          cx,
          cy + 280,
          18,
          const Color(0xFFCA8A04),
          Colors.transparent,
          strokeW: 0,
        );
      }
    } else if (dropZones.isNotEmpty) {
      _drawRect(
        canvas,
        dropZones[0].x,
        dropZones[0].y,
        dropZones[0].w,
        dropZones[0].h,
        const Color(0xFFF1F5F9),
        const Color(0xFFFACC15),
        3,
      );
    }
  }

  void _drawS2Facade(Canvas canvas) {
    _drawRect(canvas, -800, 150, 1600, 400, const Color(0xFF1E293B));
    _drawLine(canvas, -800, 150, 800, 150, const Color(0xFF0F172A), 4);
    double ew = 200, eh = 300, ex = 50, ey = 150;
    _drawRect(
      canvas,
      ex - ew / 2 - 250,
      ey - eh - 100,
      240,
      eh + 100,
      const Color(0xFFDEAA88),
      const Color(0xFF78350F),
      4,
    );
    _drawRect(
      canvas,
      ex - ew / 2 - 10,
      ey - eh - 10,
      ew + 20,
      eh + 10,
      const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      4,
    );
    _drawRect(canvas, ex - ew / 2, ey - eh, ew, eh, const Color(0xFF64748B));
    _drawRect(
      canvas,
      ex - ew / 2 - 40,
      ey - eh,
      40,
      eh,
      const Color(0xFFBAE6FD).withOpacity(0.4),
      const Color(0xFF0284C7),
      2,
    );
    _drawRect(
      canvas,
      ex + ew / 2,
      ey - eh,
      40,
      eh,
      const Color(0xFFBAE6FD).withOpacity(0.4),
      const Color(0xFF0284C7),
      2,
    );
    _drawAman(canvas, ex, ey, 2.5);
    if (dropZones.isNotEmpty)
      _drawRect(
        canvas,
        dropZones[0].x,
        dropZones[0].y,
        dropZones[0].w,
        dropZones[0].h,
        const Color(0xFFFACC15).withOpacity(0.3),
        const Color(0xFFFACC15),
        3,
      );
  }

  void _drawS2Interior(Canvas canvas) {
    _drawLine(canvas, -200, -800, -200, 800, const Color(0xFF94A3B8), 4);
    _drawLine(canvas, 200, -800, 200, 800, const Color(0xFF94A3B8), 4);
    _drawRect(canvas, -800, 200, 1600, 400, const Color(0xFF94A3B8));
    _drawLine(canvas, -800, 200, 800, 200, const Color(0xFF0F172A), 4);
    _drawAvatar(canvas, 0, 200, 2.5, const Color(0xFFEC4899), 'Binnu');
    double cx = 350, cy = -50, cw = 160, ch = 240, btnR = 30;
    _drawRect(
      canvas,
      cx - cw / 2,
      cy - ch / 2,
      cw,
      ch,
      const Color(0xFFF8FAFC),
      const Color(0xFF475569),
      4,
    );
    _drawCircle(
      canvas,
      cx,
      cy - 60,
      btnR,
      const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      4,
    );
    _drawLine(canvas, cx - 15, cy - 60, cx + 15, cy - 60, Colors.white, 6);
    _drawLine(canvas, cx, cy - 60 - 15, cx, cy - 60 + 15, Colors.white, 6);
    Color minColor = step == 1
        ? const Color(0xFFEF4444)
        : const Color(0xFF94A3B8);
    _drawCircle(
      canvas,
      cx,
      cy + 40,
      btnR,
      minColor,
      const Color(0xFF0F172A),
      4,
    );
    _drawLine(canvas, cx - 15, cy + 40, cx + 15, cy + 40, Colors.white, 6);
    _drawRect(
      canvas,
      -60,
      -250,
      120,
      50,
      const Color(0xFF0F172A),
      const Color(0xFF334155),
      4,
    );
    _drawTextWithOutline(
      canvas,
      _fmt(liftFloor),
      0,
      -225,
      36,
      const Color(0xFFEF4444),
      Colors.transparent,
      strokeW: 0,
    );
  }

  void _drawS2FullTower(Canvas canvas) {
    _drawBuilding3D(canvas, -4, 1);
    double ym1 = 80, ym3 = 240, cx = 150, cy = 160, w = 300, h = 100;
    _drawLine(
      canvas,
      -50,
      ym1,
      cx - w / 2,
      ym1,
      const Color(0xFF0F172A),
      2,
      dashed: true,
    );
    _drawLine(
      canvas,
      -50,
      ym3,
      cx - w / 2,
      ym3,
      const Color(0xFF0F172A),
      2,
      dashed: true,
    );
    _drawRect(
      canvas,
      cx - w / 2,
      cy - h / 2,
      w,
      h,
      Colors.white,
      const Color(0xFF94A3B8),
      3,
    );
    _drawRect(
      canvas,
      cx - 100,
      cy - 25,
      60,
      50,
      const Color(0xFF0F172A),
      const Color(0xFF334155),
      2,
    );
    _drawTextWithOutline(
      canvas,
      "-3",
      cx - 70,
      cy,
      24,
      Colors.white,
      Colors.transparent,
      strokeW: 0,
    );
    _drawRect(
      canvas,
      cx + 40,
      cy - 25,
      60,
      50,
      const Color(0xFF0F172A),
      const Color(0xFF334155),
      2,
    );
    _drawTextWithOutline(
      canvas,
      "-1",
      cx + 70,
      cy,
      24,
      Colors.white,
      Colors.transparent,
      strokeW: 0,
    );

    if (comparisonResult != null) {
      _drawTextWithOutline(
        canvas,
        comparisonResult!,
        cx,
        cy,
        36,
        const Color(0xFF6366F1),
        Colors.transparent,
        strokeW: 0,
      );
      if (step >= 3) {
        _drawRect(
          canvas,
          cx - 220,
          cy + 100,
          440,
          120,
          const Color(0xFF22C55E),
          const Color(0xFF14532D),
          4,
        );
        // UPDATED: Added maxWidth argument to fit text completely
        _drawTextWithOutline(
          canvas,
          t('s2_step3_out', lang),
          cx,
          cy + 160,
          16,
          Colors.white,
          Colors.transparent,
          strokeW: 0,
          maxWidth: 400,
        );
        _drawRect(
          canvas,
          cx - 80,
          cy + 260,
          160,
          40,
          const Color(0xFFFDE047),
          const Color(0xFFCA8A04),
          3,
        );
        _drawTextWithOutline(
          canvas,
          "CONTINUE",
          cx,
          cy + 280,
          18,
          const Color(0xFFCA8A04),
          Colors.transparent,
          strokeW: 0,
        );
      }
    } else if (dropZones.isNotEmpty) {
      _drawRect(
        canvas,
        dropZones[0].x,
        dropZones[0].y,
        dropZones[0].w,
        dropZones[0].h,
        const Color(0xFFF1F5F9),
        const Color(0xFFFACC15),
        3,
      );
    }
  }

  void _drawS3View(Canvas canvas) {
    _drawBuilding3D(canvas, -3, 5);
    if (step == 0) {
      for (var dz in dropZones)
        if (dz.filledWith == null)
          _drawRect(
            canvas,
            dz.x,
            dz.y,
            dz.w,
            dz.h,
            const Color(0xFF22C55E).withOpacity(0.2),
            const Color(0xFF22C55E),
            2,
          );
    } else if (step >= 1) {
      double pY = 180;
      _drawRect(
        canvas,
        -260,
        pY,
        520,
        160,
        const Color(0xFF1E293B).withOpacity(0.9),
        const Color(0xFF94A3B8),
        4,
      );
      List<String> labels = [
        t('lbl_lowest', lang),
        t('lbl_2nd', lang),
        t('lbl_3rd', lang),
        t('lbl_highest', lang),
      ];
      for (int i = 0; i < 4; i++) {
        double sx = -220 + i * 110.0;
        _drawRect(
          canvas,
          sx,
          pY + 20,
          100,
          120,
          const Color(0xFF0F172A),
          const Color(0xFFCBD5E1),
          2,
        );
        _drawTextWithOutline(
          canvas,
          labels[i].replaceAll('\n', ' '),
          sx + 50,
          pY + 50,
          12,
          const Color(0xFF94A3B8),
          Colors.transparent,
          strokeW: 0,
        );

        var dz = dropZones.length > i ? dropZones[i] : null;
        if ((dz != null && dz.filledWith != null) || step >= 2) {
          String? cid = dz?.filledWith ?? ['binnu', 'aman', 'bela', 'asin'][i];
          var char = characters.firstWhere((c) => c.id == cid);
          _drawFaceIcon(canvas, sx + 50, pY + 100, 25, char.color);
        }
      }
      if (step >= 2) {
        double boxY = 80;
        _drawRect(
          canvas,
          -250,
          boxY,
          500,
          200,
          Colors.white,
          const Color(0xFFEAB308),
          6,
        );
        _drawTextWithOutline(
          canvas,
          "-3 < -1 < 0 < +5",
          0,
          boxY + 50,
          42,
          const Color(0xFF0F172A),
          Colors.transparent,
          strokeW: 0,
        );
        _drawTextWithOutline(
          canvas,
          t('s3_summary_msg', lang),
          0,
          boxY + 110,
          16,
          const Color(0xFF334155),
          Colors.transparent,
          strokeW: 0,
          maxWidth: 460,
        ); // UPDATED maxWidth
        _drawRect(
          canvas,
          -80,
          boxY + 140,
          160,
          50,
          const Color(0xFF22C55E),
          const Color(0xFF166534),
          3,
        );
        _drawTextWithOutline(
          canvas,
          t('lbl_finish', lang),
          0,
          boxY + 165,
          22,
          Colors.white,
          Colors.transparent,
          strokeW: 0,
        );
      }
    }
  }

  void _drawS4View(Canvas canvas) {
    _drawRect(canvas, -2000, 130, 4000, 50, const Color(0xFF4ADE80));
    _drawRect(canvas, -2000, 150, 4000, 500, const Color(0xFF94A3B8));
    _drawBuilding3D(canvas, -5, 2);
    double cY = 400, cX = 30;
    if (step == 0) {
      _drawRect(
        canvas,
        cX - 40,
        cY - 30,
        80,
        30,
        const Color(0xFFB45309),
        const Color(0xFF78350F),
        3,
      );
      _drawTextWithOutline(
        canvas,
        t('s4_find_me', lang),
        cX,
        cY - 60,
        16,
        const Color(0xFF0F172A),
        Colors.white,
        strokeW: 3,
      );
      _drawSpeechBubble(
        canvas,
        "-2   -5\n+1   -4\n?",
        cX + 60,
        cY - 120,
        100,
        80,
      );
      if (dropZones.isNotEmpty && dropZones[0].filledWith == null)
        _drawRect(
          canvas,
          dropZones[0].x,
          dropZones[0].y,
          dropZones[0].w,
          dropZones[0].h,
          const Color(0xFFFACC15).withOpacity(0.3),
          const Color(0xFFFACC15),
          3,
        );
    } else {
      _drawRect(
        canvas,
        cX - 40,
        cY - 30,
        80,
        30,
        const Color(0xFFB45309),
        const Color(0xFF78350F),
        3,
      );
      var char = characters.firstWhere((c) => c.id == 'sita');
      _drawCharWithSign(canvas, cX - 60, cY + 20, 0.75, char.color, char.sign);
      _drawSpeechBubble(
        canvas,
        t('s4_success', lang).replaceAll('\n', ' '),
        cX + 50,
        cY - 100,
        240,
        80,
      );
    }
  }

  void _drawS5View(Canvas canvas) {
    double pY = 150;
    _drawRect(
      canvas,
      -160,
      pY - 100,
      100,
      100,
      const Color(0xFFE2E8F0),
      const Color(0xFF94A3B8),
      4,
    );
    _drawTextWithOutline(
      canvas,
      "2",
      -110,
      pY - 50,
      48,
      const Color(0xFF94A3B8),
      Colors.transparent,
      strokeW: 0,
    );
    _drawRect(
      canvas,
      -60,
      pY - 160,
      120,
      160,
      const Color(0xFFFEF08A),
      const Color(0xFFD97706),
      4,
    );
    _drawTextWithOutline(
      canvas,
      "1",
      0,
      pY - 80,
      64,
      const Color(0xFFD97706),
      Colors.transparent,
      strokeW: 0,
    );
    _drawRect(
      canvas,
      60,
      pY - 70,
      100,
      70,
      const Color(0xFFFED7AA),
      const Color(0xFFC2410C),
      4,
    );
    _drawTextWithOutline(
      canvas,
      "3",
      110,
      pY - 35,
      40,
      const Color(0xFFC2410C),
      Colors.transparent,
      strokeW: 0,
    );

    if (step == 0) {
      for (var dz in dropZones) {
        if (dz.filledWith == null)
          _drawRect(
            canvas,
            dz.x,
            dz.y,
            dz.w,
            dz.h,
            const Color(0xFF22C55E).withOpacity(0.2),
            const Color(0xFF22C55E),
            2,
          );
        else
          _drawRect(
            canvas,
            dz.x,
            dz.y + dz.h,
            dz.w,
            10,
            const Color(0xFF22C55E).withOpacity(0.8),
          );
      }
    } else {
      _drawTextWithOutline(
        canvas,
        "WINNERS!",
        0,
        pY - 260,
        48,
        const Color(0xFFFDE047),
        const Color(0xFFB45309),
        strokeW: 4,
      );
    }
  }

  void _drawDraggables(Canvas canvas) {
    for (var item in dragItems) {
      if (!item.dropped) {
        if (item.type == 'symbol') {
          _drawRect(
            canvas,
            item.x - 25,
            item.y - 25,
            50,
            50,
            Colors.white,
            const Color(0xFF94A3B8),
            2,
          );
          _drawTextWithOutline(
            canvas,
            item.val,
            item.x,
            item.y,
            24,
            const Color(0xFF0F172A),
            Colors.transparent,
            strokeW: 0,
          );
        } else if (item.type == 'char') {
          if (item.id == 'jay') {
            _drawJay(canvas, item.x, item.y, item.id == activeDrag ? 0.9 : 0.7);
            _drawSign(canvas, item.x + 30, item.y - 30, "+2");
          } else if (item.id == 'aman') {
            _drawAman(
              canvas,
              item.x,
              item.y,
              item.id == activeDrag ? 0.9 : 0.7,
            );
            _drawSign(canvas, item.x + 30, item.y - 30, "-1");
          } else if (item.id == 'binnu') {
            _drawAvatar(
              canvas,
              item.x,
              item.y,
              item.id == activeDrag ? 0.9 : 0.7,
              const Color(0xFFEC4899),
              'Binnu',
            );
            _drawSign(canvas, item.x + 30, item.y - 30, "-3");
          }
        } else if (item.type == 'char_sign') {
          _drawCharWithSign(
            canvas,
            item.x,
            item.y,
            item.id == activeDrag ? 0.85 : 0.75,
            item.charRef!.color,
            item.charRef!.sign,
          );
        } else if (item.type == 'icon') {
          _drawFaceIcon(
            canvas,
            item.x,
            item.y,
            item.id == activeDrag ? 30 : 25,
            item.charRef!.color,
          );
        }
      }
    }

    if (retryAnim != null) {
      canvas.saveLayer(
        null,
        Paint()..color = Colors.white.withOpacity(retryAnim!.opacity),
      );
      _drawTextWithOutline(
        canvas,
        retryAnim!.text,
        retryAnim!.x,
        retryAnim!.y,
        18,
        const Color(0xFFEF4444),
        Colors.white,
        strokeW: 3,
      );
      canvas.restore();
    }

    for (var c in confetti) {
      canvas.save();
      canvas.translate(c.x, c.y);
      canvas.rotate(c.vx);
      canvas.drawRect(
        const Rect.fromLTWH(-4, -4, 8, 8),
        Paint()..color = c.color,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant LabPainter old) => true;
}
