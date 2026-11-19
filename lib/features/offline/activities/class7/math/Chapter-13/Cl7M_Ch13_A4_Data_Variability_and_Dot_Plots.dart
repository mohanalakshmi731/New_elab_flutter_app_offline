// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure audio engine warms up (optional but good for caching)
  AudioEngine.init();
  runApp(const DataVariabilityApp());
}

class DataVariabilityApp extends StatelessWidget {
  const DataVariabilityApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Variability & Dot Plots',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const DataVariabilityAndDotPlots(),
    );
  }
}

/// Dedicated Audio Engine using network Mixkit sources
class AudioEngine {
  // Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Network Audio Sources for guaranteed playback on Android
  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3'; // Requested error sound
  static const String _alertUrl = 'audio/class7/mixkit_2869.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3'; // Requested shutter sound

  static Future<void> init() async {
    // Pre-load sources for faster subsequent playback
    await _clickPlayer.setSource(AssetSource(_clickUrl));
    await _successPlayer.setSource(AssetSource(_successUrl));
    await _errorPlayer.setSource(AssetSource(_errorUrl));
    await _fxPlayer.setSource(AssetSource(_alertUrl));
    await _shutterPlayer.setSource(AssetSource(_shutterUrl));
  }

  static void playClick() => _play(_clickPlayer, _clickUrl);
  static void playSnap() => _play(_clickPlayer, _clickUrl); // Reusing click for snap
  static void playSuccess() => _play(_successPlayer, _successUrl);
  static void playError() => _play(_errorPlayer, _errorUrl);
  static void playWhir() => _play(_fxPlayer, _alertUrl);
  static void playPop() => _play(_clickPlayer, _clickUrl);
  static void playShutter() => _play(_shutterPlayer, _shutterUrl);

  static void _play(AudioPlayer player, String url) async {
    try {
      if (player.state == PlayerState.playing) {
        await player.stop();
      }
      await player.play(AssetSource(url));
    } catch (e) {
      // Fail silently
    }
  }
}

