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
      title: 'Exploring Factors and Multiples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const ExploringFactorsandMultiples(),
    );
  }
}

// --- TRANSLATIONS ---
const Map<String, Map<String, String>> translations = {
  'en': {
    'shutterTitle': "The Tiler's Dilemma & The Scheduler's Secret: Exploring Factors and Multiples",
    'appTitle': "Exploring Factors and Multiples",
    'appSubtitle': "Class 7 • FINDING COMMON GROUND",
    'enterLab': "Enter Simulation",
    'settings': "Settings",
    'theme': "Theme",
    'darkMode': "Switch to Dark Mode",
    'lightMode': "Switch to Light Mode",
    'boardFontSize': "Text Size",
    'selectScenario': "Select Scenario",
    'stepLabel': "STEP",
    'doneBtn': "Done",
    'learnLbl': "Observations:",
    'lbl_drag': "DRAG",
    'lbl_calc': "CALCULATION:",
    'lbl_success': "SUCCESS",
    'lbl_failure': "FAILURE",
    'lbl_reset': "RESET",
    'lbl_autofill': "AUTO-FILL",
    'lbl_s1_toolbox': "Tile Toolbox (ft)",
    'lbl_s1_wall': "Wall Length: 12ft",
    'lbl_s1_fit': "\nfits perfectly!",
    'lbl_s1_notfit': "\nleaves a gap!",
    'lbl_s1_factors': "Successful sizes (factors):",
    'lbl_s1_gap': "Gap",
    'lbl_s2_identify': "Identify Common Factors",
    'lbl_s2_common': "COMMON TILES",
    'lbl_s2_floor_grid': "12 ft x 16 ft Floor Grid",
    'lbl_s2_board': "Find Common Factors",
    'lbl_s2_f12': "Factors of 12",
    'lbl_s2_f16': "Factors of 16",
    'lbl_s2_used': "Tiles used:",
    'lbl_s2_hcf_stamp': "HCF = 4",
    'lbl_s2_common_found': "Common Factors are 1, 2, and 4.\nThese sizes fit!",
    'lbl_s2_correct_4ft': "Correct! The 4ft tile is the\nlargest of the common factors.\nThe Highest Common Factor\n(HCF) of 12 and 16 is 4.",
    'lbl_s3_anshu': "Anshu's Strip (6cm)",
    'lbl_s3_guna': "Guna's Strip (8cm)",
    'lbl_s3_add': "Add Strip",
    'lbl_s3_len': "Total Length:",
    'lbl_s3_strips': "Strips",
    'lbl_s3_lcm': "LCM = 24",
    'lbl_s3_msg': "24 and 48 are common multiples.\nThe smallest is 24 (LCM).",
    'lbl_s4_pile1': "84 kg Rice",
    'lbl_s4_pile2': "108 kg Rice",
    'lbl_s4_bag': "Bag Sizer",
    'lbl_s4_leftover': "Leftover",
    'lbl_s4_bags_text': "Bags",
    'lbl_s4_hcfmsg': "The largest bag size that works for both is 12kg.\nThe HCF of 84 and 108 is 12.",
    'lbl_s5_cows': "Cow Counter",
    'lbl_s5_pass3': "Pass 3 Gates",
    'lbl_s5_pass5': "Pass 5 Gates",
    'lbl_s5_pass7': "Pass 7 Gates",
    'lbl_s5_lcmmsg': "105 is the smallest multiple for all.\nLCM of 3, 5, 7 is 105.",
    'lbl_s5_final_temp': "FINAL TEMPERATURE: -12°C",
    'lbl_s5_eq1': "8 + (-5) + (-5) + (-5) + (-5) = -12",
    'lbl_s5_eq2': "8 + (4 × -5) = 8 - 20 = -12",
    'lbl_s5_time': "TIME ELAPSED",
    'lbl_s5_hr': "HR",
    'lbl_s5_next': "NEXT HOUR",
    'lbl_white_short': "WHITE",
    'lbl_grey_short': "GREY",
    's1_title': "1. The Perfect Fit",
    's1_obj': "Discover which square tiles can perfectly fit along the 12 ft breadth of a room.",
    's1_step1_task': "DRAG the 1ft tile to the wall and CLICK the 'Auto-fill' button.",
    's1_step1_out': "1ft fits perfectly! 1 is a factor of 12.",
    's1_step2_task': "CLICK 'Reset'. Test the 2ft, 3ft, 4ft, 5ft, and 6ft tiles using Auto-fill.",
    's1_step2_out': "1, 2, 3, 4, and 6 fit. 5 does not. They are factors of 12.",
    's1_hud1': "Drag the 1ft tile to the wall starting point.",
    's1_hud2': "Test all remaining tiles.",
    's2_title': "2. The Tiler's Code: Finding HCF",
    's2_obj': "Find the largest square tile that can cover a 12 ft by 16 ft floor perfectly, using the fewest tiles possible.",
    's2_step1_task': "CLICK on the numbers that appear in BOTH factor lists on the whiteboard.",
    's2_step1_out': "The common factors are 1, 2, and 4.",
    's2_step2_task': "DRAG the 1ft tile onto the floor.",
    's2_step2_out': "The floor is tiled with 192 1ft tiles.",
    's2_step3_task': "CLICK 'Reset'. Try the 2ft tile, then 'Reset' and try the 4ft tile.",
    's2_step3_out': "2ft uses 48 tiles. 4ft uses 12 tiles.",
    's2_step4_task': "CLICK on the largest common factor tile in the toolbox.",
    's2_step4_out': "The 4ft tile uses the fewest pieces. The HCF of 12 and 16 is 4.",
    's2_hud1': "Click matching numbers in both columns.",
    's2_hud2': "Drag the 1ft tile to the floor.",
    's2_hud3': "Test the 2ft and 4ft tiles.",
    's2_hud4': "Click the 4ft tile in the toolbox.",
    's3_title': "3. The Toran Race: Finding LCM",
    's3_obj': "Find the shortest possible length at which two different cloth strips can make a toran of the exact same length.",
    's3_step1_task': "CLICK the 'Add Strip' button for Anshu's line four times.",
    's3_step1_out': "Anshu's line reaches 24cm.",
    's3_step2_task': "CLICK the 'Add Strip' button for Guna's line until its total length matches Anshu's.",
    's3_step2_out': "Guna's line matches at 24cm (after 3 strips).",
    's3_step3_task': "CLICK the 'Add Strip' buttons on both lines again until they match a second time.",
    's3_step3_out': "The lines match again at 48cm.",
    's3_step4_task': "Observe the summary.",
    's3_step4_out': "24 is the Lowest Common Multiple (LCM) of 6 and 8.",
    's3_hud1': "Add 4 strips to Anshu's line.",
    's3_hud2': "Add strips to Guna's line to reach 24cm.",
    's3_hud3': "Add strips to both until they match again.",
    's3_hud4': "Observe the LCM concept.",
    's4_title': "4. The Rice Merchant's Puzzle",
    's4_obj': "Find the largest bag size to pack 84kg and 108kg of rice with no leftovers.",
    's4_step1_task': "Set the Bag Sizer slider to 10kg.",
    's4_step1_out': "A 10kg bag is created.",
    's4_step2_task': "DRAG the 10kg bag to the 84kg pile.",
    's4_step2_out': "8 bags are filled, 4kg is leftover (Fails).",
    's4_step3_task': "Adjust the slider to find a size that leaves 0kg leftover for BOTH piles. Drag to test.",
    's4_step3_out': "The 12kg bag works perfectly for both piles.",
    's4_step4_task': "Observe the result.",
    's4_step4_out': "The largest bag size is 12kg. The HCF of 84 and 108 is 12.",
    's4_hud1': "Slide the bag size to 10kg.",
    's4_hud2': "Drag the 10kg bag to the 84kg pile.",
    's4_hud3': "Find the bag size that works for both piles.",
    's4_hud4': "Observe the highest common factor.",
    's5_title': "5. The Cowherd's Crossing",
    's5_obj': "Find the smallest number of cows that can pass through gates in groups of 3, 5, and 7 with none left over.",
    's5_step1_task': "Set the Cow Counter to 30.",
    's5_step1_out': "The counter displays 30 Cows.",
    's5_step2_task': "CLICK the 'Pass 3 Gates' button.",
    's5_step2_out': "Success! 30 is a multiple of 3.",
    's5_step3_task': "CLICK the 'Pass 7 Gates' button.",
    's5_step3_out': "Failure! 2 cows leftover. 30 is not a multiple of 7.",
    's5_step4_task': "Find a number of cows that passes all three gates successfully. Use the slider to test.",
    's5_step4_out': "105 cows successfully pass all gates.",
    's5_step5_task': "Observe the summary.",
    's5_step5_out': "105 is the Lowest Common Multiple (LCM) of 3, 5, and 7.",
    's5_hud1': "Slide the cow counter to 30.",
    's5_hud2': "Click 'Pass 3 Gates'.",
    's5_hud3': "Click 'Pass 7 Gates'.",
    's5_hud4': "Find the number that passes all gates.",
    's5_hud5': "Observe the LCM concept."
  },
  'hi': {
    'shutterTitle': "टाइलर की दुविधा और शेड्यूलर का रहस्य: गुणनखंड और गुणज की खोज",
    'appTitle': "गुणनखंड और गुणज की खोज",
    'appSubtitle': "कक्षा 7 • सामान्य आधार खोजना",
    'enterLab': "सिमुलेशन दर्ज करें",
    'selectScenario': "परिदृश्य चुनें",
    'stepLabel': "चरण",
    'learnLbl': "अवलोकन:",
    'lbl_drag': "खींचें",
    'lbl_calc': "गणना:",
    'lbl_success': "सफलता!",
    'lbl_failure': "विफलता",
    'lbl_reset': "रीसेट",
    'lbl_autofill': "ऑटो-फिल",
    'lbl_s1_toolbox': "टाइल टूलबॉक्स (ft)",
    'lbl_s1_wall': "दीवार की लंबाई: 12ft",
    'lbl_s1_fit': "\nपूरी तरह फिट है!",
    'lbl_s1_notfit': "\nजगह छोड़ता है!",
    'lbl_s1_factors': "सफल आकार (गुणनखंड):",
    'lbl_s1_gap': "अंतर",
    'lbl_s2_identify': "सामान्य गुणनखंड पहचानें",
    'lbl_s2_common': "सामान्य टाइलें",
    'lbl_s2_floor_grid': "12 x 16 फीट फर्श ग्रिड",
    'lbl_s2_board': "सामान्य गुणनखंड खोजें",
    'lbl_s2_f12': "12 के गुणनखंड",
    'lbl_s2_f16': "16 के गुणनखंड",
    'lbl_s2_used': "प्रयुक्त टाइलें:",
    'lbl_s2_hcf_stamp': "म.स.प. = 4",
    'lbl_s2_common_found': "सामान्य गुणनखंड 1, 2, और 4 हैं।\nये आकार फिट हैं!",
    'lbl_s2_correct_4ft': "सही! 4ft टाइल सबसे बड़ा सामान्य\nगुणनखंड है। 12 और 16 का म.स.प. 4 है।",
    'lbl_s3_anshu': "अंशु की पट्टी (6cm)",
    'lbl_s3_guna': "गुना की पट्टी (8cm)",
    'lbl_s3_add': "पट्टी जोड़ें",
    'lbl_s3_len': "कुल लंबाई:",
    'lbl_s3_strips': "पट्टियाँ",
    'lbl_s3_lcm': "ल.स.प. = 24",
    'lbl_s3_msg': "24 और 48 सामान्य गुणज हैं।\nसबसे छोटा 24 (LCM) है।",
    'lbl_s4_pile1': "84 kg चावल",
    'lbl_s4_pile2': "108 kg चावल",
    'lbl_s4_bag': "बैग का आकार",
    'lbl_s4_leftover': "बचा हुआ",
    'lbl_s4_bags_text': "बैग",
    'lbl_s4_hcfmsg': "दोनों के लिए सबसे बड़ा बैग 12kg है।\n84 और 108 का म.स.प. 12 है।",
    'lbl_s5_cows': "गाय काउंटर",
    'lbl_s5_pass3': "3 गेट पार करें",
    'lbl_s5_pass5': "5 गेट पार करें",
    'lbl_s5_pass7': "7 गेट पार करें",
    'lbl_s5_lcmmsg': "105 सबसे छोटा गुणज है।\n3, 5, 7 का ल.स.प. 105 है।",
    'lbl_s5_final_temp': "अंतिम तापमान: -12°C",
    'lbl_s5_eq1': "8 + (-5) + (-5) + (-5) + (-5) = -12",
    'lbl_s5_eq2': "8 + (4 × -5) = 8 - 20 = -12",
    'lbl_s5_time': "बीता हुआ समय",
    'lbl_s5_hr': "घंटा",
    'lbl_s5_next': "अगला घंटा",
    'lbl_white_short': "सफेद",
    'lbl_grey_short': "ग्रे",
    's1_title': "1. सही फिट",
    's1_obj': "पता लगाएं कि कौन सी चौकोर टाइलें कमरे की 12 फीट चौड़ाई में पूरी तरह फिट हो सकती हैं।",
    's1_step1_task': "1ft टाइल को दीवार पर खींचें और 'ऑटो-फिल' पर क्लिक करें।",
    's1_step1_out': "1ft पूरी तरह फिट है! 1, 12 का गुणनखंड है।",
    's1_step2_task': "'रीसेट' पर क्लिक करें। 2ft, 3ft, 4ft, 5ft और 6ft का परीक्षण करें।",
    's1_step2_out': "1, 2, 3, 4, 6 फिट हैं। 5 नहीं।",
    's1_hud1': "1ft टाइल को दीवार पर खींचें।",
    's1_hud2': "बाकी टाइलों का परीक्षण करें।",
    's2_title': "2. टाइलर का कोड: म.स.प.",
    's2_obj': "12x16 फीट के फर्श के लिए सबसे बड़ी टाइल खोजें।",
    's2_step1_task': "व्हाइटबोर्ड पर दोनों सूचियों में आने वाली संख्याओं पर क्लिक करें।",
    's2_step1_out': "सामान्य गुणनखंड 1, 2 और 4 हैं।",
    's2_step2_task': "1ft टाइल को फर्श पर खींचें।",
    's2_step2_out': "फर्श 192 टाइलों से भर गया है।",
    's2_step3_task': "'रीसेट' करें। 2ft और 4ft टाइल आज़माएं।",
    's2_step3_out': "2ft में 48 और 4ft में 12 टाइलें लगती हैं।",
    's2_step4_task': "टूलबॉक्स में सबसे बड़ी सामान्य गुणनखंड टाइल पर क्लिक करें।",
    's2_step4_out': "4ft टाइल सबसे अच्छी है। HCF 4 है।",
    's2_hud1': "दोनों सूचियों में समान संख्याओं पर क्लिक करें।",
    's2_hud2': "1ft टाइल को फर्श पर खींचें।",
    's2_hud3': "2ft और 4ft टाइलों का परीक्षण करें।",
    's2_hud4': "टूलबॉक्स में 4ft टाइल पर क्लिक करें।",
    's3_title': "3. तोरण दौड़: ल.स.प.",
    's3_obj': "वह सबसे छोटी लंबाई ज्ञात कीजिए जिस पर दो अलग-अलग पट्टियाँ समान लंबाई बना सकती हैं।",
    's3_step1_task': "अंशु की लाइन के लिए 4 बार 'पट्टी जोड़ें' पर क्लिक करें।",
    's3_step1_out': "अंशु की लाइन 24cm तक पहुँच गई।",
    's3_step2_task': "गुना की लाइन के लिए 'पट्टी जोड़ें' पर तब तक क्लिक करें जब तक वह अंशु से मेल न खा जाए।",
    's3_step2_out': "गुना की लाइन 24cm पर मिलती है।",
    's3_step3_task': "दोनों लाइनों पर तब तक क्लिक करें जब तक वे दूसरी बार मेल न खाएं।",
    's3_step3_out': "लाइनें फिर से 48cm पर मिलती हैं।",
    's3_step4_task': "सारांश देखें।",
    's3_step4_out': "24 सबसे छोटा सामान्य गुणज (LCM) है।",
    's3_hud1': "अंशु की लाइन में 4 पट्टियाँ जोड़ें।",
    's3_hud2': "गुना की लाइन में 24cm तक पट्टियाँ जोड़ें।",
    's3_hud3': "फिर से मेल खाने तक दोनों में पट्टियाँ जोड़ें।",
    's3_hud4': "ल.स.प. अवधारणा का निरीक्षण करें।",
    's4_title': "4. चावल व्यापारी की पहेली",
    's4_obj': "बिना बचे 84kg और 108kg चावल पैक करने के लिए सबसे बड़ा बैग खोजें।",
    's4_step1_task': "बैग का आकार 10kg पर सेट करें।",
    's4_step1_out': "10kg का बैग बन गया।",
    's4_step2_task': "10kg के बैग को 84kg के ढेर पर खींचें।",
    's4_step2_out': "8 बैग भरे, 4kg बचा (विफलता)।",
    's4_step3_task': "स्लाइडर को समायोजित करें और ऐसा आकार खोजें जो दोनों ढेरों के लिए काम करे।",
    's4_step3_out': "12kg का बैग दोनों के लिए सही काम करता है।",
    's4_step4_task': "परिणाम देखें।",
    's4_step4_out': "सबसे बड़ा बैग 12kg है। 84 और 108 का HCF 12 है।",
    's4_hud1': "बैग के आकार को 10kg पर लाएँ।",
    's4_hud2': "10kg बैग को 84kg के ढेर पर खींचें।",
    's4_hud3': "वह आकार खोजें जो दोनों ढेरों के लिए काम करे।",
    's4_hud4': "म.स.प. का निरीक्षण करें।",
    's5_title': "5. काउहर्ड की क्रॉसिंग",
    's5_obj': "गायों की वह सबसे छोटी संख्या ज्ञात कीजिए जो 3, 5, और 7 के समूहों में गेट से गुजर सके।",
    's5_step1_task': "गाय काउंटर को 30 पर सेट करें।",
    's5_step1_out': "काउंटर 30 गाय दिखाता है।",
    's5_step2_task': "'3 गेट पार करें' बटन पर क्लिक करें।",
    's5_step2_out': "सफलता! 30, 3 का गुणज है।",
    's5_step3_task': "'7 गेट पार करें' बटन पर क्लिक करें।",
    's5_step3_out': "विफलता! 2 गाय बचीं। 30, 7 का गुणज नहीं है।",
    's5_step4_task': "स्लाइडर का उपयोग करके वह संख्या खोजें जो सभी तीन गेट पार कर सके।",
    's5_step4_out': "105 गायें सभी गेट सफलतापूर्वक पार करती हैं।",
    's5_step5_task': "सारांश देखें।",
    's5_step5_out': "105 सबसे छोटा गुणज (LCM) है।",
    's5_hud1': "गाय काउंटर को 30 पर लाएँ।",
    's5_hud2': "'3 गेट पार करें' पर क्लिक करें।",
    's5_hud3': "'7 गेट पार करें' पर क्लिक करें।",
    's5_hud4': "सभी गेट पार करने वाली संख्या खोजें।",
    's5_hud5': "ल.स.प. का निरीक्षण करें।"
  }
};

