// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Fractional Units & Equal Shares',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const Cl6M_Ch7_A1_TheGreatRotiShareOff(),
    ),
  );
}

// --- TRANSLATIONS ---
const Map<String, Map<String, String>> TRANSLATIONS = {
  'en': {
    'shutterTitle': "The Great Roti Share-Off",
    'appTitle': "Fractional Units & Equal Shares",
    'appSubtitle': "Class 6 • Math",
    'enterLab': "Enter Simulation",
    'learnLbl': "Objective:",
    'summaryTitle': "Goal Reached!",
    'finishLab': "Finish Lab",
    'nextScenario': "Next Scenario",
    'finalDesc':
        "You successfully explored fractional units using interactive models!",
    'stepLabel': "STEP",
    'lbl_comp_mat': "Comparison Mat",
    'lbl_toolbox': "Toolbox",
    'lbl_slice': "SLICE",
    'lbl_stamp': "STAMP",
    'lbl_check': "CHECK ANSWER",

    's1_title': "1. Two vs. Four: The Roti Challenge",
    's1_obj':
        "Understand and compare the size of 1/2 and 1/4 by equally sharing one roti.",
    's1_s1_t':
        "DRAG the '2-Slice' cutter from the toolbox onto the first roti.",
    's1_s1_o': "The cutter prepares to divide the roti into two equal halves.",
    's1_s2_t': "CLICK the flashing 'Slice' button to cut the roti.",
    's1_s2_o': "The roti is cut into 2 equal pieces.",
    's1_s3_t': "DRAG each half of the roti to one of the two plates.",
    's1_s3_o': "Each person gets 1/2 of the roti.",
    's1_s4_t': "Now, DRAG the '4-Slice' cutter onto the second roti.",
    's1_s4_o':
        "The cutter prepares to divide the roti into four equal quarters.",
    's1_s5_t':
        "CLICK the 'Slice' button and DRAG each piece to the four plates.",
    's1_s5_o': "Each person gets 1/4 of the roti.",
    's1_s6_t':
        "DRAG one '1/2' piece and one '1/4' piece to the Comparison Mat.",
    's1_s6_o':
        "1/2 is MORE than 1/4. Sharing with fewer people gives a bigger piece!",
    's1_h1': "Drag the 2-Slice tool to the left Roti.",
    's1_h2': "Click Slice.",
    's1_h3': "Drag the 2 pieces to the plates.",
    's1_h4': "Drag the 4-Slice tool to the right Roti.",
    's1_h5': "Click Slice and drag pieces to plates.",
    's1_h6': "Drag one 1/2 and one 1/4 to the Mat.",

    's2_title': "2. The Chikki Bar Conundrum",
    's2_obj':
        "Reinforce that a larger denominator results in a smaller fractional unit.",
    's2_s1_t': "DRAG the '5-Part' guide over the first chikki bar.",
    's2_s1_o': "The guide shows where to break the bar into 5 equal parts.",
    's2_s2_t': "CLICK on all 4 break lines to snap the chikki bar.",
    's2_s2_o': "The bar is broken into 5 equal pieces.",
    's2_s3_t': "DRAG one piece of chikki to each of the 5 children.",
    's2_s3_o': "Each child gets 1/5 of the chikki.",
    's2_s4_t':
        "DRAG the '9-Part' guide over the second bar and CLICK on all 8 lines.",
    's2_s4_o': "The second bar is broken into 9 equal pieces.",
    's2_s5_t': "DRAG one piece of chikki to each of the 9 children.",
    's2_s5_o': "Each child gets 1/9 of the chikki.",
    's2_s6_t': "DRAG a '1/5' piece and a '1/9' piece to the Comparison Mat.",
    's2_s6_o':
        "1/5 is MORE than 1/9. Sharing with more people makes pieces smaller!",
    's2_h1': "Drag 5-Part guide to top Chikki.",
    's2_h2': "Click all dotted lines to break it.",
    's2_h3': "Drag pieces to the 5 kids.",
    's2_h4': "Drag 9-Part guide to bottom Chikki & click lines.",
    's2_h5': "Drag pieces to the 9 kids.",
    's2_h6': "Compare pieces on the mat.",

    's3_title': "3. The Fractional Unit Stamper",
    's3_obj':
        "Understand that fractional units like 1/3 and 1/6 are single, equal parts.",
    's3_s1_t':
        "DRAG the '1/6' stamper from the toolbox onto the circular chikki.",
    's3_s1_o': "The 1/6 stamper is placed on the chikki.",
    's3_s2_t': "CLICK the 'Stamp' button.",
    's3_s2_o': "A 1/6 piece is separated from the whole.",
    's3_s3_t': "DRAG the newly created '1/6' piece to the Comparison Mat.",
    's3_s3_o': "The 1/6 piece is placed for comparison.",
    's3_s4_t':
        "Now, DRAG the '1/3' stamper onto the new chikki, Stamp it, and move the piece.",
    's3_s4_o': "The 1/3 piece is placed next to the 1/6 piece.",
    's3_s5_t': "Observe the two pieces on the mat.",
    's3_s5_o': "1/3 means 1 of 3 equal parts. 1/6 means 1 of 6. 1/3 is bigger.",
    's3_h1': "Drag 1/6 Stamper to Chikki.",
    's3_h2': "Click Stamp.",
    's3_h3': "Drag the stamped piece to the Mat.",
    's3_h4': "Repeat with the 1/3 Stamper.",
    's3_h5': "Observe the difference.",

    's4_title': "4. The Guava Scale",
    's4_obj':
        "Apply the learned concepts to compare 1/3 and 1/5 using a balance scale.",
    's4_s1_t':
        "Which is bigger: 1/3 or 1/5? DRAG a slicer to the first guava for 3 people.",
    's4_s1_o': "The first guava is cut into 3 equal pieces.",
    's4_s2_t':
        "Now, divide the second guava for 5 people using the other slicer.",
    's4_s2_o': "The second guava is cut into 5 equal pieces.",
    's4_s3_t':
        "DRAG one piece from the first guava (1/3) to the LEFT side of the scale.",
    's4_s3_o': "The 1/3 piece weighs down the left pan.",
    's4_s4_t':
        "DRAG one piece from the second guava (1/5) to the RIGHT side of the scale.",
    's4_s4_o':
        "The scale settles. The 1/3 piece is heavier! 1/3 is bigger than 1/5.",
    's4_h1': "Drag the 3-Slice tool to the first Guava.",
    's4_h2': "Drag the 5-Slice tool to the second Guava.",
    's4_h3': "Drag a 1/3 piece to the Left Pan.",
    's4_h4': "Drag a 1/5 piece to the Right Pan.",

    's5_title': "5. The Equal Rice Packets",
    's5_obj':
        "Create four equal shares from a whole (1 kg), connecting division to 1/4.",
    's5_s1_t':
        "DRAG the scoop to the 1kg rice bag to fill it, then DRAG to a packet.",
    's5_s1_o': "You successfully scooped and poured rice into a packet.",
    's5_s2_t': "Continue pouring rice until the main bag is empty.",
    's5_s2_o': "All rice has been transferred to the packets.",
    's5_s3_t':
        "Adjust the rice until all four scales read exactly 250g (and turn green).",
    's5_s3_o': "All packets now have an equal share of 250g.",
    's5_s4_t': "CLICK the 'Check Answer' button.",
    's5_s4_o':
        "Perfect! When 1 kg is shared equally into 4 packets, each packet is 1/4 kg.",
    's5_h1': "Drag Scoop to Bag, then drag to Packet.",
    's5_h2': "Empty the 1kg bag completely.",
    's5_h3': "Make all 4 packets weigh 250g each.",
    's5_h4': "Click Check Answer.",
  },
  'hi': {
    'shutterTitle': "रोटी बांटने की चुनौती",
    'appTitle': "भिन्न इकाइयाँ और समान हिस्से",
    'appSubtitle': "कक्षा 6 • गणित",
    'enterLab': "सिमुलेशन शुरू करें",
    'learnLbl': "अवलोकन:",
    'summaryTitle': "लक्ष्य प्राप्त हुआ!",
    'finishLab': "समाप्त करें",
    'nextScenario': "अगला परिदृश्य",
    'finalDesc': "आपने भिन्नात्मक इकाइयों का सफलतापूर्वक पता लगाया!",
    'stepLabel': "चरण",
    'lbl_comp_mat': "तुलना चटाई",
    'lbl_toolbox': "टूलबॉक्स",
    'lbl_slice': "काटें",
    'lbl_stamp': "मोहर",
    'lbl_check': "उत्तर जांचें",

    's1_title': "1. दो बनाम चार: रोटी चुनौती",
    's1_obj': "1/2 और 1/4 के आकार को समझें और तुलना करें।",
    's1_s1_t': "'2-Slice' कटर को टूलबॉक्स से पहली रोटी पर खींचें।",
    's1_s1_o': "कटर रोटी को दो बराबर हिस्सों में बांटने के लिए तैयार है।",
    's1_s2_t': "रोटी काटने के लिए 'काटें' बटन पर क्लिक करें।",
    's1_s2_o': "रोटी 2 बराबर टुकड़ों में कट गई।",
    's1_s3_t': "रोटी के हर आधे हिस्से को दोनों प्लेटों पर खींचें।",
    's1_s3_o': "हर व्यक्ति को रोटी का 1/2 हिस्सा मिलता है।",
    's1_s4_t': "अब, '4-Slice' कटर को दूसरी रोटी पर खींचें।",
    's1_s4_o': "कटर रोटी को चार बराबर हिस्सों में बांटने के लिए तैयार है।",
    's1_s5_t': "'काटें' बटन पर क्लिक करें और टुकड़ों को 4 प्लेटों पर खींचें।",
    's1_s5_o': "हर व्यक्ति को रोटी का 1/4 हिस्सा मिलता है।",
    's1_s6_t': "एक '1/2' टुकड़ा और एक '1/4' टुकड़ा तुलना चटाई पर खींचें।",
    's1_s6_o':
        "1/2, 1/4 से बड़ा है। कम लोगों में बांटने से बड़ा हिस्सा मिलता है!",
    's1_h1': "2-Slice टूल को बाईं रोटी पर खींचें।",
    's1_h2': "काटें पर क्लिक करें।",
    's1_h3': "2 टुकड़ों को प्लेटों पर खींचें।",
    's1_h4': "4-Slice टूल को दाईं रोटी पर खींचें।",
    's1_h5': "काटें और टुकड़ों को प्लेटों पर खींचें।",
    's1_h6': "1/2 और 1/4 को चटाई पर खींचें।",

    's2_title': "2. चिक्की बार पहेली",
    's2_obj':
        "समझें कि अधिक लोगों में बांटने से हिस्सा छोटा होता है (1/5 और 1/9 की तुलना)।",
    's2_s1_t': "'5-Part' गाइड को पहली चिक्की पर खींचें।",
    's2_s1_o': "गाइड चिक्की को 5 भागों में तोड़ने की जगह दिखाता है।",
    's2_s2_t': "चिक्की तोड़ने के लिए सभी 4 लाइनों पर क्लिक करें।",
    's2_s2_o': "चिक्की 5 बराबर टुकड़ों में टूट गई।",
    's2_s3_t': "हर बच्चे को चिक्की का एक टुकड़ा दें (खींचें)।",
    's2_s3_o': "हर बच्चे को चिक्की का 1/5 हिस्सा मिलता है।",
    's2_s4_t':
        "'9-Part' गाइड को दूसरी चिक्की पर खींचें और 8 लाइनों पर क्लिक करें।",
    's2_s4_o': "दूसरी चिक्की 9 बराबर टुकड़ों में टूट गई।",
    's2_s5_t': "सभी 9 बच्चों को चिक्की का एक टुकड़ा दें।",
    's2_s5_o': "हर बच्चे को चिक्की का 1/9 हिस्सा मिलता है।",
    's2_s6_t': "'1/5' टुकड़ा और '1/9' टुकड़ा तुलना चटाई पर खींचें।",
    's2_s6_o': "1/5, 1/9 से बड़ा है।",
    's2_h1': "5-Part गाइड को चिक्की पर खींचें।",
    's2_h2': "तोड़ने के लिए लाइनों पर क्लिक करें।",
    's2_h3': "टुकड़ों को 5 बच्चों तक खींचें।",
    's2_h4': "9-Part गाइड को दूसरी चिक्की पर खींचें।",
    's2_h5': "टुकड़ों को 9 बच्चों तक खींचें।",
    's2_h6': "चटाई पर तुलना करें।",

    's3_title': "3. भिन्न इकाई मोहर",
    's3_obj': "समझें कि 1/3 और 1/6 भिन्न इकाइयाँ एक पूरे का हिस्सा हैं।",
    's3_s1_t': "'1/6' मोहर को टूलबॉक्स से चिक्की पर खींचें।",
    's3_s1_o': "1/6 मोहर चिक्की पर रखी गई है।",
    's3_s2_t': "'मोहर' बटन पर क्लिक करें।",
    's3_s2_o': "1/6 हिस्सा अलग हो गया।",
    's3_s3_t': "नए '1/6' टुकड़े को तुलना चटाई पर खींचें।",
    's3_s3_o': "1/6 टुकड़ा तुलना के लिए रखा गया।",
    's3_s4_t':
        "अब, '1/3' मोहर को नई चिक्की पर खींचें, मोहर लगाएं और टुकड़े को चटाई पर रखें।",
    's3_s4_o': "1/3 टुकड़ा 1/6 के बगल में रखा गया।",
    's3_s5_t': "दोनों टुकड़ों का निरीक्षण करें।",
    's3_s5_o': "1/3 बड़ा है क्योंकि यह कम हिस्सों से आता है।",
    's3_h1': "1/6 मोहर को चिक्की पर खींचें।",
    's3_h2': "मोहर पर क्लिक करें।",
    's3_h3': "टुकड़े को चटाई पर खींचें।",
    's3_h4': "1/3 मोहर के साथ दोहराएं।",
    's3_h5': "अंतर देखें।",

    's4_title': "4. अमरूद का तराजू",
    's4_obj': "तराजू का उपयोग करके 1/3 और 1/5 की तुलना करें।",
    's4_s1_t':
        "कौन सा बड़ा है: 1/3 या 1/5? 3 लोगों के लिए पहले अमरूद को काटने के लिए कटर खींचें।",
    's4_s1_o': "पहला अमरूद 3 टुकड़ों में कट गया।",
    's4_s2_t': "दूसरे अमरूद को 5 लोगों के लिए काटें।",
    's4_s2_o': "दूसरे अमरूद 5 टुकड़ों में कट गया।",
    's4_s3_t': "पहले अमरूद का एक टुकड़ा (1/3) बाएँ पलड़े पर खींचें।",
    's4_s3_o': "1/3 टुकड़ा बाएँ पलड़े को नीचे करता है।",
    's4_s4_t': "दूसरे अमरूद का एक टुकड़ा (1/5) दाएँ पलड़े पर खींचें।",
    's4_s4_o': "1/3 टुकड़ा भारी है! 1/3, 1/5 से बड़ा है।",
    's4_h1': "3-Slice टूल को पहले अमरूद पर खींचें।",
    's4_h2': "5-Slice टूल को दूसरे अमरूद पर खींचें।",
    's4_h3': "1/3 टुकड़े को बाएँ पलड़े पर खींचें।",
    's4_h4': "1/5 टुकड़े को दाएँ पलड़े पर खींचें।",

    's5_title': "5. चावल के बराबर पैकेट",
    's5_obj': "1 किलो को 4 बराबर हिस्सों (1/4) में बांटें।",
    's5_s1_t':
        "स्कूप को चावल की बोरी पर खींचें, फिर पैकेट पर डालकर भरें (50g प्रति स्कूप)।",
    's5_s1_o': "आपने चावल पैकेट में डाला।",
    's5_s2_t': "बोरी खाली होने तक चावल डालते रहें।",
    's5_s2_o': "सारा चावल पैकेटों में आ गया।",
    's5_s3_t':
        "पैकेटों के बीच चावल तब तक एडजस्ट करें जब तक चारों 250g के न हो जाएं।",
    's5_s3_o': "चारों पैकेटों में बराबर 250g चावल है।",
    's5_s4_t': "'उत्तर जांचें' बटन पर क्लिक करें।",
    's5_s4_o':
        "बिल्कुल सही! 1 किलो को 4 हिस्सों में बांटने पर हर हिस्सा 1/4 किलो होता है।",
    's5_h1': "स्कूप को बोरी से पैकेट तक खींचें।",
    's5_h2': "1 किलो बोरी पूरी तरह खाली करें।",
    's5_h3': "सभी 4 पैकेटों को 250g का बनाएं।",
    's5_h4': "उत्तर जांचें पर क्लिक करें।",
  },
};

