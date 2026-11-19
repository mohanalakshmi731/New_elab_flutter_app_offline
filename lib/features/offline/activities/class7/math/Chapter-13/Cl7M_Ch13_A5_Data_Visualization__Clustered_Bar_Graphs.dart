// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AudioEngine.init();
  runApp(const DataVisualizationApp());
}

class DataVisualizationApp extends StatelessWidget {
  const DataVisualizationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comparing Worlds: Clustered Bar Graphs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const DataVisualizationClustered(),
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
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _alertUrl = 'audio/class7/mixkit_2869.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';

  static Future<void> init() async {
    // Pre-load sources for faster subsequent playback
    await _clickPlayer.setSource(AssetSource(_clickUrl));
    await _successPlayer.setSource(AssetSource(_successUrl));
    await _errorPlayer.setSource(AssetSource(_errorUrl));
    await _fxPlayer.setSource(AssetSource(_alertUrl));
    await _shutterPlayer.setSource(AssetSource(_shutterUrl));
  }

  static void playClick() => _play(_clickPlayer, _clickUrl);
  static void playSnap() => _play(_clickPlayer, _clickUrl); 
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
      // Fail silently if network fails
    }
  }
}

// --- Localization Dictionary ---
const Map<String, Map<String, String>> strings = {
  'en': {
    'shutterTitle': "Comparing Worlds: The Power of Clustered Bar Graphs", 
    'appSubtitle': "Class 7 • CONNECTING THE DOTS...", 
    'enterLab': "Enter Lab",
    'selectScenario': "Select Scenario", 
    'stepLabel': "STEP", 
    'actTitle': "Action:", 
    'obsLbl': "Observation:", 
    'learnLbl': "Learning:", 
    'finalSuccessTitle': "Master of Graphs!", 
    'finalSuccessDesc': "You have successfully mastered interpreting and building Clustered Bar Graphs.", 
    'finalRestartBtn': "Restart Activity",
    
    'btn_check_graph': "CHECK MY GRAPH", 
    'btn_finalize_graph': "FINALIZE GRAPH", 
    'btn_observe': "OBSERVE & CONTINUE",

    's1_title': "1. Fruit Stand Tussle", 
    's1_obj': "To visually compare the monthly sales of apples and oranges and understand how a clustered bar graph is constructed.",
    's1_step1_task': "DRAG the 'Apples' crate (20kg) and DROP it onto the 'January' slot on the graph.", 
    's1_step1_obs': "A red bar rises to the 20 mark under January.", 
    's1_step1_learn': "The first data point forms the start of our cluster.",
    's1_step2_task': "DRAG the 'Oranges' crate (30kg) and DROP it onto the same 'January' slot.", 
    's1_step2_obs': "An orange bar rises next to the red one, completing the cluster.", 
    's1_step2_learn': "A cluster groups related data (different fruits) for a specific category (month).",
    's1_step3_task': "DRAG and DROP the crates for February (A:40, O:35) and March (A:50, O:45).", 
    's1_step3_obs': "The graph is fully populated with three clusters.", 
    's1_step3_learn': "We now have a complete visual representation of sales over time.",
    's1_step4_task': "Observe the completed graph and CLICK 'OBSERVE & CONTINUE'.", 
    's1_step4_obs': "The graph shows sales trends clearly at a glance.", 
    's1_step4_learn': "Clustered bar graphs make side-by-side comparisons effortless.", 
    's1_final': "Great job! The graph makes it easy to see that oranges sold better in January, but apples caught up later.",
    's1_jan': "January", 's1_feb': "February", 's1_mar': "March", 's1_apples': "Apples", 's1_oranges': "Oranges", 
    
    's2_title': "2. Gaming Contest", 
    's2_obj': "To interpret a clustered bar graph that compares the performance of two gamers across several rounds.",
    's2_step1_task': "DRAG Priya's Round 1 Trophy (80 points) to the 'Round 1' pedestal.", 
    's2_step1_obs': "A blue bar appears for Priya.", 
    's2_step1_learn': "We establish the first bar of the comparison.",
    's2_step2_task': "DRAG Rohan's Round 1 Trophy (60 points) to the same pedestal.", 
    's2_step2_obs': "A green bar appears for Rohan next to Priya's.", 
    's2_step2_learn': "The comparison for Round 1 is complete.",
    's2_step3_task': "DRAG and DROP the remaining trophies for Rounds 2, 3, and 4.", 
    's2_step3_obs': "The graph is populated showing all 4 rounds.", 
    's2_step3_learn': "A complete set of clusters reveals the overall trend.",
    's2_step4_task': "Observe the graph and CLICK 'OBSERVE & CONTINUE'.", 
    's2_step4_obs': "Different patterns emerge for each player.", 
    's2_step4_learn': "Visual data allows us to identify consistency vs. peak performance.", 
    's2_final': "Excellent! Priya had the highest peak score (Round 4), but Rohan was more consistent across all rounds.",
    's2_priya': "Priya", 's2_rohan': "Rohan", 's2_r1': "R1", 's2_r2': "R2", 's2_r3': "R3", 's2_r4': "R4",

    's3_title': "3. Reading Race", 
    's3_obj': "To build and analyze a graph comparing two types of reading material over time.",
    's3_step1_task': "DRAG the 'Fiction' stack (15 books) onto the 'Week 1' shelf.", 
    's3_step1_obs': "A purple bar represents fiction reading.", 
    's3_step1_learn': "Data visualization starts with setting base values.",
    's3_step2_task': "DRAG the 'Non-Fiction' stack (10 books) onto the same shelf.", 
    's3_step2_obs': "A yellow bar represents non-fiction reading.", 
    's3_step2_learn': "Contrasting colors help distinguish categories within a cluster.",
    's3_step3_task': "DRAG and DROP the remaining stacks for Weeks 2, 3, and 4.", 
    's3_step3_obs': "All four weeks are visualized.", 
    's3_step3_learn': "Building the full graph allows us to spot anomalies.",
    's3_step4_task': "Observe the graph and CLICK 'OBSERVE & CONTINUE'.", 
    's3_step4_obs': "Week 3 shows a break in the pattern.", 
    's3_step4_learn': "Graphs highlight exceptions to general trends instantly.", 
    's3_final': "Perfect! Fiction was more popular generally, but non-fiction spiked in Week 3. Good eye!",
    's3_w1': "Week 1", 's3_w2': "Week 2", 's3_w3': "Week 3", 's3_w4': "Week 4", 's3_f': "Fiction", 's3_nf': "Non-Fiction",

    's4_title': "4. Park Visitors", 
    's4_obj': "To construct a clustered bar graph from a given data table without step-by-step guidance.",
    's4_step1_task': "DRAG the correct 'Visitor Tokens' from the table and DROP them onto the correct 'Weekday' or 'Weekend' slots.", 
    's4_step1_obs': "Tokens snap into place to form bars.", 
    's4_step1_learn': "Translating tabular data into a spatial format requires careful reading.",
    's4_step2_task': "Once you have built the graph, CLICK 'CHECK MY GRAPH'.", 
    's4_step2_obs': "The graph is validated.", 
    's4_step2_learn': "Checking work ensures data integrity before analysis.", 
    's4_final': "Brilliant! You accurately converted the data table into a comparative visualization.",
    's4_table_title': "Park Visitors Data", 's4_category': "Category", 's4_kids': "Kids", 's4_adults': "Adults", 's4_weekday': "Weekday", 's4_weekend': "Weekend",

    's5_title': "5. Screen Time Showdown", 
    's5_obj': "To create a personalized clustered bar graph based on student input and interpret the resulting visualization.",
    's5_step1_task': "ADJUST the two sliders to estimate your 'Learning' and 'Entertainment' hours for Friday, then click Confirm.", 
    's5_step1_obs': "Data tokens are generated based on your input.", 
    's5_step1_learn': "Data collection is the first step of personalized analysis.",
    's5_step2_task': "ADJUST the sliders for Saturday and Sunday, then click Confirm.", 
    's5_step2_obs': "More tokens are generated.", 
    's5_step2_learn': "Collecting a complete dataset allows for pattern matching.",
    's5_step3_task': "DRAG each generated token to its correct day on the graph canvas.", 
    's5_step3_obs': "A personalized clustered bar graph is constructed.", 
    's5_step3_learn': "Visualizing personal data makes abstract numbers tangible.",
    's5_step4_task': "Type your observation in the text box, then CLICK 'Submit Observation'.", 
    's5_step4_obs': "The reflection is recorded.", 
    's5_step4_learn': "The ultimate goal of graphing is drawing meaningful, personal inferences.", 
    's5_final': "Case closed! You successfully gathered personal data, visualized it, and interpreted the results.",
    's5_input_title': "Input Hours", 's5_learn_lbl': "Learning", 's5_ent_lbl': "Entertainment", 's5_confirm_btn': "Confirm Data", 
    's5_fri': "Friday", 's5_sat': "Saturday", 's5_sun': "Sunday",
    's5_reflect_title': "Final Reflection", 's5_reflect_desc': "What does your graph tell you about your screen time habits over the weekend?", 's5_reflect_placeholder': "Type your observations here...",
    
    'footer': "© ZeroScienceLab - Fall in love with math and Science"
  },
  'hi': {
    'shutterTitle': "तुलनात्मक दुनिया: क्लस्टर बार ग्राफ", 
    'appSubtitle': "कक्षा 7 • बिंदुओं को जोड़ना...", 
    'enterLab': "लैब में प्रवेश करें",
    'selectScenario': "परिदृश्य चुनें", 
    'stepLabel': "चरण", 
    'actTitle': "कार्य:", 
    'obsLbl': "अवलोकन:", 
    'learnLbl': "सीख:", 
    'finalSuccessTitle': "ग्राफ के मास्टर!", 
    'finalSuccessDesc': "आपने क्लस्टर बार ग्राफ की व्याख्या करना और बनाना सफलतापूर्वक सीख लिया है।", 
    'finalRestartBtn': "गतिविधि पुनरारंभ करें",
    
    'btn_check_graph': "मेरा ग्राफ जांचें", 
    'btn_finalize_graph': "ग्राफ को अंतिम रूप दें", 
    'btn_observe': "देखें और आगे बढ़ें",

    's1_title': "1. फलों की दुकान", 
    's1_obj': "सेब और संतरे की मासिक बिक्री की दृष्टि से तुलना करना और यह समझना कि क्लस्टर बार ग्राफ कैसे बनाया जाता है।",
    's1_step1_task': "डिलीवरी ट्रक से '20 किलो' वाले 'सेब' के क्रेट को खींचें और इसे ग्राफ पर 'जनवरी' स्लॉट में छोड़ें।", 
    's1_step1_obs': "एक लाल रंग का बार जनवरी के तहत 20 के निशान तक बढ़ता है।", 
    's1_step1_learn': "पहला डेटा बिंदु हमारे क्लस्टर की शुरुआत करता है।",
    's1_step2_task': "ट्रक से '30 किलो' वाले 'संतरे' के क्रेट को खींचें और उसी 'जनवरी' स्लॉट में छोड़ें।", 
    's1_step2_obs': "लाल बार के बगल में एक नारंगी बार उभरता है, जो क्लस्टर को पूरा करता है।", 
    's1_step2_learn': "एक क्लस्टर किसी विशिष्ट श्रेणी (महीने) के लिए संबंधित डेटा (विभिन्न फलों) को समूहित करता है।",
    's1_step3_task': "फरवरी (सेब: 40, संतरे: 35) और मार्च (सेब: 50, संतरे: 45) के लिए क्रेट्स को खींचें और उनके सही स्लॉट में छोड़ें।", 
    's1_step3_obs': "ग्राफ तीन क्लस्टर्स से पूरी तरह भर गया है।", 
    's1_step3_learn': "अब हमारे पास समय के साथ बिक्री का पूर्ण दृश्य प्रतिनिधित्व है।",
    's1_step4_task': "पूर्ण ग्राफ का निरीक्षण करें और 'देखें और आगे बढ़ें' पर क्लिक करें।", 
    's1_step4_obs': "ग्राफ एक नज़र में बिक्री के रुझानों को स्पष्ट रूप से दिखाता है।", 
    's1_step4_learn': "क्लस्टर बार ग्राफ साथ-साथ तुलना को सहज बनाते हैं।", 
    's1_final': "बहुत बढ़िया! ग्राफ से यह देखना आसान हो जाता है कि जनवरी में संतरे बेहतर बिके, लेकिन बाद में सेब आगे निकल गए।",
    's1_jan': "जनवरी", 's1_feb': "फरवरी", 's1_mar': "मार्च", 's1_apples': "सेब", 's1_oranges': "संतरे",
    
    's2_title': "2. गेमिंग प्रतियोगिता", 
    's2_obj': "एक क्लस्टर बार ग्राफ की व्याख्या करना जो कई राउंड में दो गेमर्स के प्रदर्शन की तुलना करता है।",
    's2_step1_task': "प्रिया की 'राउंड 1 ट्रॉफी' (80 अंक) को ग्राफ पर 'राउंड 1' पेडस्टल पर खींचें।", 
    's2_step1_obs': "प्रिया के लिए एक नीला बार दिखाई देता है।", 
    's2_step1_learn': "हम तुलना का पहला बार स्थापित करते हैं।",
    's2_step2_task': "रोहन की 'राउंड 1 ट्रॉफी' (60 अंक) को उसी पेडस्टल पर खींचें।", 
    's2_step2_obs': "प्रिया के नीले बार के बगल में रोहन के लिए एक हरा बार दिखाई देता है।", 
    's2_step2_learn': "राउंड 1 के लिए तुलना पूरी हो गई है।",
    's2_step3_task': "राउंड 2, 3 और 4 के लिए शेष ट्रॉफियों को खींचें और छोड़ें।", 
    's2_step3_obs': "ग्राफ सभी 4 राउंड दिखा रहा है।", 
    's2_step3_learn': "क्लस्टर्स का एक पूरा सेट समग्र प्रवृत्ति को प्रकट करता है।",
    's2_step4_task': "ग्राफ का निरीक्षण करें और 'देखें और आगे बढ़ें' पर क्लिक करें।", 
    's2_step4_obs': "प्रत्येक खिलाड़ी के लिए अलग-अलग पैटर्न उभरते हैं।", 
    's2_step4_learn': "दृश्य डेटा हमें स्थिरता बनाम चरम प्रदर्शन की पहचान करने की अनुमति देता है।", 
    's2_final': "उत्कृष्ट! प्रिया का उच्चतम स्कोर (राउंड 4) था, लेकिन रोहन सभी राउंड में अधिक सुसंगत था।",
    's2_priya': "प्रिया", 's2_rohan': "रोहन", 's2_r1': "R1", 's2_r2': "R2", 's2_r3': "R3", 's2_r4': "R4",

    's3_title': "3. पढ़ने की दौड़", 
    's3_obj': "समय के साथ दो प्रकार की पठन सामग्री (फिक्शन बनाम नॉन-फिक्शन) की तुलना करने वाले ग्राफ का निर्माण और विश्लेषण करना।",
    's3_step1_task': "'फिक्शन' स्टैक (15 किताबें) को 'सप्ताह 1' शेल्फ पर खींचें।", 
    's3_step1_obs': "एक बैंगनी बार फिक्शन पढ़ने को दर्शाता है।", 
    's3_step1_learn': "डेटा विज़ुअलाइज़ेशन आधार मान सेट करने से शुरू होता है।",
    's3_step2_task': "'नॉन-फिक्शन' स्टैक (10 किताबें) को उसी शेल्फ पर खींचें।", 
    's3_step2_obs': "एक पीला बार नॉन-फिक्शन पढ़ने को दर्शाता है।", 
    's3_step2_learn': "विपरीत रंग एक क्लस्टर के भीतर श्रेणियों को अलग करने में मदद करते हैं।",
    's3_step3_task': "सप्ताह 2, 3, और 4 के लिए शेष स्टैक खींचें और छोड़ें।", 
    's3_step3_obs': "सभी चार सप्ताहों की कल्पना की गई है।", 
    's3_step3_learn': "पूरा ग्राफ बनाने से हमें विसंगतियों का पता लगाने में मदद मिलती है।",
    's3_step4_task': "ग्राफ का निरीक्षण करें और 'देखें और आगे बढ़ें' पर क्लिक करें।", 
    's3_step4_obs': "सप्ताह 3 पैटर्न में एक विराम दिखाता है।", 
    's3_step4_learn': "ग्राफ तुरंत सामान्य प्रवृत्तियों के अपवादों को उजागर करते हैं।", 
    's3_final': "बिल्कुल सही! फिक्शन आम तौर पर अधिक लोकप्रिय था, लेकिन सप्ताह 3 में नॉन-फिक्शन में उछाल आया।",
    's3_w1': "सप्ताह 1", 's3_w2': "सप्ताह 2", 's3_w3': "सप्ताह 3", 's3_w4': "सप्ताह 4", 's3_f': "फिक्शन", 's3_nf': "नॉन-फिक्शन",

    's4_title': "4. पार्क आगंतुक", 
    's4_obj': "चरण-दर-चरण मार्गदर्शन के बिना दिए गए डेटा टेबल से क्लस्टर बार ग्राफ बनाना।",
    's4_step1_task': "टेबल से सही 'विज़िटर टोकन' खींचें और उन्हें सही 'सप्ताह के दिन' या 'सप्ताहांत' स्लॉट पर छोड़ें।", 
    's4_step1_obs': "टोकन बार बनाने के लिए अपनी जगह पर आ जाते हैं।", 
    's4_step1_learn': "सारणीबद्ध डेटा को स्थानिक प्रारूप में अनुवाद करने के लिए सावधानीपूर्वक पढ़ने की आवश्यकता होती है।",
    's4_step2_task': "एक बार जब आप ग्राफ बना लें, तो 'मेरा ग्राफ जांचें' पर क्लिक करें।", 
    's4_step2_obs': "ग्राफ मान्य किया गया है।", 
    's4_step2_learn': "काम की जाँच करने से विश्लेषण से पहले डेटा की अखंडता सुनिश्चित होती है।", 
    's4_final': "शानदार! आपने डेटा टेबल को तुलनात्मक विज़ुअलाइज़ेशन में सटीक रूप से बदल दिया।",
    's4_table_title': "पार्क आगंतुक डेटा", 's4_category': "श्रेणी", 's4_kids': "बच्चे", 's4_adults': "वयस्क", 's4_weekday': "सप्ताह का दिन", 's4_weekend': "सप्ताहांत",

    's5_title': "5. स्क्रीन टाइम", 
    's5_obj': "छात्र इनपुट के आधार पर व्यक्तिगत क्लस्टर बार ग्राफ बनाना और परिणामी विज़ुअलाइज़ेशन की व्याख्या करना।",
    's5_step1_task': "शुक्रवार के लिए 'सीखने' और 'मनोरंजन' पर बिताए गए अपने घंटों का अनुमान लगाने के लिए दो स्लाइडर्स को समायोजित करें, फिर 'पुष्टि करें' पर क्लिक करें।", 
    's5_step1_obs': "आपके इनपुट के आधार पर डेटा टोकन उत्पन्न होते हैं।", 
    's5_step1_learn': "डेटा संग्रह व्यक्तिगत विश्लेषण का पहला चरण है।",
    's5_step2_task': "शनिवार और रविवार के लिए स्लाइडर्स समायोजित करें, फिर 'पुष्टि करें' पर क्लिक करें।", 
    's5_step2_obs': "अधिक टोकन उत्पन्न होते हैं।", 
    's5_step2_learn': "एक पूर्ण डेटासेट एकत्र करने से पैटर्न मिलान की अनुमति मिलती है।",
    's5_step3_task': "प्रत्येक उत्पन्न टोकन को ग्राफ कैनवास पर उसके सही दिन पर खींचें।", 
    's5_step3_obs': "एक व्यक्तिगत क्लस्टर बार ग्राफ का निर्माण किया गया है।", 
    's5_step3_learn': "व्यक्तिगत डेटा को विज़ुअलाइज़ करने से अमूर्त संख्याएं मूर्त हो जाती हैं।",
    's5_step4_task': "टेक्स्ट बॉक्स में अपना अवलोकन टाइप करें, फिर 'सबमिट करें' पर क्लिक करें।", 
    's5_step4_obs': "आपका प्रतिबिंब रिकॉर्ड किया गया है।", 
    's5_step4_learn': "ग्राफिंग का अंतिम लक्ष्य सार्थक निष्कर्ष निकालना है।", 
    's5_final': "आपने सफलतापूर्वक व्यक्तिगत डेटा एकत्र किया, इसे विज़ुअलाइज़ किया, और परिणामों की व्याख्या की।",
    's5_input_title': "घंटे दर्ज करें", 's5_learn_lbl': "सीखना", 's5_ent_lbl': "मनोरंजन", 's5_confirm_btn': "डेटा की पुष्टि करें", 
    's5_fri': "शुक्रवार", 's5_sat': "शनिवार", 's5_sun': "रविवार",
    's5_reflect_title': "अंतिम प्रतिबिंब", 's5_reflect_desc': "सप्ताहांत में आपके स्क्रीन टाइम की आदतों के बारे में आपका ग्राफ आपको क्या बताता है?", 's5_reflect_placeholder': "अपनी टिप्पणियां यहां टाइप करें...",
    
    'footer': "© ZeroScienceLab - Fall in love with math and Science"
  }
};

