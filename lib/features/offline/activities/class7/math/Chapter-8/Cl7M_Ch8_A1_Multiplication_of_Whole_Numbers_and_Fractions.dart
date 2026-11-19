// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

// ----------------------------------------------------------------------
// Please ensure you have the following in your pubspec.yaml:
// dependencies:
//   flutter:
//     sdk: flutter
//   audioplayers: ^5.2.1
// ----------------------------------------------------------------------

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FractionFactoryApp());
}

class FractionFactoryApp extends StatelessWidget {
  const FractionFactoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Fraction Factory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        primaryColor: const Color(0xFF6366f1),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const MultiplicationofWholeNumbersandFractions(),
    );
  }
}

// --- DATA MODELS ---

class Jug {
  int id;
  double x, y;
  double fill;
  String state; // 'pile', 'drag', 'under_tap', 'done', 'drag_pour', 'poured'
  Jug(this.id, this.x, this.y, this.fill, this.state);
}

class Stone {
  String type; // 'whole', 'quarter', 'half'
  double x, y;
  Stone(this.type, this.x, this.y);
}

// --- LOCALIZATION ---

const Map<String, Map<String, String>> translations = {
  'en': {
    'appTitle': "The Fraction Factory: Multiplying Wholes and Parts",
    'appSubtitle': "Class 7 • WORKING WITH FRACTIONS",
    'enterLab': "Enter Lab",
    'objectiveLbl': "Mission Objective:",
    'stepLabel': "STEP",
    'doneBtn': "I'm Done",
    'nextBtn': "Next Step",
    'cutBtn': "Cut Ribbon",
    'completed': "Completed!",
    'successTitle': "Fraction Master!",
    'successDesc':
        "You successfully mastered multiplying whole numbers and fractions!",
    'restartLab': "Restart Lab",
    'selectScenario': "Select Scenario",
    'nextScenario': "Next Challenge",

    's1_sugar': "SUGAR",
    's1_canvas_eq1': "1/4 + 1/4 + 1/4 = 3/4",
    's1_canvas_eq2': "3 × 1/4 = 3/4",
    's2_eq': "2/5 × 3 = 6/5 = 1 1/5",
    's3_eq': "2 × 1 1/4 = 2 1/2",
    's4_eq': "4 × 2/3 = 8/3 = 2 2/3",
    's5_eq': "3/4 × 2 = 6/4 = 1 1/2",
    'denom': "DENOM",
    'numer': "NUMER",
    's4_juice': "JUICE",
    's2_choc': "CHOCOLATE",
    's2_tool': "Fractionator 5000",
    's3_wand': "Wand Tool",
    's3_palette': "STONES",
    's4_oops': "Oops, too much!",
    's5_spool': "SPOOL",
    's5_tool': "Fraction Cutter",
    's5_mat_0m': "0m",
    's5_mat_1m': "1m",
    's5_mat_2m': "2m",
    's5_project': "Project Box",

    's1_title': "1. The Recipe Multiplier",
    's1_obj':
        "To visually understand Whole Number × Fraction as repeated addition by making 3 batches of a recipe.",
    's1_step1':
        "Task: The recipe shows 1 batch requires 1/4 cup of sugar. Your mission is to measure sugar for 3 batches. DRAG the 1/4 Measuring Cup to the sugar bag to fill it.\nObservation: The 1/4 Measuring Cup is filled with a white, sugary substance.\nLearnt: We have measured exactly 1/4 cup of sugar for one batch.",
    's1_step2':
        "Task: DRAG the filled 1/4 Measuring Cup and DROP it over the large Mixing Bowl to pour the sugar in.\nObservation: The sugar pours into the bowl. The gauge rises to the 1/4 mark.\nLearnt: The bowl now contains 1/4 cup of sugar.",
    's1_step3':
        "Task: That's 1 batch down, 2 to go! Repeat the process for the second batch. DRAG the 1/4 Measuring Cup to the sugar, then to the Mixing Bowl.\nObservation: The bowl's measurement gauge rises from 1/4 to 2/4 (which simplifies to 1/2).\nLearnt: 1/4 + 1/4 = 2/4 or 1/2.",
    's1_step4':
        "Task: One more batch to go! Measure and pour the sugar for the third and final batch.\nObservation: The bowl's measurement gauge rises from 2/4 to 3/4.\nLearnt: We have successfully added three 1/4 cups of sugar.",
    's1_sum': "1/4 + 1/4 + 1/4 = 3/4. This is the same as: 3 × 1/4 = 3/4.",

    's2_title': "2. The Chocolate Divider",
    's2_obj':
        "To visually understand Fraction × Whole Number as finding a part of a quantity. Find 2/5 of 3 chocolate bars.",
    's2_step1':
        "Task: We need to give a friend 2/5 of our chocolate. DRAG the 3 Chocolate Bars from the box onto the Cutting Board.\nObservation: Three distinct chocolate bars are on the board.\nLearnt: This is our starting 'whole' quantity: 3.",
    's2_step2':
        "Task: To find 2/5, divide the bars into 5 equal shares. DRAG the Fractionator machine over the bars. TAP the denominator dial '+' to set it to 5.\nObservation: The machine projects lines, splitting the 3 bars into 5 equal vertical sections.\nLearnt: The denominator divides the whole quantity.",
    's2_step3':
        "Task: We need 2 parts. TAP the numerator dial '+' to set it to 2.\nObservation: The first 2 vertical columns are highlighted.\nLearnt: The numerator selects the parts we want.",
    's2_step4':
        "Task: DRAG the highlighted pieces to the Friend's Plate.\nObservation: You took 6 small squares in total.\nLearnt: The highlighted portion is 2/5 of the total chocolate.",
    's2_sum':
        "We divided 3 bars into 5 parts and took 2. 2/5 × 3 = 6/5. This equals 1 full bar and 1/5 of another (1 1/5).",

    's3_title': "3. Paving the Garden Path",
    's3_obj':
        "To multiply a whole number by a mixed fraction (2 × 1 1/4) using repeated addition.",
    's3_step1':
        "Task: DRAG 1 Whole Stone and 1 Quarter Stone to the first Path Outline.\nObservation: One section of the path is paved.\nLearnt: This represents 1 and 1/4.",
    's3_step2':
        "Task: Build the second section. DRAG stones to the second Path Outline.\nObservation: Two sections are now paved.\nLearnt: We have added (1 1/4) + (1 1/4).",
    's3_step3':
        "Task: DRAG the Combiner Tool (wand) over all the stones to simplify them.\nObservation: The two Quarter Stones merge into one Half Stone.\nLearnt: 1/4 + 1/4 = 1/2.",
    's3_sum':
        "2 × 1 1/4 = 2 1/2. We can also calculate it as improper fractions: 2 × 5/4 = 10/4 = 2 2/4 = 2 1/2.",

    's4_title': "4. Party Juice Prep",
    's4_obj':
        "To calculate 4 × 2/3 by physically measuring and combining quantities.",
    's4_step1':
        "Task: We need 4 jugs filled to 2/3. DRAG an Empty Jug under the Juice Dispenser.\nObservation: The jug is ready to be filled.\nLearnt: The target is the 2/3 mark.",
    's4_step2':
        "Task: TAP the Dispenser Handle ONCE to start filling. TAP IT AGAIN to stop exactly at 2/3 mark.\nObservation: The jug is filled.\nLearnt: One jug contains 2/3 of a unit.",
    's4_step3':
        "Task: Fill the other 3 jugs. Then, DRAG all 4 jugs to the large Measuring Cylinder.\nObservation: All juice is combined in the cylinder.\nLearnt: We are calculating 4 times 2/3.",
    's4_sum':
        "The final level is 8/3. So, 4 × 2/3 = 8/3 (which is 2 2/3). You successfully prepped the juice!",

    's5_title': "5. The Ribbon Cutter",
    's5_obj':
        "To calculate 3/4 × 2 by setting up a tool to find a fractional part of a quantity.",
    's5_step1':
        "Task: DRAG the two Ribbons from the SPOOL onto the Cutting Mat.\nObservation: The ribbons form a continuous 2-meter length.\nLearnt: Our starting quantity is 2 wholes.",
    's5_step2':
        "Task: To find 3/4, use the tool dials. TAP '+' to set Denominator to 4, Numerator to 3.\nObservation: The tool highlights 3 out of 4 parts.\nLearnt: 3/4 of the total length is selected.",
    's5_step3':
        "Task: DRAG the configured Fraction Cutter down over the ribbons. TAP the 'Cut Ribbon' button. Then DRAG the highlighted pieces to the Project Box.\nObservation: The cut pieces are moved to the box.\nLearnt: The selected part is extracted.",
    's5_sum':
        "You took 3 pieces, each 1/2 meter long. Total length = 3/2 meters. So, 3/4 × 2 = 6/4 = 3/2 (or 1 1/2).",
  },
  'hi': {
    'appTitle': "द फ्रैक्शन फैक्ट्री: गुणा",
    'appSubtitle': "कक्षा 7 • WORKING WITH FRACTIONS",
    'enterLab': "लैब में प्रवेश करें",
    'objectiveLbl': "मिशन उद्देश्य:",
    'stepLabel': "कदम",
    'doneBtn': "मैं कर चुका हूँ",
    'nextBtn': "अगला",
    'cutBtn': "रिबन काटें",
    'completed': "पूरा हुआ!",
    'successTitle': "भिन्न के उस्ताद!",
    'successDesc':
        "आपने संपूर्ण संख्याओं और भिन्नों को गुणा करने में सफलतापूर्वक महारत हासिल कर ली है!",
    'restartLab': "लैब फिर से शुरू करें",
    'selectScenario': "दृश्य चुनें",
    'nextScenario': "अगली चुनौती",

    's1_sugar': "चीनी",
    's1_canvas_eq1': "1/4 + 1/4 + 1/4 = 3/4",
    's1_canvas_eq2': "3 × 1/4 = 3/4",
    's2_eq': "2/5 × 3 = 6/5 = 1 1/5",
    's3_eq': "2 × 1 1/4 = 2 1/2",
    's4_eq': "4 × 2/3 = 8/3 = 2 2/3",
    's5_eq': "3/4 × 2 = 6/4 = 1 1/2",
    'denom': "हर",
    'numer': "अंश",
    's4_juice': "जूस",
    's2_choc': "चॉकलेट",
    's2_tool': "Fractionator 5000",
    's3_wand': "छड़ी उपकरण",
    's3_palette': "पत्थर",
    's4_oops': "उफ़, बहुत ज़्यादा!",
    's5_spool': "स्पूल",
    's5_tool': "फ्रैक्शन कटर",
    's5_mat_0m': "0 मी",
    's5_mat_1m': "1 मी",
    's5_mat_2m': "2 मी",
    's5_project': "प्रोजेक्ट बॉक्स",

    's1_title': "1. पकाने की विधि गुणक",
    's1_obj':
        "एक नुस्खा के 3 बैच बनाकर बार-बार जोड़ने के रूप में पूर्ण संख्या × भिन्न को समझने के लिए।",
    's1_step1':
        "कार्य निर्देश: नुस्खा बताता है कि 1 बैच के लिए 1/4 कप चीनी की आवश्यकता होती है। 1/4 मापने वाले कप को चीनी की थैली में खींचें और भरें।\nअवलोकन: 1/4 मापने वाला कप चीनी से भर गया है।\nसीखा: हमने एक बैच के लिए 1/4 कप चीनी मापी है।",
    's1_step2':
        "कार्य निर्देश: भरे हुए कप को खींचें और इसे बड़े मिक्सिंग बाउल के ऊपर छोड़ दें।\nअवलोकन: चीनी कटोरे में गिरती है। कटोरे का गेज 1/4 निशान तक बढ़ जाता है।\nसीखा: कटोरे में अब 1/4 कप चीनी है।",
    's1_step3':
        "कार्य निर्देश: दूसरे बैच के लिए दोहराएं: कप को चीनी पर खींचें, फिर कटोरे में।\nअवलोकन: गेज 2/4 (1/2) तक बढ़ जाता है।\nसीखा: 1/4 + 1/4 = 2/4 या 1/2।",
    's1_step4':
        "कार्य निर्देश: तीसरे और अंतिम बैच के लिए चीनी मापें और डालें।\nअवलोकन: गेज 3/4 तक बढ़ जाता है।\nसीखा: हमने सफलतापूर्वक 1/4 कप चीनी तीन बार मिला दी है।",
    's1_sum': "1/4 + 1/4 + 1/4 = 3/4। यह इसके समान है: 3 × 1/4 = 3/4।",

    's2_title': "2. चॉकलेट डिवाइडर",
    's2_obj': "3 चॉकलेट बार के 2/5 का पता लगाएं।",
    's2_step1':
        "कार्य निर्देश: 3 चॉकलेट बार को कटिंग बोर्ड पर खींचें।\nअवलोकन: तीन बार बोर्ड पर हैं।\nसीखा: यह हमारी शुरुआती पूर्ण मात्रा है: 3।",
    's2_step2':
        "कार्य निर्देश: बार के ऊपर Fractionator मशीन खींचें। हर डायल को 5 पर सेट करें।\nअवलोकन: मशीन 3 बार को 5 समान लंबवत वर्गों में विभाजित करती है।\nसीखा: हर पूरे को विभाजित करता है।",
    's2_step3':
        "कार्य निर्देश: अंश डायल को 2 पर सेट करें।\nअवलोकन: पहले 2 लंबवत कॉलम हाइलाइट किए गए हैं।\nसीखा: अंश हमारी जरूरत के हिस्सों का चयन करता है।",
    's2_step4':
        "कार्य निर्देश: हाइलाइट किए गए टुकड़ों को प्लेट में खींचें।\nअवलोकन: आपने कुल 6 छोटे वर्ग लिए।\nसीखा: यह भाग कुल चॉकलेट का 2/5 है।",
    's2_sum':
        "हमने 3 बार को 5 भागों में विभाजित किया और 2 लिया। 2/5 × 3 = 6/5। यह 1 पूर्ण बार और दूसरे का 1/5 (1 1/5) है।",

    's3_title': "3. गार्डन पथ",
    's3_obj':
        "बार-बार जोड़ने का उपयोग करके एक मिश्रित अंश (2 × 1 1/4) को पूर्ण संख्या से गुणा करें।",
    's3_step1':
        "कार्य निर्देश: 1 पूरे पत्थर और 1 चौथाई पत्थर को पहले पथ की रूपरेखा में खींचें।\nअवलोकन: पथ का एक खंड पक्का है।\nसीखा: यह 1 और 1/4 का प्रतिनिधित्व करता है।",
    's3_step2':
        "कार्य निर्देश: दूसरे अनुभाग का निर्माण करें। पत्थरों को दूसरी रूपरेखा पर खींचें।\nअवलोकन: अब दो खंड पक्के हैं।\nसीखा: हमने (1 1/4) + (1 1/4) जोड़ा है।",
    's3_step3':
        "कार्य निर्देश: उन्हें सरल बनाने के लिए सभी पत्थरों के ऊपर कॉम्बिनर टूल को खींचें।\nअवलोकन: दो चौथाई पत्थर एक आधे पत्थर में विलीन हो जाते हैं।\nसीखा: 1/4 + 1/4 = 1/2।",
    's3_sum': "2 × 1 1/4 = 2 1/2।",

    's4_title': "4. पार्टी जूस की तैयारी",
    's4_obj': "मात्राओं को मापकर और मिलाकर 4 × 2/3 की गणना करें।",
    's4_step1':
        "कार्य निर्देश: जूस डिस्पेंसर के नीचे एक खाली जग खींचें।\nअवलोकन: जग भरने के लिए तैयार है।\nसीखा: लक्ष्य 2/3 का निशान है।",
    's4_step2':
        "कार्य निर्देश: डिस्पेंसर हैंडल पर टैप करें। 2/3 निशान पर रोकें।\nअवलोकन: जग पूरी तरह से भर गया है।\nसीखा: एक जग में 2/3 इकाई होती है।",
    's4_step3':
        "कार्य निर्देश: अन्य 3 जग भरें। फिर, सभी 4 जगों को बड़े सिलेंडर में खींचें।\nअवलोकन: सारा रस सिलेंडर में मिल गया है।\nसीखा: हम 4 गुना 2/3 की गणना कर रहे हैं।",
    's4_sum': "अंतिम स्तर 8/3 है। तो, 4 × 2/3 = 8/3 (2 2/3)।",

    's5_title': "5. रिबन कटर",
    's5_obj': "3/4 × 2 की गणना करें।",
    's5_step1':
        "कार्य निर्देश: स्पूल से रिबन को कटिंग मैट पर खींचें।\nअवलोकन: रिबन 2 मीटर लंबाई बनाते हैं।\nसीखा: हमारी शुरुआती मात्रा 2 पूर्ण है।",
    's5_step2':
        "कार्य निर्देश: हर को 4, अंश को 3 पर सेट करें।\nअवलोकन: 3/4 का चयन किया गया है।\nसीखा: कुल लंबाई का 3/4 चुना गया है।",
    's5_step3':
        "कार्य निर्देश: मशीन खींचें। 'रिबन काटें' बटन पर क्लिक करें। फिर हाइलाइट किए गए टुकड़ों को प्रोजेक्ट बॉक्स में खींचें।\nअवलोकन: कटे हुए टुकड़ों को बॉक्स में ले जाया जाता है।\nसीखा: चयनित भाग निकाला जाता है।",
    's5_sum': "कुल लंबाई = 3/2 मीटर। तो, 3/4 × 2 = 6/4 = 3/2 (1 1/2)।",
  },
};

