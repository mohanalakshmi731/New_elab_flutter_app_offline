// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CryptarithmsApp());
}

class CryptarithmsApp extends StatelessWidget {
  const CryptarithmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Solving Cryptarithms',
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
      home: const CryptarithmsLab(),
    );
  }
}

// --- TRANSLATIONS ---

const Map<String, Map<String, String>> translations = {
  'en': {
    'appTitle': "Solving Cryptarithms: The Digit Detective",
    'appSubtitle': "Class 7 • Number Play",
    'enterLab': "Enter Lab",
    'reset': "Reset",
    'selectScenario': "Select Puzzle",
    'nextScenario': "Next Challenge",
    'stepLabel': "OBSERVATION",
    'theory': "Investigation Notes",
    'completed': "Case Closed!",
    'successTitle': "Master Detective!",
    'successDesc':
        "You have successfully decoded the hidden letters and mastered the logic of cryptarithms.",
    'restartLab': "Restart Lab",

    's1_title': "1. The Triple 'T' Teaser",
    's1_obj':
        "To solve the cryptarithm T + T + T = UT by understanding how a single-digit sum can result in a two-digit number and create a 'carry-over'.",
    's1_hud_1':
        "Task: DRAG the '2' token and DROP it onto the 'T' block to test the value.",
    's1_text_1:':
        "<b>Task:</b> DRAG the '2' token and DROP it onto the 'T' block to test the value.<br><br><span class='text-rose-500 font-semibold'>Observed:</span> 2 + 2 + 2 = 6. The result '6' does not match the 'T' above it (which is '2'). The result glows red.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> T cannot be 2.",
    's1_hud_2':
        "Task: The previous attempt failed. Try '5'. DRAG the '5' token and DROP it onto the 'T' block.",
    's1_text_2':
        "<b>Task:</b> The previous attempt failed. Try '5'. DRAG the '5' token and DROP it onto the 'T' block.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> 5 + 5 + 5 = 15. The '5' perfectly matches the 'T'. A '1' carry-over block pops into the tens column.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> T must be 5 to end with the same digit.",
    's1_hud_3':
        "Task: Look at the tens column. DRAG the '1' token and DROP it onto the 'U' block.",
    's1_text_3':
        "<b>Task:</b> Look at the tens column. DRAG the '1' token and DROP it onto the 'U' block.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> The 'U' block accepts the carry value '1'. The equation 5 + 5 + 5 = 15 is complete.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> A carry-over directly solved the value for U.",
    's1_sum':
        "By testing values in the units column, we found T=5. This created a carry-over of 1, solving U=1.",

    's2_title': "2. The Double 'K' Conundrum",
    's2_obj':
        "To solve the cryptarithm K2 + K2 = HMM by using a known digit and deducing the unknown letters.",
    's2_hud_1':
        "Task: Look at the units column: 2 + 2. DRAG the correct number token and DROP it onto the 'M' block.",
    's2_text_1':
        "<b>Task:</b> Look at the units column: 2 + 2. DRAG the correct number token and DROP it onto the 'M' block.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> 2 + 2 = 4. The 'M' blocks now display '4'. No carry-over.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> Known numbers can immediately solve for letters.",
    's2_hud_2': "Task: K + K must end in 4. Try dragging '7' to the 'K' block.",
    's2_text_2':
        "<b>Task:</b> K + K must end in 4. Try dragging '7' to the 'K' block.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> 7 + 7 = 14. The '4' drops down matching 'M'. A '1' carry-over block pops out.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> The digits match perfectly. K = 7.",
    's2_hud_3':
        "Task: The carry-over is '1'. DRAG the '1' token to the 'H' block.",
    's2_text_3':
        "<b>Task:</b> The carry-over is '1'. DRAG the '1' token to the 'H' block.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> The entire puzzle 72 + 72 = 144 is correct.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> Working from right to left using logical deductions solved the puzzle.",
    's2_sum':
        "The known digits gave us M=4. This helped find K=7, which created a carry that solved H=1.",

    's3_title': "3. The 'SO' Simple Solution",
    's3_obj':
        "To solve the cryptarithm SO + SO = TOO and understand how a letter can be deduced to be zero.",
    's3_hud_1': "Task: Look at O + O = O. Try dragging '0' to the 'O' block.",
    's3_text_1':
        "<b>Task:</b> Look at O + O = O. Try dragging '0' to the 'O' block.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> 0 + 0 = 0. The rule holds true.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> 0 is a valid digit for a number added to itself resulting in itself.",
    's3_hud_2':
        "Task: S + S = 0. What single digit added to itself equals 10? DRAG it to the 'S' block.",
    's3_text_2':
        "<b>Task:</b> S + S = 0. What single digit added to itself equals 10? DRAG it to the 'S' block.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> You dragged '5'. 5 + 5 = 10. The '0' matches 'O'. A '1' carry pops out.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> We deduce digits by working backward from the required sum.",
    's3_hud_3': "Task: Assign the carry-over. DRAG '1' to the 'T' block.",
    's3_text_3':
        "<b>Task:</b> Assign the carry-over. DRAG '1' to the 'T' block.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> 50 + 50 = 100.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> Systematic deduction column by column guarantees the correct answer.",
    's3_sum':
        "O+O=O led to O=0, and S+S ending in 0 led to S=5. The carry-over solved the rest.",

    's4_title': "4. The Curious Case of 'C'",
    's4_obj':
        "To solve the cryptarithm C1 + C = 1FF independently by applying the learned strategies.",
    's4_hud_1':
        "Task: Independently decode C1 + C = 1FF. Drag numbers to test hypotheses. No leading zero, no duplicates.",
    's4_text_1':
        "<b>Task:</b> Independently decode C1 + C = 1FF. Drag numbers to test hypotheses. No leading zero, no duplicates.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> You successfully mapped C to 9, and F to 0.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> You independently evaluated the rules to find 91 + 9 = 100.",
    's4_sum': "You solved it! 91 + 9 = 100.",

    's5_title': "5. The 'FOUR'-midable Finale",
    's5_obj':
        "To solve the more complex cryptarithm TWO + TWO = FOUR involving more letters.",
    's5_hud_1':
        "Task: Decode TWO + TWO = FOUR. Notice the result has 4 digits. Use all available tokens carefully.",
    's5_text_1':
        "<b>Task:</b> Decode TWO + TWO = FOUR. Notice the result has 4 digits. Use all available tokens carefully.<br><br><span class='text-emerald-500 font-semibold'>Observed:</span> You systematically mapped T=7, W=3, O=4, F=1, U=6, R=8.<br><br><span class='text-indigo-400 font-semibold'>What we learned:</span> Breaking a large problem into small column checks is a powerful computational skill.",
    's5_sum': "Incredible deduction! 734 + 734 = 1468.",
  },
  'hi': {
    'appTitle': "क्रिप्टअरिथम्स सुलझाना: द डिजिट डिटेक्टिव",
    'appSubtitle': "कक्षा 7 • संख्याओं का खेल",
    'enterLab': "लैब में प्रवेश करें",
    'reset': "रीसेट",
    'selectScenario': "पहेली चुनें",
    'nextScenario': "अगली चुनौती",
    'stepLabel': "अवलोकन",
    'theory': "जांच नोट्स",
    'completed': "केस बंद!",
    'successTitle': "मास्टर डिटेक्टिव!",
    'successDesc':
        "आपने सफलतापूर्वक छिपे हुए अक्षरों को डिकोड कर लिया है और क्रिप्टअरिथम्स के तर्क में महारत हासिल कर ली है।",
    'restartLab': "लैब को फिर से शुरू करें",

    's1_title': "1. ट्रिपल 'T' टीज़र",
    's1_obj':
        "T + T + T = UT को समझना और यह जानना कि एक-अंक का योग कैसे दो-अंक की संख्या में बदल सकता है और एक 'कैरी' बना सकता है।",
    's1_hud_1':
        "कार्य: मूल्य का परीक्षण करने के लिए '2' टोकन खींचें और इसे 'T' ब्लॉक पर छोड़ दें।",
    's1_text_1':
        "<b>कार्य:</b> मूल्य का परीक्षण करने के लिए '2' टोकन खींचें और इसे 'T' ब्लॉक पर छोड़ दें।<br><br><span class='text-rose-500 font-semibold'>देखा गया:</span> 2 + 2 + 2 = 6। परिणाम '6' ऊपर के 'T' ('2') से मेल नहीं खाता। यह लाल रंग में चमकता है।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> T 2 नहीं हो सकता।",
    's1_hud_2':
        "कार्य: पिछला प्रयास विफल रहा। '5' आज़माएँ। '5' टोकन खींचें और इसे 'T' ब्लॉक पर छोड़ दें।",
    's1_text_2':
        "<b>कार्य:</b> पिछला प्रयास विफल रहा। '5' आज़माएँ। '5' टोकन खींचें और इसे 'T' ब्लॉक पर छोड़ दें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> 5 + 5 + 5 = 15। '5' 'T' से पूरी तरह मेल खाता है। दहाई के कॉलम में '1' का कैरी आता है।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> उसी अंक के साथ समाप्त होने के लिए T को 5 होना चाहिए।",
    's1_hud_3':
        "कार्य: दहाई के कॉलम को देखें। '1' टोकन खींचें और इसे 'U' ब्लॉक पर छोड़ दें।",
    's1_text_3':
        "<b>कार्य:</b> दहाई के कॉलम को देखें। '1' टोकन खींचें और इसे 'U' ब्लॉक पर छोड़ दें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> 'U' ब्लॉक कैरी मूल्य '1' स्वीकार करता है। 5 + 5 + 5 = 15 समीकरण पूरा हो गया है।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> कैरी ने सीधे U का मूल्य हल कर दिया।",
    's1_sum':
        "इकाई के कॉलम में परीक्षण करके, हमने T=5 पाया। इससे 1 का कैरी बना, जिसने U=1 को हल किया।",

    's2_title': "2. डबल 'K' रहस्य",
    's2_obj': "K2 + K2 = HMM को एक ज्ञात अंक का उपयोग करके हल करना।",
    's2_hud_1':
        "कार्य: इकाई का कॉलम देखें: 2 + 2। सही टोकन खींचें और इसे 'M' ब्लॉक पर छोड़ दें।",
    's2_text_1':
        "<b>कार्य:</b> इकाई का कॉलम देखें: 2 + 2। सही टोकन खींचें और इसे 'M' ब्लॉक पर छोड़ दें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> 2 + 2 = 4। 'M' ब्लॉक अब '4' दिखाते हैं। कोई कैरी नहीं।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> ज्ञात अंक तुरंत अक्षरों को हल कर सकते हैं।",
    's2_hud_2':
        "कार्य: K + K 4 पर समाप्त होना चाहिए। 'K' ब्लॉक में '7' खींचकर आज़माएँ।",
    's2_text_2:':
        "<b>कार्य:</b> K + K 4 पर समाप्त होना चाहिए। 'K' ब्लॉक में '7' खींचकर आज़माएँ।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> 7 + 7 = 14। '4' नीचे आता है और 'M' से मेल खाता है। '1' का कैरी बाहर आता है।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> अंक पूरी तरह से मेल खाते हैं। K = 7.",
    's2_hud_3': "कार्य: कैरी '1' है। 'H' ब्लॉक में '1' टोकन खींचें।",
    's2_text_3':
        "<b>कार्य:</b> कैरी '1' है। 'H' ब्लॉक में '1' टोकन खींचें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> पूरी पहेली 72 + 72 = 144 सही है।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> दाईं से बाईं ओर तार्किक कटौती करने से पहेली हल हो गई।",
    's2_sum':
        "ज्ञात अंकों ने M=4 दिया। इससे K=7 का पता चला, जिससे कैरी बना और H=1 हल हो गया।",

    's3_title': "3. 'SO' का सरल समाधान",
    's3_obj':
        "SO + SO = TOO को हल करना और समझना कि कैसे एक अक्षर को शून्य माना जा सकता है।",
    's3_hud_1': "कार्य: O + O = O को देखें। 'O' ब्लॉक में '0' खींचकर आज़माएँ।",
    's3_text_1':
        "<b>कार्य:</b> O + O = O को देखें। 'O' ब्लॉक में '0' खींचकर आज़माएँ।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> 0 + 0 = 0। यह नियम सही बैठता है।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> 0 एक मान्य अंक है जिसे खुद से जोड़ने पर 0 ही आता है।",
    's3_hud_2':
        "कार्य: S + S = 0। कौन सा एक अंक खुद से जुड़कर 10 बनता है? इसे 'S' ब्लॉक में खींचें।",
    's3_text_2':
        "<b>कार्य:</b> S + S = 0। कौन सा एक अंक खुद से जुड़कर 10 बनता है? इसे 'S' ब्लॉक में खींचें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> आपने '5' खींचा। 5 + 5 = 10। '0' 'O' से मेल खाता है। एक '1' कैरी आता है।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> हम आवश्यक योग से पीछे की ओर काम करके अंकों का पता लगाते हैं।",
    's3_hud_3': "कार्य: कैरी असाइन करें। 'T' ब्लॉक में '1' खींचें।",
    's3_text_3':
        "<b>कार्य:</b> कैरी असाइन करें। 'T' ब्लॉक में '1' खींचें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> 50 + 50 = 100.<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> कॉलम दर कॉलम व्यवस्थित कटौती सही उत्तर की गारंटी देती है।",
    's3_sum':
        "O+O=O से O=0 मिला, और S+S 0 पर समाप्त होने से S=5 मिला। कैरी ने बाकी हल कर दिया।",

    's4_title': "4. 'C' का जिज्ञासु मामला",
    's4_obj':
        "सीखी गई रणनीतियों को लागू करके C1 + C = 1FF को स्वतंत्र रूप से हल करना।",
    's4_hud_1':
        "कार्य: स्वतंत्र रूप से C1 + C = 1FF को डिकोड करें। परिकल्पना का परीक्षण करें।",
    's4_text_1':
        "<b>कार्य:</b> स्वतंत्र रूप से C1 + C = 1FF को डिकोड करें।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> आपने C को 9 और F को 0 से सफलतापूर्वक मैप किया।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> आपने 91 + 9 = 100 खोजने के लिए नियमों का स्वतंत्र रूप से मूल्यांकन किया।",
    's4_sum': "आपने इसे हल कर लिया! 91 + 9 = 100.",

    's5_title': "5. 'FOUR' का महा-रहस्य",
    's5_obj': "अधिक अक्षरों वाले अधिक जटिल TWO + TWO = FOUR को हल करना।",
    's5_hud_1':
        "कार्य: TWO + TWO = FOUR को डिकोड करें। ध्यान दें कि परिणाम में 4 अंक हैं।",
    's5_text_1':
        "<b>कार्य:</b> TWO + TWO = FOUR को डिकोड करें। ध्यान दें कि परिणाम में 4 अंक हैं।<br><br><span class='text-emerald-500 font-semibold'>देखा गया:</span> आपने T=7, W=3, O=4, F=1, U=6, R=8 मैप किया।<br><br><span class='text-indigo-400 font-semibold'>हमने क्या सीखा:</span> बड़ी समस्या को छोटे कॉलम चेक में तोड़ना एक शक्तिशाली कम्प्यूटेशनल कौशल है।",
    's5_sum': "अविश्वसनीय कटौती! 734 + 734 = 1468.",
  },
  'te': {
    'appTitle': "క్రిప్టారిథమ్స్ సాధన: ద డిజిట్ డిటెక్టివ్",
    'appSubtitle': "7వ తరగతి • సంఖ్యలతో ఆట",
    'enterLab': "ల్యాబ్‌లోకి ప్రవేశించండి",
    'reset': "రీసెట్ చేయండి",
    'selectScenario': "పజిల్ ఎంచుకోండి",
    'nextScenario': "తదుపరి సవాలు",
    'stepLabel': "పరిశీలన",
    'theory': "పరిశోధన గమనికలు",
    'completed': "కేస్ ముగిసింది!",
    'successTitle': "మాస్టర్ డిటెక్టివ్!",
    'successDesc':
        "మీరు దాచిన అక్షరాలను విజయవంతంగా డీకోడ్ చేసారు మరియు క్రిప్టారిథమ్స్ లాజిక్‌ను మాస్టర్ చేసారు.",
    'restartLab': "ల్యాబ్‌ను పునఃప్రారంభించండి",

    's1_title': "1. ట్రిపుల్ 'T' టీజర్",
    's1_obj':
        "T + T + T = UT ని అర్థం చేసుకోవడం మరియు సింగిల్-డిజిట్ మొత్తం రెండు-అంకెల సంఖ్యగా ఎలా మారుతుందో తెలుసుకోవడం.",
    's1_hud_1':
        "పని: విలువను పరీక్షించడానికి '2' టోకెన్‌ను లాగి, దాన్ని 'T' బ్లాక్‌లో వదలండి.",
    's1_text_1':
        "<b>పని:</b> విలువను పరీక్షించడానికి '2' టోకెన్‌ను లాగి, దాన్ని 'T' బ్లాక్‌లో వదలండి.<br><br><span class='text-rose-500 font-semibold'>గమనించబడింది:</span> 2 + 2 + 2 = 6. ఫలితం '6' పైనున్న 'T' ('2') తో సరిపోలడం లేదు. ఇది ఎరుపు రంగులో మెరుస్తుంది.<br><br><span class='text-indigo-400 font-semibold'>మనం ఏమి నేర్చుకున్నాం:</span> T 2 కాకూడదు.",
    's1_hud_2':
        "పని: మునుపటి ప్రయత్నం విఫలమైంది. '5' ప్రయత్నించండి. '5' టోకెన్‌ను లాగి 'T' బ్లాక్‌లో వదలండి.",
    's1_text_2':
        "<b>పని:</b> మునుపటి ప్రయత్నం విఫలమైంది. '5' ప్రయత్నించండి. '5' టోకెన్‌ను లాగి 'T' బ్లాక్‌లో వదలండి.<br><br><span class='text-emerald-500 font-semibold'>గమనించబడింది:</span> 5 + 5 + 5 = 15. '5' 'T' తో సరిగ్గా సరిపోలుతుంది. పదుల కాలమ్‌లో '1' క్యారీ వచ్చింది.<br><br><span class='text-indigo-400 font-semibold'>మనం ఏమి నేర్చుకున్నాం:</span> ఒకే అంకెతో ముగియడానికి T 5 అయి ఉండాలి.",
    's1_hud_3':
        "పని: పదుల కాలమ్‌ను చూడండి. '1' టోకెన్‌ను లాగి దాన్ని 'U' బ్లాక్‌లో వదలండి.",
    's1_text_3':
        "<b>పని:</b> పదుల కాలమ్‌ను చూడండి. '1' టోకెన్‌ను లాగి దాన్ని 'U' బ్లాక్‌లో వదలండి.<br><br><span class='text-emerald-500 font-semibold'>గమనించబడింది:</span> 'U' బ్లాక్ క్యారీ '1' ని అంగీకరిస్తుంది. సమీకరణం పూర్తయింది.<br><br><span class='text-indigo-400 font-semibold'>మనం ఏమి నేర్చుకున్నాం:</span> క్యారీ నేరుగా U విలువను పరిష్కరించింది.",
    's1_sum':
        "యూనిట్ల కాలమ్‌లో పరీక్షించడం ద్వారా T=5 అని కనుగొన్నాము. ఇది క్యారీ 1ని సృష్టించి U=1ని పరిష్కరించింది.",

    's2_title': "2. డబుల్ 'K' మిస్టరీ",
    's2_obj': "తెలిసిన అంకెను ఉపయోగించి K2 + K2 = HMM ని పరిష్కరించడం.",
    's2_hud_1':
        "పని: యూనిట్ల కాలమ్‌ను చూడండి: 2 + 2. సరైన టోకెన్‌ను లాగి 'M' బ్లాక్‌లో వదలండి.",
    's2_text_1':
        "<b>పని:</b> యూనిట్ల కాలమ్‌ను చూడండి: 2 + 2. సరైన టోకెన్‌ను లాగి 'M' బ్లాక్‌లో వదలండి.<br><br><span class='text-emerald-500 font-semibold'>గమనించబడింది:</span> 2 + 2 = 4. 'M' బ్లాక్‌లు '4' చూపుతున్నాయి. క్యారీ లేదు.<br><br><span class='text-indigo-400 font-semibold'>మనం ఏమి నేర్చుకున్నాం:</span> తెలిసిన అంకెలు వెంటనే అక్షరాలను పరిష్కరించగలవు.",
    's2_hud_2': "పని: K + K 4 తో ముగియాలి. 'K' బ్లాక్‌కు '7' లాగండి.",
    's2_text_2':
        "<b>పని:</b> K + K 4 తో ముగియాలి. 'K' బ్లాక్‌కు '7' లాగండి.<br><br><span class='text-emerald-500 font-semibold'>గమనించబడింది:</span> 7 + 7 = 14. '4' కిందకు వచ్చి 'M' తో సరిపోలుతుంది. '1' క్యారీ వచ్చింది.<br><br><span class='text-indigo-400 font-semibold'>మనం ఏమి నేర్చుకున్నాం:</span> అంకెలు సరిగ్గా సరిపోలాయి. K = 7.",
    's2_hud_3': "పని: క్యారీ '1'. 'H' బ్లాక్‌కు '1' టోకెన్‌ను లాగండి.",
    's2_text_3':
        "<b>పని:</b> క్యారీ '1'. 'H' బ్లాక్‌కు '1' టోకెన్‌ను లాగండి.<br><br><span class='text-emerald-500 font-semibold'>గమనించబడింది:</span> మొత్తం పజిల్ 72 + 72 = 144 సరైనది.<br><br><span class='text-indigo-400 font-semibold'>మనం ఏమి నేర్చుకున్నాం:</span> కుడి నుండి ఎడమకు తార్కికంగా ఆలోచించడం వల్ల పజిల్ పరిష్కరించబడింది.",
    's2_sum':
        "తెలిసిన అంకెలు M=4 ఇచ్చాయి. ఇది K=7 కనుగొనడంలో సహాయపడింది, తద్వారా H=1 పరిష్కరించబడింది.",

    's3_title': "3. 'SO' సాధారణ పరిష్కారం",
    's3_obj':
        "SO + SO = TOO ని పరిష్కరించడం మరియు ఒక అక్షరాన్ని సున్నాగా ఎలా భావించాలో అర్థం చేసుకోవడం.",
    's3_hud_1': "పని: O + O = O చూడండి. 'O' బ్లాక్‌కు '0' లాగండి.",
    's3_text_1':
        "<b>పని:</b> O + O = O చూడండి. 'O' బ్లాక్‌కు '0' లాగండి.<br><br><span class='text-emerald-500 font-semibold'>గమనించబడింది:</span> 0 + 0 = 0. ఇది నియమానికి కట్టుబడి ఉంది.<br><br><span class='text-indigo-400 font-semibold'>మనం ఏమి నేర్చుకున్నాం:</span> తనను తాను కలుపుకుంటే అదే వచ్చే ఒకే ఒక్క అంకె 0.",
    's3_hud_2':
        "పని: S + S = 0. ఏ ఒకే అంకె తనతో తాను కలుపుకుంటే 10 అవుతుంది? దాన్ని 'S' కు లాగండి.",
    's3_text_2':
        "<b>పని:</b> S + S = 0. ఏ ఒకే అంకె తనతో తాను కలుపుకుంటే 10 అవుతుంది? దాన్ని 'S' కు లాగండి.<br><br><span class='text-emerald-500 font-semibold'>గమనించబడింది:</span> మీరు '5' లాగారు. 5 + 5 = 10. '0' 'O' తో సరిపోలుతుంది. '1' క్యారీ వచ్చింది.<br><br><span class='text-indigo-400 font-semibold'>మనం ఏమి నేర్చుకున్నాం:</span> అవసరమైన మొత్తం నుండి వెనుకకు ఆలోచించడం ద్వారా అంకెలను కనుగొంటాము.",
    's3_hud_3': "పని: క్యారీని కేటాయించండి. 'T' బ్లాక్‌కు '1' లాగండి.",
    's3_text_3':
        "<b>పని:</b> క్యారీని కేటాయించండి. 'T' బ్లాక్‌కు '1' లాగండి.<br><br><span class='text-emerald-500 font-semibold'>గమనించబడింది:</span> 50 + 50 = 100.<br><br><span class='text-indigo-400 font-semibold'>మనం ఏమి నేర్చుకున్నాం:</span> కాలమ్ వారీగా పద్ధతి సరైన జవాబుకు హామీ ఇస్తుంది.",
    's3_sum':
        "O+O=O ద్వారా O=0 అని తెలిసింది, మరియు S+S 0 తో ముగియడం ద్వారా S=5 తెలిసింది.",

    's4_title': "4. 'C' ఆసక్తికరమైన కేసు",
    's4_obj':
        "నేర్చుకున్న వ్యూహాలను వర్తింపజేయడం ద్వారా స్వతంత్రంగా C1 + C = 1FF పరిష్కరించడం.",
    's4_hud_1':
        "పని: స్వతంత్రంగా C1 + C = 1FF డీకోడ్ చేయండి. అంకెలను లాగి పరీక్షించండి.",
    's4_text_1':
        "<b>పని:</b> స్వతంత్రంగా C1 + C = 1FF డీకోడ్ చేయండి. అంకెలను లాగి పరీక్షించండి.<br><br><span class='text-emerald-500 font-semibold'>గమనించబడింది:</span> మీరు C ని 9 కి మరియు F ని 0 కి విజయవంతంగా మ్యాప్ చేసారు.<br><br><span class='text-indigo-400 font-semibold'>మనం ఏమి నేర్చుకున్నాం:</span> మీరు స్వతంత్రంగా 91 + 9 = 100 ని కనుగొన్నారు.",
    's4_sum': "మీరు పరిష్కరించారు! 91 + 9 = 100.",

    's5_title': "5. 'FOUR' మహా-రహస్యం",
    's5_obj':
        "మరిన్ని అక్షరాలతో సంక్లిష్టమైన TWO + TWO = FOUR పజిల్‌ను పరిష్కరించడం.",
    's5_hud_1':
        "పని: TWO + TWO = FOUR డీకోడ్ చేయండి. ఫలితంలో 4 అంకెలు ఉన్నాయని గమనించండి.",
    's5_text_1':
        "<b>పని:</b> TWO + TWO = FOUR డీకోడ్ చేయండి. ఫలితంలో 4 అంకెలు ఉన్నాయని గమనించండి.<br><br><span class='text-emerald-500 font-semibold'>గమనించబడింది:</span> మీరు T=7, W=3, O=4, F=1, U=6, R=8 మ్యాప్ చేసారు.<br><br><span class='text-indigo-400 font-semibold'>మనం ఏమి నేర్చుకున్నాం:</span> పెద్ద సమస్యను చిన్న కాలమ్‌లుగా విభజించడం మంచి నైపుణ్యం.",
    's5_sum': "అద్భుతమైన తగ్గింపు! 734 + 734 = 1468.",
  },
};