// --- Localization Dictionary ---
const Map<String, Map<String, String>> strings = {
  'en': {
    'shutterTitle': "Data Variability and Dot Plots: The Pocket Mystery", 
    'appSubtitle': "Class 7 • CONNECTING THE DOTS...", 
    'enterLab': "Enter Lab",
    'settings': "Settings", 
    'selectScenario': "Select Scenario", 
    'stepLabel': "STEP", 
    'actTitle': "Action:", 
    'obsLbl': "Observation:", 
    'learnLbl': "Learning:", 
    'nextScenario': "Next Scenario",
    'btn_summarize': "SUMMARIZE", 
    'btn_check_graph': "CHECK MY PLOTS", 
    'btn_create_plot': "CREATE PLOT",
    'insight': "Insight",
    'finalSuccessTitle': "Master of Graphs!", 
    'finalSuccessDesc': "You have successfully mastered interpreting and building Dot Plots.", 
    'finalRestartBtn': "Restart Activity",
    'c_uni': "Uniform Shirt", 'c_jeans': "Jeans", 'c_cargo': "Cargo Shorts", 'c_tshirt': "T-shirt", 'c_dress': "Dress",
    'c_jacket': "Jacket", 'c_sweatpants': "Sweatpants", 'c_shorts': "Shorts",
    's4_plotA': "Dot Plot A", 's4_plotB': "Dot Plot B", 'outlier_lbl': "OUTLIER", 'tryAgain': "Try Again!", 'grade1': "GRADE 1", 'grade7': "GRADE 7",
    's1_title': "1. Uniform Day: A Cluster", 's1_obj': "To visually understand what a dataset with low variability looks like on a dot plot.",
    's1_hud1': "Drag the first student in uniform to the Pocket Scanner.", 's1_step1_task': "DRAG the first student and DROP them onto the 'Pocket Scanner'.", 's1_step1_obs': "A dot appears on the number line based on their pocket count.", 's1_step1_learn': "This dot represents one data point (one student's pocket count).",
    's1_hud2': "Drag the remaining 9 students to the scanner.", 's1_step2_task': "DRAG and DROP the remaining 9 students onto the scanner.", 's1_step2_obs': "The dots stack up close to each other.", 's1_step2_learn': "Because they wear uniforms, their pocket counts are very similar.",
    's1_hud3': "Summarize your findings.", 's1_step3_task': "CLICK the 'Summarize' button on the canvas.", 's1_step3_obs': "A circle highlights the cluster.", 's1_step3_learn': "LOW VARIABILITY means most data points are very similar.", 's1_final': "Mission Accomplished! You identified LOW VARIABILITY.",
    's1_summary_text': "Look how close together the dots are! This is called LOW VARIABILITY. It means most of the data points are very similar.",
    's2_title': "2. Casual Day: Scattered", 's2_obj': "To visually understand what a dataset with high variability looks like on a dot plot.",
    's2_hud1': "Drag the first student in casual wear to the scanner.", 's2_step1_task': "DRAG the first casual student and DROP them onto the scanner.", 's2_step1_obs': "A dot appears on the number line.", 's2_step1_learn': "Casual clothes have different numbers of pockets.",
    's2_hud2': "Drag the remaining 9 casual students to the scanner.", 's2_step2_task': "DRAG and DROP the remaining 9 students.", 's2_step2_obs': "The dots are spread out across many numbers.", 's2_step2_learn': "The data shows a wide range of values.",
    's2_hud3': "Summarize your findings.", 's2_step3_task': "CLICK the 'Summarize' button on the canvas.", 's2_step3_obs': "An arrow shows the spread from minimum to maximum.", 's2_step3_learn': "HIGH VARIABILITY means the data points are very different from each other.", 's2_final': "Mission Accomplished! You identified HIGH VARIABILITY.",
    's2_summary_text': "See how spread out the dots are! This is called HIGH VARIABILITY. It means the data points are very different from each other.",
    's3_title': "3. Cargo Mystery: Outlier", 's3_obj': "To visually identify an outlier in a dataset and understand its meaning.",
    's3_hud1': "Scan the 9 students in regular casual clothes.", 's3_step1_task': "DRAG and DROP the 9 students in casual clothes onto the scanner.", 's3_step1_obs': "A spread-out dot plot is created.", 's3_step1_learn': "This is a typical high variability distribution.",
    's3_hud2': "Scan the student wearing cargo pants.", 's3_step2_task': "DRAG the student wearing cargo pants onto the scanner.", 's3_step2_obs': "A dot appears far away from the rest.", 's3_step2_learn': "This data point does not fit the main pattern.",
    's3_hud3': "Identify the unusual point.", 's3_step3_task': "CLICK the 'Summarize' button on the canvas.", 's3_step3_obs': "The far-away dot flashes red.", 's3_step3_learn': "This dot is an OUTLIER.", 's3_final': "Mission Accomplished! You discovered an OUTLIER.",
    's3_summary_text': "This dot is an OUTLIER! It's a data point that is very different from the rest. It doesn't fit the main pattern.",
    's3_warning': "Scan the 9 casual students first!",
    's4_title': "4. Unsolved Challenge - Who Wears More Pockets?", 's4_obj': "Compare Grade 1 & 7 students by pocket count variability.",
    's4_hud1': "Drag Group A to Scanner A.", 's4_step1_task': "DRAG the students from 'Group A' to Scanner A to create the first plot.", 's4_step1_obs': "Plot A is generated, showing tightly clustered dots.", 's4_step1_learn': "Group A has low variability in pockets.",
    's4_hud2': "Drag Group B to Scanner B.", 's4_step2_task': "DRAG the students from 'Group B' to Scanner B to create the second plot.", 's4_step2_obs': "Plot B is generated, showing scattered dots.", 's4_step2_learn': "Group B has high variability in pockets.",
    's4_hud3': "Match the labels to the plots.", 's4_step3_task': "DRAG the 'Grade 1' and 'Grade 7' labels onto the correct plots, then click CHECK.", 's4_step3_obs': "The labels match the distribution patterns.", 's4_step3_learn': "Older students likely have more clothing variety (higher variability).", 's4_final': "Mission Accomplished! You correctly matched the variability to the groups.",
    's4_lbl_g1': "Grade 1 Students", 's4_lbl_g7': "Grade 7 Students",
    's4_correct_text_l1': "Correct! Older students have", 's4_correct_text_l2': "more clothing variety and", 's4_correct_text_l3': "pocket variability.",
    's5_title': "5. Unsolved Challenge - The Fashion Designer", 's5_obj': "Mission Objective: Construct a dataset with high variability and at least one outlier.",
    's5_hud1': "Dress 8 students to create high variability and 1 outlier.", 's5_step1_task': "DRAG clothes from the Closet onto the 8 avatars. Include one item with many pockets for an outlier.", 's5_step1_obs': "Students are dressed.", 's5_step1_learn': "You are designing the dataset.",
    's5_hud2': "Generate the dot plot.", 's5_step2_task': "CLICK 'CREATE PLOT' on the canvas to scan all students.", 's5_step2_obs': "The dot plot is generated based on your choices.", 's5_step2_learn': "Visualizing the dataset you created.",
    's5_hud3': "Check your design.", 's5_step3_task': "The system will check if your design has HIGH variability and an OUTLIER.", 's5_step3_obs': "The plot is analyzed.", 's5_step3_learn': "Validating data criteria visually.", 's5_final': "Mission Accomplished! You successfully created a dataset with high variability and an outlier.",
    's5_closet': "CLOSET",
    'footer': "© ZeroScienceLab - Fall in love with math and Science"
  },
  'hi': {
    'shutterTitle': "डेटा परिवर्तनशीलता और डॉट प्लॉट: पॉकेट रहस्य", 'appSubtitle': "कक्षा 7 • बिंदुओं को जोड़ना...", 'enterLab': "लैब में प्रवेश करें",
    'settings': "सेटिंग्स", 'selectScenario': "परिदृश्य चुनें", 'stepLabel': "चरण", 'actTitle': "कार्य:", 'obsLbl': "अवलोकन:", 'learnLbl': "सीख:", 'nextScenario': "अगला परिदृश्य",
    'btn_summarize': "संक्षेप करें", 'btn_check_graph': "प्लॉट की जाँच करें", 'btn_create_plot': "प्लॉट बनाएँ", 'insight': "अंतर्दृष्टि",
    'finalSuccessTitle': "ग्राफ के मास्टर!", 'finalSuccessDesc': "आपने डॉट प्लॉट की व्याख्या करना और बनाना सफलतापूर्वक सीख लिया है।", 'finalRestartBtn': "गतिविधि पुनरारंभ करें",
    'c_uni': "यूनिफॉर्म शर्ट", 'c_jeans': "जींस", 'c_cargo': "कार्गो शॉर्ट्स", 'c_tshirt': "टी-शर्ट", 'c_dress': "ड्रेस",
    'c_jacket': "जैकेट", 'c_sweatpants': "स्वेटपैंट्स", 'c_shorts': "शॉर्ट्स",
    's4_plotA': "डॉट प्लॉट A", 's4_plotB': "डॉट प्लॉट B", 'outlier_lbl': "आउटलेयर", 'tryAgain': "पुनः प्रयास करें!", 'grade1': "ग्रेड 1", 'grade7': "ग्रेड 7",
    's1_title': "1. यूनिफॉर्म दिवस: एक क्लस्टर", 's1_obj': "नेत्रहीन रूप से यह समझना कि कम परिवर्तनशीलता वाला डेटासेट डॉट प्लॉट पर कैसा दिखता है।",
    's1_hud1': "यूनिफॉर्म वाले पहले छात्र को पॉकेट स्कैनर पर खींचें।", 's1_step1_task': "पहले छात्र को 'पॉकेट स्कैनर' पर खींचें और छोड़ें।", 's1_step1_obs': "पॉकेट की संख्या के आधार पर एक डॉट दिखाई देता है।", 's1_step1_learn': "यह डॉट एक डेटा बिंदु को दर्शाता है।",
    's1_hud2': "शेष 9 छात्रों को स्कैनर पर खींचें।", 's1_step2_task': "शेष 9 छात्रों को स्कैनर पर खींचें और छोड़ें।", 's1_step2_obs': "करते हुए डॉट्स एक साथ टिक जाते हैं।", 's1_step2_learn': "यूनिफॉर्म के कारण, उनके पॉकेट की संख्या बहुत समान है।",
    's1_hud3': "अपने निष्कर्षों को संक्षेप में बताएं।", 's1_step3_task': "कैनवास पर 'संक्षेप करें' बटन पर क्लिक करें।", 's1_step3_obs': "एक वृत्त क्लस्टर को हाइलाइट करता है।", 's1_step3_learn': "कम परिवर्तनशीलता का मतलब है कि अधिकांश डेटा बिंदु बहुत समान हैं।", 's1_final': "मिशन पूरा हुआ! आपने कम परिवर्तनशीलता की पहचान की।",
    's1_summary_text': "देखें कि डॉट्स एक साथ कितने करीब हैं! इसे कम परिवर्तनशीलता (LOW VARIABILITY) कहा जाता है। इसका अर्थ है कि अधिकांश डेटा बिंदु बहुत समान हैं।",
    's2_title': "2. कैज़ुअल डे: फैला हुआ", 's2_obj': "यह समझना कि उच्च परिवर्तनशीलता वाला डेटासेट डॉट प्लॉट पर कैसा दिखता है।",
    's2_hud1': "कैज़ुअल कपड़े पहने पहले छात्र को स्कैनर पर खींचें।", 's2_step1_task': "पहले कैज़ुअल छात्र को स्कैनर पर खींचें और छोड़ें।", 's2_step1_obs': "नंबर लाइन पर एक डॉट दिखाई देता है।", 's2_step1_learn': "कैज़ुअल कपड़ों में पॉकेट की संख्या अलग-अलग होती है।",
    's2_hud2': "शेष 9 कैज़ुअल छात्रों को स्कैनर पर खींचें।", 's2_step2_task': "शेष 9 छात्रों को खींचें और छोड़ें।", 's2_step2_obs': "डॉट्स कई नंबरों में फैले हुए हैं।", 's2_step2_learn': "डेटा मूल्यों की एक विस्तृत श्रृंखला दिखाता है।",
    's2_hud3': "अपने निष्कर्षों को संक्षेप में बताएं।", 's2_step3_task': "कैनवास पर 'संक्षेप करें' बटन पर क्लिक करें।", 's2_step3_obs': "एक तीर न्यूनतम से अधिकतम तक फैलाव दिखाता है।", 's2_step3_learn': "उच्च परिवर्तनशीलता का अर्थ है कि डेटा बिंदु एक दूसरे से बहुत भिन्न हैं।", 's2_final': "मिशन पूरा हुआ! आपने उच्च परिवर्तनशीलता की पहचान की।",
    's2_summary_text': "देखें कि डॉट्स कैसे फैले हुए हैं! इसे उच्च परिवर्तनशीलता (HIGH VARIABILITY) कहा जाता है। इसका अर्थ है कि डेटा बिंदु एक दूसरे से बहुत भिन्न हैं।",
    's3_title': "3. कार्गो रहस्य: आउटलेयर", 's3_obj': "डेटासेट में आउटलेयर (Outlier) की पहचान करना और उसका अर्थ समझना।",
    's3_hud1': "नियमित कैज़ुअल कपड़े पहने 9 छात्रों को स्कैन करें।", 's3_step1_task': "कैज़ुअल कपड़ों में 9 छात्रों को स्कैनर पर खींचें और छोड़ें।", 's3_step1_obs': "एक फैला हुआ डॉट प्लॉट बनाया गया है।", 's3_step1_learn': "यह एक विशिष्ट उच्च परिवर्तनशीलता वितरण है।",
    's3_hud2': "कार्गो पैंट पहने छात्र को स्कैन करें।", 's3_step2_task': "कार्गो पैंट पहने छात्र को स्कैनर पर खींचें।", 's3_step2_obs': "एक डॉट बाकी से बहुत दूर दिखाई देता है।", 's3_step2_learn': "यह डेटा बिंदु मुख्य पैटर्न में फिट नहीं होता है।",
    's3_hud3': "असामान्य बिंदु को पहचानें।", 's3_step3_task': "कैनवास पर 'संक्षेप करें' बटन पर क्लिक करें।", 's3_step3_obs': "दूर वाला डॉट लाल रंग में चमकता है।", 's3_step3_learn': "यह डॉट एक आउटलेयर (OUTLIER) है।", 's3_final': "मिशन पूरा हुआ! आपने एक आउटलेयर की खोज की।",
    's3_summary_text': "यह डॉट एक OUTLIER है! यह एक ऐसा डेटा बिंदु जो बाकी हिस्सों से बहुत अलग है। यह मुख्य पैटर्न में फिट नहीं होता है।",
    's3_warning': "पहले 9 कैज़ुअल छात्रों को स्कैन करें!",
    's4_title': "4. Unsolved Challenge - किसके पास अधिक पॉकेट हैं?", 's4_obj': "ग्रेड 1 और 7 के छात्रों के पॉकेट काउंट परिवर्तनशीलता की तुलना करें।",
    's4_hud1': "समूह A को स्कैनर A पर खींचें।", 's4_step1_task': "'समूह A' के छात्रों को स्कैनर A पर खींचें।", 's4_step1_obs': "प्लॉट A उत्पन्न होता है, जो बारीकी से क्लस्टर किए गए डॉट्स दिखाता है।", 's4_step1_learn': "समूह A में पॉकेट्स में कम परिवर्तनशीलता है।",
    's4_hud2': "समूह B को स्कैनर B पर खींचें।", 's4_step2_task': "'समूह B' के छात्रों को स्कैनर B पर खींचें।", 's4_step2_obs': "प्लॉट B उत्पन्न होता है, जो फैले हुए डॉट्स दिखाता है।", 's4_step2_learn': "समूह B में पॉकेट्स में उच्च परिवर्तनशीलता है।",
    's4_hud3': "अर्थात लेबल को प्लॉट्स से मिलाएँ।", 's4_step3_task': "'ग्रेड 1' और 'ग्रेड 7' लेबल को सही प्लॉट पर खींचें, फिर चेक पर क्लिक करें।", 's4_step3_obs': "लेबल वितरण पैटर्न से मेल खाते हैं।", 's4_step3_learn': "बड़े छात्रों के कपड़ों में अधिक विविधता (उच्च परिवर्तनशीलता) होने की संभावना है।", 's4_final': "मिशन पूरा हुआ! आपने परिवर्तनशीलता का सही मिलान किया।",
    's4_lbl_g1': "Grade 1 Students", 's4_lbl_g7': "Grade 7 Students",
    's4_correct_text_l1': "सही! बड़े छात्रों के कपड़ों में", 's4_correct_text_l2': "अधिक विविधता और पॉकेट की", 's4_correct_text_l3': "परिवर्तनशीलता होती है।",
    's5_title': "5. Unsolved Challenge - फैशन डिज़ाइनर", 's5_obj': "मिशन उद्देश्य: उच्च परिवर्तनशीलता और कम से कम एक आउटलेयर के साथ एक डेटासेट का निर्माण करें।",
    's5_hud1': "उच्च परिवर्तनशीलता और 1 आउटलेयर बनाने के लिए 8 छात्रों को कपड़े पहनाएं।", 's5_step1_task': "अलमारी से कपड़ों को 8 अवतारों पर खींचें। एक आउटलेयर के लिए अधिक पॉकेट वाली वस्तु शामिल करें।", 's5_step1_obs': "छात्रों को कपड़े पहनाए गए हैं।", 's5_step1_learn': "आप डेटासेट डिज़ाइन कर रहे हैं।",
    's5_hud2': "डॉट प्लॉट बनाएँ।", 's5_step2_task': "सभी छात्रों को स्कैन करने के लिए कैनवास पर 'प्लॉट बनाएँ' पर क्लिक करें।", 's5_step2_obs': "आपकी पसंद के आधार पर डॉट प्लॉट उत्पन्न होता है।", 's5_step2_learn': "आपके द्वारा बनाए गए डेटासेट की कल्पना करना।",
    's5_hud3': "अपने डिज़ाइन की जाँच करें।", 's5_step3_task': "सिस्टम जाँच करेगा कि आपके डिज़ाइन में उच्च परिवर्तनशीलता और एक आउटलेयर है या नहीं।", 's5_step3_obs': "प्लॉट का विश्लेषण किया गया है।", 's5_step3_learn': "नेत्रहीन रूप से डेटा मानदंड की पुष्टि करना।", 's5_final': "मिशन पूरा हुआ! आपने सफलतापूर्वक उच्च परिवर्तनशीलता और आउटलेयर वाला डेटासेट बनाया।",
    's5_closet': "अलमारी",
    'footer': "© ZeroScienceLab - Fall in love with math and Science"
  }
};