// --- MAIN SCREEN ---

class MultiplicationofWholeNumbersandFractions extends StatefulWidget {
  const MultiplicationofWholeNumbersandFractions({super.key});

  @override
  State<MultiplicationofWholeNumbersandFractions> createState() =>
      _MultiplicationofWholeNumbersandFractionsState();
}

class _MultiplicationofWholeNumbersandFractionsState
    extends State<MultiplicationofWholeNumbersandFractions>
    with SingleTickerProviderStateMixin {
  String _lang = 'en';
  bool _isSidebarOpen = true;
  int _scenario = 1;
  String _phase = 'init';

  double _zoom = 1.0;
  double _baseZoom = 1.0;
  Offset _pan = const Offset(0, 20);

  // S1
  Offset _s1CupPos = const Offset(-340, 115);
  String _s1CupState = 'empty';
  double _s1BowlFill = 0;
  int _s1Batches = 0;
  bool _s1Pouring = false;

  // S2
  bool _s2BarsOnBoard = false;
  bool _s2MachinePlaced = false;
  int _s2D = 1;
  int _s2N = 0;
  bool _s2PiecesMoved = false;

  // S3
  List<bool> _s3WDone = [false, false];
  List<bool> _s3QDone = [false, false];
  List<Stone> _s3Stones = [];
  bool _s3WandActive = false;
  Offset _s3WandPos = const Offset(0, -120);
  bool _s3Merging = false;

  // S4
  List<Jug> _s4Jugs = [];
  bool _s4HandleDown = false;
  bool _s4Oops = false;
  double _s4CylFill = 0;

  // S5
  bool _s5RibbonsPlaced = false;
  bool _s5MachineActive = false;
  Offset _s5MachinePos = const Offset(0, -160);
  int _s5D = 1;
  int _s5N = 1;
  bool _s5CutDone = false;
  bool _s5PiecesMoved = false;
  List<Map<String, dynamic>> _s5Ribbons = [];

  String? _draggedItem;
  Offset _dragPos = Offset.zero;

  bool _showSuccessPopup = false;
  bool _isPlayingCurtain = true;

  Offset _compactStepPos = const Offset(20, 80);
  Offset? _popupPos;

  // Auto-scroll controller for the sidebar
  final ScrollController _sidebarScrollController = ScrollController();
  int _lastPseudoStep = -1;

  // Animation Engine
  late AnimationController _ticker;

  // Dedicated Audio Players
  static final AudioPlayer _clickPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _shutterPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Network Audio Sources
  static const String _clickUrl =
      'audio/class7/mixkit_2568.mp3';
  static const String _successUrl =
      'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl =
      'audio/class7/mixkit_955.mp3';
  static const String _alertUrl =
      'audio/class7/mixkit_2869.mp3';
  static const String _shutterUrl =
      'audio/class7/mixkit_2574.mp3';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _initAudio();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(days: 365),
    )..forward();
    _ticker.addListener(() {
      if (mounted) {
        setState(() {
          if (_scenario == 4 && _s4HandleDown) {
            Jug? j = _s4Jugs.where((x) => x.state == 'under_tap').firstOrNull;
            if (j != null && j.fill < 1) j.fill += 0.005;
          }
        });
      }
    });

    _loadScenario(1);
    _playSound('shutter');
  }

  void _initAudio() async {
    await _clickPlayer.setSourceAsset(_clickUrl);
    await _successPlayer.setSourceAsset(_successUrl);
    await _errorPlayer.setSourceAsset(_errorUrl);
    await _fxPlayer.setSourceAsset(_alertUrl);
    await _shutterPlayer.setSourceAsset(_shutterUrl);
  }

  void _playSound(String type) {
    try {
      if (type == 'click') _clickPlayer.resume();
      if (type == 'snap' || type == 'pour') _fxPlayer.resume();
      if (type == 'success') _successPlayer.resume();
      if (type == 'error') _errorPlayer.resume();
      if (type == 'shutter') _shutterPlayer.resume();
    } catch (e) {
      // ignore
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _shutterPlayer.dispose();
    _sidebarScrollController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String t(String key) {
    return translations[_lang]?[key] ?? translations['en']?[key] ?? key;
  }

  void _cycleLanguage() {
    setState(() {
      if (_lang == 'en') {
        _lang = 'hi';
      } else {
        _lang = 'en';
      }
    });
    _playSound('click');
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _phase = 'init';

      _draggedItem = null;
      _showSuccessPopup = false;
      _popupPos = null;
      _pan = const Offset(0, 20);
      _zoom = 1.0;

      // Resets
      _s1CupPos = const Offset(-340, 115);
      _s1CupState = 'empty';
      _s1BowlFill = 0;
      _s1Batches = 0;
      _s1Pouring = false;
      _s2BarsOnBoard = false;
      _s2MachinePlaced = false;
      _s2D = 1;
      _s2N = 0;
      _s2PiecesMoved = false;
      _s3WDone = [false, false];
      _s3QDone = [false, false];
      _s3Stones = [];
      _s3WandActive = false;
      _s3WandPos = const Offset(0, -120);
      _s3Merging = false;
      _s4Jugs = List.generate(
        4,
        (i) => Jug(i, -120 + i * 80.0, 120, 0, 'pile'),
      );
      _s4HandleDown = false;
      _s4Oops = false;
      _s4CylFill = 0;
      _s5RibbonsPlaced = false;
      _s5MachineActive = false;
      _s5MachinePos = const Offset(0, -160);
      _s5D = 1;
      _s5N = 1;
      _s5CutDone = false;
      _s5PiecesMoved = false;
      _s5Ribbons = [];

      if (_scenario == 3) _phase = 'build1';
      if (_scenario == 4) _phase = 'fill';

      _lastPseudoStep = -1;
    });
    _playSound('click');
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    if (_phase == 'complete') return;

    double worldX =
        (details.localFocalPoint.dx - size.width / 2 - _pan.dx) / _zoom;
    double worldY =
        (details.localFocalPoint.dy - size.height / 2 - _pan.dy) / _zoom;
    Offset pt = Offset(worldX, worldY);

    _baseZoom = _zoom;

    setState(() {
      if (_scenario == 1) {
        if ((pt - _s1CupPos).distance < 50) {
          _draggedItem = 'cup';
          _playSound('click');
        }
      } else if (_scenario == 2) {
        if (_phase == 'init' &&
            pt.dx > -300 &&
            pt.dx < -120 &&
            pt.dy > -50 &&
            pt.dy < 90) {
          _draggedItem = 'bars';
          _dragPos = pt;
          _playSound('click');
        } else if (_phase == 'dials_d') {
          if (!_s2MachinePlaced &&
              pt.dx > -40 &&
              pt.dx < 80 &&
              pt.dy > 130 &&
              pt.dy < 190) {
            _draggedItem = 'machine';
            _dragPos = pt;
            _playSound('click');
          } else if (_s2MachinePlaced) {
            if ((pt - const Offset(40, -75)).distance < 25) {
              _s2D = math.min(5, _s2D + 1);
              _playSound('click');
              if (_s2D == 5) _phase = 'dials_n';
            } // D +
            if ((pt - const Offset(0, -75)).distance < 25) {
              _s2D = math.max(1, _s2D - 1);
              _playSound('click');
            } // D -
          }
        } else if (_phase == 'dials_n') {
          if ((pt - const Offset(120, -75)).distance < 25) {
            _s2N = math.min(2, _s2N + 1);
            _playSound('click');
            if (_s2N == 2) _phase = 'drag_pieces';
          } // N +
          if ((pt - const Offset(80, -75)).distance < 25) {
            _s2N = math.max(0, _s2N - 1);
            _playSound('click');
          } // N -
        } else if (_phase == 'drag_pieces') {
          if (pt.dx > -50 && pt.dx < 100 && pt.dy > -80 && pt.dy < 100) {
            // Widened hit box for pieces
            _draggedItem = 'hl_pieces';
            _dragPos = pt;
            _playSound('click');
          }
        }
      } else if (_scenario == 3) {
        if (_phase == 'build1' || _phase == 'build2') {
          if ((pt - const Offset(-290, -30)).distance < 40) {
            _draggedItem = 'new_whole';
            _dragPos = pt;
            _playSound('click');
          }
          if ((pt - const Offset(-290, 60)).distance < 30) {
            _draggedItem = 'new_quarter';
            _dragPos = pt;
            _playSound('click');
          }
        } else if (_phase == 'combine') {
          if ((pt - _s3WandPos).distance < 40) {
            _s3WandActive = true;
            _playSound('click');
          }
        }
      } else if (_scenario == 4) {
        if (_phase == 'fill') {
          Jug? idleJug = _s4Jugs.where((j) => j.state == 'pile').firstOrNull;
          if (idleJug != null &&
              (pt - Offset(idleJug.x, idleJug.y)).distance < 60 &&
              !_s4Jugs.any((j) => j.state == 'under_tap')) {
            _draggedItem = 'jug_${idleJug.id}';
            idleJug.state = 'drag';
            _playSound('click');
          }
          if ((pt - const Offset(-115, -45)).distance < 40) {
            _s4HandleDown = !_s4HandleDown; // Toggle pouring
            if (_s4HandleDown && _s4Jugs.any((j) => j.state == 'under_tap')) {
              _playSound('pour');
            } else if (!_s4HandleDown) {
              _checkJuiceFill();
            }
          }
        } else if (_phase == 'pour') {
          Jug? hit =
              _s4Jugs
                  .where(
                    (j) =>
                        j.state == 'done' &&
                        (pt - Offset(j.x, j.y)).distance < 40,
                  )
                  .firstOrNull;
          if (hit != null) {
            hit.state = 'drag_pour';
            _draggedItem = 'jug_${hit.id}';
            _playSound('click');
          }
        }
      } else if (_scenario == 5) {
        if (_phase == 'init' && (pt - const Offset(-280, -20)).distance < 60) {
          _draggedItem = 'ribbons';
          _dragPos = pt;
          _playSound('click');
        } else if (_phase == 'dials') {
          // Fraction Cutter Plus/Minus interaction with generously sized touch targets
          if ((pt - const Offset(-38, -137)).distance < 40) {
            _s5D = _s5D >= 10 ? 1 : _s5D + 1;
            _playSound('click');
          } // D +
          if ((pt - const Offset(-82, -137)).distance < 40) {
            _s5D = _s5D <= 1 ? 10 : _s5D - 1;
            _playSound('click');
          } // D -
          if ((pt - const Offset(82, -137)).distance < 40) {
            _s5N = _s5N >= 10 ? 1 : _s5N + 1;
            _playSound('click');
          } // N +
          if ((pt - const Offset(38, -137)).distance < 40) {
            _s5N = _s5N <= 1 ? 10 : _s5N - 1;
            _playSound('click');
          } // N -

          if (_s5D == 4 && _s5N == 3) _phase = 'drag_machine';
        } else if (_phase == 'drag_machine') {
          if (pt.dx > -110 && pt.dx < 110 && pt.dy > -210 && pt.dy < -110) {
            _draggedItem = 'machine';
            _dragPos = pt;
            _playSound('click');
          }
        } else if (_phase == 'drag_pieces') {
          // Hugely expanded hit box making it super easy to grab the cut pieces
          if (pt.dx > -200 && pt.dx < 200 && pt.dy > -50 && pt.dy < 100) {
            _draggedItem = 'cut_pieces';
            _dragPos = pt;
            _playSound('click');
          }
        }
      }
    });
  }

  void _checkJuiceFill() {
    Jug? j = _s4Jugs.where((x) => x.state == 'under_tap').firstOrNull;
    if (j != null) {
      if (j.fill >= 0.60 && j.fill <= 0.72) {
        j.state = 'done';
        j.fill = 0.666;
        int count =
            _s4Jugs
                .where((x) => x.state == 'done' || x.state == 'poured')
                .length;
        j.x = -120 + (count - 1) * 80.0;
        j.y = 120;
        _s4Oops = false;
        _playSound('success');
        if (_s4Jugs.where((x) => x.state == 'done').length == 4) {
          _phase = 'pour';
        }
      } else {
        j.fill = 0;
        _s4Oops = true;
        _playSound('error');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _s4Oops = false;
            });
          }
        });
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    if (_draggedItem != null || _s3WandActive) {
      // Dragging item logic
      double dx = details.focalPointDelta.dx / _zoom;
      double dy = details.focalPointDelta.dy / _zoom;

      setState(() {
        if (_scenario == 1 && _draggedItem == 'cup') {
          _s1CupPos += Offset(dx, dy);
        } else if (_scenario == 2 && _draggedItem != null) {
          _dragPos += Offset(dx, dy);
        } else if (_scenario == 3 &&
            (_draggedItem == 'new_whole' || _draggedItem == 'new_quarter')) {
          _dragPos += Offset(dx, dy);
        } else if (_scenario == 3 && _s3WandActive) {
          _s3WandPos += Offset(dx, dy);
          var qStones = _s3Stones.where((s) => s.type == 'quarter').toList();
          if (qStones.length >= 2 &&
              _s3WandPos.dx > -50 &&
              _s3WandPos.dx < 100 &&
              _s3WandPos.dy > -80 &&
              _s3WandPos.dy < 80) {
            _s3WandActive = false;
            _s3Merging = true;
            _s3Stones.removeWhere((s) => s.type == 'quarter');
            _playSound('snap');
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted) {
                setState(() {
                  _phase = 'complete';
                  _playSound('success');
                });
              }
            });
          }
        } else if (_scenario == 4 &&
            _draggedItem != null &&
            _draggedItem!.startsWith('jug_')) {
          int id = int.parse(_draggedItem!.split('_')[1]);
          Jug j = _s4Jugs.firstWhere((x) => x.id == id);
          j.x += dx;
          j.y += dy;
        } else if (_scenario == 5) {
          if (_draggedItem == 'ribbons' || _draggedItem == 'machine') {
            _dragPos += Offset(dx, dy);
          } else if (_draggedItem == 'cut_pieces') {
            for (var r in _s5Ribbons) {
              if (r['glow']) {
                r['x'] += dx;
                r['y'] += dy;
              }
            }
            _dragPos += Offset(
              dx,
              dy,
            ); // Update _dragPos explicitly for drop validation
          }
        }
      });
    } else if (_draggedItem == null && !_s3WandActive) {
      // Panning/Zooming canvas seamlessly using the incrementing delta.
      setState(() {
        if (details.scale != 1.0) {
          _zoom = (_baseZoom * details.scale).clamp(0.5, 3.0);
        }
        _pan += details.focalPointDelta;
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    setState(() {
      if (_scenario == 1 && _draggedItem == 'cup') {
        if (_s1CupState == 'empty' &&
            _s1CupPos.dx > -250 &&
            _s1CupPos.dx < -130 &&
            _s1CupPos.dy > -100 &&
            _s1CupPos.dy < 60) {
          _s1CupState = 'full';
          _playSound('snap');
        } else if (_s1CupState == 'full' &&
            (_s1CupPos - const Offset(100, 50)).distance < 120) {
          _s1Pouring = true;
          _s1CupPos = const Offset(100, -30);
          _playSound('pour');

          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              setState(() {
                _s1Pouring = false;
                _s1CupState = 'empty';
                _s1CupPos = const Offset(-340, 115);
                _s1BowlFill++;
                _s1Batches++;
                if (_s1Batches == 3) {
                  _phase = 'complete';
                  _playSound('success');
                }
              });
            }
          });
        } else {
          _s1CupPos = const Offset(-250, 80);
          _playSound('error');
        }
      } else if (_scenario == 2 && _draggedItem != null) {
        if (_draggedItem == 'bars') {
          if (_dragPos.dx > -80 && _dragPos.dx < 200) {
            _s2BarsOnBoard = true;
            _phase = 'dials_d';
            _playSound('snap');
          } else {
            _playSound('error');
          }
        } else if (_draggedItem == 'machine') {
          if (_dragPos.dx > -80 && _dragPos.dx < 200) {
            _s2MachinePlaced = true;
            _playSound('snap');
          } else {
            _playSound('error');
          }
        } else if (_draggedItem == 'hl_pieces') {
          if ((_dragPos - const Offset(280, 10)).distance < 100) {
            _s2PiecesMoved = true;
            _phase = 'complete';
            _playSound('success');
          } else {
            _playSound('error');
          }
        }
      } else if (_scenario == 3 && _draggedItem != null) {
        bool placed = false;
        Offset o1 = const Offset(-80, -40);
        Offset o2 = const Offset(80, -40);
        Offset? activeOut =
            _phase == 'build1' ? o1 : (_phase == 'build2' ? o2 : null);
        int outIdx = _phase == 'build1' ? 0 : 1;

        if (activeOut != null) {
          if (_draggedItem == 'new_whole' &&
              (_dragPos - activeOut).distance < 50 &&
              !_s3WDone[outIdx]) {
            _s3Stones.add(Stone('whole', activeOut.dx, activeOut.dy));
            _s3WDone[outIdx] = true;
            placed = true;
            _playSound('snap');
          } else if (_draggedItem == 'new_quarter' &&
              (_dragPos - Offset(activeOut.dx + 45, activeOut.dy + 15))
                      .distance <
                  50 &&
              !_s3QDone[outIdx]) {
            _s3Stones.add(
              Stone('quarter', activeOut.dx + 45, activeOut.dy + 15),
            );
            _s3QDone[outIdx] = true;
            placed = true;
            _playSound('snap');
          }
        }
        if (!placed) _playSound('error');

        if (_s3WDone[0] && _s3QDone[0] && _phase == 'build1') _phase = 'build2';
        if (_s3WDone[1] && _s3QDone[1] && _phase == 'build2') {
          _phase = 'combine';
        }
      } else if (_scenario == 4 &&
          _draggedItem != null &&
          _draggedItem!.startsWith('jug_')) {
        int id = int.parse(_draggedItem!.split('_')[1]);
        Jug j = _s4Jugs.firstWhere((x) => x.id == id);
        if (j.state == 'drag') {
          if ((Offset(j.x, j.y) - const Offset(-140, 50)).distance < 60) {
            j.x = -140;
            j.y = 50;
            j.state = 'under_tap';
            _playSound('snap');
          } else {
            j.state = 'pile';
            j.x = -120 + j.id * 80.0;
            j.y = 120;
            _playSound('error');
          }
        } else if (j.state == 'drag_pour') {
          if ((Offset(j.x, j.y) - const Offset(220, 80)).distance < 80) {
            _s4CylFill += j.fill;
            j.state = 'poured';
            j.x = 2000;
            _playSound('pour');
            if (_s4Jugs.where((x) => x.state == 'poured').length == 4) {
              _phase = 'complete';
              _playSound('success');
            }
          } else {
            j.state = 'done';
            int count = _s4Jugs
                .where((x) => x.state == 'done' || x.state == 'poured')
                .toList()
                .indexOf(j);
            j.x = -120 + count * 80.0;
            j.y = 120;
            _playSound('error');
          }
        }
      } else if (_scenario == 5 && _draggedItem != null) {
        if (_draggedItem == 'ribbons') {
          if (_dragPos.dx > -150 &&
              _dragPos.dx < 150 &&
              _dragPos.dy > -20 &&
              _dragPos.dy < 80) {
            _s5RibbonsPlaced = true;
            _s5Ribbons = [
              {'x': -180.0, 'y': 15.0, 'w': 180.0, 'h': 30.0, 'glow': false},
              {'x': 0.0, 'y': 15.0, 'w': 180.0, 'h': 30.0, 'glow': false},
            ];
            _phase = 'dials';
            _s5MachineActive = true;
            _playSound('snap');
          } else {
            _playSound('error');
          }
        } else if (_draggedItem == 'machine') {
          if (_dragPos.dy > -50 &&
              _dragPos.dy < 80 &&
              _dragPos.dx > -100 &&
              _dragPos.dx < 100) {
            _s5MachinePos = const Offset(0, 30);
            _phase = 'cut_ready';
            _playSound('snap');
          } else {
            _s5MachinePos = const Offset(0, -160);
            _playSound('error');
          }
        } else if (_draggedItem == 'cut_pieces') {
          if (_dragPos.dx > 100 && _dragPos.dy > 50) {
            // Highly forgiving drop zone
            _s5PiecesMoved = true;
            _phase = 'complete';
            _playSound('success');

            // Snap them neatly into the Project Box
            int idx = 0;
            for (var r in _s5Ribbons) {
              if (r['glow']) {
                r['x'] = 195.0;
                r['y'] = 130.0 + idx * 28;
                idx++;
              }
            }
          } else {
            int idx = 0;
            for (var r in _s5Ribbons) {
              if (r['glow']) {
                r['x'] = -180.0 + idx * 90;
                r['y'] = 15.0;
                idx++;
              }
            }
            _playSound('error');
          }
        }
      }

      _draggedItem = null;
      _s3WandActive = false;
    });
  }

  void _triggerCut() {
    setState(() {
      _s5Ribbons = [
        {'x': -180.0, 'y': 15.0, 'w': 90.0, 'h': 30.0, 'glow': true},
        {'x': -90.0, 'y': 15.0, 'w': 90.0, 'h': 30.0, 'glow': true},
        {'x': 0.0, 'y': 15.0, 'w': 90.0, 'h': 30.0, 'glow': true},
        {'x': 90.0, 'y': 15.0, 'w': 90.0, 'h': 30.0, 'glow': false},
      ];
      _s5CutDone = true;
      _phase = 'drag_pieces';
      _playSound('snap');
    });
  }

  int _getPseudoStep() {
    int pseudoStep = 0;
    if (_scenario == 1) {
      if (_s1Batches == 0 && _s1CupState == 'empty') {
        pseudoStep = 0;
      } else if (_s1Batches == 0 && (_s1CupState == 'full' || _s1Pouring)) {
        pseudoStep = 1;
      } else if (_s1Batches == 1) {
        pseudoStep = 2;
      } else if (_s1Batches == 2) {
        pseudoStep = 3;
      } else if (_s1Batches == 3 || _phase == 'complete') {
        pseudoStep = 4;
      }
    } else if (_scenario == 2) {
      if (!_s2BarsOnBoard) {
        pseudoStep = 0;
      } else if (_s2D < 5) {
        pseudoStep = 1;
      } else if (_s2N < 2) {
        pseudoStep = 2;
      } else if (!_s2PiecesMoved) {
        pseudoStep = 3;
      } else {
        pseudoStep = 4;
      }
    } else if (_scenario == 3) {
      if (_phase == 'build1') {
        pseudoStep = 0;
      } else if (_phase == 'build2') {
        pseudoStep = 1;
      } else if (_phase == 'combine') {
        pseudoStep = 2;
      } else if (_phase == 'complete') {
        pseudoStep = 3;
      }
    } else if (_scenario == 4) {
      if (_phase == 'fill' && _s4Jugs.where((x) => x.state == 'done').isEmpty) {
        pseudoStep = 0;
      } else if (_phase == 'fill') {
        pseudoStep = 1;
      } else if (_phase == 'pour') {
        pseudoStep = 2;
      } else if (_phase == 'complete') {
        pseudoStep = 3;
      }
    } else if (_scenario == 5) {
      if (_phase == 'init') {
        pseudoStep = 0;
      } else if (_phase == 'dials' || _phase == 'drag_machine') {
        pseudoStep = 1;
      } else if (_phase == 'cut_ready' || _phase == 'drag_pieces') {
        pseudoStep = 2;
      } else if (_phase == 'complete') {
        pseudoStep = 3;
      }
    }
    return pseudoStep;
  }

  Widget _buildRichText(String text, Color baseColor, bool isActive) {
    List<Widget> children = [];
    List<String> lines = text.split('\n');

    for (String line in lines) {
      Color textColor = baseColor;
      if (line.startsWith('Observation:') ||
          line.startsWith('अवलोकन:') ||
          line.startsWith('పరిశీలన:')) {
        textColor =
            isActive
                ? const Color(0xFF34d399)
                : baseColor.withOpacity(0.6); // Emerald
      } else if (line.startsWith('Learnt:') ||
          line.startsWith('सीखा:') ||
          line.startsWith('నేర్చుకున్నది:')) {
        textColor =
            isActive
                ? const Color(0xFF60a5fa)
                : baseColor.withOpacity(0.6); // Blue
      }

      int colonIdx = line.indexOf(':');
      if (colonIdx != -1 &&
          (line.startsWith('Task') ||
              line.startsWith('Observation') ||
              line.startsWith('Learnt') ||
              line.startsWith('कार्य') ||
              line.startsWith('अवलोकन') ||
              line.startsWith('सीखा') ||
              line.startsWith('పని') ||
              line.startsWith('పరిశీలన') ||
              line.startsWith('నేర్చుకున్నది'))) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  height: 1.4,
                  fontFamily: 'Plus Jakarta Sans',
                ),
                children: [
                  TextSpan(
                    text: line.substring(0, colonIdx + 1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: line.substring(colonIdx + 1)),
                ],
              ),
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              line,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                height: 1.4,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildSidebar(double width) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: _isSidebarOpen ? 0 : -width,
      top: 0,
      bottom: 0,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1e293b).withOpacity(0.95),
          border: Border(
            right: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(5, 0),
            ),
          ],
        ),
        child: SingleChildScrollView(
          controller: _sidebarScrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header & Language/Reset
              Container(
                padding: const EdgeInsets.only(
                  top: 80,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.pie_chart,
                          color: Color(0xFF6366f1),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t('appTitle'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t('appSubtitle'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.language,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            _lang.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onPressed: _cycleLanguage,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.refresh,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          label: Text(
                            t('restartLab'),
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () {
                            _playSound('shutter');
                            setState(() {
                              _lang = 'en';
                              _isPlayingCurtain = true;
                            });
                            _loadScenario(1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scenario Dropdown Selection
                    Text(
                      t('selectScenario'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _scenario,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1e293b),
                          iconEnabledColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                          items:
                              [1, 2, 3, 4, 5].map((id) {
                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text(t('s${id}_title')),
                                );
                              }).toList(),
                          onChanged: (val) {
                            if (val != null) _loadScenario(val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Objective
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0f172a).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.track_changes,
                                color: Color(0xFF6366f1),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t('objectiveLbl'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t('s${_scenario}_obj'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Steps Display
                    _buildStepsList(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "© ZeroScienceLab - Fall in love with math and Science",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepsList() {
    int pseudoStep = _getPseudoStep();
    List<Widget> stepWidgets = [];
    int maxSteps =
        (_scenario == 1)
            ? 4
            : (_scenario == 2
                ? 4
                : (_scenario == 3 ? 3 : (_scenario == 4 ? 3 : 3)));

    for (int i = 0; i < maxSteps; i++) {
      bool isCompleted = i < pseudoStep;
      bool isActive = i == pseudoStep;

      Color bgColor =
          isActive
              ? const Color(0xFF6366f1).withOpacity(0.2)
              : (isCompleted ? Colors.black26 : Colors.transparent);
      Color borderColor =
          isActive ? const Color(0xFF6366f1) : Colors.white.withOpacity(0.1);

      stepWidgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isCompleted
                  ? const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  )
                  : Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          isActive ? const Color(0xFF6366f1) : Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${t('stepLabel')} ${i + 1}",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildRichText(
                      t('s${_scenario}_step${i + 1}'),
                      Colors.white,
                      isActive,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_phase == 'complete') {
      stepWidgets.add(
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    t('completed'),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t('s${_scenario}_sum'),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: stepWidgets);
  }

  Widget _buildActionButtons() {
    List<Widget> buttons = [];

    if (_scenario == 5 && _phase == 'cut_ready') {
      buttons.add(
        _customButton(t('cutBtn'), Icons.cut, Colors.red, _triggerCut),
      );
    }

    if (_phase == 'complete') {
      if (_scenario < 5) {
        buttons.add(
          _customButton(
            t('nextScenario'),
            Icons.navigate_next,
            Colors.green,
            () => _loadScenario(_scenario + 1),
          ),
        );
      } else {
        buttons.add(
          _customButton(t('doneBtn'), Icons.done_all, Colors.green, () {
            setState(() {
              _showSuccessPopup = true;
            });
            _playSound('success');
          }),
        );
      }
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: buttons,
    );
  }

  Widget _customButton(
    String text,
    IconData icon,
    MaterialColor color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.shade500,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
      ),
      onPressed: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double sidebarWidth = screenWidth * 0.30;
    if (sidebarWidth < 300) sidebarWidth = 300;

    int pseudoStep = _getPseudoStep();

    // Auto-scroll Trigger logic inside build
    if (pseudoStep != _lastPseudoStep) {
      _lastPseudoStep = pseudoStep;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_sidebarScrollController.hasClients) {
          _sidebarScrollController.animateTo(
            _sidebarScrollController.position.maxScrollExtent +
                200, // force to bottom
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Canvas Layer (Zoom/Pan handled natively via InteractiveViewer / ScaleGestureRecognizer equivalent)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                Size canvasSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
                return GestureDetector(
                  onScaleStart: (d) => _handleScaleStart(d, canvasSize),
                  onScaleUpdate: (d) => _handleScaleUpdate(d, canvasSize),
                  onScaleEnd: (d) => _handleScaleEnd(d),
                  child: CustomPaint(
                    painter: FractionFactoryPainter(
                      scenario: _scenario,
                      phase: _phase,
                      zoom: _zoom,
                      pan: _pan,
                      s1CupPos: _s1CupPos,
                      s1CupState: _s1CupState,
                      s1BowlFill: _s1BowlFill,
                      s1Pouring: _s1Pouring,
                      s2BarsOnBoard: _s2BarsOnBoard,
                      s2MachinePlaced: _s2MachinePlaced,
                      s2D: _s2D,
                      s2N: _s2N,
                      s2PiecesMoved: _s2PiecesMoved,
                      s3WDone: _s3WDone,
                      s3QDone: _s3QDone,
                      s3Stones: _s3Stones,
                      s3WandPos: _s3WandPos,
                      s3Merging: _s3Merging,
                      s4Jugs: _s4Jugs,
                      s4HandleDown: _s4HandleDown,
                      s4Oops: _s4Oops,
                      s4CylFill: _s4CylFill,
                      s5Ribbons: _s5Ribbons,
                      s5MachinePos: _s5MachinePos,
                      s5D: _s5D,
                      s5N: _s5N,
                      s5CutDone: _s5CutDone,
                      s5PiecesMoved: _s5PiecesMoved,
                      s5RibbonsPlaced: _s5RibbonsPlaced,
                      s5MachineActive: _s5MachineActive,
                      draggedItem: _draggedItem,
                      dragPos: _dragPos,
                      translations: translations[_lang] ?? translations['en']!,
                    ),
                    size: Size.infinite,
                  ),
                );
              },
            ),
          ),

          // Sidebar Layer
          _buildSidebar(sidebarWidth),

          // Action Buttons Overlay on Canvas
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: 40,
            left: _isSidebarOpen ? sidebarWidth : 0,
            right: 0,
            child: Center(child: _buildActionButtons()),
          ),

          // Top Left Menu Button
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
              color: Colors.orangeAccent,
              iconSize: 28,
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _isSidebarOpen = !_isSidebarOpen;
                });
                _playSound('click');
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.orange.withOpacity(0.8)),
                ),
              ),
            ),
          ),

          // Compact Active Step Tracker on Canvas
          if (!_isSidebarOpen && _phase != 'complete')
            Positioned(
              left: _compactStepPos.dx,
              top: _compactStepPos.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _compactStepPos += details.delta;
                  });
                },
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e293b).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6366f1).withOpacity(0.5),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.drag_indicator,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${t('stepLabel')} ${pseudoStep + 1}",
                            style: const TextStyle(
                              color: Color(0xFF6366f1),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildRichText(
                        t('s${_scenario}_step${pseudoStep + 1}'),
                        Colors.white,
                        true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Curtain Layer
          if (_isPlayingCurtain)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF020617),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.pie_chart,
                      size: 80,
                      color: Color(0xFF6366f1),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t('appTitle'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t('appSubtitle'),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 28,
                      ),
                      label: Text(
                        t('enterLab'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366f1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      onPressed: () {
                        _playSound('click');
                        setState(() {
                          _isPlayingCurtain = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

          // Success Popup Layer
          if (_showSuccessPopup)
            Positioned(
              left: _popupPos?.dx ?? (screenWidth - 400) / 2,
              top: _popupPos?.dy ?? (screenHeight - 350) / 2,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _popupPos =
                        (_popupPos ??
                            Offset(
                              (screenWidth - 400) / 2,
                              (screenHeight - 350) / 2,
                            )) +
                        details.delta;
                  });
                },
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e293b).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 20),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -16,
                        right: -16,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _showSuccessPopup = false;
                            });
                            _playSound('click');
                          },
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('successTitle'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t('successDesc'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            label: Text(
                              t('restartLab'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366f1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              _playSound('shutter');
                              setState(() {
                                _showSuccessPopup = false;
                                _lang = 'en';
                                _isPlayingCurtain = true;
                              });
                              _loadScenario(1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- CANVAS DRAWING (CUSTOM PAINTER) ---

class FractionFactoryPainter extends CustomPainter {
  final int scenario;
  final String phase;
  final double zoom;
  final Offset pan;
  final Map<String, String> translations;

  // S1
  final Offset s1CupPos;
  final String s1CupState;
  final double s1BowlFill;
  final bool s1Pouring;

  // S2
  final bool s2BarsOnBoard;
  final bool s2MachinePlaced;
  final int s2D;
  final int s2N;
  final bool s2PiecesMoved;

  // S3
  final List<bool> s3WDone;
  final List<bool> s3QDone;
  final List<Stone> s3Stones;
  final Offset s3WandPos;
  final bool s3Merging;

  // S4
  final List<Jug> s4Jugs;
  final bool s4HandleDown;
  final bool s4Oops;
  final double s4CylFill;

  // S5
  final List<Map<String, dynamic>> s5Ribbons;
  final Offset s5MachinePos;
  final int s5D;
  final int s5N;
  final bool s5CutDone;
  final bool s5PiecesMoved;
  final bool s5RibbonsPlaced;
  final bool s5MachineActive;

  final String? draggedItem;
  final Offset dragPos;

  FractionFactoryPainter({
    required this.scenario,
    required this.phase,
    required this.zoom,
    required this.pan,
    required this.translations,
    required this.s1CupPos,
    required this.s1CupState,
    required this.s1BowlFill,
    required this.s1Pouring,
    required this.s2BarsOnBoard,
    required this.s2MachinePlaced,
    required this.s2D,
    required this.s2N,
    required this.s2PiecesMoved,
    required this.s3WDone,
    required this.s3QDone,
    required this.s3Stones,
    required this.s3WandPos,
    required this.s3Merging,
    required this.s4Jugs,
    required this.s4HandleDown,
    required this.s4Oops,
    required this.s4CylFill,
    required this.s5Ribbons,
    required this.s5MachinePos,
    required this.s5D,
    required this.s5N,
    required this.s5CutDone,
    required this.s5PiecesMoved,
    required this.s5RibbonsPlaced,
    required this.s5MachineActive,
    required this.draggedItem,
    required this.dragPos,
  });

  void drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    Color color = Colors.white,
    double fontSize = 16,
    bool bold = true,
  }) {
    TextSpan span = TextSpan(
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'Plus Jakarta Sans',
      ),
      text: text,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  void drawCup(Canvas canvas, Offset pos, String state) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    Path p =
        Path()
          ..moveTo(-24, -24)
          ..lineTo(24, -24)
          ..lineTo(18, 24)
          ..lineTo(-18, 24)
          ..close();

    if (state == 'empty') {
      canvas.drawPath(
        p,
        Paint()
          ..color = const Color(0xFFE2E8F0).withOpacity(0.6)
          ..style = PaintingStyle.fill,
      );
    } else {
      canvas.drawPath(
        p,
        Paint()
          ..color = Colors.white.withOpacity(0.95)
          ..style = PaintingStyle.fill,
      );
    }

    // Strong outline keeps cup readable over busy backgrounds.
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF1E3A8A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Handle
    canvas.drawArc(
      Rect.fromLTWH(24, -12, 18, 24),
      -math.pi / 2,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    // High-contrast badge so "1/4" is always visible.
    canvas.drawCircle(
      const Offset(0, 2),
      12,
      Paint()..color = const Color(0xFF0F172A),
    );
    drawText(
      canvas,
      '1/4',
      const Offset(0, 2),
      color: Colors.white,
      fontSize: 13,
    );
    canvas.restore();
  }

  void drawBag(Canvas canvas, Offset pos) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    double w = 120, h = 160;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 20, w, h - 20),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.white10,
    );

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5, 30, w - 10, h - 35),
        const Radius.circular(8),
      ),
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = Colors.white);

    // Some noise
    var rand = math.Random(42);
    for (int i = 0; i < 100; i++) {
      canvas.drawRect(
        Rect.fromLTWH(rand.nextDouble() * w, rand.nextDouble() * h, 4, 4),
        Paint()..color = Colors.grey.shade300,
      );
    }
    canvas.restore();

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 20, w, h - 20),
        const Radius.circular(10),
      ),
      Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Label
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-5, 0, w + 10, 20),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.amber,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-5, 0, w + 10, 20),
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.brown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawRect(
      Rect.fromLTWH(w / 2 - 30, h / 2 - 10, 60, 20),
      Paint()..color = Colors.white.withOpacity(0.8),
    );
    drawText(
      canvas,
      translations['s1_sugar'] ?? 'SUGAR',
      Offset(w / 2, h / 2),
      color: Colors.black,
      fontSize: 12,
    );
    canvas.restore();
  }

  void drawBowl(Canvas canvas, Offset pos, double fillAmt) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    double r = 120;

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r),
      0,
      math.pi,
      false,
      Paint()..color = const Color(0xFF1e293b),
    );

    if (fillAmt > 0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(-r, 0, r, r));

      Path arcPath =
          Path()..addArc(
            Rect.fromCircle(center: Offset.zero, radius: r - 5),
            0,
            math.pi,
          );
      canvas.clipPath(arcPath);

      double fillRatio = fillAmt / 3.0;
      double h = fillRatio * (r - 10);
      double ySurf = r - h;

      canvas.drawRect(
        Rect.fromLTRB(-r, ySurf, r, r),
        Paint()..color = Colors.white,
      );
      canvas.restore();
    }

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r),
      0,
      math.pi,
      false,
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Gauge
    canvas.drawRect(
      Rect.fromLTWH(-r - 20, -10, 12, r + 20),
      Paint()..color = Colors.red,
    );
    double gaugeH = (fillAmt / 3.0) * (r + 18);
    canvas.drawRect(
      Rect.fromLTWH(-r - 19, r + 9 - gaugeH, 10, gaugeH),
      Paint()..color = Colors.green,
    );

    drawText(canvas, '3/4', Offset(-r - 40, 0), fontSize: 14);
    drawText(canvas, '2/4', Offset(-r - 40, r / 2), fontSize: 14);
    drawText(canvas, '1/4', Offset(-r - 40, r), fontSize: 14);

    canvas.restore();
  }

  void drawChocBar(
    Canvas canvas,
    Offset pos,
    int parts,
    int glowParts,
    double w,
    double h, {
    bool glow = false,
  }) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF451a03),
    );
    double pW = w / parts;
    for (int i = 0; i < parts; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * pW + 1, 1, pW - 2, h - 2),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF5c2b14),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * pW + 3, 3, pW - 6, h - 6),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF78350f),
      );
    }

    if (glowParts > 0 || glow) {
      double gw = glow ? w : glowParts * pW;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, gw, h),
          const Radius.circular(4),
        ),
        Paint()..color = Colors.lightBlueAccent.withOpacity(0.4),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, gw, h),
          const Radius.circular(4),
        ),
        Paint()
          ..color = Colors.lightBlueAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    canvas.restore();
  }

  void drawFractionator(
    Canvas canvas,
    Offset pos,
    double w,
    double h,
    int D,
    int N,
  ) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, -50, w, 50),
        topLeft: const Radius.circular(12),
        topRight: const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFFcbd5e1),
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, -50, w, 50),
        topLeft: const Radius.circular(12),
        topRight: const Radius.circular(12),
      ),
      Paint()
        ..color = const Color(0xFF94a3b8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    drawText(
      canvas,
      translations['s2_tool'] ?? 'Fractionator 5000',
      Offset(w / 2, -35),
      color: Colors.black,
      fontSize: 14,
    );

    Offset dPos = Offset(w / 2 - 40, -15);
    canvas.drawRect(
      Rect.fromCircle(center: Offset(dPos.dx - 20, dPos.dy), radius: 10),
      Paint()..color = Colors.grey.shade400,
    ); // - button
    canvas.drawRect(
      Rect.fromCircle(center: Offset(dPos.dx + 20, dPos.dy), radius: 10),
      Paint()..color = Colors.grey.shade400,
    ); // + button
    drawText(
      canvas,
      '-',
      Offset(dPos.dx - 20, dPos.dy),
      color: Colors.black,
      fontSize: 16,
    );
    drawText(
      canvas,
      '+',
      Offset(dPos.dx + 20, dPos.dy),
      color: Colors.black,
      fontSize: 16,
    );
    canvas.drawCircle(dPos, 14, Paint()..color = Colors.white);
    canvas.drawCircle(
      dPos,
      14,
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    drawText(canvas, D.toString(), dPos, color: Colors.black, fontSize: 14);

    Offset nPos = Offset(w / 2 + 40, -15);
    canvas.drawRect(
      Rect.fromCircle(center: Offset(nPos.dx - 20, nPos.dy), radius: 10),
      Paint()..color = Colors.grey.shade400,
    ); // - button
    canvas.drawRect(
      Rect.fromCircle(center: Offset(nPos.dx + 20, nPos.dy), radius: 10),
      Paint()..color = Colors.grey.shade400,
    ); // + button
    drawText(
      canvas,
      '-',
      Offset(nPos.dx - 20, nPos.dy),
      color: Colors.black,
      fontSize: 16,
    );
    drawText(
      canvas,
      '+',
      Offset(nPos.dx + 20, nPos.dy),
      color: Colors.black,
      fontSize: 16,
    );
    canvas.drawCircle(nPos, 14, Paint()..color = Colors.white);
    canvas.drawCircle(
      nPos,
      14,
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    drawText(canvas, N.toString(), nPos, color: Colors.black, fontSize: 14);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, w, h),
        bottomLeft: const Radius.circular(5),
        bottomRight: const Radius.circular(5),
      ),
      Paint()..color = Colors.white.withOpacity(0.1),
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, w, h),
        bottomLeft: const Radius.circular(5),
        bottomRight: const Radius.circular(5),
      ),
      Paint()
        ..color = Colors.grey.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    if (D > 1) {
      double chocWidth = w - 40;
      double chocOffsetX = 20;
      double partW = chocWidth / D;
      for (int i = 1; i < D; i++) {
        canvas.drawLine(
          Offset(chocOffsetX + i * partW, 0),
          Offset(chocOffsetX + i * partW, h),
          Paint()
            ..color = Colors.lightBlueAccent.withOpacity(0.8)
            ..strokeWidth = 3,
        );
      }
    }

    canvas.restore();
  }

  void drawStone(Canvas canvas, Stone s) {
    canvas.save();
    canvas.translate(s.x, s.y);

    if (s.type == 'whole') {
      canvas.drawRect(
        const Rect.fromLTWH(-30, -30, 60, 60),
        Paint()..color = const Color(0xFF94a3b8),
      );
      canvas.drawRect(
        const Rect.fromLTWH(-30, -30, 60, 60),
        Paint()
          ..color = const Color(0xFF475569)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      drawText(canvas, '1', const Offset(0, 0));
    } else if (s.type == 'quarter') {
      canvas.drawRect(
        const Rect.fromLTWH(-15, -15, 30, 30),
        Paint()..color = const Color(0xFF94a3b8),
      );
      canvas.drawRect(
        const Rect.fromLTWH(-15, -15, 30, 30),
        Paint()
          ..color = const Color(0xFF475569)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      drawText(canvas, '1/4', const Offset(0, 0), fontSize: 12);
    } else if (s.type == 'half') {
      canvas.drawRect(
        const Rect.fromLTWH(-30, -15, 60, 30),
        Paint()..color = const Color(0xFF94a3b8),
      );
      canvas.drawRect(
        const Rect.fromLTWH(-30, -15, 60, 30),
        Paint()
          ..color = const Color(0xFF475569)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      drawText(canvas, '1/2', const Offset(0, 0), fontSize: 14);
    }

    canvas.restore();
  }

  void drawJug(Canvas canvas, Jug j) {
    canvas.save();
    canvas.translate(j.x, j.y);
    double w = 50, h = 60;

    // Handle
    canvas.drawArc(
      Rect.fromCircle(center: Offset(-w / 2, -5), radius: 15),
      math.pi / 2,
      math.pi,
      false,
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w / 2, -h / 2, w, h),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFf1f5f9),
    );

    if (j.fill > 0) {
      double fh = j.fill * h;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(-w / 2 + 2, h / 2 - fh, w - 4, fh),
          bottomLeft: const Radius.circular(4),
          bottomRight: const Radius.circular(4),
        ),
        Paint()..color = Colors.orange,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w / 2, -h / 2, w, h),
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Marks
    canvas.drawLine(
      Offset(-w / 2, h / 2 - h * (1 / 3)),
      Offset(-w / 2 + 10, h / 2 - h * (1 / 3)),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(-w / 2, h / 2 - h * (2 / 3)),
      Offset(-w / 2 + 10, h / 2 - h * (2 / 3)),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );

    drawText(
      canvas,
      '1/3',
      Offset(-w / 2 + 20, h / 2 - h * (1 / 3)),
      color: Colors.black,
      fontSize: 10,
    );
    drawText(
      canvas,
      '2/3',
      Offset(-w / 2 + 20, h / 2 - h * (2 / 3)),
      color: Colors.black,
      fontSize: 10,
    );

    canvas.restore();
  }

  void drawDispenser(Canvas canvas, Offset pos) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    canvas.drawRect(
      const Rect.fromLTWH(-70, 130, 160, 20),
      Paint()..color = const Color(0xFF0f766e),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-60, -80, 100, 210),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF14b8a6),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-60, -80, 100, 210),
        const Radius.circular(8),
      ),
      Paint()
        ..color = const Color(0xFF0d9488)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-40, -60, 60, 30),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF0f172a),
    );
    drawText(
      canvas,
      translations['s4_juice'] ?? 'JUICE',
      const Offset(-10, -45),
      color: const Color(0xFF2dd4bf),
      fontSize: 12,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(20, -10, 40, 30),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFccfbf1),
    );
    canvas.drawRect(
      const Rect.fromLTWH(32, 20, 16, 30),
      Paint()..color = const Color(0xFF94a3b8),
    );
    canvas.drawRect(
      const Rect.fromLTWH(32, 20, 16, 30),
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.save();
    canvas.translate(65, 5);
    canvas.rotate(s4HandleDown ? math.pi / 6 : 0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, -5, 20, 10),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF94a3b8),
    );
    canvas.drawCircle(const Offset(20, 0), 12, Paint()..color = Colors.red);
    canvas.restore();

    if (s4Oops) {
      drawText(
        canvas,
        translations['s4_oops'] ?? 'Oops, too much!',
        const Offset(0, -100),
        color: Colors.red,
        fontSize: 18,
      );
    }

    canvas.restore();
  }

  void drawCylinder(Canvas canvas, Offset pos, double fill) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    double w = 70, h = 240;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(-w / 2, -h, w, h),
        bottomLeft: const Radius.circular(5),
        bottomRight: const Radius.circular(5),
      ),
      Paint()..color = Colors.white10,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(-w / 2, -h, w, h),
        bottomLeft: const Radius.circular(5),
        bottomRight: const Radius.circular(5),
      ),
      Paint()
        ..color = Colors.lightBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    double unitH = h / 4;
    if (fill > 0) {
      double fh = fill * unitH;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(-w / 2 + 2, -fh, w - 4, fh - 2),
          bottomLeft: const Radius.circular(3),
          bottomRight: const Radius.circular(3),
        ),
        Paint()..color = Colors.orange.withOpacity(0.9),
      );
    }

    for (int i = 1; i <= 12; i++) {
      double yy = -(i / 3) * unitH;
      bool isWhole = (i % 3 == 0);

      canvas.drawLine(
        Offset(-w / 2, yy),
        Offset(-w / 2 + (isWhole ? 14 : 8), yy),
        Paint()
          ..color = isWhole ? Colors.white : Colors.grey
          ..strokeWidth = isWhole ? 2.5 : 1.5,
      );

      if (isWhole) {
        drawText(
          canvas,
          (i ~/ 3).toString(),
          Offset(w / 2 + 15, yy),
          fontSize: 16,
        );
      } else {
        drawText(
          canvas,
          '$i/3',
          Offset(w / 2 + 15, yy),
          color: Colors.grey,
          fontSize: 12,
          bold: false,
        );
      }
    }

    if (fill > 2.6) {
      drawText(
        canvas,
        '8/3 ➡',
        Offset(-w / 2 - 25, -(8 / 3) * unitH),
        color: Colors.orange,
        fontSize: 18,
      );
    }

    canvas.restore();
  }

  void drawFractionCutter(
    Canvas canvas,
    Offset pos,
    double w,
    double h,
    int D,
    int N,
  ) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w / 2, -h / 2, w, h),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFFcbd5e1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w / 2, -h / 2, w, h),
        const Radius.circular(10),
      ),
      Paint()
        ..color = const Color(0xFF94a3b8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    drawText(
      canvas,
      translations['s5_tool'] ?? 'Fraction Cutter',
      Offset(0, -h / 2 - 12),
      color: Colors.white,
      fontSize: 20,
      bold: true,
    );

    Offset dPos = const Offset(-60, -5);
    canvas.drawRect(
      Rect.fromCircle(center: Offset(dPos.dx - 22, dPos.dy + 28), radius: 12),
      Paint()..color = Colors.grey.shade400,
    ); // - button
    canvas.drawRect(
      Rect.fromCircle(center: Offset(dPos.dx + 22, dPos.dy + 28), radius: 12),
      Paint()..color = Colors.grey.shade400,
    ); // + button
    drawText(
      canvas,
      '-',
      Offset(dPos.dx - 22, dPos.dy + 28),
      color: Colors.black,
      fontSize: 16,
      bold: true,
    );
    drawText(
      canvas,
      '+',
      Offset(dPos.dx + 22, dPos.dy + 28),
      color: Colors.black,
      fontSize: 16,
      bold: true,
    );

    canvas.drawCircle(dPos, 22, Paint()..color = Colors.white);
    canvas.drawCircle(
      dPos,
      22,
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    drawText(
      canvas,
      D.toString(),
      dPos,
      color: Colors.black,
      fontSize: 18,
      bold: true,
    );
    drawText(
      canvas,
      translations['denom'] ?? 'DENOM',
      Offset(dPos.dx, dPos.dy - 35),
      color: Colors.black,
      fontSize: 12,
      bold: true,
    );

    Offset nPos = const Offset(60, -5);
    canvas.drawRect(
      Rect.fromCircle(center: Offset(nPos.dx - 22, nPos.dy + 28), radius: 12),
      Paint()..color = Colors.grey.shade400,
    ); // - button
    canvas.drawRect(
      Rect.fromCircle(center: Offset(nPos.dx + 22, nPos.dy + 28), radius: 12),
      Paint()..color = Colors.grey.shade400,
    ); // + button
    drawText(
      canvas,
      '-',
      Offset(nPos.dx - 22, nPos.dy + 28),
      color: Colors.black,
      fontSize: 16,
      bold: true,
    );
    drawText(
      canvas,
      '+',
      Offset(nPos.dx + 22, nPos.dy + 28),
      color: Colors.black,
      fontSize: 16,
      bold: true,
    );

    canvas.drawCircle(nPos, 22, Paint()..color = Colors.white);
    canvas.drawCircle(
      nPos,
      22,
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    drawText(
      canvas,
      N.toString(),
      nPos,
      color: Colors.black,
      fontSize: 18,
      bold: true,
    );
    drawText(
      canvas,
      translations['numer'] ?? 'NUMER',
      Offset(nPos.dx, nPos.dy - 35),
      color: Colors.black,
      fontSize: 12,
      bold: true,
    );

    canvas.drawRect(
      Rect.fromLTWH(-w / 2 - 10, h / 2 - 25, w + 20, 35),
      Paint()..color = const Color(0xFF64748b),
    );
    canvas.drawRect(
      Rect.fromLTWH(-w / 2, h / 2 - 15, w, 15),
      Paint()..color = const Color(0xFF475569),
    );

    canvas.restore();
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 8, dashSpace = 8;
    double dx = p2.dx - p1.dx, dy = p2.dy - p1.dy;
    double dist = math.sqrt(dx * dx + dy * dy);
    double dashCount = dist / (dashWidth + dashSpace);

    for (int i = 0; i < dashCount; i++) {
      double startX = p1.dx + (dx / dist) * (i * (dashWidth + dashSpace));
      double startY = p1.dy + (dy / dist) * (i * (dashWidth + dashSpace));
      double endX = startX + (dx / dist) * dashWidth;
      double endY = startY + (dy / dist) * dashWidth;
      if (i == dashCount.floor()) {
        endX = p2.dx;
        endY = p2.dy;
      }
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Constant Dark Canvas Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF020617),
    );

    // Background Grid
    Paint gridPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    for (double i = -2000; i < 2000; i += 40) {
      canvas.drawLine(Offset(i, -2000), Offset(i, 2000), gridPaint);
      canvas.drawLine(Offset(-2000, i), Offset(2000, i), gridPaint);
    }

    canvas.translate(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    canvas.scale(zoom);

    if (scenario == 1) {
      drawBag(canvas, const Offset(-250, -50));
      drawBowl(canvas, const Offset(100, 50), s1BowlFill);
      drawCup(canvas, s1CupPos, s1CupState);

      if (s1Pouring) {
        canvas.drawRect(
          Rect.fromLTWH(
            s1CupPos.dx - 6,
            s1CupPos.dy + 10,
            12,
            100 - s1CupPos.dy - 10,
          ),
          Paint()..color = Colors.white,
        );
      }

      if (phase == 'complete') {
        drawText(
          canvas,
          translations['s1_canvas_eq2'] ?? '3 × 1/4 = 3/4',
          const Offset(100, -100),
          color: Colors.green,
          fontSize: 30,
        );
      }
    } else if (scenario == 2) {
      // Box
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-300, -50, 180, 140),
          const Radius.circular(5),
        ),
        Paint()..color = const Color(0xFFb4855d),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-295, -45, 170, 130),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF8a5a32),
      );
      drawText(
        canvas,
        translations['s2_choc'] ?? 'CHOCOLATE',
        const Offset(-210, 75),
        fontSize: 12,
      );

      // Board
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-80, -80, 280, 180),
          const Radius.circular(15),
        ),
        Paint()..color = const Color(0xFFdeaa6b),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-80, -80, 280, 180),
          const Radius.circular(15),
        ),
        Paint()
          ..color = const Color(0xFFb87c4c)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(190, -10, 50, 40),
          const Radius.circular(10),
        ),
        Paint()..color = const Color(0xFFdeaa6b),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(190, -10, 50, 40),
          const Radius.circular(10),
        ),
        Paint()
          ..color = const Color(0xFFb87c4c)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawCircle(
        const Offset(225, 10),
        8,
        Paint()..color = const Color(0xFF020617),
      );

      // Plate
      canvas.drawCircle(
        const Offset(280, 10),
        60,
        Paint()..color = Colors.greenAccent,
      );
      canvas.drawCircle(
        const Offset(280, 10),
        60,
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawCircle(
        const Offset(280, 10),
        42,
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      double barW = 160, barH = 30, gap = 15;
      double bx = s2BarsOnBoard ? -20 : -290;
      double by = s2BarsOnBoard ? -50 : -25;

      if (draggedItem == 'bars') {
        bx = dragPos.dx - barW / 2;
        by = dragPos.dy - (3 * barH + 2 * gap) / 2;
      }

      if (!s2PiecesMoved || draggedItem == 'hl_pieces') {
        for (int i = 0; i < 3; i++) {
          drawChocBar(
            canvas,
            Offset(bx, by + i * (barH + gap)),
            s2MachinePlaced ? s2D : 1,
            0,
            barW,
            barH,
          );
        }

        if (s2MachinePlaced) {
          drawFractionator(
            canvas,
            const Offset(-40, -60),
            barW + 40,
            3 * barH + 2 * gap + 20,
            s2D,
            s2N,
          );

          if (s2N > 0 && draggedItem != 'hl_pieces') {
            double partW = barW / s2D;
            canvas.drawRect(
              Rect.fromLTWH(
                bx,
                by - 2,
                s2N * partW,
                3 * (barH + gap) - gap + 4,
              ),
              Paint()..color = Colors.white.withOpacity(0.6),
            );
            canvas.drawRect(
              Rect.fromLTWH(
                bx,
                by - 2,
                s2N * partW,
                3 * (barH + gap) - gap + 4,
              ),
              Paint()
                ..color = Colors.lightBlueAccent
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3,
            );
          }

          if (draggedItem == 'hl_pieces') {
            double partW = barW / s2D;
            double hlX = dragPos.dx - (s2N * partW) / 2;
            double hlY = dragPos.dy - (3 * (barH + gap)) / 2;
            canvas.drawRect(
              Rect.fromLTWH(hlX, hlY, s2N * partW, 3 * (barH + gap) - gap),
              Paint()..color = Colors.white.withOpacity(0.6),
            );
            canvas.drawRect(
              Rect.fromLTWH(hlX, hlY, s2N * partW, 3 * (barH + gap) - gap),
              Paint()
                ..color = Colors.lightBlueAccent
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3,
            );
            for (int i = 0; i < 3; i++) {
              drawChocBar(
                canvas,
                Offset(hlX, hlY + i * (barH + gap)),
                s2N,
                0,
                s2N * partW,
                barH,
                glow: true,
              );
            }
          }
        }
      } else {
        double partW = barW / s2D;
        double remW = barW - (s2N * partW);
        for (int i = 0; i < 3; i++) {
          drawChocBar(
            canvas,
            Offset(-20 + s2N * partW, -50 + i * (barH + gap)),
            s2D - s2N,
            0,
            remW,
            barH,
            glow: false,
          );
        }
        drawFractionator(
          canvas,
          const Offset(-40, -60),
          barW + 40,
          3 * barH + 2 * gap + 20,
          s2D,
          s2N,
        );

        double pY = 10 - 25;
        drawChocBar(
          canvas,
          Offset(280 - barW / 2, pY),
          5,
          0,
          barW,
          barH,
          glow: false,
        );
        drawChocBar(
          canvas,
          Offset(280 - barW / 2, pY + barH + gap),
          1,
          0,
          barW / 5,
          barH,
          glow: false,
        );
        drawText(
          canvas,
          '6/5 = 1 1/5',
          Offset(280, pY - 20),
          color: Colors.white,
          fontSize: 16,
        );
      }

      if (!s2MachinePlaced && s2BarsOnBoard) {
        double mtx = draggedItem == 'machine' ? dragPos.dx - 60 : -40;
        double mty = draggedItem == 'machine' ? dragPos.dy - 30 : 130;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(mtx, mty, 120, 60),
            const Radius.circular(10),
          ),
          Paint()..color = Colors.grey,
        );
        drawText(
          canvas,
          'Fractionator',
          Offset(mtx + 60, mty + 30),
          color: Colors.black,
        );
      }

      if (phase == 'complete') {
        drawText(
          canvas,
          translations['s2_eq'] ?? '2/5 × 3 = 6/5 = 1 1/5',
          const Offset(0, -120),
          color: Colors.green,
          fontSize: 24,
        );
      }
    } else if (scenario == 3) {
      canvas.drawRect(
        const Rect.fromLTWH(-350, -120, 120, 240),
        Paint()..color = const Color(0xFF334155),
      );
      drawText(
        canvas,
        translations['s3_palette'] ?? 'STONES',
        const Offset(-290, -90),
      );
      drawStone(canvas, Stone('whole', -290, -30));
      drawStone(canvas, Stone('quarter', -290, 60));

      List<Offset> outs = const [Offset(-80, -40), Offset(80, -40)];
      for (var o in outs) {
        _drawDashedLine(
          canvas,
          Offset(o.dx - 30, o.dy - 30),
          Offset(o.dx + 30, o.dy - 30),
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 3,
        );
        _drawDashedLine(
          canvas,
          Offset(o.dx + 30, o.dy - 30),
          Offset(o.dx + 30, o.dy + 30),
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 3,
        );
        _drawDashedLine(
          canvas,
          Offset(o.dx + 30, o.dy + 30),
          Offset(o.dx - 30, o.dy + 30),
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 3,
        );
        _drawDashedLine(
          canvas,
          Offset(o.dx - 30, o.dy + 30),
          Offset(o.dx - 30, o.dy - 30),
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 3,
        );

        _drawDashedLine(
          canvas,
          Offset(o.dx + 30, o.dy),
          Offset(o.dx + 60, o.dy),
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 3,
        );
        _drawDashedLine(
          canvas,
          Offset(o.dx + 60, o.dy),
          Offset(o.dx + 60, o.dy + 30),
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 3,
        );
        _drawDashedLine(
          canvas,
          Offset(o.dx + 60, o.dy + 30),
          Offset(o.dx + 30, o.dy + 30),
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 3,
        );
      }

      for (var s in s3Stones) {
        drawStone(canvas, s);
      }
      if (s3Merging) {
        drawStone(canvas, Stone('half', 45, -25));
      }

      canvas.drawCircle(
        s3WandPos,
        30,
        Paint()..color = Colors.yellow.withOpacity(0.2),
      );
      canvas.drawCircle(
        s3WandPos,
        30,
        Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      drawText(
        canvas,
        '🪄',
        Offset(s3WandPos.dx, s3WandPos.dy + 10),
        fontSize: 30,
      );

      if (draggedItem == 'new_whole') {
        drawStone(canvas, Stone('whole', dragPos.dx, dragPos.dy));
      }
      if (draggedItem == 'new_quarter') {
        drawStone(canvas, Stone('quarter', dragPos.dx, dragPos.dy));
      }

      if (phase == 'complete') {
        drawText(
          canvas,
          translations['s3_eq'] ?? '2 × 1 1/4 = 2 1/2',
          const Offset(0, -120),
          color: Colors.green,
          fontSize: 24,
        );
      }
    } else if (scenario == 4) {
      drawDispenser(canvas, const Offset(-180, -50));
      if (s4HandleDown) {
        Jug? hasJug = s4Jugs.where((j) => j.state == 'under_tap').firstOrNull;
        double streamLen = 80;
        if (hasJug != null) streamLen = 80 - (hasJug.fill * 60);
        canvas.drawRect(
          Rect.fromLTWH(-144, 0, 8, streamLen),
          Paint()..color = Colors.orange.withOpacity(0.8),
        );
      }

      drawCylinder(canvas, const Offset(220, 80), s4CylFill);
      for (var j in s4Jugs) {
        if (j.state != 'poured') drawJug(canvas, j);
      }

      if (draggedItem != null && draggedItem!.startsWith('jug_')) {
        int id = int.parse(draggedItem!.split('_')[1]);
        Jug j = s4Jugs.firstWhere((x) => x.id == id);
        if (j.state == 'drag_pour') {
          canvas.drawRect(
            Rect.fromLTWH(j.x, j.y, 10, 80 - j.y),
            Paint()..color = Colors.orange.withOpacity(0.6),
          );
        }
      }

      if (phase == 'complete') {
        drawText(
          canvas,
          translations['s4_eq'] ?? '4 × 2/3 = 8/3 = 2 2/3',
          const Offset(0, -140),
          color: Colors.green,
          fontSize: 24,
        );
      }
    } else if (scenario == 5) {
      if (phase == 'init') {
        canvas.drawOval(
          const Rect.fromLTWH(-320, -50, 80, 20),
          Paint()..color = Colors.orange.shade700,
        );
        canvas.drawOval(
          const Rect.fromLTWH(-320, 10, 80, 20),
          Paint()..color = Colors.orange.shade700,
        );
        canvas.drawRect(
          const Rect.fromLTWH(-310, -40, 60, 60),
          Paint()..color = Colors.blue,
        );
        drawText(
          canvas,
          translations['s5_spool'] ?? 'SPOOL',
          const Offset(-280, -60),
          fontSize: 12,
        );
      }

      if (draggedItem == 'ribbons') {
        canvas.drawRect(
          Rect.fromLTWH(dragPos.dx - 90, dragPos.dy - 15, 180, 30),
          Paint()..color = Colors.blue.withOpacity(0.7),
        );
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-200, -30, 400, 120),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFF475569),
      );
      for (double i = -180; i < 200; i += 20) {
        canvas.drawLine(
          Offset(i, -30),
          Offset(i, 90),
          Paint()..color = Colors.white10,
        );
      }
      drawText(
        canvas,
        translations['s5_mat_0m'] ?? '0m',
        const Offset(-180, 80),
        fontSize: 14,
      );
      drawText(
        canvas,
        translations['s5_mat_1m'] ?? '1m',
        const Offset(0, 80),
        fontSize: 14,
      );
      drawText(
        canvas,
        translations['s5_mat_2m'] ?? '2m',
        const Offset(180, 80),
        fontSize: 14,
      );

      // Draw Project Box behind ribbons
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(180, 100, 120, 120),
          const Radius.circular(4),
        ),
        Paint()..color = Colors.green.shade600,
      );
      drawText(
        canvas,
        translations['s5_project'] ?? 'Project Box',
        const Offset(240, 115),
      );

      for (var r in s5Ribbons) {
        canvas.drawRect(
          Rect.fromLTWH(r['x'], r['y'], r['w'], r['h']),
          Paint()..color = r['glow'] ? Colors.redAccent : Colors.blue,
        );
        canvas.drawRect(
          Rect.fromLTWH(r['x'], r['y'], r['w'], r['h']),
          Paint()
            ..color = r['glow'] ? Colors.red : Colors.indigo
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        if (s5CutDone) {
          drawText(
            canvas,
            '1/$s5D',
            Offset(r['x'] + r['w'] / 2, r['y'] + r['h'] / 2),
            fontSize: 14,
          );
        }
      }

      if (phase == 'cut_ready' ||
          phase == 'drag_pieces' ||
          phase == 'complete') {
        double partW = 360 / s5D;
        if (s5N > 0 && !s5CutDone) {
          canvas.drawRect(
            Rect.fromLTWH(-180, 15, s5N * partW, 30),
            Paint()..color = Colors.lightBlueAccent.withOpacity(0.4),
          );
        }
        for (int i = 1; i < s5D; i++) {
          _drawDashedLine(
            canvas,
            Offset(-180 + i * partW, -10),
            Offset(-180 + i * partW, 70),
            Paint()
              ..color = Colors.redAccent
              ..strokeWidth = 3,
          );
        }
        if (!s5CutDone) {
          for (int i = 0; i < s5D; i++) {
            drawText(
              canvas,
              '1/$s5D',
              Offset(-180 + (i + 0.5) * partW, 30),
              fontSize: 14,
            );
          }
        }
      }

      if (s5MachineActive) {
        double mtx = draggedItem == 'machine' ? dragPos.dx : s5MachinePos.dx;
        double mty = draggedItem == 'machine' ? dragPos.dy : s5MachinePos.dy;
        drawFractionCutter(canvas, Offset(mtx, mty), 320, 140, s5D, s5N);
      }

      if (phase == 'complete') {
        drawText(
          canvas,
          translations['s5_eq'] ?? '3/4 × 2 = 6/4 = 1 1/2',
          const Offset(0, -120),
          color: Colors.green,
          fontSize: 24,
        );
      }
    }
  }

  @override
  bool shouldRepaint(FractionFactoryPainter oldDelegate) => true;
}
