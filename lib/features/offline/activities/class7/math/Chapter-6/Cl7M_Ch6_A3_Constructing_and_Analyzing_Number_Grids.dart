// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZSLNumberGridsApp());
}

class ZSLNumberGridsApp extends StatelessWidget {
  const ZSLNumberGridsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Number Grids',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          surface: Color(0xFF1E293B),
          background: Color(0xFF020617),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Roboto',
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const NumberGridsLab(),
    );
  }
}

// --- MODELS & STATE ---

class TileData {
  final String id;
  final int val;
  double homeX, homeY;
  double x, y;
  double tgtX, tgtY;
  double offX = 0, offY = 0;
  double alpha = 1.0;
  bool isCorrect = false;

  TileData(this.id, this.val, this.homeX, this.homeY)
    : x = homeX,
      y = homeY,
      tgtX = homeX,
      tgtY = homeY;
}

// --- TRANSLATIONS ---

const Map<String, Map<String, String>> translations = {
  'en': {
    'appTitle': 'Constructing and Analyzing Number Grids',
    'appSubtitle': 'Class 7 • Number Play',
    'enterLab': 'Enter Lab',
    'reset': 'Reset',
    'selectScenario': 'Select Scenario',
    'nextScenario': 'Next Challenge',
    'stepLabel': 'OBSERVATION',
    'theory': 'Observation Notes',
    'explainBtn': 'Explain Why',
    'rowSum': 'Row',
    'completed': 'Completed!',
    'min': 'Min',
    'max': 'Max',
    'sumOMeter': 'Sum-o-Meter',
    'target': 'Target',
    'current': 'Current',
    'outOfRange': 'TARGETS OUT OF RANGE!',
    'totalSum': 'Total Sum',
    'dropHere': 'DROP HERE',
    'divide3': 'Calculate Magic Sum',
    'minPossible': 'Minimum Possible',
    'maxPossible': 'Maximum Possible',
    'calcTotal': 'TOTAL SUM CALCULATOR',
    's1_title': '1. The Sum Grid Challenge',
    's1_obj':
        'To understand the relationship between numbers in a grid and their corresponding row and column sums by solving a basic sum puzzle.',
    's1_hud_1':
        "DRAG the number tile '9' and DROP it into the top-left cell of the grid.",
    's1_text_1':
        "The number 9 appears in the top-left cell. The sum in the circle for the first row and the first column should instantly update to '9'.",
    's1_hud_2':
        "DRAG the number tile '5' and DROP it into the top-middle cell.",
    's1_text_2':
        "The number 5 appears in the top-middle cell. The first-row sum circle updates to 14 (9+5). The second-column sum circle updates to 5.",
    's1_hud_3': "DRAG the number tile '1' and DROP it into the top-right cell.",
    's1_text_3':
        "The number 1 appears in the top-right cell. The first-row sum circle updates to 15 (9+5+1). The first-row sum circle now matches its target value (15). It glows bright green and makes a soft 'chime' sound to indicate success for that row.",
    's1_hud_4':
        "Continue to DRAG and DROP the remaining number tiles into the empty cells to make all the row and column sum circles turn green.",
    's1_text_4':
        "As each row or column is completed correctly, its corresponding sum circle glows green. When the final tile is placed correctly, the entire grid flashes green, and a 'Success!' message appears.",
    's1_sum':
        "This activity shows that every number you place affects two sums simultaneously: its row and its column. Solving the puzzle requires thinking about both at the same time.",
    's2_title': '2. The Impossible Grid',
    's2_obj':
        'To visually understand why some grid puzzles are impossible by exploring the minimum and maximum possible sums.',
    's2_hud_1':
        "DRAG the three smallest number tiles (1, 2, 3) and DROP them into the first row.",
    's2_text_1':
        "The tiles 1, 2, and 3 are in the first row. The row sum circle updates to 6. The Sum-o-Meter is a vertical bar graph. It has a green zone labeled 'Possible Sums (6 to 24)'. The area below 6 is red ('Too Low') and above 24 is red ('Too High'). As the user drops 1, 2, and 3, the row sum of 6 is highlighted on the meter, right at the bottom of the green zone. The target sum of '5' is shown in the red zone below.",
    's2_hud_2':
        "DRAG the three largest number tiles (7, 8, 9) and DROP them into the first column.",
    's2_text_2':
        "The tiles 7, 8, and 9 are in the first column. The column sum circle updates to 24. The column sum of 24 is highlighted on the Sum-o-Meter, at the very top of the green zone. The target sum of '26' is shown in the red zone above it. A visual barrier, like a red force field, appears over the grid, preventing further tile placement.",
    's2_hud_3': "CLICK the 'Explain Why' button on the canvas.",
    's2_text_3':
        "An explanation appears. An animation highlights the numbers 1, 2, and 3, showing 1+2+3=6. The text 'Smallest possible sum is 6' appears. Then, it highlights 7, 8, and 9, showing 7+8+9=24. The text 'Largest possible sum is 24' appears. The animation then points to the target sums of 5 and 26 with large red 'X' marks.",
    's2_sum':
        "This puzzle is impossible because the requested sums are outside the possible range.",
    's3_title': '3. Secret of the Magic Square',
    's3_obj':
        'To discover the core properties of a 3x3 magic square using numbers 1-9 in a guided, visual way.',
    's3_hud_1':
        "DRAG the 'Balance' lever to distribute the total sum of 45 equally among the three buckets.",
    's3_text_1':
        "The user drags the lever, and an animation shows the number 45 splitting into three 15s, which flow into the buckets. In a magic square, every row, column, and diagonal must have the same sum. This is the Magic Sum. For numbers 1-9, the Magic Sum is 15.",
    's3_hud_2':
        "DRAG the '5' tile and DROP it into the center cell of the grid.",
    's3_text_2':
        "The 5 tile is placed in the center. The grid appears with the Magic Sum of 15 displayed for all rows, columns, and diagonals. When 5 is placed in the center, all lines passing through it (middle row, middle column, two diagonals) light up.",
    's3_hud_3':
        "Notice the pairs of numbers that add up to 10 on the side (1&9, 2&8, 3&7, 4&6). DRAG the '1' and '9' tiles and DROP them on opposite sides of the center '5' to complete a line.",
    's3_text_3':
        "The user places 1 and 9, for example, in the middle row, creating the line 1-5-9. The sum is 15. When the user places 1, 5, and 9 in a line, that line (e.g., the main diagonal) flashes green. The calculation 1 + 5 + 9 = 15 appears briefly.",
    's3_hud_4':
        "Continue placing the other pairs (2&8, 3&7, 4&6) on opposite sides of the center '5' until the magic square is complete.",
    's3_text_4':
        "The user completes the magic square. As each correct line of three is formed, it flashes green. Once the entire square is correctly filled, the whole grid glows, and an animation highlights each row, column, and diagonal, showing the sum '15' for each.",
    's3_sum':
        "This visually proves why 5 must be in the center—it's the pivot for all the pairs that sum to 10.",
    's4_title': '4. Next Level Magic Square',
    's4_obj':
        'To apply the learned principles to construct a new magic square using a different set of consecutive numbers (2-10).',
    's4_hud_1':
        "A new challenge! Your number tiles are now 2 through 10. First, figure out the new Magic Sum. DRAG all the number tiles into the 'Total Sum Calculator' machine.",
    's4_text_1':
        "The user drags all nine tiles (2-10) into the machine. The machine calculates the total sum as 54. A fun, animated machine with a hopper on top. As tiles are dropped in, gears turn and lights flash. A display on the machine shows the running total, ending at 54.",
    's4_hud_2':
        "The total sum is 54. CLICK the 'Calculate Magic Sum' button to divide this total by 3 (for the 3 rows).",
    's4_text_2':
        "The user clicks the button, and an animation shows 54 being divided by 3, resulting in 18. The number 54 travels down a pipe, passes through a '÷3' gate, and the number 18 comes out the other side. The target sum circles on the grid all update to 18.",
    's4_hud_3':
        "The new Magic Sum is 18. The number tiles have been returned to your tray. Construct the magic square by DRAGGING and DROPPING the tiles into the grid.",
    's4_text_3':
        "The user correctly constructs the magic square for numbers 2-10 (e.g., 9,2,7 / 4,6,8 / 5,10,3). This is an open challenge. The system provides feedback only by making the sum circles for rows, columns, and diagonals glow green when their sum correctly equals 18. There are no other hints. Success is achieved when the entire grid is filled and all sums are correct.",
    's4_sum':
        "Success is achieved when the entire grid is filled and all sums are correct.",
    's5_title': '5. The Algebraic Magic Square',
    's5_obj':
        'To build a magic square using a generalized algebraic formula, demonstrating a deeper understanding of its structure.',
    's5_hud_1':
        "Let's build a magic square where the center number, 'm', is 25. The grid shows the algebraic formula for a magic square. Your number tray contains the calculated values. DRAG the correct number tile and DROP it onto the cell labeled 'm'.",
    's5_text_1':
        "The user drags the number 25 and drops it on the center cell labeled 'm'. The 3x3 grid cells are labeled with algebraic expressions: m+3, m-4, m+1 in the first row, etc. The number tray contains tiles like 21, 22, 23, ..., 29. When the user drops 25 on 'm', the cell now shows the number 25.",
    's5_hud_2':
        "Now, fill in the rest of the grid. For the cell labeled 'm-4', calculate the value (25 - 4 = 21) and DRAG the corresponding number tile to that cell.",
    's5_text_2':
        "The user drags the number 21 and drops it on the cell labeled 'm-4'. When the user hovers a number tile over a cell, a tooltip shows the calculation, e.g., hovering '21' over 'm-4' shows '25 - 4 = 21'. This provides subtle support without giving the answer away.",
    's5_hud_3':
        "Complete the entire grid by placing the correct numerical value in each cell based on the algebraic formula and the central value m=25.",
    's5_text_3':
        "The user correctly fills the entire grid. As each number is placed correctly, the algebraic label (e.g., 'm-4') fades out, leaving just the number (e.g., '21').",
    's5_sum':
        "Once the grid is complete, the row, column, and diagonal sums automatically calculate and appear in glowing circles, all showing the magic sum of 75 (3 x m = 3 x 25). This provides immediate verification of their work and reinforces the generalized concept.",
  },
  'hi': {
    'appTitle': 'नंबर ग्रिड का निर्माण और विश्लेषण',
    'appSubtitle': 'कक्षा 7 • Number Play',
    'enterLab': 'लैब में प्रवेश करें',
    'reset': 'रीसेट',
    'selectScenario': 'मिशन चुनें',
    'nextScenario': 'अगली चुनौती',
    'stepLabel': 'अवलोकन',
    'theory': 'अवलोकन नोट्स',
    'explainBtn': 'कारण स्पष्ट करें',
    'rowSum': 'पंक्ति',
    'completed': 'पूरा हुआ!',
    'min': 'न्यूनतम',
    'max': 'अधिकतम',
    'sumOMeter': 'सम-ओ-मीटर',
    'target': 'लक्ष्य',
    'current': 'वर्तमान',
    'outOfRange': 'लक्ष्य सीमा से बाहर!',
    'totalSum': 'कुल योग',
    'dropHere': 'यहाँ छोड़ें',
    'divide3': 'जादुई योग की गणना करें',
    'minPossible': 'न्यूनतम संभव',
    'maxPossible': 'अधिकतम संभव',
    'calcTotal': 'कुल योग कैलकुलेटर',
    's1_title': '1. सम ग्रिड चुनौती',
    's1_obj':
        'बुनियादी योग पहेली को हल करके ग्रिड में संख्याओं और उनके संबंधित पंक्ति और स्तंभ के योग के बीच के संबंध को समझना।',
    's1_hud_1':
        "संख्या टाइल '9' को खींचें (DRAG) और इसे ग्रिड के ऊपरी-बाएं सेल में छोड़ें (DROP)।",
    's1_text_1':
        "संख्या 9 ऊपरी-बाएं सेल में दिखाई देती है। पहली पंक्ति और पहले स्तंभ के लिए योग वाले सर्कल तुरंत '9' में अपडेट हो जाने चाहिए।",
    's1_hud_2': "संख्या टाइल '5' को खींचें और इसे ऊपर-मध्य सेल में छोड़ें।",
    's1_text_2':
        "संख्या 5 ऊपर-मध्य सेल में दिखाई देती है। पहली पंक्ति का योग सर्कल 14 (9+5) पर अपडेट हो जाता है। दूसरे स्तंभ का योग सर्कल 5 पर अपडेट हो जाता है।",
    's1_hud_3': "संख्या टाइल '1' को खींचें और इसे ऊपरी-दाएं सेल में छोड़ें।",
    's1_text_3':
        "संख्या 1 ऊपरी-दाएं सेल में दिखाई देती है। पहली पंक्ति का योग सर्कल 15 (9+5+1) पर अपडेट हो जाता है। पहली पंक्ति का योग सर्कल अब अपने लक्ष्य मान (15) से मेल खाता है। उस पंक्ति के लिए सफलता का संकेत देने के लिए इसे चमकीले हरे रंग में चमकना चाहिए।",
    's1_hud_4':
        "पंक्ति और स्तंभ के सभी योग सर्कलों को हरा बनाने के लिए शेष संख्या टाइलों को खींचना और खाली सेल में छोड़ना जारी रखें।",
    's1_text_4':
        "जैसे ही प्रत्येक पंक्ति या स्तंभ सही ढंग से पूरा होता है, उसका संबंधित योग सर्कल हरा हो जाता है। जब अंतिम टाइल सही ढंग से रखी जाती है, तो पूरा ग्रिड हरे रंग में चमकता है, और सफलता संदेश दिखाई देता है।",
    's1_sum':
        "यह गतिविधि दिखाती है कि आपके द्वारा रखी गई प्रत्येक संख्या एक साथ दो योगों को प्रभावित करती है: इसकी पंक्ति और इसका स्तंभ। पहेली को हल करने के लिए एक ही समय में दोनों के बारे में सोचना आवश्यक है।",
    's2_title': '2. असंभव ग्रिड',
    's2_obj':
        'न्यूनतम और अधिकतम संभव योगों की खोज करके दृश्य रूप से समझें कि कुछ ग्रिड पहेलियाँ असंभव क्यों हैं।',
    's2_hud_1':
        "तीन सबसे छोटी संख्या टाइलों (1, 2, 3) को खींचें और उन्हें पहली पंक्ति में छोड़ें।",
    's2_text_1':
        "टाइलें 1, 2 और 3 पहली पंक्ति में हैं। पंक्ति का योग 6 हो जाता है। सम-ओ-मीटर एक ऊर्ध्वाधर बार ग्राफ है। 6 का योग मीटर पर हरे क्षेत्र के ठीक नीचे हाइलाइट किया गया है।",
    's2_hud_2':
        "तीन सबसे बड़ी संख्या टाइलों (7, 8, 9) को खींचें और उन्हें पहले स्तंभ में छोड़ें।",
    's2_text_2':
        "टाइलें 7, 8 और 9 पहले स्तंभ में हैं। स्तंभ का योग 24 हो जाता है। 24 का स्तंभ योग सम-ओ-मीटर पर हरे क्षेत्र के बिल्कुल शीर्ष पर हाइलाइट किया गया है। ग्रिड पर एक लाल बल क्षेत्र (force field) दिखाई देता है जो आगे टाइल रखने से रोकता है।",
    's2_hud_3': "कैनवास पर 'कारण स्पष्ट करें' बटन पर क्लिक करें।",
    's2_text_3':
        "एक स्पष्टीकरण प्रकट होता है। एक एनीमेशन संख्याओं 1, 2, और 3 को हाइलाइट करता है। फिर, यह 7, 8, और 9 को हाइलाइट करता है।",
    's2_sum': "यह पहेली असंभव है क्योंकि अनुरोधित योग संभव सीमा से बाहर हैं।",
    's3_title': '3. जादुई वर्ग का रहस्य',
    's3_obj':
        'एक निर्देशित, दृश्य तरीके से 1-9 संख्याओं का उपयोग करके 3x3 जादुई वर्ग के मूल गुणों की खोज करें।',
    's3_hud_1':
        "45 के कुल योग को तीनों बाल्टियों के बीच समान रूप से वितरित करने के लिए 'Balance' लीवर को खींचें।",
    's3_text_1':
        "उपयोगकर्ता लीवर खींचता है, और एक एनीमेशन 45 की संख्या को तीन 15s में विभाजित करते हुए दिखाता है, जो बाल्टियों में बहते हैं।",
    's3_hud_2':
        "संख्या 5 विशेष है। '5' टाइल को खींचें और इसे ग्रिड के केंद्र सेल में छोड़ें।",
    's3_text_2':
        "5 टाइल को केंद्र में रखा गया है। ग्रिड सभी पंक्तियों, स्तंभों और विकर्णों के लिए प्रदर्शित 15 के जादुई योग के साथ दिखाई देता है।",
    's3_hud_3':
        "उन संख्याओं के जोड़े पर ध्यान दें जो साइड में 10 तक जुड़ते हैं। एक पंक्ति को पूरा करने के लिए '1' और '9' टाइलों को खींचें और उन्हें केंद्र '5' के विपरीत किनारों पर छोड़ें।",
    's3_text_3':
        "उपयोगकर्ता 1 और 9 को रखता है, उदाहरण के लिए, मध्य पंक्ति में, पंक्ति 1-5-9 बनाता है। योग 15 है।",
    's3_hud_4':
        "जादुई वर्ग पूरा होने तक अन्य जोड़े (2&8, 3&7, 4&6) को केंद्र '5' के विपरीत किनारों पर रखना जारी रखें।",
    's3_text_4':
        "उपयोगकर्ता जादुई वर्ग को पूरा करता है। एक बार पूरा वर्ग सही ढंग से भर जाने के बाद, पूरा ग्रिड चमकता है।",
    's3_sum':
        "यह दृश्य रूप से साबित करता है कि 5 केंद्र में क्यों होना चाहिए—यह उन सभी जोड़ियों के लिए धुरी है जिनका योग 10 है।",
    's4_title': '4. अगला स्तर जादुई वर्ग',
    's4_obj':
        'लगातार संख्याओं (2-10) के एक अलग सेट का उपयोग करके एक नए जादुई वर्ग का निर्माण करने के लिए सीखे गए सिद्धांतों को लागू करें।',
    's4_hud_1':
        "एक नई चुनौती! आपकी संख्या टाइलें अब 2 से 10 तक हैं। सभी संख्या टाइलों को 'कुल योग कैलकुलेटर' मशीन में खींचें।",
    's4_text_1':
        "उपयोगकर्ता सभी नौ टाइलों (2-10) को मशीन में खींचता है। मशीन कुल योग की गणना 54 के रूप में करती है।",
    's4_hud_2':
        "कुल योग 54 है। इस कुल को 3 से विभाजित करने के लिए 'जादुई योग की गणना करें' बटन पर क्लिक करें।",
    's4_text_2':
        "उपयोगकर्ता बटन पर क्लिक करता है, और एक एनीमेशन 54 को 3 से विभाजित करते हुए 18 दिखाता है।",
    's4_hud_3':
        "नया जादुई योग 18 है। टाइलों को ग्रिड में खींचकर और छोड़कर जादुई वर्ग का निर्माण करें।",
    's4_text_3':
        "उपयोगकर्ता 2-10 संख्याओं के लिए जादुई वर्ग का सही ढंग से निर्माण करता है।",
    's4_sum':
        "सफलता तब प्राप्त होती है जब पूरा ग्रिड भर जाता है और सभी योग सही होते हैं।",
    's5_title': '5. बीजीय जादुई वर्ग',
    's5_obj':
        'इसकी संरचना की गहरी समझ का प्रदर्शन करते हुए, एक सामान्यीकृत बीजीय सूत्र का उपयोग करके एक जादुई वर्ग बनाएं।',
    's5_hud_1':
        "आइए एक जादुई वर्ग बनाएं जहां केंद्र संख्या, 'm', 25 है। सही संख्या टाइल खींचें और इसे 'm' लेबल वाले सेल पर छोड़ दें।",
    's5_text_1':
        "उपयोगकर्ता संख्या 25 को खींचता है और इसे 'm' लेबल वाले केंद्र सेल पर छोड़ देता है।",
    's5_hud_2':
        "अब, ग्रिड के बाकी हिस्से को भरें। 'm-4' लेबल वाले सेल के लिए, मान (25 - 4 = 21) की गणना करें और संबंधित संख्या टाइल को उस सेल में खींचें।",
    's5_text_2':
        "उपयोगकर्ता संख्या 21 को खींचता है और इसे 'm-4' लेबल वाले सेल पर छोड़ देता है।",
    's5_hud_3':
        "बीजीय सूत्र और केंद्रीय मान m=25 के आधार पर प्रत्येक सेल में सही संख्यात्मक मान रखकर पूरे ग्रिड को पूरा करें।",
    's5_text_3':
        "उपयोगकर्ता पूरे ग्रिड को सही ढंग से भरता है। जैसे ही प्रत्येक संख्या को सही ढंग से रखा जाता है, बीजीय लेबल फीका हो जाता है।",
    's5_sum':
        "एक बार ग्रिड पूरा हो जाने पर, पंक्ति, स्तंभ और विकर्ण योग स्वचालित रूप से गणना करते हैं और चमकते हलकों में दिखाई देते हैं, सभी 75 का जादुई योग दिखाते हैं।",
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
  static final AudioPlayer _chimePlayer =
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
  static const String _chimeUrl =
      'audio/class7/mixkit_2869.mp3';
  static const String _shutterUrl =
      'audio/class7/mixkit_2574.mp3';
  static const String _snapUrl =
      'audio/class7/mixkit_1114.mp3';

  static Future<void> init() async {
    _clickPlayer.setSourceAsset(_clickUrl).catchError((e) {});
    _successPlayer.setSourceAsset(_successUrl).catchError((e) {});
    _errorPlayer.setSourceAsset(_errorUrl).catchError((e) {});
    _chimePlayer.setSourceAsset(_chimeUrl).catchError((e) {});
    _shutterPlayer.setSourceAsset(_shutterUrl).catchError((e) {});
    _snapPlayer.setSourceAsset(_snapUrl).catchError((e) {});
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

  static void chime() {
    _chimePlayer.stop().then((_) => _chimePlayer.resume()).catchError((e) {});
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
}

// --- MAIN SCREEN ---

class NumberGridsLab extends StatefulWidget {
  const NumberGridsLab({super.key});

  @override
  State<NumberGridsLab> createState() => _NumberGridsLabState();
}

class _NumberGridsLabState extends State<NumberGridsLab>
    with SingleTickerProviderStateMixin {
  bool _isCurtainOpen = false;
  bool _isSidebarOpen = true;
  String _lang = 'en';
  final double _sidebarWidthPct = 0.38;

  // Auto-scroll controller for the Sidebar
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _stepKeys = List.generate(5, (_) => GlobalKey());

  // Canvas View State
  double _panX = 0;
  double _panY = -30;
  double _zoom = 1.0;

  // Custom gesture tracking
  double _baseZoom = 1.0;

  // Game State
  int _scenario = 1;
  int _step = 0;
  List<TileData?> _grid = List.filled(9, null);
  final List<TileData> _tiles = [];
  final Set<int> _completedScenarios = {};
  TileData? _draggedTile;
  int _hoverCellIndex = -1;

  final Map<String, List<int>> _s1Targets = {
    'r': [15, 17, 13],
    'c': [21, 10, 14],
  };
  Map<String, List<bool>> _s1Reached = {
    'r': [false, false, false],
    'c': [false, false, false],
  };
  final Map<String, List<int>> _s2Targets = {
    'r': [5, 21, 19],
    'c': [26, 11, 9],
  };
  bool _s2Explained = false;
  bool _s2Animating = false;
  int _s2AnimStartTime = 0;

  bool _s3LeverPulled = false;
  double _s3LeverY = 0;
  bool _s3Animating = false;
  int _s3AnimStartTime = 0;

  int _s4CalcTotal = 0;
  bool _s4MagicSumCalculated = false;
  bool _s4Animating = false;
  int _s4AnimStartTime = 0;

  final List<String> _s5Formulas = [
    'm+3',
    'm-4',
    'm+1',
    'm-2',
    'm',
    'm+2',
    'm-1',
    'm+4',
    'm-3',
  ];

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
      bool needsUpdate = false;

      for (var tile in _tiles) {
        if ((tile.x - tile.tgtX).abs() > 0.5 ||
            (tile.y - tile.tgtY).abs() > 0.5) {
          tile.x += (tile.tgtX - tile.x) * 0.3;
          tile.y += (tile.tgtY - tile.y) * 0.3;
          needsUpdate = true;
        }
      }

      if (_s2Animating || _s3Animating || _s4Animating || needsUpdate) {
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
      _s2Animating = false;
      _lang = 'en'; // Reset language to English
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;
      _grid = List.filled(9, null);
      _tiles.clear();

      double cellSize = 65;
      double gap = 8;
      double w = cellSize * 3 + gap * 2;
      double startX = -w / 2 + cellSize / 2;
      double trayY = 200;

      if (_scenario == 1) {
        for (int i = 0; i < 9; i++) {
          _tiles.add(
            TileData(
              't${i + 1}',
              i + 1,
              startX + (i % 5) * 65 - 20,
              trayY + (i ~/ 5) * 65,
            ),
          );
        }
        _s1Reached = {
          'r': [false, false, false],
          'c': [false, false, false],
        };
      } else if (_scenario == 2) {
        List<int> vals = [1, 2, 3, 7, 8, 9];
        for (int i = 0; i < vals.length; i++) {
          _tiles.add(
            TileData(
              't${vals[i]}',
              vals[i],
              startX + (i % 3) * 80,
              trayY + (i ~/ 3) * 70,
            ),
          );
        }
        _s2Explained = false;
        _s2Animating = false;
      } else if (_scenario == 3) {
        double pX = 230, pY = -120;
        List<Offset> posArr = [
          Offset(-pX, pY),
          Offset(-pX, pY + 70),
          Offset(pX, pY),
          Offset(pX, pY + 70),
          Offset(0, trayY),
          Offset(pX + 60, pY + 70),
          Offset(pX + 60, pY),
          Offset(-pX + 60, pY + 70),
          Offset(-pX + 60, pY),
        ];
        for (int i = 0; i < 9; i++) {
          var t = TileData('t${i + 1}', i + 1, posArr[i].dx, posArr[i].dy);
          t.alpha = 0;
          _tiles.add(t);
        }
        _s3LeverPulled = false;
        _s3LeverY = 0;
        _s3Animating = false;
      } else if (_scenario == 4) {
        for (int i = 0; i < 9; i++) {
          _tiles.add(
            TileData(
              't${i + 2}',
              i + 2,
              startX + (i % 5) * 65 - 20,
              trayY + (i ~/ 5) * 65,
            ),
          );
        }
        _s4CalcTotal = 0;
        _s4MagicSumCalculated = false;
        _s4Animating = false;
      } else if (_scenario == 5) {
        List<int> vals = [21, 22, 23, 24, 25, 26, 27, 28, 29];
        for (int i = 0; i < vals.length; i++) {
          _tiles.add(
            TileData(
              't${vals[i]}',
              vals[i],
              startX + (i % 5) * 65 - 20,
              trayY + (i ~/ 5) * 65,
            ),
          );
        }
      }

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

  void _checkStepCompletion() {
    if (_scenario == 1) {
      if (_step == 0 && _grid[0]?.val == 9) _markStepComplete();
      if (_step == 1 && _grid[1]?.val == 5) _markStepComplete();
      if (_step == 2 && _grid[2]?.val == 1) _markStepComplete();
      if (_step == 3) {
        var s = _getRowColSums();
        bool win = true;
        int filledCells = _grid.where((c) => c != null).length;
        for (int i = 0; i < 3; i++) {
          if (s['r']![i] != _s1Targets['r']![i]) win = false;
          if (s['c']![i] != _s1Targets['c']![i]) win = false;
        }
        if (win && filledCells == 9) {
          for (var t in _tiles) {
            t.isCorrect = true;
          }
          _markStepComplete();
        }
      }
    } else if (_scenario == 2) {
      if (_step == 0) {
        var r0 =
            [_grid[0], _grid[1], _grid[2]].where((t) => t != null).toList();
        if (r0.length == 3 && r0.every((t) => [1, 2, 3].contains(t!.val))) {
          _markStepComplete();
        }
      } else if (_step == 1) {
        var c0 =
            [_grid[0], _grid[3], _grid[6]].where((t) => t != null).toList();
        if (c0.length == 3 && c0.every((t) => [7, 8, 9].contains(t!.val))) {
          _markStepComplete();
        }
      }
    } else if (_scenario == 3) {
      if (_step == 1 && _grid[4]?.val == 5) {
        _grid[4]!.isCorrect = true;
        _markStepComplete();
      }
      if (_step == 2) {
        if ((_grid[0]?.val == 1 && _grid[8]?.val == 9) ||
            (_grid[0]?.val == 9 && _grid[8]?.val == 1) ||
            (_grid[1]?.val == 1 && _grid[7]?.val == 9) ||
            (_grid[1]?.val == 9 && _grid[7]?.val == 1) ||
            (_grid[2]?.val == 1 && _grid[6]?.val == 9) ||
            (_grid[2]?.val == 9 && _grid[6]?.val == 1) ||
            (_grid[3]?.val == 1 && _grid[5]?.val == 9) ||
            (_grid[3]?.val == 9 && _grid[5]?.val == 1)) {
          _markStepComplete();
        }
      }
      if (_step == 3) {
        var s = _getRowColSums();
        int filledCells = _grid.where((c) => c != null).length;
        if (s['r']!.every((x) => x == 15) &&
            s['c']!.every((x) => x == 15) &&
            s['d1']![0] == 15 &&
            s['d2']![0] == 15 &&
            filledCells == 9) {
          for (var t in _tiles) {
            t.isCorrect = true;
          }
          _markStepComplete();
        }
      }
    } else if (_scenario == 4) {
      if (_step == 0 && _s4CalcTotal == 54) _markStepComplete();
      if (_step == 2) {
        var s = _getRowColSums();
        int filledCells = _grid.where((c) => c != null).length;
        if (s['r']!.every((x) => x == 18) &&
            s['c']!.every((x) => x == 18) &&
            s['d1']![0] == 18 &&
            s['d2']![0] == 18 &&
            filledCells == 9) {
          for (var t in _tiles) {
            t.isCorrect = true;
          }
          _markStepComplete();
        }
      }
    } else if (_scenario == 5) {
      if (_step == 0 && _grid[4]?.val == 25) {
        _grid[4]!.isCorrect = true;
        _markStepComplete();
      }
      if (_step == 1 && _grid[1]?.val == 21) {
        _grid[1]!.isCorrect = true;
        _markStepComplete();
      }
      if (_step == 2) {
        var s = _getRowColSums();
        int filledCells = _grid.where((c) => c != null).length;
        if (s['r']!.every((x) => x == 75) &&
            s['c']!.every((x) => x == 75) &&
            s['d1']![0] == 75 &&
            s['d2']![0] == 75 &&
            filledCells == 9) {
          for (var t in _tiles) {
            t.isCorrect = true;
          }
          _markStepComplete();
        }
      }
    }
  }

  void _markStepComplete() {
    setState(() {
      _step++;
      int maxSteps = _scenario == 2 || _scenario == 4 || _scenario == 5 ? 3 : 4;
      if (_step >= maxSteps) {
        AudioEngine.success();
        _completedScenarios.add(_scenario);
        if (_completedScenarios.length == 5) {
          _showFinalSuccessDialog();
        }
      } else {
        AudioEngine.snap();
      }
    });
    _scrollToActiveStep();
  }

  void _showFinalSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 36),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    AudioEngine.click();
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Congratulations!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "You have successfully completed all challenges in the Number Grids Lab.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    AudioEngine.click();
                    Navigator.of(ctx).pop();
                    _resetLab();
                  },
                  child: const Text("Play Again"),
                ),
              ],
            ),
          ),
    );
  }

  Map<String, List<int>> _getRowColSums() {
    List<int> r = [0, 0, 0], c = [0, 0, 0], rC = [0, 0, 0], cC = [0, 0, 0];
    int d1 = 0, d2 = 0, d1C = 0, d2C = 0;
    for (int i = 0; i < 9; i++) {
      if (_grid[i] != null) {
        int v = _grid[i]!.val;
        int row = i ~/ 3, col = i % 3;
        r[row] += v;
        rC[row]++;
        c[col] += v;
        cC[col]++;
        if (row == col) {
          d1 += v;
          d1C++;
        }
        if (row + col == 2) {
          d2 += v;
          d2C++;
        }
      }
    }
    return {
      'r': r,
      'c': c,
      'rC': rC,
      'cC': cC,
      'd1': [d1],
      'd2': [d2],
      'd1C': [d1C],
      'd2C': [d2C],
    };
  }

  // --- Input Handling ---

  void _handlePointerDown(PointerDownEvent e, Size canvasSize) {
    Offset pt = _screenToWorld(e.localPosition, canvasSize);

    // Scenario 3 Lever
    if (_scenario == 3 && _step == 0 && !_s3LeverPulled && !_s3Animating) {
      if (pt.dx > 210 && pt.dx < 260 && pt.dy > -280 && pt.dy < -180) {
        setState(() {
          _s3LeverY = 40;
          _s3Animating = true;
          _s3AnimStartTime = DateTime.now().millisecondsSinceEpoch;
        });
        AudioEngine.chime();
        return;
      }
    }

    // Scenario 4 Button
    if (_scenario == 4 &&
        _step == 1 &&
        _s4CalcTotal == 54 &&
        !_s4MagicSumCalculated &&
        !_s4Animating) {
      if (pt.dx > -100 && pt.dx < 100 && pt.dy > -215 && pt.dy < -165) {
        setState(() {
          _s4Animating = true;
          _s4AnimStartTime = DateTime.now().millisecondsSinceEpoch;
        });
        AudioEngine.chime();
        return;
      }
    }

    // Check Tile Drag
    for (int i = _tiles.length - 1; i >= 0; i--) {
      var t = _tiles[i];
      if (t.alpha > 0 &&
          (pt.dx - t.x).abs() < 32.5 &&
          (pt.dy - t.y).abs() < 32.5) {
        bool isTileOnGrid = _grid.any((g) => g?.id == t.id);
        if (!isTileOnGrid) {
          if (_scenario == 1 && _step < 3) {
            if (_step == 0 && t.val != 9) {
              AudioEngine.error();
              return;
            }
            if (_step == 1 && t.val != 5) {
              AudioEngine.error();
              return;
            }
            if (_step == 2 && t.val != 1) {
              AudioEngine.error();
              return;
            }
          }
          if (_scenario == 3) {
            if (_step == 1 && t.val != 5) {
              AudioEngine.error();
              return;
            }
            if (_step == 2 && ![1, 9].contains(t.val)) {
              AudioEngine.error();
              return;
            }
          }
          if (_scenario == 5) {
            if (_step == 0 && t.val != 25) {
              AudioEngine.error();
              return;
            }
            if (_step == 1 && t.val != 21) {
              AudioEngine.error();
              return;
            }
          }
        }

        setState(() {
          _draggedTile = t;
          t.offX = t.x - pt.dx;
          t.offY = t.y - pt.dy;
          int idx = _grid.indexWhere((g) => g?.id == t.id);
          if (idx != -1) _grid[idx] = null;
          _tiles.removeAt(i);
          _tiles.add(t); // Bring to front
        });
        AudioEngine.click();
        return;
      }
    }
  }

  void _handlePointerMove(PointerMoveEvent e, Size canvasSize) {
    if (_draggedTile != null) {
      Offset pt = _screenToWorld(e.localPosition, canvasSize);
      setState(() {
        _draggedTile!.tgtX = pt.dx + _draggedTile!.offX;
        _draggedTile!.tgtY = pt.dy + _draggedTile!.offY;
        _draggedTile!.x = _draggedTile!.tgtX; // Immediate follow
        _draggedTile!.y = _draggedTile!.tgtY;
        _hoverCellIndex = -1;

        if (_scenario == 4 && _step == 0) {
          if (pt.dx > -100 && pt.dx < 100 && pt.dy > -440 && pt.dy < -380) {
            _hoverCellIndex = 99;
            return;
          }
        }

        for (int i = 0; i < 9; i++) {
          Rect rect = _getCellRect(i);
          if ((pt.dx - rect.center.dx).abs() < rect.width / 2 &&
              (pt.dy - rect.center.dy).abs() < rect.height / 2) {
            if (_scenario == 1 && _step < 3) {
              if (_step == 0 && i != 0) continue;
              if (_step == 1 && i != 1) continue;
              if (_step == 2 && i != 2) continue;
            }
            if (_scenario == 3 && _step < 2) {
              if (_step == 1 && i != 4) continue;
            }
            if (_scenario == 5 && _step < 2) {
              if (_step == 0 && i != 4) continue;
              if (_step == 1 && i != 1) continue;
            }
            _hoverCellIndex = i;
            break;
          }
        }
      });
    }
  }

  void _handlePointerUp(PointerUpEvent e) {
    if (_draggedTile != null) {
      var t = _draggedTile!;
      setState(() {
        if (_hoverCellIndex == 99) {
          t.tgtX = 0;
          t.tgtY = -410;
          t.alpha = 0;
          _s4CalcTotal += t.val;
          AudioEngine.snap();
          if (_s4CalcTotal == 54) _checkStepCompletion();
        } else if (_hoverCellIndex != -1) {
          Rect rect = _getCellRect(_hoverCellIndex);
          t.tgtX = rect.center.dx;
          t.tgtY = rect.center.dy;

          if (_grid[_hoverCellIndex] != null) {
            var oldT = _grid[_hoverCellIndex]!;
            oldT.tgtX = oldT.homeX;
            oldT.tgtY = oldT.homeY;
          }
          _grid[_hoverCellIndex] = t;
          AudioEngine.snap();

          if (_scenario == 1) {
            var sums = _getRowColSums();
            bool shouldChime = false;
            for (int i = 0; i < 3; i++) {
              if (sums['r']![i] == _s1Targets['r']![i] &&
                  !_s1Reached['r']![i]) {
                shouldChime = true;
                _s1Reached['r']![i] = true;
              }
              if (sums['c']![i] == _s1Targets['c']![i] &&
                  !_s1Reached['c']![i]) {
                shouldChime = true;
                _s1Reached['c']![i] = true;
              }
            }
            if (shouldChime) AudioEngine.chime();
          }
          _checkStepCompletion();
        } else {
          t.tgtX = t.homeX;
          t.tgtY = t.homeY;
          AudioEngine.click();
        }
        _draggedTile = null;
        _hoverCellIndex = -1;
      });
    }
  }

  // --- Canvas Gestures (Pan & Zoom) ---
  void _handleScaleStart(ScaleStartDetails details) {
    if (_draggedTile == null) {
      _baseZoom = _zoom;
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_draggedTile == null) {
      setState(() {
        _zoom = (_baseZoom * details.scale).clamp(0.1, 3.0);
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
      });
      _repaintNotifier.value++;
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    // Gestures clean up automatically as states are preserved and not flagged otherwise.
  }

  Offset _screenToWorld(Offset screen, Size size) {
    return Offset(
      (screen.dx - size.width / 2 - _panX) / _zoom,
      (screen.dy - size.height / 2 - _panY) / _zoom,
    );
  }

  Rect _getCellRect(int index) {
    int col = index % 3;
    int row = index ~/ 3;
    double cellSize = 65;
    double gap = 8;
    double w = cellSize * 3 + gap * 2;
    double startX = -w / 2;
    return Rect.fromLTWH(
      startX + col * (cellSize + gap),
      -40 + (row - 1) * (cellSize + gap) - cellSize / 2,
      cellSize,
      cellSize,
    );
  }

  Widget _buildSidebarContent(BuildContext context) {
    List<Map<String, String>> steps = [];
    if (_scenario == 1) {
      steps = [
        {'text': t('s1_text_1')},
        {'text': t('s1_text_2')},
        {'text': t('s1_text_3')},
        {'text': t('s1_text_4')},
      ];
    } else if (_scenario == 2) {
      steps = [
        {'text': t('s2_text_1')},
        {'text': t('s2_text_2')},
        {'text': t('s2_text_3')},
      ];
    } else if (_scenario == 3) {
      steps = [
        {'text': t('s3_text_1')},
        {'text': t('s3_text_2')},
        {'text': t('s3_text_3')},
        {'text': t('s3_text_4')},
      ];
    } else if (_scenario == 4) {
      steps = [
        {'text': t('s4_text_1')},
        {'text': t('s4_text_2')},
        {'text': t('s4_text_3')},
      ];
    } else if (_scenario == 5) {
      steps = [
        {'text': t('s5_text_1')},
        {'text': t('s5_text_2')},
        {'text': t('s5_text_3')},
      ];
    }

    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        // Sidebar Content Pushed down explicitly to avoid the absolute toggle icon
        const SizedBox(height: 50),

        // Header (Title & Subtitle)
        Text(
          t('appTitle'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          t('appSubtitle'),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Lang Toggle & Reset
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

        // Select Scenario
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

        // Objective
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag, color: Color(0xFF3B82F6), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    t('theory'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B82F6),
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

        // Steps
        ...List.generate(steps.length, (index) {
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
                      ? const Color(0xFF3B82F6).withOpacity(0.15)
                      : Colors.transparent,
              border: Border.all(
                color:
                    isActive
                        ? const Color(0xFF3B82F6)
                        : Colors.white.withOpacity(0.1),
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.2),
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
                                ? const Color(0xFF3B82F6)
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
                      Text(
                        steps[index]['text']!,
                        style: TextStyle(
                          fontSize: 14,
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

        // Summary
        if (_step >= steps.length)
          Container(
            key: _stepKeys[math.min(steps.length, _stepKeys.length - 1)],
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
        const SizedBox(height: 32), // Bottom padding
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
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.6),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.grid_4x4,
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
                  backgroundColor: Colors.blue,
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
    double sidebarWidth = (screenWidth * _sidebarWidthPct).clamp(300.0, 450.0);

    // Identify current HUD text based on exact active sidebar step.
    List<Map<String, String>> stepsText = [];
    if (_scenario == 1) {
      stepsText = [
        {'text': t('s1_text_1'), 'hud': t('s1_hud_1')},
        {'text': t('s1_text_2'), 'hud': t('s1_hud_2')},
        {'text': t('s1_text_3'), 'hud': t('s1_hud_3')},
        {'text': t('s1_text_4'), 'hud': t('s1_hud_4')},
      ];
    } else if (_scenario == 2) {
      stepsText = [
        {'text': t('s2_text_1'), 'hud': t('s2_hud_1')},
        {'text': t('s2_text_2'), 'hud': t('s2_hud_2')},
        {'text': t('s2_text_3'), 'hud': t('s2_hud_3')},
      ];
    } else if (_scenario == 3) {
      stepsText = [
        {'text': t('s3_text_1'), 'hud': t('s3_hud_1')},
        {'text': t('s3_text_2'), 'hud': t('s3_hud_2')},
        {'text': t('s3_text_3'), 'hud': t('s3_hud_3')},
        {'text': t('s3_text_4'), 'hud': t('s3_hud_4')},
      ];
    } else if (_scenario == 4) {
      stepsText = [
        {'text': t('s4_text_1'), 'hud': t('s4_hud_1')},
        {'text': t('s4_text_2'), 'hud': t('s4_hud_2')},
        {'text': t('s4_text_3'), 'hud': t('s4_hud_3')},
      ];
    } else if (_scenario == 5) {
      stepsText = [
        {'text': t('s5_text_1'), 'hud': t('s5_hud_1')},
        {'text': t('s5_text_2'), 'hud': t('s5_hud_2')},
        {'text': t('s5_text_3'), 'hud': t('s5_hud_3')},
      ];
    }

    String currentHudText = "";
    if (_step < stepsText.length) {
      currentHudText = stepsText[_step]['hud']!;
    } else {
      currentHudText = t('completed');
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: Stack(
          children: [
            // Structural Row handling dynamic resize between Sidebar and Canvas
            Row(
              children: [
                // Animated Sidebar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _isSidebarOpen ? sidebarWidth : 0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
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

                // Canvas Area (Takes up remaining screen real estate gracefully)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        color: const Color(0xFF020617),
                        child: Stack(
                          children: [
                            // Gesture / Canvas Layer
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
                                    painter: GridPainter(state: this),
                                    size: Size.infinite,
                                  ),
                                ),
                              ),
                            ),

                            // --- CANVAS BUTTONS & INTERACTIONS OVERLAY ---

                            // Canvas Floating Interaction Buttons (Bottom Center)
                            Positioned(
                              bottom: 100,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Next Challenge Button
                                  if (_completedScenarios.contains(_scenario) &&
                                      _scenario < 5)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        AudioEngine.click();
                                        _loadScenario(_scenario + 1);
                                      },
                                      icon: const Icon(Icons.arrow_forward),
                                      label: Text(t('nextScenario')),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                        elevation: 8,
                                      ),
                                    ),

                                  // Explain Why Button (Scenario 2 specific)
                                  if (_scenario == 2 &&
                                      _step == 2 &&
                                      !_s2Explained)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _s2Explained = true;
                                          _s2Animating = true;
                                          _s2AnimStartTime =
                                              DateTime.now()
                                                  .millisecondsSinceEpoch;
                                        });
                                        AudioEngine.success();
                                        Future.delayed(
                                          const Duration(seconds: 9),
                                          () {
                                            if (mounted) {
                                              setState(
                                                () => _s2Animating = false,
                                              );
                                              _markStepComplete();
                                            }
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.white,
                                      ),
                                      label: Text(t('explainBtn')),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
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

                            // HUD Instruction Panel
                            // Docks correctly on Canvas Center-Bottom to provide active step feedback
                            Positioned(
                              bottom: 24,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 500,
                                    minWidth: 320,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.5),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black38,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        color: Colors.blue,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          currentHudText,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            height: 1.4,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
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
              ],
            ),

            // Top Left Floating Menu Button (Absolute placement on Screen)
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

// --- CUSTOM PAINTER FOR GRID, MACHINES, TILES ---

class GridPainter extends CustomPainter {
  final _NumberGridsLabState state;

  GridPainter({required this.state}) : super(repaint: state._repaintNotifier);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Offset for panning to center correctly inside responsive width
    canvas.translate(
      size.width / 2 + state._panX,
      size.height / 2 + state._panY,
    );
    canvas.scale(state._zoom, state._zoom);

    if (state._scenario == 2) _drawSumOMeter(canvas);
    if (state._scenario == 3) _drawS3Machine(canvas);
    if (state._scenario == 4) _drawS4Machine(canvas);

    if (state._scenario != 3 || state._s3LeverPulled) {
      _drawGrid(canvas);
      _drawTargetSums(canvas);
    }

    // Draw non-dragged tiles
    for (var tile in state._tiles) {
      if (tile.alpha > 0 && tile != state._draggedTile) {
        _drawTile(canvas, tile, false);
      }
    }

    // Draw dragged tile on top
    if (state._draggedTile != null) {
      _drawTile(canvas, state._draggedTile!, true);
    }

    if (state._scenario == 2 && state._s2Animating) {
      _drawS2ExplainAnimation(canvas);
    }

    canvas.restore();
  }

  void _drawGrid(Canvas canvas) {
    if (state._scenario == 4 && state._step == 0) return;

    canvas.save();

    final Paint cellBgPaint =
        Paint()..color = const Color(0xFF94A3B8).withOpacity(0.1);
    final Paint cellBorderPaint =
        Paint()
          ..color = const Color(0xFF94A3B8).withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    final Paint hoverBgPaint = Paint()..color = Colors.blue.withOpacity(0.2);
    final Paint hoverBorderPaint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    for (int i = 0; i < 9; i++) {
      Rect rect = state._getCellRect(i);
      RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

      if (state._hoverCellIndex == i && state._draggedTile != null) {
        canvas.drawRRect(rrect, hoverBgPaint);
        canvas.drawRRect(rrect, hoverBorderPaint);
      } else {
        canvas.drawRRect(rrect, cellBgPaint);
        canvas.drawRRect(rrect, cellBorderPaint);
      }

      if (state._scenario == 5 && state._grid[i] == null) {
        TextPainter tp = TextPainter(
          text: TextSpan(
            text: state._s5Formulas[i],
            style: const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        tp.layout();
        tp.paint(
          canvas,
          Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2),
        );
      }
    }

    if (state._scenario == 3 && state._grid[4]?.val == 5) {
      Paint starPaint =
          Paint()
            ..color = Colors.blue.withOpacity(0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6;
      Rect cRect = state._getCellRect(4);
      double s = 65 + 8;
      canvas.drawLine(
        Offset(cRect.center.dx - s * 1.5, cRect.center.dy),
        Offset(cRect.center.dx + s * 1.5, cRect.center.dy),
        starPaint,
      );
      canvas.drawLine(
        Offset(cRect.center.dx, cRect.center.dy - s * 1.5),
        Offset(cRect.center.dx, cRect.center.dy + s * 1.5),
        starPaint,
      );
      canvas.drawLine(
        Offset(cRect.center.dx - s * 1.5, cRect.center.dy - s * 1.5),
        Offset(cRect.center.dx + s * 1.5, cRect.center.dy + s * 1.5),
        starPaint,
      );
      canvas.drawLine(
        Offset(cRect.center.dx + s * 1.5, cRect.center.dy - s * 1.5),
        Offset(cRect.center.dx - s * 1.5, cRect.center.dy + s * 1.5),
        starPaint,
      );
    }
    canvas.restore();
  }

  void _drawTile(Canvas canvas, TileData tile, bool isDragged) {
    canvas.save();
    double scale = isDragged ? 1.1 : 1.0;
    canvas.translate(tile.x, tile.y);
    canvas.scale(scale, scale);

    double size = 55;
    Rect tRect = Rect.fromCenter(
      center: Offset.zero,
      width: size,
      height: size,
    );
    RRect rrect = RRect.fromRectAndRadius(tRect, const Radius.circular(8));
    RRect innerRRect = RRect.fromRectAndRadius(
      tRect.deflate(2),
      const Radius.circular(6),
    );

    if (isDragged) {
      canvas.drawShadow(Path()..addRRect(rrect), Colors.black, 8, true);
    }

    Paint basePaint = Paint()..color = const Color(0xFF1E293B);
    Paint borderPaint =
        Paint()
          ..color = tile.isCorrect ? Colors.green : Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = tile.isCorrect ? 4 : 2;
    Paint innerPaint = Paint()..color = const Color(0xFF334155);

    canvas.drawRRect(rrect, basePaint);
    canvas.drawRRect(rrect, borderPaint);
    canvas.drawRRect(innerRRect, innerPaint);

    TextPainter tp = TextPainter(
      text: TextSpan(
        text: '${tile.val}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 26,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2 + 2));

    if (isDragged && state._scenario == 5 && state._hoverCellIndex != -1) {
      String form = state._s5Formulas[state._hoverCellIndex];
      String calcStr = form.replaceAll('m', '25');
      int result = 25;
      if (form.contains('+')) result = 25 + int.parse(form.split('+')[1]);
      if (form.contains('-')) result = 25 - int.parse(form.split('-')[1]);

      Paint tooltipPaint =
          Paint()..color = const Color(0xFF0F172A).withOpacity(0.9);
      Rect ttRect = Rect.fromCenter(
        center: const Offset(0, -70),
        width: 100,
        height: 26,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(ttRect, const Radius.circular(4)),
        tooltipPaint,
      );

      TextPainter ttTp = TextPainter(
        text: TextSpan(
          text: '$calcStr = $result',
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      ttTp.layout();
      ttTp.paint(canvas, Offset(-ttTp.width / 2, -70 - ttTp.height / 2));
    }

    canvas.restore();
  }

  void _drawTargetSums(Canvas canvas) {
    if (state._scenario == 4 && state._step == 0) return;

    var sums = state._getRowColSums();
    Rect rect0 = state._getCellRect(0);
    double spacing = 65 + 8;
    double tX = rect0.center.dx + 2.5 * spacing;
    double bY = rect0.center.dy + 2.5 * spacing;

    void drawNode(double x, double y, int current, int target, bool isFull) {
      Color color = const Color(0xFF94A3B8).withOpacity(0.3);
      Color textCol = Colors.grey;
      bool glow = false;
      if (current > 0) {
        if (current == target) {
          color = Colors.green;
          textCol = Colors.white;
          glow = true;
        } else if (isFull && current != target) {
          color = Colors.red;
          textCol = Colors.white;
        } else {
          color = Colors.blue;
          textCol = Colors.white;
        }
      }

      if (glow) {
        canvas.drawShadow(
          Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: 22)),
          Colors.green,
          10,
          true,
        );
      }

      canvas.drawCircle(
        Offset(x, y),
        22,
        Paint()..color = const Color(0xFF0F172A),
      );
      canvas.drawCircle(
        Offset(x, y),
        22,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      TextPainter tp = TextPainter(
        text: TextSpan(
          text: '${state._scenario >= 3 ? target : current}',
          style: TextStyle(
            color: textCol,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2 + 2));

      if (state._scenario < 3) {
        TextPainter tpSub = TextPainter(
          text: TextSpan(
            text: '/$target',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tpSub.layout();
        tpSub.paint(canvas, Offset(x + 25, y - 5));
      }
    }

    List<int> rTgts =
        state._scenario == 1
            ? state._s1Targets['r']!
            : (state._scenario == 2 ? state._s2Targets['r']! : [15, 15, 15]);
    if (state._scenario == 4) rTgts = [18, 18, 18];
    if (state._scenario == 5) rTgts = [75, 75, 75];
    for (int i = 0; i < 3; i++) {
      drawNode(
        tX,
        rect0.center.dy + i * spacing,
        sums['r']![i],
        rTgts[i],
        sums['rC']![i] == 3,
      );
    }

    List<int> cTgts =
        state._scenario == 1
            ? state._s1Targets['c']!
            : (state._scenario == 2 ? state._s2Targets['c']! : [15, 15, 15]);
    if (state._scenario == 4) cTgts = [18, 18, 18];
    if (state._scenario == 5) cTgts = [75, 75, 75];
    for (int i = 0; i < 3; i++) {
      drawNode(
        rect0.center.dx + i * spacing,
        bY,
        sums['c']![i],
        cTgts[i],
        sums['cC']![i] == 3,
      );
    }

    if (state._scenario >= 3) {
      int dTgt = state._scenario == 4 ? 18 : (state._scenario == 5 ? 75 : 15);
      drawNode(tX, bY, sums['d1']![0], dTgt, sums['d1C']![0] == 3);
      drawNode(
        tX,
        rect0.center.dy - spacing,
        sums['d2']![0],
        dTgt,
        sums['d2C']![0] == 3,
      );
    }
  }

  void _drawSumOMeter(Canvas canvas) {
    double x = -280, y = -40, w = 30, h = 240;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y - h / 2, w, h),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );

    final Rect gradRect = Rect.fromLTWH(x + 4, y - h / 2 + 4, w - 8, h - 8);
    const Gradient gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Colors.red,
        Colors.red,
        Colors.green,
        Colors.green,
        Colors.red,
        Colors.red,
      ],
      stops: [0.0, 0.2, 0.25, 0.85, 0.9, 1.0],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(gradRect, const Radius.circular(6)),
      Paint()..shader = gradient.createShader(gradRect),
    );

    if (state._step > 0) {
      var sums = state._getRowColSums();
      int highlightSum = state._step == 1 ? sums['r']![0] : sums['c']![0];
      int targetSum = state._step == 1 ? 5 : 26;
      double mapY(int val) => (y + h / 2) - ((val / 30) * h);

      Path tgtPath =
          Path()
            ..moveTo(x + w + 5, mapY(targetSum))
            ..lineTo(x + w + 15, mapY(targetSum) - 5)
            ..lineTo(x + w + 15, mapY(targetSum) + 5)
            ..close();
      canvas.drawPath(tgtPath, Paint()..color = Colors.red);
      _drawText(
        canvas,
        '${state.t('target')}: $targetSum',
        Offset(x + w + 20, mapY(targetSum)),
        Colors.red,
        12,
        TextAlign.left,
      );

      if (highlightSum > 0) {
        Path curPath =
            Path()
              ..moveTo(x - 5, mapY(highlightSum))
              ..lineTo(x - 15, mapY(highlightSum) - 5)
              ..lineTo(x - 15, mapY(highlightSum) + 5)
              ..close();
        canvas.drawPath(curPath, Paint()..color = Colors.white);
        _drawText(
          canvas,
          '${state.t('current')}: $highlightSum',
          Offset(x - 20, mapY(highlightSum)),
          Colors.white,
          12,
          TextAlign.right,
        );
      }

      if (state._step == 2 && !state._s2Animating) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-145, -185, 290, 250),
            const Radius.circular(16),
          ),
          Paint()..color = Colors.red.withOpacity(0.15),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-145, -185, 290, 250),
            const Radius.circular(16),
          ),
          Paint()
            ..color = Colors.red
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
      }
    }
  }

  void _drawS2ExplainAnimation(Canvas canvas) {
    int elapsed = state._currentTime - state._s2AnimStartTime;
    if (elapsed < 3000) {
      canvas.drawRect(
        const Rect.fromLTWH(-145, -185, 290, 78),
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      _drawText(
        canvas,
        '1 + 2 + 3 = 6 (${state.t('minPossible')})',
        const Offset(0, -205),
        Colors.amber,
        20,
        TextAlign.center,
      );
    } else if (elapsed < 6000) {
      canvas.drawRect(
        const Rect.fromLTWH(-145, -185, 78, 250),
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      _drawText(
        canvas,
        '7 + 8 + 9 = 24 (${state.t('maxPossible')})',
        const Offset(0, -205),
        Colors.amber,
        20,
        TextAlign.center,
      );
    } else {
      Paint xPaint =
          Paint()
            ..color = Colors.red
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8;
      Rect rect0 = state._getCellRect(0);
      double spacing = 65 + 8;
      double tX = rect0.center.dx + 2.5 * spacing;
      double bY = rect0.center.dy + 2.5 * spacing;
      double rY = rect0.center.dy;
      double cX = rect0.center.dx;
      // Target 5
      canvas.drawLine(
        Offset(tX - 15, rY - 15),
        Offset(tX + 15, rY + 15),
        xPaint,
      );
      canvas.drawLine(
        Offset(tX + 15, rY - 15),
        Offset(tX - 15, rY + 15),
        xPaint,
      );
      // Target 26
      canvas.drawLine(
        Offset(cX - 15, bY - 15),
        Offset(cX + 15, bY + 15),
        xPaint,
      );
      canvas.drawLine(
        Offset(cX + 15, bY - 15),
        Offset(cX - 15, bY + 15),
        xPaint,
      );
      _drawText(
        canvas,
        state.t('outOfRange'),
        const Offset(0, -205),
        Colors.red,
        26,
        TextAlign.center,
      );
    }
  }

  void _drawS3Machine(Canvas canvas) {
    if (!state._s3LeverPulled && !state._s3Animating) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-200, -280, 400, 100),
          const Radius.circular(10),
        ),
        Paint()..color = const Color(0xFF1E293B).withOpacity(0.8),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-200, -280, 400, 100),
          const Radius.circular(10),
        ),
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      _drawText(
        canvas,
        '${state.t('totalSum')} = 45',
        const Offset(0, -210),
        Colors.white,
        32,
        TextAlign.center,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(220, -270, 30, 80),
          const Radius.circular(5),
        ),
        Paint()..color = const Color(0xFF475569),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(215, -270 + state._s3LeverY, 40, 30),
          const Radius.circular(6),
        ),
        Paint()..color = Colors.red,
      );

      for (int i = 0; i < 3; i++) {
        double bx = -150.0 + i * 150;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(bx - 40, -80, 80, 90),
            const Radius.circular(8),
          ),
          Paint()..color = Colors.blue.withOpacity(0.1),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(bx - 40, -80, 80, 90),
            const Radius.circular(8),
          ),
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        _drawText(
          canvas,
          '${state.t('rowSum')} ${i + 1}',
          Offset(bx, 30),
          Colors.grey,
          14,
          TextAlign.center,
        );
      }
    } else if (state._s3Animating) {
      int elapsed = state._currentTime - state._s3AnimStartTime;
      double p = (elapsed / 2000).clamp(0.0, 1.0);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-200, -280, 400, 100),
          const Radius.circular(10),
        ),
        Paint()..color = const Color(0xFF1E293B).withOpacity(0.8),
      );
      _drawText(
        canvas,
        '${state.t('totalSum')} = 45',
        const Offset(0, -210),
        Colors.white.withOpacity(1 - p),
        32,
        TextAlign.center,
      );

      for (int i = 0; i < 3; i++) {
        double bx = -150.0 + i * 150;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(bx - 40, -80, 80, 90),
            const Radius.circular(8),
          ),
          Paint()..color = Colors.blue.withOpacity(0.1),
        );
        double y = -210 + p * 190;
        _drawText(
          canvas,
          '15',
          Offset(bx, y),
          Colors.green.withOpacity(p > 0.8 ? 1 : p),
          28,
          TextAlign.center,
        );
      }

      if (p == 1.0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.mounted) {
            state.setState(() {
              state._s3Animating = false;
              state._s3LeverPulled = true;
              state._markStepComplete();
              for (var t in state._tiles) {
                t.alpha = 1;
              }
            });
          }
        });
      }
    }
  }

  void _drawGear(
    Canvas canvas,
    double cx,
    double cy,
    double radius,
    int teeth,
    double rot,
    Color color,
  ) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rot);
    Paint p = Paint()..color = color;
    Path path = Path();
    for (int i = 0; i < teeth; i++) {
      double angle = (i / teeth) * math.pi * 2;
      path.lineTo(
        math.cos(angle - 0.1) * radius,
        math.sin(angle - 0.1) * radius,
      );
      path.lineTo(
        math.cos(angle) * radius * 1.2,
        math.sin(angle) * radius * 1.2,
      );
      path.lineTo(
        math.cos(angle + 0.1) * radius * 1.2,
        math.sin(angle + 0.1) * radius * 1.2,
      );
      path.lineTo(
        math.cos(angle + 0.2) * radius,
        math.sin(angle + 0.2) * radius,
      );
    }
    path.close();
    canvas.drawPath(path, p);
    canvas.drawCircle(
      Offset.zero,
      radius * 0.4,
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.restore();
  }

  void _drawS4Machine(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-150, -380, 300, 220),
        const Radius.circular(16),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-150, -380, 300, 220),
        const Radius.circular(16),
      ),
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    Path hPath =
        Path()
          ..moveTo(-60, -380)
          ..lineTo(-100, -440)
          ..lineTo(100, -440)
          ..lineTo(60, -380)
          ..close();
    canvas.drawPath(hPath, Paint()..color = const Color(0xFF334155));
    if (state._step == 0 &&
        state._draggedTile != null &&
        state._hoverCellIndex == 99) {
      canvas.drawPath(hPath, Paint()..color = Colors.blue.withOpacity(0.3));
    }
    if (state._step == 0) {
      _drawText(
        canvas,
        state.t('dropHere'),
        const Offset(0, -410),
        Colors.white,
        16,
        TextAlign.center,
      );
    }

    double gearRot = (state._step <= 1) ? state._currentTime * 0.001 : 0;
    _drawGear(canvas, -100, -300, 30, 8, gearRot, const Color(0xFF94A3B8));
    _drawGear(
      canvas,
      -50,
      -280,
      25,
      6,
      -gearRot * 1.2,
      const Color(0xFF64748B),
    );
    _drawGear(
      canvas,
      100,
      -320,
      35,
      10,
      -gearRot * 0.8,
      const Color(0xFF475569),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-40, -340, 80, 50),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );
    String dispVal = state._step >= 2 ? "0" : state._s4CalcTotal.toString();
    _drawText(
      canvas,
      dispVal,
      const Offset(0, -315),
      Colors.green,
      36,
      TextAlign.center,
    );

    if (state._step <= 1) {
      double lA = (math.sin(state._currentTime * 0.005) + 1) / 2;
      canvas.drawCircle(
        const Offset(-110, -220),
        8,
        Paint()..color = Colors.red.withOpacity(0.3 + 0.7 * lA),
      );
      canvas.drawCircle(
        const Offset(-80, -220),
        8,
        Paint()
          ..color = Colors.amber.withOpacity(
            0.3 + 0.7 * (math.sin(state._currentTime * 0.004).abs()),
          ),
      );
      canvas.drawCircle(
        const Offset(-50, -220),
        8,
        Paint()
          ..color = Colors.green.withOpacity(
            0.3 + 0.7 * (math.cos(state._currentTime * 0.006).abs()),
          ),
      );
      _drawText(
        canvas,
        state.t('calcTotal'),
        const Offset(0, -260),
        Colors.white,
        16,
        TextAlign.center,
      );
    }

    if (state._step == 1 && state._s4CalcTotal == 54 && !state._s4Animating) {
      double bs = 1 + 0.03 * math.sin(state._currentTime * 0.008);
      canvas.save();
      canvas.translate(0, -190);
      canvas.scale(bs, bs);
      canvas.drawShadow(
        Path()..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-100, -25, 200, 50),
            const Radius.circular(12),
          ),
        ),
        Colors.purple,
        15,
        true,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-100, -25, 200, 50),
          const Radius.circular(12),
        ),
        Paint()..color = Colors.purple,
      );
      _drawText(
        canvas,
        state.t('divide3'),
        Offset.zero,
        Colors.white,
        16,
        TextAlign.center,
      );
      canvas.restore();
    }

    if (state._s4Animating || state._step >= 2) {
      Paint pipeOuter =
          Paint()
            ..color = const Color(0xFF475569)
            ..strokeWidth = 40
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke;
      Paint pipeInner =
          Paint()
            ..color = const Color(0xFF1E293B)
            ..strokeWidth = 30
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke;
      Path pPath =
          Path()
            ..moveTo(0, -315)
            ..lineTo(200, -315)
            ..lineTo(200, -50);
      canvas.drawPath(pPath, pipeOuter);
      canvas.drawPath(pPath, pipeInner);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(160, -180, 80, 40),
          const Radius.circular(8),
        ),
        Paint()..color = Colors.red,
      );
      _drawText(
        canvas,
        '÷ 3',
        const Offset(200, -160),
        Colors.white,
        20,
        TextAlign.center,
      );

      if (state._s4Animating) {
        int elapsed = state._currentTime - state._s4AnimStartTime;
        double p = (elapsed / 3000).clamp(0.0, 1.0);
        double bx = 0, by = -315;
        if (p < 0.4) {
          bx = (p / 0.4) * 200;
          by = -315;
        } else {
          bx = 200;
          by = -315 + ((p - 0.4) / 0.6) * 265;
        }

        canvas.drawShadow(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(bx - 25, by - 25, 50, 50),
              const Radius.circular(8),
            ),
          ),
          Colors.amber,
          15,
          true,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(bx - 25, by - 25, 50, 50),
            const Radius.circular(8),
          ),
          Paint()..color = Colors.amber,
        );
        _drawText(
          canvas,
          by < -160 ? '54' : '18',
          Offset(bx, by),
          Colors.black,
          24,
          TextAlign.center,
        );

        if (p >= 1.0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (state.mounted) {
              state.setState(() {
                state._s4Animating = false;
                state._s4MagicSumCalculated = true;
                state._markStepComplete();
                double w = 65 * 3 + 8 * 2;
                double startX = -w / 2 + 65 / 2;
                for (int i = 0; i < state._tiles.length; i++) {
                  var t = state._tiles[i];
                  t.alpha = 1;
                  t.x = 200;
                  t.y = -50;
                  t.tgtX = startX + (i % 5) * 65 - 20;
                  t.tgtY = 180 + (i ~/ 5) * 65;
                }
              });
            }
          });
        }
      }
    }
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