// --- Models ---
class DraggableItem {
  String id, type, day, group;
  int val, r, zIndex;
  double x, y, homeX, homeY, targetX, targetY;
  bool isDragging, isSnapped, active, isError, isSource;
  Color? color;

  DraggableItem({
    required this.id, required this.type, required this.val,
    required this.x, required this.y,
    this.r = 0, this.day = '', this.group = '',
    this.zIndex = 0, this.isSource = false, this.active = true,
    this.color,
  })  : targetX = x, targetY = y, homeX = x, homeY = y,
        isDragging = false, isSnapped = false, isError = false;
}

class Dropzone {
  String id, type, day;
  int r;
  double x, y, w, h;
  String? occupied;

  Dropzone({
    required this.id, required this.x, required this.y, 
    required this.w, required this.h,
    this.r = 0, this.type = '', this.day = '',
  });
}

class ScenarioStep {
  final String task;
  final String obs;
  final String learn;
  ScenarioStep(this.task, this.obs, this.learn);
}

// --- Main Screen ---
class DataVisualizationClustered extends StatefulWidget {
  const DataVisualizationClustered({Key? key}) : super(key: key);

  @override
  State<DataVisualizationClustered> createState() => _DataVisualizationClusteredState();
}

class _DataVisualizationClusteredState extends State<DataVisualizationClustered> with SingleTickerProviderStateMixin {
  bool _isSidebarOpen = true;
  String _lang = 'en';
  bool _showCurtain = true;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _reflectionController = TextEditingController();

