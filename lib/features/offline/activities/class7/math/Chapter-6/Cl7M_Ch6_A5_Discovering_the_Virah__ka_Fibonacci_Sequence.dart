// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RhythmsOfNatureApp());
}

class RhythmsOfNatureApp extends StatelessWidget {
  const RhythmsOfNatureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Rhythms of Nature',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1), // Indigo
          surface: Color(0xFF1E293B),
          background: Color(0xFF020617),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Roboto',
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const RhythmsLab(),
    );
  }
}

const Map<String, Map<String, String>> translations = {
  'en': {
    'appTitle':
        'Rhythms of Nature: Discovering the Virahāṅka–Fibonacci Sequence',
    'appSubtitle': 'Class 7 • Number Play',
    'enterLab': 'Enter Lab',
    'reset': 'Reset',
    'selectScenario': 'Select Scenario',
    'nextScenario': 'Next Challenge',
    'stepLabel': 'OBSERVATION',
    'theory': 'Observation Notes',
    'completed': 'Completed!',
    'successTitle': 'Rhythm Master!',
    'successDesc':
        'You have successfully decoded the ancient patterns and mastered the Virahāṅka–Fibonacci sequence.',
    'restartLab': 'Restart Lab',
    'beats': 'Beats',
    'shortBeat': 'Short',
    'longBeat': 'Long',
    'calculate': 'CALCULATE',
    'calcSubmit': 'SUBMIT',
    'currentObjective': 'CURRENT OBJECTIVE',

    's1_title': "1. The 2-Beat Rhythm",
    's1_obj':
        "To find all possible rhythmic combinations that fill exactly 2 beats using 1-beat and 2-beat blocks.",
    's1_hud_1':
        "Task: DRAG two 'Short Beat' blocks from the dispenser and DROP them into the 2-beat Tray.",
    's1_text_1':
        "Task: DRAG two 'Short Beat' blocks from the dispenser and DROP them into the 2-beat Tray.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> You filled the tray using two 1-beat blocks. A combination is saved.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> You found a valid rhythmic combination for 2 beats.",
    's1_hud_2':
        "Task: Find a different way. DRAG a single 'Long Beat' block and DROP it into the tray.",
    's1_text_2':
        "Task: Find a different way. DRAG a single 'Long Beat' block and DROP it into the tray.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> You filled the tray using one 2-beat block. A new combination is saved.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> You found another valid combination.",
    's1_hud_3':
        "Task: Notice the total count on the shelf. CLICK 'Next Challenge'.",
    's1_text_3':
        "Task: Notice the total count on the shelf. CLICK 'Next Challenge'.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> The shelf shows the total completed combinations.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> There is a specific number of unique ways to construct a 2-beat rhythm.",
    's1_sum': "You found all unique rhythmic combinations for 2 beats.",

    's2_title': "2. The 3-Beat Rhythm",
    's2_obj':
        "To discover the systematic method of building new rhythms from previous solutions.",
    's2_hud_1':
        "Task: DRAG a 'Short Beat' to the start, then DRAG a group directly from the 2-Beat shelf.",
    's2_text_1':
        "Task: DRAG a 'Short Beat' to the start, then DRAG a group directly from the 2-Beat shelf.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> You built a 3-beat rhythm by appending a 2-beat solution to a 1-beat block.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> Rhythms can be built recursively from previous smaller blocks.",
    's2_hud_2':
        "Task: Do it again: DRAG a 'Short Beat', then DRAG another group from the shelf to fill the tray.",
    's2_text_2':
        "Task: Do it again: DRAG a 'Short Beat', then DRAG another group from the shelf to fill the tray.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> You built another 3-beat rhythm using a different 2-beat solution.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> Every 2-beat combination can be prefixed with a 1-beat block to form a 3-beat rhythm.",
    's2_hud_3':
        "Task: Start with a 'Long Beat'. Then DRAG a block from the 1-beat shelf.",
    's2_text_3':
        "Task: Start with a 'Long Beat'. Then DRAG a block from the 1-beat shelf.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> You built a 3-beat rhythm by appending a 1-beat solution to a 2-beat block.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> Every 1-beat combination can be prefixed with a 2-beat block.",
    's2_hud_4': "Task: Notice the total combinations on each shelf!",
    's2_text_4':
        "Task: Notice the total combinations on each shelf!<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> The number of ways adds up.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> The total number of 3-beat rhythms is exactly the sum of ways from the previous two shelves.",
    's2_sum':
        "To find the number of ways for N beats, add the ways for (N-1) beats and (N-2) beats.",

    's3_title': "3. The 4-Beat Confirmation",
    's3_obj':
        "To confirm the discovered pattern by constructing all 4-beat rhythms.",
    's3_hud_1':
        "Task: Create rhythms starting with a 'Short Beat'. Place a 'Short Beat', then sequentially DRAG each group from the 3-beat shelf.",
    's3_text_1':
        "Task: Create rhythms starting with a 'Short Beat'. Place a 'Short Beat', then sequentially DRAG each group from the 3-beat shelf.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> You created combinations by prefixing 3-beat solutions with a 1-beat block.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> The ways to make a 3-beat rhythm directly contribute to ways to make a 4-beat rhythm.",
    's3_hud_2':
        "Task: Create rhythms starting with a 'Long Beat'. Place a 'Long Beat', then sequentially DRAG each group from the 2-beat shelf.",
    's3_text_2':
        "Task: Create rhythms starting with a 'Long Beat'. Place a 'Long Beat', then sequentially DRAG each group from the 2-beat shelf.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> You created combinations by prefixing 2-beat solutions with a 2-beat block.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> The ways to make a 2-beat rhythm contribute to making a 4-beat rhythm.",
    's3_hud_3': "Task: Confirm the pattern! Does it add up?",
    's3_text_3':
        "Task: Confirm the pattern! Does it add up?<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> The total ways matches the sum of the previous two.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> The pattern holds! Each term is the sum of the previous two.",
    's3_sum': "The sequence is 1, 2, 3, 5... Each step adds the previous two.",

    's4_title': "4. The 5-Beat Challenge",
    's4_obj':
        "To apply the rule to find all possible 5-beat rhythms without guidance.",
    's4_hud_1':
        "Task: Construct all possible 5-beat rhythms. Start with 1- or 2-beat blocks, then grab remaining sequences from shelves.",
    's4_text_1':
        "Task: Construct all possible 5-beat rhythms. Start with 1- or 2-beat blocks, then grab remaining sequences from shelves.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> Systematically applying the rule to discover new combinations.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> You can independently derive higher-order combinations using the recursive rule.",
    's4_hud_2': "Task: You found all the rhythms!",
    's4_text_2':
        "Task: You found all the rhythms!<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> The math works perfectly.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> You have mastered the physical construction of the Virahāṅka sequence!",
    's4_sum':
        "You have mastered the physical construction of the Virahāṅka sequence.",

    's5_title': "5. The 8-Beat Prediction",
    's5_obj':
        "To use the sequence to predict a future term and verify the mathematical property.",
    's5_hud_1':
        "Task: DRAG the sequence numbers into the calculator to logically compute the next terms.",
    's5_text_1':
        "Task: DRAG the sequence numbers into the calculator to logically compute the next terms.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> Calculating sequentially using the established rule.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> The mathematical rule V(n) = V(n-1) + V(n-2) allows us to predict the future without building blocks.",
    's5_hud_2': "Task: Submit your final answer for 8 beats.",
    's5_text_2':
        "Task: Submit your final answer for 8 beats.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> You submitted the final calculated answer.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> Ancient poets calculated the unique rhythmic combinations for an 8-beat meter, long before Fibonacci!",
    's5_sum':
        "Amazing! The ancient poets calculated the unique rhythmic combinations for an 8-beat meter.",
  },
  'hi': {
    'appTitle': 'प्रकृति की लय: विरहांक-फिबोनाची अनुक्रम की खोज',
    'appSubtitle': 'कक्षा 7 • संख्याओं का खेल',
    'enterLab': 'लैब में प्रवेश करें',
    'reset': 'रीसेट',
    'selectScenario': 'मिशन चुनें',
    'nextScenario': 'अगली चुनौती',
    'stepLabel': 'अवलोकन',
    'theory': 'अवलोकन नोट्स',
    'completed': 'पूरा हुआ!',
    'successTitle': 'लय के उस्ताद!',
    'successDesc':
        'आपने प्राचीन पैटर्नों को सफलतापूर्वक डिकोड कर लिया है और विरहांक-फिबोनाची अनुक्रम में महारत हासिल कर ली है।',
    'restartLab': 'लैब को फिर से शुरू करें',
    'beats': 'बीट्स',
    'shortBeat': 'छोटा',
    'longBeat': 'बड़ा',
    'calculate': 'गणना करें',
    'calcSubmit': 'जमा करें',
    'currentObjective': 'वर्तमान लक्ष्य',

    's1_title': "1. 2-बीट लय",
    's1_obj':
        "1-बीट और 2-बीट ब्लॉकों का उपयोग करके 2 बीट्स को भरने वाले सभी संभव लयबद्ध संयोजनों को खोजना।",
    's1_hud_1':
        "कार्य: डिस्पेंसर से दो 'Short Beat' ब्लॉक खींचें और उन्हें 2-बीट ट्रे में छोड़ दें।",
    's1_text_1':
        "कार्य: डिस्पेंसर से दो 'Short Beat' ब्लॉक खींचें और उन्हें 2-बीट ट्रे में छोड़ दें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> आपने दो 1-बीट ब्लॉकों का उपयोग करके ट्रे को भर दिया। एक संयोजन सहेजा गया है।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> आपने 2 बीट्स के लिए एक मान्य लयबद्ध संयोजन खोजा है।",
    's1_hud_2':
        "कार्य: एक अलग तरीका खोजें। एक 'Long Beat' ब्लॉक खींचें और उसे ट्रे में छोड़ दें।",
    's1_text_2':
        "कार्य: एक अलग तरीका खोजें। एक 'Long Beat' ब्लॉक खींचें और उसे ट्रे में छोड़ दें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> आपने एक 2-बीट ब्लॉक का उपयोग करके ट्रे को भर दिया। एक नया संयोजन सहेजा गया है।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> आपने एक और मान्य संयोजन खोजा है।",
    's1_hud_3':
        "कार्य: शेल्फ पर कुल गिनती पर ध्यान दें। 'Next Challenge' पर क्लिक करें।",
    's1_text_3':
        "कार्य: शेल्फ पर कुल गिनती पर ध्यान दें। 'Next Challenge' पर क्लिक करें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> शेल्फ कुल पूर्ण संयोजन दिखाता है।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> 2-बीट लय बनाने के कुछ अनोखे तरीके हैं।",
    's1_sum': "आपने 2 बीट्स के लिए सभी अद्वितीय लयबद्ध संयोजन खोज लिए हैं।",

    's2_title': "2. 3-बीट लय",
    's2_obj': "पिछले समाधानों से नई लय बनाने की व्यवस्थित विधि की खोज करना।",
    's2_hud_1':
        "कार्य: शुरुआत में एक 'Short Beat' रखें, फिर 2-बीट शेल्फ से एक समूह को सीधे खींचें।",
    's2_text_1':
        "कार्य: शुरुआत में एक 'Short Beat' रखें, फिर 2-बीट शेल्फ से एक समूह को सीधे खींचें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> आपने पिछले 2-बीट समाधान में 1 बीट जोड़कर 3-बीट की लय बनाई।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> लय को पिछले छोटे ब्लॉकों से पुनरावर्ती रूप से बनाया जा सकता है।",
    's2_hud_2':
        "कार्य: इसे फिर से करें: एक 'Short Beat' रखें, फिर शेल्फ से दूसरा समूह खींचें।",
    's2_text_2':
        "कार्य: इसे फिर से करें: एक 'Short Beat' रखें, फिर शेल्फ से दूसरा समूह खींचें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> आपने एक अलग 2-बीट समाधान का उपयोग करके एक और 3-बीट लय बनाई।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> हर 2-बीट संयोजन के आगे 1-बीट ब्लॉक लगाकर 3-बीट लय बनाई जा सकती है।",
    's2_hud_3':
        "कार्य: अब 'Long Beat' से शुरुआत करें। फिर 1-बीट शेल्फ से एक ब्लॉक खींचें।",
    's2_text_3':
        "कार्य: अब 'Long Beat' से शुरुआत करें। फिर 1-बीट शेल्फ से एक ब्लॉक खींचें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> आपने 1-बीट समाधान में 2 बीट जोड़कर 3-बीट की लय बनाई।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> हर 1-बीट संयोजन के आगे 2-बीट ब्लॉक लगाया जा सकता है।",
    's2_hud_4': "कार्य: प्रत्येक शेल्फ पर कुल संयोजनों पर ध्यान दें!",
    's2_text_4':
        "कार्य: प्रत्येक शेल्फ पर कुल संयोजनों पर ध्यान दें!<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> तरीकों की संख्या जुड़ जाती है।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> 3-बीट लय की संख्या ठीक 2-बीट लय और 1-बीट लय का योग है।",
    's2_sum':
        "N बीट्स के तरीकों की संख्या खोजने के लिए, (N-1) बीट्स और (N-2) बीट्स के तरीकों को जोड़ें।",

    's3_title': "3. 4-बीट की पुष्टि",
    's3_obj': "सभी 4-बीट लय का निर्माण करके खोजे गए पैटर्न की पुष्टि करना।",
    's3_hud_1':
        "कार्य: 'Short Beat' से शुरू होने वाले लय बनाएं। फिर 3-बीट शेल्फ से क्रमिक रूप से प्रत्येक समूह को खींचें।",
    's3_text_1':
        "कार्य: 'Short Beat' से शुरू होने वाले लय बनाएं। फिर 3-बीट शेल्फ से क्रमिक रूप से प्रत्येक समूह को खींचें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> आपने 3-बीट समाधानों के आगे 1-बीट ब्लॉक लगाकर संयोजन बनाए।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> 3-बीट लय बनाने के तरीके सीधे 4-बीट लय बनाने में योगदान करते हैं।",
    's3_hud_2':
        "कार्य: 'Long Beat' से शुरू होने वाले लय बनाएं। फिर 2-बीट शेल्फ से क्रमिक रूप से प्रत्येक समूह को खींचें।",
    's3_text_2':
        "कार्य: 'Long Beat' से शुरू होने वाले लय बनाएं। फिर 2-बीट शेल्फ से क्रमिक रूप से प्रत्येक समूह को खींचें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> आपने 2-बीट समाधानों के आगे 2-बीट ब्लॉक लगाकर संयोजन बनाए।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> 2-बीट लय बनाने के तरीके 4-बीट लय बनाने के लिए योगदान करते हैं।",
    's3_hud_3': "कार्य: पैटर्न की पुष्टि करें! क्या यह जुड़ता है?",
    's3_text_3':
        "कार्य: पैटर्न की पुष्टि करें! क्या यह जुड़ता है?<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> कुल तरीके पिछले दो के योग से मेल खाते हैं।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> पैटर्न काम करता है! प्रत्येक पद पिछले दो का योग है।",
    's3_sum': "अनुक्रम जारी है। हर कदम पिछले दो को जोड़ता है।",

    's4_title': "4. 5-बीट की चुनौती",
    's4_obj':
        "बिना मार्गदर्शन के सभी संभव 5-बीट लय खोजने के लिए नियम लागू करना।",
    's4_hud_1':
        "कार्य: सभी संभव 5-बीट लय बनाएं। 1 या 2-बीट ब्लॉक से शुरू करें, फिर शेल्फ से लें।",
    's4_text_1':
        "कार्य: सभी संभव 5-बीट लय बनाएं। 1 या 2-बीट ब्लॉक से शुरू करें, फिर शेल्फ से लें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> नए संयोजनों को खोजने के लिए व्यवस्थित रूप से नियम लागू करना।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> आप पुनरावर्ती नियम का उपयोग करके उच्च-क्रम संयोजनों को स्वतंत्र रूप से प्राप्त कर सकते हैं।",
    's4_hud_2': "कार्य: आपने सभी लय खोज लिए!",
    's4_text_2':
        "कार्य: आपने सभी लय खोज लिए!<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> गणित पूरी तरह से काम करता है।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> आपने विरहांक अनुक्रम के भौतिक निर्माण में महारत हासिल कर ली है!",
    's4_sum': "आपने विरहांक अनुक्रम के भौतिक निर्माण में महारत हासिल कर ली है।",

    's5_title': "5. 8-बीट की भविष्यवाणी",
    's5_obj':
        "भविष्य के शब्द की भविष्यवाणी करने और गणितीय गुण को सत्यापित करने के लिए अनुक्रम का उपयोग करना।",
    's5_hud_1':
        "कार्य: अगले पदों की गणना करने के लिए कैलकुलेटर में नंबरों को खींचें।",
    's5_text_1':
        "कार्य: अगले पदों की गणना करने के लिए कैलकुलेटर में नंबरों को खींचें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> स्थापित नियम का उपयोग करके क्रमिक रूप से गणना करना।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> गणितीय नियम V(n) = V(n-1) + V(n-2) हमें ब्लॉक बनाए बिना भविष्य की भविष्यवाणी करने की अनुमति देता है।",
    's5_hud_2': "कार्य: 8 बीट्स के लिए अपना अंतिम उत्तर जमा करें।",
    's5_text_2':
        "कार्य: 8 बीट्स के लिए अपना अंतिम उत्तर जमा करें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> आपने अंतिम गणना किया हुआ उत्तर जमा किया।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> प्राचीन कवियों ने 8-बीट मीटर के लिए अद्वितीय लयबद्ध संयोजनों की गणना की थी, फिबोनाची से बहुत पहले!",
    's5_sum':
        "अद्भुत! प्राचीन कवियों ने गणना की थी कि 8-बीट मीटर के लिए अद्वितीय लयबद्ध संयोजन हैं।",
  },
};