// --- DATA MODELS ---

class SimState {
  bool animating = false;
  double animProgress = 0.0;
  String? activeDragEntity;
  double dragX = 0;
  double dragY = 0;
  String? activeSlider;

  // S1
  int? s1ActiveTile;
  int? s1CurrentTest;
  int s1Filled = 0;
  Map<int, bool> s1Tested = {1: false, 2: false, 3: false, 4: false, 5: false, 6: false};

  // S2
  List<int> s2F12 = [1, 2, 3, 4, 6, 12];
  List<int> s2F16 = [1, 2, 4, 8, 16];
  List<int> s2Clicked12 = [];
  List<int> s2Clicked16 = [];
  int? s2ActiveTile;
  int s2Filled = 0;
  Map<int, bool> s2Tested = {1: false, 2: false, 4: false};

  // S3
  int s3Anshu = 0;
  int s3Guna = 0;

  // S4
  int s4BagSize = 1;
  int? s4Tested84;
  int? s4Tested108;

  // S5
  int s5Cows = 30;
  Map<int, int?> s5Tested = {3: null, 5: null, 7: null};
  int? s5AnimGate;
  double s5AnimProgress = 0.0;

  void resetScenario(int sc) {
    animating = false;
    animProgress = 0;
    activeDragEntity = null;
    activeSlider = null;
    if (sc == 1) {
      s1ActiveTile = null;
      s1CurrentTest = null;
      s1Filled = 0;
      s1Tested = {1: false, 2: false, 3: false, 4: false, 5: false, 6: false};
    }
    if (sc == 2) {
      s2Clicked12.clear();
      s2Clicked16.clear();
      s2ActiveTile = null;
      s2Filled = 0;
      s2Tested = {1: false, 2: false, 4: false};
    }
    if (sc == 3) {
      s3Anshu = 0;
      s3Guna = 0;
    }
    if (sc == 4) {
      s4BagSize = 1;
      s4Tested84 = null;
      s4Tested108 = null;
    }
    if (sc == 5) {
      s5Cows = 30;
      s5Tested = {3: null, 5: null, 7: null};
      s5AnimGate = null;
      s5AnimProgress = 0.0;
    }
  }
}

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