  late Ticker _ticker;
  final ValueNotifier<int> _tickNotifier = ValueNotifier<int>(0); 
  bool _isDraggingAnyItem = false;
  
  int _scenario = 1;
  int _step = 0;
  
  List<DraggableItem> _draggables = [];
  List<Dropzone> _dropzones = [];
  
  bool _showSuccess = false;
  String _errorMsg = '';
  int _maxVal = 60;
  
  // S5 State
  double _s5LearnHours = 0;
  double _s5EntHours = 0;
  
  // Animation State
  bool _isAnimating = false;
  double _progress = 0.0;
  DraggableItem? _activeBar;
  int _shakeTimer = 0;

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
    _reflectionController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  List<ScenarioStep> _getStepsForScenario(int scenarioId) {
    int maxSteps = scenarioId == 4 ? 2 : 4;
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
    _showSuccess = false;
    _errorMsg = '';
    _isAnimating = false;
    _progress = 0.0;
    _activeBar = null;
    _shakeTimer = 0;

    if (s == 1) {
      _maxVal = 60;
      List<Map<String, dynamic>> mData = [ 
        {'m':'Jan', 'a':20, 'o':30}, 
        {'m':'Feb', 'a':40, 'o':35}, 
        {'m':'Mar', 'a':50, 'o':45} 
      ];
      double gX = 50, gY = 150, spacing = 110;
      for (int r = 0; r < mData.length; r++) {
        double cX = gX + spacing * (r + 1);
        _dropzones.add(Dropzone(id: '${mData[r]['m']}_a', x: cX - 16, y: gY, w: 40, h: 200, r: r, type: 'A'));
        _dropzones.add(Dropzone(id: '${mData[r]['m']}_o', x: cX + 16, y: gY, w: 40, h: 200, r: r, type: 'O'));

        double spawnYA = 110 - (r * 40.0);
        double spawnYO = 110 - (r * 40.0);
        double spawnXA = -325;
        double spawnXO = -400;

        _draggables.add(DraggableItem(id: 'D_${mData[r]['m']}_a', val: mData[r]['a'], type: 'A', r: r, x: spawnXA, y: spawnYA, active: r == 0));
        _draggables.add(DraggableItem(id: 'D_${mData[r]['m']}_o', val: mData[r]['o'], type: 'O', r: r, x: spawnXO, y: spawnYO, active: false));
      }
    } else if (s == 2) {
      _maxVal = 100;
      List<Map<String, dynamic>> mData = [ 
        {'m':'R1', 'p':80, 'r':60}, {'m':'R2', 'p':70, 'r':75}, 
        {'m':'R3', 'p':50, 'r':70}, {'m':'R4', 'p':90, 'r':65} 
      ];
      double originX = -130, spacing = 90;
      for (int r = 0; r < mData.length; r++) {
        double gx = originX + r * spacing; double gy = 110;
        _dropzones.add(Dropzone(id: '${mData[r]['m']}_p', x: gx - 16, y: gy, w: 40, h: 200, r: r, type: 'P'));
        _dropzones.add(Dropzone(id: '${mData[r]['m']}_r', x: gx + 16, y: gy, w: 40, h: 200, r: r, type: 'R'));

        double spawnXP, spawnYP, spawnXR, spawnYR;
        if (r == 0) {
          spawnXP = 40; spawnYP = -100; spawnXR = 40; spawnYR = -100;
        } else {
          spawnXP = -150 + ((r - 1) % 3) * 60.0; spawnYP = -110;
          spawnXR = -150 + ((r - 1) % 3) * 60.0; spawnYR = -60;
        }
        _draggables.add(DraggableItem(id: 'D_${mData[r]['m']}_p', val: mData[r]['p'], type: 'P', r: r, x: spawnXP, y: spawnYP, active: r == 0));
        _draggables.add(DraggableItem(id: 'D_${mData[r]['m']}_r', val: mData[r]['r'], type: 'R', r: r, x: spawnXR, y: spawnYR, active: false));
      }
    } else if (s == 3) {
      _maxVal = 25;
      List<Map<String, dynamic>> mData = [ 
        {'m':'W1', 'f':15, 'nf':10}, {'m':'W2', 'f':18, 'nf':12}, 
        {'m':'W3', 'f':14, 'nf':15}, {'m':'W4', 'f':20, 'nf':10} 
      ];
      double originX = -130, spacing = 90;
      for (int r = 0; r < mData.length; r++) {
        double gx = originX + r * spacing; double gy = 110;
        _dropzones.add(Dropzone(id: '${mData[r]['m']}_f', x: gx - 16, y: gy, w: 40, h: 200, r: r, type: 'F'));
        _dropzones.add(Dropzone(id: '${mData[r]['m']}_nf', x: gx + 16, y: gy, w: 40, h: 200, r: r, type: 'NF'));

        double spawnXF, spawnYF, spawnXNF, spawnYNF;
        if (r == 0) {
          spawnXF = 40; spawnYF = -100; spawnXNF = 40; spawnYNF = -100;
        } else {
          spawnXF = -150 + ((r - 1) % 3) * 60.0; spawnYF = -110;
          spawnXNF = -150 + ((r - 1) % 3) * 60.0; spawnYNF = -60;
        }
        _draggables.add(DraggableItem(id: 'D_${mData[r]['m']}_f', val: mData[r]['f'], type: 'F', r: r, x: spawnXF, y: spawnYF, active: r == 0));
        _draggables.add(DraggableItem(id: 'D_${mData[r]['m']}_nf', val: mData[r]['nf'], type: 'NF', r: r, x: spawnXNF, y: spawnYNF, active: false));
      }
    } else if (s == 4) {
      _maxVal = 100;
      double originX = 180, originY = 150, spacing = 200;
      _dropzones = [
        Dropzone(id: 'wd_k', x: originX - 35, y: originY, w: 60, h: 60, type: 'K', day: 'WD'),
        Dropzone(id: 'wd_a', x: originX + 35, y: originY, w: 60, h: 60, type: 'A', day: 'WD'),
        Dropzone(id: 'we_k', x: originX + spacing - 35, y: originY, w: 60, h: 60, type: 'K', day: 'WE'),
        Dropzone(id: 'we_a', x: originX + spacing + 35, y: originY, w: 60, h: 60, type: 'A', day: 'WE'),
      ];
      _draggables = [
        DraggableItem(id: 't1', val: 30, type: 'K', day: 'WD', x: -280, y: 70, color: const Color(0xFF4F46E5)),
        DraggableItem(id: 't2', val: 80, type: 'K', day: 'WE', x: -180, y: 70, color: const Color(0xFF4F46E5)),
        DraggableItem(id: 't3', val: 50, type: 'A', day: 'WD', x: -280, y: 150, color: const Color(0xFFEF4444)),
        DraggableItem(id: 't4', val: 70, type: 'A', day: 'WE', x: -180, y: 150, color: const Color(0xFFEF4444)),
      ];
    } else if (s == 5) {
      _maxVal = 10;
      double originX = -100, originY = 150, spacing = 150;
      _dropzones = [
        Dropzone(id: 'fri_l', x: originX - 25, y: originY, w: 50, h: 50, type: 'L', day: 'Fri'),
        Dropzone(id: 'fri_e', x: originX + 25, y: originY, w: 50, h: 50, type: 'E', day: 'Fri'),
        Dropzone(id: 'sat_l', x: originX + spacing - 25, y: originY, w: 50, h: 50, type: 'L', day: 'Sat'),
        Dropzone(id: 'sat_e', x: originX + spacing + 25, y: originY, w: 50, h: 50, type: 'E', day: 'Sat'),
        Dropzone(id: 'sun_l', x: originX + spacing*2 - 25, y: originY, w: 50, h: 50, type: 'L', day: 'Sun'),
        Dropzone(id: 'sun_e', x: originX + spacing*2 + 25, y: originY, w: 50, h: 50, type: 'E', day: 'Sun'),
      ];
      _s5LearnHours = 0;
      _s5EntHours = 0;
      _reflectionController.clear();
    }

    _tickNotifier.value++;
    setState(() {});
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _startTickerIfNeeded() {
    if (!_ticker.isTicking) _ticker.start();
  }

  void _handleReset() {
    AudioEngine.playError();
    setState(() { 
      _showCurtain = true; 
      _lang = 'en'; 
    });
  }

  void _toggleLanguage() {
    AudioEngine.playClick();
    setState(() {
      if (_lang == 'en') _lang = 'hi';
      else _lang = 'en';
    });
  }

  void _updateSimulation() {
    bool isAnimatingLocal = false;
    bool needsRepaint = false;

    for (var d in _draggables) {
      if ((d.x - d.targetX).abs() > 0.5 || (d.y - d.targetY).abs() > 0.5) {
        d.x += (d.targetX - d.x) * 0.2;
        d.y += (d.targetY - d.y) * 0.2;
        isAnimatingLocal = true;
        needsRepaint = true;
      } else if (d.x != d.targetX || d.y != d.targetY) {
        d.x = d.targetX;
        d.y = d.targetY;
        needsRepaint = true;
      }
      
      if (_scenario == 4 && _shakeTimer > 0 && !d.isDragging && d.isSnapped && d.isError) {
        d.x += (Random().nextDouble() - 0.5) * 10;
        needsRepaint = true;
        isAnimatingLocal = true;
      }
    }

    if (_shakeTimer > 0) {
      _shakeTimer--;
      isAnimatingLocal = true;
      needsRepaint = true;
    }

    if (_isAnimating) {
      _progress += 0.02;
      isAnimatingLocal = true;
      needsRepaint = true;
      if (_progress >= 1.0) {
        _isAnimating = false;
        AudioEngine.playPop();
        _activeBar = null;
        if (_step < 3 && _scenario <= 3) {
          int expectedSnapped = (_step == 0) ? 1 : (_step == 1) ? 2 : 6;
          if (_scenario > 1 && _step == 2) expectedSnapped = 8;
          if (_draggables.where((d) => d.isSnapped).length >= expectedSnapped) {
             _advanceStep();
          }
        }
      }
    }

    if (!isAnimatingLocal && !_isDraggingAnyItem && _ticker.isTicking) {
      _ticker.stop();
    }

    if (needsRepaint) {
      _tickNotifier.value++;
    }
  }

  void _advanceStep() {
    setState(() { _step++; });
    if (_scenario <= 3) {
      if (_step == 1) {
        for (var d in _draggables) {
          if (d.r == 0 && (d.type == 'O' || d.type == 'R' || d.type == 'NF')) d.active = true;
        }
      }
      if (_step == 2) {
        for (var d in _draggables) { if (d.r > 0) d.active = true; }
      }
    }
    
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
        }
      });
    }
  }

  void _checkScenarioSuccess() {
    int maxSteps = _scenario == 4 ? 2 : 4;
    setState(() {
      _step = maxSteps;
      _showSuccess = true;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      AudioEngine.playSuccess();
    });
  }

  void _onPointerDown(PointerDownEvent details) {
    if (_showCurtain || _showSuccess) return;

    double worldX = details.localPosition.dx - 600;
    double worldY = details.localPosition.dy - 400;

    _draggables.sort((a, b) => b.zIndex.compareTo(a.zIndex));
    
    for (int i = _draggables.length - 1; i >= 0; i--) {
      var d = _draggables[i];
      if (!d.active || d.isSnapped) continue;

      double w = 60, h = 80;
      if (_scenario == 4 || _scenario == 5) {
        w = 50; h = 50;
      }
      
      bool hit = false;
      if (_scenario <= 3) {
        if (worldX >= d.x - w/2 && worldX <= d.x + w/2 && worldY >= d.y - h/2 && worldY <= d.y + h/2) hit = true;
      } else {
        if (sqrt(pow(d.x - worldX, 2) + pow(d.y - worldY, 2)) <= 30) hit = true;
      }

      if (hit) {
        AudioEngine.playClick();
        setState(() {
          _isDraggingAnyItem = true;
          d.isDragging = true;
          _draggables.removeAt(i);
          _draggables.add(d); 
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
          if (_scenario == 4 || _scenario == 5) {
            if (sqrt(pow(active.targetX - dz.x, 2) + pow(active.targetY - dz.y, 2)) < 60) hit = true;
          } else if (_scenario <= 3) {
            if ((active.targetX - dz.x).abs() < 40 && (active.targetY - dz.y).abs() < 150) hit = true;
          }

          if (hit) {
            bool valid = false;
            if (_scenario == 1) {
              if (_step == 0 && active.r == 0 && active.type == 'A' && dz.r == 0 && dz.type == 'A') valid = true;
              if (_step == 1 && active.r == 0 && active.type == 'O' && dz.r == 0 && dz.type == 'O') valid = true;
              if (_step == 2 && active.r > 0 && active.r == dz.r && active.type == dz.type) valid = true;
            } else if (_scenario == 2) {
              if (_step == 0 && active.r == 0 && active.type == 'P' && dz.r == 0 && dz.type == 'P') valid = true;
              if (_step == 1 && active.r == 0 && active.type == 'R' && dz.r == 0 && dz.type == 'R') valid = true;
              if (_step == 2 && active.r > 0 && active.r == dz.r && active.type == dz.type) valid = true;
            } else if (_scenario == 3) {
              if (_step == 0 && active.r == 0 && active.type == 'F' && dz.r == 0 && dz.type == 'F') valid = true;
              if (_step == 1 && active.r == 0 && active.type == 'NF' && dz.r == 0 && dz.type == 'NF') valid = true;
              if (_step == 2 && active.r > 0 && active.r == dz.r && active.type == dz.type) valid = true;
            } else if (_scenario == 4) {
              if (dz.occupied == null) valid = true; 
            } else if (_scenario == 5) {
              if (_step == 2 && dz.occupied == null) valid = true; 
            }

            if (valid) {
              active.isSnapped = true; 
              snapped = true;
              active.targetX = dz.x; 
              active.targetY = dz.y;
              dz.occupied = active.id;
              
              if (_scenario < 4) {
                _isAnimating = true; 
                _progress = 0; 
                _activeBar = active;
              } else {
                AudioEngine.playSnap();
              }
              
              if (_scenario == 4 && _step == 0) {
                if (_draggables.where((d) => d.isSnapped).length == 4) {
                  _advanceStep();
                }
              }
              break;
            }
          }
        }

        if (!snapped) { 
          AudioEngine.playError(); 
          active.targetX = active.homeX; 
          active.targetY = active.homeY; 
          active.isSnapped = false; 
        }
      });
      _startTickerIfNeeded();
    }
  }

  void _onCheckGraph() {
    AudioEngine.playClick();
    bool allCorrect = true;
    for (var d in _draggables) {
      if (!d.isSnapped) { allCorrect = false; continue; }
      var dz = _dropzones.firstWhere((z) => z.x == d.targetX && z.y == d.targetY, orElse: () => Dropzone(id: 'null', x: 0, y: 0, w: 0, h: 0));
      if (dz.id == 'null' || dz.type != d.type || dz.day != d.day) {
        allCorrect = false; d.isError = true;
      } else {
        d.isError = false;
      }
    }

    if (_draggables.where((d) => d.isSnapped).length < 4) { AudioEngine.playError(); return; }

    if (allCorrect) {
      _checkScenarioSuccess();
    } else {
      AudioEngine.playError();
      setState(() { _shakeTimer = 30; });
      _startTickerIfNeeded();
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          for (var d in _draggables) {
            if (d.isError) {
              d.targetX = d.homeX; d.targetY = d.homeY; d.isSnapped = false; d.isError = false;
              for (var dz in _dropzones) { if (dz.occupied == d.id) dz.occupied = null; }
            }
          }
        });
      });
    }
  }

  void _onS5ConfirmSliders() {
    AudioEngine.playPop();
    setState(() {
      if (_step == 0) {
        _draggables.add(DraggableItem(id: 'fri_l', val: _s5LearnHours.toInt(), type: 'L', day: 'Fri', x: -400, y: -100, color: const Color(0xFF10B981)));
        _draggables.add(DraggableItem(id: 'fri_e', val: _s5EntHours.toInt(), type: 'E', day: 'Fri', x: -300, y: -100, color: const Color(0xFFF43F5E)));
        _s5LearnHours = 0; _s5EntHours = 0;
        _advanceStep();
      } else if (_step == 1) {
        int satL = _s5LearnHours.toInt(); int satE = _s5EntHours.toInt();
        int sunL = max(0, satL - 1); int sunE = satE + 1;
        _draggables.add(DraggableItem(id: 'sat_l', val: satL, type: 'L', day: 'Sat', x: -400, y: 0, color: const Color(0xFF10B981)));
        _draggables.add(DraggableItem(id: 'sat_e', val: satE, type: 'E', day: 'Sat', x: -300, y: 0, color: const Color(0xFFF43F5E)));
        _draggables.add(DraggableItem(id: 'sun_l', val: sunL, type: 'L', day: 'Sun', x: -400, y: 100, color: const Color(0xFF10B981)));
        _draggables.add(DraggableItem(id: 'sun_e', val: sunE, type: 'E', day: 'Sun', x: -300, y: 100, color: const Color(0xFFF43F5E)));
        _advanceStep();
      }
    });
  }

  String _getCurrentHud() {
    int displayStep = _step + 1;
    int maxSteps = _scenario == 4 ? 2 : 4;
    if (displayStep > maxSteps) displayStep = maxSteps; 
    String key = 's${_scenario}_step${displayStep}_task';
    return strings[_lang]?[key] ?? '';
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sidebarWidth = sw * 0.38; 
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
                panEnabled: !_isDraggingAnyItem, 
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
                        step: _step,
                        draggables: _draggables,
                        dropzones: _dropzones,
                        maxVal: _maxVal,
                        isAnimating: _isAnimating,
                        progress: _progress,
                        activeBar: _activeBar,
                        showSuccess: _showSuccess,
                        lang: _lang,
                        errorMsg: _errorMsg,
                        currentHud: _getCurrentHud(),
                        repaint: _tickNotifier,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // S5 Overlays on top of Canvas
            if (_scenario == 5 && (_step == 0 || _step == 1))
              Positioned(
                left: 100,
                top: 48,
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF1E293B).withOpacity(0.95),
                  child: Container(
                    width: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Text(
                            _step == 0 ? "${t('s5_fri')} ${t('s5_input_title')}".toUpperCase() : "WEEKEND ${t('s5_input_title')}".toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(t('s5_learn_lbl'), style: const TextStyle(color: Colors.white70)),
                                  Text("${_s5LearnHours.toInt()} hrs", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Slider(
                                value: _s5LearnHours,
                                min: 0, max: 10, divisions: 10,
                                activeColor: Colors.green,
                                onChanged: (val) {
                                  AudioEngine.playClick();
                                  setState(() { _s5LearnHours = val; });
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(t('s5_ent_lbl'), style: const TextStyle(color: Colors.white70)),
                                  Text("${_s5EntHours.toInt()} hrs", style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Slider(
                                value: _s5EntHours,
                                min: 0, max: 10, divisions: 10,
                                activeColor: Colors.pink,
                                onChanged: (val) {
                                  AudioEngine.playClick();
                                  setState(() { _s5EntHours = val; });
                                },
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 44)),
                                onPressed: _onS5ConfirmSliders,
                                child: Text(t('s5_confirm_btn'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

            if (_scenario == 5 && _step == 3)
              Positioned(
                left: sw / 2 - 175,
                top: MediaQuery.of(context).size.height / 2 - 100,
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF1E293B).withOpacity(0.95),
                  child: Container(
                    width: 350,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t('s5_reflect_title'), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(t('s5_reflect_desc'), style: const TextStyle(color: Colors.white70, fontSize: 13), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _reflectionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            filled: true, fillColor: Colors.white10,
                            hintText: t('s5_reflect_placeholder'), hintStyle: const TextStyle(color: Colors.white30),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 44)),
                          onPressed: () {
                            if (_reflectionController.text.length > 5) {
                              _checkScenarioSuccess();
                            } else {
                              AudioEngine.playError();
                            }
                          },
                          child: const Text("Submit Observation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      ],
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
                  if (_scenario <= 3 && _step == 3 && !_showSuccess)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.analytics, size: 28),
                      label: Text(t('btn_observe'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      onPressed: () {
                        AudioEngine.playSuccess();
                        _checkScenarioSuccess();
                      },
                    ),
                  if (_scenario == 4 && _step == 1 && !_showSuccess)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle, size: 28),
                      label: Text(t('btn_check_graph'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      onPressed: _onCheckGraph,
                    ),
                  if (_scenario == 5 && _step == 2 && !_showSuccess)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle, size: 28),
                      label: Text(t('btn_finalize_graph'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      onPressed: () {
                        if (_draggables.every((d) => d.isSnapped)) {
                          AudioEngine.playSuccess(); _advanceStep();
                        } else {
                          AudioEngine.playError();
                        }
                      },
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
                  physics: const ClampingScrollPhysics(), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Content with Back Button explicitly matched
                      Padding(
                        padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 16), 
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
                            Text(t('appSubtitle'), style: const TextStyle(fontSize: 11, color: Colors.blueAccent)),
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
                                      border: Border.all(color: Colors.blue.withOpacity(0.5))
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.language, color: Colors.blueAccent, size: 18),
                                        const SizedBox(width: 8),
                                        Text(_lang.toUpperCase(), style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.bold)),
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
                                border: Border.all(color: Colors.blue.withOpacity(0.5))
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
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.withOpacity(0.3))
                              ),
                              child: Text(t('s${_scenario}_obj'), style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4)),
                            ),
                            const SizedBox(height: 24),

                            // Steps List
                            ...List.generate(scenarioSteps.length, (index) {
                              bool isCompleted = index < _step;
                              bool isActive = index == _step;
                              bool isLocked = index > _step;

                              Color bgColor = isLocked ? Colors.white10 : (isActive ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.05));
                              Color borderColor = isLocked ? Colors.transparent : (isActive ? Colors.blue : Colors.blue.withOpacity(0.3));

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
                                          ? const Icon(Icons.check_circle, color: Colors.blue)
                                          : CircleAvatar(
                                              radius: 12,
                                              backgroundColor: isActive ? Colors.blue : Colors.grey,
                                              child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                            ),
                                        const SizedBox(width: 8),
                                        Text("${t('stepLabel')} ${index + 1}", style: TextStyle(color: isActive ? Colors.blueAccent : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(text: "${t('actTitle')} ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                                          TextSpan(text: scenarioSteps[index].task, style: TextStyle(color: isLocked ? Colors.grey : Colors.white)),
                                        ]
                                      )
                                    ),
                                    if (isCompleted)
                                      Container(
                                        margin: const EdgeInsets.only(top: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.blue.withOpacity(0.3))
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
                            if (_showSuccess && _scenario <= 4)
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
                                        t('s${_scenario}_final'),
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
              top: 24, 
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
                        border: Border.all(color: Colors.blue)
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
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
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
                        const Icon(Icons.insert_chart, size: 80, color: Colors.blueAccent),
                        const SizedBox(height: 24),
                        Text(t('shutterTitle'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 12),
                        Text(t('appSubtitle'), style: const TextStyle(fontSize: 18, color: Colors.blue)),
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
                            backgroundColor: Colors.blue,
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
  final int step;
  final List<DraggableItem> draggables;
  final List<Dropzone> dropzones;
  final int maxVal;
  final bool isAnimating;
  final double progress;
  final DraggableItem? activeBar;
  final bool showSuccess;
  final String lang;
  final String errorMsg;
  final String currentHud;

  String t(String key) => strings[lang]?[key] ?? key;

  LabCanvasPainter({
    required this.scenario,
    required this.step,
    required this.draggables,
    required this.dropzones,
    required this.maxVal,
    required this.isAnimating,
    required this.progress,
    required this.activeBar,
    required this.showSuccess,
    required this.lang,
    required this.errorMsg,
    required this.currentHud,
    Listenable? repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    _drawBackground(canvas, scenario);

    if (scenario == 1) {
      _drawGraphGridS1(canvas);
      _drawTruckS1(canvas);
    } else if (scenario == 2 || scenario == 3) {
      _drawGraphGridS2S3(canvas, scenario);
    } else {
      _drawGraphGridS4S5(canvas, scenario);
    }

    if (scenario == 4 && showSuccess) {
      final textSpan = const TextSpan(text: "Well Done!", style: TextStyle(color: Colors.greenAccent, fontSize: 40, fontWeight: FontWeight.bold));
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(50 - textPainter.width/2, -100 - textPainter.height/2));
    }

    // Draw dropzones base
    for (var dz in dropzones) {
      if (scenario == 4) {
        _drawCylinder(canvas, dz.x, dz.y, 50, 8, const Color(0xFF334155), const Color(0xFF1E293B));
        String txt = dz.type == 'K' ? t('s4_kids') : t('s4_adults');
        _drawTextOutline(canvas, txt, dz.x, dz.y + 18, Colors.blueGrey.shade300, 11);
      } else if (scenario == 5) {
        if (dz.occupied == null) {
          final p = Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 2;
          canvas.drawRect(Rect.fromLTWH(dz.x - 20, dz.y - 10, 40, 20), p);
        }
      }
    }

    // Draw snapped bars
    double scaleF = 300 / 60;
    if (scenario == 1) scaleF = 4.5;
    if (scenario == 2) scaleF = 2.5;
    if (scenario == 3) scaleF = 10;
    if (scenario == 4) scaleF = 3;
    if (scenario == 5) scaleF = 30;

    for (var d in draggables) {
      if (d.isSnapped) {
        double h = d.val * scaleF;
        double displayH = h;
        if (isAnimating && activeBar?.id == d.id) {
          displayH = h * progress;
        }

        Color bCol = Colors.red, sCol = Colors.red.shade900, tCol = Colors.redAccent;
        if (d.type == 'O') { bCol = Colors.orange; sCol = Colors.orange.shade900; tCol = Colors.orangeAccent; }
        if (d.type == 'P') { bCol = Colors.blue; sCol = Colors.blue.shade900; tCol = Colors.blueAccent; }
        if (d.type == 'R') { bCol = Colors.green; sCol = Colors.green.shade900; tCol = Colors.greenAccent; }
        if (d.type == 'F') { bCol = Colors.purple; sCol = Colors.purple.shade900; tCol = Colors.purpleAccent; }
        if (d.type == 'NF') { bCol = Colors.yellow; sCol = Colors.yellow.shade900; tCol = Colors.yellowAccent; }
        
        if (scenario == 4 || scenario == 5) {
          bCol = d.color ?? Colors.grey; sCol = const Color(0xFF0F172A); tCol = d.color ?? Colors.grey;
        }
        if (scenario == 4 && d.isError) {
          bCol = Colors.red; sCol = const Color(0xFF0F172A); tCol = Colors.red;
        }

        if (scenario == 1) {
          canvas.drawRect(Rect.fromLTWH(d.targetX - 15, d.targetY - displayH, 30, displayH), Paint()..color = bCol);
          canvas.drawRect(Rect.fromLTWH(d.targetX - 15, d.targetY - displayH, 30, displayH), Paint()..color = sCol..style = PaintingStyle.stroke..strokeWidth = 2);
          _drawCrate(canvas, d.targetX, d.targetY + 30, d.type, d.val, scale: 0.55); // Draw original item at bottom
        } else if (scenario == 2 || scenario == 3) {
          _drawCylinder(canvas, d.targetX, d.targetY, 30, displayH, tCol, bCol);
          if (scenario == 2) {
             String lbl = d.type == 'P' ? t('s2_priya') : t('s2_rohan');
             _drawTrophy(canvas, d.targetX, d.targetY + 40, tCol, lbl, d.val, scale: 0.55);
          } else {
             String lbl = d.type == 'F' ? t('s3_f') : t('s3_nf');
             _drawBookStack(canvas, d.targetX, d.targetY + 35, bCol, lbl, d.val, scale: 0.55);
          }
        } else if (scenario == 4 || scenario == 5) {
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(d.targetX - 20, d.targetY - displayH, 40, displayH), const Radius.circular(4)), Paint()..color = bCol);
          canvas.drawRect(Rect.fromLTWH(d.targetX - 20, d.targetY - displayH, 40, displayH), Paint()..color = sCol..style = PaintingStyle.stroke..strokeWidth = 1);
          Color shadowCol = bCol.value == 0xFF4F46E5 || bCol.value == 0xFF3B82F6 || bCol.value == 0xFF10B981 ? Colors.indigo.shade800 : Colors.red.shade900;
          _drawCylinder(canvas, d.targetX, d.targetY, 46, 8, bCol, shadowCol);
          _drawTextOutline(canvas, d.val.toString(), d.targetX, d.targetY - displayH - 12, Colors.white, 12);
        }

        if (scenario != 1 && scenario != 4 && scenario != 5 && (!isAnimating || activeBar?.id != d.id)) {
           _drawTextOutline(canvas, d.val.toString(), d.targetX, d.targetY - displayH - 15, Colors.white, 14);
        }
      }
    }

    // Draw unsnapped draggables
    var renderList = List<DraggableItem>.from(draggables);
    renderList.sort((a, b) => (a.isDragging ? 1 : 0).compareTo(b.isDragging ? 1 : 0));

    for (var d in renderList) {
      if (d.isSnapped && scenario < 4) continue;
      if (d.isSnapped && (scenario == 4 || scenario == 5) && !d.isDragging) continue;
      if (!d.active && scenario < 4) continue;

      canvas.save();
      canvas.translate(d.x, d.y);
      if (d.isDragging) canvas.scale(1.1);

      if (scenario == 1) {
        _drawCrate(canvas, 0, 0, d.type, d.val);
      } else if (scenario == 2) {
        Color tCol = d.type == 'P' ? Colors.blue : Colors.green;
        String labelName = d.type == 'P' ? t('s2_priya') : t('s2_rohan');
        _drawTrophy(canvas, 0, -10, tCol, labelName, d.val);
      } else if (scenario == 3) {
        Color bCol = d.type == 'F' ? Colors.purple : Colors.yellow;
        String labelName = d.type == 'F' ? t('s3_f') : t('s3_nf');
        _drawBookStack(canvas, 0, -10, bCol, labelName, d.val);
      } else if (scenario == 4) {
        Color tokenColor = d.isError ? Colors.red : (d.color ?? Colors.grey);
        Color shadowCol = tokenColor.value == 0xFF4F46E5 || tokenColor.value == 0xFF3B82F6 ? Colors.indigo.shade800 : Colors.red.shade900;
        _drawCylinder(canvas, 0, 0, 40, 8, tokenColor, shadowCol);
        _drawTextOutline(canvas, d.val.toString(), 0, -5, Colors.white, 12);
      } else if (scenario == 5) {
        Color tokenColor = d.color ?? Colors.grey;
        Color shadowCol = tokenColor.value == 0xFF10B981 ? Colors.green.shade800 : Colors.pink.shade800; 
        _drawCylinder(canvas, 0, 0, 40, 8, tokenColor, shadowCol);
        _drawTextOutline(canvas, d.val.toString(), 0, -5, Colors.white, 12);
      }

      canvas.restore();
    }

    if (scenario == 4 && step < 2) {
      _drawTableS4(canvas);
    }

    // Draw HUD banner at the bottom if applicable
    if (currentHud.isNotEmpty && !showSuccess) {
      final RRect hudRect = RRect.fromRectAndRadius(const Rect.fromLTWH(-350, 330, 700, 44), const Radius.circular(22));
      canvas.drawRRect(hudRect, Paint()..color = const Color(0xFF1E293B).withOpacity(0.9));
      canvas.drawRRect(hudRect, Paint()..color = Colors.blue..style = PaintingStyle.stroke..strokeWidth = 2);
      _drawTextOutline(canvas, currentHud, 0, 352, Colors.white, 16);
    }

    canvas.restore(); 
  }

  void _drawBackground(Canvas canvas, int s) {
    canvas.drawRect(const Rect.fromLTWH(-1000, 100, 2000, 400), Paint()..color = const Color(0xFF1E293B));
    canvas.drawRect(const Rect.fromLTWH(-1000, 100, 2000, 10), Paint()..color = const Color(0xFF334155));

    if (s != 4 && s != 5) {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-250, -220, 500, 200), const Radius.circular(4)), Paint()..color = const Color(0xFFE2E8F0));
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-250, -220, 500, 200), const Radius.circular(4)), Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 6);
      canvas.drawRect(const Rect.fromLTWH(-240, -26, 480, 6), Paint()..color = const Color(0xFF94A3B8));
    }
  }

  void _drawGraphGridS1(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(10, -140, 430, 320), const Radius.circular(10)), Paint()..color = const Color(0xFF1E293B).withOpacity(0.5));
    canvas.drawLine(const Offset(50, 150), const Offset(420, 150), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2);
    canvas.drawLine(const Offset(50, 150), const Offset(50, -130), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2);

    for (int i = 0; i <= 60; i += 10) {
      double y = 150 - (i * 4.5);
      canvas.drawLine(Offset(50, y), Offset(420, y), Paint()..color = Colors.white10);
      _drawTextOutline(canvas, i.toString(), 30, y, const Color(0xFFCBD5E1), 12);
    }
    
    List<String> mLabels = [t('s1_jan'), t('s1_feb'), t('s1_mar')];
    for (int i = 0; i < mLabels.length; i++) {
      double cX = 50 + 110.0 * (i + 1);
      _drawTextOutline(canvas, mLabels[i], cX, 160, const Color(0xFFCBD5E1), 13);
      if ((step == 0 || step == 1) && i == 0) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cX - 45, -125, 90, 305), const Radius.circular(8)), Paint()..color = Colors.yellow.withOpacity(0.1));
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cX - 45, -125, 90, 305), const Radius.circular(8)), Paint()..color = Colors.yellow..style = PaintingStyle.stroke..strokeWidth = 3);
      } else if (step == 2 && i > 0) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cX - 45, -125, 90, 305), const Radius.circular(8)), Paint()..color = Colors.yellow..style = PaintingStyle.stroke..strokeWidth = 3);
      }
    }
  }

  void _drawTruckS1(Canvas canvas) {
    canvas.save();
    final Paint bedPaint = Paint()..color = const Color(0xFF475569); // slate-600
    final Paint cabPaint = Paint()..color = const Color(0xFF1E40AF); // blue-800
    final Paint windowPaint = Paint()..color = Colors.lightBlueAccent.withOpacity(0.5);
    final Paint wheelPaint = Paint()..color = const Color(0xFF0F172A); // slate-900
    final Paint rimPaint = Paint()..color = const Color(0xFF94A3B8); // slate-400

    // Truck Bed
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-470, 135, 230, 20), const Radius.circular(4)), bedPaint);
    
    // Truck Cabin
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-240, 40, 90, 115), const Radius.circular(8)), cabPaint);
    
    // Window
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-230, 50, 50, 40), const Radius.circular(4)), windowPaint);
    
    // Wheels
    void drawWheel(double wx, double wy) {
      canvas.drawCircle(Offset(wx, wy), 20, wheelPaint);
      canvas.drawCircle(Offset(wx, wy), 10, rimPaint);
      canvas.drawCircle(Offset(wx, wy), 4, wheelPaint);
    }
    
    drawWheel(-410, 155);
    drawWheel(-330, 155);
    drawWheel(-190, 155);

    canvas.restore();
  }

  void _drawGraphGridS2S3(Canvas canvas, int s) {
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-260, -180, 520, 370), const Radius.circular(10)), Paint()..color = const Color(0xFF1E293B));
    
    int yMax = s == 2 ? 100 : 25;
    int yStep = s == 2 ? 20 : 5;
    double scale = s == 2 ? 2.5 : 10.0;
    double base_y = 110;

    for (int i = 0; i <= yMax; i += yStep) {
      double y = base_y - (i * scale);
      canvas.drawLine(Offset(-200, y), Offset(240, y), Paint()..color = Colors.white10);
      _drawTextOutline(canvas, i.toString(), -220, y, const Color(0xFFCBD5E1), 14);
    }
    canvas.drawLine(Offset(-200, base_y), Offset(-200, base_y - 250), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.5);

    List<String> xLabels = s == 2 ? [t('s2_r1'), t('s2_r2'), t('s2_r3'), t('s2_r4')] : [t('s3_w1'), t('s3_w2'), t('s3_w3'), t('s3_w4')];
    double spacing = 90; double originX = -130;
    
    for (int i = 0; i < xLabels.length; i++) {
      double cX = originX + i * spacing;
      canvas.drawOval(Rect.fromCenter(center: Offset(cX, base_y + 10), width: 70, height: 20), Paint()..color = const Color(0xFF475569));
      canvas.drawRect(Rect.fromLTWH(cX - 35, base_y, 70, 10), Paint()..color = const Color(0xFF334155));
      canvas.drawOval(Rect.fromCenter(center: Offset(cX, base_y), width: 70, height: 20), Paint()..color = const Color(0xFF64748B));
      
      _drawTextOutline(canvas, xLabels[i], cX, base_y + 30, const Color(0xFFCBD5E1), 14);
      
      if ((step == 0 || step == 1) && i == 0) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cX - 50, base_y - 260, 100, 335), const Radius.circular(8)), Paint()..color = Colors.yellow.withOpacity(0.1));
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cX - 50, base_y - 260, 100, 335), const Radius.circular(8)), Paint()..color = Colors.yellow..style = PaintingStyle.stroke..strokeWidth = 3);
      } else if (step == 2 && i > 0) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cX - 50, base_y - 260, 100, 335), const Radius.circular(8)), Paint()..color = Colors.yellow..style = PaintingStyle.stroke..strokeWidth = 3);
      }
    }
  }

  void _drawGraphGridS4S5(Canvas canvas, int s) {
    double graphStartX = s == 4 ? 30 : -250;
    double graphWidth = s == 4 ? 450 : 500;
    
    canvas.drawRect(Rect.fromLTWH(graphStartX, -150, graphWidth, 300), Paint()..color = const Color(0xFF1E293B).withOpacity(0.8));

    int yMax = 100; int ySteps = 5; 
    if(s == 5) {yMax = 10; ySteps = 5;}

    for (int i = 0; i <= ySteps; i++) {
      double y = 150 - (i / ySteps) * 300;
      double val = (i / ySteps) * yMax;
      canvas.drawLine(Offset(graphStartX, y), Offset(graphStartX + graphWidth, y), Paint()..color = const Color(0xFF334155)..strokeWidth = 2);
      _drawTextOutline(canvas, val.toInt().toString(), graphStartX - 20, y, const Color(0xFF94A3B8), 12);
    }

    List<String> xLabels = s == 4 ? [t('s4_weekday'), t('s4_weekend')] : [t('s5_fri'), t('s5_sat'), t('s5_sun')];
    double spacing = s == 4 ? 200 : 150;
    double originX = s == 4 ? 180 : -100;
    
    for (int i = 0; i < xLabels.length; i++) {
      _drawTextOutline(canvas, xLabels[i], originX + i * spacing, 180, const Color(0xFFCBD5E1), 14);
    }
  }

  void _drawTableS4(Canvas canvas) {
    double tableX = -320, tableY = -120;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(tableX, tableY, 280, 180), const Radius.circular(5)), Paint()..color = const Color(0xFF1E293B));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(tableX, tableY, 280, 180), const Radius.circular(5)), Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 1);
    
    _drawTextOutline(canvas, t('s4_table_title'), tableX + 140, tableY + 20, Colors.white, 14);
    canvas.drawRect(Rect.fromLTWH(tableX, tableY + 40, 280, 30), Paint()..color = const Color(0xFF334155));
    
    _drawTextOutline(canvas, t('s4_category'), tableX + 60, tableY + 55, Colors.white, 12);
    _drawTextOutline(canvas, t('s4_kids'), tableX + 160, tableY + 55, Colors.blue, 12);
    _drawTextOutline(canvas, t('s4_adults'), tableX + 220, tableY + 55, Colors.orange, 12);
    
    List<Map<String, dynamic>> tblData = [ 
      {'l': t('s4_weekday'), 'k':30, 'a':50}, 
      {'l': t('s4_weekend'), 'k':80, 'a':70} 
    ];
    for (int i = 0; i < tblData.length; i++) {
      _drawTextOutline(canvas, tblData[i]['l'], tableX + 60, tableY + 90 + i * 40, const Color(0xFFCBD5E1), 12);
      _drawTextOutline(canvas, tblData[i]['k'].toString(), tableX + 160, tableY + 90 + i * 40, Colors.blue, 14);
      _drawTextOutline(canvas, tblData[i]['a'].toString(), tableX + 220, tableY + 90 + i * 40, Colors.orange, 14);
    }
  }

  void _drawFruitIcon(Canvas canvas, String type, double x, double y, double size) {
    Color col = type == 'apple' ? Colors.red : Colors.orange;
    canvas.drawCircle(Offset(x, y), size/2, Paint()..color = col);
    // stem
    canvas.drawRect(Rect.fromLTWH(x - 1, y - size/2 - 2, 2, 4), Paint()..color = Colors.brown);
    // leaf
    canvas.drawOval(Rect.fromCenter(center: Offset(x + 3, y - size/2), width: 6, height: 3), Paint()..color = Colors.green);
  }

  void _drawCrate(Canvas canvas, double x, double y, String type, int val, {double scale = 1.0}) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);
    // Main box
    canvas.drawRect(const Rect.fromLTWH(-35, -25, 70, 50), Paint()..color = Colors.brown.shade600);
    canvas.drawRect(const Rect.fromLTWH(-35, -25, 70, 50), Paint()..color = Colors.brown.shade900..style = PaintingStyle.stroke..strokeWidth = 3);
    // Planks
    canvas.drawLine(const Offset(-35, -5), const Offset(35, -5), Paint()..color = Colors.brown.shade900..strokeWidth = 2);
    canvas.drawLine(const Offset(-35, 10), const Offset(35, 10), Paint()..color = Colors.brown.shade900..strokeWidth = 2);
    // Cross
    canvas.drawLine(const Offset(-35, -25), const Offset(35, 25), Paint()..color = Colors.brown.shade900..strokeWidth = 2);
    canvas.drawLine(const Offset(-35, 25), const Offset(35, -25), Paint()..color = Colors.brown.shade900..strokeWidth = 2);

    // Label background
    canvas.drawRect(const Rect.fromLTWH(-20, -15, 40, 30), Paint()..color = Colors.white.withOpacity(0.9));
    canvas.drawRect(const Rect.fromLTWH(-20, -15, 40, 30), Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1);
    
    String lbl = type == 'A' ? t('s1_apples') : t('s1_oranges');
    _drawTextOutline(canvas, lbl, 0, -5, Colors.black, 9);
    _drawTextOutline(canvas, "${val}kg", 0, 7, Colors.black, 10);
    canvas.restore();
  }

  void _drawTrophy(Canvas canvas, double x, double y, Color color, String name, int val, {double scale = 1.0}) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);
    
    // Base
    canvas.drawRect(const Rect.fromLTWH(-20, 20, 40, 15), Paint()..color = Colors.blueGrey.shade800);
    canvas.drawRect(const Rect.fromLTWH(-20, 20, 40, 15), Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);
    // Stem
    canvas.drawRect(const Rect.fromLTWH(-5, 0, 10, 20), Paint()..color = color);
    canvas.drawRect(const Rect.fromLTWH(-5, 0, 10, 20), Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5);
    // Cup
    Path cup = Path()..moveTo(-25, -20)..lineTo(25, -20)..lineTo(15, 5)..lineTo(-15, 5)..close();
    canvas.drawPath(cup, Paint()..color = color);
    canvas.drawPath(cup, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);
    
    // Handles
    canvas.drawArc(const Rect.fromLTWH(-35, -20, 20, 20), pi/2, pi, false, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 4);
    canvas.drawArc(const Rect.fromLTWH(15, -20, 20, 20), -pi/2, pi, false, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 4);

    // Label background (if full size)
    if (scale >= 1.0) {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-30, 40, 60, 20), const Radius.circular(4)), Paint()..color = const Color(0xFF1E293B));
      _drawTextOutline(canvas, "$name: $val", 0, 50, color, 10);
    }
    canvas.restore();
  }

  void _drawBookStack(Canvas canvas, double x, double y, Color color, String name, int val, {double scale = 1.0}) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);
    
    // Stack 4 books
    for(int i=0; i<4; i++) {
      double by = 15 - i*12.0;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-30, by, 60, 12), const Radius.circular(2)), Paint()..color = color);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-30, by, 60, 12), const Radius.circular(2)), Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 1.5);
      canvas.drawRect(Rect.fromLTWH(-28, by + 2, 56, 8), Paint()..color = Colors.white.withOpacity(0.5));
    }

    if (scale >= 1.0) {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-35, 35, 70, 20), const Radius.circular(4)), Paint()..color = const Color(0xFF1E293B));
      _drawTextOutline(canvas, "$name: $val", 0, 45, color, 10);
    }
    canvas.restore();
  }

  void _drawCylinder(Canvas canvas, double x, double y, double w, double h, Color fillTop, Color fillSide) {
    canvas.drawRect(Rect.fromLTWH(x - w/2, y - h, w, h), Paint()..color = fillSide);
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: w, height: w/3), Paint()..color = fillSide);
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y - h), width: w, height: w/3), Paint()..color = fillTop);
  }

  void _drawTextOutline(Canvas canvas, String text, double x, double y, Color color, double size) {
    final TextSpan span = TextSpan(style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.bold), text: text);
    final TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant LabCanvasPainter oldDelegate) => true;
}