class AudioEngine {
  static final AudioPlayer _clickPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _snapPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl =
      'audio/class7/mixkit_2568.mp3';
  static const String _successUrl =
      'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl =
      'audio/class7/mixkit_955.mp3';
  static const String _shutterUrl =
      'audio/class7/mixkit_2574.mp3';
  static const String _snapUrl =
      'audio/class7/mixkit_1114.mp3';

  static Future<void> init() async {
    _clickPlayer.setSource(AssetSource(_clickUrl)).catchError((e) {});
    _successPlayer.setSource(AssetSource(_successUrl)).catchError((e) {});
    _errorPlayer.setSource(AssetSource(_errorUrl)).catchError((e) {});
    _shutterPlayer.setSource(AssetSource(_shutterUrl)).catchError((e) {});
    _snapPlayer.setSource(AssetSource(_snapUrl)).catchError((e) {});
  }

  static void click() {
    _clickPlayer.stop().then((_) => _clickPlayer.resume()).catchError((e) {});
  }

  static void success() {
    _successPlayer
        .stop()
        .then((_) => _successPlayer.resume())
        .catchError((e) {});
  }

  static void error() {
    _errorPlayer.stop().then((_) => _errorPlayer.resume()).catchError((e) {});
  }

  static void shutter() {
    _shutterPlayer
        .stop()
        .then((_) => _shutterPlayer.resume())
        .catchError((e) {});
  }