// --- Models ---
class DraggableItem {
  String id;
  String type;
  int val;
  double x, y;
  double targetX, targetY;
  double homeX, homeY;
  bool isDragging = false;
  bool isScanning = false;
  bool isScanned = false;
  bool isSnapped = false;
  int scanTimer = 0;
  String? targetLine;
  String group;
  int zIndex;
  bool isSource;
  int avatarIndex;

  DraggableItem({
    required this.id,
    required this.type,
    required this.val,
    required this.x,
    required this.y,
    this.group = '',
    this.zIndex = 0,
    this.isSource = false,
    this.avatarIndex = 0,
  })  : targetX = x,
        targetY = y,
        homeX = x,
        homeY = y;
}

class Dropzone {
  String id;
  double x, y, w, h;
  String? topType;
  String? bottomType;
  int topPockets = 0;
  int bottomPockets = 0;
  int pockets = 0;
  int? avatarIndex;
  double targetX, targetY;

  Dropzone({
    required this.id,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.avatarIndex,
  })  : targetX = x,
        targetY = y;
}

class DotPlotDot {
  double x, y;
  double targetX, targetY;
  int val;
  String line;
  double progress = 0;

  DotPlotDot({
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
    required this.val,
    required this.line,
  });
}

class ScenarioStep {
  final String task;
  final String obs;
  final String learn;
  ScenarioStep(this.task, this.obs, this.learn);
}

// --- Main Screen ---
class DataVariabilityAndDotPlots extends StatefulWidget {
  const DataVariabilityAndDotPlots({Key? key}) : super(key: key);

  @override
  State<DataVariabilityAndDotPlots> createState() => _DataVariabilityAndDotPlotsState();
}

class _DataVariabilityAndDotPlotsState extends State<DataVariabilityAndDotPlots> with SingleTickerProviderStateMixin {
  bool _isSidebarOpen = true;
  String _lang = 'en';
  bool _showCurtain = true;

  // Scroll Controller for Sidebar Auto-Scroll
  final ScrollController _scrollController = ScrollController();

  // Game State
  late Ticker _ticker;
  final ValueNotifier<int> _tickNotifier = ValueNotifier<int>(0); // Isolates canvas repaints perfectly
  bool _isDraggingAnyItem = false;
  
  int _scenario = 1;
  int _step = 0;
  
  List<DraggableItem> _draggables = [];
  List<Dropzone> _dropzones = [];
  List<DotPlotDot> _dots = [];
  Map<String, Map<int, int>> _dotCounts = {};
  
  bool _showSummary = false;
  bool _showSuccess = false;
  String _errorMsg = '';
  int _maxVal = 12;

  final TransformationController _transformCtrl = TransformationController();

  String t(String key) => strings[_lang]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      _updateSimulation();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _tickNotifier.dispose();
    _scrollController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  List<ScenarioStep> _getStepsForScenario(int scenarioId) {
    int maxSteps = (scenarioId == 4 || scenarioId == 5) ? 3 : 3;
    List<ScenarioStep> steps = [];
    for (int i = 1; i <= maxSteps; i++) {
      steps.add(ScenarioStep(
        t('s${scenarioId}_step${i}_task'),
        t('s${scenarioId}_step${i}_obs'),
        t('s${scenarioId}_step${i}_learn'),
      ));
    }
    return steps;
  }