// --- AUDIO ENGINE ---
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

// --- DRAGGABLE DIALOG COMPONENT ---
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
  String type; // 'carryFly'
  int? val;
  double x1, y1, x2, y2;
  int start, duration;

  AnimData({
    required this.type,
    required this.start,
    required this.duration,
    this.val,
    this.x1 = 0,
    this.y1 = 0,
    this.x2 = 0,
    this.y2 = 0,
  });
}

// --- MAIN SCREEN ---
class CryptarithmsLab extends StatefulWidget {
  const CryptarithmsLab({super.key});

  @override
  State<CryptarithmsLab> createState() => _CryptarithmsLabState();
}

class _CryptarithmsLabState extends State<CryptarithmsLab>
    with SingleTickerProviderStateMixin {
  bool _isCurtainOpen = false;
  bool _isSidebarOpen = true;
  String _lang = 'en';
  final double _sidebarWidthPct = 0.35;
  final double U = 50.0;

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _stepKeys = List.generate(5, (_) => GlobalKey());

  double _panX = 0;
  double _panY = -30; // initial offset to make room for lower tray
  double _zoom = 1.0;
  double _baseZoom = 1.0;

  Offset _hudOffset = const Offset(20, 100);

  int _scenario = 1;
  int _step = 0;
  final Set<int> _completedScenarios = {};

  // Puzzle Definitions
  final Map<int, Map<String, List<String>>> _puzzles = {
    1: {
      't1': ['T'],
      't2': ['T'],
      't3': ['T'],
      'res': ['U', 'T'],
    },
    2: {
      't1': ['K', '2'],
      't2': ['K', '2'],
      'res': ['H', 'M', 'M'],
    },
    3: {
      't1': ['S', 'O'],
      't2': ['S', 'O'],
      'res': ['T', 'O', 'O'],
    },
    4: {
      't1': ['C', '1'],
      't2': ['C'],
      'res': ['1', 'F', 'F'],
    },
    5: {
      't1': ['T', 'W', 'O'],
      't2': ['T', 'W', 'O'],
      'res': ['F', 'O', 'U', 'R'],
    },
  };

  // Cryptarithm State
  Map<String, int?> _letters = {};
  List<String> _fixedDigits = [];
  Map<int, int> _carry = {};
  Map<int, bool> _colErrors = {};
  Map<int, bool> _colSuccess = {};
  Map<String, dynamic>? _draggedToken; // {val: 5, x: 100.0, y: 100.0}
  String? _hoverTarget;
  bool _hoverBtnNext = false;

  List<AnimData> _animations = [];

  late Ticker _ticker;
  int _currentTime = 0;
  final ValueNotifier<int> _repaintNotifier = ValueNotifier<int>(0);

  FutureOr<dynamic> Function()? get _showFinalSuccessDialog => null;

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
      _animations = [];
      _draggedToken = null;
      _hoverTarget = null;
      _hoverBtnNext = false;
      _carry = {};
      _colErrors = {};
      _colSuccess = {};
      _letters = {};
      _fixedDigits = [];

      final p = _puzzles[_scenario]!;
      void extract(List<String>? arr) {
        if (arr == null) return;
        for (var c in arr) {
          if (RegExp(r'\d').hasMatch(c)) {
            _fixedDigits.add(c);
          } else {
            _letters[c] = null;
          }
        }
      }

      extract(p['t1']);
      extract(p['t2']);
      extract(p['t3']);
      extract(p['res']);

      AudioEngine.click();
      _zoom = 1.0;
      _panX = 0;
      _panY = -30;
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
    return {
      'gridY': _scenario == 1 ? -180.0 : -140.0,
      'trayY': 160.0,
      'colWidth': 70.0,
      'rowHeight': 70.0,
    };
  }

  double _getColX(int colIndex, int totalCols) {
    var layout = _getLayout();
    double startX = ((totalCols - 1) * layout['colWidth']!) / 2;
    return startX - (colIndex * layout['colWidth']!);
  }

  void _evaluatePuzzle() {
    _carry = {};
    _colErrors = {};
    _colSuccess = {};
    final p = _puzzles[_scenario]!;

    int len1 = p['t1']?.length ?? 0;
    int len2 = p['t2']?.length ?? 0;
    int len3 = p['t3']?.length ?? 0;
    int lenRes = p['res']?.length ?? 0;
    int maxLen = math.max(len1, math.max(len2, math.max(len3, lenRes)));

    bool puzzleComplete = true;
    int currentCarry = 0;

    int? getVal(List<String>? arr, int cIdx) {
      if (arr == null || cIdx >= arr.length) return 0;
      String char = arr[arr.length - 1 - cIdx];
      if (RegExp(r'\d').hasMatch(char)) return int.parse(char);
      return _letters[char];
    }

    for (int cIdx = 0; cIdx < maxLen; cIdx++) {
      int? v1 = getVal(p['t1'], cIdx);
      int? v2 = getVal(p['t2'], cIdx);
      int? v3 = getVal(p['t3'], cIdx);
      int? vRes = getVal(p['res'], cIdx);

      if (v1 == null || v2 == null || v3 == null || vRes == null) {
        puzzleComplete = false;
        break; // Stop evaluating further left
      }

      int sum = v1 + v2 + v3 + currentCarry;
      int expectedDigit = sum % 10;
      int nextCarry = sum ~/ 10;

      if (vRes == expectedDigit) {
        _colSuccess[cIdx] = true;
        if (nextCarry > 0) {
          _carry[cIdx + 1] = nextCarry;
          var layout = _getLayout();
          double cx = _getColX(cIdx + 1, maxLen);
          int numRows =
              (p['t1'] != null ? 1 : 0) +
              (p['t2'] != null ? 1 : 0) +
              (p['t3'] != null ? 1 : 0);
          double resY = layout['gridY']! + numRows * layout['rowHeight']! + 30;
          _animations.add(
            AnimData(
              type: 'carryFly',
              val: nextCarry,
              x1: cx + layout['colWidth']!,
              y1: resY,
              x2: cx,
              y2: layout['gridY']! - 50,
              start: DateTime.now().millisecondsSinceEpoch,
              duration: 600,
            ),
          );
        }
        currentCarry = nextCarry;
      } else {
        _colErrors[cIdx] = true;
        puzzleComplete = false;
        AudioEngine.error();
        break;
      }
    }

    // Step logic mapping
    if (_scenario == 1) {
      if (_step == 0 && _colErrors[0] == true) {
        Future.delayed(
          const Duration(milliseconds: 1500),
          () => _markStepComplete(),
        );
      }
      if (_step == 1 && _colSuccess[0] == true) {
        _markStepComplete();
      }
      if (_step == 2 && puzzleComplete) {
        AudioEngine.success();
        _markStepComplete();
      }
    } else if (_scenario == 2 || _scenario == 3) {
      if (_step == 0 && _colSuccess[0] == true) {
        _markStepComplete();
      }
      if (_step == 1 && _colSuccess[1] == true) {
        _markStepComplete();
      }
      if (_step == 2 && puzzleComplete) {
        AudioEngine.success();
        _markStepComplete();
      }
    } else if (_scenario >= 4) {
      if (puzzleComplete) {
        AudioEngine.success();
        _markStepComplete();
      }
    }
  }

  void _markStepComplete({bool advanceUI = true}) {
    if (!mounted) return;
    setState(() {
      if (advanceUI) _step++;
      List<int> maxSteps = [
        0,
        3,
        3,
        3,
        1,
        1,
      ]; // Max interactive steps per scenario

      if (_step >= maxSteps[_scenario]) {
        _completedScenarios.add(_scenario);
        if (_scenario == 5) {
          Future.delayed(
            const Duration(milliseconds: 1000),
            _showFinalSuccessDialog,
          );
        }
      } else {
        if (_scenario < 4) AudioEngine.snap();
      }
    });
    if (advanceUI) _scrollToActiveStep();
  }

  void _handlePointerDown(PointerDownEvent e, Size canvasSize) {
    Offset pt = _screenToWorld(e.localPosition, canvasSize);
    var layout = _getLayout();
    List<int> maxSteps = [0, 3, 3, 3, 1, 1];

    // Check Next Challenge Button (Drawn on Canvas)
    if ((_scenario >= 4 && _step >= 1) ||
        (_scenario < 4 && _step >= maxSteps[_scenario])) {
      double btnY = layout['trayY']! + 100;
      if (pt.dx > -100 &&
          pt.dx < 100 &&
          pt.dy > btnY + 10 &&
          pt.dy < btnY + 54 &&
          _scenario < 5) {
        AudioEngine.tick();
        setState(() {
          _hoverBtnNext = false;
        });
        _loadScenario(_scenario + 1);
        return;
      }
    }

    // Pick up from Tray
    double trayW = 520;
    double trayH = 70;
    double startX = -trayW / 2;
    if (pt.dy > layout['trayY']! - trayH / 2 &&
        pt.dy < layout['trayY']! + trayH / 2) {
      for (int i = 0; i <= 9; i++) {
        double px = startX + 35 + i * 50;
        if ((pt.dx - px).abs() < 25) {
          bool isUsed = _fixedDigits.contains(i.toString());
          if (!isUsed) {
            _letters.forEach((key, val) {
              if (val == i) isUsed = true;
            });
          }
          if (!isUsed) {
            setState(() {
              _draggedToken = {'val': i, 'x': pt.dx, 'y': pt.dy};
            });
            AudioEngine.tick();
            return;
          }
        }
      }
    }

    // Pick up from Grid (Clear value)
    final p = _puzzles[_scenario]!;
    int maxLen = math.max(
      p['t1']?.length ?? 0,
      math.max(
        p['t2']?.length ?? 0,
        math.max(p['t3']?.length ?? 0, p['res']?.length ?? 0),
      ),
    );
    String? clickedLetter;

    void checkHit(List<String> arr, double ry) {
      for (int cInv = 0; cInv < arr.length; cInv++) {
        int cIdx = arr.length - 1 - cInv;
        double cx = _getColX(cIdx, maxLen);
        if ((pt.dx - cx).abs() < 30 && (pt.dy - ry).abs() < 30) {
          clickedLetter = arr[cInv];
        }
      }
    }

    int rowIdx = 0;
    if (p['t1'] != null) {
      checkHit(p['t1']!, layout['gridY']! + (rowIdx++) * layout['rowHeight']!);
    }
    if (p['t2'] != null) {
      checkHit(p['t2']!, layout['gridY']! + (rowIdx++) * layout['rowHeight']!);
    }
    if (p['t3'] != null) {
      checkHit(p['t3']!, layout['gridY']! + (rowIdx++) * layout['rowHeight']!);
    }

    double resY = layout['gridY']! + rowIdx * layout['rowHeight']! + 30;
    checkHit(p['res']!, resY);

    if (clickedLetter != null && !RegExp(r'\d').hasMatch(clickedLetter!)) {
      if (_letters[clickedLetter!] != null) {
        int val = _letters[clickedLetter!]!;
        setState(() {
          _letters[clickedLetter!] = null;
          _draggedToken = {'val': val, 'x': pt.dx, 'y': pt.dy};
        });
        AudioEngine.tick();
        _evaluatePuzzle();
      }
    }
  }

  void _handlePointerMove(PointerMoveEvent e, Size canvasSize) {
    Offset pt = _screenToWorld(e.localPosition, canvasSize);
    var layout = _getLayout();
    List<int> maxSteps = [0, 3, 3, 3, 1, 1];

    if ((_scenario >= 4 && _step >= 1) ||
        (_scenario < 4 && _step >= maxSteps[_scenario])) {
      double btnY = layout['trayY']! + 100;
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

    if (_draggedToken != null) {
      setState(() {
        _draggedToken!['x'] = pt.dx;
        _draggedToken!['y'] = pt.dy;

        _hoverTarget = null;
        final p = _puzzles[_scenario]!;
        int maxLen = math.max(
          p['t1']?.length ?? 0,
          math.max(
            p['t2']?.length ?? 0,
            math.max(p['t3']?.length ?? 0, p['res']?.length ?? 0),
          ),
        );

        void checkHover(List<String> arr, double ry) {
          for (int cInv = 0; cInv < arr.length; cInv++) {
            int cIdx = arr.length - 1 - cInv;
            double cx = _getColX(cIdx, maxLen);
            if ((pt.dx - cx).abs() < 30 &&
                (pt.dy - ry).abs() < 30 &&
                !RegExp(r'\d').hasMatch(arr[cInv])) {
              _hoverTarget = arr[cInv];
            }
          }
        }

        int rowIdx = 0;
        if (p['t1'] != null) {
          checkHover(
            p['t1']!,
            layout['gridY']! + (rowIdx++) * layout['rowHeight']!,
          );
        }
        if (p['t2'] != null) {
          checkHover(
            p['t2']!,
            layout['gridY']! + (rowIdx++) * layout['rowHeight']!,
          );
        }
        if (p['t3'] != null) {
          checkHover(
            p['t3']!,
            layout['gridY']! + (rowIdx++) * layout['rowHeight']!,
          );
        }
        double resY = layout['gridY']! + rowIdx * layout['rowHeight']! + 30;
        checkHover(p['res']!, resY);
      });
    }
  }

  void _handlePointerUp(PointerUpEvent e) {
    if (_draggedToken != null) {
      if (_hoverTarget != null) {
        String l = _hoverTarget!;
        int v = _draggedToken!['val'];

        bool allowDrop = true;
        if (_scenario == 1) {
          if (_step == 0 && (l != 'T' || v != 2)) allowDrop = false;
          if (_step == 1 && (l != 'T' || v != 5)) allowDrop = false;
          if (_step == 2 && (l != 'U' || v != 1)) allowDrop = false;
        } else if (_scenario == 2) {
          if (_step == 0 && (l != 'M' || v != 4)) allowDrop = false;
          if (_step == 1 && (l != 'K' || v != 7)) allowDrop = false;
          if (_step == 2 && (l != 'H' || v != 1)) allowDrop = false;
        } else if (_scenario == 3) {
          if (_step == 0 && (l != 'O' || v != 0)) allowDrop = false;
          if (_step == 1 && (l != 'S' || v != 5)) allowDrop = false;
          if (_step == 2 && (l != 'T' || v != 1)) allowDrop = false;
        }

        // Leading Zero check
        final p = _puzzles[_scenario]!;
        bool isLeading(String char) {
          return (p['t1']?[0] == char ||
              p['t2']?[0] == char ||
              p['t3']?[0] == char ||
              p['res']?[0] == char);
        }

        if (v == 0 && isLeading(l)) allowDrop = false;

        if (allowDrop) {
          AudioEngine.snap();
          setState(() {
            _letters[l] = v;
          });
          _evaluatePuzzle();
        } else {
          AudioEngine.error();
        }
      } else {
        AudioEngine.tick();
      }
      setState(() {
        _draggedToken = null;
        _hoverTarget = null;
      });
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (_draggedToken == null) {
      _baseZoom = _zoom;
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_draggedToken == null) {
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
    List<int> maxSteps = [0, 3, 3, 3, 1, 1];
    int scenarioSteps = maxSteps[_scenario];

    for (int i = 1; i <= scenarioSteps; i++) {
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

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF6366F1), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    t('theory').toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
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
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

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
                          children: _parseRichText(
                            isDone
                                ? stepsText[index]['text']!
                                : t('s${_scenario}_hud_${index + 1}'),
                          ),
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
                child: const Icon(Icons.search, size: 50, color: Colors.white),
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
    List<int> maxStepsArr = [0, 3, 3, 3, 1, 1];
    int maxSteps = maxStepsArr[_scenario];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
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
                                                      's${_scenario}_hud_${_step + 1}',
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
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
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
  final _CryptarithmsLabState state;

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

    // Grid lines
    final Paint gridLinePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    for (double i = -2000; i < 2000; i += state.U) {
      canvas.drawLine(Offset(i, -2000), Offset(i, 2000), gridLinePaint);
      canvas.drawLine(Offset(-2000, i), Offset(2000, i), gridLinePaint);
    }

    _drawPuzzleGrid(canvas);
    _drawTokenTray(canvas);
    _drawCarryBlocks(canvas);
    _drawAnimations(canvas, state._currentTime);

    List<int> maxSteps = [0, 3, 3, 3, 1, 1];
    int scenarioSteps = maxSteps[state._scenario];

    if ((state._scenario >= 4 && state._step >= 1) ||
        (state._scenario < 4 && state._step >= scenarioSteps)) {
      var layout = state._getLayout();
      double btnY = layout['trayY']! + 100;

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

      if (state._scenario < 5) {
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
    }

    if (state._draggedToken != null) {
      double px = state._draggedToken!['x'];
      double py = state._draggedToken!['y'];
      int val = state._draggedToken!['val'];

      canvas.drawShadow(
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(px - 24, py - 24, 48, 48),
            const Radius.circular(12),
          ),
        ),
        Colors.black,
        15,
        true,
      );
      _drawRoundedRect(
        canvas,
        px - 24,
        py - 24,
        48,
        48,
        12,
        Paint()..color = const Color(0xFF6366F1),
      );
      _drawText(
        canvas,
        val.toString(),
        Offset(px, py),
        Colors.white,
        24,
        TextAlign.center,
      );
    }

    canvas.restore();
  }

  void _drawPuzzleGrid(Canvas canvas) {
    var layout = state._getLayout();
    final p = state._puzzles[state._scenario]!;
    int len1 = p['t1']?.length ?? 0;
    int len2 = p['t2']?.length ?? 0;
    int len3 = p['t3']?.length ?? 0;
    int lenRes = p['res']?.length ?? 0;
    int maxLen = math.max(len1, math.max(len2, math.max(len3, lenRes)));

    List<List<String>> rows = [];
    if (p['t1'] != null) rows.add(p['t1']!);
    if (p['t2'] != null) rows.add(p['t2']!);
    if (p['t3'] != null) rows.add(p['t3']!);

    // Draw Operator
    double opX = state._getColX(maxLen, maxLen) + 20;
    double opY = layout['gridY']! + (rows.length - 1) * layout['rowHeight']!;
    _drawText(
      canvas,
      '+',
      Offset(opX, opY),
      const Color(0xFF94A3B8),
      30,
      TextAlign.center,
    );

    // Draw Highlight Errors/Success
    double resY = layout['gridY']! + rows.length * layout['rowHeight']! + 30;
    for (int i = 0; i < maxLen; i++) {
      double cx = state._getColX(i, maxLen);
      if (state._colSuccess[i] == true) {
        canvas.drawRect(
          Rect.fromLTWH(
            cx - 30,
            layout['gridY']! - 40,
            60,
            resY - layout['gridY']! + 80,
          ),
          Paint()..color = const Color(0xFF22C55E).withOpacity(0.1),
        );
      } else if (state._colErrors[i] == true) {
        canvas.drawRect(
          Rect.fromLTWH(
            cx - 30,
            layout['gridY']! - 40,
            60,
            resY - layout['gridY']! + 80,
          ),
          Paint()..color = const Color(0xFFF43F5E).withOpacity(0.1),
        );
      }
    }

    // Draw Terms
    for (int rIdx = 0; rIdx < rows.length; rIdx++) {
      List<String> rowArr = rows[rIdx];
      double ry = layout['gridY']! + rIdx * layout['rowHeight']!;
      for (int cInv = 0; cInv < rowArr.length; cInv++) {
        int cIdx = rowArr.length - 1 - cInv;
        double cx = state._getColX(cIdx, maxLen);
        _drawLetterBlock(canvas, cx, ry, rowArr[cInv], cIdx);
      }
    }

    // Draw Equals Line
    double lineY = layout['gridY']! + rows.length * layout['rowHeight']! - 20;
    double lineStartX =
        state._getColX(maxLen - 1, maxLen) - layout['colWidth']!;
    double lineEndX = state._getColX(0, maxLen) + layout['colWidth']! / 2;
    canvas.drawLine(
      Offset(lineStartX, lineY),
      Offset(lineEndX, lineY),
      Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Draw Result
    if (p['res'] != null) {
      for (int cInv = 0; cInv < p['res']!.length; cInv++) {
        int cIdx = p['res']!.length - 1 - cInv;
        double cx = state._getColX(cIdx, maxLen);
        _drawLetterBlock(canvas, cx, resY, p['res']![cInv], cIdx);
      }
    }
  }

  void _drawLetterBlock(
    Canvas canvas,
    double x,
    double y,
    String char,
    int colIndex,
  ) {
    bool isDigit = RegExp(r'\d').hasMatch(char);
    int? val = isDigit ? int.parse(char) : state._letters[char];
    bool isHovered = state._hoverTarget == char;
    bool hasError = state._colErrors[colIndex] == true;
    bool hasSuccess = state._colSuccess[colIndex] == true;

    canvas.save();
    canvas.translate(x, y);

    if (hasError) {
      canvas.translate(
        math.sin(DateTime.now().millisecondsSinceEpoch / 50) * 3,
        0,
      );
    }

    if (isDigit) {
      _drawRoundedRect(
        canvas,
        -25,
        -25,
        50,
        50,
        10,
        Paint()..color = const Color(0xFF1E293B),
      );
      _drawText(
        canvas,
        char,
        const Offset(0, 0),
        const Color(0xFF94A3B8),
        24,
        TextAlign.center,
      );
    } else {
      Color borderColor =
          hasError
              ? const Color(0xFFF43F5E)
              : (hasSuccess
                  ? const Color(0xFF10B981)
                  : (isHovered
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF334155)));
      double lineWidth = isHovered || hasError || hasSuccess ? 3 : 2;

      _drawRoundedRect(
        canvas,
        -28,
        -28,
        56,
        56,
        12,
        Paint()..color = const Color(0xFF0F172A),
      );
      _drawRoundedRect(
        canvas,
        -28,
        -28,
        56,
        56,
        12,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineWidth,
      );

      if (val != null) {
        _drawRoundedRect(
          canvas,
          -24,
          -24,
          48,
          48,
          10,
          Paint()..color = const Color(0xFF6366F1),
        );
        _drawText(
          canvas,
          val.toString(),
          const Offset(0, 0),
          Colors.white,
          24,
          TextAlign.center,
        );
        _drawText(
          canvas,
          char,
          const Offset(-15, -15),
          Colors.white.withOpacity(0.7),
          10,
          TextAlign.center,
        );
      } else {
        _drawText(
          canvas,
          char,
          const Offset(0, 0),
          const Color(0xFFCBD5E1),
          24,
          TextAlign.center,
        );
      }
    }
    canvas.restore();
  }

  void _drawTokenTray(Canvas canvas) {
    var layout = state._getLayout();
    double trayW = 520;
    double trayH = 70;
    double startX = -trayW / 2;

    _drawRoundedRect(
      canvas,
      startX,
      layout['trayY']! - trayH / 2,
      trayW,
      trayH,
      16,
      Paint()..color = const Color(0xFF1E293B),
    );

    for (int i = 0; i <= 9; i++) {
      double px = startX + 35 + i * 50;
      double py = layout['trayY']!;

      bool isUsed = state._fixedDigits.contains(i.toString());
      if (!isUsed) {
        state._letters.forEach((key, val) {
          if (val == i) isUsed = true;
        });
      }
      bool isDraggingThis =
          state._draggedToken != null && state._draggedToken!['val'] == i;

      if (isUsed || isDraggingThis) {
        _drawRoundedRect(
          canvas,
          px - 20,
          py - 20,
          40,
          40,
          10,
          Paint()..color = const Color(0xFF0F172A),
        );
      } else {
        _drawRoundedRect(
          canvas,
          px - 20,
          py - 20,
          40,
          40,
          10,
          Paint()..color = const Color(0xFF6366F1),
        );
        _drawText(
          canvas,
          i.toString(),
          Offset(px, py),
          Colors.white,
          20,
          TextAlign.center,
        );
      }
    }
  }

  void _drawCarryBlocks(Canvas canvas) {
    var layout = state._getLayout();
    final p = state._puzzles[state._scenario]!;
    int len1 = p['t1']?.length ?? 0;
    int len2 = p['t2']?.length ?? 0;
    int len3 = p['t3']?.length ?? 0;
    int lenRes = p['res']?.length ?? 0;
    int maxLen = math.max(len1, math.max(len2, math.max(len3, lenRes)));

    for (int i = 1; i < maxLen; i++) {
      if (state._carry[i] != null && state._carry[i]! > 0) {
        double cx = state._getColX(i, maxLen);
        double cy = layout['gridY']! - 50;
        canvas.drawCircle(
          Offset(cx, cy),
          14,
          Paint()..color = const Color(0xFF10B981),
        );
        _drawText(
          canvas,
          state._carry[i]!.toString(),
          Offset(cx, cy + 1),
          Colors.white,
          14,
          TextAlign.center,
        );
      }
    }
  }

  void _drawAnimations(Canvas canvas, int time) {
    for (var anim in state._animations) {
      double p = math.max(
        0.0,
        math.min(1.0, (time - anim.start) / anim.duration),
      );
      double ease = 1 - math.pow(1 - p, 3).toDouble();

      if (anim.type == 'carryFly') {
        double cy = anim.y1 + (anim.y2 - anim.y1) * ease;
        double cx = anim.x1 + (anim.x2 - anim.x1) * ease;
        double r = math.max(0.0, 14 * ease);
        canvas.drawCircle(
          Offset(cx, cy),
          r,
          Paint()..color = const Color(0xFF10B981),
        );
        _drawText(
          canvas,
          anim.val.toString(),
          Offset(cx, cy + 1),
          Colors.white.withOpacity(math.max(0.0, ease)),
          14,
          TextAlign.center,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