  static void snap() {
    _snapPlayer.stop().then((_) => _snapPlayer.resume()).catchError((e) {});
  }

  static void tick() {
    click();
  }
}

class DraggableDialog extends StatefulWidget {
  final Widget child;
  const DraggableDialog({super.key, required this.child});

  @override
  State<DraggableDialog> createState() => _DraggableDialogState();
}

class _DraggableDialogState extends State<DraggableDialog> {
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _offset,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() => _offset += details.delta);
        },
        child: Material(type: MaterialType.transparency, child: widget.child),
      ),
    );
  }
}

// --- MODELS ---

class AnimData {
  String type;
  List<int>? arr;
  double x1, y1, x2, y2;
  int start, duration;
  String? text;
  int? sum;
  Map<String, dynamic>? n1, n2;
  VoidCallback? onComplete;

  AnimData({
    required this.type,
    required this.start,
    required this.duration,
    this.arr,
    this.x1 = 0,
    this.y1 = 0,
    this.x2 = 0,
    this.y2 = 0,
    this.text,
    this.sum,
    this.n1,
    this.n2,
    this.onComplete,
  });
}

// --- MAIN SCREEN ---
class RhythmsLab extends StatefulWidget {
  const RhythmsLab({super.key});

  @override
  State<RhythmsLab> createState() => _RhythmsLabState();
}