// --- MAIN WIDGET ---

class ExploringFactorsandMultiples extends StatefulWidget {
  const ExploringFactorsandMultiples({super.key});

  @override
  State<ExploringFactorsandMultiples> createState() => _ExploringFactorsandMultiplesState();
}

class _ExploringFactorsandMultiplesState extends State<ExploringFactorsandMultiples> with SingleTickerProviderStateMixin {
  bool _showCurtain = true;
  bool _isSidebarOpen = true;
  double _sidebarWidthRatio = 0.38;
  String _lang = 'en';

  int _scenario = 1;
  int _step = 0;

  double _zoom = 1.0;
  double _panX = 0.0;
  double _panY = 0.0;
  
  final SimState _sim = SimState();
  late Ticker _ticker;
  Timer? _s1Timer;
  DateTime? _animStart;
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      if (_sim.animating && _animStart != null && _sim.s5AnimGate != null) {
        final double delta = DateTime.now().difference(_animStart!).inMilliseconds / 1500.0;
        setState(() {
          _sim.s5AnimProgress = delta;
          if (_sim.s5AnimProgress >= 1.0) {
            _sim.animating = false;
            _sim.s5AnimProgress = 1.0;
            _handleS5AnimComplete();
          }
        });
      } else {
        setState(() {}); // Drive the painter
      }
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
    _s1Timer?.cancel();
    super.dispose();
  }

  String t(String key) => translations[_lang]?[key] ?? translations['en']![key] ?? key;

  void _startLab() {
    AudioEngine.enter();
    setState(() { _showCurtain = false; });
  }

  void _toggleLang() {
    AudioEngine.pop();
    setState(() { _lang = _lang == 'en' ? 'hi' : 'en'; });
  }

  void _loadScenario(int id) {
    AudioEngine.pop();
    _s1Timer?.cancel();
    setState(() {
      _scenario = id;
      _step = 0;
      _panX = 0;
      _panY = 0;
      _zoom = 1.0;
      _sim.resetScenario(id);
    });
  }

  void _resetLab() {
    AudioEngine.pop();
    _s1Timer?.cancel();
    setState(() {
      _lang = 'en';
      _showCurtain = true;
      _scenario = 1;
      _step = 0;
      _panX = 0;
      _panY = 0;
      _zoom = 1.0;
      _sim.resetScenario(1);
    });
  }

  void _advanceStep() {
    int maxSteps = _getScenarioStepsCount();
    if (_step < maxSteps) {
      setState(() { _step++; });
    }
  }

  int _getScenarioStepsCount() {
    if (_scenario == 1) return 2;
    if (_scenario == 2) return 4;
    if (_scenario == 3) return 4;
    if (_scenario == 4) return 4;
    return 5;
  }

  void _handleS5AnimComplete() {
    int param = _sim.s5AnimGate!;
    _sim.s5AnimGate = null;
    _sim.s5Tested[param] = _sim.s5Cows % param;
    if (_sim.s5Tested[param] == 0) AudioEngine.success(); else AudioEngine.error();
    
    if (_scenario == 5 && _step == 1 && param == 3) _advanceStep();
    if (_scenario == 5 && _step == 2 && param == 7) _advanceStep();
    
    if (_sim.s5Tested[3] == 0 && _sim.s5Tested[5] == 0 && _sim.s5Tested[7] == 0 && _step == 3) {
      _advanceStep();
      AudioEngine.success();
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (_step == 4) _advanceStep(); // Auto-complete the final observation step
      });
    }
  }

  void _checkS3() {
    int lenA = _sim.s3Anshu * 6;
    int lenG = _sim.s3Guna * 8;
    if (_step == 0 && lenA >= 24) { _advanceStep(); AudioEngine.success(); }
    if (_step == 1 && lenG >= 24) { _advanceStep(); AudioEngine.success(); }
    if (_step == 2 && lenA >= 48 && lenG >= 48) {
      _advanceStep();
      AudioEngine.success();
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (_step == 3) _advanceStep(); // Auto-complete the final observation step
      });
    }
  }

  void _triggerAction(String action, [int param = 0]) {
    if (action == 's1_autofill') {
      if (_sim.s1ActiveTile == null) return;
      _sim.animating = true;
      AudioEngine.tick();
      int tVal = _sim.s1ActiveTile!;
      _sim.s1CurrentTest = tVal;
      _sim.s1Filled = 0;
      
      _s1Timer?.cancel();
      _s1Timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
        if (_sim.s1Filled + tVal <= 12) {
          setState(() { _sim.s1Filled += tVal; });
          AudioEngine.snap();
        } else {
          timer.cancel();
          setState(() {
            _sim.animating = false;
            _sim.s1Tested[tVal] = true;
            if (12 % tVal != 0) AudioEngine.error(); else AudioEngine.success();
            
            bool allTested = true;
            [1, 2, 3, 4, 5, 6].forEach((x) { if (!_sim.s1Tested[x]!) allTested = false; });
            if (allTested && _step == 1) {
              _advanceStep();
              AudioEngine.success();
            }
            if (_scenario == 1 && _step == 0 && tVal == 1) _advanceStep();
          });
        }
      });
    } else if (action == 's1_reset') {
      setState(() { _sim.s1ActiveTile = null; _sim.s1CurrentTest = null; _sim.s1Filled = 0; });
      AudioEngine.pop();
    } else if (action == 's2_reset') {
      setState(() { _sim.s2ActiveTile = null; _sim.s2Filled = 0; });
      AudioEngine.pop();
    } else if (action == 's3_addA') {
      setState(() { _sim.s3Anshu++; });
      AudioEngine.snap();
      _checkS3();
    } else if (action == 's3_addG') {
      setState(() { _sim.s3Guna++; });
      AudioEngine.snap();
      _checkS3();
    } else if (action == 's5_test') {
      if (_sim.animating) return;
      _sim.animating = true;
      _sim.s5AnimGate = param;
      _sim.s5AnimProgress = 0;
      _animStart = DateTime.now();
      AudioEngine.tick();
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
    
    if (_scenario == 1) {
      if (_hitTestBox(-340, 160, 140, 50, pt)) { _triggerAction('s1_autofill'); return; }
      if (_hitTestBox(-180, 160, 120, 50, pt)) { _triggerAction('s1_reset'); return; }
      List<int> tiles = [1, 2, 3, 4, 5, 6];
      for (int i = 0; i < tiles.length; i++) {
        int tVal = tiles[i];
        int col = i % 3; int row = i ~/ 3;
        double tx = 120 + 30 + col * 70.0; double ty = -120 + 40 + row * 60.0;
        if (_hitTestBox(tx - 25, ty - 25, 50, 50, pt)) {
          setState(() {
            _sim.activeDragEntity = 's1tile_$tVal';
            _sim.dragX = pt.x; _sim.dragY = pt.y;
          });
          AudioEngine.tick();
          return;
        }
      }
    } else if (_scenario == 2) {
      if (_hitTestBox(270, 90, 100, 40, pt)) { _triggerAction('s2_reset'); return; }
      double bx = -240; double by = -150; double startY = by + 90;
      if (_step == 0) {
        for (int i = 0; i < _sim.s2F12.length; i++) {
          int f = _sim.s2F12[i];
          if (_hitTestBox(bx + 90, startY - 15 + i * 35.0, 40, 30, pt) && !_sim.s2Clicked12.contains(f)) {
            setState(() { _sim.s2Clicked12.add(f); }); AudioEngine.tick();
          }
        }
        for (int i = 0; i < _sim.s2F16.length; i++) {
          int f = _sim.s2F16[i];
          if (_hitTestBox(bx + 330, startY - 15 + i * 35.0, 40, 30, pt) && !_sim.s2Clicked16.contains(f)) {
            setState(() { _sim.s2Clicked16.add(f); }); AudioEngine.tick();
          }
        }
        if (_sim.s2Clicked12.contains(1) && _sim.s2Clicked12.contains(2) && _sim.s2Clicked12.contains(4) &&
            _sim.s2Clicked16.contains(1) && _sim.s2Clicked16.contains(2) && _sim.s2Clicked16.contains(4) && !_sim.animating) {
          _sim.animating = true;
          AudioEngine.success();
          Future.delayed(const Duration(milliseconds: 2500), () {
            setState(() { _sim.animating = false; _advanceStep(); });
          });
        }
      }
      if (_step >= 1) {
        double tBoxX = -350, tBoxY = -120;
        List<Map<String, dynamic>> tools = [
          {'size': 1, 'x': tBoxX + 50.0, 'y': tBoxY + 100.0},
          {'size': 2, 'x': tBoxX + 130.0, 'y': tBoxY + 130.0},
          {'size': 4, 'x': tBoxX + 70.0, 'y': tBoxY + 200.0}
        ];
        for (var tItem in tools) {
          if (_hitTestBox(tItem['x'] - 30, tItem['y'] - 30, 60, 60, pt)) {
            if (_step == 3 && tItem['size'] == 4) {
              _advanceStep(); AudioEngine.success();
              return;
            }
            setState(() {
              _sim.activeDragEntity = 's2tile_${tItem['size']}';
              _sim.dragX = pt.x; _sim.dragY = pt.y;
            });
            AudioEngine.tick();
          }
        }
      }
    } else if (_scenario == 3) {
      double rx = -400; double ay = -140; double gy = 100;
      if (_hitTestBox(rx + 30, ay + 65, 120, 40, pt)) { _triggerAction('s3_addA'); return; }
      if (_hitTestBox(rx + 30, gy + 65, 120, 40, pt)) { _triggerAction('s3_addG'); return; }
    } else if (_scenario == 4) {
      double slX = -150; double slY = 180; double slW = 300;
      if (_hitTestBox(slX - 40, slY - 60, slW + 80, 120, pt)) { _sim.activeSlider = 's4'; }
      if (_hitTestBox(-40, slY - 110, 80, 80, pt) && !_sim.animating) {
        setState(() {
          _sim.activeDragEntity = 'bag'; _sim.dragX = pt.x; _sim.dragY = pt.y;
        });
        AudioEngine.snap();
      }
    } else if (_scenario == 5) {
      double slX = -400; double slY = -240; double slW = 350;
      if (_hitTestBox(slX, slY - 40, slW, 90, pt)) { _sim.activeSlider = 's5'; }
      double gx = 50; List<double> gys = [-200, -50, 100];
      List<int> gates = [3, 5, 7];
      for (int i = 0; i < gates.length; i++) {
        if (_hitTestBox(gx, gys[i], 150, 45, pt)) { _triggerAction('s5_test', gates[i]); }
      }
    }
  }

  void _onPointerMove(PointerMoveEvent e) {
    final pt = _screenToWorld(e.position);
    
    if (_sim.activeSlider != null) {
      if (_sim.activeSlider == 's4') {
        double relX = pt.x - (-150);
        double rawVal = (relX / 300) * 19 + 1;
        setState(() {
          _sim.s4BagSize = max(1, min(20, rawVal.round()));
          _sim.s4Tested84 = null; _sim.s4Tested108 = null;
        });
      } else if (_sim.activeSlider == 's5') {
        double slX = -400; double slW = 350;
        double relX = pt.x - (slX + 20);
        double rawVal = (relX / (slW - 40)) * 198 + 1;
        setState(() {
          _sim.s5Cows = max(1, min(199, rawVal.round()));
          _sim.s5Tested = {3: null, 5: null, 7: null};
        });
      }
      return;
    }

    if (_sim.activeDragEntity != null) {
      setState(() { _sim.dragX = pt.x; _sim.dragY = pt.y; });
      return;
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    final pt = _screenToWorld(e.position);

    if (_sim.activeSlider != null) {
      _sim.activeSlider = null; AudioEngine.tick();
      if (_scenario == 4 && _step == 0 && _sim.s4BagSize == 10) _advanceStep();
      if (_scenario == 5 && _step == 0 && _sim.s5Cows == 30) _advanceStep();
      return;
    }

    if (_sim.activeDragEntity != null) {
      if (_sim.activeDragEntity!.startsWith('s1tile_')) {
        int tVal = int.parse(_sim.activeDragEntity!.split('_')[1]);
        if (_hitTestBox(-380, -80, 360, 120, pt)) {
          setState(() {
            _sim.s1ActiveTile = tVal; _sim.s1CurrentTest = tVal; _sim.s1Filled = 0; _sim.s1Tested[tVal] = false;
          });
          AudioEngine.snap();
        } else { AudioEngine.error(); }
      } else if (_sim.activeDragEntity!.startsWith('s2tile_')) {
        int tVal = int.parse(_sim.activeDragEntity!.split('_')[1]);
        double fx = -50, fy = -120, fw = 320, fh = 240;
        if (_hitTestBox(fx, fy, fw, fh, pt)) {
          setState(() { _sim.s2ActiveTile = tVal; _sim.s2Filled = 0; _sim.animating = true; });
          AudioEngine.snap();
          int maxTiles = (16 ~/ tVal) * (12 ~/ tVal);
          
          _s1Timer?.cancel();
          _s1Timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
            if (_sim.s2Filled < maxTiles) {
              setState(() { _sim.s2Filled++; });
            } else {
              timer.cancel();
              setState(() {
                _sim.animating = false; AudioEngine.success();
                _sim.s2Tested[tVal] = true;
                if (_step == 1 && tVal == 1) _advanceStep();
                if (_step == 2 && _sim.s2Tested[2]! && _sim.s2Tested[4]!) _advanceStep();
              });
            }
          });
        } else { AudioEngine.error(); }
      } else if (_sim.activeDragEntity == 'bag') {
        if (_hitTestBox(-400, -200, 300, 300, pt)) { setState(() { _sim.s4Tested84 = _sim.s4BagSize; }); AudioEngine.snap(); }
        else if (_hitTestBox(100, -200, 300, 300, pt)) { setState(() { _sim.s4Tested108 = _sim.s4BagSize; }); AudioEngine.snap(); }
        else { AudioEngine.error(); }
        
        if (_scenario == 4) {
          if (_step == 1 && _sim.s4Tested84 != null) _advanceStep();
          if (_step == 2 && _sim.s4Tested84 == 12 && _sim.s4Tested108 == 12) {
            _advanceStep();
            AudioEngine.success();
            Future.delayed(const Duration(milliseconds: 2000), () {
              if (_step == 3) _advanceStep(); // Auto-complete final step
            });
          }
        }
      }
      setState(() { _sim.activeDragEntity = null; });
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
                      if (_sim.activeDragEntity != null || _sim.activeSlider != null) return;
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
                          zoom: _zoom,
                          panX: _panX,
                          panY: _panY,
                          t: t,
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
                                const Icon(Icons.dashboard_customize, color: Color(0xFF6366F1)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t('appTitle'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white), overflow: TextOverflow.ellipsis),
                                      Text(t('appSubtitle'), style: const TextStyle(fontSize: 10, color: Colors.white70)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
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
                                  label: Text(t('lbl_reset'), style: const TextStyle(color: Colors.white, fontSize: 12)),
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
              bottom: (_step < _getScenarioStepsCount()) ? 30 : -100, // Slide out when done
              child: Center(
                child: Container(
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
                      Text(t('s${_scenario}_hud${_step + 1}'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
  final double zoom;
  final double panX;
  final double panY;
  final String Function(String) t;

  LabPainter({
    required this.sim,
    required this.scenario,
    required this.step,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.t,
  });

  final Color outlineColor = const Color(0xFF0F172A);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom, zoom);

    if (scenario == 1) _renderS1(canvas);
    if (scenario == 2) _renderS2(canvas);
    if (scenario == 3) _renderS3(canvas);
    if (scenario == 4) _renderS4(canvas);
    if (scenario == 5) _renderS5(canvas);

    if (sim.activeDragEntity == 'bag') {
      _drawBlueBag(canvas, sim.dragX, sim.dragY, "${sim.s4BagSize}kg", 1.5);
    }

    canvas.restore();
  }

  void _drawRRect(Canvas canvas, double x, double y, double w, double h, double r, Color fill, Color stroke, [double lw = 1]) {
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    if (fill != Colors.transparent) canvas.drawRRect(rect, Paint()..color = fill..style = PaintingStyle.fill);
    if (stroke != Colors.transparent && lw > 0) canvas.drawRRect(rect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = lw..strokeJoin = StrokeJoin.round);
  }

  void _drawRRectCustom(Canvas canvas, double x, double y, double w, double h, double tl, double tr, double br, double bl, Color fill, Color stroke, [double lw = 1]) {
    final rect = RRect.fromRectAndCorners(Rect.fromLTWH(x, y, w, h), topLeft: Radius.circular(tl), topRight: Radius.circular(tr), bottomRight: Radius.circular(br), bottomLeft: Radius.circular(bl));
    if (fill != Colors.transparent) canvas.drawRRect(rect, Paint()..color = fill..style = PaintingStyle.fill);
    if (stroke != Colors.transparent && lw > 0) canvas.drawRRect(rect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = lw..strokeJoin = StrokeJoin.round);
  }

  void _drawLine(Canvas canvas, double x1, double y1, double x2, double y2, Color color, double width, [bool dashed = false]) {
    final paint = Paint()..color = color..strokeWidth = width..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    if (dashed) {
      const double dashWidth = 8, dashSpace = 8;
      double startX = x1, startY = y1;
      final double distance = sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
      final double dx = (x2 - x1) / distance;
      final double dy = (y2 - y1) / distance;
      double drawn = 0;
      while (drawn < distance) {
        final double endX = startX + dx * dashWidth;
        final double endY = startY + dy * dashWidth;
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
        startX = endX + dx * dashSpace;
        startY = endY + dy * dashSpace;
        drawn += dashWidth + dashSpace;
      }
    } else {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
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

  void _drawArrow(Canvas canvas, double x1, double y1, double x2, double y2, Color color, double width, [double headSize = 15]) {
    _drawLine(canvas, x1, y1, x2, y2, color, width);
    final angle = atan2(y2 - y1, x2 - x1);
    final path = Path()
      ..moveTo(x2, y2)
      ..lineTo(x2 - headSize * cos(angle - pi / 6), y2 - headSize * sin(angle - pi / 6))
      ..lineTo(x2 - headSize * cos(angle + pi / 6), y2 - headSize * sin(angle + pi / 6))
      ..close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  void _drawSpeechBubble(Canvas canvas, String text, double x, double y, double w, double h, String pointDir, double pointOffset, Color bg, Color textCol, Color border, double borderW) {
    _drawRRect(canvas, x, y, w, h, 10, bg, border, borderW);
    final paintFill = Paint()..color = bg..style = PaintingStyle.fill;
    final paintStroke = Paint()..color = border..strokeWidth = borderW..style = PaintingStyle.stroke;
    
    final pathFill = Path();
    final pathStroke = Path();
    
    if (pointDir == 'left') {
      pathFill..moveTo(x + 3, y + pointOffset)..lineTo(x - 20, y + pointOffset + 10)..lineTo(x + 3, y + pointOffset + 20);
      pathStroke..moveTo(x + 3, y + pointOffset)..lineTo(x - 20, y + pointOffset + 10)..lineTo(x + 3, y + pointOffset + 20);
    } else if (pointDir == 'bottom') {
      pathFill..moveTo(x + pointOffset, y + h - 3)..lineTo(x + pointOffset + 10, y + h + 20)..lineTo(x + pointOffset + 20, y + h - 3);
      pathStroke..moveTo(x + pointOffset, y + h - 3)..lineTo(x + pointOffset + 10, y + h + 20)..lineTo(x + pointOffset + 20, y + h - 3);
    } else if (pointDir == 'right') {
      pathFill..moveTo(x + w - 3, y + pointOffset)..lineTo(x + w + 20, y + pointOffset + 10)..lineTo(x + w - 3, y + pointOffset + 20);
      pathStroke..moveTo(x + w - 3, y + pointOffset)..lineTo(x + w + 20, y + pointOffset + 10)..lineTo(x + w - 3, y + pointOffset + 20);
    } else if (pointDir == 'top') {
      pathFill..moveTo(x + pointOffset, y + 3)..lineTo(x + pointOffset + 10, y - 20)..lineTo(x + pointOffset + 20, y + 3);
      pathStroke..moveTo(x + pointOffset, y + 3)..lineTo(x + pointOffset + 10, y - 20)..lineTo(x + pointOffset + 20, y + 3);
    }
    
    canvas.drawPath(pathFill, paintFill);
    if (borderW > 0) canvas.drawPath(pathStroke, paintStroke);
    
    _drawText(canvas, text, x + w / 2, y + h / 2, 16, textCol, Colors.transparent, 0);
  }

  void _drawSquareTile(Canvas canvas, double x, double y, double size, Color fill) {
    _drawRRect(canvas, x, y, size, size, 4, fill, outlineColor, 3);
    _drawRRect(canvas, x + 4, y + 4, size - 8, size - 8, 2, Colors.white24, Colors.transparent, 0);
  }
  
  void _drawFabricStrip(Canvas canvas, double x, double y, double width, double height, String colorType) {
    Color baseColor = colorType == 'red' ? const Color(0xFFEF4444) : const Color(0xFF3B82F6);
    Color darkColor = colorType == 'red' ? const Color(0xFFB91C1C) : const Color(0xFF1D4ED8);
    _drawRRect(canvas, x, y, width, height, 0, baseColor, outlineColor, 3);
    _drawLine(canvas, x, y + 6, x + width, y + 6, darkColor, 2);
    _drawLine(canvas, x, y + height - 6, x + width, y + height - 6, darkColor, 2);
    
    final p = Paint()..color = const Color(0xFFF8FAFC)..style = PaintingStyle.fill;
    for(double dx = x + 15; dx < x + width - 10; dx += 20) {
      final path = Path()..moveTo(dx, y + height/2 - 4)..lineTo(dx + 4, y + height/2)..lineTo(dx, y + height/2 + 4)..lineTo(dx - 4, y + height/2)..close();
      canvas.drawPath(path, p);
      canvas.drawCircle(Offset(dx - 10, y + height/2), 2, p);
    }
  }

  void _drawConveyor(Canvas canvas, double x, double y, double width) {
    _drawRRect(canvas, x + 30, y + 20, 15, 50, 0, const Color(0xFF475569), outlineColor, 3);
    _drawRRect(canvas, x + width - 45, y + 20, 15, 50, 0, const Color(0xFF475569), outlineColor, 3);
    
    _drawRRect(canvas, x - 40, y - 60, 60, 100, 4, const Color(0xFF94A3B8), outlineColor, 3);
    _drawRRect(canvas, x - 30, y - 50, 40, 30, 2, const Color(0xFF334155), outlineColor, 2);
    
    _drawRRect(canvas, x, y - 15, width, 45, 22.5, const Color(0xFF334155), outlineColor, 4);
    _drawRRect(canvas, x + 15, y - 8, width - 30, 31, 15.5, const Color(0xFF1E293B), Colors.transparent, 0);
    
    final ptFill = Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.fill;
    final ptStroke = Paint()..color = outlineColor..style = PaintingStyle.stroke..strokeWidth = 1;
    for(double wx = x + 30; wx < x + width - 20; wx += 35) {
      canvas.drawCircle(Offset(wx, y + 7), 6, ptFill);
      canvas.drawCircle(Offset(wx, y + 7), 6, ptStroke);
    }
  }

  void _drawRicePile(Canvas canvas, double x, double y, double sizeMultiplier, Color color) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(sizeMultiplier, sizeMultiplier);
    
    final path = Path()
      ..moveTo(-60, 20)
      ..quadraticBezierTo(-60, -40, 0, -60)
      ..quadraticBezierTo(60, -40, 60, 20)
      ..close();
      
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = outlineColor..style = PaintingStyle.stroke..strokeWidth = 3);
    
    final Random rnd = Random(42);
    final dotP = Paint()..color = Colors.black12;
    for(int i = 0; i < 15; i++) {
      canvas.drawCircle(Offset(-40 + rnd.nextDouble() * 80, -30 + rnd.nextDouble() * 40), 3, dotP);
    }
    canvas.restore();
  }

  void _drawBlueBag(Canvas canvas, double x, double y, String label, [double scale = 1.0]) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    
    final path = Path()
      ..moveTo(-20, 30)..lineTo(-15, -20)..lineTo(-25, -35)..lineTo(25, -35)..lineTo(15, -20)..lineTo(20, 30)..close();
      
    canvas.drawPath(path, Paint()..color = const Color(0xFF3B82F6)..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 3);
    
    _drawLine(canvas, -15, -20, 15, -20, const Color(0xFF0F172A), 3);
    _drawText(canvas, label, 0, 10, 14, const Color(0xFFF8FAFC), Colors.transparent, 0);
    canvas.restore();
  }

  void _drawCowIcon(Canvas canvas, double x, double y, [double scale = 1.0]) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);

    final black = Paint()..color = const Color(0xFF0F172A);
    final pink = Paint()..color = const Color(0xFFFCA5A5);
    final white = Paint()..color = const Color(0xFFF8FAFC);
    final stroke = Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 2;

    canvas.drawRect(const Rect.fromLTWH(-11, 10, 4, 15), black);
    canvas.drawRect(const Rect.fromLTWH(14, 10, 4, 15), black);

    canvas.drawPath(Path()..addArc(Rect.fromCenter(center: const Offset(-2, 12), width: 12, height: 12), pi, pi), pink);

    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 44, height: 28), white);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 44, height: 28), stroke);

    canvas.save(); canvas.translate(-10, -2); canvas.rotate(0.5); canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 12, height: 16), black); canvas.restore();
    canvas.save(); canvas.translate(8, -4); canvas.rotate(-0.3); canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 10, height: 12), black); canvas.restore();
    canvas.drawOval(Rect.fromCenter(center: const Offset(2, 6), width: 8, height: 6), black);

    final tailPath = Path()..moveTo(-22, -4)..quadraticBezierTo(-28, -2, -28, 8);
    canvas.drawPath(tailPath, stroke);
    canvas.drawCircle(const Offset(-28, 10), 3, black);

    canvas.drawRect(const Rect.fromLTWH(-4, 10, 5, 15), white); canvas.drawRect(const Rect.fromLTWH(-4, 10, 5, 15), stroke);
    canvas.drawRect(const Rect.fromLTWH(20, 10, 5, 15), white); canvas.drawRect(const Rect.fromLTWH(20, 10, 5, 15), stroke);

    canvas.drawOval(Rect.fromCenter(center: const Offset(24, -10), width: 20, height: 20), white);
    canvas.drawOval(Rect.fromCenter(center: const Offset(24, -10), width: 20, height: 20), stroke);

    canvas.save(); canvas.translate(30, -8); canvas.rotate(0.3); canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 12, height: 14), pink); canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 12, height: 14), stroke); canvas.restore();
    
    canvas.drawCircle(const Offset(32, -10), 1.5, black);
    canvas.drawCircle(const Offset(22, -12), 2, black);

    canvas.save(); canvas.translate(16, -12); canvas.rotate(-0.5); canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 12, height: 6), white); canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 12, height: 6), stroke); canvas.restore();

    final hornPath = Path()..moveTo(20, -18)..lineTo(22, -26)..lineTo(24, -18)..close();
    canvas.drawPath(hornPath, Paint()..color = const Color(0xFFCBD5E1)..style = PaintingStyle.fill);
    canvas.drawPath(hornPath, stroke);

    canvas.restore();
  }

  void _drawCheckmark(Canvas canvas, double x, double y, [double scale = 1.0]) {
    canvas.save(); canvas.translate(x, y); canvas.scale(scale, scale);
    final p = Path()..moveTo(-6, 0)..lineTo(-2, 4)..lineTo(6, -6);
    canvas.drawPath(p, Paint()..color = const Color(0xFF22C55E)..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    canvas.restore();
  }

  void _drawCross(Canvas canvas, double x, double y, [double scale = 1.0]) {
    canvas.save(); canvas.translate(x, y); canvas.scale(scale, scale);
    final p = Path()..moveTo(-5, -5)..lineTo(5, 5)..moveTo(5, -5)..lineTo(-5, 5);
    canvas.drawPath(p, Paint()..color = const Color(0xFFEF4444)..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    canvas.restore();
  }

  void _drawChalkboardDuster(Canvas canvas, double bx, double by, double bw, double bh) {
    _drawRRect(canvas, bx + 10, by + bh - 15, bw - 20, 15, 4, const Color(0xFFCBD5E1), outlineColor, 3);
    _drawRRect(canvas, bx + bw - 80, by + bh - 25, 50, 18, 2, const Color(0xFF475569), outlineColor, 2);
    _drawRRect(canvas, bx + bw - 80, by + bh - 7, 50, 5, 0, const Color(0xFFF8FAFC), outlineColor, 2);
  }

  void _drawGateArch(Canvas canvas, double x, double y) {
    canvas.save(); canvas.translate(x, y);
    final fill = Paint()..color = const Color(0xFF818CF8)..style = PaintingStyle.fill;
    final stroke = Paint()..color = const Color(0xFF1E3A8A)..style = PaintingStyle.stroke..strokeWidth = 3;
    
    canvas.drawRect(const Rect.fromLTWH(-20, -50, 10, 50), fill); canvas.drawRect(const Rect.fromLTWH(-20, -50, 10, 50), stroke);
    canvas.drawRect(const Rect.fromLTWH(10, -50, 10, 50), fill); canvas.drawRect(const Rect.fromLTWH(10, -50, 10, 50), stroke);
    canvas.drawRect(const Rect.fromLTWH(-20, -60, 40, 10), fill); canvas.drawRect(const Rect.fromLTWH(-20, -60, 40, 10), stroke);
    canvas.restore();
  }

  void _drawCowShed(Canvas canvas, double x, double y, double w, double h) {
    canvas.save(); canvas.translate(x, y);
    final roof = Path()..moveTo(-20, 40)..lineTo(w/2, -30)..lineTo(w+20, 40)..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFF78350F)..style = PaintingStyle.fill);
    canvas.drawPath(roof, Paint()..color = outlineColor..style = PaintingStyle.stroke..strokeWidth = 4);
    
    canvas.drawRect(Rect.fromLTWH(0, 40, w, h-40), Paint()..color = const Color(0xFFB91C1C));
    canvas.drawRect(Rect.fromLTWH(0, 40, w, h-40), Paint()..color = outlineColor..style = PaintingStyle.stroke..strokeWidth = 4);
    
    _drawRRectCustom(canvas, 20, 60, w-40, h-60, 20, 20, 0, 0, const Color(0xFF0F172A), Colors.transparent, 0);
    _drawLine(canvas, -20, 40, w+20, 40, const Color(0xFFF8FAFC), 6);
    
    canvas.drawOval(Rect.fromCenter(center: Offset(w/2, h), width: w - 20, height: 30), Paint()..color = const Color(0xFFFACC15));
    canvas.restore();
  }

  void _renderS1(Canvas canvas) {
    double u = 30; double gridW = 12 * u; double gridH = 4 * u; double gridX = -380; double gridY = -80;
    
    _drawRRect(canvas, gridX, gridY, gridW, gridH, 0, Colors.white, outlineColor, 3);
    for(int i=1; i<12; i++) _drawLine(canvas, gridX + i*u, gridY, gridX + i*u, gridY + gridH, Colors.black12, 1);
    for(int i=1; i<4; i++) _drawLine(canvas, gridX, gridY + i*u, gridX + gridW, gridY + i*u, Colors.black12, 1);
    
    _drawLine(canvas, gridX, gridY - 20, gridX + gridW, gridY - 20, outlineColor, 2);
    _drawLine(canvas, gridX, gridY - 25, gridX, gridY - 15, outlineColor, 2);
    _drawLine(canvas, gridX + gridW, gridY - 25, gridX + gridW, gridY - 15, outlineColor, 2);
    _drawText(canvas, t('lbl_s1_wall'), gridX + gridW/2, gridY - 35, 16, const Color(0xFF0F172A), Colors.transparent, 0);
    
    double tbX = 120; double tbY = -120;
    _drawRRect(canvas, tbX, tbY, 260, 160, 8, const Color(0xFFD97706), outlineColor, 4);
    _drawRRectCustom(canvas, tbX, tbY - 20, 260, 30, 8, 8, 0, 0, const Color(0xFFB45309), outlineColor, 4);
    _drawText(canvas, t('lbl_s1_toolbox'), tbX + 130, tbY - 5, 14, const Color(0xFFF8FAFC), Colors.transparent, 0);
    
    List<int> tiles = [1, 2, 3, 4, 5, 6];
    for (int i = 0; i < tiles.length; i++) {
      int tVal = tiles[i];
      int col = i % 3; int row = i ~/ 3;
      double tx = tbX + 30 + col*70.0; double ty = tbY + 40 + row*60.0;
      
      double activeOffset = (sim.s1ActiveTile == tVal) ? -4 : 0;
      _drawSquareTile(canvas, tx, ty + activeOffset, 45, (sim.s1ActiveTile == tVal) ? const Color(0xFF60A5FA) : const Color(0xFFCBD5E1)); 
      _drawText(canvas, "${tVal}ft", tx + 22.5, ty + 22.5 + activeOffset, 16, const Color(0xFF0F172A), Colors.transparent, 0);
      
      if(sim.s1Tested[tVal] == true) {
        if(12 % tVal == 0) {
          canvas.drawCircle(Offset(tx+45, ty+activeOffset), 12, Paint()..color = const Color(0xFF22C55E));
          canvas.drawCircle(Offset(tx+45, ty+activeOffset), 12, Paint()..color = outlineColor..style=PaintingStyle.stroke..strokeWidth=1);
          _drawCheckmark(canvas, tx+45, ty+activeOffset, 1.2);
        } else {
          canvas.drawCircle(Offset(tx+45, ty+activeOffset), 12, Paint()..color = const Color(0xFFEF4444));
          canvas.drawCircle(Offset(tx+45, ty+activeOffset), 12, Paint()..color = outlineColor..style=PaintingStyle.stroke..strokeWidth=1);
          _drawCross(canvas, tx+45, ty+activeOffset, 1.2);
        }
      }
    }

    double btnY = 160;
    Color autoBtnColor = (sim.s1ActiveTile != null && !sim.animating && sim.s1CurrentTest != null && !sim.s1Tested[sim.s1CurrentTest!]!) ? const Color(0xFF22C55E) : const Color(0xFF86EFAC);
    _drawRRect(canvas, gridX + 40, btnY, 140, 50, 25, autoBtnColor, outlineColor, 4);
    _drawText(canvas, t('lbl_autofill'), gridX + 110, btnY + 25, 16, const Color(0xFF0F172A), Colors.transparent, 0);
    
    _drawRRect(canvas, gridX + 200, btnY, 120, 50, 25, const Color(0xFFEF4444), outlineColor, 4);
    _drawText(canvas, t('lbl_reset'), gridX + 260, btnY + 25, 16, Colors.white, Colors.transparent, 0);

    if (sim.s1CurrentTest != null) {
      int tVal = sim.s1CurrentTest!;
      double tileSize = tVal * u;
      
      int numPlacing = sim.s1Filled ~/ tVal;
      if (sim.s1Filled == 0 && sim.s1ActiveTile != null) numPlacing = 1; 
      Color tileColor = (tVal==5) ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC);
      
      for(int i=0; i<numPlacing; i++) {
        double px = gridX + i*tileSize; double py = gridY + gridH - tileSize;
        _drawSquareTile(canvas, px, py, tileSize, tileColor); 
        _drawText(canvas, "${tVal}ft", px + tileSize/2, py + tileSize/2, 18, const Color(0xFF0F172A), Colors.transparent, 0);
      }
      
      if (!sim.animating && sim.s1Tested[tVal] == true) {
        if (12 % tVal == 0) {
          _drawRRect(canvas, gridX, gridY + gridH - tileSize, gridW, tileSize, 0, const Color(0x4422C55E), const Color(0xFF22C55E), 5);
          String msg = "${tVal}ft${t('lbl_s1_fit')}\n$tVal is a factor of 12.";
          _drawSpeechBubble(canvas, msg, gridX + gridW/2 - 180, gridY + gridH + 30, 360, 90, 'top', 170, const Color(0xFFF0FDF4), const Color(0xFF166534), outlineColor, 3);
        } else {
          double filledW = numPlacing * tileSize; double gapX = gridX + filledW; double gapW = gridW - filledW;
          _drawRRect(canvas, gridX, gridY + gridH - tileSize, filledW, tileSize, 0, const Color(0x44EF4444), const Color(0xFFEF4444), 5);
          _drawRRect(canvas, gapX, gridY + gridH - tileSize, gapW, tileSize, 0, const Color(0x4DEF4444), const Color(0xFFEF4444), 4);
          _drawText(canvas, "${gapW/u}ft\n${t('lbl_s1_gap')}", gapX + gapW/2, gridY + gridH - tileSize/2, 14, const Color(0xFFEF4444), Colors.transparent, 0);
          
          _drawArrow(canvas, gapX + gapW/2, gridY - 40, gapX + gapW/2, gridY + gridH - tileSize - 10, const Color(0xFFEF4444), 4, 15);
          String msg = "${tVal}ft${t('lbl_s1_notfit')}\n$tVal is not a factor of 12.";
          _drawSpeechBubble(canvas, msg, gapX + gapW/2 - 180, gridY - 120, 360, 90, 'bottom', 170, const Color(0xFFFEF2F2), const Color(0xFF991B1B), outlineColor, 3);
        }
      }
    }

    if (sim.activeDragEntity != null && sim.activeDragEntity!.startsWith('s1tile_')) {
      int tVal = int.parse(sim.activeDragEntity!.split('_')[1]); double s = 45;
      _drawSquareTile(canvas, sim.dragX - s/2, sim.dragY - s/2, s, const Color(0xFFCBD5E1));
      _drawText(canvas, "${tVal}ft", sim.dragX, sim.dragY, 16, const Color(0xFF0F172A), Colors.transparent, 0);
    }

    String factors = [1,2,3,4,6].where((f) => sim.s1Tested[f] == true).join(", ");
    _drawRRect(canvas, tbX - 50, tbY + 200, 360, 40, 8, const Color(0xFFF1F5F9), outlineColor, 3);
    _drawText(canvas, "${t('lbl_s1_factors')} $factors", tbX + 130, tbY + 220, 14, const Color(0xFF0F172A), Colors.transparent, 0);
  }

  void _renderS2(Canvas canvas) {
    if (step == 0) {
      double bx = -240, by = -150, bw = 480, bh = 320;
      _drawRRect(canvas, bx, by, bw, bh, 10, const Color(0xFFF8FAFC), outlineColor, 5);
      _drawChalkboardDuster(canvas, bx, by, bw, bh);
      
      _drawText(canvas, t('lbl_s2_f12'), bx + 120, by + 40, 18, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawText(canvas, t('lbl_s2_f16'), bx + 360, by + 40, 18, const Color(0xFF0F172A), Colors.transparent, 0);

      double startY = by + 90;
      for (int i=0; i<sim.s2F12.length; i++) {
        int f = sim.s2F12[i];
        bool isClicked = sim.s2Clicked12.contains(f);
        if (isClicked) _drawRRect(canvas, bx + 105, startY - 15 + i*35, 30, 30, 8, const Color(0xFFBBF7D0), const Color(0xFF22C55E), 3);
        _drawText(canvas, "$f", bx + 120, startY + i*35, 18, outlineColor, Colors.transparent, 0, TextAlign.center, 'monospace');
      }

      for (int i=0; i<sim.s2F16.length; i++) {
        int f = sim.s2F16[i];
        bool isClicked = sim.s2Clicked16.contains(f);
        if (isClicked) _drawRRect(canvas, bx + 345, startY - 15 + i*35, 30, 30, 8, const Color(0xFFBBF7D0), const Color(0xFF22C55E), 3);
        _drawText(canvas, "$f", bx + 360, startY + i*35, 18, outlineColor, Colors.transparent, 0, TextAlign.center, 'monospace');
      }

      List<int> common = [1, 2, 4];
      for(int f in common) {
        if (sim.s2Clicked12.contains(f) && sim.s2Clicked16.contains(f)) {
          double y12 = startY + sim.s2F12.indexOf(f)*35;
          double y16 = startY + sim.s2F16.indexOf(f)*35;
          _drawLine(canvas, bx + 135, y12, bx + 345, y16, const Color(0xFF4ADE80), 4);
        }
      }

      if (common.every((f) => sim.s2Clicked12.contains(f) && sim.s2Clicked16.contains(f))) {
        _drawSpeechBubble(canvas, t('lbl_s2_common_found'), bx + bw/2 - 140, by + bh + 20, 280, 70, 'top', 130, Colors.white, Colors.black, outlineColor, 3);
      }
    } else {
      double fx = -50, fy = -120, fw = 320, fh = 240;
      _drawRRect(canvas, fx, fy, fw, fh, 0, const Color(0xFFCBD5E1), outlineColor, 5);
      for(int x=1; x<16; x++) _drawLine(canvas, fx + x*20, fy, fx + x*20, fy + fh, Colors.black12, 1);
      for(int y=1; y<12; y++) _drawLine(canvas, fx, fy + y*20, fx + fw, fy + y*20, Colors.black12, 1);
      _drawText(canvas, t('lbl_s2_floor_grid'), fx + fw/2, fy + fh + 20, 16, const Color(0xFF0F172A), Colors.transparent, 0);

      double bx = -350, by = -120, bw = 220, bh = 260;
      _drawRRect(canvas, bx, by, bw, bh, 15, const Color(0xFF334155), outlineColor, 5);
      _drawRRect(canvas, bx+20, by+20, bw-40, 30, 5, const Color(0xFF1E293B), Colors.transparent, 0);
      _drawText(canvas, t('lbl_s2_common'), bx + bw/2, by + 35, 14, const Color(0xFFF8FAFC), Colors.transparent, 0);

      List<Map<String, dynamic>> tools = [
        {'size': 1, 'x': bx + 50.0, 'y': by + 100.0},
        {'size': 2, 'x': bx + 130.0, 'y': by + 130.0},
        {'size': 4, 'x': bx + 70.0, 'y': by + 200.0}
      ];
      
      for(var tool in tools) {
        int tSize = tool['size']; double s = tSize * 20.0; double tx = tool['x']; double ty = tool['y'];
        bool isTarget = (step == 3 && tSize == 4);
        if (isTarget) {
          _drawRRect(canvas, tx - s/2 - 5, ty - s/2 - 5, s + 10, s + 10, 4, const Color(0x44FACC15), const Color(0xFFFACC15), 5);
        }
        _drawSquareTile(canvas, tx - s/2, ty - s/2, s, const Color(0xFFCBD5E1));
        _drawText(canvas, "${tSize}ft", tx, ty, 14, const Color(0xFF0F172A), Colors.transparent, 0);
      }

      if (sim.s2ActiveTile != null && sim.s2Filled > 0) {
        int tVal = sim.s2ActiveTile!; double ts = tVal * 20.0;
        for(int i=0; i<sim.s2Filled; i++) {
          int row = i ~/ (16~/tVal); int col = i % (16~/tVal);
          _drawSquareTile(canvas, fx + col*ts, fy + row*ts, ts, const Color(0xFF38BDF8));
          if (tVal >= 2) _drawText(canvas, "${tVal}ft", fx + col*ts + ts/2, fy + row*ts + ts/2, 12, const Color(0xFF0F172A), Colors.transparent, 0);
        }
      }

      _drawRRect(canvas, fx + fw - 160, fy - 50, 160, 40, 8, const Color(0xFF334155), outlineColor, 3);
      _drawText(canvas, "${t('lbl_s2_used')} ${sim.s2Filled}", fx + fw - 80, fy - 30, 16, const Color(0xFFF8FAFC), Colors.transparent, 0);

      if (!sim.animating && sim.s2Filled > 0 && step == 2) {
        _drawRRect(canvas, fx + fw + 20, fy + fh - 50, 100, 40, 8, const Color(0xFFEF4444), outlineColor, 3);
        _drawText(canvas, t('lbl_reset'), fx + fw + 70, fy + fh - 30, 14, Colors.white, Colors.transparent, 0);
      }

      if (sim.activeDragEntity != null && sim.activeDragEntity!.startsWith('s2tile_')) {
        int tVal = int.parse(sim.activeDragEntity!.split('_')[1]); double s = tVal * 20.0;
        _drawSquareTile(canvas, sim.dragX - s/2, sim.dragY - s/2, s, const Color(0xFFCBD5E1));
        _drawText(canvas, "${tVal}ft", sim.dragX, sim.dragY, 14, const Color(0xFF0F172A), Colors.transparent, 0);
      }

      if (step >= 4) {
        canvas.save(); canvas.translate(fx + fw/2, fy + fh/2); canvas.rotate(-0.2);
        _drawRRect(canvas, -100, -30, 200, 60, 4, Colors.transparent, const Color(0xFF0F172A), 6);
        _drawText(canvas, t('lbl_s2_hcf_stamp'), 0, 0, 36, const Color(0xFF0F172A), Colors.transparent, 0, TextAlign.center, 'monospace');
        canvas.restore();

        _drawSpeechBubble(canvas, t('lbl_s2_correct_4ft'), fx + fw + 20, fy, 320, 100, 'left', 50, Colors.white, Colors.black, outlineColor, 3);
      }
    }
  }

  void _renderS3(Canvas canvas) {
    double u = 12; double rx = -400; 
    
    // Conveyor A
    double ay = -140;
    _drawConveyor(canvas, rx, ay, 750);
    _drawText(canvas, t('lbl_s3_anshu'), rx, ay-70, 18, const Color(0xFF0F172A), Colors.transparent, 0, TextAlign.left);
    
    _drawRRect(canvas, rx + 190, ay - 100, 140, 35, 6, const Color(0xFFF8FAFC), outlineColor, 3);
    _drawText(canvas, "${t('lbl_s3_len')} ${sim.s3Anshu*6}cm", rx + 260, ay-82, 14, const Color(0xFF0F172A), Colors.transparent, 0);
    
    if(sim.s3Anshu > 0) {
      _drawRRect(canvas, rx + 340, ay - 95, 110, 25, 4, const Color(0xFFFECDD3), outlineColor, 2);
      _drawText(canvas, "${t('lbl_s3_strips')}=${sim.s3Anshu}x6cm", rx + 395, ay-82, 12, const Color(0xFF991B1B), Colors.transparent, 0);
    }

    for(int i=0; i<sim.s3Anshu; i++) {
      _drawFabricStrip(canvas, rx + i*(6*u) + 30, ay - 20, 6*u, 40, 'red');
    }
    
    Color btnColorA = (step == 0 && sim.s3Anshu < 4) || (step == 2 && sim.s3Anshu < 8) ? const Color(0xFF22C55E) : const Color(0xFF86EFAC);
    _drawRRect(canvas, rx + 30, ay + 65, 120, 40, 8, btnColorA, outlineColor, 3);
    _drawText(canvas, t('lbl_s3_add'), rx + 90, ay + 85, 15, const Color(0xFF0F172A), Colors.transparent, 0);
    if(btnColorA.value == 0xFF22C55E) _drawRRect(canvas, rx + 25, ay + 60, 130, 50, 12, Colors.transparent, const Color(0xFFFACC15), 3);

    // Conveyor B
    double gy = 100;
    _drawConveyor(canvas, rx, gy, 750);
    _drawText(canvas, t('lbl_s3_guna'), rx, gy-70, 18, const Color(0xFF0F172A), Colors.transparent, 0, TextAlign.left);
    
    _drawRRect(canvas, rx + 190, gy - 100, 140, 35, 6, const Color(0xFFF8FAFC), outlineColor, 3);
    _drawText(canvas, "${t('lbl_s3_len')} ${sim.s3Guna*8}cm", rx + 260, gy-82, 14, const Color(0xFF0F172A), Colors.transparent, 0);

    if(sim.s3Guna > 0) {
      _drawRRect(canvas, rx + 340, gy - 95, 110, 25, 4, const Color(0xFFBFDBFE), outlineColor, 2);
      _drawText(canvas, "${t('lbl_s3_strips')}=${sim.s3Guna}x8cm", rx + 395, gy-82, 12, const Color(0xFF1E3A8A), Colors.transparent, 0);
    }

    for(int i=0; i<sim.s3Guna; i++) {
      _drawFabricStrip(canvas, rx + i*(8*u) + 30, gy - 20, 8*u, 40, 'blue');
    }

    Color btnColorG = (step == 1 && sim.s3Guna < 3) || (step == 2 && sim.s3Guna < 6) ? const Color(0xFF22C55E) : const Color(0xFF86EFAC);
    _drawRRect(canvas, rx + 30, gy + 65, 120, 40, 8, btnColorG, outlineColor, 3);
    _drawText(canvas, t('lbl_s3_add'), rx + 90, gy + 85, 15, const Color(0xFF0F172A), Colors.transparent, 0);
    if(btnColorG.value == 0xFF22C55E) _drawRRect(canvas, rx + 25, gy + 60, 130, 50, 12, Colors.transparent, const Color(0xFFFACC15), 3);

    bool match24 = sim.s3Anshu >= 4 && sim.s3Guna >= 3;
    bool match48 = sim.s3Anshu >= 8 && sim.s3Guna >= 6;

    if (match24) {
      double mX = rx + 30 + 24*u;
      _drawLine(canvas, mX, ay - 40, mX, gy + 40, const Color(0xFFFACC15), 5, false);
      _drawText(canvas, "24cm", mX, ay - 55, 16, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawText(canvas, "24cm", mX, gy + 55, 16, const Color(0xFF0F172A), Colors.transparent, 0);
    }
    if (match48) {
      double mX = rx + 30 + 48*u;
      _drawLine(canvas, mX, ay - 40, mX, gy + 40, const Color(0xFFFACC15), 5, false);
      _drawText(canvas, "48cm", mX, ay - 55, 16, const Color(0xFF0F172A), Colors.transparent, 0);
      _drawText(canvas, "48cm", mX, gy + 55, 16, const Color(0xFF0F172A), Colors.transparent, 0);
    }

    if (step >= 3) {
      _drawRRect(canvas, rx + 100, gy + 140, 500, 110, 10, const Color(0xFFFEF08A), outlineColor, 4);
      _drawText(canvas, t('lbl_s3_lcm'), rx + 350, gy + 170, 36, const Color(0xFFDC2626), Colors.transparent, 0);
      List<String> msgs = t('lbl_s3_msg').split('\n');
      for(int i=0; i<msgs.length; i++) {
        _drawText(canvas, msgs[i], rx + 350, gy + 210 + i*22, 16, outlineColor, Colors.transparent, 0);
      }
      canvas.drawRect(Rect.fromLTWH(rx + 30 + 24*u - 15, ay - 25, 30, gy - ay + 50), Paint()..color = const Color(0x66FACC15));
    }
  }

  void _drawS4Test(Canvas canvas, double x, double y, int pileW, int? bagS) {
    if (bagS == null) return;
    int bags = pileW ~/ bagS;
    int left = pileW % bagS;
    
    _drawRRect(canvas, x - 130, y + 20, 260, 120, 8, const Color(0xFFF8FAFC), outlineColor, 3);
    
    double startX = x - 100;
    for(int i=0; i<min(bags, 10); i++) {
      int col = i%5; int row = i~/5;
      _drawBlueBag(canvas, startX + col*35, y + 60 + row*30, "${bagS}kg", 0.7);
    }
    if (bags > 10) _drawText(canvas, "+", x + 80, y + 75, 18, const Color(0xFF0F172A), Colors.transparent, 0);
    
    if (left > 0) {
      _drawRicePile(canvas, x + 80, y + 110, 0.6, const Color(0xFFF8FAFC));
      _drawText(canvas, "${left}kg", x + 80, y + 130, 12, const Color(0xFFEF4444), Colors.transparent, 0);
    } else {
      canvas.drawCircle(Offset(x + 90, y + 90), 15, Paint()..color = const Color(0xFF22C55E));
      canvas.drawCircle(Offset(x + 90, y + 90), 15, Paint()..color = outlineColor..style=PaintingStyle.stroke..strokeWidth=1);
      _drawCheckmark(canvas, x + 90, y + 90, 1.2);
    }
    
    String msg = "${bagS}kg x $bags + ${left}kg";
    _drawText(canvas, msg, x, y + 35, 14, const Color(0xFF0F172A), Colors.transparent, 0);
  }

  void _renderS4(Canvas canvas) {
    canvas.save();
    canvas.drawRect(const Rect.fromLTWH(-2000, -2000, 4000, 4000), Paint()..color = const Color(0xFF5C4033));
    canvas.drawRect(const Rect.fromLTWH(-2000, 0, 4000, 2000), Paint()..color = const Color(0xFF3F2A14));
    _drawLine(canvas, -2000, 0, 2000, 0, const Color(0xFF291C0B), 8);
    canvas.restore();

    final woodFill = Paint()..color = const Color(0xFF8B5A2B)..style = PaintingStyle.fill;
    final woodStroke = Paint()..color = const Color(0xFF291C0B)..style = PaintingStyle.stroke..strokeWidth = 4;
    
    for(int i=0; i<3; i++) {
      canvas.drawRect(Rect.fromLTWH(-800 + i*600.0, -250, 400, 30), woodFill); canvas.drawRect(Rect.fromLTWH(-800 + i*600.0, -250, 400, 30), woodStroke);
      canvas.drawRect(Rect.fromLTWH(-800 + i*600.0, -50, 400, 30), woodFill); canvas.drawRect(Rect.fromLTWH(-800 + i*600.0, -50, 400, 30), woodStroke);
      for(int b=0; b<6; b++) {
        _drawBlueBag(canvas, -750 + i*600 + b*50.0, -280, "", 0.6);
        _drawBlueBag(canvas, -750 + i*600 + b*50.0, -80, "", 0.6);
      }
    }

    double px1 = -200; double px2 = 200;
    
    _drawRicePile(canvas, px1, -80, 2, const Color(0xFFF8FAFC));
    _drawText(canvas, t('lbl_s4_pile1'), px1, -180, 18, const Color(0xFF0F172A), Colors.transparent, 0);
    _drawText(canvas, "84 kg", px1, -150, 24, const Color(0xFF0F172A), Colors.transparent, 0, TextAlign.center, 'monospace');

    _drawRicePile(canvas, px2, -80, 2.3, const Color(0xFFF8FAFC));
    _drawText(canvas, t('lbl_s4_pile2'), px2, -190, 18, const Color(0xFF0F172A), Colors.transparent, 0);
    _drawText(canvas, "108 kg", px2, -160, 24, const Color(0xFF0F172A), Colors.transparent, 0, TextAlign.center, 'monospace');

    double slX = -150; double slY = 180; double slW = 300;
    _drawRRect(canvas, slX - 40, slY - 60, slW + 80, 120, 10, const Color(0xFFF8FAFC), outlineColor, 4);
    _drawText(canvas, t('lbl_s4_bag'), 0, slY - 40, 18, const Color(0xFF0F172A), Colors.transparent, 0);
    
    _drawLine(canvas, slX, slY + 10, slX + slW, slY + 10, const Color(0xFFFACC15), 10);
    _drawLine(canvas, slX, slY + 10, slX + slW, slY + 10, outlineColor, 4);
    
    double handleX = slX + ((sim.s4BagSize - 1) / 19) * slW;
    
    if (step >= 3 && sim.s4BagSize == 12) {
      _drawRRect(canvas, handleX - 20, slY - 10, 40, 40, 20, const Color(0x4422C55E), const Color(0xFF22C55E), 5);
    }

    _drawRRect(canvas, handleX - 10, slY - 5, 20, 30, 5, const Color(0xFF3B82F6), outlineColor, 3);
    _drawText(canvas, "${sim.s4BagSize}kg", handleX, slY + 40, 16, const Color(0xFF0F172A), Colors.transparent, 0);

    if (sim.activeDragEntity == null) {
      _drawBlueBag(canvas, 0, slY - 90, "${sim.s4BagSize}kg", 1.5);
    }

    if (step >= 1) _drawS4Test(canvas, px1, 10, 84, sim.s4Tested84);
    if (step >= 2) _drawS4Test(canvas, px2, 10, 108, sim.s4Tested108);

    if (step >= 3) {
      _drawRRect(canvas, 150, -280, 340, 140, 10, const Color(0xFF1E293B), outlineColor, 4);
      List<String> msgs = t('lbl_s4_hcfmsg').split('\n');
      double cY = -240;
      for(int i=0; i<msgs.length; i++) {
        _drawText(canvas, msgs[i].trim(), 320, cY + i*25, 16, const Color(0xFFF8FAFC), Colors.transparent, 0);
      }
    }
  }

  void _renderS5(Canvas canvas) {
    canvas.save();
    canvas.drawRect(const Rect.fromLTWH(-2000, -300, 4000, 3000), Paint()..color = const Color(0xFFBBF7D0));
    canvas.drawRect(const Rect.fromLTWH(-2000, -1500, 4000, 1200), Paint()..color = const Color(0xFFBAE6FD));
    _drawLine(canvas, -2000, -300, 2000, -300, const Color(0xFF4ADE80), 4);
    canvas.restore();

    double slX = -400; double slY = -240; double slW = 350;
    _drawRRect(canvas, slX, slY - 40, slW, 90, 10, const Color(0xFFF8FAFC), outlineColor, 4);
    _drawText(canvas, t('lbl_s5_cows'), slX + 80, slY - 15, 16, const Color(0xFF0F172A), Colors.transparent, 0);
    
    _drawRRect(canvas, slX + slW - 120, slY - 30, 100, 40, 8, const Color(0xFF334155), outlineColor, 2);
    Color cowCountColor = (step >= 4 && sim.s5Cows == 105) ? const Color(0xFFFACC15) : const Color(0xFFF8FAFC);
    if(step >= 4 && sim.s5Cows == 105) {
       _drawText(canvas, "${sim.s5Cows} Cows", slX + slW - 70, slY - 10, 18, cowCountColor, Colors.transparent, 0, TextAlign.center, 'monospace');
    } else {
       _drawText(canvas, "${sim.s5Cows} Cows", slX + slW - 70, slY - 10, 18, cowCountColor, Colors.transparent, 0, TextAlign.center, 'monospace');
    }

    _drawLine(canvas, slX + 20, slY + 20, slX + slW - 20, slY + 20, outlineColor, 4);
    
    double handleX = slX + 20 + ((sim.s5Cows - 1) / 198) * (slW - 40);
    _drawRRect(canvas, handleX - 10, slY + 5, 20, 30, 5, const Color(0xFF3B82F6), outlineColor, 3);
    
    _drawCowShed(canvas, 500, -250, 200, 450);

    int maxCowsToShow = 35;
    int totalCows = sim.s5Cows;
    
    double gx = 50; 
    Map<int, double> gys = { 3: -200, 5: -50, 7: 100 };

    void renderGateControls(int count) {
      double gy = gys[count]!;
      _drawRRect(canvas, gx, gy, 150, 45, 8, const Color(0xFF3B82F6), outlineColor, 4);
      _drawText(canvas, t('lbl_s5_pass$count'), gx + 75, gy + 22.5, 14, Colors.white, Colors.transparent, 0);
      
      double gateStartX = gx + 180;
      double gateSpacing = count == 3 ? 60 : count == 5 ? 45 : 35;
      for (int j=0; j<count; j++) {
        _drawGateArch(canvas, gateStartX + j*gateSpacing, gy + 20);
      }

      int? res = sim.s5Tested[count];
      if (res != null && (!sim.animating || sim.s5AnimGate != count)) {
        _drawRRect(canvas, gateStartX + count*gateSpacing + 20, gy + 5, 140, 35, 8, const Color(0xFFF8FAFC), outlineColor, 2);
        if (res == 0) {
          canvas.drawCircle(Offset(gateStartX + count*gateSpacing + 35, gy + 22.5), 8, Paint()..color = const Color(0xFF22C55E));
          canvas.drawCircle(Offset(gateStartX + count*gateSpacing + 35, gy + 22.5), 8, Paint()..color = outlineColor..style=PaintingStyle.stroke..strokeWidth=1);
          _drawCheckmark(canvas, gateStartX + count*gateSpacing + 35, gy + 22.5, 1.0);
          _drawText(canvas, t('lbl_success').replaceAll('!', ''), gateStartX + count*gateSpacing + 85, gy + 22.5, 12, const Color(0xFF166534), Colors.transparent, 0);
        } else {
          canvas.drawCircle(Offset(gateStartX + count*gateSpacing + 35, gy + 22.5), 8, Paint()..color = const Color(0xFFEF4444));
          canvas.drawCircle(Offset(gateStartX + count*gateSpacing + 35, gy + 22.5), 8, Paint()..color = outlineColor..style=PaintingStyle.stroke..strokeWidth=1);
          _drawCross(canvas, gateStartX + count*gateSpacing + 35, gy + 22.5, 1.0);
          _drawText(canvas, "$res ${t('lbl_s4_leftover')}", gateStartX + count*gateSpacing + 85, gy + 22.5, 12, const Color(0xFF991B1B), Colors.transparent, 0);
        }
      }
    }

    renderGateControls(3);
    renderGateControls(5);
    renderGateControls(7);

    int? animGate = sim.s5AnimGate;
    double p = sim.s5AnimProgress;
    int visibleCows = min(totalCows, maxCowsToShow);
    
    for(int i=0; i<visibleCows; i++) { 
      int r = i~/7; int c = i%7;
      double startX = -400 + c*50.0;
      double startY = -120 + r*35.0;
      double cx = startX, cy = startY;
      double opacity = 1;
      double scale = 0.75;
      
      if (animGate != null) {
        int numLeftovers = totalCows % animGate;
        bool isLeftoverVisually = i >= visibleCows - numLeftovers;
        
        if (isLeftoverVisually) {
          cx += sin(p * pi * 15) * 4;
        } else {
          int visGroupSize = (visibleCows - numLeftovers) ~/ animGate;
          int groupIdx = 0;
          if (visGroupSize > 0) {
            groupIdx = i ~/ visGroupSize;
            if (groupIdx >= animGate) groupIdx = animGate - 1; 
          }
          
          double gateSpacing = animGate == 3 ? 60 : animGate == 5 ? 45 : 35;
          double targetX = gx + 180 + groupIdx * gateSpacing;
          double targetY = gys[animGate]! + 20;
          double shedX = 600;
          
          if (p < 0.6) {
            double p1 = p / 0.6;
            cx = startX + (targetX - startX) * p1;
            cy = startY + (targetY - startY) * p1;
          } else {
            double p2 = (p - 0.6) / 0.4;
            cx = targetX + (shedX - targetX) * p2;
            cy = targetY;
          }
          
          opacity = p < 0.7 ? 1 : 1 - ((p - 0.7) / 0.3);
          scale = 0.75 * (1 - p * 0.2);
        }
      }
      
      canvas.saveLayer(null, Paint()..color = Colors.black.withOpacity(opacity));
      _drawCowIcon(canvas, cx, cy, scale);
      canvas.restore();
    }

    if(totalCows > maxCowsToShow) {
      _drawText(canvas, "+ ${totalCows - maxCowsToShow} more...", -200, 80, 16, const Color(0xFF0F172A), Colors.transparent, 0);
    }

    if (step >= 4 && sim.s5Cows == 105 && !sim.animating) {
      _drawRRect(canvas, -150, 200, 300, 60, 10, const Color(0xFFDCFCE7), const Color(0xFF166534), 4);
      _drawText(canvas, t('lbl_s5_lcmmsg'), 0, 230, 16, const Color(0xFF166534), Colors.transparent, 0);
    }
  }

  @override
  bool shouldRepaint(LabPainter oldDelegate) => true;
}