  void _loadScenario(int s) {
    _scenario = s;
    _step = 0;
    _draggables.clear();
    _dropzones.clear();
    _dots.clear();
    _dotCounts.clear();
    _showSummary = false;
    _showSuccess = false;
    _errorMsg = '';

    if (s == 1 || s == 2 || s == 3) {
      _maxVal = (s == 3) ? 15 : 8;
      List<int> values = [];
      String type = '';
      if (s == 1) { values = [3, 2, 3, 4, 3, 2, 4, 3, 3, 2]; type = 'uniform'; }
      if (s == 2) { values = [6, 0, 2, 5, 3, 7, 1, 4, 2, 5]; type = 'casual'; }
      if (s == 3) { values = [1, 2, 3, 1, 2, 4, 2, 3, 1, 12]; type = 'casual'; }

      double scanX = (s == 3) ? 250 : 200;
      double scanY = (s == 3) ? -50 : -20;
      _dropzones.add(Dropzone(id: 'scanner', x: scanX, y: scanY, w: 120, h: 180));

      for (int i = 0; i < values.length; i++) {
        String avatarType = type;
        double sx = (s == 3) ? -400 + (i % 5) * 70 : -350 + (i % 5) * 70;
        double sy = (s == 3) ? -80 + (i ~/ 5) * 80 : -80 + (i ~/ 5) * 100;
        
        if (s == 3 && i == 9) {
          avatarType = 'cargo';
          sx += 30;
        }

        _draggables.add(DraggableItem(
          id: 'stu_$i', type: avatarType, val: values[i], x: sx, y: sy, avatarIndex: i, zIndex: i
        ));
      }
    } else if (s == 4) {
      _maxVal = 8;
      _dropzones.add(Dropzone(id: 'scannerA', x: -280, y: 20, w: 80, h: 120));
      _dropzones.add(Dropzone(id: 'scannerB', x: 220, y: 20, w: 80, h: 120));
      _dropzones.add(Dropzone(id: 'lblDropA', x: -140, y: 195, w: 150, h: 40));
      _dropzones.add(Dropzone(id: 'lblDropB', x: 360, y: 195, w: 150, h: 40));

      List<int> valsA = [1, 2, 1, 3, 2, 0, 1, 2, 0, 1];
      List<int> valsB = [0, 4, 6, 2, 7, 1, 8, 3, 5, 2];

      for (int i = 0; i < valsA.length; i++) {
        _draggables.add(DraggableItem(
          id: 'gA_$i', type: 'uniform', val: valsA[i], group: 'A',
          x: -440 + (i % 3) * 30, y: -20 + (i ~/ 3) * 35, avatarIndex: i, zIndex: 20-i
        ));
      }
      for (int i = 0; i < valsB.length; i++) {
        _draggables.add(DraggableItem(
          id: 'gB_$i', type: 'casual', val: valsB[i], group: 'B',
          x: 60 + (i % 3) * 30, y: -20 + (i ~/ 3) * 35, avatarIndex: i + 10, zIndex: 20-i
        ));
      }
      
      _draggables.add(DraggableItem(id: 'lbl_g1', type: 'label', val: 0, x: -120, y: 260, zIndex: 100));
      _draggables.add(DraggableItem(id: 'lbl_g7', type: 'label', val: 0, x: 120, y: 260, zIndex: 100));

    } else if (s == 5) {
      _maxVal = 12;
      for (int i = 0; i < 8; i++) {
        double sx = -350 + (i % 4) * 120;
        double sy = -130 + (i ~/ 4) * 150;
        _dropzones.add(Dropzone(id: 'ava_$i', x: sx, y: sy, w: 70, h: 100, avatarIndex: i)
          ..topType = 'blank_top'
          ..bottomType = 'blank_bottom'
        );
      }

      List<Map<String, dynamic>> clothes = [
        {'id': 'c_tshirt', 'type': 'tshirt', 'p': 0},
        {'id': 'c_uni', 'type': 'uniform', 'p': 2},
        {'id': 'c_jacket', 'type': 'jacket', 'p': 4},
        {'id': 'c_dress', 'type': 'dress', 'p': 0},
        {'id': 'c_sweatpants', 'type': 'sweatpants', 'p': 2},
        {'id': 'c_shorts', 'type': 'shorts', 'p': 3},
        {'id': 'c_jeans', 'type': 'jeans', 'p': 5},
        {'id': 'c_cargo', 'type': 'cargo', 'p': 8}
      ];

      List<Offset> positions = [
        const Offset(220, -110), const Offset(320, -110),
        const Offset(220, -20),  const Offset(320, -20),
        const Offset(220, 70),   const Offset(320, 70),
        const Offset(220, 160),  const Offset(320, 160)
      ];

      for (int i = 0; i < clothes.length; i++) {
        double cx = positions[i].dx;
        double cy = positions[i].dy;
        _draggables.add(DraggableItem(
          id: clothes[i]['id'] as String, type: clothes[i]['type'] as String, val: clothes[i]['p'] as int,
          x: cx, y: cy, isSource: true, zIndex: 50
        ));
      }
    }

    _tickNotifier.value++;
    setState(() {});
    
    // Auto scroll top when scenario loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _startTickerIfNeeded() {
    if (!_ticker.isTicking) {
      _ticker.start();
    }
  }

  void _handleReset() {
    AudioEngine.playError();
    setState(() { _showCurtain = true; });
  }

  void _toggleLanguage() {
    AudioEngine.playClick();
    setState(() {
      if (_lang == 'en') _lang = 'hi';
      else _lang = 'en';
    });
  }

  void _updateSimulation() {
    bool isAnimating = false;
    bool needsRepaint = false;
    bool needsStateUpdate = false;

    // Movement interpolation
    for (var d in _draggables) {
      if ((d.x - d.targetX).abs() > 0.5 || (d.y - d.targetY).abs() > 0.5) {
        d.x += (d.targetX - d.x) * 0.2;
        d.y += (d.targetY - d.y) * 0.2;
        isAnimating = true;
        needsRepaint = true;
      } else if (d.x != d.targetX || d.y != d.targetY) {
        d.x = d.targetX;
        d.y = d.targetY;
        needsRepaint = true;
      }

      if (d.isScanning) {
        isAnimating = true;
        d.scanTimer--;
        needsRepaint = true;
        if (d.scanTimer <= 0) {
          d.isScanning = false;
          d.isScanned = true;
          AudioEngine.playPop();

          String line = d.targetLine ?? 'main';
          _dotCounts.putIfAbsent(line, () => {});
          int count = _dotCounts[line]![d.val] ?? 0;
          _dotCounts[line]![d.val] = count + 1;

          double spacing = (_scenario == 4) ? 20 : (_maxVal > 8 ? 30 : 50);
          double baseX = (_scenario == 4) ? (line == 'A' ? -220 : 280) : (_scenario == 3 ? -350 : -200);
          if(_scenario == 5) baseX = -220;

          double endX = baseX + d.val * spacing;
          double dotRad = _scenario == 4 ? 7 : 11;
          
          double endY = 150;
          if (_scenario == 4) endY = 110;
          if (_scenario == 5) endY = 220;
          
          endY = endY - count * (dotRad * 2 + 4) - (dotRad + 4);

          _dots.add(DotPlotDot(x: d.x, y: d.y, targetX: endX, targetY: endY, val: d.val, line: line));
          needsStateUpdate = true;
        }
      }
    }

    for (var dot in _dots) {
      if (dot.progress < 1.0) {
        isAnimating = true;
        dot.progress += 0.06;
        dot.x += (dot.targetX - dot.x) * 0.2;
        dot.y += (dot.targetY - dot.y) * 0.2;
        if (dot.progress >= 1.0) {
          dot.x = dot.targetX;
          dot.y = dot.targetY;
          dot.progress = 1.0;
          AudioEngine.playSnap();
        }
        needsRepaint = true;
      }
    }

    if (!isAnimating && !_isDraggingAnyItem && _ticker.isTicking) {
      _ticker.stop();
    }

    if (needsStateUpdate) {
      _checkAutoAdvance();
      setState(() {}); 
    } else if (needsRepaint) {
      _tickNotifier.value++;
    }
  }