// --- SIMULATION STATE ---
class SimState {
  // Global
  String lang = 'en';
  int scenario = 1;
  int step = 0;
  double zoom = 1.0;
  double panX = 0;
  double panY = 0;

  // Interaction
  String? activeDrag;
  double dragX = 0;
  double dragY = 0;

  // Scenarios
  // S1
  bool s1c1 = false;
  bool s1c2 = false;
  bool s1r1 = false;
  bool s1r2 = false;
  List<bool> s1p2 = [false, false];
  List<bool> s1p4 = [false, false, false, false];
  List<bool> s1comp = [false, false];
  bool s1btnSliceR1 = false;
  bool s1btnSliceR2 = false;

  // S2
  bool s2g1 = false;
  bool s2g2 = false;
  List<bool> s2l1 = [false, false, false, false];
  List<bool> s2l2 = [false, false, false, false, false, false, false, false];
  bool s2b1 = false;
  bool s2b2 = false;
  int s2k5 = 0;
  int s2k9 = 0;
  List<bool> s2comp = [false, false];

  // S3
  bool s3st1 = false;
  bool s3st2 = false;
  bool s3stamped1 = false;
  bool s3stamped2 = false;
  bool s3p1 = false;
  bool s3p2 = false;
  bool s3btnStamp1 = false;
  bool s3btnStamp2 = false;

  // S4
  bool s4c3 = false;
  bool s4c5 = false;
  int s4sL = 0;
  int s4sR = 0;

  // S5
  int s5bag = 1000;
  List<int> s5p = [0, 0, 0, 0];
  int s5scoop = 0;
  int s5scoopSrc = -1;

  void resetScenario() {
    step = 0;
    activeDrag = null;
    if (scenario == 1) {
      s1c1 = false;
      s1c2 = false;
      s1r1 = false;
      s1r2 = false;
      s1p2 = [false, false];
      s1p4 = [false, false, false, false];
      s1comp = [false, false];
      s1btnSliceR1 = false;
      s1btnSliceR2 = false;
    } else if (scenario == 2) {
      s2g1 = false;
      s2g2 = false;
      s2b1 = false;
      s2b2 = false;
      s2k5 = 0;
      s2k9 = 0;
      s2l1 = [false, false, false, false];
      s2l2 = [false, false, false, false, false, false, false, false];
      s2comp = [false, false];
    } else if (scenario == 3) {
      s3st1 = false;
      s3st2 = false;
      s3stamped1 = false;
      s3stamped2 = false;
      s3p1 = false;
      s3p2 = false;
      s3btnStamp1 = false;
      s3btnStamp2 = false;
    } else if (scenario == 4) {
      s4c3 = false;
      s4c5 = false;
      s4sL = 0;
      s4sR = 0;
    } else if (scenario == 5) {
      s5bag = 1000;
      s5p = [0, 0, 0, 0];
      s5scoop = 0;
      s5scoopSrc = -1;
    }
  }

  void resetAll() {
    scenario = 1;
    zoom = 1.0;
    panX = 0;
    panY = 0;
    resetScenario();
  }

  int get maxSteps {
    if (scenario == 1 || scenario == 2) return 6;
    if (scenario == 3) return 5;
    return 4; // 4, 5
  }
}

final SimState state = SimState();

// --- LAYOUT CONSTANTS ---
class Layouts {
  static const s1 = {
    'matX': -120.0,
    'matY': -240.0,
    'matW': 360.0,
    'matH': 120.0,
    'tbX': 250.0,
    'tbY': -240.0,
    'tbW': 160.0,
    'tbH': 120.0,
    't2X': 210.0,
    't2Y': -225.0,
    't4X': 290.0,
    't4Y': -225.0,
    'r1X': -200.0,
    'r1Y': 20.0,
    'r2X': 200.0,
    'r2Y': 20.0,
    'btn1X': -200.0,
    'btn1Y': 20.0,
    'btn2X': 200.0,
    'btn2Y': 20.0,
    'p2L': -260.0,
    'p2R': -140.0,
    'pY': 180.0,
    'p4Arr': <double>[95.0, 165.0, 235.0, 305.0],
  };
  static const s2 = {
    'matX': -120.0,
    'matY': -260.0,
    'matW': 340.0,
    'matH': 140.0,
    'tbX': 240.0,
    'tbY': -260.0,
    'tbW': 160.0,
    'tbH': 140.0,
    't5X': 240.0,
    't5Y': -290.0,
    't9X': 240.0,
    't9Y': -220.0,
    'c1X': -150.0,
    'c1Y': -75.0,
    'c1W': 300.0,
    'c1H': 50.0,
    'kid1Y': 10.0,
    'c2X': -150.0,
    'c2Y': 110.0,
    'c2W': 300.0,
    'c2H': 50.0,
    'kid2Y': 195.0,
  };
  static const s3 = {
    'matX': -120.0,
    'matY': -220.0,
    'matW': 300.0,
    'matH': 180.0,
    'tbX': 220.0,
    'tbY': -220.0,
    'tbW': 160.0,
    'tbH': 180.0,
    't6X': 220.0,
    't6Y': -260.0,
    't3X': 220.0,
    't3Y': -160.0,
    'chX': 0.0,
    'chY': 60.0,
    'chR': 120.0,
    'btnX': 0.0,
    'btnY': -80.0,
  };
  static const s4 = {
    'tbX': 0.0,
    'tbY': -280.0,
    'tbW': 240.0,
    'tbH': 80.0,
    't3X': -60.0,
    't3Y': -280.0,
    't5X': 60.0,
    't5Y': -280.0,
    'g1X': -150.0,
    'g1Y': -100.0,
    'g2X': 150.0,
    'g2Y': -100.0,
    'gR': 60.0,
    'scX': 0.0,
    'scY': 150.0,
    'pL': -150.0,
    'pR': 150.0,
  };
  static const s5 = {
    'bagX': 0.0,
    'bagY': -150.0,
    'bagW': 160.0,
    'bagH': 180.0,
    'scX': -140.0,
    'scY': -150.0,
    'btnX': 0.0,
    'btnY': 240.0,
    'pX': <double>[-255.0, -85.0, 85.0, 255.0],
    'pY': 120.0,
  };
}

// --- MAIN SCREEN ---
class Cl6M_Ch7_A1_TheGreatRotiShareOff extends StatefulWidget {
  const Cl6M_Ch7_A1_TheGreatRotiShareOff({super.key});

  @override
  State<Cl6M_Ch7_A1_TheGreatRotiShareOff> createState() =>
      _Cl6M_Ch7_A1_TheGreatRotiShareOffState();
}

