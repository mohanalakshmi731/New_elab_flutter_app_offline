// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExploringMagicSquaresApp());
}

class ExploringMagicSquaresApp extends StatelessWidget {
  const ExploringMagicSquaresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Exploring Magic Squares',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      // Force both theme and darkTheme to be dark to prevent any light theme flashes
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          surface: Color(0xFF1E293B),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Roboto',
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          surface: Color(0xFF1E293B),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Roboto',
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const MagicSquaresLab(),
    );
  }
}

// --- MODELS & STATE ---

class TileData {
  final String id;
  int val;
  int originalVal;
  double homeX, homeY;
  double x, y;
  double tgtX, tgtY;
  double offX = 0, offY = 0;
  double alpha = 1.0;
  bool isCorrect = false;

  TileData(this.id, this.val, this.homeX, this.homeY)
    : originalVal = val,
      x = homeX,
      y = homeY,
      tgtX = homeX,
      tgtY = homeY;
}

// --- TRANSLATIONS ---

const Map<String, Map<String, String>> translations = {
  'en': {
    'appTitle': 'Exploring Magic Squares',
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
    'minSum': 'Minimum Sum',
    'maxSum': 'Maximum Sum',
    'targetSum': 'Target',
    'currentSum': 'Current',
    'outOfRange': 'OUT OF RANGE',
    'rowsScale': 'Rows',
    'colsScale': 'Columns',
    'diagsScale': 'Diagonals',
    'confirmBtn': 'CONFIRM',
    'tooLight': 'Too Light',
    'tooHeavy': 'Too Heavy',
    'dialOff': 'OFF',
    'dropHere': 'DROP HERE',
    'calcSumText': 'CALCULATE',
    'divide3': 'DIVIDE 3',
    'minPossible': 'Minimum Possible',
    'maxPossible': 'Maximum Possible',
    'successTitle': 'Master of Magic!',
    'successDesc':
        'You have successfully completed all the challenges and mastered the secrets of Magic Squares.',
    'restartLab': 'Restart Lab',
    's1_title': '1. The Balancing Grid',
    's1_obj':
        'To visually understand the core property of a magic square by arranging numbered tiles to balance a set of scales representing rows, columns, and diagonals.',
    's1_hud_1':
        "DRAG the tile '5' and DROP it into the center square of the grid.",
    's1_text_1':
        "The tile '5' locks into the center square. The grid glows momentarily.",
    's1_hud_2':
        "DRAG the tile '8' to a corner square and the tile '2' to the opposite corner square.",
    's1_text_2':
        "The tiles '8' and '2' are placed. A glowing line connects 8, 5, and 2. The diagonal scale animates: its two pans rise and fall before settling perfectly level, and a display above it shows '15'.",
    's1_hud_3':
        "Complete the grid by dragging the remaining tiles into the empty squares. Your goal is to make all three scales balance at 15.",
    's1_text_3':
        "All tiles are placed correctly in the grid. All three scales are perfectly balanced, and the number '15' is lit up above each one. The entire grid glows, indicating success.",
    's1_sum':
        "A magic square perfectly balances every row, column, and diagonal to the same magic sum.",
    's2_title': '2. The Transformation Machine',
    's2_obj':
        'To discover how uniform arithmetic operations affect a magic square and its magic sum.',
    's2_hud_1': "CLICK the dial to set the number to '+3'.",
    's2_text_1': "The dial displays '+3'. The machine begins to hum and glow.",
    's2_hud_2': "PULL the large lever on the machine downwards.",
    's2_text_2':
        "The machine animates, and every number tile in the grid increases by 3. A mechanical arm extends from the machine and 'zaps' each tile. The scales unbalance and then re-balance at a new, higher value (18).",
    's2_hud_3':
        "Now, reset the grid by clicking the dial to 'x2', then PULL the lever again.",
    's2_text_3':
        "The machine animates, and every number tile in the grid is doubled. The scales unbalance and then re-balance at the new magic sum of 30.",
    's2_sum':
        "Applying a uniform arithmetic operation to all cells maintains the magic properties of the square.",
    's3_title': '3. The Centerpiece Puzzle',
    's3_obj':
        'To deduce through guided trial-and-error why the number 5 must occupy the center of a 1-9 magic square.',
    's3_hud_1':
        "Let's test which numbers can be the centerpiece. DRAG the tile '9' and DROP it into the center square.",
    's3_text_1':
        "The tile '9' is placed in the center. Four lines highlight, representing the center row, center column, and the two diagonals that pass through the center.",
    's3_hud_2':
        "The system will now try to find pairs of remaining numbers that add up to the required sum (15 - 9 = 6).",
    's3_text_2':
        "The system visually scans the remaining tiles. It pulls out '1' and '5', then '2' and '4'. Then, it searches for more pairs that sum to 6 but finds none. The remaining lines flash red, and a large 'X' appears.",
    's3_hud_3': "Now, DRAG the tile '5' and DROP it into the center square.",
    's3_text_3':
        "The tile '5' is placed. The system scans the remaining tiles and quickly finds four pairs: (1,9), (2,8), (3,7), and (4,6). It animates these pairs flying into place. A 'POSSIBLE!' message appears.",
    's3_sum':
        "The number 5 is the only number with enough matching pairs to satisfy all 4 intersecting lines through the center.",
    's4_title': '4. The Impossible Grid',
    's4_obj':
        'To use knowledge of minimum and maximum possible sums to determine that a given grid puzzle cannot be solved.',
    's4_hud_1':
        "The target sum for the top row is '5'. Try to fill the top row to sum exactly to 5.",
    's4_text_1':
        "As the user places tiles in the top row, the attached scale reacts. If they place '1' and '2', the scale shows '3'. If they add '3', the sum becomes '6' and the scale shows 'Too Heavy'. The scale for '5' can never be balanced.",
    's4_hud_2':
        "Now, try to fill the rightmost column so the sum is exactly 26. Conclude if this grid is solvable.",
    's4_text_2':
        "Even with the three largest tiles (7, 8, 9), the scale shows the sum is '24' and is 'Too Light'. A red warning light flashes next to the '26' target.",
    's4_hud_3': "CLICK the 'Explain Why' button on the canvas.",
    's4_text_3':
        "An animation highlights the numbers 1, 2, and 3, showing 1+2+3=6 (Minimum Possible). Then, it highlights 7, 8, 9, showing 7+8+9=24 (Maximum Possible). The target sums of 5 and 26 are crossed out with large red 'X' marks.",
    's4_sum':
        "This grid is impossible because the requested targets are outside the maximum (24) and minimum (6) boundaries.",
    's5_title': '5. The Custom Creator',
    's5_obj':
        'To generalize the magic square concept by creating a magic square using a different set of 9 consecutive numbers.',
    's5_hud_1':
        "Your mission is to create a magic square using numbers 2 through 10. First, calculate the new magic sum. Use the buttons on the calculator to enter it.",
    's5_text_1':
        "The user determines the new magic sum is 18 (Sum of 2-10 is 54; 54 / 3 = 18). The user inputs '18' into the target sum display.",
    's5_hud_2':
        "Which number from your new set should go in the center? DRAG the correct tile.",
    's5_text_2':
        "The user correctly identifies the middle number of the sequence (6) and places it in the center.",
    's5_hud_3':
        "Now, fill the rest of the grid to create a magic square where every row, column, and diagonal balances at 18.",
    's5_text_3':
        "The user successfully arranges the tiles 2-10 to form a valid magic square. All three scales balance perfectly at 18. The grid and scales light up.",
    's5_sum':
        "By applying the rules of medians and sums, you can construct a magic square with any set of consecutive numbers.",
  },
  'hi': {
    'appTitle': 'जादुई वर्गों की खोज',
    'appSubtitle': 'कक्षा 7 • संख्याओं का खेल',
    'enterLab': 'लैब में प्रवेश करें',
    'reset': 'रीसेट',
    'selectScenario': 'मिशन चुनें',
    'nextScenario': 'अगली चुनौती',
    'stepLabel': 'अवलोकन',
    'theory': 'अवलोकन नोट्स',
    'explainBtn': 'कारण स्पष्ट करें',
    'rowSum': 'पंक्ति',
    'completed': 'पूरा हुआ!',
    'minSum': 'न्यूनतम योग',
    'maxSum': 'अधिकतम योग',
    'targetSum': 'लक्ष्य',
    'currentSum': 'वर्तमान',
    'outOfRange': 'सीमा से बाहर',
    'rowsScale': 'पंक्तियाँ',
    'colsScale': 'स्तंभ',
    'diagsScale': 'विकर्ण',
    'confirmBtn': 'पुष्टि करें',
    'tooLight': 'बहुत हल्का',
    'tooHeavy': 'बहुत भारी',
    'dialOff': 'बंद',
    'dropHere': 'यहाँ छोड़ें',
    'calcSumText': 'गणना करें',
    'divide3': '3 से भाग दें',
    'minPossible': 'न्यूनतम संभव',
    'maxPossible': 'अधिकतम संभव',
    'successTitle': 'जादू के उस्ताद!',
    'successDesc':
        'आपने सभी चुनौतियों को सफलतापूर्वक पूरा कर लिया है और जादुई वर्गों के रहस्यों में महारत हासिल कर ली है।',
    'restartLab': 'लैब को फिर से शुरू करें',
    's1_title': '1. संतुलन ग्रिड',
    's1_obj':
        'पंक्तियों, स्तंभों और विकर्णों का प्रतिनिधित्व करने वाले तराजू के एक सेट को संतुलित करने के लिए संख्या वाली टाइलों को व्यवस्थित करके एक जादुई वर्ग के मुख्य गुण को दृश्य रूप से समझना।',
    's1_hud_1':
        "टाइल '5' को खींचें (DRAG) और ग्रिड के केंद्र वर्ग में छोड़ें (DROP)।",
    's1_text_1':
        "टाइल '5' केंद्र वर्ग में लॉक हो जाती है। ग्रिड क्षण भर के लिए चमकता है।",
    's1_hud_2':
        "टाइल '8' को एक कोने के वर्ग में और टाइल '2' को विपरीत कोने के वर्ग में खींचें।",
    's1_text_2':
        "टाइलें '8' और '2' रखी गई हैं। एक चमकती रेखा 8, 5, और 2 को जोड़ती है। विकर्ण पैमाना एनिमेट होता है: इसके दो पैन पूरी तरह से समतल होने से पहले उठते और गिरते हैं, और इसके ऊपर एक डिस्प्ले '15' दिखाता है।",
    's1_hud_3':
        "शेष टाइलों को खाली वर्गों में खींचकर ग्रिड को पूरा करें। आपका लक्ष्य तीनों पैमानों को 15 पर संतुलित करना है।",
    's1_text_3':
        "सभी टाइलें ग्रिड में सही ढंग से रखी गई हैं। सभी तीन पैमाने पूरी तरह से संतुलित हैं, और प्रत्येक के ऊपर '15' संख्या जगमगाती है। पूरा ग्रिड चमकता है, जो सफलता का संकेत देता है।",
    's1_sum':
        "एक जादुई वर्ग प्रत्येक पंक्ति, स्तंभ और विकर्ण को एक ही जादुई योग में पूरी तरह से संतुलित करता है।",
    's2_title': '2. परिवर्तन मशीन',
    's2_obj':
        'यह खोजना कि एकसमान अंकगणितीय संचालन एक जादुई वर्ग और उसके जादुई योग को कैसे प्रभावित करते हैं।',
    's2_hud_1': "संख्या को '+3' पर सेट करने के लिए डायल पर क्लिक करें।",
    's2_text_1':
        "डायल '+3' प्रदर्शित करता है। मशीन गुनगुनाने और चमकने लगती है।",
    's2_hud_2': "मशीन पर बड़े लीवर को नीचे की ओर खींचें।",
    's2_text_2':
        "मशीन एनिमेट होती है, और ग्रिड में प्रत्येक संख्या टाइल 3 से बढ़ जाती है। एक यांत्रिक भुजा मशीन से निकलती है और प्रत्येक टाइल को 'ज़ैप' करती है। तराजू असंतुलित हो जाते हैं और फिर एक नए, उच्च मान (18) पर फिर से संतुलित हो जाते हैं।",
    's2_hud_3':
        "अब, डायल को 'x2' पर क्लिक करके ग्रिड को रीसेट करें, फिर से लीवर खींचें।",
    's2_text_3':
        "मशीन एनिमेट होती है, और ग्रिड में प्रत्येक संख्या टाइल दोगुनी हो जाती है। तराजू असंतुलित हो जाते हैं और फिर 30 के नए जादुई योग पर फिर से संतुलित हो जाते हैं।",
    's2_sum':
        "सभी कोशिकाओं में एकसमान अंकगणितीय संक्रिया लागू करने से वर्ग के जादुई गुण बने रहते हैं।",
    's3_title': '3. केंद्रबिंदु पहेली',
    's3_obj':
        'निर्देशित परीक्षण और त्रुटि के माध्यम से यह निकालना कि 1-9 जादुई वर्ग के केंद्र में संख्या 5 क्यों होनी चाहिए।',
    's3_hud_1':
        "आइए परीक्षण करें कि कौन सी संख्याएँ केंद्रबिंदु हो सकती हैं। टाइल '9' को खींचें और इसे केंद्र वर्ग में छोड़ दें।",
    's3_text_1':
        "टाइल '9' को केंद्र में रखा गया है। चार पंक्तियाँ हाइलाइट होती हैं, जो केंद्र पंक्ति, केंद्र स्तंभ और दो विकर्णों का प्रतिनिधित्व करती हैं जो केंद्र से होकर गुजरती हैं।",
    's3_hud_2':
        "सिस्टम अब शेष संख्याओं के जोड़े खोजने का प्रयास करेगा जो आवश्यक योग (15 - 9 = 6) तक जुड़ते हैं।",
    's3_text_2':
        "सिस्टम शेष टाइलों को दृश्य रूप से स्कैन करता है। यह '1' और '5', फिर '2' और '4' को निकालता है। फिर, यह अधिक जोड़े खोजता है जो 6 तक जुड़ते हैं लेकिन कोई नहीं मिलता है। शेष रेखाएँ लाल रंग में चमकती हैं, और एक बड़ा 'X' दिखाई देता है।",
    's3_hud_3': "अब, टाइल '5' को खींचें और इसे केंद्र वर्ग में छोड़ दें।",
    's3_text_3':
        "टाइल '5' रखी गई है। सिस्टम शेष टाइलों को स्कैन करता है और जल्दी से चार जोड़े खोजता है: (1,9), (2,8), (3,7), और (4,6)। यह इन जोड़ों को जगह में उड़ान भरते हुए एनिमेट करता है। एक 'संभव!' संदेश दिखाई देता है।",
    's3_sum':
        "संख्या 5 एकमात्र ऐसी संख्या है जिसमें केंद्र से होकर गुजरने वाली सभी 4 प्रतिच्छेदन रेखाओं को संतुष्ट करने के लिए पर्याप्त मिलान जोड़े हैं।",
    's4_title': '4. असंभव ग्रिड',
    's4_obj':
        'यह निर्धारित करने के लिए न्यूनतम और अधिकतम संभव योगों के ज्ञान का उपयोग करना कि किसी दिए गए ग्रिड पहेली को हल नहीं किया जा सकता है।',
    's4_hud_1':
        "शीर्ष पंक्ति के लिए लक्ष्य योग '5' है। शीर्ष पंक्ति को भरने का प्रयास करें ताकि योग बिल्कुल 5 हो।",
    's4_text_1':
        "जैसे ही उपयोगकर्ता शीर्ष पंक्ति में टाइलें रखता है, संलग्न पैमाना प्रतिक्रिया करता है। यदि वे '1' और '2' रखते हैं, तो पैमाना '3' दिखाता है। यदि वे '3' जोड़ते हैं, तो योग '6' हो जाता है और पैमाना 'बहुत भारी' दिखाता है। '5' के लिए पैमाना कभी संतुलित नहीं किया जा सकता है।",
    's4_hud_2':
        "अब, सबसे दाहिने स्तंभ को भरने का प्रयास करें ताकि योग बिल्कुल 26 हो। निष्कर्ष निकालें कि क्या यह ग्रिड हल करने योग्य है।",
    's4_text_2':
        "तीन सबसे बड़ी टाइलों (7, 8, 9) के साथ भी, पैमाना दिखाता है कि योग '24' है और 'बहुत हल्का' है। '26' लक्ष्य के बगल में एक लाल चेतावनी बत्ती चमकती है।",
    's4_hud_3': "कैनवास पर 'कारण स्पष्ट करें' बटन पर क्लिक करें।",
    's4_text_3':
        "एक एनीमेशन संख्याओं 1, 2, और 3 को हाइलाइट करता है, जो 1+2+3=6 (न्यूनतम संभव) दिखाता है। फिर, यह 7, 8, 9 को हाइलाइट करता है, जो 7+8+9=24 (अधिकतम संभव) दिखाता है। 5 और 26 के लक्ष्य योगों को बड़े लाल 'X' निशान के साथ काट दिया जाता है।",
    's4_sum':
        "यह ग्रिड असंभव है क्योंकि अनुरोधित लक्ष्य अधिकतम (24) और न्यूनतम (6) सीमाओं के बाहर हैं।",
    's5_title': '5. कस्टम निर्माता',
    's5_obj':
        '9 लगातार संख्याओं के एक अलग सेट का उपयोग करके एक जादुई वर्ग बनाकर जादुई वर्ग अवधारणा को सामान्य बनाना।',
    's5_hud_1':
        "आपका मिशन 2 से 10 तक की संख्याओं का उपयोग करके एक जादुई वर्ग बनाना है। सबसे पहले, नए जादुई योग की गणना करें। इसे दर्ज करने के लिए कैलकुलेटर के बटनों का उपयोग करें।",
    's5_text_1':
        "उपयोगकर्ता निर्धारित करता है कि नया जादुई योग 18 है (2-10 का योग 54 है; 54 / 3 = 18)। उपयोगकर्ता लक्ष्य योग प्रदर्शन में '18' इनपुट करता है।",
    's5_hud_2':
        "आपके नए सेट से कौन सी संख्या केंद्र में जानी चाहिए? सही टाइल खींचें।",
    's5_text_2':
        "उपयोगकर्ता सही ढंग से अनुक्रम (6) की मध्य संख्या की पहचान करता है और इसे केंद्र में रखता है।",
    's5_hud_3':
        "अब, एक जादुई वर्ग बनाने के लिए बाकी ग्रिड को भरें जहां प्रत्येक पंक्ति, स्तंभ और विकर्ण 18 पर संतुलित हो।",
    's5_text_3':
        "उपयोगकर्ता एक मान्य जादुई वर्ग बनाने के लिए टाइल्स 2-10 को सफलतापूर्वक व्यवस्थित करता है। सभी तीन तराजू 18 पर पूरी तरह से संतुलित हैं। ग्रिड और तराजू चमकते हैं।",
    's5_sum':
        "माध्य और योग के नियमों को लागू करके, आप किसी भी लगातार संख्याओं के सेट के साथ एक जादुई वर्ग बना सकते हैं।",
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

// --- MAIN SCREEN ---

class MagicSquaresLab extends StatefulWidget {
  const MagicSquaresLab({super.key});

  @override
  State<MagicSquaresLab> createState() => _MagicSquaresLabState();
}

class _MagicSquaresLabState extends State<MagicSquaresLab>
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
  double _panY = 0;
  double _zoom = 1.0;

  // Custom gesture tracking
  double _baseZoom = 1.0;

  // Game State
  int _scenario = 1;
  int _step = 0;

  void updateState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  List<TileData?> _grid = List.filled(9, null);
  final List<TileData> _tiles = [];
  final Set<int> _completedScenarios = {};
  TileData? _draggedTile;
  int _hoverCellIndex = -1;

  // Scenario 2 specific
  int _s2Dial = 0; // 0: off, 1: +3, 2: x2
  bool _s2Animating = false;
  int _s2AnimStart = 0;
  String _s2AnimType = '';

  // Scenario 3 specific
  bool _s3Animating = false;
  int _s3AnimStart = 0;

  // Scenario 4 specific
  bool _s4Animating = false;
  int _s4AnimStart = 0;
  bool _s4Explained = false;
  bool _s4Wait = false;

  // Scenario 5 specific
  int _s5CalcInput = 18;
  bool _s5CalcConfirmed = false;

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
      _s3Animating = false;
      _s4Animating = false;
      _lang = 'en';
    });
  }

  void _resetGridAndTiles(List<int> vals, {double yOffset = 280}) {
    _grid = List.filled(9, null);
    _tiles.clear();
    double cellSize = 70;
    double gap = 8;
    double w = cellSize * 3 + gap * 2;
    double startX = -w / 2 + cellSize / 2;
    for (int i = 0; i < vals.length; i++) {
      _tiles.add(
        TileData(
          't${vals[i]}',
          vals[i],
          startX + (i % 5) * 65 - 20,
          yOffset + (i ~/ 5) * 75,
        ),
      );
    }
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;

      if (_scenario == 1) {
        _resetGridAndTiles([1, 2, 3, 4, 5, 6, 7, 8, 9]);
      } else if (_scenario == 2) {
        _resetGridAndTiles([8, 1, 6, 3, 5, 7, 4, 9, 2]);
        for (int i = 0; i < _tiles.length; i++) {
          Rect r = _getCellRect(i);
          var t = _tiles[i];
          t.x = t.tgtX = t.homeX = r.center.dx;
          t.y = t.tgtY = t.homeY = r.center.dy;
          t.originalVal = t.val;
          _grid[i] = t;
        }
        _s2Dial = 0;
        _s2Animating = false;
      } else if (_scenario == 3) {
        _resetGridAndTiles([1, 2, 3, 4, 5, 6, 7, 8, 9]);
        _s3Animating = false;
      } else if (_scenario == 4) {
        _resetGridAndTiles([1, 2, 3, 4, 5, 6, 7, 8, 9]);
        _s4Explained = false;
        _s4Animating = false;
        _s4Wait = false;
      } else if (_scenario == 5) {
        _resetGridAndTiles([2, 3, 4, 5, 6, 7, 8, 9, 10]);
        _s5CalcInput = 18;
        _s5CalcConfirmed = false;
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

  void _checkStepCompletion() {
    if (_scenario == 1) {
      if (_step == 0 && _grid[4]?.val == 5) _markStepComplete();
      if (_step == 1) {
        if ((_grid[0]?.val == 8 && _grid[8]?.val == 2) ||
            (_grid[0]?.val == 2 && _grid[8]?.val == 8) ||
            (_grid[2]?.val == 8 && _grid[6]?.val == 2) ||
            (_grid[2]?.val == 2 && _grid[6]?.val == 8)) {
          _markStepComplete();
        }
      }
      if (_step == 2) {
        var s = _getRowColSums();
        int filledCells = _grid.where((c) => c != null).length;
        if (s['r']!.every((x) => x == 15) &&
            s['c']!.every((x) => x == 15) &&
            s['d1'] == 15 &&
            s['d2'] == 15 &&
            filledCells == 9) {
          for (var t in _tiles) {
            t.isCorrect = true;
          }
          _markStepComplete();
        }
      }
    } else if (_scenario == 2) {
      if (_step == 0) {
        // Step 0 handled in tap listener.
      }
    } else if (_scenario == 3) {
      if (_step == 0 && _grid[4]?.val == 9) {
        _markStepComplete(); // advance to step 1
        setState(() {
          _s3Animating = true;
          _s3AnimStart = DateTime.now().millisecondsSinceEpoch;
        });
        AudioEngine.chime();
      }
      if (_step == 2 && _grid[4]?.val == 5) {
        // Just start animation. The completion is triggered at end of animation.
        setState(() {
          _s3Animating = true;
          _s3AnimStart = DateTime.now().millisecondsSinceEpoch;
        });
        AudioEngine.chime();
      }
    } else if (_scenario == 4) {
      if (_step == 0) {
        var r0 =
            [_grid[0], _grid[1], _grid[2]].where((t) => t != null).toList();
        if (r0.length == 3 && !_s4Wait) {
          _s4Wait = true;
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _markStepComplete();
              _s4Wait = false;
            }
          });
        }
      } else if (_step == 1) {
        var c2 =
            [_grid[2], _grid[5], _grid[8]].where((t) => t != null).toList();
        if (c2.length == 3 && !_s4Wait) {
          _s4Wait = true;
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _markStepComplete();
              _s4Wait = false;
            }
          });
        }
      }
    } else if (_scenario == 5) {
      if (_step == 1 && _grid[4]?.val == 6) {
        _grid[4]!.isCorrect = true;
        _markStepComplete();
      }
      if (_step == 2) {
        var s = _getRowColSums();
        int filledCells = _grid.where((c) => c != null).length;
        if (s['r']!.every((x) => x == 18) &&
            s['c']!.every((x) => x == 18) &&
            s['d1'] == 18 &&
            s['d2'] == 18 &&
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
      int maxSteps = 3;

      if (_step >= maxSteps) {
        AudioEngine.success();
        _completedScenarios.add(_scenario);
        if (_completedScenarios.length >= 5) {
          Future.delayed(
            const Duration(milliseconds: 1500),
            _showFinalSuccessDialog,
          );
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
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
    );
  }

  Map<String, dynamic> _getRowColSums() {
    List<int> r = [0, 0, 0], c = [0, 0, 0];
    int d1 = 0, d2 = 0;
    for (int i = 0; i < 9; i++) {
      if (_grid[i] != null) {
        int v = _grid[i]!.val;
        if (_scenario == 2 && _s2Animating) {
          double p = math.min(1.0, (_currentTime - _s2AnimStart) / 1500);
          if (p > 0.5)
            v =
                _s2AnimType == '+3'
                    ? _grid[i]!.originalVal + 3
                    : _grid[i]!.originalVal * 2;
        }
        int row = i ~/ 3, col = i % 3;
        r[row] += v;
        c[col] += v;
        if (row == col) d1 += v;
        if (row + col == 2) d2 += v;
      }
    }
    return {'r': r, 'c': c, 'd1': d1, 'd2': d2};
  }

  // --- Input Handling ---

  void _handlePointerDown(PointerDownEvent e, Size canvasSize) {
    Offset pt = _screenToWorld(e.localPosition, canvasSize);

    if (_scenario == 2 && !_s2Animating) {
      double gridOffsetY = -180;
      // Dial Tap
      if (pt.dx > 260 &&
          pt.dx < 360 &&
          pt.dy > gridOffsetY + 30 &&
          pt.dy < gridOffsetY + 70) {
        if (_step == 0) {
          setState(() => _s2Dial = 1);
          AudioEngine.tick();
          _markStepComplete();
        } else if (_step == 2 && _s2Dial != 2) {
          setState(() {
            _s2Dial = 2;
            for (var t in _tiles) {
              t.val = int.parse(t.id.replaceAll('t', ''));
              t.originalVal = t.val;
            }
          });
          AudioEngine.tick();
        }
        return;
      }
      // Lever Tap
      if (pt.dx > 280 &&
          pt.dx < 340 &&
          pt.dy > gridOffsetY + 90 &&
          pt.dy < gridOffsetY + 170) {
        if (_step == 1 && _s2Dial == 1) {
          setState(() {
            _s2Animating = true;
            _s2AnimStart = DateTime.now().millisecondsSinceEpoch;
            _s2AnimType = '+3';
            for (var t in _tiles) {
              t.originalVal = t.val;
            }
          });
          AudioEngine.chime();
          return;
        }
        if (_step == 2 && _s2Dial == 2) {
          setState(() {
            _s2Animating = true;
            _s2AnimStart = DateTime.now().millisecondsSinceEpoch;
            _s2AnimType = 'x2';
            for (var t in _tiles) {
              t.originalVal = t.val;
            }
          });
          AudioEngine.chime();
          return;
        }
      }
    }

    if (_scenario == 5 && _step == 0 && !_s5CalcConfirmed) {
      double x = -350;
      double y = -180 - 30; // GRID_OFFSET_Y - 30
      if (pt.dx > x + 20 &&
          pt.dx < x + 60 &&
          pt.dy > y + 90 &&
          pt.dy < y + 130) {
        setState(() => _s5CalcInput = math.max(0, _s5CalcInput - 1));
        AudioEngine.tick();
        return;
      }
      if (pt.dx > x + 100 &&
          pt.dx < x + 140 &&
          pt.dy > y + 90 &&
          pt.dy < y + 130) {
        setState(() => _s5CalcInput++);
        AudioEngine.tick();
        return;
      }
      if (_s5CalcInput == 18 &&
          pt.dx > x + 20 &&
          pt.dx < x + 140 &&
          pt.dy > y + 140 &&
          pt.dy < y + 170) {
        setState(() => _s5CalcConfirmed = true);
        AudioEngine.success();
        _markStepComplete();
        return;
      }
    }

    if (_scenario == 2) return; // No dragging in scenario 2

    // Check Tile Drag
    for (int i = _tiles.length - 1; i >= 0; i--) {
      var t = _tiles[i];
      if (t.alpha > 0 && (pt.dx - t.x).abs() < 35 && (pt.dy - t.y).abs() < 35) {
        bool isTileOnGrid = _grid.any((g) => g?.id == t.id);

        if (!isTileOnGrid) {
          if (_scenario == 3) {
            if (_step == 0 && t.val != 9) {
              AudioEngine.error();
              return;
            }
            if (_step == 1) {
              AudioEngine.error();
              return;
            }
            if (_step == 2 && t.val != 5) {
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

        for (int i = 0; i < 9; i++) {
          Rect rect = _getCellRect(i);
          if ((pt.dx - rect.center.dx).abs() < rect.width / 2 &&
              (pt.dy - rect.center.dy).abs() < rect.height / 2) {
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
        if (_hoverCellIndex != -1) {
          bool validDrop = true;

          if (_scenario == 1) {
            if (_step == 0 && _hoverCellIndex == 4 && t.val != 5) {
              validDrop = false;
            } else if (_step == 0 && _hoverCellIndex != 4) {
              validDrop = false;
            }
            if (_step == 1 && ![0, 8, 2, 6].contains(_hoverCellIndex))
              validDrop = false;
            if (_step == 1 && ![8, 2].contains(t.val)) validDrop = false;
          } else if (_scenario == 3) {
            if (_step == 0 && _hoverCellIndex == 4 && t.val != 9) {
              validDrop = false;
            } else if (_step == 0 && _hoverCellIndex != 4) {
              validDrop = false;
            }
            if (_step == 1) validDrop = false;
            if (_step == 2 && _hoverCellIndex == 4 && t.val != 5) {
              validDrop = false;
            } else if (_step == 2 && _hoverCellIndex != 4) {
              validDrop = false;
            }
          } else if (_scenario == 5) {
            if (_step == 1 && _hoverCellIndex == 4 && t.val != 6) {
              validDrop = false;
            } else if (_step == 1 && _hoverCellIndex != 4) {
              validDrop = false;
            }
          }

          if (!validDrop) {
            AudioEngine.error();
            t.tgtX = t.homeX;
            t.tgtY = t.homeY;
          } else {
            Rect rect = _getCellRect(_hoverCellIndex);
            t.tgtX = rect.center.dx;
            t.tgtY = rect.center.dy;

            if (_grid[_hoverCellIndex] != null) {
              var oldT = _grid[_hoverCellIndex]!;
              oldT.tgtX = oldT.homeX;
              oldT.tgtY = oldT.homeY;
              oldT.x = oldT.homeX;
              oldT.y = oldT.homeY;
            }
            _grid[_hoverCellIndex] = t;
            AudioEngine.snap();
            _checkStepCompletion();
          }
        } else {
          t.tgtX = t.homeX;
          t.tgtY = t.homeY;
          AudioEngine.click();
          _checkStepCompletion();
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

  void _handleScaleEnd(ScaleEndDetails details) {}

  Offset _screenToWorld(Offset screen, Size size) {
    return Offset(
      (screen.dx - size.width / 2 - _panX) / _zoom,
      (screen.dy - size.height / 2 - _panY) / _zoom,
    );
  }

  Rect _getCellRect(int index) {
    int col = index % 3;
    int row = index ~/ 3;
    double cellSize = 70;
    double gap = 8;
    double w = cellSize * 3 + gap * 2;
    double startX = -w / 2;
    double gridOffsetY = -180;
    return Rect.fromLTWH(
      startX + col * (cellSize + gap),
      gridOffsetY + (row - 1) * (cellSize + gap) - cellSize / 2,
      cellSize,
      cellSize,
    );
  }

  Widget _buildSidebarContent(BuildContext context) {
    List<Map<String, String>> stepsText = [
      {'text': t('s${_scenario}_text_1')},
      {'text': t('s${_scenario}_text_2')},
      {'text': t('s${_scenario}_text_3')},
    ];

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
            color: Colors.blue,
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
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
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
                backgroundColor: Colors.red.withValues(alpha: 0.2),
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
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            ),
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
                      ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                      : Colors.transparent,
              border: Border.all(
                color:
                    isActive
                        ? const Color(0xFF3B82F6)
                        : Colors.white.withValues(alpha: 0.1),
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
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
                                : Colors.grey.withValues(alpha: 0.5)),
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
                        stepsText[index]['text']!,
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

        if (_step >= stepsText.length)
          Container(
            key: _stepKeys[math.min(stepsText.length, _stepKeys.length - 1)],
            margin: const EdgeInsets.only(top: 8, bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
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
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.6),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(Icons.grid_on, size: 50, color: Colors.white),
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

    List<Map<String, String>> stepsHud = [
      {'hud': t('s${_scenario}_hud_1')},
      {'hud': t('s${_scenario}_hud_2')},
      {'hud': t('s${_scenario}_hud_3')},
    ];

    String currentHudText = "";
    if (_step < stepsHud.length) {
      currentHudText = stepsHud[_step]['hud']!;
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
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _isSidebarOpen ? sidebarWidth : 0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    border: Border(
                      right: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
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

                                  if (_scenario == 4 &&
                                      _step == 2 &&
                                      !_s4Explained)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _s4Explained = true;
                                          _s4Animating = true;
                                          _s4AnimStart =
                                              DateTime.now()
                                                  .millisecondsSinceEpoch;
                                        });
                                        AudioEngine.success();
                                        Future.delayed(
                                          const Duration(seconds: 9),
                                          () {
                                            if (mounted) {
                                              setState(
                                                () => _s4Animating = false,
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
                                    color: const Color(
                                      0xFF1E293B,
                                    ).withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.blue.withValues(alpha: 0.5),
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
                  backgroundColor: Colors.black.withValues(alpha: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.orange.withValues(alpha: 0.8),
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

// --- CUSTOM PAINTER FOR GRID, MACHINES, TILES ---

class _GridPainter extends CustomPainter {
  final _MagicSquaresLabState state;

  _GridPainter({required this.state}) : super(repaint: state._repaintNotifier);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(
      size.width / 2 + state._panX,
      size.height / 2 + state._panY,
    );
    canvas.scale(state._zoom, state._zoom);

    // Grid lines background
    final Paint gridLinePaint =
        Paint()
          ..color = const Color(0xFF94A3B8).withValues(alpha: 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    for (double i = -2000; i < 2000; i += 40) {
      canvas.drawLine(Offset(i, -2000), Offset(i, 2000), gridLinePaint);
      canvas.drawLine(Offset(-2000, i), Offset(2000, i), gridLinePaint);
    }

    if (state._scenario == 2) _drawS2Machine(canvas);
    if (state._scenario == 4) _drawS4Scales(canvas);
    if (state._scenario == 5) _drawS5Calculator(canvas);

    _drawGrid(canvas);

    if (state._scenario == 1 || state._scenario == 2 || state._scenario == 5) {
      _drawScales(canvas);
    }

    if (state._scenario == 3) _drawS3Animations(canvas);

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

    canvas.restore();
  }

  void _drawGrid(Canvas canvas) {
    final Paint cellBgPaint =
        Paint()..color = const Color(0xFF94A3B8).withValues(alpha: 0.1);
    final Paint cellBorderPaint =
        Paint()
          ..color = const Color(0xFF94A3B8).withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    final Paint hoverBgPaint =
        Paint()..color = Colors.blue.withValues(alpha: 0.2);
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
    }

    if (state._scenario == 1 &&
        state._grid[0]?.val == 8 &&
        state._grid[4]?.val == 5 &&
        state._grid[8]?.val == 2) {
      Paint starPaint =
          Paint()
            ..color = Colors.green.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6;
      Rect r0 = state._getCellRect(0);
      Rect r8 = state._getCellRect(8);
      canvas.drawLine(r0.center, r8.center, starPaint);
    }
  }

  void _drawTile(Canvas canvas, TileData tile, bool isDragged) {
    canvas.save();
    double scale = isDragged ? 1.1 : 1.0;
    canvas.translate(tile.x, tile.y);
    canvas.scale(scale, scale);

    double size = 60;
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
    Color borderColor = tile.isCorrect ? Colors.green : Colors.blue;

    if (state._scenario == 2 && state._s2Animating && state._step > 0) {
      double p = math.min(
        1.0,
        (state._currentTime - state._s2AnimStart) / 1500,
      );
      if (p < 0.5) borderColor = Colors.purple;
    }

    Paint borderPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = tile.isCorrect ? 4 : 2;
    Paint innerPaint = Paint()..color = const Color(0xFF334155);

    canvas.drawRRect(rrect, basePaint);
    canvas.drawRRect(rrect, borderPaint);
    canvas.drawRRect(innerRRect, innerPaint);

    int displayVal = tile.val;
    if (state._scenario == 2 && state._s2Animating) {
      double p = math.min(
        1.0,
        (state._currentTime - state._s2AnimStart) / 1500,
      );
      if (p > 0.5) {
        displayVal =
            state._s2AnimType == '+3'
                ? tile.originalVal + 3
                : tile.originalVal * 2;
      }
    }

    TextPainter tp = TextPainter(
      text: TextSpan(
        text: '$displayVal',
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

    canvas.restore();
  }

  void _drawScales(Canvas canvas) {
    var sums = state._getRowColSums();
    double cellSize = 70;
    double gap = 8;
    double w = cellSize * 3 + gap * 2;
    double startX = -w / 2;
    double scalesY = 60;

    int tgt = 15;
    if (state._scenario == 2) {
      if (state._s2Animating) {
        double p = math.min(
          1.0,
          (state._currentTime - state._s2AnimStart) / 1500,
        );
        tgt =
            p > 0.5
                ? (state._step == 1 ? 18 : 30)
                : (state._step == 1 ? 15 : 18);
      } else {
        tgt = state._step == 0 ? 15 : (state._step == 2 ? 18 : 30);
      }
    }
    if (state._scenario == 5)
      tgt = state._s5CalcConfirmed ? state._s5CalcInput : 0;

    int rVal = 0, cVal = 0, dVal = 0;
    for (int i = 0; i < 3; i++) {
      if (sums['r']![i] > 0) rVal = math.max(rVal, sums['r']![i]);
    }
    for (int i = 0; i < 3; i++) {
      if (sums['c']![i] > 0) cVal = math.max(cVal, sums['c']![i]);
    }
    dVal = math.max(sums['d1'], sums['d2']);

    _drawSingleScale(
      canvas,
      startX + 30,
      scalesY,
      state.t('rowsScale'),
      rVal,
      tgt,
    );
    _drawSingleScale(
      canvas,
      startX + 130,
      scalesY,
      state.t('colsScale'),
      cVal,
      tgt,
    );
    _drawSingleScale(
      canvas,
      startX + 230,
      scalesY,
      state.t('diagsScale'),
      dVal,
      tgt,
    );
  }

  void _drawSingleScale(
    Canvas canvas,
    double x,
    double y,
    String label,
    int current,
    int target,
  ) {
    double diff = (current - target).toDouble();
    double angle = math.max(-20.0, math.min(20.0, diff * 5)) * math.pi / 180;
    if (target == 0 || current == 0) angle = 20 * math.pi / 180;

    canvas.save();
    canvas.translate(x, y);

    // Stand
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-15, 0, 30, 60),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-25, 50, 50, 10),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF334155),
    );

    // Rotating Arm
    canvas.translate(0, 10);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-40, -4, 80, 8),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF64748B),
    );

    Paint wirePaint =
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Left Pan
    canvas.save();
    canvas.translate(-35, 0);
    canvas.rotate(-angle);
    canvas.drawLine(Offset.zero, const Offset(-15, 30), wirePaint);
    canvas.drawLine(Offset.zero, const Offset(15, 30), wirePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-15, 30, 30, 6),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.blue,
    );
    if (current > 0)
      _drawText(
        canvas,
        '$current',
        const Offset(0, 20),
        Colors.white,
        14,
        TextAlign.center,
      );
    canvas.restore();

    // Right Pan
    canvas.save();
    canvas.translate(35, 0);
    canvas.rotate(-angle);
    canvas.drawLine(Offset.zero, const Offset(-15, 30), wirePaint);
    canvas.drawLine(Offset.zero, const Offset(15, 30), wirePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-15, 30, 30, 6),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.red,
    );
    if (target > 0)
      _drawText(
        canvas,
        '$target',
        const Offset(0, 20),
        Colors.white,
        14,
        TextAlign.center,
      );
    canvas.restore();

    canvas.drawCircle(Offset.zero, 4, Paint()..color = Colors.white);
    canvas.restore();

    _drawText(
      canvas,
      label,
      Offset(x, y + 80),
      const Color(0xFF94A3B8),
      12,
      TextAlign.center,
    );

    if (target > 0 && current > 0) {
      String status =
          current == target
              ? 'Balanced'
              : (current < target ? state.t('tooLight') : state.t('tooHeavy'));
      Color c = current == target ? Colors.green : Colors.red;
      _drawText(canvas, status, Offset(x, y + 95), c, 12, TextAlign.center);
    }
  }

  void _drawS2Machine(Canvas canvas) {
    double x = 240;
    double y = -200; // GRID_OFFSET_Y - 20

    if (state._s2Animating) {
      double p = math.min(
        1.0,
        (state._currentTime - state._s2AnimStart) / 1500,
      );
      if (p < 0.8) {
        canvas.save();
        Paint laser =
            Paint()
              ..color = Colors.purple.withValues(alpha: 1 - p)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4;
        for (var t in state._grid) {
          if (t != null) {
            canvas.drawLine(Offset(x + 50, y + 100), Offset(t.x, t.y), laser);
          }
        }
        canvas.restore();
      } else if (p == 1.0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.mounted) {
            state.updateState(() {
              state._s2Animating = false;
              for (var t in state._tiles) {
                t.val =
                    state._s2AnimType == '+3'
                        ? t.originalVal + 3
                        : t.originalVal * 2;
                t.originalVal = t.val;
              }
              state._markStepComplete();
            });
          }
        });
      }
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, 140, 200),
        const Radius.circular(16),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, 140, 200),
        const Radius.circular(16),
      ),
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    _drawText(
      canvas,
      "Transformer",
      Offset(x + 70, y + 30),
      Colors.white,
      16,
      TextAlign.center,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 20, y + 50, 100, 40),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );
    String dialText =
        state._s2Dial == 0
            ? state.t('dialOff')
            : (state._s2Dial == 1 ? "+ 3" : "x 2");
    Color dCol = state._s2Dial > 0 ? Colors.green : Colors.grey;
    _drawText(
      canvas,
      dialText,
      Offset(x + 70, y + 70),
      dCol,
      24,
      TextAlign.center,
    );

    double leverY = state._s2Animating ? 40 : 0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 50, y + 110, 40, 80),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF475569),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 40, y + 110 + leverY, 60, 20),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.red,
    );
  }

  void _drawS3Animations(Canvas canvas) {
    double gridOffsetY = -180;
    if (state._step == 1 && state._s3Animating) {
      double p = math.min(
        1.0,
        (state._currentTime - state._s3AnimStart) / 3500,
      );
      Rect cRect = state._getCellRect(4);
      Paint p1 =
          Paint()
            ..color = Colors.red.withValues(alpha: 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4;
      double s = 70 + 8;

      canvas.drawLine(
        Offset(cRect.center.dx - s * 1.5, cRect.center.dy),
        Offset(cRect.center.dx + s * 1.5, cRect.center.dy),
        p1,
      );
      canvas.drawLine(
        Offset(cRect.center.dx, cRect.center.dy - s * 1.5),
        Offset(cRect.center.dx, cRect.center.dy + s * 1.5),
        p1,
      );
      canvas.drawLine(
        Offset(cRect.center.dx - s * 1.5, cRect.center.dy - s * 1.5),
        Offset(cRect.center.dx + s * 1.5, cRect.center.dy + s * 1.5),
        p1,
      );
      canvas.drawLine(
        Offset(cRect.center.dx + s * 1.5, cRect.center.dy - s * 1.5),
        Offset(cRect.center.dx - s * 1.5, cRect.center.dy + s * 1.5),
        p1,
      );

      _drawText(
        canvas,
        '15 - 9 = 6',
        Offset(0, gridOffsetY - 140),
        Colors.red,
        24,
        TextAlign.center,
      );
      _drawText(
        canvas,
        'Searching pairs for 6...',
        Offset(0, gridOffsetY - 110),
        Colors.red,
        20,
        TextAlign.center,
      );

      if (p > 0.3) {
        _drawText(
          canvas,
          '(1,5) = 6',
          Offset(-80, gridOffsetY - 70),
          Colors.red,
          20,
          TextAlign.center,
        );
        _drawText(
          canvas,
          '✔',
          Offset(-20, gridOffsetY - 70),
          Colors.green,
          20,
          TextAlign.center,
        );
      }
      if (p > 0.5) {
        _drawText(
          canvas,
          '(2,4) = 6',
          Offset(80, gridOffsetY - 70),
          Colors.red,
          20,
          TextAlign.center,
        );
        _drawText(
          canvas,
          '✔',
          Offset(140, gridOffsetY - 70),
          Colors.green,
          20,
          TextAlign.center,
        );
      }
      if (p > 0.8) {
        _drawText(
          canvas,
          'IMPOSSIBLE!',
          Offset(0, gridOffsetY),
          Colors.red,
          32,
          TextAlign.center,
        );
        Paint xPaint =
            Paint()
              ..color = Colors.red
              ..style = PaintingStyle.stroke
              ..strokeWidth = 8;
        canvas.drawLine(
          Offset(-100, gridOffsetY - 100),
          Offset(100, gridOffsetY + 100),
          xPaint,
        );
        canvas.drawLine(
          Offset(100, gridOffsetY - 100),
          Offset(-100, gridOffsetY + 100),
          xPaint,
        );
      }

      if (p == 1.0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.mounted) {
            state.updateState(() {
              state._s3Animating = false;
              if (state._grid[4] != null) {
                state._grid[4]!.tgtX = state._grid[4]!.homeX;
                state._grid[4]!.tgtY = state._grid[4]!.homeY;
                state._grid[4] = null;
              }
              state._markStepComplete();
            });
          }
        });
      }
    } else if (state._step == 2 && state._s3Animating) {
      double p = math.min(
        1.0,
        (state._currentTime - state._s3AnimStart) / 4000,
      );
      Rect cRect = state._getCellRect(4);
      Paint p1 =
          Paint()
            ..color = Colors.green.withValues(alpha: 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4;
      double s = 70 + 8;

      canvas.drawLine(
        Offset(cRect.center.dx - s * 1.5, cRect.center.dy),
        Offset(cRect.center.dx + s * 1.5, cRect.center.dy),
        p1,
      );
      canvas.drawLine(
        Offset(cRect.center.dx, cRect.center.dy - s * 1.5),
        Offset(cRect.center.dx, cRect.center.dy + s * 1.5),
        p1,
      );
      canvas.drawLine(
        Offset(cRect.center.dx - s * 1.5, cRect.center.dy - s * 1.5),
        Offset(cRect.center.dx + s * 1.5, cRect.center.dy + s * 1.5),
        p1,
      );
      canvas.drawLine(
        Offset(cRect.center.dx + s * 1.5, cRect.center.dy - s * 1.5),
        Offset(cRect.center.dx - s * 1.5, cRect.center.dy + s * 1.5),
        p1,
      );

      _drawText(
        canvas,
        '15 - 5 = 10',
        Offset(0, gridOffsetY - 140),
        Colors.green,
        24,
        TextAlign.center,
      );
      _drawText(
        canvas,
        'Searching pairs for 10...',
        Offset(0, gridOffsetY - 110),
        Colors.green,
        20,
        TextAlign.center,
      );

      if (p > 0.2) {
        _drawText(
          canvas,
          '(1,9)',
          Offset(-120, gridOffsetY - 70),
          Colors.green,
          20,
          TextAlign.center,
        );
        _drawText(
          canvas,
          '✔',
          Offset(-70, gridOffsetY - 70),
          Colors.green,
          20,
          TextAlign.center,
        );
      }
      if (p > 0.4) {
        _drawText(
          canvas,
          '(2,8)',
          Offset(-40, gridOffsetY - 70),
          Colors.green,
          20,
          TextAlign.center,
        );
        _drawText(
          canvas,
          '✔',
          Offset(10, gridOffsetY - 70),
          Colors.green,
          20,
          TextAlign.center,
        );
      }
      if (p > 0.6) {
        _drawText(
          canvas,
          '(3,7)',
          Offset(40, gridOffsetY - 70),
          Colors.green,
          20,
          TextAlign.center,
        );
        _drawText(
          canvas,
          '✔',
          Offset(90, gridOffsetY - 70),
          Colors.green,
          20,
          TextAlign.center,
        );
      }
      if (p > 0.8) {
        _drawText(
          canvas,
          '(4,6)',
          Offset(120, gridOffsetY - 70),
          Colors.green,
          20,
          TextAlign.center,
        );
        _drawText(
          canvas,
          '✔',
          Offset(170, gridOffsetY - 70),
          Colors.green,
          20,
          TextAlign.center,
        );
      }

      if (p > 0.9) {
        _drawText(
          canvas,
          'POSSIBLE!',
          Offset(0, gridOffsetY),
          Colors.green,
          40,
          TextAlign.center,
        );
      }

      if (p == 1.0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.mounted) {
            state.updateState(() {
              state._s3Animating = false;
              state._markStepComplete();
            });
          }
        });
      }
    }
  }

  void _drawS4Scales(Canvas canvas) {
    var sums = state._getRowColSums();
    double gridOffsetY = -180;

    _drawSingleScale(canvas, -240, gridOffsetY - 40, "Row 1", sums['r'][0], 5);
    _drawSingleScale(canvas, 240, gridOffsetY + 100, "Col 3", sums['c'][2], 26);

    if (state._s4Animating) {
      int elapsed = state._currentTime - state._s4AnimStart;

      if (elapsed < 3000) {
        canvas.drawRect(
          Rect.fromLTWH(-215, gridOffsetY - 125, 250, 78),
          Paint()
            ..color = Colors.amber
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
        _drawText(
          canvas,
          '1+2+3=6 (${state.t('minPossible')})',
          Offset(-80, gridOffsetY - 145),
          Colors.amber,
          20,
          TextAlign.center,
        );
      } else if (elapsed < 6000) {
        canvas.drawRect(
          Rect.fromLTWH(35, gridOffsetY - 125, 78, 250),
          Paint()
            ..color = Colors.amber
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
        _drawText(
          canvas,
          '7+8+9=24 (${state.t('maxPossible')})',
          Offset(80, gridOffsetY - 145),
          Colors.amber,
          20,
          TextAlign.center,
        );
      } else {
        Paint xp =
            Paint()
              ..color = Colors.red
              ..style = PaintingStyle.stroke
              ..strokeWidth = 8;
        canvas.drawLine(
          Offset(-260, gridOffsetY - 60),
          Offset(-220, gridOffsetY - 20),
          xp,
        );
        canvas.drawLine(
          Offset(-220, gridOffsetY - 60),
          Offset(-260, gridOffsetY - 20),
          xp,
        );
        canvas.drawLine(
          Offset(220, gridOffsetY + 80),
          Offset(260, gridOffsetY + 120),
          xp,
        );
        canvas.drawLine(
          Offset(260, gridOffsetY + 80),
          Offset(220, gridOffsetY + 120),
          xp,
        );
        _drawText(
          canvas,
          state.t('outOfRange'),
          Offset(0, gridOffsetY - 160),
          Colors.red,
          26,
          TextAlign.center,
        );
      }

      if (elapsed > 9000) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.mounted) {
            state.updateState(() {
              state._s4Animating = false;
              state._markStepComplete();
            });
          }
        });
      }
    }
  }

  void _drawS5Calculator(Canvas canvas) {
    double x = -350;
    double y = -210; // GRID_OFFSET_Y - 30

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, 160, 160),
        const Radius.circular(16),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, 160, 160),
        const Radius.circular(16),
      ),
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 10, y + 20, 140, 50),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );
    _drawText(
      canvas,
      '${state._s5CalcInput}',
      Offset(x + 80, y + 45),
      Colors.green,
      36,
      TextAlign.center,
    );

    if (!state._s5CalcConfirmed && state._step == 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 20, y + 90, 40, 40),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFF475569),
      );
      _drawText(
        canvas,
        '-',
        Offset(x + 40, y + 110),
        Colors.white,
        24,
        TextAlign.center,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 100, y + 90, 40, 40),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFF475569),
      );
      _drawText(
        canvas,
        '+',
        Offset(x + 120, y + 110),
        Colors.white,
        24,
        TextAlign.center,
      );

      if (state._s5CalcInput == 18) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 20, y + 140, 120, 30),
            const Radius.circular(4),
          ),
          Paint()..color = Colors.purple,
        );
        _drawText(
          canvas,
          state.t('confirmBtn'),
          Offset(x + 80, y + 155),
          Colors.white,
          14,
          TextAlign.center,
        );
      }
    } else {
      _drawText(
        canvas,
        "LOCKED",
        Offset(x + 80, y + 110),
        Colors.purple,
        16,
        TextAlign.center,
      );
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