  void _checkAutoAdvance() {
    bool advanced = false;
    if (_scenario <= 3) {
      int scanned = _draggables.where((d) => d.isScanned).length;
      int expected = (_scenario == 3 && _step == 0) ? 9 : 10;
      if (scanned >= expected && _step == 0) {
        _step = 1;
        advanced = true;
      }
    } else if (_scenario == 4) {
      int scannedA = _draggables.where((d) => d.group == 'A' && d.isScanned).length;
      int scannedB = _draggables.where((d) => d.group == 'B' && d.isScanned).length;
      if (scannedA == 10 && _step == 0) { _step = 1; advanced = true; }
      if (scannedB == 10 && _step == 1) { _step = 2; advanced = true; }
    }

    // Auto-scroll sidebar when advancing to a new step
    if (advanced && _scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _onPointerDown(PointerDownEvent details) {
    if (_showCurtain || _showSuccess) return;

    double worldX = details.localPosition.dx - 600;
    double worldY = details.localPosition.dy - 400;

    _draggables.sort((a, b) => b.zIndex.compareTo(a.zIndex));
    for (var d in _draggables) {
      if (d.isScanned || d.isScanning) continue;
      if (_scenario == 4 && _step == 0 && d.group == 'B') continue;
      if (_scenario == 4 && _step == 1 && d.group == 'A') continue;

      double w = d.type == 'label' ? 150 : (d.isSource ? 80 : 70);
      double h = d.type == 'label' ? 40 : (d.isSource ? 100 : 90);

      if (worldX >= d.x - w/2 && worldX <= d.x + w/2 &&
          worldY >= d.y - h/2 && worldY <= d.y + h/2) {
        
        AudioEngine.playClick();
        setState(() {
          _isDraggingAnyItem = true;
          if (d.isSource && _scenario == 5) {
            DraggableItem clone = DraggableItem(
              id: 'clone_${DateTime.now().millisecondsSinceEpoch}',
              type: d.type, val: d.val, x: worldX, y: worldY, zIndex: 200
            )..isDragging = true;
            _draggables.add(clone);
          } else {
            d.isDragging = true;
            d.zIndex = 200;
          }
        });
        _startTickerIfNeeded();
        break;
      }
    }
  }

  void _onPointerMove(PointerMoveEvent details) {
    DraggableItem? active = _draggables.where((d) => d.isDragging).firstOrNull;
    if (active != null) {
      double worldX = details.localPosition.dx - 600;
      double worldY = details.localPosition.dy - 400;

      active.targetX = worldX;
      active.targetY = worldY;
      active.x = worldX;
      active.y = worldY;
      
      _tickNotifier.value++; 
    }
  }

  void _onPointerUp(PointerUpEvent details) {
    DraggableItem? active = _draggables.where((d) => d.isDragging).firstOrNull;
    if (active != null) {
      setState(() {
        active.isDragging = false;
        _isDraggingAnyItem = false;
        bool snapped = false;

        for (var dz in _dropzones) {
          bool hit = false;
          if (active.type == 'label') {
            if (dz.id.startsWith('lblDrop') && (active.targetX - dz.x).abs() < 80 && (active.targetY - dz.y).abs() < 40) hit = true;
          } else if (_scenario == 5 && active.id.startsWith('clone_')) {
            if (dz.id.startsWith('ava_') && (active.targetX - dz.x).abs() < 60 && (active.targetY - dz.y).abs() < 80) hit = true;
          } else {
            if (dz.id.startsWith('scanner') && (active.targetX - dz.x).abs() < 100 && (active.targetY - dz.y).abs() < 120) hit = true;
          }

          if (hit) {
            bool valid = false;
            if (_scenario <= 3 && dz.id.startsWith('scanner')) {
              if (_scenario == 3 && active.type == 'cargo' && _step == 0) {
                 AudioEngine.playError();
                 _errorMsg = t('s3_warning');
                 Future.delayed(const Duration(seconds: 2), () => setState(()=>_errorMsg=''));
                 valid = false;
              } else {
                valid = true;
              }
            }
            if (_scenario == 4 && active.group == 'A' && dz.id == 'scannerA') valid = true;
            if (_scenario == 4 && active.group == 'B' && dz.id == 'scannerB') valid = true;
            if (_scenario == 4 && active.type == 'label') valid = true;
            if (_scenario == 5 && active.id.startsWith('clone_')) valid = true;

            if (valid) {
              snapped = true;
              active.isSnapped = true;
              if (active.type == 'label') {
                active.targetX = dz.x; active.targetY = dz.y;
                AudioEngine.playSnap();
              } else if (_scenario == 5 && active.id.startsWith('clone_')) {
                // Dress avatar
                if (['uniform', 'tshirt', 'jacket'].contains(active.type)) {
                  dz.topType = active.type; dz.topPockets = active.val;
                  if (dz.bottomType == 'dress') { dz.bottomType = 'blank_bottom'; dz.bottomPockets = 0; }
                } else if (['jeans', 'cargo', 'sweatpants', 'shorts'].contains(active.type)) {
                  dz.bottomType = active.type; dz.bottomPockets = active.val;
                  if (dz.topType == 'dress') { dz.topType = 'blank_top'; dz.topPockets = 0; }
                } else if (active.type == 'dress') {
                  dz.topType = 'dress'; dz.bottomType = 'dress'; dz.topPockets = active.val; dz.bottomPockets = 0;
                }
                dz.pockets = dz.topPockets + dz.bottomPockets;
                AudioEngine.playSnap();
                _draggables.remove(active); // consumed
              } else {
                active.targetX = dz.x; active.targetY = dz.y + 10;
                active.isScanning = true; active.scanTimer = 40;
                active.targetLine = dz.id == 'scannerA' ? 'A' : (dz.id == 'scannerB' ? 'B' : 'main');
                AudioEngine.playWhir();
              }
              break;
            }
          }
        }

        if (!snapped) {
          if (active.id.startsWith('clone_')) {
            _draggables.remove(active);
          } else {
            AudioEngine.playError();
            active.targetX = active.homeX;
            active.targetY = active.homeY;
            active.isSnapped = false;
          }
        }
      });
      _startTickerIfNeeded();
    }
  }

  // --- Button Handlers ---
  void _onSummarize() {
    AudioEngine.playSuccess();
    setState(() {
      _showSummary = true;
      _step = 2; // End of scenario 1-3
      _showSuccess = true;
    });
    // Auto-scroll sidebar when advancing to summary
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onCheckPlots() {
    var l1 = _draggables.firstWhere((d) => d.id == 'lbl_g1');
    var l7 = _draggables.firstWhere((d) => d.id == 'lbl_g7');

    if (l1.isSnapped && l7.isSnapped) {
      if ((l1.targetX - (-140)).abs() < 10 && (l7.targetX - 360).abs() < 10) {
        AudioEngine.playSuccess();
        setState(() {
          _showSummary = true;
          _step = 3;
          _showSuccess = true;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
          }
        });
      } else {
        AudioEngine.playError();
        setState(() { _errorMsg = t('tryAgain'); });
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            l1.targetX = l1.homeX; l1.targetY = l1.homeY; l1.isSnapped = false;
            l7.targetX = l7.homeX; l7.targetY = l7.homeY; l7.isSnapped = false;
            _errorMsg = '';
          });
        });
      }
    } else {
      AudioEngine.playError();
    }
  }

  void _onCreatePlot() async {
    AudioEngine.playClick();
    setState(() { _step = 1; _dots.clear(); _dotCounts.clear(); });
    _startTickerIfNeeded();
    
    List<int> vals = [];
    for (var dz in _dropzones) {
      if (dz.id.startsWith('ava_')) vals.add(dz.pockets);
    }

    for (int i = 0; i < vals.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      var dz = _dropzones.firstWhere((z) => z.id == 'ava_$i');
      
      String line = 'main';
      _dotCounts.putIfAbsent(line, () => {});
      int count = _dotCounts[line]![vals[i]] ?? 0;
      _dotCounts[line]![vals[i]] = count + 1;

      double endX = -220 + vals[i] * 32.0;
      double endY = 220 - count * 26.0 - 15.0; // S5 endY

      AudioEngine.playPop();
      setState(() {
        _dots.add(DotPlotDot(x: dz.x, y: dz.y, targetX: endX, targetY: endY, val: vals[i], line: line));
      });
      _startTickerIfNeeded();
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    vals.sort();
    int min = vals.first, max = vals.last;
    int range = max - min;
    int? outlierVal;
    if (vals[vals.length - 1] - vals[vals.length - 2] >= 3) {
      outlierVal = vals[vals.length - 1];
    } else if (vals[1] - vals[0] >= 3) {
      outlierVal = vals[0];
    }

    if (range >= 5 && outlierVal != null) {
      AudioEngine.playSuccess();
      setState(() { _showSummary = true; _step = 2; _showSuccess = true; });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
        }
      });
    } else {
      AudioEngine.playError();
      setState(() { _errorMsg = "Design Rejected! Need high spread & distinct outlier."; });
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        _dots.clear();
        _dotCounts.clear();
        for (var dz in _dropzones) {
          if (dz.id.startsWith('ava_')) {
            dz.topType = 'blank_top'; dz.bottomType = 'blank_bottom'; dz.pockets = 0;
          }
        }
        _errorMsg = '';
        _step = 0;
      });
    }
  }

  String _getCurrentHud() {
    int displayStep = _step + 1;
    if (displayStep > 3) displayStep = 3; // cap at 3 for scenario HUD messages
    String key = 's${_scenario}_hud$displayStep';
    return strings[_lang]?[key] ?? '';
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sidebarWidth = sw * 0.38; // Requested 38% screen width
    if (sidebarWidth < 300) sidebarWidth = 300; 
    
    List<ScenarioStep> scenarioSteps = _getStepsForScenario(_scenario);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Base Interactive Canvas
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _transformCtrl,
                minScale: 0.5,
                maxScale: 3.0,
                constrained: false,
                panEnabled: !_isDraggingAnyItem, // Enables canvas panning natively
                boundaryMargin: const EdgeInsets.all(800),
                child: SizedBox(
                  width: 1200,
                  height: 800,
                  child: Listener( 
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: _onPointerDown,
                    onPointerMove: _onPointerMove,
                    onPointerUp: _onPointerUp,
                    child: CustomPaint(
                      painter: LabCanvasPainter(
                        scenario: _scenario,
                        draggables: _draggables,
                        dropzones: _dropzones,
                        dots: _dots,
                        maxVal: _maxVal,
                        showSummary: _showSummary,
                        lang: _lang,
                        errorMsg: _errorMsg,
                        currentHud: _getCurrentHud(),
                        repaint: _tickNotifier, // Highly optimized redraw isolation
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Floating Action Buttons (On Canvas instead of Sidebar)
            Positioned(
              bottom: 32,
              right: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_scenario <= 3 && _step == 1 && !_showSummary)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.analytics, size: 28),
                      label: Text(t('btn_summarize'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      onPressed: _onSummarize,
                    ),
                  if (_scenario == 4 && _step == 2 && !_showSummary)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle, size: 28),
                      label: Text(t('btn_check_graph'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      onPressed: _onCheckPlots,
                    ),
                  if (_scenario == 5 && _step == 0)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.scatter_plot, size: 28),
                      label: Text(t('btn_create_plot'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      onPressed: _onCreatePlot,
                    ),
                ],
              ),
            ),

            // Sidebar (Animated Positioned - completely scrollable from top to bottom)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.95),
                  border: const Border(right: BorderSide(color: Colors.white24, width: 1)),
                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(), // Ensures smooth scrolling
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Content with Back Button explicitly matched
                      Padding(
                        padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 16), // Adjusted for no SafeArea
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  color: Colors.white,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(t('shutterTitle'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(t('appSubtitle'), style: const TextStyle(fontSize: 11, color: Colors.cyanAccent)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Toggle Button for Language
                                InkWell(
                                  onTap: _toggleLanguage,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    height: 36,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.cyan.withOpacity(0.5))
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.language, color: Colors.cyanAccent, size: 18),
                                        const SizedBox(width: 8),
                                        Text(_lang.toUpperCase(), style: const TextStyle(color: Colors.cyanAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                // Reset Button
                                IconButton(
                                  icon: const Icon(Icons.refresh, color: Colors.redAccent),
                                  onPressed: _handleReset,
                                  tooltip: t('finalRestartBtn'),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white12, height: 1),

                      // Main Sidebar Body
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(t('selectScenario').toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.cyan.withOpacity(0.5))
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _scenario,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1E293B),
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  items: [1, 2, 3, 4, 5].map((s) {
                                    return DropdownMenuItem<int>(
                                      value: s,
                                      child: Text(t('s${s}_title')),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      AudioEngine.playClick();
                                      _loadScenario(val);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Target Objective
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.cyan.withOpacity(0.3))
                              ),
                              child: Text(t('s${_scenario}_obj'), style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4)),
                            ),
                            const SizedBox(height: 24),

                            // Steps List
                            ...List.generate(scenarioSteps.length, (index) {
                              bool isCompleted = index < _step;
                              bool isActive = index == _step;
                              bool isLocked = index > _step;

                              Color bgColor = isLocked ? Colors.white10 : (isActive ? Colors.cyan.withOpacity(0.2) : Colors.cyan.withOpacity(0.05));
                              Color borderColor = isLocked ? Colors.transparent : (isActive ? Colors.cyan : Colors.cyan.withOpacity(0.3));

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  border: Border.all(color: borderColor),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        isCompleted && _step != scenarioSteps.length
                                          ? const Icon(Icons.check_circle, color: Colors.cyan)
                                          : CircleAvatar(
                                              radius: 12,
                                              backgroundColor: isActive ? Colors.cyan : Colors.grey,
                                              child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                            ),
                                        const SizedBox(width: 8),
                                        Text("${t('stepLabel')} ${index + 1}", style: TextStyle(color: isActive ? Colors.cyanAccent : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(text: "${t('actTitle')} ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                                          TextSpan(text: scenarioSteps[index].task, style: TextStyle(color: isLocked ? Colors.grey : Colors.white)),
                                        ]
                                      )
                                    ),
                                    if (isCompleted)
                                      Container(
                                        margin: const EdgeInsets.only(top: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.cyan.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.cyan.withOpacity(0.3))
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(text: "${t('obsLbl')} ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                                  TextSpan(text: scenarioSteps[index].obs, style: const TextStyle(color: Colors.white70)),
                                                ]
                                              )
                                            ),
                                            const Divider(color: Colors.white24, height: 16),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(text: "${t('learnLbl')} ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                                  TextSpan(text: scenarioSteps[index].learn, style: const TextStyle(color: Colors.white70)),
                                                ]
                                              )
                                            ),
                                          ],
                                        ),
                                      )
                                  ],
                                ),
                              );
                            }),

                            // Summary Feedback inside Sidebar
                            if (_showSummary)
                              Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green)
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.lightbulb, color: Colors.amber, size: 32),
                                      const SizedBox(height: 8),
                                      Text(
                                        _scenario == 4 ? t('s4_final') : (_scenario == 5 ? t('s5_final') : t('s${_scenario}_summary_text')),
                                        style: const TextStyle(color: Colors.white, fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Footer
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.white12))
                        ),
                        child: Text(
                          t('footer'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Hamburger Menu Icon (Top Left, always visible, front Z-index)
            Positioned(
              top: 24, // Adjusted for no SafeArea
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() { _isSidebarOpen = !_isSidebarOpen; });
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

            // Success Popup overlay (Scrollable)
            if (_showSuccess && _scenario == 5)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Container(
                      width: 400,
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.cyan)
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                                const SizedBox(height: 16),
                                Text(t('finalSuccessTitle'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 16),
                                Text(t('finalSuccessDesc'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.white70)),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.refresh),
                                  label: Text(t('finalRestartBtn')),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                                  onPressed: () {
                                    AudioEngine.playClick();
                                    _loadScenario(1);
                                  },
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70),
                              onPressed: () {
                                AudioEngine.playClick();
                                setState(() { _showSuccess = false; });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Shutter Curtain
            if (_showCurtain)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.scatter_plot, size: 80, color: Colors.cyanAccent),
                        const SizedBox(height: 24),
                        Text(t('shutterTitle'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 12),
                        Text(t('appSubtitle'), style: const TextStyle(fontSize: 18, color: Colors.cyan)),
                        const SizedBox(height: 48),
                        ElevatedButton.icon(
                          onPressed: () {
                            AudioEngine.playShutter();
                            setState(() { _showCurtain = false; });
                            _loadScenario(1);
                          },
                          icon: const Icon(Icons.play_circle_fill, size: 28),
                          label: Text(t('enterLab'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
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
}

// --- Canvas Painter ---
class LabCanvasPainter extends CustomPainter {
  final int scenario;
  final List<DraggableItem> draggables;
  final List<Dropzone> dropzones;
  final List<DotPlotDot> dots;
  final int maxVal;
  final bool showSummary;
  final String lang;
  final String errorMsg;
  final String currentHud;

  String t(String key) => strings[lang]?[key] ?? key;

  LabCanvasPainter({
    required this.scenario,
    required this.draggables,
    required this.dropzones,
    required this.dots,
    required this.maxVal,
    required this.showSummary,
    required this.lang,
    required this.errorMsg,
    required this.currentHud,
    Listenable? repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    // We establish the center of our 1200x800 internal coordinate system
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    _drawBackground(canvas, scenario);
    
    // Draw HUD banner if applicable
    if (currentHud.isNotEmpty && !showSummary) {
      final RRect hudRect = RRect.fromRectAndRadius(const Rect.fromLTWH(-300, -380, 600, 50), const Radius.circular(25));
      canvas.drawRRect(hudRect, Paint()..color = Colors.cyan.withOpacity(0.9));
      canvas.drawRRect(hudRect, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
      _drawText(canvas, currentHud, 0, -355, Colors.black, 16);
    }

    if (scenario <= 3) {
      double bx = (scenario == 3) ? -350 : -200;
      _drawDotPlotAxis(canvas, bx, 150, maxVal, maxVal > 8 ? 30 : 50);
    } else if (scenario == 5) {
      _drawDotPlotAxis(canvas, -220, 220, maxVal, 32); // Adjusted dot plot axis slightly lower
      _drawCloset(canvas, 190, -170, 290, 410); // Match closet position to HTML
    } else if (scenario == 4) {
      // Split tables matching S4 coords
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-460, -190, 110, 140), const Radius.circular(8)), Paint()..color = const Color(0xFF1E293B));
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(40, -190, 110, 140), const Radius.circular(8)), Paint()..color = const Color(0xFF1E293B));
      
      _drawDotPlotAxis(canvas, -220, 110, 8, 20);
      _drawDotPlotAxis(canvas, 280, 110, 8, 20);
      _drawText(canvas, t('s4_plotA'), -140, -40, Colors.white70, 16);
      _drawText(canvas, t('s4_plotB'), 360, -40, Colors.white70, 16);
      
      // Label dropzones
      final Paint dashPaint = Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-215, 175, 150, 40), const Radius.circular(20)), dashPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(285, 175, 150, 40), const Radius.circular(20)), dashPaint);
    }

    // Draw Dropzones (Scanners / Avatars)
    for (var dz in dropzones) {
      if (dz.id.startsWith('scanner')) {
        DraggableItem? active = draggables.where((d) => d.isScanning && (d.targetLine == dz.id.replaceAll('scanner', '') || (dz.id == 'scanner' && d.targetLine == 'main'))).firstOrNull;
        _drawScanner(canvas, dz.x, dz.y, dz.w, dz.h, active != null, active?.val, scenario, dz.id);
      } else if (dz.id.startsWith('ava_')) {
        _drawAvatar(canvas, dz.x, dz.y, 'blank', dz.pockets, dz: dz);
      }
    }

    // Draw Summary Highlights
    if (showSummary) {
      if (scenario == 1) {
        final Paint hPaint = Paint()..color = Colors.cyan..style = PaintingStyle.stroke..strokeWidth = 5;
        canvas.drawOval(const Rect.fromLTWH(-200 + 2*50 - 42.5, 150 - 110, 85, 110), hPaint);
      } else if (scenario == 2) {
        final Paint hPaint = Paint()..color = Colors.cyan..style = PaintingStyle.stroke..strokeWidth = 5;
        canvas.drawLine(const Offset(-200, 180), Offset(-200 + 7*50, 180), hPaint);
      } else if (scenario == 3) {
        double outX = -350 + 12 * 30.0;
        final Paint hPaint = Paint()..color = Colors.red..style = PaintingStyle.stroke..strokeWidth = 4;
        canvas.drawCircle(Offset(outX, 150 - 26 - 15), 16, hPaint);
        _drawText(canvas, t('outlier_lbl'), outX + 65, 150 - 26 - 15 + 15, Colors.white, 14);
      } else if (scenario == 5) {
        List<int> vals = [];
        for (var dz in dropzones) if (dz.id.startsWith('ava_')) vals.add(dz.pockets);
        vals.sort();
        int? outlier;
        if (vals.last - vals[vals.length-2] >= 3) outlier = vals.last;
        else if (vals[1] - vals.first >= 3) outlier = vals.first;

        if (outlier != null) {
          double outX = -220 + outlier * 32.0;
          canvas.drawCircle(Offset(outX, 220 - 24 - 12), 16, Paint()..color=Colors.red..style=PaintingStyle.stroke..strokeWidth=4);
          _drawText(canvas, t('outlier_lbl'), outX, 220 - 65, Colors.redAccent, 15);
        }
      }
    }

    if (errorMsg.isNotEmpty) {
      _drawText(canvas, errorMsg, 0, -220, Colors.redAccent, 24);
    }

    // Draw Dots
    for (var dot in dots) {
      final Paint dotPaint = Paint()..color = (scenario == 3 && dot.val == 12) ? Colors.red : Colors.blue;
      canvas.drawCircle(Offset(dot.x, dot.y), scenario == 4 ? 7 : 11, dotPaint);
      canvas.drawCircle(Offset(dot.x, dot.y), scenario == 4 ? 7 : 11, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 2);
    }

    // Draw Draggables
    var sorted = List<DraggableItem>.from(draggables)..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    for (var d in sorted) {
      if (d.isScanned) continue;
      if (scenario == 4 && !d.isDragging) {
        if (d.group == 'B' && draggables.where((e)=>e.group=='A'&&e.isScanned).length < 10) continue; 
      }
      
      canvas.save();
      canvas.translate(d.x, d.y);
      if (d.isDragging) canvas.scale(1.1);

      if (d.type == 'label') {
        final Paint lblPaint = Paint()..color = d.isSnapped ? Colors.green : Colors.blueAccent;
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-75, -20, 150, 40), const Radius.circular(20)), lblPaint);
        _drawText(canvas, t(d.id == 'lbl_g1' ? 's4_lbl_g1' : 's4_lbl_g7'), 0, 0, Colors.white, 14); // Fixed to translation keys
      } else if (d.isSource || d.id.startsWith('clone_')) {
        _drawClothingItem(canvas, 0, 0, d.type, d.val);
      } else {
        _drawAvatar(canvas, 0, 0, d.type, d.val, avatarIndex: d.avatarIndex);
      }
      
      canvas.restore();
    }

    canvas.restore(); // Restore global center translation
  }

  void _drawBackground(Canvas canvas, int s) {
    // Exact visual background matching the HTML base decorations
    canvas.drawRect(const Rect.fromLTWH(-1000, 100, 2000, 400), Paint()..color = const Color(0xFF1E293B));
    canvas.drawRect(const Rect.fromLTWH(-1000, 100, 2000, 10), Paint()..color = const Color(0xFF334155));

    if (s != 4 && s != 5) {
      final Paint bgPaint = Paint()..color = const Color(0xFFE2E8F0);
      final Paint strokePaint = Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 6;
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-250, -220, 500, 200), const Radius.circular(4)), bgPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-250, -220, 500, 200), const Radius.circular(4)), strokePaint);
      
      canvas.drawRect(const Rect.fromLTWH(-240, -26, 480, 6), Paint()..color = const Color(0xFF94A3B8));

      // Left blue box
      canvas.drawRect(const Rect.fromLTWH(-380, -180, 100, 140), Paint()..color = const Color(0xFF1E40AF));
      canvas.drawRect(const Rect.fromLTWH(-380, -180, 100, 140), Paint()..color = const Color(0xFF3B82F6)..style = PaintingStyle.stroke..strokeWidth=4);
      canvas.drawCircle(const Offset(-330, -140), 25, Paint()..color = const Color(0xFF60A5FA));
      
      // Right green box
      canvas.drawRect(const Rect.fromLTWH(280, -180, 100, 140), Paint()..color = const Color(0xFF065F46));
      canvas.drawRect(const Rect.fromLTWH(280, -180, 100, 140), Paint()..color = const Color(0xFF10B981)..style = PaintingStyle.stroke..strokeWidth=4);
      canvas.drawRect(const Rect.fromLTWH(300, -160, 60, 60), Paint()..color = const Color(0xFF34D399));
    }
  }

  void _drawDotPlotAxis(Canvas canvas, double x, double y, int max, double spacing) {
    final Paint linePaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 3;
    double w = max * spacing;
    canvas.drawLine(Offset(x - 20, y), Offset(x + w + 20, y), linePaint);
    
    for (int i = 0; i <= max; i++) {
      double tx = x + i * spacing;
      canvas.drawLine(Offset(tx, y - 6), Offset(tx, y + 6), linePaint);
      _drawText(canvas, i.toString(), tx, y + 15, Colors.white70, 14);
    }
  }

  void _drawScanner(Canvas canvas, double x, double y, double w, double h, bool isScanning, int? val, int s, String id) {
    canvas.save();
    canvas.translate(x, y);

    if (s == 1 || s == 2) {
      final Paint fill = Paint()..color = const Color(0xFF4ADE80);
      final Paint stroke = Paint()..color = const Color(0xFF166534)..style = PaintingStyle.stroke..strokeWidth = 5;
      
      Path p = Path();
      p.moveTo(-w/2, h/2);
      p.lineTo(w/2, h/2);
      p.lineTo(w/2, -h/2 + 60);
      p.lineTo(w/2 - 25, -h/2);
      p.lineTo(-w/2 + 25, -h/2);
      p.lineTo(-w/2, -h/2 + 60);
      p.close();
      
      canvas.drawPath(p, fill);
      canvas.drawPath(p, stroke);

      canvas.drawRect(Rect.fromLTWH(-w/2 + 25, -h/2 + 35, w - 50, 70), Paint()..color = const Color(0xFF0F172A));
      if (isScanning && val != null) {
        _drawText(canvas, val.toString(), 0, -h/2 + 70, Colors.greenAccent, 40);
      }
    } else if (s == 3) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w/2, -h/2, w, h), const Radius.circular(15)), Paint()..color = Colors.blue.shade400);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w/2, -h/2, w, h), const Radius.circular(15)), Paint()..color = Colors.blue.shade700..style = PaintingStyle.stroke..strokeWidth = 4);
      
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w/2 + 15, -h/2 + 20, w - 30, 60), const Radius.circular(5)), Paint()..color = const Color(0xFF0F172A));
      if (isScanning && val != null) {
        _drawText(canvas, val.toString(), 0, -h/2 + 50, Colors.greenAccent, 40);
      }
    } else if (s == 4) {
      Color baseCol = id == 'scannerA' ? Colors.grey.shade400 : Colors.yellow.shade400;
      Color strokeCol = id == 'scannerA' ? Colors.grey.shade600 : Colors.amber.shade600;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w/2, -h/2, w, h), const Radius.circular(10)), Paint()..color = baseCol);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w/2, -h/2, w, h), const Radius.circular(10)), Paint()..color = strokeCol..style = PaintingStyle.stroke..strokeWidth = 4);
      
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w/2 + 10, -h/2 + 15, w - 20, 50), const Radius.circular(5)), Paint()..color = Colors.lightBlue.shade50);
      if (isScanning && val != null) {
        _drawText(canvas, val.toString(), 0, -18, Colors.blue, 28);
      }
    }

    canvas.restore();
  }

  void _drawAvatar(Canvas canvas, double x, double y, String type, int val, {Dropzone? dz, int? avatarIndex}) {
    canvas.save();
    canvas.translate(x, y);

    String tType = type, bType = type;
    int tVal = val, bVal = 0;
    
    if (dz != null) {
      tType = dz.topType ?? 'blank_top';
      bType = dz.bottomType ?? 'blank_bottom';
      tVal = dz.topPockets;
      bVal = dz.bottomPockets;
      val = dz.pockets;
      avatarIndex = dz.avatarIndex;
    } else {
      if (type == 'cargo') { tType = 'casual'; bType = 'cargo'; }
      else if (type == 'jeans') { tType = 'casual'; bType = 'jeans'; }
      else if (type == 'uniform') { tType = 'uniform'; bType = 'uniform_pants'; }
    }

    Color shirtCol = Colors.white;
    Color pantsCol = Colors.blueGrey;
    Color skinCol = Colors.orange.shade200;

    if (tType == 'uniform') shirtCol = Colors.blue.shade800;
    else if (tType == 'jacket') shirtCol = Colors.orange;
    else if (tType == 'dress') shirtCol = Colors.purpleAccent;
    else if (tType == 'casual') shirtCol = Colors.primaries[(avatarIndex ?? 0) % Colors.primaries.length];
    else if (tType == 'blank_top') shirtCol = Colors.grey.shade600;

    if (bType == 'uniform_pants') pantsCol = Colors.grey.shade300;
    else if (bType == 'jeans') pantsCol = Colors.blue.shade700;
    else if (bType == 'cargo') pantsCol = Colors.brown;
    else if (bType == 'shorts') pantsCol = Colors.green;
    else if (bType == 'blank_bottom') pantsCol = Colors.grey.shade600;
    else if (bType == 'dress') pantsCol = Colors.purpleAccent;

    // Legs
    canvas.drawRect(const Rect.fromLTWH(-12, 15, 10, 25), Paint()..color = pantsCol);
    canvas.drawRect(const Rect.fromLTWH(2, 15, 10, 25), Paint()..color = pantsCol);
    
    // Body
    if (tType == 'dress') {
      Path p = Path()..moveTo(-15, -20)..lineTo(15, -20)..lineTo(20, 25)..lineTo(-20, 25)..close();
      canvas.drawPath(p, Paint()..color = shirtCol);
    } else {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-16, -20, 32, 40), const Radius.circular(6)), Paint()..color = shirtCol);
    }

    // Pockets visual
    Paint pockPaint = Paint()..color = Colors.black26;
    if (tVal > 0 && tType != 'dress' && tType != 'blank_top') {
        canvas.drawRect(const Rect.fromLTWH(-10, 0, 6, 8), pockPaint);
    }
    if (bVal > 0 || (type != 'dress' && type != 'blank_top' && val > 0)) {
       canvas.drawRect(const Rect.fromLTWH(-10, 20, 6, 8), pockPaint);
       canvas.drawRect(const Rect.fromLTWH(4, 20, 6, 8), pockPaint);
    }

    // Head
    canvas.drawCircle(const Offset(0, -32), 14, Paint()..color = skinCol);
    
    // Face (Smiley!)
    final Paint facePaint = Paint()..color = Colors.black87;
    canvas.drawCircle(const Offset(-4, -34), 1.5, facePaint); // Left eye
    canvas.drawCircle(const Offset(4, -34), 1.5, facePaint);  // Right eye
    
    final Path smilePath = Path();
    smilePath.addArc(Rect.fromLTWH(-5, -31, 10, 8), 0, pi); // Happy smile
    canvas.drawPath(smilePath, Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 1.5);
    
    // Pocket Total Badge
    if (val >= 0 && (tType != 'blank_top' || bType != 'blank_bottom')) {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-10, 28, 20, 16), const Radius.circular(4)), Paint()..color = Colors.amber);
      _drawText(canvas, val.toString(), 0, 36, Colors.black, 10);
    }

    canvas.restore();
  }

  void _drawClothingItem(Canvas canvas, double x, double y, String type, int val) {
    canvas.save();
    canvas.translate(x, y);

    // Hanger
    canvas.drawArc(const Rect.fromLTWH(-4, -22, 8, 8), 0.8 * pi, 1.4 * pi, false, Paint()..color = Colors.grey..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawLine(const Offset(0, -14), const Offset(-14, -6), Paint()..color = Colors.grey..strokeWidth = 2);
    canvas.drawLine(const Offset(0, -14), const Offset(14, -6), Paint()..color = Colors.grey..strokeWidth = 2);

    Color fillCol = Colors.pink;
    if (type == 'uniform') fillCol = Colors.blue.shade300;
    else if (type == 'jeans') fillCol = Colors.blue.shade400;
    else if (type == 'cargo') fillCol = Colors.brown.shade300;
    else if (type == 'tshirt') fillCol = Colors.white;
    else if (type == 'dress') fillCol = Colors.yellow;
    else if (type == 'jacket') fillCol = Colors.orange;
    else if (type == 'sweatpants') fillCol = Colors.grey;
    else if (type == 'shorts') fillCol = Colors.green;

    if (['uniform', 'tshirt', 'jacket'].contains(type)) {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-15, -6, 30, 26), const Radius.circular(3)), Paint()..color = fillCol);
    } else if (['jeans', 'cargo', 'sweatpants', 'shorts'].contains(type)) {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-13, -6, 26, 34), const Radius.circular(4)), Paint()..color = fillCol);
    } else if (type == 'dress') {
      Path p = Path()..moveTo(-9, -6)..lineTo(9, -6)..lineTo(16, 28)..lineTo(-16, 28)..close();
      canvas.drawPath(p, Paint()..color = fillCol);
    }

    // Label
    canvas.drawRect(const Rect.fromLTWH(-8, -2, 16, 12), Paint()..color = Colors.white);
    _drawText(canvas, val.toString(), 0, 4, Colors.black, 10);

    canvas.restore();
  }

  void _drawCloset(Canvas canvas, double x, double y, double w, double h) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(12)), Paint()..color = Colors.orange.shade100);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, 40), const Radius.circular(12)), Paint()..color = Colors.orange.shade300);
    _drawText(canvas, t('s5_closet'), x + w/2, y + 20, Colors.black, 20);
  }

  void _drawText(Canvas canvas, String text, double x, double y, Color color, double size) {
    final TextSpan span = TextSpan(style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.bold), text: text);
    final TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant LabCanvasPainter oldDelegate) => true;
}