class _Cl6M_Ch7_A1_TheGreatRotiShareOffState
    extends State<Cl6M_Ch7_A1_TheGreatRotiShareOff>
    with SingleTickerProviderStateMixin {
  bool isCurtainOpen = false;
  bool isSidebarOpen = true;
  double sidebarWidth = 350.0;
  bool showSuccess = false;

  late AnimationController _gameLoop;
  final GlobalKey _canvasKey = GlobalKey();

  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/click.mp3'));
  }

  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/science/page_open.mp3'));
  }

  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource('audio/class6/science/dropdown.mp3'),
    );
  }

  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(AssetSource('audio/class6/science/error.mp3'));
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(AssetSource('audio/class6/math/shutter.mp3'));
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitScreen();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gameLoop.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    super.dispose();
  }

  String t(String key) => TRANSLATIONS[state.lang]?[key] ?? key;

  void _fitScreen() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    double canvasW = size.width - (isSidebarOpen ? sidebarWidth : 0);
    double canvasH = size.height;
    setState(() {
      state.zoom = math.max(
        0.3,
        math.min(2.0, math.min((canvasW - 40) / 750, (canvasH - 160) / 800)),
      );
      state.panX = 0;
      state.panY = 0;
    });
  }

  // --- HIT TESTING HELPERS ---
  Offset _getWorldPoint(Offset localFocal) {
    RenderBox box = _canvasKey.currentContext?.findRenderObject() as RenderBox;
    final size = box.size;
    double worldX = (localFocal.dx - size.width / 2 - state.panX) / state.zoom;
    double worldY = (localFocal.dy - size.height / 2 - state.panY) / state.zoom;
    return Offset(worldX, worldY);
  }

  bool _hitBox(double x, double y, double w, double h, Offset pt) =>
      pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;

  bool _hitCircle(double cx, double cy, double r, Offset pt) {
    double dx = pt.dx - cx;
    double dy = pt.dy - cy;
    return (dx * dx + dy * dy) <= r * r;
  }

  void _advanceStep() {
    state.step++;
    if (state.step == state.maxSteps) {
      if (state.scenario == 5) {
        showSuccess = true;
      }
    }
  }

  void _checkSuccess() {
    setState(() {
      state.step = state.maxSteps;
      showSuccess = true;
    });
    playPageOpen();
  }

  // --- GESTURE HANDLING ---
  double _startZoom = 1.0;

  void _handleTouchDown(Offset localPosition) {
    if (state.activeDrag != null) return;
    Offset pt = _getWorldPoint(localPosition);
    bool handled = false;

    setState(() {
      if (state.scenario == 1) {
        final L = Layouts.s1;
        if (!state.s1c1 &&
            _hitCircle(L['t2X'] as double, L['t2Y'] as double, 35, pt)) {
          state.activeDrag = 'tool2';
          state.dragX = pt.dx;
          state.dragY = pt.dy;
          handled = true;
        } else if (state.step >= 3 &&
            !state.s1c2 &&
            _hitCircle(L['t4X'] as double, L['t4Y'] as double, 35, pt)) {
          state.activeDrag = 'tool4';
          state.dragX = pt.dx;
          state.dragY = pt.dy;
          handled = true;
        } else if (state.s1btnSliceR1 &&
            _hitBox(
              (L['btn1X'] as double) - 40,
              (L['btn1Y'] as double) - 20,
              80,
              40,
              pt,
            )) {
          state.s1r1 = true;
          state.s1btnSliceR1 = false;
          handled = true;
          _advanceStep();
        } else if (state.s1btnSliceR2 &&
            _hitBox(
              (L['btn2X'] as double) - 40,
              (L['btn2Y'] as double) - 20,
              80,
              40,
              pt,
            )) {
          state.s1r2 = true;
          state.s1btnSliceR2 = false;
          handled = true;
        }

        if (!handled && state.s1r1) {
          if (!state.s1p2[0] &&
              _hitCircle(L['r1X'] as double, L['r1Y'] as double, 70, pt)) {
            state.activeDrag = 'r1_0';
            state.dragX = pt.dx;
            state.dragY = pt.dy;
            handled = true;
          } else if (!state.s1p2[1] &&
              _hitCircle(L['r1X'] as double, L['r1Y'] as double, 70, pt)) {
            state.activeDrag = 'r1_1';
            state.dragX = pt.dx;
            state.dragY = pt.dy;
            handled = true;
          } else if (state.step >= 5 &&
              state.s1p2[0] &&
              !state.s1comp[0] &&
              _hitCircle(L['p2L'] as double, L['pY'] as double, 60, pt)) {
            state.activeDrag = 'r1_0';
            state.dragX = pt.dx;
            state.dragY = pt.dy;
            handled = true;
          } else if (state.step >= 5 &&
              state.s1p2[1] &&
              !state.s1comp[0] &&
              _hitCircle(L['p2R'] as double, L['pY'] as double, 60, pt)) {
            state.activeDrag = 'r1_1';
            state.dragX = pt.dx;
            state.dragY = pt.dy;
            handled = true;
          }
        }

        if (!handled && state.s1r2) {
          for (int i = 0; i < 4; i++) {
            if (!state.s1p4[i] &&
                _hitCircle(L['r2X'] as double, L['r2Y'] as double, 70, pt)) {
              state.activeDrag = 'r2_$i';
              state.dragX = pt.dx;
              state.dragY = pt.dy;
              handled = true;
              break;
            } else if (state.step >= 5 &&
                state.s1p4[i] &&
                !state.s1comp[1] &&
                _hitCircle(
                  (L['p4Arr'] as List<double>)[i],
                  L['pY'] as double,
                  50,
                  pt,
                )) {
              state.activeDrag = 'r2_$i';
              state.dragX = pt.dx;
              state.dragY = pt.dy;
              handled = true;
              break;
            }
          }
        }
      } else if (state.scenario == 2) {
        final L = Layouts.s2;
        double c1X = L['c1X'] as double,
            c1Y = L['c1Y'] as double,
            c1W = L['c1W'] as double,
            c1H = L['c1H'] as double;
        double c2X = L['c2X'] as double,
            c2Y = L['c2Y'] as double,
            c2W = L['c2W'] as double,
            c2H = L['c2H'] as double;

        if (!state.s2g1 &&
            _hitBox(
              (L['t5X'] as double) - 40,
              (L['t5Y'] as double) - 25,
              80,
              50,
              pt,
            )) {
          state.activeDrag = 'guide5';
          state.dragX = pt.dx;
          state.dragY = pt.dy;
          handled = true;
        } else if (state.step >= 3 &&
            !state.s2g2 &&
            _hitBox(
              (L['t9X'] as double) - 40,
              (L['t9Y'] as double) - 25,
              80,
              50,
              pt,
            )) {
          state.activeDrag = 'guide9';
          state.dragX = pt.dx;
          state.dragY = pt.dy;
          handled = true;
        } else if (state.s2g1 &&
            !state.s2b1 &&
            pt.dy > c1Y &&
            pt.dy < c1Y + c1H) {
          for (int i = 0; i < 4; i++) {
            if ((pt.dx - (c1X + (i + 1) * c1W / 5)).abs() < 20) {
              state.s2l1[i] = true;
              handled = true;
            }
          }
          if (state.s2l1.every((v) => v)) {
            state.s2b1 = true;
            _advanceStep();
          }
        } else if (state.s2g2 &&
            !state.s2b2 &&
            pt.dy > c2Y &&
            pt.dy < c2Y + c2H) {
          for (int i = 0; i < 8; i++) {
            if ((pt.dx - (c2X + (i + 1) * c2W / 9)).abs() < 15) {
              state.s2l2[i] = true;
              handled = true;
            }
          }
          if (state.s2l2.every((v) => v)) {
            state.s2b2 = true;
            _advanceStep();
          }
        }

        if (state.step >= 5) {
          if (!state.s2comp[0] && state.activeDrag == null) {
            for (int i = 0; i < 5; i++) {
              if (_hitBox(
                c1X + 20 + i * (c1W / 5),
                (L['kid1Y'] as double) + 35,
                c1W / 5 - 4,
                c1H,
                pt,
              )) {
                state.activeDrag = 'c1_p';
                state.dragX = pt.dx;
                state.dragY = pt.dy;
                state.s2k5--;
                handled = true;
                break;
              }
            }
          }
          if (!state.s2comp[1] && state.activeDrag == null) {
            for (int i = 0; i < 9; i++) {
              if (_hitBox(
                c2X + 5 + i * (c2W / 9),
                (L['kid2Y'] as double) + 25,
                c2W / 9 - 2,
                c2H,
                pt,
              )) {
                state.activeDrag = 'c2_p';
                state.dragX = pt.dx;
                state.dragY = pt.dy;
                state.s2k9--;
                handled = true;
                break;
              }
            }
          }
        }
        if (state.activeDrag == null) {
          if (state.s2b1 && state.s2k5 < 5 && _hitBox(c1X, c1Y, c1W, c1H, pt)) {
            state.activeDrag = 'c1_p';
            state.dragX = pt.dx;
            state.dragY = pt.dy;
            handled = true;
          }
          if (state.s2b2 && state.s2k9 < 9 && _hitBox(c2X, c2Y, c2W, c2H, pt)) {
            state.activeDrag = 'c2_p';
            state.dragX = pt.dx;
            state.dragY = pt.dy;
            handled = true;
          }
        }
      } else if (state.scenario == 3) {
        final L = Layouts.s3;
        double chX = L['chX'] as double,
            chY = L['chY'] as double,
            chR = L['chR'] as double;
        if (!state.s3st1 &&
            _hitCircle(L['t6X'] as double, L['t6Y'] as double, 40, pt)) {
          state.activeDrag = 'stamp6';
          state.dragX = pt.dx;
          state.dragY = pt.dy;
          handled = true;
        } else if (!state.s3st2 &&
            _hitCircle(L['t3X'] as double, L['t3Y'] as double, 40, pt)) {
          state.activeDrag = 'stamp3';
          state.dragX = pt.dx;
          state.dragY = pt.dy;
          handled = true;
        } else if (state.s3btnStamp1 &&
            _hitBox(
              (L['btnX'] as double) - 40,
              (L['btnY'] as double) - 20,
              80,
              40,
              pt,
            )) {
          state.s3stamped1 = true;
          state.s3btnStamp1 = false;
          handled = true;
          _advanceStep();
        } else if (state.s3btnStamp2 &&
            _hitBox(
              (L['btnX'] as double) - 40,
              (L['btnY'] as double) - 20,
              80,
              40,
              pt,
            )) {
          state.s3stamped2 = true;
          state.s3btnStamp2 = false;
          handled = true;
        } else if (state.s3stamped1 &&
            !state.s3p1 &&
            _hitCircle(chX, chY, chR, pt)) {
          state.activeDrag = 'piece6';
          state.dragX = pt.dx;
          state.dragY = pt.dy;
          handled = true;
        } else if (state.s3stamped2 &&
            !state.s3p2 &&
            _hitCircle(chX, chY, chR, pt)) {
          state.activeDrag = 'piece3';
          state.dragX = pt.dx;
          state.dragY = pt.dy;
          handled = true;
        }
      } else if (state.scenario == 4) {
        final L = Layouts.s4;
        if (!state.s4c3 &&
            _hitCircle(L['t3X'] as double, L['t3Y'] as double, 30, pt)) {
          state.activeDrag = 'gcut3';
          state.dragX = pt.dx;
          state.dragY = pt.dy;
          handled = true;
        } else if (!state.s4c5 &&
            _hitCircle(
              (L['tbX'] as double) + (L['t5X'] as double),
              (L['tbY'] as double) + 40,
              30,
              pt,
            )) {
          state.activeDrag = 'gcut5';
          state.dragX = pt.dx;
          state.dragY = pt.dy;
          handled = true;
        } else if (state.s4c3 &&
            state.s4sL != 3 &&
            _hitBox(
              (L['g1X'] as double) - 60,
              (L['g1Y'] as double) - 60,
              120,
              120,
              pt,
            )) {
          state.activeDrag = 'p3';
          state.dragX = pt.dx;
          state.dragY = pt.dy;
          handled = true;
        } else if (state.s4c5 &&
            state.s4sR != 5 &&
            _hitBox(
              (L['g2X'] as double) - 60,
              (L['g2Y'] as double) - 60,
              120,
              120,
              pt,
            )) {
          state.activeDrag = 'p5';
          state.dragX = pt.dx;
          state.dragY = pt.dy;
          handled = true;
        }
      } else if (state.scenario == 5) {
        final L = Layouts.s5;
        if (_hitCircle(L['scX'] as double, L['scY'] as double, 35, pt)) {
          state.activeDrag = 'scoop';
          state.dragX = pt.dx;
          state.dragY = pt.dy;
          state.s5scoopSrc = -1;
          handled = true;
        }
        for (int i = 0; i < 4; i++) {
          if (_hitBox(
                (L['pX'] as List<double>)[i] - 35,
                (L['pY'] as double) - 100,
                70,
                110,
                pt,
              ) &&
              state.s5p[i] >= 50) {
            state.activeDrag = 'scoop';
            state.dragX = pt.dx;
            state.dragY = pt.dy;
            state.s5scoopSrc = i;
            state.s5scoop = 50;
            state.s5p[i] -= 50;
            handled = true;
          }
        }
        bool allEq = state.s5p.every((x) => x == 250);
        if (state.step == 3 &&
            allEq &&
            _hitBox(
              (L['btnX'] as double) - 80,
              (L['btnY'] as double) - 25,
              160,
              50,
              pt,
            )) {
          handled = true;
          _advanceStep();
          Future.delayed(const Duration(seconds: 1), _checkSuccess);
        }
      }
    });

    if (handled) playClick();
  }

  void _handleProcessDrop() {
    setState(() {
      Offset pt = Offset(state.dragX, state.dragY);
      bool handled = false;

      if (state.scenario == 1) {
        final L = Layouts.s1;
        if (state.activeDrag == 'tool2' &&
            _hitBox(
              (L['r1X'] as double) - 90,
              (L['r1Y'] as double) - 90,
              180,
              180,
              pt,
            )) {
          state.s1c1 = true;
          handled = true;
          _advanceStep();
        } else if (state.activeDrag == 'tool4' &&
            _hitBox(
              (L['r2X'] as double) - 90,
              (L['r2Y'] as double) - 90,
              180,
              180,
              pt,
            )) {
          state.s1c2 = true;
          handled = true;
          _advanceStep();
        } else if (state.activeDrag == 'r1_0' || state.activeDrag == 'r1_1') {
          int idx = state.activeDrag == 'r1_0' ? 0 : 1;
          if (!state.s1p2[0] &&
              _hitCircle(L['p2L'] as double, L['pY'] as double, 60, pt)) {
            state.s1p2[0] = true;
            handled = true;
            if (state.s1p2[0] && state.s1p2[1] && state.step == 2)
              _advanceStep();
          } else if (!state.s1p2[1] &&
              _hitCircle(L['p2R'] as double, L['pY'] as double, 60, pt)) {
            state.s1p2[1] = true;
            handled = true;
            if (state.s1p2[0] && state.s1p2[1] && state.step == 2)
              _advanceStep();
          } else if (state.step == 5 &&
              !state.s1comp[0] &&
              _hitBox(
                (L['matX'] as double) - (L['matW'] as double) / 2,
                L['matY'] as double,
                L['matW'] as double,
                L['matH'] as double,
                pt,
              )) {
            state.s1comp[0] = true;
            state.s1p2[idx] = false;
            handled = true;
            if (state.s1comp[0] && state.s1comp[1]) {
              _advanceStep();
              Future.delayed(const Duration(seconds: 1), _checkSuccess);
            }
          }
        } else if (state.activeDrag!.startsWith('r2_')) {
          int pIdx = int.parse(state.activeDrag!.split('_')[1]);
          for (int i = 0; i < 4; i++) {
            if (!state.s1p4[i] &&
                _hitCircle(
                  (L['p4Arr'] as List<double>)[i],
                  L['pY'] as double,
                  50,
                  pt,
                )) {
              state.s1p4[i] = true;
              handled = true;
              if (state.s1p4.every((v) => v) && state.step == 4) _advanceStep();
              break;
            }
          }
          if (!handled &&
              state.step == 5 &&
              !state.s1comp[1] &&
              _hitBox(
                (L['matX'] as double) - (L['matW'] as double) / 2,
                L['matY'] as double,
                L['matW'] as double,
                L['matH'] as double,
                pt,
              )) {
            state.s1comp[1] = true;
            state.s1p4[pIdx] = false;
            handled = true;
            if (state.s1comp[0] && state.s1comp[1]) {
              _advanceStep();
              Future.delayed(const Duration(seconds: 1), _checkSuccess);
            }
          }
        }
      } else if (state.scenario == 2) {
        final L = Layouts.s2;
        if (state.activeDrag == 'guide5' &&
            _hitBox(
              L['c1X'] as double,
              L['c1Y'] as double,
              L['c1W'] as double,
              L['c1H'] as double,
              pt,
            )) {
          state.s2g1 = true;
          handled = true;
          _advanceStep();
        } else if (state.activeDrag == 'guide9' &&
            _hitBox(
              L['c2X'] as double,
              L['c2Y'] as double,
              L['c2W'] as double,
              L['c2H'] as double,
              pt,
            )) {
          state.s2g2 = true;
          handled = true;
          _advanceStep();
        } else if (state.activeDrag == 'c1_p') {
          if (state.step < 5 &&
              state.s2k5 < 5 &&
              _hitBox(
                L['c1X'] as double,
                L['kid1Y'] as double,
                L['c1W'] as double,
                100,
                pt,
              )) {
            state.s2k5++;
            handled = true;
            if (state.s2k5 == 5) _advanceStep();
          } else if (state.step >= 5 &&
              !state.s2comp[0] &&
              _hitBox(
                (L['matX'] as double) - (L['matW'] as double) / 2,
                L['matY'] as double,
                L['matW'] as double,
                L['matH'] as double,
                pt,
              )) {
            state.s2comp[0] = true;
            handled = true;
            if (state.s2comp[0] && state.s2comp[1]) {
              _advanceStep();
              Future.delayed(const Duration(seconds: 1), _checkSuccess);
            }
          } else {
            if (state.step >= 5) state.s2k5++;
          }
        } else if (state.activeDrag == 'c2_p') {
          if (state.step < 5 &&
              state.s2k9 < 9 &&
              _hitBox(
                L['c2X'] as double,
                L['kid2Y'] as double,
                L['c2W'] as double,
                100,
                pt,
              )) {
            state.s2k9++;
            handled = true;
            if (state.s2k9 == 9) _advanceStep();
          } else if (state.step >= 5 &&
              !state.s2comp[1] &&
              _hitBox(
                (L['matX'] as double) - (L['matW'] as double) / 2,
                L['matY'] as double,
                L['matW'] as double,
                L['matH'] as double,
                pt,
              )) {
            state.s2comp[1] = true;
            handled = true;
            if (state.s2comp[0] && state.s2comp[1]) {
              _advanceStep();
              Future.delayed(const Duration(seconds: 1), _checkSuccess);
            }
          } else {
            if (state.step >= 5) state.s2k9++;
          }
        }
      } else if (state.scenario == 3) {
        final L = Layouts.s3;
        if (state.activeDrag == 'stamp6' &&
            _hitCircle(
              L['chX'] as double,
              L['chY'] as double,
              L['chR'] as double,
              pt,
            )) {
          state.s3st1 = true;
          handled = true;
          _advanceStep();
        } else if (state.activeDrag == 'stamp3' &&
            _hitCircle(
              L['chX'] as double,
              L['chY'] as double,
              L['chR'] as double,
              pt,
            )) {
          state.s3st2 = true;
          handled = true;
        } else if (state.activeDrag == 'piece6' &&
            _hitBox(
              (L['matX'] as double) - (L['matW'] as double) / 2,
              L['matY'] as double,
              (L['matW'] as double) / 2,
              L['matH'] as double,
              pt,
            )) {
          state.s3p1 = true;
          handled = true;
          _advanceStep();
        } else if (state.activeDrag == 'piece3' &&
            _hitBox(
              L['matX'] as double,
              L['matY'] as double,
              (L['matW'] as double) / 2,
              L['matH'] as double,
              pt,
            )) {
          state.s3p2 = true;
          handled = true;
          _advanceStep();
          Future.delayed(const Duration(seconds: 1), _checkSuccess);
        }
      } else if (state.scenario == 4) {
        final L = Layouts.s4;
        if (state.activeDrag == 'gcut3' &&
            _hitBox(
              (L['g1X'] as double) - 60,
              (L['g1Y'] as double) - 60,
              120,
              120,
              pt,
            )) {
          state.s4c3 = true;
          handled = true;
          _advanceStep();
        } else if (state.activeDrag == 'gcut5' &&
            _hitBox(
              (L['g2X'] as double) - 60,
              (L['g2Y'] as double) - 60,
              120,
              120,
              pt,
            )) {
          state.s4c5 = true;
          handled = true;
          _advanceStep();
        } else if (state.activeDrag == 'p3' &&
            _hitBox(
              (L['scX'] as double) - 150,
              (L['scY'] as double) - 100,
              150,
              200,
              pt,
            )) {
          state.s4sL = 3;
          handled = true;
          _advanceStep();
        } else if (state.activeDrag == 'p5' &&
            _hitBox(
              (L['scX'] as double),
              (L['scY'] as double) - 100,
              150,
              200,
              pt,
            )) {
          state.s4sR = 5;
          handled = true;
          _advanceStep();
          Future.delayed(const Duration(seconds: 1), _checkSuccess);
        }
      } else if (state.scenario == 5) {
        final L = Layouts.s5;
        if (state.activeDrag == 'scoop') {
          if (_hitBox(
                (L['bagX'] as double) - (L['bagW'] as double) / 2,
                (L['bagY'] as double) - (L['bagH'] as double) / 2,
                L['bagW'] as double,
                L['bagH'] as double,
                pt,
              ) &&
              state.s5scoop == 0 &&
              state.s5bag >= 50) {
            state.s5scoop = 50;
            state.s5bag -= 50;
            handled = true;
          } else if (state.s5scoop > 0) {
            for (int i = 0; i < 4; i++) {
              if (_hitBox(
                (L['pX'] as List<double>)[i] - 45,
                (L['pY'] as double) - 110,
                90,
                130,
                pt,
              )) {
                state.s5p[i] += state.s5scoop;
                state.s5scoop = 0;
                handled = true;
                if (state.step == 0) _advanceStep();
                break;
              }
            }
          }
          if (!handled && state.s5scoop > 0) {
            if (state.s5scoopSrc == -1)
              state.s5bag += state.s5scoop;
            else
              state.s5p[state.s5scoopSrc] += state.s5scoop;
            state.s5scoop = 0;
          }
          if (state.s5bag == 0 && state.step == 1) _advanceStep();
          bool allEq = state.s5p.every((x) => x == 250);
          if (allEq && state.s5bag == 0 && state.step == 2) _advanceStep();
        }
      }

      if (handled)
        playClick();
      else
        playError();

      state.activeDrag = null;
    });
  }

  void _loadScenario(int id) {
    setState(() {
      state.scenario = id;
      state.resetScenario();
      showSuccess = false;
      _fitScreen();
    });
    playPageOpen();
  }

  // --- UI BUILDING ---
  @override
  Widget build(BuildContext context) {
    if (!isCurtainOpen) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pie_chart, size: 80, color: Colors.indigo.shade400),
                const SizedBox(height: 20),
                Text(
                  t('shutterTitle'),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  t('appSubtitle'),
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    curtainScreen();
                    setState(() {
                      isCurtainOpen = true;
                    });
                  },
                  icon: const Icon(Icons.play_circle_fill),
                  label: Text(
                    t('enterLab'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    backgroundColor: Colors.indigo.shade500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    String currentObjective = t('s${state.scenario}_obj');
    String? hudText = t('s${state.scenario}_h${state.step + 1}');
    if (state.step >= state.maxSteps) hudText = null;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // CANVAS AREA
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: GestureDetector(
                onTapDown: (details) => _handleTouchDown(details.localPosition),
                onTapUp: (details) {
                  if (state.activeDrag != null) {
                    _handleProcessDrop();
                  }
                },
                // IMPORTANT: onTapCancel is intentionally absent.
                // Do not re-add onTapCancel, as it destroys the active drag state
                // the moment a finger moves and the Scale gesture begins.
                onScaleStart: (details) {
                  _startZoom = state.zoom;
                  _handleTouchDown(details.localFocalPoint);
                },
                onScaleUpdate: (details) {
                  if (state.activeDrag != null) {
                    Offset pt = _getWorldPoint(details.localFocalPoint);
                    setState(() {
                      state.dragX = pt.dx;
                      state.dragY = pt.dy;
                    });
                  } else {
                    setState(() {
                      if (details.scale != 1.0) {
                        state.zoom = (_startZoom * details.scale).clamp(
                          0.3,
                          3.0,
                        );
                      }
                      state.panX += details.focalPointDelta.dx;
                      state.panY += details.focalPointDelta.dy;
                    });
                  }
                },
                onScaleEnd: (details) {
                  if (state.activeDrag != null) {
                    _handleProcessDrop();
                  }
                },
                child: AnimatedBuilder(
                  animation: _gameLoop,
                  builder: (context, _) {
                    return CustomPaint(
                      key: _canvasKey,
                      painter: LabPainter(state),
                      child: Container(),
                    );
                  },
                ),
              ),
            ),

            // HUD
            if (hudText != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                bottom: 30,
                left: isSidebarOpen ? sidebarWidth + 20 : 20,
                right: 20,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border(
                        top: BorderSide(
                          color: Colors.indigo.shade500,
                          width: 4,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.indigo.shade400,
                          size: 28,
                        ),
                        const SizedBox(width: 15),
                        Flexible(
                          child: Text(
                            hudText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    if (isSidebarOpen)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.pie_chart,
                            color: Colors.indigo.shade400,
                            size: 40,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t('shutterTitle'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t('appSubtitle'),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        playClick();
                                        setState(() {
                                          state.lang = state.lang == 'en'
                                              ? 'hi'
                                              : 'en';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey.shade700,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.language,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              state.lang.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () {
                                        playPageOpen();
                                        state.resetAll();
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade900
                                              .withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.refresh,
                                              size: 16,
                                              color: Colors.redAccent,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              "Reset",
                                              style: const TextStyle(
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade800,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueGrey.shade600),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            dropdownColor: Colors.blueGrey.shade800,
                            value: state.scenario,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            items: [1, 2, 3, 4, 5]
                                .map(
                                  (i) => DropdownMenuItem(
                                    value: i,
                                    child: Text(t('s${i}_title')),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              playDropdown();
                              _loadScenario(v!);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Objective
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade800.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blueGrey.shade700),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.track_changes,
                                  color: Colors.pink.shade500,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  t('learnLbl'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentObjective,
                              style: TextStyle(
                                color: Colors.blueGrey.shade300,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Steps
                      ...List.generate(state.maxSteps, (i) {
                        bool active = i == state.step;
                        bool past = i < state.step;
                        Color bg = active
                            ? Colors.indigo.shade500.withOpacity(0.2)
                            : (past
                                  ? Colors.green.shade900.withOpacity(0.3)
                                  : Colors.blueGrey.shade800.withOpacity(0.3));
                        Color border = active
                            ? Colors.indigo.shade400
                            : (past
                                  ? Colors.green.shade800
                                  : Colors.blueGrey.shade700);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              past
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Colors.green.shade500,
                                    )
                                  : CircleAvatar(
                                      radius: 12,
                                      backgroundColor: active
                                          ? Colors.indigo.shade500
                                          : Colors.blueGrey.shade700,
                                      child: Text(
                                        '${i + 1}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${t('stepLabel')} ${i + 1}',
                                      style: TextStyle(
                                        color: Colors.blueGrey.shade500,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      t('s${state.scenario}_s${i + 1}_t'),
                                      style: TextStyle(
                                        color: active
                                            ? Colors.indigo.shade300
                                            : (past
                                                  ? Colors.blueGrey.shade400
                                                  : Colors.blueGrey.shade600),
                                        fontSize: 13,
                                        fontWeight: active
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    if (past) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade900
                                              .withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          t('s${state.scenario}_s${i + 1}_o'),
                                          style: TextStyle(
                                            color: Colors.green.shade200,
                                            fontSize: 12,
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

                      const SizedBox(height: 40),

                      // Footer
                      const Center(
                        child: Text(
                          '© ZeroScienceLab - Fall in love with math and Science',
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),

            // SIDEBAR RESIZER
            if (isSidebarOpen)
              Positioned(
                top: 0,
                bottom: 0,
                left: sidebarWidth - 5,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (d) {
                    setState(() {
                      sidebarWidth += d.delta.dx;
                      sidebarWidth = math.max(
                        300,
                        math.min(
                          sidebarWidth,
                          MediaQuery.of(context).size.width * 0.5,
                        ),
                      );
                      _fitScreen();
                    });
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: Container(width: 10, color: Colors.transparent),
                  ),
                ),
              ),

            // MENU BUTTON
            Positioned(
              top: 15,
              left: 15,
              child: InkWell(
                onTap: () {
                  playDropdown();
                  setState(() {
                    isSidebarOpen = !isSidebarOpen;
                    _fitScreen();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade800,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueGrey.shade600),
                  ),
                  child: Icon(
                    isSidebarOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // SUCCESS POPUP
            if (showSuccess)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: Container(
                      width: 400,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade800,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueGrey.shade600),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flag_circle,
                            color: Colors.green.shade400,
                            size: 80,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            t('summaryTitle'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            t('finalDesc'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.green.shade300,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: () {
                              playPageOpen();
                              if (state.scenario < 5)
                                _loadScenario(state.scenario + 1);
                              else
                                setState(() {
                                  showSuccess = false;
                                  isCurtainOpen = false;
                                });
                            },
                            icon: Icon(
                              state.scenario < 5
                                  ? Icons.arrow_forward
                                  : Icons.home,
                            ),
                            label: Text(
                              state.scenario < 5
                                  ? t('nextScenario')
                                  : t('finishLab'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.scenario < 5
                                  ? Colors.indigo.shade500
                                  : Colors.amber.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
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
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER ---
class LabPainter extends CustomPainter {
  final SimState s;
  LabPainter(this.s);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + s.panX, size.height / 2 + s.panY);
    canvas.scale(s.zoom, s.zoom);

    if (s.scenario == 1)
      _renderS1(canvas);
    else if (s.scenario == 2)
      _renderS2(canvas);
    else if (s.scenario == 3)
      _renderS3(canvas);
    else if (s.scenario == 4)
      _renderS4(canvas);
    else if (s.scenario == 5)
      _renderS5(canvas);

    canvas.restore();
  }

  void _renderS1(Canvas canvas) {
    final L = Layouts.s1;

    _drawRoundedRect(
      canvas,
      (L['matX'] as double) - (L['matW'] as double) / 2,
      L['matY'] as double,
      L['matW'] as double,
      L['matH'] as double,
      12,
      const Color(0xFFCBD5E1),
      const Color(0xFF0F172A),
      4,
    );
    _drawText(
      canvas,
      TRANSLATIONS[s.lang]!['lbl_comp_mat']!,
      L['matX'] as double,
      (L['matY'] as double) + 25,
      18,
      Colors.black,
      false,
    );

    _drawDashedRect(
      canvas,
      (L['matX'] as double) - 100,
      (L['matY'] as double) + 50,
      80,
      50,
      8,
    );
    _drawDashedRect(
      canvas,
      (L['matX'] as double) + 20,
      (L['matY'] as double) + 50,
      80,
      50,
      8,
    );

    if (s.s1comp[0]) {
      _drawRotiPiece(
        canvas,
        (L['matX'] as double) - 60,
        (L['matY'] as double) + 75,
        60,
        math.pi,
        math.pi * 2,
      );
      _drawText(
        canvas,
        "1/2",
        (L['matX'] as double) - 60,
        (L['matY'] as double) + 30,
        16,
        Colors.redAccent,
        true,
      );
    }
    if (s.s1comp[1]) {
      _drawRotiPiece(
        canvas,
        (L['matX'] as double) + 60,
        (L['matY'] as double) + 75,
        60,
        math.pi,
        math.pi * 1.5,
      );
      _drawText(
        canvas,
        "1/4",
        (L['matX'] as double) + 60,
        (L['matY'] as double) + 30,
        16,
        Colors.redAccent,
        true,
      );
    }

    _drawRoundedRect(
      canvas,
      (L['tbX'] as double) - (L['tbW'] as double) / 2,
      (L['tbY'] as double) - (L['tbH'] as double) / 2,
      L['tbW'] as double,
      L['tbH'] as double,
      8,
      const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      4,
    );
    _drawText(
      canvas,
      TRANSLATIONS[s.lang]!['lbl_toolbox']!,
      L['tbX'] as double,
      (L['tbY'] as double) - (L['tbH'] as double) / 2 + 20,
      16,
      Colors.white,
      true,
    );

    void drawSlicer(double cx, double cy, String lbl) {
      _drawCircle(
        canvas,
        cx,
        cy,
        25,
        Colors.indigo,
        const Color(0xFF0F172A),
        3,
      );
      _drawText(canvas, lbl, cx, cy, 20, Colors.white, true);
    }

    if (!s.s1c1 && s.activeDrag != 'tool2')
      drawSlicer(L['t2X'] as double, L['t2Y'] as double, "2");
    if (!s.s1c2 && s.step >= 3 && s.activeDrag != 'tool4')
      drawSlicer(L['t4X'] as double, L['t4Y'] as double, "4");

    _drawWoodBoard(
      canvas,
      (L['r1X'] as double) - 90,
      (L['r1Y'] as double) - 90,
      180,
      180,
      10,
    );
    if (!s.s1r1) {
      _drawRotiPiece(
        canvas,
        L['r1X'] as double,
        L['r1Y'] as double,
        70,
        0,
        math.pi * 2,
      );
      if (s.s1c1) {
        _drawDashedLine(
          canvas,
          Offset((L['r1X'] as double) - 70, L['r1Y'] as double),
          Offset((L['r1X'] as double) + 70, L['r1Y'] as double),
          Colors.redAccent,
          4,
        );
        s.s1btnSliceR1 = true;
      }
    } else {
      if (!s.s1p2[0] && s.activeDrag != 'r1_0')
        _drawRotiPiece(
          canvas,
          L['r1X'] as double,
          (L['r1Y'] as double) - 5,
          70,
          math.pi,
          math.pi * 2,
        );
      if (!s.s1p2[1] && s.activeDrag != 'r1_1' && !s.s1comp[0])
        _drawRotiPiece(
          canvas,
          L['r1X'] as double,
          (L['r1Y'] as double) + 5,
          70,
          0,
          math.pi,
        );
    }

    _drawPlate(canvas, L['p2L'] as double, L['pY'] as double, 50);
    _drawPlate(canvas, L['p2R'] as double, L['pY'] as double, 50);
    if (s.s1p2[0]) {
      _drawRotiPiece(
        canvas,
        L['p2L'] as double,
        (L['pY'] as double) + 10,
        50,
        math.pi,
        math.pi * 2,
      );
      _drawText(
        canvas,
        "1/2",
        L['p2L'] as double,
        (L['pY'] as double) - 50,
        16,
        Colors.redAccent,
        true,
      );
    }
    if (s.s1p2[1] && !s.s1comp[0]) {
      _drawRotiPiece(
        canvas,
        L['p2R'] as double,
        (L['pY'] as double) - 10,
        50,
        0,
        math.pi,
      );
      _drawText(
        canvas,
        "1/2",
        L['p2R'] as double,
        (L['pY'] as double) + 50,
        16,
        Colors.redAccent,
        true,
      );
    }

    if (s.s1btnSliceR1 && !s.s1r1)
      _drawButton(
        canvas,
        TRANSLATIONS[s.lang]!['lbl_slice']!,
        L['btn1X'] as double,
        L['btn1Y'] as double,
        80,
        40,
        Colors.redAccent,
        true,
      );

    if (s.step >= 3) {
      _drawWoodBoard(
        canvas,
        (L['r2X'] as double) - 90,
        (L['r2Y'] as double) - 90,
        180,
        180,
        10,
      );
      if (!s.s1r2) {
        _drawRotiPiece(
          canvas,
          L['r2X'] as double,
          L['r2Y'] as double,
          70,
          0,
          math.pi * 2,
        );
        if (s.s1c2) {
          _drawDashedLine(
            canvas,
            Offset((L['r2X'] as double) - 70, L['r2Y'] as double),
            Offset((L['r2X'] as double) + 70, L['r2Y'] as double),
            Colors.redAccent,
            4,
          );
          _drawDashedLine(
            canvas,
            Offset(L['r2X'] as double, (L['r2Y'] as double) - 70),
            Offset(L['r2X'] as double, (L['r2Y'] as double) + 70),
            Colors.redAccent,
            4,
          );
          s.s1btnSliceR2 = true;
        }
      } else {
        var p = [
          {'a1': math.pi, 'a2': math.pi * 1.5, 'x': -5.0, 'y': -5.0},
          {'a1': math.pi * 1.5, 'a2': math.pi * 2, 'x': 5.0, 'y': -5.0},
          {'a1': 0.0, 'a2': math.pi * 0.5, 'x': 5.0, 'y': 5.0},
          {'a1': math.pi * 0.5, 'a2': math.pi, 'x': -5.0, 'y': 5.0},
        ];
        for (int i = 0; i < 4; i++) {
          if (!s.s1p4[i] &&
              s.activeDrag != 'r2_$i' &&
              !(i == 0 && s.s1comp[1])) {
            _drawRotiPiece(
              canvas,
              (L['r2X'] as double) + p[i]['x']!,
              (L['r2Y'] as double) + p[i]['y']!,
              70,
              p[i]['a1']!,
              p[i]['a2']!,
            );
          }
        }
      }

      for (int i = 0; i < 4; i++) {
        double px = (L['p4Arr'] as List<double>)[i];
        _drawPlate(canvas, px, L['pY'] as double, 30);
        if (s.s1p4[i] && !(i == 0 && s.s1comp[1])) {
          _drawRotiPiece(
            canvas,
            px,
            (L['pY'] as double) + 5,
            30,
            math.pi,
            math.pi * 1.5,
          );
          _drawText(
            canvas,
            "1/4",
            px,
            (L['pY'] as double) - 35,
            14,
            Colors.redAccent,
            true,
          );
        }
      }
      if (s.s1btnSliceR2 && !s.s1r2)
        _drawButton(
          canvas,
          TRANSLATIONS[s.lang]!['lbl_slice']!,
          L['btn2X'] as double,
          L['btn2Y'] as double,
          80,
          40,
          Colors.redAccent,
          true,
        );
    }

    if (s.activeDrag == 'tool2') drawSlicer(s.dragX, s.dragY, "2");
    if (s.activeDrag == 'tool4') drawSlicer(s.dragX, s.dragY, "4");
    if (s.activeDrag == 'r1_0')
      _drawRotiPiece(canvas, s.dragX, s.dragY, 70, math.pi, math.pi * 2);
    if (s.activeDrag == 'r1_1')
      _drawRotiPiece(canvas, s.dragX, s.dragY, 70, 0, math.pi);
    if (s.activeDrag != null && s.activeDrag!.startsWith('r2_')) {
      int pIdx = int.parse(s.activeDrag!.split('_')[1]);
      var p = [
        {'a1': math.pi, 'a2': math.pi * 1.5},
        {'a1': math.pi * 1.5, 'a2': math.pi * 2},
        {'a1': 0.0, 'a2': math.pi * 0.5},
        {'a1': math.pi * 0.5, 'a2': math.pi},
      ];
      _drawRotiPiece(
        canvas,
        s.dragX,
        s.dragY,
        70,
        p[pIdx]['a1']!,
        p[pIdx]['a2']!,
      );
    }
  }

  void _renderS2(Canvas canvas) {
    final L = Layouts.s2;
    double c1X = L['c1X'] as double,
        c1Y = L['c1Y'] as double,
        c1W = L['c1W'] as double,
        c1H = L['c1H'] as double;
    double c2X = L['c2X'] as double,
        c2Y = L['c2Y'] as double,
        c2W = L['c2W'] as double,
        c2H = L['c2H'] as double;

    _drawRoundedRect(
      canvas,
      (L['matX'] as double) - (L['matW'] as double) / 2,
      L['matY'] as double,
      L['matW'] as double,
      L['matH'] as double,
      12,
      const Color(0xFFCBD5E1),
      const Color(0xFF0F172A),
      4,
    );
    _drawText(
      canvas,
      TRANSLATIONS[s.lang]!['lbl_comp_mat']!,
      L['matX'] as double,
      (L['matY'] as double) + 25,
      16,
      Colors.black,
      false,
    );
    _drawDashedRect(
      canvas,
      (L['matX'] as double) - 140,
      (L['matY'] as double) + 60,
      120,
      50,
      4,
    );
    _drawDashedRect(
      canvas,
      (L['matX'] as double) + 20,
      (L['matY'] as double) + 60,
      120,
      50,
      4,
    );

    if (s.s2comp[0]) {
      _drawChikkiBar(
        canvas,
        (L['matX'] as double) - 140,
        (L['matY'] as double) + 60,
        c1W / 5 - 4,
        c1H,
      );
      _drawText(
        canvas,
        "1/5",
        (L['matX'] as double) - 80,
        (L['matY'] as double) + 130,
        14,
        Colors.redAccent,
        true,
      );
    }
    if (s.s2comp[1]) {
      _drawChikkiBar(
        canvas,
        (L['matX'] as double) + 20,
        (L['matY'] as double) + 60,
        c2W / 9 - 2,
        c2H,
      );
      _drawText(
        canvas,
        "1/9",
        (L['matX'] as double) + 80,
        (L['matY'] as double) + 130,
        14,
        Colors.redAccent,
        true,
      );
    }

    _drawRoundedRect(
      canvas,
      (L['tbX'] as double) - (L['tbW'] as double) / 2,
      (L['tbY'] as double) - (L['tbH'] as double) / 2,
      L['tbW'] as double,
      L['tbH'] as double,
      8,
      const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(
      canvas,
      TRANSLATIONS[s.lang]!['lbl_toolbox']!,
      L['tbX'] as double,
      (L['tbY'] as double) - (L['tbH'] as double) / 2 + 20,
      16,
      Colors.white,
      true,
    );

    if (!s.s2g1 && s.activeDrag != 'guide5')
      _drawDashedRect(
        canvas,
        (L['t5X'] as double) - 35,
        (L['t5Y'] as double) - 20,
        70,
        40,
        2,
      );
    if (s.step >= 3 && !s.s2g2 && s.activeDrag != 'guide9')
      _drawDashedRect(
        canvas,
        (L['t9X'] as double) - 35,
        (L['t9Y'] as double) - 20,
        70,
        40,
        2,
      );

    if (!s.s2b1)
      _drawChikkiBar(canvas, c1X, c1Y, c1W, c1H);
    else {
      for (int i = 0; i < 5; i++) {
        if (s.s2k5 <= i && s.activeDrag != 'c1_p' && !(i == 4 && s.s2comp[0]))
          _drawChikkiBar(canvas, c1X + i * (c1W / 5), c1Y, c1W / 5 - 4, c1H);
      }
    }

    if (s.s2g1 && !s.s2b1) {
      _drawRoundedRect(
        canvas,
        c1X,
        c1Y,
        c1W,
        c1H,
        4,
        Colors.white.withOpacity(0.2),
        Colors.amber,
        3,
      );
      for (int i = 1; i < 5; i++) {
        double lx = c1X + i * (c1W / 5);
        _drawDashedLine(
          canvas,
          Offset(lx, c1Y),
          Offset(lx, c1Y + c1H),
          s.s2l1[i - 1] ? Colors.green : Colors.amber,
          4,
        );
      }
    }
    for (int i = 0; i < 5; i++) {
      _drawPersonSVG(
        canvas,
        c1X + 20 + i * (c1W / 5),
        L['kid1Y'] as double,
        2.0,
      );
      if (s.s2k5 > i) {
        _drawChikkiBar(
          canvas,
          c1X + 20 + i * (c1W / 5),
          (L['kid1Y'] as double) + 35,
          c1W / 5 - 4,
          c1H,
        );
        _drawText(
          canvas,
          "1/5",
          c1X + 20 + i * (c1W / 5) + (c1W / 5) / 2,
          (L['kid1Y'] as double) + 95,
          12,
          Colors.redAccent,
          true,
        );
      }
    }

    if (s.step >= 3) {
      if (!s.s2b2)
        _drawChikkiBar(canvas, c2X, c2Y, c2W, c2H);
      else {
        for (int i = 0; i < 9; i++) {
          if (s.s2k9 <= i && s.activeDrag != 'c2_p' && !(i == 8 && s.s2comp[1]))
            _drawChikkiBar(canvas, c2X + i * (c2W / 9), c2Y, c2W / 9 - 2, c2H);
        }
      }
      if (s.s2g2 && !s.s2b2) {
        _drawRoundedRect(
          canvas,
          c2X,
          c2Y,
          c2W,
          c2H,
          4,
          Colors.white.withOpacity(0.2),
          Colors.amber,
          3,
        );
        for (int i = 1; i < 9; i++) {
          double lx = c2X + i * (c2W / 9);
          _drawDashedLine(
            canvas,
            Offset(lx, c2Y),
            Offset(lx, c2Y + c2H),
            s.s2l2[i - 1] ? Colors.green : Colors.amber,
            4,
          );
        }
      }
      for (int i = 0; i < 9; i++) {
        _drawPersonSVG(
          canvas,
          c2X + 5 + i * (c2W / 9),
          L['kid2Y'] as double,
          1.5,
        );
        if (s.s2k9 > i) {
          _drawChikkiBar(
            canvas,
            c2X + 5 + i * (c2W / 9),
            (L['kid2Y'] as double) + 25,
            c2W / 9 - 2,
            c2H,
          );
          _drawText(
            canvas,
            "1/9",
            c2X + 5 + i * (c2W / 9) + (c2W / 9) / 2,
            (L['kid2Y'] as double) + 85,
            10,
            Colors.redAccent,
            true,
          );
        }
      }
    }

    if (s.activeDrag == 'guide5')
      _drawDashedRect(canvas, s.dragX - 35, s.dragY - 20, 70, 40, 2);
    if (s.activeDrag == 'guide9')
      _drawDashedRect(canvas, s.dragX - 35, s.dragY - 20, 70, 40, 2);
    if (s.activeDrag == 'c1_p')
      _drawChikkiBar(
        canvas,
        s.dragX - c1W / 10,
        s.dragY - c1H / 2,
        c1W / 5 - 4,
        c1H,
      );
    if (s.activeDrag == 'c2_p')
      _drawChikkiBar(
        canvas,
        s.dragX - c2W / 18,
        s.dragY - c2H / 2,
        c2W / 9 - 2,
        c2H,
      );
  }

  void _renderS3(Canvas canvas) {
    final L = Layouts.s3;
    _drawRoundedRect(
      canvas,
      (L['tbX'] as double) - (L['tbW'] as double) / 2,
      (L['tbY'] as double) - (L['tbH'] as double) / 2,
      L['tbW'] as double,
      L['tbH'] as double,
      8,
      const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      4,
    );
    _drawText(
      canvas,
      TRANSLATIONS[s.lang]!['lbl_toolbox']!,
      L['tbX'] as double,
      (L['tbY'] as double) - (L['tbH'] as double) / 2 + 20,
      16,
      Colors.white,
      true,
    );

    if (!s.s3st1 && s.activeDrag != 'stamp6')
      _drawArcPiece(
        canvas,
        L['t6X'] as double,
        L['t6Y'] as double,
        30,
        0,
        math.pi / 3,
        Colors.white.withOpacity(0.7),
        const Color(0xFF0F172A),
        3,
      );
    if (!s.s3st2 && s.step >= 3 && s.activeDrag != 'stamp3')
      _drawArcPiece(
        canvas,
        L['t3X'] as double,
        L['t3Y'] as double,
        30,
        0,
        math.pi * 2 / 3,
        Colors.white.withOpacity(0.7),
        const Color(0xFF0F172A),
        3,
      );

    _drawRoundedRect(
      canvas,
      (L['matX'] as double) - (L['matW'] as double) / 2,
      L['matY'] as double,
      L['matW'] as double,
      L['matH'] as double,
      12,
      const Color(0xFFCBD5E1),
      const Color(0xFF0F172A),
      4,
    );
    _drawText(
      canvas,
      TRANSLATIONS[s.lang]!['lbl_comp_mat']!,
      L['matX'] as double,
      (L['matY'] as double) + 25,
      16,
      Colors.black,
      false,
    );

    _drawDashedArc(
      canvas,
      (L['matX'] as double) - 80,
      (L['matY'] as double) + 90,
      60,
      0,
      math.pi / 3,
    );
    _drawDashedArc(
      canvas,
      (L['matX'] as double) + 80,
      (L['matY'] as double) + 90,
      60,
      0,
      math.pi * 2 / 3,
    );

    if (s.s3p1)
      _drawChikkiCircular(
        canvas,
        (L['matX'] as double) - 80,
        (L['matY'] as double) + 90,
        60,
        0,
        math.pi / 3,
      );
    if (s.s3p2)
      _drawChikkiCircular(
        canvas,
        (L['matX'] as double) + 80,
        (L['matY'] as double) + 90,
        60,
        0,
        math.pi * 2 / 3,
      );

    if (!s.s3p2)
      _drawChikkiCircular(
        canvas,
        L['chX'] as double,
        L['chY'] as double,
        L['chR'] as double,
        0,
        math.pi * 2,
      );

    if (s.s3st1 && !s.s3stamped1) {
      _drawArcPiece(
        canvas,
        L['chX'] as double,
        L['chY'] as double,
        L['chR'] as double,
        0,
        math.pi / 3,
        Colors.white.withOpacity(0.5),
        Colors.amber,
        4,
      );
      _drawButton(
        canvas,
        TRANSLATIONS[s.lang]!['lbl_stamp']!,
        L['btnX'] as double,
        L['btnY'] as double,
        80,
        40,
        Colors.redAccent,
        true,
      );
      s.s3btnStamp1 = true;
    } else if (s.s3stamped1 && !s.s3p1 && s.activeDrag != 'piece6') {
      _drawChikkiCircular(
        canvas,
        L['chX'] as double,
        L['chY'] as double,
        L['chR'] as double,
        0,
        math.pi / 3,
      );
    }

    if (s.step >= 3) {
      if (!s.s3p2) {
        if (s.s3st2 && !s.s3stamped2) {
          _drawArcPiece(
            canvas,
            L['chX'] as double,
            L['chY'] as double,
            L['chR'] as double,
            0,
            math.pi * 2 / 3,
            Colors.white.withOpacity(0.5),
            Colors.amber,
            4,
          );
          _drawButton(
            canvas,
            TRANSLATIONS[s.lang]!['lbl_stamp']!,
            L['btnX'] as double,
            L['btnY'] as double,
            80,
            40,
            Colors.redAccent,
            true,
          );
          s.s3btnStamp2 = true;
        } else if (s.s3stamped2 && s.activeDrag != 'piece3') {
          _drawChikkiCircular(
            canvas,
            L['chX'] as double,
            L['chY'] as double,
            L['chR'] as double,
            0,
            math.pi * 2 / 3,
          );
        }
      }
    }

    if (s.activeDrag == 'stamp6')
      _drawArcPiece(
        canvas,
        s.dragX,
        s.dragY,
        40,
        0,
        math.pi / 3,
        Colors.white.withOpacity(0.7),
        const Color(0xFF0F172A),
        3,
      );
    if (s.activeDrag == 'stamp3')
      _drawArcPiece(
        canvas,
        s.dragX,
        s.dragY,
        40,
        0,
        math.pi * 2 / 3,
        Colors.white.withOpacity(0.7),
        const Color(0xFF0F172A),
        3,
      );
    if (s.activeDrag == 'piece6')
      _drawChikkiCircular(
        canvas,
        s.dragX,
        s.dragY,
        L['chR'] as double,
        0,
        math.pi / 3,
      );
    if (s.activeDrag == 'piece3')
      _drawChikkiCircular(
        canvas,
        s.dragX,
        s.dragY,
        L['chR'] as double,
        0,
        math.pi * 2 / 3,
      );
  }

  void _renderS4(Canvas canvas) {
    final L = Layouts.s4;
    _drawRoundedRect(
      canvas,
      (L['tbX'] as double) - (L['tbW'] as double) / 2,
      (L['tbY'] as double) - (L['tbH'] as double) / 2,
      L['tbW'] as double,
      L['tbH'] as double,
      8,
      const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      4,
    );
    _drawText(
      canvas,
      TRANSLATIONS[s.lang]!['lbl_toolbox']!,
      L['tbX'] as double,
      (L['tbY'] as double) - (L['tbH'] as double) / 2 + 20,
      16,
      Colors.white,
      true,
    );

    if (!s.s4c3 && s.activeDrag != 'gcut3') {
      _drawCircle(
        canvas,
        L['t3X'] as double,
        L['t3Y'] as double,
        20,
        Colors.indigo,
        const Color(0xFF0F172A),
        2,
      );
      _drawText(
        canvas,
        "3",
        L['t3X'] as double,
        L['t3Y'] as double,
        16,
        Colors.white,
        true,
      );
    }
    if (!s.s4c5 && s.step >= 1 && s.activeDrag != 'gcut5') {
      _drawCircle(
        canvas,
        L['t5X'] as double,
        L['t5Y'] as double,
        20,
        Colors.indigo,
        const Color(0xFF0F172A),
        2,
      );
      _drawText(
        canvas,
        "5",
        L['t5X'] as double,
        L['t5Y'] as double,
        16,
        Colors.white,
        true,
      );
    }

    _drawWoodBoard(
      canvas,
      (L['g1X'] as double) - 60,
      (L['g1Y'] as double) - 60,
      120,
      120,
      8,
    );
    if (!s.s4c3)
      _drawGuavaWhole(
        canvas,
        L['g1X'] as double,
        L['g1Y'] as double,
        L['gR'] as double,
      );
    else if (s.s4sL != 3 && s.activeDrag != 'p3')
      _drawGuavaPiece(
        canvas,
        L['g1X'] as double,
        L['g1Y'] as double,
        L['gR'] as double,
        math.pi * 2 / 3,
      );

    if (s.step >= 1) {
      _drawWoodBoard(
        canvas,
        (L['g2X'] as double) - 60,
        (L['g2Y'] as double) - 60,
        120,
        120,
        8,
      );
      if (!s.s4c5)
        _drawGuavaWhole(
          canvas,
          L['g2X'] as double,
          L['g2Y'] as double,
          L['gR'] as double,
        );
      else if (s.s4sR != 5 && s.activeDrag != 'p5')
        _drawGuavaPiece(
          canvas,
          L['g2X'] as double,
          L['g2Y'] as double,
          L['gR'] as double,
          math.pi * 2 / 5,
        );
    }

    double scX = L['scX'] as double, scY = L['scY'] as double;
    _drawRoundedRect(
      canvas,
      scX - 40,
      scY,
      80,
      20,
      4,
      const Color(0xFF64748B),
      const Color(0xFF0F172A),
      3,
    );
    _drawRoundedRect(
      canvas,
      scX - 10,
      scY - 150,
      20,
      150,
      0,
      const Color(0xFF64748B),
      const Color(0xFF0F172A),
      3,
    );

    double wL = s.s4sL == 3 ? 0.33 : 0;
    double wR = s.s4sR == 5 ? 0.2 : 0;
    double angle = (wR - wL) * math.pi / 4;

    canvas.save();
    canvas.translate(scX, scY - 140);
    canvas.rotate(angle);
    _drawRoundedRect(
      canvas,
      -120,
      -5,
      240,
      10,
      5,
      const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      3,
    );

    canvas.save();
    canvas.translate(-110, 5);
    canvas.rotate(-angle);
    _drawPolyline(
      canvas,
      [const Offset(0, 0), const Offset(-30, 80), const Offset(30, 80)],
      const Color(0xFF0F172A),
      2,
      true,
    );
    _drawRoundedRect(
      canvas,
      -30,
      80,
      60,
      15,
      10,
      const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      2,
    );
    if (s.s4sL == 3)
      _drawGuavaPiece(
        canvas,
        0,
        75,
        (L['gR'] as double) * 0.7,
        math.pi * 2 / 3,
      );
    canvas.restore();

    canvas.save();
    canvas.translate(110, 5);
    canvas.rotate(-angle);
    _drawPolyline(
      canvas,
      [const Offset(0, 0), const Offset(-30, 80), const Offset(30, 80)],
      const Color(0xFF0F172A),
      2,
      true,
    );
    _drawRoundedRect(
      canvas,
      -30,
      80,
      60,
      15,
      10,
      const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      2,
    );
    if (s.s4sR == 5)
      _drawGuavaPiece(
        canvas,
        0,
        75,
        (L['gR'] as double) * 0.7,
        math.pi * 2 / 5,
      );
    canvas.restore();
    canvas.restore();

    if (s.activeDrag == 'gcut3') {
      _drawCircle(
        canvas,
        s.dragX,
        s.dragY,
        20,
        Colors.indigo,
        const Color(0xFF0F172A),
        2,
      );
      _drawText(canvas, "3", s.dragX, s.dragY, 16, Colors.white, true);
    }
    if (s.activeDrag == 'gcut5') {
      _drawCircle(
        canvas,
        s.dragX,
        s.dragY,
        20,
        Colors.indigo,
        const Color(0xFF0F172A),
        2,
      );
      _drawText(canvas, "5", s.dragX, s.dragY, 16, Colors.white, true);
    }
    if (s.activeDrag == 'p3')
      _drawGuavaPiece(
        canvas,
        s.dragX,
        s.dragY,
        L['gR'] as double,
        math.pi * 2 / 3,
      );
    if (s.activeDrag == 'p5')
      _drawGuavaPiece(
        canvas,
        s.dragX,
        s.dragY,
        L['gR'] as double,
        math.pi * 2 / 5,
      );
  }

  void _renderS5(Canvas canvas) {
    final L = Layouts.s5;
    double bagX = L['bagX'] as double,
        bagY = L['bagY'] as double,
        bagW = L['bagW'] as double,
        bagH = L['bagH'] as double;

    if (s.activeDrag == 'scoop' &&
        s.dragX > bagX - bagW / 2 &&
        s.dragX < bagX + bagW / 2 &&
        s.dragY > bagY - bagH / 2 &&
        s.dragY < bagY + bagH / 2 &&
        s.s5scoop > 0) {
      _drawRoundedRect(
        canvas,
        bagX - bagW / 2 - 5,
        bagY - bagH / 2 - 5,
        bagW + 10,
        bagH + 10,
        20,
        Colors.transparent,
        Colors.green,
        4,
      );
    }
    _drawSack(canvas, bagX, bagY, bagW, bagH, "${s.s5bag}g");

    bool allEq = s.s5p.every((x) => x == 250);
    for (int i = 0; i < 4; i++) {
      double px = (L['pX'] as List<double>)[i];
      double py = L['pY'] as double;
      bool hover =
          s.activeDrag == 'scoop' &&
          s.dragX > px - 45 &&
          s.dragX < px + 45 &&
          s.dragY > py - 110 &&
          s.dragY < py + 20;
      if (hover && s.s5scoop > 0) {
        _drawRoundedRect(
          canvas,
          px - 45,
          py - 110,
          90,
          130,
          12,
          Colors.transparent,
          Colors.green,
          4,
        );
      }
      _drawRiceJar(canvas, px, py, s.s5p[i].toDouble());
      String? txt = (s.step == 4 && allEq) ? "1/4 kg" : null;
      _drawScale(canvas, px, py, s.s5p[i], txt, hover);
    }

    if (s.activeDrag != 'scoop')
      _drawScoop(canvas, L['scX'] as double, L['scY'] as double, s.s5scoop > 0);
    else
      _drawScoop(canvas, s.dragX, s.dragY, s.s5scoop > 0);

    if (allEq && s.s5bag == 0 && s.step == 3)
      _drawButton(
        canvas,
        TRANSLATIONS[s.lang]!['lbl_check']!,
        L['btnX'] as double,
        L['btnY'] as double,
        160,
        50,
        Colors.green,
        true,
      );
  }

  // --- DRAWING HELPERS ---
  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke,
    double strokeW,
  ) {
    var rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    if (fill != Colors.transparent)
      canvas.drawRRect(
        rect,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
    if (stroke != Colors.transparent)
      canvas.drawRRect(
        rect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
  }

  void _drawCircle(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    Color fill,
    Color stroke,
    double strokeW,
  ) {
    if (fill != Colors.transparent)
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
    if (stroke != Colors.transparent)
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double size,
    Color color,
    bool outline,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    if (outline) {
      final outlineTp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = const Color(0xFF0F172A),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      outlineTp.paint(
        canvas,
        Offset(x - outlineTp.width / 2, y - outlineTp.height / 2),
      );
    }
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawDashedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
  ) {
    var path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
      );
    _drawDashedPath(canvas, path, const Color(0xFF0F172A).withOpacity(0.5), 2);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Color color,
    double width,
  ) {
    var path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy);
    _drawDashedPath(canvas, path, color, width);
  }

  void _drawDashedArc(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double startA,
    double sweepA,
  ) {
    var path = Path()
      ..moveTo(cx, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startA,
        sweepA,
        false,
      )
      ..close();
    _drawDashedPath(canvas, path, const Color(0xFF0F172A).withOpacity(0.5), 2);
  }

  void _drawDashedPath(Canvas canvas, Path path, Color color, double width) {
    var metrics = path.computeMetrics();
    var p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    for (var metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), p);
        distance += 10;
      }
    }
  }

  void _drawPolyline(
    Canvas canvas,
    List<Offset> pts,
    Color color,
    double width,
    bool close,
  ) {
    if (pts.isEmpty) return;
    var path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
    if (close) path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  void _drawArcPiece(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double startA,
    double sweepA,
    Color fill,
    Color stroke,
    double strokeW,
  ) {
    var path = Path()
      ..moveTo(cx, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startA,
        sweepA,
        false,
      )
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );
  }

  void _drawWoodBoard(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
  ) {
    var rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    var p = Paint()
      ..shader = ui.Gradient.linear(Offset(x, y), Offset(x + w, y + h), [
        const Color(0xFFD97706),
        const Color(0xFF92400E),
      ]);
    canvas.drawRRect(rect, p);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  void _drawPlate(Canvas canvas, double x, double y, double r) {
    var p = Paint()
      ..shader = ui.Gradient.radial(Offset(x - r * 0.2, y - r * 0.2), r, [
        Colors.white,
        const Color(0xFF94A3B8),
      ]);
    canvas.drawCircle(Offset(x, y), r, p);
    canvas.drawCircle(
      Offset(x, y),
      r,
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      Offset(x, y),
      r * 0.65,
      Paint()
        ..color = Colors.black12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawRotiPiece(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double startA,
    double endA,
  ) {
    var path = Path();
    double sweep = endA - startA;

    // Fix for Flutter sometimes failing to draw `arcTo` at exactly 2pi
    if (sweep >= math.pi * 2 - 0.01) {
      path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    } else {
      path.moveTo(cx, cy);
      path.arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startA,
        sweep,
        false,
      );
      path.close();
    }

    var p = Paint()
      ..shader = ui.Gradient.radial(Offset(cx, cy), r, [
        const Color(0xFFFEF08A),
        const Color(0xFFEAB308),
      ]);
    canvas.drawPath(path, p);

    canvas.save();
    canvas.clipPath(path);
    canvas.drawCircle(
      Offset(cx - r * 0.3, cy - r * 0.3),
      r * 0.12,
      Paint()..color = const Color(0x66783C00),
    );
    canvas.drawCircle(
      Offset(cx + r * 0.2, cy + r * 0.2),
      r * 0.12,
      Paint()..color = const Color(0x66783C00),
    );
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFB45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _drawChikkiBar(Canvas canvas, double x, double y, double w, double h) {
    var rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      const Radius.circular(6),
    );
    var p = Paint()
      ..shader = ui.Gradient.linear(Offset(x, y), Offset(x + w, y + h), [
        const Color(0xFFB45309),
        const Color(0xFF78350F),
      ]);
    canvas.drawRRect(rect, p);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.save();
    canvas.clipRRect(rect);
    var pDot = Paint()..color = const Color(0x99FDE68A);
    for (double i = 10; i < w; i += 25) {
      for (double j = 10; j < h; j += 20) {
        canvas.drawCircle(
          Offset(x + i + (j % 3) * 4, y + j + (i % 2) * 3),
          4,
          pDot,
        );
      }
    }
    canvas.drawRect(
      Rect.fromLTWH(x, y, w, h),
      Paint()
        ..shader = ui.Gradient.linear(Offset(x, y), Offset(x, y + h), [
          Colors.white38,
          Colors.transparent,
        ]),
    );
    canvas.restore();
  }

  void _drawChikkiCircular(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double startA,
    double sweepA,
  ) {
    var path = Path();

    // Fix for Flutter sometimes failing to draw `arcTo` at exactly 2pi
    if (sweepA >= math.pi * 2 - 0.01) {
      path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    } else {
      path.moveTo(cx, cy);
      path.arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startA,
        sweepA,
        false,
      );
      path.close();
    }

    var p = Paint()
      ..shader = ui.Gradient.radial(Offset(cx - r * 0.2, cy - r * 0.2), r, [
        const Color(0xFFB45309),
        const Color(0xFF78350F),
      ]);
    canvas.drawPath(path, p);

    canvas.save();
    canvas.clipPath(path);
    var pDot = Paint()..color = const Color(0x99FDE68A);
    for (double a = 0; a < math.pi * 2; a += 0.5) {
      for (double d = 15; d < r; d += 20) {
        canvas.drawCircle(
          Offset(cx + math.cos(a) * d, cy + math.sin(a) * d),
          4,
          pDot,
        );
      }
    }
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _drawGuavaWhole(Canvas canvas, double cx, double cy, double r) {
    var p = Paint()
      ..shader = ui.Gradient.radial(Offset(cx - r * 0.2, cy - r * 0.2), r, [
        const Color(0xFF86EFAC),
        const Color(0xFF166534),
      ]);
    canvas.drawCircle(Offset(cx, cy), r, p);
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy + r * 0.8), radius: r * 0.15),
      0,
      math.pi,
      true,
      Paint()..color = const Color(0xFF14532D),
    );
  }

  void _drawGuavaPiece(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double sweepA,
  ) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-math.pi / 2);
    var path = Path()
      ..moveTo(0, 0)
      ..arcTo(Rect.fromCircle(center: Offset.zero, radius: r), 0, sweepA, false)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF22C55E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    var p = Paint()
      ..shader = ui.Gradient.radial(Offset.zero, r, [
        const Color(0xFFFECDD3),
        const Color(0xFFFEF08A),
      ]);
    canvas.drawPath(path, p);
    canvas.save();
    canvas.clipPath(path);
    var pDot = Paint()..color = const Color(0xFFFDE047);
    for (double a = 0.1; a < sweepA; a += 0.3)
      canvas.drawCircle(
        Offset(math.cos(a) * r * 0.4, math.sin(a) * r * 0.4),
        3,
        pDot,
      );
    canvas.restore();
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  void _drawSack(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    String text,
  ) {
    canvas.save();
    var path = Path()
      ..moveTo(x - w / 2 + 10, y - h / 2)
      ..quadraticBezierTo(x - w / 2 - 20, y, x - w / 2 + 10, y + h / 2)
      ..lineTo(x + w / 2 - 20, y + h / 2)
      ..quadraticBezierTo(x + w / 2 + 20, y, x + w / 2 - 10, y - h / 2)
      ..close();
    var p = Paint()
      ..shader = ui.Gradient.radial(Offset(x, y), w, [
        const Color(0xFFE2E8F0),
        const Color(0xFF94A3B8),
      ]);
    canvas.drawPath(path, p);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.restore();
    _drawRoundedRect(
      canvas,
      x - w / 3,
      y - h / 2 - 15,
      w * 0.66,
      20,
      5,
      const Color(0xFFCBD5E1),
      const Color(0xFF0F172A),
      3,
    );
    _drawText(canvas, text, x, y + 10, 24, Colors.white, true);
  }

  void _drawRiceJar(Canvas canvas, double x, double y, double fillAmt) {
    double w = 70, h = 100;
    double fillH = math.min(h - 10, (fillAmt / 250) * (h - 20));
    _drawRoundedRect(
      canvas,
      x - w / 2,
      y - h,
      w,
      h,
      10,
      Colors.white12,
      const Color(0xFF0F172A),
      3,
    );
    if (fillH > 0) {
      canvas.save();
      var r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - w / 2 + 3, y - fillH, w - 6, fillH),
        const Radius.circular(8),
      );
      canvas.clipRRect(r);
      canvas.drawRect(
        Rect.fromLTWH(x - w / 2, y - h, w, h),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(x - w / 2, 0),
            Offset(x + w / 2, 0),
            [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)],
          ),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y - fillH), width: w - 6, height: 10),
        Paint()..color = const Color(0xFFF1F5F9),
      );
      canvas.restore();
    }
    _drawRoundedRect(
      canvas,
      x - w / 2 - 4,
      y - h - 8,
      w + 8,
      12,
      4,
      const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      3,
    );
  }

  void _drawScale(
    Canvas canvas,
    double x,
    double y,
    int weight,
    String? stateText,
    bool isTarget,
  ) {
    Color baseC = isTarget ? const Color(0xFF475569) : const Color(0xFF334155);
    _drawRoundedRect(
      canvas,
      x - 50,
      y,
      100,
      30,
      10,
      baseC,
      const Color(0xFF0F172A),
      2,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: 90, height: 24),
      Paint()..color = const Color(0xFFCBD5E1),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: 90, height: 24),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    Color lcd = const Color(0xFF3B82F6);
    if (stateText != null || weight == 250)
      lcd = Colors.green;
    else if (weight > 250)
      lcd = Colors.red;
    _drawRoundedRect(
      canvas,
      x - 30,
      y + 8,
      60,
      16,
      3,
      const Color(0xFF0F172A),
      const Color(0xFF1E293B),
      1,
    );
    _drawText(canvas, stateText ?? "${weight}g", x, y + 16, 12, lcd, false);
  }

  void _drawScoop(Canvas canvas, double x, double y, bool full) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(-math.pi / 6);
    _drawRoundedRect(
      canvas,
      15,
      -6,
      50,
      12,
      6,
      const Color(0xFF94A3B8),
      const Color(0xFF0F172A),
      3,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 24),
      math.pi / 2,
      math.pi,
      true,
      Paint()..color = const Color(0xFF64748B),
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 24),
      math.pi / 2,
      math.pi,
      true,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 20, height: 48),
      Paint()..color = const Color(0xFFCBD5E1),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 20, height: 48),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (full)
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 16, height: 44),
        Paint()..color = const Color(0xFFF8FAFC),
      );
    canvas.restore();
  }

  void _drawButton(
    Canvas canvas,
    String text,
    double x,
    double y,
    double w,
    double h,
    Color color,
    bool active,
  ) {
    _drawRoundedRect(
      canvas,
      x - w / 2,
      y - h / 2,
      w,
      h,
      20,
      color,
      const Color(0xFF0F172A),
      3,
    );
    if (active) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - w / 2 - 2, y - h / 2 - 2, w + 4, h + 4),
          const Radius.circular(22),
        ),
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    _drawText(canvas, text, x, y, 16, Colors.white, true);
  }

  void _drawPersonSVG(Canvas canvas, double x, double y, double scale) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);
    canvas.drawCircle(const Offset(12, 7), 5, Paint()..color = Colors.indigo);
    var path = Path()
      ..moveTo(4.5, 21)
      ..arcToPoint(
        const Offset(19.5, 21),
        radius: const Radius.circular(7.5),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.indigo);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