class _RhythmsLabState extends State<RhythmsLab>
    with SingleTickerProviderStateMixin {
  bool _isCurtainOpen = false;
  bool _isSidebarOpen = true;
  String _lang = 'en';
  final double _sidebarWidthPct = 0.35;
  final double U = 50.0;

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _stepKeys = List.generate(5, (_) => GlobalKey());

  double _panX = 0;
  double _panY = 0;
  double _zoom = 1.0;
  double _baseZoom = 1.0;

  Offset _hudOffset = const Offset(20, 100);

  int _scenario = 1;
  int _step = 0;
  final Set<int> _completedScenarios = {};

  List<int> _currentTray = [];
  Map<int, List<List<int>>> _completedRhythms = {
    1: [
      [1],
    ],
    2: [],
    3: [],
    4: [],
    5: [],
  };

  List<int> _s5Tiles = [1, 2, 3, 5, 8];
  int? _s5Box1, _s5Box2, _s5BoxFinal;
  int _s5ExpectedResult = 13;

  Map<String, dynamic>? _draggedEntity;
  bool _hoverValid = false;
  bool _hoverBtnNext = false;

  List<AnimData> _animations = [];

  late Ticker _ticker;
  int _currentTime = 0;
  final ValueNotifier<int> _repaintNotifier = ValueNotifier<int>(0);

  String t(String key) =>
      translations[_lang]?[key] ?? translations['en']?[key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    AudioEngine.init();

    _ticker = createTicker((elapsed) {
      _currentTime = DateTime.now().millisecondsSinceEpoch;

      bool animActive = false;
      List<AnimData> toRemove = [];
      for (var anim in _animations) {
        animActive = true;
        double p = (_currentTime - anim.start) / anim.duration;
        if (p >= 1.0) {
          toRemove.add(anim);
        }
      }

      for (var anim in toRemove) {
        _animations.remove(anim);
        if (anim.onComplete != null) anim.onComplete!();
      }

      if (animActive) {
        _repaintNotifier.value++;
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _repaintNotifier.dispose();
    _scrollController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startLab() {
    AudioEngine.shutter();
    setState(() => _isCurtainOpen = true);
    _loadScenario(1);
  }

  void _resetLab() {
    AudioEngine.click();
    setState(() {
      _isCurtainOpen = false;
      _completedScenarios.clear();
      _lang = 'en';
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;
      _currentTray = [];
      _animations = [];
      _draggedEntity = null;
      _hoverBtnNext = false;

      _completedRhythms = {
        1: [
          [1],
        ],
        2: [],
        3: [],
        4: [],
        5: [],
      };
      if (_scenario >= 2) {
        _completedRhythms[2] = [
          [1, 1],
          [2],
        ];
      }
      if (_scenario >= 3) {
        _completedRhythms[3] = [
          [1, 1, 1],
          [1, 2],
          [2, 1],
        ];
      }
      if (_scenario >= 4) {
        _completedRhythms[4] = [
          [1, 1, 1, 1],
          [1, 1, 2],
          [1, 2, 1],
          [2, 1, 1],
          [2, 2],
        ];
      }
      if (_scenario >= 5) {
        _completedRhythms[5] = [
          [1, 1, 1, 1, 1],
          [1, 1, 1, 2],
          [1, 1, 2, 1],
          [1, 2, 1, 1],
          [1, 2, 2],
          [2, 1, 1, 1],
          [2, 1, 2],
          [2, 2, 1],
        ];
      }

      if (_scenario == 5) {
        _s5Tiles = [1, 2, 3, 5, 8];
        _s5Box1 = null;
        _s5Box2 = null;
        _s5BoxFinal = null;
        _s5ExpectedResult = 13;
      }

      AudioEngine.click();
      _zoom = 1.0;
      _panX = 0;
      _panY = 0;
      _repaintNotifier.value++;
    });
    _scrollToActiveStep();
  }

  void _scrollToActiveStep() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _stepKeys.length > _step &&
          _stepKeys[_step].currentContext != null) {
        Scrollable.ensureVisible(
          _stepKeys[_step].currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      }
    });
  }

  Map<String, double> _getLayout() {
    bool hasRow2 = _scenario >= 3;
    if (hasRow2) {
      return {
        'row1Y': -200,
        'row2Y': -10,
        'dispShortY': 190,
        'dispLongY': 290,
        'trayY': 240,
      };
    } else {
      return {
        'row1Y': -100,
        'dispShortY': 100,
        'dispLongY': 200,
        'trayY': 150,
        'row2Y': 0,
      };
    }
  }

  Map<String, double> _getShelfPosition(int n) {
    var l = _getLayout();
    List<Map<String, double>> positions = [
      {'x': -250, 'y': l['row1Y']!, 'h': 160},
      {'x': 0, 'y': l['row1Y']!, 'h': 160},
      {'x': 250, 'y': l['row1Y']!, 'h': 160},
      {'x': -150, 'y': l['row2Y']!, 'h': 180},
      {'x': 150, 'y': l['row2Y']!, 'h': 180},
    ];
    if (n >= 1 && n <= positions.length) return positions[n - 1];
    return {'x': 0, 'y': 0, 'h': 100};
  }

  bool _arraysEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _checkTrayCompletion(int targetBeats) {
    int currentBeats = _currentTray.fold(0, (sum, i) => sum + i);
    if (currentBeats == targetBeats) {
      bool validCombination = true;
      if (_scenario == 1) {
        if (_step == 0 && !_arraysEqual(_currentTray, [1, 1])) {
          validCombination = false;
        }
        if (_step == 1 && !_arraysEqual(_currentTray, [2])) {
          validCombination = false;
        }
      }
      if (_scenario == 2) {
        if (_step == 0 && !_arraysEqual(_currentTray, [1, 1, 1])) {
          validCombination = false;
        }
        if (_step == 1 && !_arraysEqual(_currentTray, [1, 2])) {
          validCombination = false;
        }
        if (_step == 2 && !_arraysEqual(_currentTray, [2, 1])) {
          validCombination = false;
        }
      }

      bool isNew =
          !(_completedRhythms[targetBeats]!.any(
            (arr) => _arraysEqual(arr, _currentTray),
          ));

      if (isNew && validCombination) {
        AudioEngine.success();
        _completedRhythms[targetBeats]!.add(List.from(_currentTray));

        var shelfPos = _getShelfPosition(targetBeats);
        var layout = _getLayout();

        setState(() {
          _animations.add(
            AnimData(
              type: 'float',
              arr: List.from(_currentTray),
              x1: 0,
              y1: layout['trayY']!,
              x2: shelfPos['x']!,
              y2: shelfPos['y']! + shelfPos['h']! / 2,
              start: DateTime.now().millisecondsSinceEpoch,
              duration: 800,
              onComplete: () {
                if (_scenario == 1) {
                  if (_step == 0 && _completedRhythms[2]!.length == 1) {
                    _markStepComplete();
                  } else if (_step == 1 && _completedRhythms[2]!.length == 2) {
                    _markStepComplete();
                  }
                } else if (_scenario == 2) {
                  if (_step == 0 && _completedRhythms[3]!.length == 1) {
                    _markStepComplete();
                  } else if (_step == 1 && _completedRhythms[3]!.length == 2) {
                    _markStepComplete();
                  } else if (_step == 2 && _completedRhythms[3]!.length == 3) {
                    _markStepComplete();
                  }
                } else if (_scenario == 3) {
                  if (_step == 0 && _completedRhythms[4]!.length == 3) {
                    _markStepComplete();
                  } else if (_step == 1 && _completedRhythms[4]!.length == 5) {
                    _markStepComplete();
                  }
                } else if (_scenario == 4) {
                  if (_completedRhythms[5]!.length == 8) {
                    _markStepComplete();
                  }
                }
                _repaintNotifier.value++;
              },
            ),
          );
        });
      } else {
        AudioEngine.error();
        var layout = _getLayout();
        setState(() {
          _animations.add(
            AnimData(
              type: 'textFly',
              text: 'Invalid!',
              x1: 0,
              y1: layout['trayY']!,
              x2: 0,
              y2: layout['trayY']! - 100,
              start: DateTime.now().millisecondsSinceEpoch,
              duration: 1000,
              onComplete: () => _repaintNotifier.value++,
            ),
          );
        });
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _currentTray = [];
          });
        }
      });
    }
  }

  void _markStepComplete({bool advanceUI = true}) {
    setState(() {
      if (advanceUI) _step++;

      int maxSteps = [0, 3, 4, 3, 2, 2][_scenario];

      if (_scenario == 1 && _step == 2) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _markStepComplete();
        });
      }

      if (_scenario == 2 && _step == 3) {
        var p1 = _getShelfPosition(1);
        var p2 = _getShelfPosition(2);
        var p3 = _getShelfPosition(3);
        _animations.add(
          AnimData(
            type: 'mathSum',
            n1: {'val': 2, 'x': p2['x']!, 'y': p2['y']!},
            n2: {'val': 1, 'x': p1['x']!, 'y': p1['y']!},
            x2: p3['x']!,
            y2: p3['y']!,
            sum: 3,
            start: DateTime.now().millisecondsSinceEpoch,
            duration: 2000,
          ),
        );
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _markStepComplete();
        });
        return;
      }

      if (_scenario == 3 && _step == 2) {
        var p2 = _getShelfPosition(2);
        var p3 = _getShelfPosition(3);
        var p4 = _getShelfPosition(4);
        _animations.add(
          AnimData(
            type: 'mathSum',
            n1: {'val': 3, 'x': p3['x']!, 'y': p3['y']!},
            n2: {'val': 2, 'x': p2['x']!, 'y': p2['y']!},
            x2: p4['x']!,
            y2: p4['y']!,
            sum: 5,
            start: DateTime.now().millisecondsSinceEpoch,
            duration: 2000,
          ),
        );
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _markStepComplete();
        });
        return;
      }

      if (_step >= maxSteps) {
        AudioEngine.success();
        _completedScenarios.add(_scenario);
        if (_scenario == 5) {
          Future.delayed(
            const Duration(milliseconds: 1000),
            _showFinalSuccessDialog,
          );
        }
      } else {
        AudioEngine.snap();
      }
    });
    if (advanceUI) _scrollToActiveStep();
  }

  void _showFinalSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder:
          (ctx) => DraggableDialog(
            child: Dialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 340,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.stars,
                                color: Colors.amber,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t('successTitle'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              AudioEngine.click();
                              Navigator.of(ctx).pop();
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.white70,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('successDesc'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          AudioEngine.click();
                          Navigator.of(ctx).pop();
                          _resetLab();
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(t('restartLab')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  void _handlePointerDown(PointerDownEvent e, Size canvasSize) {
    Offset pt = _screenToWorld(e.localPosition, canvasSize);
    var layout = _getLayout();

    if (_scenario < 5) {
      if (_scenario == 4 && _completedRhythms[5]!.length == 8) {
        double btnY = layout['trayY']! + 90;
        if (pt.dx > -100 &&
            pt.dx < 100 &&
            pt.dy > btnY + 10 &&
            pt.dy < btnY + 54) {
          AudioEngine.tick();
          _loadScenario(_scenario + 1);
          return;
        }
      }

      bool allowDisp1 = true, allowDisp2 = true;
      List<bool> allowShelf = [false, false, false, false, false, false];

      if (_scenario == 1) {
        if (_step == 0) allowDisp2 = false;
        if (_step == 1) allowDisp1 = false;
      }
      if (_scenario == 2) {
        if (_step == 0 || _step == 1) {
          if (_currentTray.isEmpty) {
            allowDisp2 = false;
          } else if (_currentTray.length == 1 && _currentTray[0] == 1) {
            allowDisp1 = false;
            allowDisp2 = false;
            allowShelf[2] = true;
          }
        } else if (_step == 2) {
          if (_currentTray.isEmpty) {
            allowDisp1 = false;
          } else if (_currentTray.length == 1 && _currentTray[0] == 2) {
            allowDisp1 = false;
            allowDisp2 = false;
            allowShelf[1] = true;
          }
        }
      }
      if (_scenario == 3) {
        if (_step == 0) {
          if (_currentTray.isEmpty) {
            allowDisp2 = false;
          } else if (_currentTray.length == 1 && _currentTray[0] == 1) {
            allowDisp1 = false;
            allowDisp2 = false;
            allowShelf[3] = true;
          }
        } else if (_step == 1) {
          if (_currentTray.isEmpty) {
            allowDisp1 = false;
          } else if (_currentTray.length == 1 && _currentTray[0] == 2) {
            allowDisp1 = false;
            allowDisp2 = false;
            allowShelf[2] = true;
          }
        }
      }
      if (_scenario == 4) {
        if (_currentTray.isEmpty) {
        } else if (_currentTray.length == 1) {
          allowDisp1 = false;
          allowDisp2 = false;
          if (_currentTray[0] == 1) allowShelf[4] = true;
          if (_currentTray[0] == 2) allowShelf[3] = true;
        } else {
          allowDisp1 = false;
          allowDisp2 = false;
        }
      }

      if ((pt.dx - -350).abs() < 40 &&
          (pt.dy - layout['dispShortY']!).abs() < 40) {
        if (allowDisp1) {
          setState(() {
            _draggedEntity = {
              'arr': <int>[1],
              'x': pt.dx,
              'y': pt.dy,
            };
          });
          AudioEngine.tick();
        } else {
          AudioEngine.error();
        }
        return;
      }
      if ((pt.dx - -350).abs() < 60 &&
          (pt.dy - layout['dispLongY']!).abs() < 40) {
        if (allowDisp2) {
          setState(() {
            _draggedEntity = {
              'arr': <int>[2],
              'x': pt.dx,
              'y': pt.dy,
            };
          });
          AudioEngine.tick();
        } else {
          AudioEngine.error();
        }
        return;
      }

      if (_scenario > 1) {
        for (int i = 1; i <= math.min(_scenario, 4); i++) {
          if (!allowShelf[i]) continue;
          var conf = _getShelfPosition(i);
          if (pt.dx > conf['x']! - 100 &&
              pt.dx < conf['x']! + 100 &&
              pt.dy > conf['y']! &&
              pt.dy < conf['y']! + conf['h']!) {
            var items = _completedRhythms[i]!;
            double baseH = 28;
            double totalHUnscaled = items.length * baseH;
            double scale = 1;
            if (totalHUnscaled > conf['h']! - 20) {
              scale = (conf['h']! - 20) / totalHUnscaled;
            }
            double itemSpacing = baseH * scale;
            double totalH = items.length * itemSpacing;
            double startY = conf['y']! + conf['h']! / 2 - totalH / 2 + 10;

            for (int j = 0; j < items.length; j++) {
              if ((pt.dy - (startY + j * itemSpacing)).abs() < 15) {
                var clickedArr = items[j];
                bool isValid = true;

                if (_scenario == 2) {
                  if (_step == 0 && !_arraysEqual(clickedArr, [1, 1])) {
                    isValid = false;
                  }
                  if (_step == 1 && !_arraysEqual(clickedArr, [2])) {
                    isValid = false;
                  }
                  if (_step == 2 && !_arraysEqual(clickedArr, [1])) {
                    isValid = false;
                  }
                }

                if (isValid) {
                  setState(() {
                    _draggedEntity = {
                      'arr': List<int>.from(clickedArr),
                      'x': pt.dx,
                      'y': pt.dy,
                    };
                  });
                  AudioEngine.tick();
                } else {
                  AudioEngine.error();
                }
                return;
              }
            }
          }
        }
      }
    } else {
      double cx = 0;
      double cy = -50;
      if (_step == 0 && _s5Box1 != null && _s5Box2 != null) {
        if (pt.dx > cx + 120 &&
            pt.dx < cx + 200 &&
            pt.dy > cy - 10 &&
            pt.dy < cy + 50) {
          if (_s5Box1! + _s5Box2! == _s5ExpectedResult) {
            AudioEngine.success();
            setState(() {
              _s5Tiles.add(_s5ExpectedResult);
              _s5Box1 = null;
              _s5Box2 = null;
              if (_s5ExpectedResult == 13) {
                _s5ExpectedResult = 21;
                _markStepComplete(advanceUI: false);
              } else if (_s5ExpectedResult == 21) {
                _s5ExpectedResult = 34;
                _markStepComplete(advanceUI: false);
              } else if (_s5ExpectedResult == 34) {
                _markStepComplete();
              }
            });
          } else {
            AudioEngine.error();
            setState(() {
              _s5Box1 = null;
              _s5Box2 = null;
            });
          }
          return;
        }
      }
      if (_step == 1 && _s5BoxFinal != null) {
        if (pt.dx > cx + 90 &&
            pt.dx < cx + 170 &&
            pt.dy > cy - 10 &&
            pt.dy < cy + 50) {
          if (_s5BoxFinal == 34) {
            _markStepComplete();
          } else {
            AudioEngine.error();
            setState(() {
              _s5BoxFinal = null;
            });
          }
          return;
        }
      }

      for (int i = 0; i < _s5Tiles.length; i++) {
        double tx = cx - 200 + i * 70;
        if ((pt.dx - tx).abs() < 25 && (pt.dy - (cy + 190)).abs() < 25) {
          setState(() {
            _draggedEntity = {'val': _s5Tiles[i], 'x': pt.dx, 'y': pt.dy};
          });
          AudioEngine.tick();
          return;
        }
      }
    }
  }

  void _handlePointerMove(PointerMoveEvent e, Size canvasSize) {
    Offset pt = _screenToWorld(e.localPosition, canvasSize);
    var layout = _getLayout();

    if (_scenario == 4 && _completedRhythms[5]!.length == 8) {
      double btnY = layout['trayY']! + 90;
      bool hover =
          (pt.dx > -100 &&
              pt.dx < 100 &&
              pt.dy > btnY + 10 &&
              pt.dy < btnY + 54);
      if (_hoverBtnNext != hover) {
        setState(() {
          _hoverBtnNext = hover;
        });
      }
    }

    if (_draggedEntity != null) {
      setState(() {
        _draggedEntity!['x'] = pt.dx;
        _draggedEntity!['y'] = pt.dy;
        if (_scenario < 5) {
          double w = (_scenario + 1) * U;
          _hoverValid =
              (pt.dx.abs() < w / 2 + 50 &&
                  (pt.dy - layout['trayY']!).abs() < 40);
        } else {
          _hoverValid = (pt.dy > -80 && pt.dy < 0);
        }
      });
    }
  }

  void _handlePointerUp(PointerUpEvent e) {
    if (_draggedEntity != null) {
      if (_scenario < 5 && _hoverValid) {
        int targetBeats = _scenario + 1;
        int currentBeats = _currentTray.fold(0, (sum, i) => sum + i);
        List<int> draggedArr = List<int>.from(_draggedEntity!['arr']);
        int dragBeats = draggedArr.fold(0, (sum, i) => sum + i);

        if (currentBeats + dragBeats <= targetBeats) {
          setState(() {
            _currentTray.addAll(draggedArr);
          });
          AudioEngine.snap();
          _checkTrayCompletion(targetBeats);
        } else {
          AudioEngine.error();
        }
      } else if (_scenario == 5 && _hoverValid) {
        double cx = 0;
        double ptX = _draggedEntity!['x'];
        if (_step == 0) {
          if ((ptX - (cx - 90)).abs() < 30) {
            setState(() {
              _s5Box1 = _draggedEntity!['val'];
            });
            AudioEngine.snap();
          } else if ((ptX - (cx + 30)).abs() < 30) {
            setState(() {
              _s5Box2 = _draggedEntity!['val'];
            });
            AudioEngine.snap();
          } else {
            AudioEngine.error();
          }
        } else {
          if ((ptX - (cx + 30)).abs() < 30) {
            setState(() {
              _s5BoxFinal = _draggedEntity!['val'];
            });
            AudioEngine.snap();
          } else {
            AudioEngine.error();
          }
        }
      } else {
        AudioEngine.tick();
      }

      setState(() {
        _draggedEntity = null;
        _hoverValid = false;
      });
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (_draggedEntity == null) {
      _baseZoom = _zoom;
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_draggedEntity == null) {
      setState(() {
        _zoom = (_baseZoom * details.scale).clamp(0.1, 3.0);
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
      });
      _repaintNotifier.value++;
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {}

  Offset _screenToWorld(Offset screen, Size size) {
    return Offset(
      (screen.dx - size.width / 2 - _panX) / _zoom,
      (screen.dy - size.height / 2 - _panY) / _zoom,
    );
  }

  List<TextSpan> _parseRichText(String text) {
    String cleanStr = text.replaceAll(RegExp(r'<[^>]*>'), '');
    List<TextSpan> spans = [];

    // Split based on EN, HI, TE prefix identifiers
    List<String> parts = cleanStr.split(
      RegExp(
        r'(?=Task:|Observed:|What we learned:|कार्य:|देखा गया:|हमने क्या सीखा:|పని:|గమనించబడింది:|మనం ఏమి నేర్చుకున్నాం:)',
      ),
    );

    for (String part in parts) {
      String p = part.trim();
      if (p.startsWith('Task:')) {
        spans.add(
          const TextSpan(
            text: 'Task: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: '${p.replaceFirst('Task:', '').trim()}\n\n',
            style: const TextStyle(color: Colors.white),
          ),
        );
      } else if (p.startsWith('कार्य:')) {
        spans.add(
          const TextSpan(
            text: 'कार्य: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: '${p.replaceFirst('कार्य:', '').trim()}\n\n',
            style: const TextStyle(color: Colors.white),
          ),
        );
      } else if (p.startsWith('పని:')) {
        spans.add(
          const TextSpan(
            text: 'పని: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: '${p.replaceFirst('పని:', '').trim()}\n\n',
            style: const TextStyle(color: Colors.white),
          ),
        );
      } else if (p.startsWith('Observed:')) {
        spans.add(
          const TextSpan(
            text: 'Observed: ',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
        );
        spans.add(
          TextSpan(
            text: '${p.replaceFirst('Observed:', '').trim()}\n\n',
            style: const TextStyle(color: Colors.white),
          ),
        );
      } else if (p.startsWith('देखा गया:')) {
        spans.add(
          const TextSpan(
            text: 'देखा गया: ',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
        );
        spans.add(
          TextSpan(
            text: '${p.replaceFirst('देखा गया:', '').trim()}\n\n',
            style: const TextStyle(color: Colors.white),
          ),
        );
      } else if (p.startsWith('గమనించబడింది:')) {
        spans.add(
          const TextSpan(
            text: 'గమనించబడింది: ',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
        );
        spans.add(
          TextSpan(
            text: '${p.replaceFirst('గమనించబడింది:', '').trim()}\n\n',
            style: const TextStyle(color: Colors.white),
          ),
        );
      } else if (p.startsWith('What we learned:')) {
        spans.add(
          const TextSpan(
            text: 'What we learned: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigoAccent,
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: '${p.replaceFirst('What we learned:', '').trim()}\n\n',
            style: const TextStyle(color: Colors.white),
          ),
        );
      } else if (p.startsWith('हमने क्या सीखा:')) {
        spans.add(
          const TextSpan(
            text: 'हमने क्या सीखा: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigoAccent,
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: '${p.replaceFirst('हमने क्या सीखा:', '').trim()}\n\n',
            style: const TextStyle(color: Colors.white),
          ),
        );
      } else if (p.startsWith('మనం ఏమి నేర్చుకున్నాం:')) {
        spans.add(
          const TextSpan(
            text: 'మనం ఏమి నేర్చుకున్నాం: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigoAccent,
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: '${p.replaceFirst('మనం ఏమి నేర్చుకున్నాం:', '').trim()}\n\n',
            style: const TextStyle(color: Colors.white),
          ),
        );
      } else {
        spans.add(
          TextSpan(text: '$p\n\n', style: const TextStyle(color: Colors.white)),
        );
      }
    }
    return spans;
  }

  Widget _buildSidebarContent(BuildContext context) {
    List<Map<String, String>> stepsText = [];
    int maxSteps = [0, 3, 4, 3, 2, 2][_scenario];

    for (int i = 1; i <= maxSteps; i++) {
      stepsText.add({'text': t('s${_scenario}_text_$i')});
    }

    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        const SizedBox(height: 50),

        Text(
          t('appTitle'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          t('appSubtitle'),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    if (_lang == 'en') {
                      _lang = 'hi';
                    } else {
                      _lang = 'en';
                    }
                  });
                  AudioEngine.click();
                },
                icon: const Icon(Icons.language, size: 18, color: Colors.white),
                label: Text(
                  _lang.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF020617),
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _resetLab,
              icon: const Icon(
                Icons.refresh,
                size: 18,
                color: Colors.redAccent,
              ),
              label: Text(
                t('reset'),
                style: const TextStyle(color: Colors.redAccent),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Text(
          t('selectScenario').toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF020617),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _scenario,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E293B),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items:
                  [1, 2, 3, 4, 5].map((int val) {
                    return DropdownMenuItem<int>(
                      value: val,
                      child: Text(
                        t('s${val}_title'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (val) {
                if (val != null) _loadScenario(val);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ------------------ MISSION OBJECTIVE ------------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.track_changes,
                    color: Colors.blueAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t('theory').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t('s${_scenario}_obj'),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // -------------------------------------------------------
        ...List.generate(stepsText.length, (index) {
          bool isActive = index == _step;
          bool isDone = index < _step;
          return AnimatedContainer(
            key: _stepKeys[index],
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isActive
                      ? const Color(0xFF6366F1).withOpacity(0.15)
                      : Colors.transparent,
              border: Border.all(
                color:
                    isActive
                        ? const Color(0xFF6366F1)
                        : Colors.white.withOpacity(0.1),
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ]
                      : [],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isDone
                            ? Colors.green
                            : (isActive
                                ? const Color(0xFF6366F1)
                                : Colors.grey.withOpacity(0.5)),
                  ),
                  child:
                      isDone
                          ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                          : Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${t('stepLabel')} ${index + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: _parseRichText(stepsText[index]['text']!),
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? Colors.white54 : Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        if (_step >= stepsText.length)
          Container(
            key: _stepKeys[math.min(stepsText.length, _stepKeys.length - 1)],
            margin: const EdgeInsets.only(top: 8, bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      t('completed'),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  t('s${_scenario}_sum'),
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

        const SizedBox(height: 32),
        const Divider(color: Colors.white24),
        const SizedBox(height: 16),
        const Text(
          '© ZeroScienceLab - Fall in love with math and Science',
          style: TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCurtainOpen) {
      return Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.6),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.music_note,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                t('appTitle'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t('appSubtitle'),
                style: const TextStyle(color: Colors.grey, fontSize: 20),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _startLab,
                icon: const Icon(Icons.play_circle_fill, size: 28),
                label: Text(
                  t('enterLab'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * _sidebarWidthPct;

    int maxSteps = [0, 3, 4, 3, 2, 2][_scenario];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: Stack(
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _isSidebarOpen ? sidebarWidth : 0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.95),
                    border: Border(
                      right: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  child: ClipRect(
                    child:
                        _isSidebarOpen
                            ? _buildSidebarContent(context)
                            : const SizedBox(),
                  ),
                ),

                Expanded(
                  child: ClipRect(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          color: const Color(0xFF020617),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: GestureDetector(
                                  onScaleStart: _handleScaleStart,
                                  onScaleUpdate: _handleScaleUpdate,
                                  onScaleEnd: _handleScaleEnd,
                                  child: Listener(
                                    onPointerDown:
                                        (e) => _handlePointerDown(
                                          e,
                                          constraints.biggest,
                                        ),
                                    onPointerMove:
                                        (e) => _handlePointerMove(
                                          e,
                                          constraints.biggest,
                                        ),
                                    onPointerUp: _handlePointerUp,
                                    child: CustomPaint(
                                      painter: _GridPainter(state: this),
                                      size: Size.infinite,
                                    ),
                                  ),
                                ),
                              ),

                              Positioned(
                                bottom: 100,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_scenario < 5 &&
                                        _step >= maxSteps &&
                                        _scenario != 4)
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          AudioEngine.click();
                                          _loadScenario(_scenario + 1);
                                        },
                                        icon: const Icon(Icons.arrow_forward),
                                        label: Text(t('nextScenario')),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF10B981,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                          elevation: 8,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // COMPACT & DRAGGABLE ACTIVE STEP HUD
                              if (!_isSidebarOpen)
                                Positioned(
                                  left: _hudOffset.dx,
                                  top: _hudOffset.dy,
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      setState(() {
                                        _hudOffset += details.delta;
                                      });
                                    },
                                    child: Container(
                                      width: 270,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF0F172A,
                                        ).withOpacity(0.95),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.blueAccent,
                                          width: 1.5,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black54,
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.drag_indicator,
                                                color: Colors.grey,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${t('stepLabel')} ${math.min(_step + 1, maxSteps)}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                  color: Colors.blueAccent,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text.rich(
                                            TextSpan(
                                              children: _parseRichText(
                                                _step < maxSteps
                                                    ? t(
                                                      's${_scenario}_text_${_step + 1}',
                                                    )
                                                    : t('s${_scenario}_sum'),
                                              ),
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              height: 1.3,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  AudioEngine.click();
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
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER ---
class _GridPainter extends CustomPainter {
  final _RhythmsLabState state;

  _GridPainter({required this.state}) : super(repaint: state._repaintNotifier);

  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Paint paint,
  ) {
    RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    canvas.drawRRect(rrect, paint);
  }

  void _drawBlock(
    Canvas canvas,
    double x,
    double y,
    int type, {
    double scale = 1,
    double alpha = 1,
  }) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);

    double h = state.U - 8;
    double w = (type == 1 ? state.U : state.U * 2) - 8;

    Color baseColor =
        type == 1 ? const Color(0xFF6366F1) : const Color(0xFFF59E0B);
    Color darkColor =
        type == 1 ? const Color(0xFF4F46E5) : const Color(0xFFD97706);
    Color lightColor =
        type == 1 ? const Color(0xFF818CF8) : const Color(0xFFFBBF24);

    _drawRoundedRect(
      canvas,
      -w / 2,
      -h / 2,
      w,
      h,
      8,
      Paint()..color = baseColor.withOpacity(alpha),
    );
    _drawRoundedRect(
      canvas,
      -w / 2,
      0,
      w,
      h / 2,
      8,
      Paint()..color = darkColor.withOpacity(alpha),
    );
    _drawRoundedRect(
      canvas,
      -w / 2 + 4,
      -h / 2 + 4,
      w - 8,
      h - 12,
      6,
      Paint()..color = lightColor.withOpacity(alpha),
    );

    TextPainter tp = TextPainter(
      text: TextSpan(
        text: type == 1 ? '1' : '2',
        style: TextStyle(
          color: Colors.white.withOpacity(alpha),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2 + 2));

    canvas.restore();
  }

  void _drawBlockGroup(
    Canvas canvas,
    double x,
    double y,
    List<int> arr, {
    double scale = 1,
    double alpha = 1,
  }) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    if (arr.isNotEmpty) {
      double totalW = arr.fold(0, (s, a) => s + a) * state.U;
      double curX = -totalW / 2;
      for (int type in arr) {
        double w = type * state.U;
        _drawBlock(canvas, curX + w / 2, 0, type, alpha: alpha);
        curX += w;
      }
    }
    canvas.restore();
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset centerPos,
    Color color,
    double fontSize,
    TextAlign align,
  ) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    double dx =
        align == TextAlign.center
            ? centerPos.dx - tp.width / 2
            : (align == TextAlign.right
                ? centerPos.dx - tp.width
                : centerPos.dx);
    tp.paint(canvas, Offset(dx, centerPos.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(
      size.width / 2 + state._panX,
      size.height / 2 + state._panY,
    );
    canvas.scale(state._zoom, state._zoom);

    final Paint gridLinePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    for (double i = -2000; i < 2000; i += state.U) {
      canvas.drawLine(Offset(i, -2000), Offset(i, 2000), gridLinePaint);
      canvas.drawLine(Offset(-2000, i), Offset(2000, i), gridLinePaint);
    }

    if (state._scenario < 5) {
      _drawDispensers(canvas);
      _drawShelves(canvas);
      _drawTray(canvas);

      if (state._scenario == 4 && state._completedRhythms[5]!.length == 8) {
        var l = state._getLayout();
        double btnY = l['trayY']! + 90;

        _drawRoundedRect(
          canvas,
          -200,
          btnY - 50,
          400,
          45,
          10,
          Paint()..color = const Color(0xFF10B981).withOpacity(0.15),
        );
        _drawRoundedRect(
          canvas,
          -200,
          btnY - 50,
          400,
          45,
          10,
          Paint()
            ..color = const Color(0xFF10B981).withOpacity(0.5)
            ..style = PaintingStyle.stroke,
        );
        _drawText(
          canvas,
          state.t('completed'),
          Offset(0, btnY - 28),
          const Color(0xFF10B981),
          18,
          TextAlign.center,
        );

        _drawRoundedRect(
          canvas,
          -100,
          btnY + 10,
          200,
          44,
          22,
          Paint()
            ..color =
                state._hoverBtnNext
                    ? const Color(0xFF34D399)
                    : const Color(0xFF10B981),
        );
        _drawText(
          canvas,
          state.t('nextScenario'),
          Offset(0, btnY + 32),
          Colors.white,
          16,
          TextAlign.center,
        );
      }
    } else {
      _drawCalculator(canvas);
    }

    for (var anim in state._animations) {
      double p = math.min(
        1.0,
        (state._currentTime - anim.start) / anim.duration,
      );
      if (anim.type == 'float') {
        double ease = 1 - math.pow(1 - p, 3).toDouble();
        double cx = anim.x1 + (anim.x2 - anim.x1) * ease;
        double cy = anim.y1 + (anim.y2 - anim.y1) * ease;
        _drawBlockGroup(canvas, cx, cy, anim.arr!, alpha: 1 - p);
      } else if (anim.type == 'mathSum') {
        if (p < 0.5) {
          double p2 = p * 2;
          double e2 = 1 - math.pow(1 - p2, 3).toDouble();
          double cx1 = anim.n1!['x'] + (anim.x2 - anim.n1!['x']) * e2;
          double cy1 = anim.n1!['y'] + (anim.y2 - anim.n1!['y']) * e2;
          double cx2 = anim.n2!['x'] + (anim.x2 - anim.n2!['x']) * e2;
          double cy2 = anim.n2!['y'] + (anim.y2 - anim.n2!['y']) * e2;
          _drawText(
            canvas,
            '${anim.n1!['val']}',
            Offset(cx1, cy1),
            Colors.blue,
            24,
            TextAlign.center,
          );
          _drawText(
            canvas,
            '${anim.n2!['val']}',
            Offset(cx2, cy2),
            Colors.blue,
            24,
            TextAlign.center,
          );
        } else {
          double scale = 24 + math.sin(p * math.pi) * 15;
          _drawText(
            canvas,
            '${anim.sum}',
            Offset(anim.x2, anim.y2),
            Colors.green,
            scale,
            TextAlign.center,
          );
        }
      } else if (anim.type == 'textFly') {
        double ease = 1 - math.pow(1 - p, 3).toDouble();
        double cy = anim.y1 + (anim.y2 - anim.y1) * ease;
        _drawText(
          canvas,
          anim.text!,
          Offset(anim.x1, cy),
          const Color(0xFFF43F5E).withOpacity(1 - p),
          30,
          TextAlign.center,
        );
      }
    }

    if (state._draggedEntity != null) {
      if (state._scenario < 5) {
        _drawBlockGroup(
          canvas,
          state._draggedEntity!['x'],
          state._draggedEntity!['y'],
          state._draggedEntity!['arr'] as List<int>,
          scale: 1.1,
        );
      } else {
        canvas.drawShadow(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                state._draggedEntity!['x'] - 25,
                state._draggedEntity!['y'] - 25,
                50,
                50,
              ),
              const Radius.circular(8),
            ),
          ),
          Colors.black,
          15,
          true,
        );
        _drawRoundedRect(
          canvas,
          state._draggedEntity!['x'] - 25,
          state._draggedEntity!['y'] - 25,
          50,
          50,
          8,
          Paint()..color = const Color(0xFF6366F1),
        );
        _drawText(
          canvas,
          '${state._draggedEntity!['val']}',
          Offset(state._draggedEntity!['x'], state._draggedEntity!['y']),
          Colors.white,
          20,
          TextAlign.center,
        );
      }
    }

    canvas.restore();
  }

  void _drawDispensers(Canvas canvas) {
    var l = state._getLayout();
    _drawBlock(canvas, -350, l['dispShortY']!, 1);
    _drawText(
      canvas,
      state.t('shortBeat'),
      Offset(-350, l['dispShortY']! + 40),
      const Color(0xFF94A3B8),
      14,
      TextAlign.center,
    );

    _drawBlock(canvas, -350, l['dispLongY']!, 2);
    _drawText(
      canvas,
      state.t('longBeat'),
      Offset(-350, l['dispLongY']! + 40),
      const Color(0xFF94A3B8),
      14,
      TextAlign.center,
    );
  }

  void _drawShelves(Canvas canvas) {
    int maxN = math.min(state._scenario + 1, 5);
    for (int i = 1; i <= maxN; i++) {
      var conf = state._getShelfPosition(i);
      double w = 220;
      double h = conf['h']!;

      bool isActiveShelf = false;
      if (state._scenario == 2 &&
          state._step < 2 &&
          i == 2 &&
          state._currentTray.length == 1 &&
          state._currentTray[0] == 1) {
        isActiveShelf = true;
      }
      if (state._scenario == 2 &&
          state._step == 2 &&
          i == 1 &&
          state._currentTray.length == 1 &&
          state._currentTray[0] == 2) {
        isActiveShelf = true;
      }
      if (state._scenario == 3 &&
          state._step == 0 &&
          i == 3 &&
          state._currentTray.length == 1 &&
          state._currentTray[0] == 1) {
        isActiveShelf = true;
      }
      if (state._scenario == 3 &&
          state._step == 1 &&
          i == 2 &&
          state._currentTray.length == 1 &&
          state._currentTray[0] == 2) {
        isActiveShelf = true;
      }

      if (isActiveShelf) {
        canvas.drawShadow(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(conf['x']! - w / 2, conf['y']!, w, h),
              const Radius.circular(8),
            ),
          ),
          Colors.green,
          20,
          true,
        );
        _drawRoundedRect(
          canvas,
          conf['x']! - w / 2,
          conf['y']!,
          w,
          h,
          8,
          Paint()
            ..color = Colors.green
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }

      _drawRoundedRect(
        canvas,
        conf['x']! - w / 2,
        conf['y']!,
        w,
        h,
        8,
        Paint()..color = const Color(0xFF0F172A),
      );
      _drawRoundedRect(
        canvas,
        conf['x']! - w / 2,
        conf['y']! + h,
        w,
        10,
        4,
        Paint()..color = const Color(0xFF334155),
      );

      _drawText(
        canvas,
        '$i ${state.t('beats')}',
        Offset(conf['x']!, conf['y']! - 15),
        const Color(0xFFCBD5E1),
        16,
        TextAlign.center,
      );

      var items = state._completedRhythms[i]!;
      if (state._scenario == 4 && i == 5 && items.length < 8) {
        _drawText(
          canvas,
          '${items.length} / ?',
          Offset(conf['x']!, conf['y']! + h / 2),
          const Color(0xFF6366F1),
          28,
          TextAlign.center,
        );
      } else {
        double baseH = 28;
        double scale = 1;
        if (items.length * baseH > h - 20) {
          scale = (h - 20) / (items.length * baseH);
        }
        double itemSpacing = baseH * scale;
        double totalH = items.length * itemSpacing;
        double startY = conf['y']! + h / 2 - totalH / 2 + 10;

        for (int j = 0; j < items.length; j++) {
          _drawBlockGroup(
            canvas,
            conf['x']!,
            startY + j * itemSpacing,
            items[j],
            scale: 0.45 * scale,
          );
        }
      }

      if (items.isNotEmpty || i < 5) {
        String count =
            (i == 5 && state._scenario == 4 && items.length < 8)
                ? '?'
                : '${items.length}';
        canvas.drawCircle(
          Offset(conf['x']! + w / 2 - 10, conf['y']! - 15),
          14,
          Paint()..color = const Color(0xFF22C55E),
        );
        _drawText(
          canvas,
          count,
          Offset(conf['x']! + w / 2 - 10, conf['y']! - 14),
          Colors.white,
          14,
          TextAlign.center,
        );
      }
    }
  }

  void _drawTray(Canvas canvas) {
    int targetBeats = state._scenario + 1;
    double w = targetBeats * state.U;
    double h = state.U;
    double startX = -w / 2;
    double trayY = state._getLayout()['trayY']!;

    Paint basePaint = Paint()..color = const Color(0xFF1E293B);
    Paint borderPaint =
        Paint()
          ..color =
              state._hoverValid
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF334155)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
    _drawRoundedRect(
      canvas,
      startX - 8,
      trayY - h / 2 - 8,
      w + 16,
      h + 16,
      10,
      basePaint,
    );
    _drawRoundedRect(
      canvas,
      startX - 8,
      trayY - h / 2 - 8,
      w + 16,
      h + 16,
      10,
      borderPaint,
    );

    Paint emptyPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    for (int i = 0; i < targetBeats; i++) {
      _drawRoundedRect(
        canvas,
        startX + i * state.U + 4,
        trayY - h / 2 + 4,
        state.U - 8,
        h - 8,
        6,
        emptyPaint,
      );
    }

    if (state._currentTray.isNotEmpty) {
      double curX = startX;
      for (int type in state._currentTray) {
        double tw = type * state.U;
        _drawBlock(canvas, curX + tw / 2, trayY, type);
        curX += tw;
      }
    }
  }

  void _drawCalculator(Canvas canvas) {
    double x = 0;
    double y = -50;
    _drawRoundedRect(
      canvas,
      x - 200,
      y - 100,
      400,
      200,
      16,
      Paint()..color = const Color(0xFF1E293B),
    );
    _drawText(
      canvas,
      "V(n) = V(n-1) + V(n-2)",
      Offset(x, y - 50),
      const Color(0xFFF8FAFC),
      20,
      TextAlign.center,
    );

    _drawRoundedRect(
      canvas,
      x - 250,
      y + 150,
      500,
      80,
      12,
      Paint()..color = const Color(0xFF0F172A),
    );
    for (int i = 0; i < state._s5Tiles.length; i++) {
      int v = state._s5Tiles[i];
      double tx = (x - 200) + i * 70;
      if (state._draggedEntity == null || state._draggedEntity!['val'] != v) {
        _drawRoundedRect(
          canvas,
          tx - 25,
          y + 190 - 25,
          50,
          50,
          8,
          Paint()..color = const Color(0xFF6366F1),
        );
        _drawText(
          canvas,
          '$v',
          Offset(tx, y + 190),
          Colors.white,
          20,
          TextAlign.center,
        );
      }
    }

    void drawCalcBox(double bx, int? val, bool active) {
      _drawRoundedRect(
        canvas,
        bx - 30,
        y + 20 - 30,
        60,
        60,
        8,
        Paint()
          ..color = active ? Colors.green : const Color(0xFF64748B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      if (val != null) {
        _drawRoundedRect(
          canvas,
          bx - 25,
          y + 20 - 25,
          50,
          50,
          6,
          Paint()..color = const Color(0xFF6366F1),
        );
        _drawText(
          canvas,
          '$val',
          Offset(bx, y + 20),
          Colors.white,
          20,
          TextAlign.center,
        );
      }
    }

    if (state._step == 0) {
      drawCalcBox(
        x - 90,
        state._s5Box1,
        state._hoverValid &&
            state._draggedEntity != null &&
            (state._draggedEntity!['x'] - (x - 90)).abs() < 30,
      );
      _drawText(
        canvas,
        "+",
        Offset(x - 30, y + 20),
        Colors.white,
        24,
        TextAlign.center,
      );
      drawCalcBox(
        x + 30,
        state._s5Box2,
        state._hoverValid &&
            state._draggedEntity != null &&
            (state._draggedEntity!['x'] - (x + 30)).abs() < 30,
      );
      _drawText(
        canvas,
        "=",
        Offset(x + 90, y + 20),
        Colors.white,
        24,
        TextAlign.center,
      );

      if (state._s5Box1 != null && state._s5Box2 != null) {
        _drawRoundedRect(
          canvas,
          x + 120,
          y - 10,
          80,
          60,
          8,
          Paint()..color = Colors.green,
        );
        _drawText(
          canvas,
          state.t('calculate'),
          Offset(x + 160, y + 20),
          Colors.white,
          14,
          TextAlign.center,
        );
      }
    } else {
      _drawText(
        canvas,
        "8 Beats = ",
        Offset(x - 60, y + 20),
        Colors.white,
        24,
        TextAlign.center,
      );
      drawCalcBox(
        x + 30,
        state._s5BoxFinal,
        state._hoverValid &&
            state._draggedEntity != null &&
            (state._draggedEntity!['x'] - (x + 30)).abs() < 30,
      );

      if (state._s5BoxFinal != null) {
        _drawRoundedRect(
          canvas,
          x + 90,
          y - 10,
          80,
          60,
          8,
          Paint()..color = Colors.green,
        );
        _drawText(
          canvas,
          state.t('calcSubmit'),
          Offset(x + 130, y + 20),
          Colors.white,
          14,
          TextAlign.center,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
