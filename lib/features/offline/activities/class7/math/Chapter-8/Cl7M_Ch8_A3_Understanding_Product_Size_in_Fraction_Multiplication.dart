// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'dart:ui'; // Added to fix PointerDeviceKind
import 'package:flutter/scheduler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProductSizeLabApp());
}

class ProductSizeLabApp extends StatelessWidget {
  const ProductSizeLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Understanding Product Size',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFf59e0b), // Amber primary
          secondary: Color(0xFF10b981), // Emerald secondary
          surface: Color(0xFF1E293B),
        ),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
      ),
      home: const ProductSizeinFractionMultiplication(),
    );
  }
}

// --- AUDIO ENGINE ---
class AudioEngine {
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
  static final AudioPlayer _snapPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);

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
  static const String _snapUrl =
      'audio/class7/mixkit_392.mp3';

  static Future<void> init() async {
    // Fire and forget preloading to prevent TimeoutExceptions from blocking app startup.
    _clickPlayer.setSource(AssetSource(_clickUrl)).catchError((_) {});
    _successPlayer.setSource(AssetSource(_successUrl)).catchError((_) {});
    _errorPlayer.setSource(AssetSource(_errorUrl)).catchError((_) {});
    _fxPlayer.setSource(AssetSource(_alertUrl)).catchError((_) {});
    _shutterPlayer.setSource(AssetSource(_shutterUrl)).catchError((_) {});
    _snapPlayer.setSource(AssetSource(_snapUrl)).catchError((_) {});
  }

  static void play(String type) async {
    try {
      switch (type) {
        case 'click':
          await _clickPlayer.play(AssetSource(_clickUrl));
          break;
        case 'success':
          await _successPlayer.play(AssetSource(_successUrl));
          break;
        case 'error':
          await _errorPlayer.play(AssetSource(_errorUrl));
          break;
        case 'pop':
          await _fxPlayer.play(AssetSource(_alertUrl));
          break;
        case 'shutter':
          await _shutterPlayer.play(AssetSource(_shutterUrl));
          break;
        case 'snap':
          await _snapPlayer.play(AssetSource(_snapUrl));
          break;
        case 'rumble':
          await _errorPlayer.play(AssetSource(_errorUrl));
          break; // Reuse error for rumble
        case 'stretch':
          await _shutterPlayer.play(AssetSource(_shutterUrl));
          break; // Reuse shutter for stretch
      }
    } catch (e) {
      debugPrint("Audio Play Error: $e");
    }
  }
}

// --- LOCALIZATION ---
const Map<String, Map<String, String>> translations = {
  'en': {
    'appTitle': 'Understanding Product Size in Fraction Multiplication',
    'appSubtitle': 'Class 7 • WORKING WITH FRACTIONS',
    'enterLab': 'Enter Lab',
    'selectScenario': 'Select Scenario',
    'objectiveLbl': 'Mission Objective:',
    'stepLabel': 'STEP',
    'summaryTitle': 'Key Learning',
    'continueBtn': 'Awesome!',
    'langBtn': 'EN',
    'resetBtn': 'Reset',
    'errGear':
        'Try a fraction where the top number is bigger than the bottom number.',

    's1_title': '1. The Shrinking Effect: Whole Number x Proper Fraction',
    's1_obj':
        'To visually observe that multiplying a whole number by a fraction less than 1 results in a smaller product.',
    's1_hud1':
        "DRAG 'Dough Block (Size 4)' and DROP onto the input conveyor belt.",
    's1_t1':
        "<b>Observation:</b> The Dough Block (Size 4) is correctly placed at the start of the conveyor belt.",
    's1_hud2': "CLICK the glowing green 'START' button.",
    's1_t2':
        "<b>Observation:</b> The machine activates and processes the dough block. A shorter dough block emerges. The display shows '4 x 1/2 = 2'.",
    's1_hud3':
        "DRAG the smaller 'Dough Block (Size 2)' and DROP onto the 'Measurement Mat'.",
    's1_t3':
        "<b>Observation:</b> The output length is 2 units compared to the original 4 units. The visual comparison makes it obvious that the new block is shorter.",
    's1_hud4': "Observe the comparison. Summary panel appears automatically.",
    's1_t4':
        "<b>Learnt:</b> When we multiply 4 by 1/2, the result is 2. The product (2) is SMALLER than the original number (4). Multiplying by a fraction less than 1 shrinks the original amount.",
    's1_sum':
        "When we multiply 4 by 1/2, the result is 2. The product (2) is SMALLER than the original number (4). Multiplying by a fraction less than 1 shrinks the original amount.",

    's2_title': '2. The Double Shrink: Proper Fraction x Proper Fraction',
    's2_obj':
        'To visually observe that multiplying a proper fraction by another proper fraction results in an even smaller product.',
    's2_hud1':
        "DRAG the 'Dough Block (Size 1/2)' and DROP it onto the input conveyor belt.",
    's2_t1':
        "<b>Observation:</b> The Dough Block (Size 1/2) is correctly placed at the start of the conveyor belt.",
    's2_hud2': "CLICK the glowing green 'START' button.",
    's2_t2':
        "<b>Observation:</b> The machine animates and compresses the already small dough block. An even smaller block emerges. The display shows '1/2 x 1/2 = 1/4'.",
    's2_hud3':
        "DRAG the tiny 'Dough Block (Size 1/4)' and DROP it onto the 'Measurement Mat'.",
    's2_t3':
        "<b>Observation:</b> The output length is 1/4, which is smaller than the 1/2 block it came from.",
    's2_hud4': "Observe the comparison and read the summary panel.",
    's2_t4':
        "<b>Learnt:</b> When we multiply 1/2 by 1/2, the result is 1/4. The product (1/4) is SMALLER than both of the original fractions.",
    's2_sum':
        "When we multiply 1/2 by 1/2, the result is 1/4. The product (1/4) is SMALLER than both of the original fractions.",

    's3_title': '3. The Stretching Effect: Whole Number x Improper Fraction',
    's3_obj':
        'To visually observe that multiplying a whole number by a fraction greater than 1 results in a larger product.',
    's3_hud1':
        "DRAG the 'Dough Block (Size 2)' and DROP it onto the input conveyor belt.",
    's3_t1':
        "<b>Observation:</b> The block of size 2 is correctly placed on the conveyor belt.",
    's3_hud2': "CLICK the glowing green 'START' button.",
    's3_t2':
        "<b>Observation:</b> The machine STRETCHES the dough. A longer block emerges (size 3).",
    's3_hud3':
        "DRAG the longer 'Dough Block (Size 3)' and DROP it onto the 'Measurement Mat'.",
    's3_t3':
        "<b>Observation:</b> The output length is 3 units, visibly longer than the input of 2.",
    's3_hud4': "Observe the comparison and read the summary panel.",
    's3_t4':
        "<b>Learnt:</b> When we multiply 2 by 3/2, the result is 3. The product (3) is LARGER than the original number (2). Multiplying by an improper fraction stretches the amount.",
    's3_sum':
        "When we multiply 2 by 3/2, the result is 3. The product (3) is LARGER than the original number (2). Multiplying by an improper fraction stretches the amount.",

    's4_title': '4. Unsolved Challenge: Predict the Outcome',
    's4_obj':
        'To predict whether the product will be larger or smaller than the original number before seeing the result.',
    's4_hud1':
        "CLICK the button that describes the output: 'BIGGER' or 'SMALLER'.",
    's4_t1': "<b>Observation:</b> You selected a prediction.",
    's4_hud2':
        "CLICK the 'START' button to run the machine and see if you were right.",
    's4_t2':
        "<b>Observation:</b> The machine animates, compressing the dough. A new, shorter block of size 2 emerges.",
    's4_hud3':
        "DRAG the output 'Dough Block (Size 2)' to the 'Measurement Mat' to compare.",
    's4_t3':
        "<b>Observation:</b> The visual comparison makes it obvious that the new block is smaller.",
    's4_hud4': "Read the feedback panel.",
    's4_t4':
        "<b>Learnt:</b> Your prediction was CORRECT! The output (2) is smaller than the input (3). Remember: multiplying by a fraction less than 1 always results in a smaller number.",
    's4_sum':
        "Your prediction was CORRECT! The output (2) is smaller than the input (3). Remember: multiplying by a fraction less than 1 always results in a smaller number.",

    's5_title': '5. Unsolved Challenge: Be the Operator',
    's5_obj': 'Select the correct type of fraction to stretch the dough.',
    's5_hud1': "Mission: Make the output dough block LARGER than the input.",
    's5_t1': "<b>Observation:</b> The goal is to stretch the dough of size 2.",
    's5_hud2': "DRAG an improper fraction gear onto the 'Multiplier Dial'.",
    's5_t2':
        "<b>Observation:</b> An improper fraction gear was placed on the dial.",
    's5_hud3': "CLICK the 'START' button to run the machine.",
    's5_t3':
        "<b>Observation:</b> The machine uses the multiplier > 1 and stretches the dough.",
    's5_hud4':
        "DRAG the output block to the 'Measurement Mat' to confirm success.",
    's5_t4':
        "<b>Learnt:</b> Great job! To scale a number up, multiply it by a fraction greater than 1.",
    's5_sum':
        "Great job! You chose a fraction greater than 1, which stretched the dough and made the product larger.",
  },
  'hi': {
    'appTitle': 'भिन्न गुणन में उत्पाद का आकार समझना',
    'appSubtitle': 'कक्षा 7 • भिन्नों के साथ काम करना',
    'enterLab': 'लैब में प्रवेश करें',
    'selectScenario': 'परिदृश्य चुनें',
    'objectiveLbl': 'मिशन उद्देश्य:',
    'stepLabel': 'कदम',
    'summaryTitle': 'मुख्य सीख',
    'continueBtn': 'बहुत बढ़िया!',
    'langBtn': 'HI',
    'resetBtn': 'रीसेट',
    'errGear': 'ऐसा भिन्न चुनें जिसका ऊपर का भाग नीचे के भाग से बड़ा हो।',

    's1_title': '1. सिकुड़ने का प्रभाव: पूर्ण संख्या x उचित भिन्न',
    's1_obj':
        'यह दृश्य रूप से देखना कि किसी पूर्ण संख्या को 1 से छोटे भिन्न से गुणा करने पर छोटा उत्पाद मिलता है।',
    's1_hud1': "'आटे के ब्लॉक (आकार 4)' को इनपुट कन्वेयर पर खींचें।",
    's1_t1':
        "<b>अवलोकन:</b> आटे का ब्लॉक कन्वेयर बेल्ट पर अपनी जगह पर आ जाता है।",
    's1_hud2': "चमकते हरे 'START' बटन पर क्लिक करें।",
    's1_t2':
        "<b>अवलोकन:</b> मशीन आटे को संपीड़ित करती है। एक छोटा ब्लॉक निकलता है।",
    's1_hud3': "छोटे 'आटे के ब्लॉक (आकार 2)' को 'मापन मैट' पर खींचें।",
    's1_t3': "<b>अवलोकन:</b> आउटपुट की लंबाई 2 है जो मूल 4 से कम है।",
    's1_hud4': "सारांश पैनल पढ़ें।",
    's1_t4': "<b>सीखा:</b> उत्पाद (2) मूल (4) से छोटा है।",
    's1_sum':
        "जब हम 4 को 1/2 से गुणा करते हैं, तो परिणाम 2 होता है। उत्पाद (2) मूल संख्या (4) से छोटा है। उचित भिन्न से गुणा करने पर मात्रा सिकुड़ती है।",

    's2_title': '2. दोहरा सिकुड़न: उचित भिन्न x उचित भिन्न',
    's2_obj':
        'यह देखना कि दो उचित भिन्नों को गुणा करने पर और भी छोटा उत्पाद मिलता है।',
    's2_hud1': "'आटे के ब्लॉक (आकार 1/2)' को इनपुट कन्वेयर पर खींचें।",
    's2_t1': "<b>अवलोकन:</b> 1/2 आकार का ब्लॉक बेल्ट पर है।",
    's2_hud2': "हरे 'START' बटन पर क्लिक करें।",
    's2_t2':
        "<b>अवलोकन:</b> मशीन इसे और संपीड़ित करती है। एक और भी छोटा ब्लॉक निकलता है।",
    's2_hud3': "छोटे 'आटे के ब्लॉक (आकार 1/4)' को 'मापन मैट' पर खींचें।",
    's2_t3': "<b>अवलोकन:</b> लंबाई 1/4 है, जो इनपुट 1/2 से भी बहुत छोटी है।",
    's2_hud4': "तुलना करें और सारांश पढ़ें।",
    's2_t4': "<b>सीखा:</b> उत्पाद (1/4) दोनों भिन्नों से छोटा है।",
    's2_sum':
        "1/2 को 1/2 से गुणा करने पर 1/4 मिलता है। उत्पाद दोनों मूल भिन्नों से छोटा है।",

    's3_title': '3. खिंचाव का प्रभाव: पूर्ण संख्या x अनुचित भिन्न',
    's3_obj':
        'यह देखना कि 1 से बड़े भिन्न से गुणा करने पर बड़ा उत्पाद मिलता है।',
    's3_hud1': "'आटे के ब्लॉक (आकार 2)' को इनपुट कन्वेयर पर खींचें।",
    's3_t1': "<b>अवलोकन:</b> 2 आकार का ब्लॉक मशीन पर है।",
    's3_hud2': "हरे 'START' बटन पर क्लिक करें।",
    's3_t2':
        "<b>अवलोकन:</b> मशीन आटे को खींचती है। एक लंबा ब्लॉक निकलता है (आकार 3)।",
    's3_hud3': "लंबे आउटपुट ब्लॉक को 'मापन मैट' पर खींचें।",
    's3_t3': "<b>अवलोकन:</b> लंबाई 3 है, जो इनपुट 2 से बड़ी है।",
    's3_hud4': "तुलना करें और सारांश पढ़ें।",
    's3_t4': "<b>सीखा:</b> उत्पाद (3) मूल (2) से बड़ा है।",
    's3_sum':
        "2 को 3/2 से गुणा करने पर 3 मिलता है। उत्पाद (3) मूल संख्या (2) से बड़ा है।",

    's4_title': '4. अनसुलझी चुनौती: परिणाम की भविष्यवाणी',
    's4_obj': 'भविष्यवाणी करना कि उत्पाद बड़ा होगा या छोटा।',
    's4_hud1':
        "क्या आउटपुट बड़ा (BIGGER) होगा या छोटा (SMALLER)? अपनी भविष्यवाणी पर क्लिक करें।",
    's4_t1': "<b>अवलोकन:</b> आपने एक भविष्यवाणी चुनी।",
    's4_hud2': "मशीन चलाने के लिए 'START' बटन पर क्लिक करें और देखें।",
    's4_t2': "<b>अवलोकन:</b> मशीन आटे को 3 से 2 कर देती है।",
    's4_hud3': "सत्यापित करने के लिए आउटपुट को 'मापन मैट' पर खींचें।",
    's4_t3': "<b>अवलोकन:</b> छात्र दृश्य रूप से परिणाम की पुष्टि करता है।",
    's4_hud4': "फीडबैक पढ़ें।",
    's4_t4':
        "<b>सीखा:</b> उचित भिन्न से गुणा हमेशा छोटी संख्या देता है। आपकी भविष्यवाणी सही थी!",
    's4_sum':
        "आपकी भविष्यवाणी सही थी! 1 से छोटे भिन्न से गुणा करने पर हमेशा छोटी संख्या मिलती है।",

    's5_title': '5. अनसुलझी चुनौती: ऑपरेटर बनें',
    's5_obj': 'आटे को खींचने के लिए सही भिन्न चुनें।',
    's5_hud1': "मिशन: आउटपुट को इनपुट से बड़ा बनाएं।",
    's5_t1': "<b>अवलोकन:</b> लक्ष्य 2 आकार के आटे को खींचना है।",
    's5_hud2': "एक अनुचित भिन्न गियर को 'मल्टीप्लायर डायल' पर खींचें।",
    's5_t2': "<b>अवलोकन:</b> एक अनुचित भिन्न गियर डायल पर रखा गया।",
    's5_hud3': "मशीन चलाने के लिए 'START' बटन पर क्लिक करें।",
    's5_t3':
        "<b>अवलोकन:</b> मशीन 1 से बड़े गुणक का उपयोग करती है और आटे को खींचती है।",
    's5_hud4': "पुष्टि के लिए आउटपुट ब्लॉक को 'मापन मैट' पर खींचें।",
    's5_t4': "<b>सीखा:</b> बड़ा करने के लिए 1 से बड़े भिन्न से गुणा करें।",
    's5_sum':
        "बहुत बढ़िया! आपने 1 से बड़ा भिन्न चुना, जिसने आटे को खींचा और उत्पाद बड़ा हो गया।",
  },
};

// --- MODELS ---
class DoughBlock {
  double val;
  String label;
  double x, y;
  double origX, origY;
  bool visible;
  String zone;
  Color? color;

  DoughBlock({
    required this.val,
    required this.label,
    required this.x,
    required this.y,
    this.visible = true,
    this.zone = 'shelf',
    this.color,
  }) : origX = x,
       origY = y;
}

class Gear {
  String txt;
  double x, y;
  double origX, origY;

  Gear({required this.txt, required this.x, required this.y})
    : origX = x,
      origY = y;
}

// --- MAIN SCREEN ---
class ProductSizeinFractionMultiplication extends StatefulWidget {
  const ProductSizeinFractionMultiplication({super.key});

  @override
  State<ProductSizeinFractionMultiplication> createState() =>
      _ProductSizeinFractionMultiplicationState();
}

class _ProductSizeinFractionMultiplicationState
    extends State<ProductSizeinFractionMultiplication>
    with SingleTickerProviderStateMixin {
  bool _isSidebarOpen = true;
  bool _showCurtain = true;
  double _curtainOffset = 0;
  bool _isSuccessPopupVisible = false;

  String _lang = 'en';
  int _scenario = 1;
  int _step = 0;

  // Animation & Transform
  late Ticker _ticker;
  double _time = 0;
  final TransformationController _transformationController =
      TransformationController();

  // Lab State
  static const double unitSize = 40.0;
  DoughBlock? _inputBlock;
  DoughBlock? _outputBlock;
  final List<Gear> _gears = [];
  String _machineState = 'idle';
  double _machineProgress = 0.0;
  String _dialVal = "";
  String _displayTxt = "";
  String? _prediction; // 'SMALLER' or 'BIGGER'

  // Hitbox Coordinates (Canvas relative to center 0,0)
  final Rect _conveyorInRect = const Rect.fromLTWH(
    -210 - 160,
    10 - 12,
    320,
    24,
  ); // Center -210,10, w:320, h:24
  final Rect _conveyorOutRect = const Rect.fromLTWH(
    410 - 160,
    10 - 12,
    320,
    24,
  );
  final Rect _matRect = const Rect.fromLTWH(0 - 260, 160 - 50, 520, 100);
  final Offset _machineCenter = const Offset(100, -50);
  final double _machineW = 340;
  final Offset _shelfCenter = const Offset(-280, -100);

  // Dragging State
  dynamic _draggedItem;
  bool _isCanvasDragging = false;

  String getString(String key) =>
      translations[_lang]?[key] ?? translations['en']![key] ?? key;

  @override
  void initState() {
    super.initState();
    AudioEngine.init();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0;
        _updateMachineLogic();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.of(context).size.width < 768) {
        setState(() => _isSidebarOpen = false);
      }
      _resetZoom();
      _loadScenario(1);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ticker.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _enterLab() {
    AudioEngine.play('shutter');
    setState(() {
      _curtainOffset = -MediaQuery.of(context).size.height;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        _showCurtain = false;
        _ticker.start();
      });
    });
  }

  void _loadScenario(int index) {
    setState(() {
      _scenario = index;
      _step = 0;
      _machineState = 'idle';
      _machineProgress = 0.0;
      _dialVal = "";
      _prediction = null;
      _gears.clear();
      _isSuccessPopupVisible = false;

      double cy = _shelfCenter.dy - 20;

      if (index == 1) {
        _inputBlock = DoughBlock(val: 4, label: "4", x: _shelfCenter.dx, y: cy);
        _outputBlock = DoughBlock(
          val: 2,
          label: "2",
          x: _conveyorOutRect.center.dx,
          y: _conveyorOutRect.center.dy - 15,
          visible: false,
        );
        _dialVal = "1/2";
        _displayTxt = "READY";
      } else if (index == 2) {
        _inputBlock = DoughBlock(
          val: 0.5,
          label: "1/2",
          x: _shelfCenter.dx,
          y: cy,
        );
        _outputBlock = DoughBlock(
          val: 0.25,
          label: "1/4",
          x: _conveyorOutRect.center.dx,
          y: _conveyorOutRect.center.dy - 15,
          visible: false,
        );
        _dialVal = "1/2";
        _displayTxt = "READY";
      } else if (index == 3) {
        _inputBlock = DoughBlock(val: 2, label: "2", x: _shelfCenter.dx, y: cy);
        _outputBlock = DoughBlock(
          val: 3,
          label: "3",
          x: _conveyorOutRect.center.dx,
          y: _conveyorOutRect.center.dy - 15,
          visible: false,
        );
        _dialVal = "3/2";
        _displayTxt = "READY";
      } else if (index == 4) {
        _inputBlock = DoughBlock(
          val: 3,
          label: "3",
          x: _conveyorInRect.center.dx,
          y: _conveyorInRect.center.dy - 15,
          zone: 'in',
        );
        _outputBlock = DoughBlock(
          val: 2,
          label: "2",
          x: _conveyorOutRect.center.dx,
          y: _conveyorOutRect.center.dy - 15,
          visible: false,
        );
        _dialVal = "2/3";
        _displayTxt = "Input: 3";
      } else if (index == 5) {
        _inputBlock = DoughBlock(
          val: 2,
          label: "2",
          x: _conveyorInRect.center.dx,
          y: _conveyorInRect.center.dy - 15,
          zone: 'in',
        );
        _outputBlock = DoughBlock(
          val: 0,
          label: "",
          x: _conveyorOutRect.center.dx,
          y: _conveyorOutRect.center.dy - 15,
          visible: false,
        );
        _displayTxt = "Input: 2";
        List<String> vals = ["1/3", "3/4", "5/4", "4/2"];
        for (int i = 0; i < vals.length; i++) {
          _gears.add(
            Gear(
              txt: vals[i],
              x: _shelfCenter.dx - 75 + i * 50,
              y: _shelfCenter.dy - 5,
            ),
          );
        }
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resetZoom();
      });
    });
  }

  void _resetLab() {
    AudioEngine.play('error');
    setState(() {
      _lang = 'en';
      _isSidebarOpen = MediaQuery.of(context).size.width >= 768;
      _curtainOffset = 0;
      _showCurtain = true;
      _ticker.stop();
    });
    _loadScenario(1);
  }

  void _toggleLanguage() {
    AudioEngine.play('pop');
    setState(() {
      if (_lang == 'en') {
        _lang = 'hi';
      } else {
        _lang = 'en';
      }
    });
  }

  void _resetZoom() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    double effectiveSidebarWidth =
        _isSidebarOpen ? math.max(300.0, size.width * 0.30) : 0.0;

    double availableWidth = size.width - effectiveSidebarWidth;
    double availableHeight = size.height;

    double scaleX = availableWidth / 1200.0;
    double scaleY = availableHeight / 800.0;
    double scale = math.min(scaleX, scaleY) * 0.95; // 5% padding
    if (scale < 0.1) scale = 0.1;
    if (scale > 3.0) scale = 3.0;

    double dx = effectiveSidebarWidth + (availableWidth - (1200 * scale)) / 2;
    double dy = (availableHeight - (800 * scale)) / 2;

    _transformationController.value =
        Matrix4.identity()
          ..translateByDouble(dx, dy, 0.0, 1.0)
          ..scaleByDouble(scale, scale, 1.0, 1.0);
  }

  void _advanceStep() {
    AudioEngine.play('success');
    setState(() {
      _step++;
    });
  }

  void _updateMachineLogic() {
    if (_machineState == 'running') {
      _machineProgress += 0.015; // Drives animation loop
      if (_machineProgress > 1.0) {
        _machineState = 'done';
        _machineProgress = 1.0;

        if (_scenario == 1) {
          _displayTxt = "4 x 1/2 = 2";
        } else if (_scenario == 2) {
          _displayTxt = "1/2 x 1/2=1/4";
        } else if (_scenario == 3) {
          _displayTxt = "2 x 3/2 = 3";
        } else if (_scenario == 4) {
          _displayTxt = "3 x 2/3 = 2";
        }

        _advanceStep();
      } else {
        // Animate Dough
        if (_machineProgress < 0.3) {
          // Slide into machine
          double startX = _conveyorInRect.center.dx;
          double endX = _machineCenter.dx - _machineW / 2 + 40;
          _inputBlock!.x = startX + (endX - startX) * (_machineProgress / 0.3);
        } else if (_machineProgress >= 0.3 && _machineProgress < 0.7) {
          // Processing (hidden input, output at center)
          _inputBlock!.visible = false;
          _outputBlock!.visible = true;
          _outputBlock!.x = _machineCenter.dx - _machineW / 2 + 100;
          _outputBlock!.y = _machineCenter.dy + 40;
        } else {
          // Slide out
          _outputBlock!.visible = true;
          _outputBlock!.y = _conveyorOutRect.center.dy - 15;
          double startX = _machineCenter.dx + _machineW / 2 - 40;
          double endX = _conveyorOutRect.center.dx;
          _outputBlock!.x =
              startX + (endX - startX) * ((_machineProgress - 0.7) / 0.3);
        }
      }
    }
  }

  void _showSummary() {
    AudioEngine.play('success');
    setState(() {
      _isSuccessPopupVisible = true;
    });
  }

  bool _isStartBtnReady() {
    if (_scenario == 1 && _step == 1 && _inputBlock?.zone == 'in') return true;
    if (_scenario == 2 && _step == 1 && _inputBlock?.zone == 'in') return true;
    if (_scenario == 3 && _step == 1 && _inputBlock?.zone == 'in') return true;
    if (_scenario == 4 && _step == 1 && _prediction != null) return true;
    if (_scenario == 5 && _step == 1 && _dialVal.isNotEmpty) return true;
    return false;
  }

  Offset _getCanvasPoint(Offset localPos) {
    final Matrix4 inverse = Matrix4.copy(_transformationController.value)
      ..invert();
    final Offset scenePoint = MatrixUtils.transformPoint(inverse, localPos);
    // Adjust for Center (0,0) coordinate system
    return Offset(scenePoint.dx - 600, scenePoint.dy - 400);
  }

  void _handlePointerDown(PointerDownEvent e) {
    if (e.buttons != 1 && e.kind == PointerDeviceKind.mouse) {
      return; // Left click only
    }
    Offset worldPt = _getCanvasPoint(e.localPosition);

    // 1. Prediction Buttons (S4 Step 0)
    if (_scenario == 4 && _step == 0) {
      double px = 100, py = -280;
      Rect sBtn = Rect.fromLTWH(px - 150, py - 40, 150, 80);
      Rect bBtn = Rect.fromLTWH(px, py - 40, 150, 80);

      if (sBtn.contains(worldPt)) {
        setState(() {
          _prediction = 'SMALLER';
          AudioEngine.play('click');
          _advanceStep();
        });
        return;
      }
      if (bBtn.contains(worldPt)) {
        setState(() {
          _prediction = 'BIGGER';
          AudioEngine.play('click');
          _advanceStep();
        });
        return;
      }
    }

    // 2. Start Button
    if (_isStartBtnReady()) {
      Offset btnCenter = Offset(
        _machineCenter.dx + _machineW / 2 - 85,
        _machineCenter.dy + 130,
      );
      if ((worldPt - btnCenter).distance < 40) {
        setState(() {
          _machineState = 'running';
          _machineProgress = 0.0;
        });
        if (_outputBlock!.val > _inputBlock!.val) {
          AudioEngine.play('stretch');
        } else {
          AudioEngine.play('rumble');
        }
        return;
      }
    }

    // 3. Drag Blocks
    if (_step == 0 && _inputBlock != null && _inputBlock!.visible) {
      double w = math.max(80.0, _inputBlock!.val * unitSize + 20);
      if ((worldPt.dx - _inputBlock!.x).abs() < w / 2 &&
          (worldPt.dy - _inputBlock!.y).abs() < 35) {
        setState(() {
          _draggedItem = _inputBlock;
          _isCanvasDragging = true;
          AudioEngine.play('click');
        });
        return;
      }
    }
    if (_step == 2 && _outputBlock != null && _outputBlock!.visible) {
      double w = math.max(80.0, _outputBlock!.val * unitSize + 20);
      if ((worldPt.dx - _outputBlock!.x).abs() < w / 2 &&
          (worldPt.dy - _outputBlock!.y).abs() < 35) {
        setState(() {
          _draggedItem = _outputBlock;
          _isCanvasDragging = true;
          AudioEngine.play('click');
        });
        return;
      }
    }

    // 4. Drag Gears
    if (_scenario == 5 && _step == 0) {
      for (var g in _gears) {
        if ((worldPt - Offset(g.x, g.y)).distance < 35) {
          setState(() {
            _draggedItem = g;
            _isCanvasDragging = true;
            AudioEngine.play('click');
          });
          return;
        }
      }
    }
  }

  void _handlePointerMove(PointerMoveEvent e) {
    if (_draggedItem != null) {
      Offset worldPt = _getCanvasPoint(e.localPosition);
      setState(() {
        _draggedItem.x = worldPt.dx;
        _draggedItem.y = worldPt.dy;
      });
    }
  }

  void _handlePointerUp(PointerUpEvent e) {
    if (_draggedItem != null) {
      Offset worldPt = _getCanvasPoint(e.localPosition);
      bool dropped = false;

      if (_draggedItem is DoughBlock) {
        DoughBlock b = _draggedItem;
        // Drop on Conveyor In
        if (_step == 0 && _conveyorInRect.inflate(40).contains(worldPt)) {
          b.x = _conveyorInRect.center.dx;
          b.y = _conveyorInRect.center.dy - 15;
          b.zone = 'in';
          dropped = true;
          AudioEngine.play('snap');

          if (_scenario == 1) _displayTxt = "Input: 4";
          if (_scenario == 2) _displayTxt = "Input: 1/2";
          if (_scenario == 3) _displayTxt = "Input: 2";

          _advanceStep();
        }
        // Drop on Mat
        else if (_step == 2 && _matRect.inflate(40).contains(worldPt)) {
          double startGridX = _matRect.left + 40;
          b.x = startGridX + (b.val * unitSize) / 2;
          b.y = _matRect.center.dy;
          b.zone = 'mat';
          dropped = true;
          AudioEngine.play('snap');
          _advanceStep();
          Future.delayed(const Duration(milliseconds: 1500), _showSummary);
        }
      } else if (_draggedItem is Gear) {
        Gear g = _draggedItem;
        Offset dialCenter = Offset(
          _machineCenter.dx + _machineW / 2 - 85,
          _machineCenter.dy + 40,
        );

        if ((worldPt - dialCenter).distance < 60) {
          List<String> parts = g.txt.split('/');
          int num = int.parse(parts[0]);
          int den = int.parse(parts[1]);

          if (num > den) {
            // Correct gear logic (improper fraction)
            _dialVal = g.txt;
            _outputBlock!.val = _inputBlock!.val * (num / den);
            _outputBlock!.label = _outputBlock!.val
                .toStringAsFixed(1)
                .replaceAll('.0', ''); // simplify display
            _gears.remove(g);
            dropped = true;
            AudioEngine.play('snap');
            _advanceStep();
          } else {
            // Error logic
            AudioEngine.play('error');
            // Can show a transient snackbar or message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(getString('errGear')),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }

      setState(() {
        if (!dropped) {
          _draggedItem.x = _draggedItem.origX;
          _draggedItem.y = _draggedItem.origY;
          AudioEngine.play('pop');
        }
        _draggedItem = null;
        _isCanvasDragging = false;
      });
    }
  }

  List<Map<String, String>> _getSteps() {
    List<Map<String, String>> steps = [];
    for (int i = 1; i <= 4; i++) {
      steps.add({
        'hud': getString('s${_scenario}_hud$i'),
        'text': getString('s${_scenario}_t$i'),
      });
    }
    return steps;
  }

  Widget _htmlText(String text, TextStyle baseStyle) {
    List<TextSpan> spans = [];
    List<String> parts = text.split('<b>');
    for (int i = 0; i < parts.length; i++) {
      if (i == 0) {
        spans.add(TextSpan(text: parts[i].replaceAll('<br>', '\n')));
      } else {
        List<String> subParts = parts[i].split('</b>');
        if (subParts.isNotEmpty) {
          spans.add(
            TextSpan(
              text: subParts[0].replaceAll('<br>', '\n'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
          if (subParts.length > 1) {
            spans.add(TextSpan(text: subParts[1].replaceAll('<br>', '\n')));
          }
        }
      }
    }
    return RichText(text: TextSpan(style: baseStyle, children: spans));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.30;
    if (sidebarWidth < 300) sidebarWidth = 300;

    List<Map<String, String>> currentSteps = _getSteps();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // --- MAIN CANVAS AREA ---
            Positioned.fill(
              child: Container(
                color: const Color(0xFF0F172A),
                child: Listener(
                  onPointerDown: _handlePointerDown,
                  onPointerMove: _handlePointerMove,
                  onPointerUp: _handlePointerUp,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    panEnabled:
                        !_isCanvasDragging, // Disable pan when dragging items
                    scaleEnabled: !_isCanvasDragging,
                    minScale: 0.1,
                    maxScale: 4.0,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    constrained: false,
                    child: SizedBox(
                      width: 1200,
                      height: 800,
                      child: CustomPaint(
                        painter: LabPainter(
                          time: _time,
                          scenario: _scenario,
                          step: _step,
                          machineState: _machineState,
                          machineProgress: _machineProgress,
                          machineDial: _dialVal,
                          displayTxt: _displayTxt,
                          prediction: _prediction,
                          inputBlock: _inputBlock,
                          outputBlock: _outputBlock,
                          gears: _gears,
                          draggedItem: _draggedItem,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- BOTTOM HUD ---
            if (_step < currentSteps.length && !_isSuccessPopupVisible)
              Positioned(
                bottom: 24,
                left: _isSidebarOpen ? sidebarWidth : 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    constraints: const BoxConstraints(maxWidth: 700),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: const Border(
                        top: BorderSide(color: Colors.amber, width: 4),
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black45, blurRadius: 20),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.touch_app,
                            color: Colors.amberAccent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            currentSteps[_step]['hud']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // --- LEFT SIDEBAR (Completely scrollable from top to bottom) ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: Material(
                elevation: 16,
                color: const Color(0xFF1E293B).withOpacity(0.98),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getString('appTitle'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              getString('appSubtitle'),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.amberAccent,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Controls Row
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.language, size: 18),
                                label: Text(getString('langBtn')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF334155),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _toggleLanguage,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.refresh, size: 18),
                                label: Text(getString('resetBtn')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent.withOpacity(
                                    0.2,
                                  ),
                                  foregroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _resetLab,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 1),

                      // Main Scrollable Body Area
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Scenario Dropdown
                            Text(
                              getString('selectScenario'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  value: _scenario,
                                  dropdownColor: const Color(0xFF0F172A),
                                  items:
                                      [1, 2, 3, 4, 5]
                                          .map(
                                            (s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(
                                                getString('s${s}_title'),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      AudioEngine.play('pop');
                                      _loadScenario(val);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Objective Box
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.amber.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.track_changes,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        getString('objectiveLbl'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    getString('s${_scenario}_obj'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Steps
                            ...List.generate(currentSteps.length, (index) {
                              bool isPast = index < _step;
                              bool isCurrent = index == _step;

                              Color bgColor =
                                  isPast
                                      ? Colors.white10
                                      : (isCurrent
                                          ? Colors.amber.withOpacity(0.15)
                                          : Colors.transparent);
                              Color borderColor =
                                  isCurrent ? Colors.amber : Colors.transparent;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  border: Border.all(color: borderColor),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isPast)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.greenAccent,
                                        size: 28,
                                      )
                                    else
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color:
                                              isCurrent
                                                  ? Colors.amber
                                                  : Colors.white24,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isCurrent
                                                    ? Colors.black
                                                    : Colors.white,
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
                                            '${getString('stepLabel')} ${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white54,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          _htmlText(
                                            currentSteps[index]['text']!,
                                            TextStyle(
                                              fontSize: 14,
                                              color:
                                                  isPast
                                                      ? Colors.white70
                                                      : (isCurrent
                                                          ? Colors.white
                                                          : Colors.white38),
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // Key Learning Injection
                            if (_isSuccessPopupVisible || _step >= 4)
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 20,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.amber,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.lightbulb,
                                          color: Colors.amberAccent,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          getString('summaryTitle'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amberAccent,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      getString('s${_scenario}_sum'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Footer
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white12),
                          ),
                        ),
                        child: const Text(
                          "© ZeroScienceLab - Fall in love with math and Science",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- MENU ICON (TOP LEFT) ---
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.amberAccent,
                iconSize: 28,
                onPressed: () {
                  AudioEngine.play('pop');
                  setState(() => _isSidebarOpen = !_isSidebarOpen);
                  // Allow animation to finish before snapping to the new zoom bounds
                  Future.delayed(const Duration(milliseconds: 350), () {
                    _resetZoom();
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // --- SUCCESS POPUP ---
            if (_isSuccessPopupVisible)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.amber, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white54,
                                ),
                                onPressed: () {
                                  AudioEngine.play('click');
                                  setState(
                                    () => _isSuccessPopupVisible = false,
                                  );
                                },
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lightbulb,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              getString('summaryTitle'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              getString('s${_scenario}_sum'),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                AudioEngine.play('pop');
                                setState(() {
                                  _isSuccessPopupVisible = false;
                                  if (_scenario < 5) {
                                    _loadScenario(_scenario + 1);
                                  } else {
                                    _resetLab();
                                  }
                                });
                              },
                              icon: const Icon(Icons.thumb_up),
                              label: Text(
                                _scenario == 5
                                    ? getString('resetBtn')
                                    : getString('continueBtn'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10b981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
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
              ),

            // --- CURTAIN (ENTRY SCREEN) ---
            if (_showCurtain)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeInOutCubic,
                top: _curtainOffset,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height,
                child: Container(
                  color: const Color(0xFF020617),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.change_history,
                          size: 80,
                          color: Colors.amber,
                        ), // Replace SVG with generic icon for size
                        const SizedBox(height: 24),
                        Text(
                          getString('appTitle'),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          getString('appSubtitle'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 48),
                        ElevatedButton.icon(
                          onPressed: _enterLab,
                          icon: const Icon(Icons.play_circle_fill, size: 28),
                          label: Text(
                            getString('enterLab'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                          ),
                        ),
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

// --- CANVAS PAINTER ---
class LabPainter extends CustomPainter {
  final double time;
  final int scenario;
  final int step;
  final String machineState;
  final double machineProgress;
  final String machineDial;
  final String displayTxt;
  final String? prediction;
  final DoughBlock? inputBlock;
  final DoughBlock? outputBlock;
  final List<Gear> gears;
  final dynamic draggedItem;

  LabPainter({
    required this.time,
    required this.scenario,
    required this.step,
    required this.machineState,
    required this.machineProgress,
    required this.machineDial,
    required this.displayTxt,
    this.prediction,
    this.inputBlock,
    this.outputBlock,
    required this.gears,
    this.draggedItem,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Coordinate Center mapping (Center of 1200x800 canvas)
    canvas.translate(size.width / 2, size.height / 2);

    // Floor and Grid
    canvas.drawRect(
      const Rect.fromLTWH(-2000, 60, 4000, 2000),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawLine(
      const Offset(-2000, 60),
      const Offset(2000, 60),
      Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 4,
    );

    Paint bgGridPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..strokeWidth = 1;
    for (double i = -1000; i < 1000; i += 40) {
      canvas.drawLine(Offset(i, -1000), Offset(i, 1000), bgGridPaint);
      canvas.drawLine(Offset(-1000, i), Offset(1000, i), bgGridPaint);
    }

    _drawShelf(canvas, -280, -100);
    _drawChef(canvas, -420, -50);

    // Conveyors
    _drawConveyor(canvas, -210, 10, 320, 24);
    _drawConveyor(canvas, 410, 10, 320, 24);

    // Mat
    _drawMat(canvas, 0, 160, 520, 100);

    // Machine
    _drawMachine(canvas, 100, -50, 340, 220);

    // Blocks
    if (inputBlock != null && inputBlock!.visible) {
      _drawBlock(canvas, inputBlock!);
    }
    if (outputBlock != null && outputBlock!.visible) {
      _drawBlock(canvas, outputBlock!);
    }

    // Dragged Item (draw last to be on top)
    if (draggedItem != null) {
      if (draggedItem is DoughBlock) {
        _drawBlock(canvas, draggedItem);
      } else if (draggedItem is Gear) {
        _drawGear(canvas, draggedItem);
      }
    }

    // Prediction Box
    if (scenario == 4 && (step == 0 || step == 1)) {
      _drawPredictionBox(canvas, 100, -280);
    }

    // Gears
    if (scenario == 5 && step == 0) {
      TextPainter tp = TextPainter(
        text: const TextSpan(
          text: "FRACTION GEARS",
          style: TextStyle(
            color: Color(0xFF94a3b8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-280 - tp.width / 2, -145));
      for (var g in gears) {
        if (g != draggedItem) _drawGear(canvas, g);
      }
    }
  }

  void _drawChef(Canvas canvas, double x, double y) {
    canvas.save();
    canvas.translate(x, y);
    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 110), width: 80, height: 20),
      Paint()..color = Colors.black.withOpacity(0.3),
    );
    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-25, 20, 50, 70),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFFf1f5f9),
    );
    // Buttons
    Paint btnPaint = Paint()..color = const Color(0xFF94a3b8);
    canvas.drawCircle(const Offset(-8, 40), 3, btnPaint);
    canvas.drawCircle(const Offset(8, 40), 3, btnPaint);
    canvas.drawCircle(const Offset(-8, 60), 3, btnPaint);
    canvas.drawCircle(const Offset(8, 60), 3, btnPaint);
    // Scarf
    Path scarf =
        Path()
          ..moveTo(-15, 20)
          ..lineTo(15, 20)
          ..lineTo(0, 40)
          ..close();
    canvas.drawPath(scarf, Paint()..color = const Color(0xFFef4444));
    // Head & Hair
    canvas.drawCircle(
      Offset.zero,
      24,
      Paint()..color = const Color(0xFFfde68a),
    ); // Skin
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, -5), radius: 25),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFF451a03),
    );
    // Hat
    Paint hatPaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(0, -35), 25, hatPaint);
    canvas.drawCircle(const Offset(-18, -25), 18, hatPaint);
    canvas.drawCircle(const Offset(18, -25), 18, hatPaint);
    canvas.drawRect(const Rect.fromLTWH(-25, -20, 50, 18), hatPaint);
    canvas.drawRect(
      const Rect.fromLTWH(-25, -20, 50, 18),
      Paint()
        ..color = const Color(0xFFe2e8f0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Face
    canvas.drawCircle(
      const Offset(-8, 2),
      4,
      Paint()..color = const Color(0xFF451a03),
    );
    canvas.drawCircle(
      const Offset(8, 2),
      4,
      Paint()..color = const Color(0xFF451a03),
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 10), radius: 6),
      0,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF451a03)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Arms
    Paint armPaint =
        Paint()
          ..color = const Color(0xFFf1f5f9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-25, 30), const Offset(-40, 50), armPaint);
    canvas.drawLine(const Offset(25, 30), const Offset(40, 50), armPaint);
    // Hands
    canvas.drawCircle(
      const Offset(-40, 50),
      8,
      Paint()..color = const Color(0xFFfde68a),
    );
    canvas.drawCircle(
      const Offset(40, 50),
      8,
      Paint()..color = const Color(0xFFfde68a),
    );
    // Legs & Shoes
    canvas.drawRect(
      const Rect.fromLTWH(-18, 80, 12, 30),
      Paint()..color = const Color(0xFF1e293b),
    );
    canvas.drawRect(
      const Rect.fromLTWH(6, 80, 12, 30),
      Paint()..color = const Color(0xFF1e293b),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-12, 110), width: 28, height: 16),
      Paint()..color = const Color(0xFF0f172a),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(12, 110), width: 28, height: 16),
      Paint()..color = const Color(0xFF0f172a),
    );
    canvas.restore();
  }

  void _drawShelf(Canvas canvas, double x, double y) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: 200, height: 15),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF8b5a2b),
    );
    canvas.drawRect(
      Rect.fromLTWH(x - 100 + 20, y + 7.5, 10, 30),
      Paint()..color = const Color(0xFF5c4033),
    );
    canvas.drawRect(
      Rect.fromLTWH(x + 100 - 30, y + 7.5, 10, 30),
      Paint()..color = const Color(0xFF5c4033),
    );
  }

  void _drawConveyor(Canvas canvas, double x, double y, double w, double h) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: w, height: h),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFF334155),
    );

    double offset = (time * 100) % 20;
    Paint lineP =
        Paint()
          ..color = const Color(0xFF64748b)
          ..strokeWidth = 3;
    for (double i = x - w / 2 + 10; i < x + w / 2 - 10; i += 20) {
      double lx = i + (machineState == 'running' ? offset : 0);
      if (lx > x + w / 2 - 10) lx -= (w - 20);
      canvas.drawLine(Offset(lx, y - h / 2), Offset(lx, y + h / 2), lineP);
    }
  }

  void _drawMat(Canvas canvas, double x, double y, double w, double h) {
    Rect r = Rect.fromCenter(center: Offset(x, y), width: w, height: h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(12)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(12)),
      Paint()
        ..color = const Color(0xFFef4444)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    double startGridX = x - w / 2 + 40;
    Paint gridP =
        Paint()
          ..color = const Color(0xFF38bdf8).withOpacity(0.4)
          ..strokeWidth = 2;
    for (int i = 0; i <= 10; i++) {
      double lx = startGridX + (i * 40.0);
      if (lx < x + w / 2 - 10) {
        canvas.drawLine(
          Offset(lx, y - h / 2 + 8),
          Offset(lx, y + h / 2 - 25),
          gridP,
        );
        TextPainter tp = TextPainter(
          text: TextSpan(
            text: i.toString(),
            style: const TextStyle(
              color: Color(0xFF64748b),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(lx - tp.width / 2, y + h / 2 - 20));
      }
    }
  }

  void _drawMachine(Canvas canvas, double x, double y, double w, double h) {
    canvas.save();
    if (machineState == 'running' &&
        machineProgress > 0.3 &&
        machineProgress < 0.7) {
      canvas.translate(math.sin(time * 50) * 4, math.Random().nextDouble() * 3);
    }
    canvas.translate(x, y);

    // Main Chassis
    Rect r = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(24)),
      Paint()..color = const Color(0xFFcbd5e1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(24)),
      Paint()
        ..color = const Color(0xFF94a3b8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Inner Window
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(20, 40), width: w - 180, height: 100),
        const Radius.circular(16),
      ),
      Paint()..color = const Color(0xFF1e293b),
    );

    // Rollers inside window
    canvas.save();
    canvas.translate(100, 40);
    double armOffset = 0;
    if (machineState == 'running' &&
        machineProgress > 0.3 &&
        machineProgress < 0.7) {
      double localP = (machineProgress - 0.3) / 0.4;
      armOffset = math.sin(localP * math.pi) * 15;
    }
    Paint rollerP = Paint()..color = const Color(0xFF94a3b8);
    canvas.drawRect(Rect.fromLTWH(-10, -50 + armOffset, 20, 40), rollerP);
    canvas.drawCircle(Offset(0, -10 + armOffset), 15, rollerP);
    canvas.drawRect(Rect.fromLTWH(-10, 10 - armOffset, 20, 40), rollerP);
    canvas.drawCircle(Offset(0, 10 - armOffset), 15, rollerP);
    canvas.restore();

    // Display
    Rect dRect = Rect.fromCenter(
      center: Offset(w / 2 - 85, -h / 2 + 45),
      width: 130,
      height: 50,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(dRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF0f172a),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(dRect, const Radius.circular(8)),
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    TextPainter tpDisp = TextPainter(
      text: TextSpan(
        text: displayTxt.isEmpty ? "READY" : displayTxt,
        style: const TextStyle(
          color: Color(0xFF10b981),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpDisp.paint(
      canvas,
      Offset(
        dRect.center.dx - tpDisp.width / 2,
        dRect.center.dy - tpDisp.height / 2,
      ),
    );

    // Dial Area
    Offset dialCenter = Offset(w / 2 - 85, 40);
    canvas.drawCircle(dialCenter, 35, Paint()..color = const Color(0xFFe2e8f0));
    canvas.drawCircle(
      dialCenter,
      35,
      Paint()
        ..color = const Color(0xFF94a3b8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    if (machineDial.isNotEmpty) {
      TextPainter tpd = TextPainter(
        text: TextSpan(
          text: machineDial,
          style: const TextStyle(
            color: Color(0xFF0f172a),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpd.paint(canvas, dialCenter - Offset(tpd.width / 2, tpd.height / 2));
    } else if (scenario == 5) {
      TextPainter tpd = TextPainter(
        text: const TextSpan(
          text: "DROP",
          style: TextStyle(
            color: Colors.black38,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpd.paint(canvas, dialCenter - Offset(tpd.width / 2, tpd.height / 2));
      canvas.drawCircle(
        dialCenter,
        38,
        Paint()
          ..color = Color.fromRGBO(
            245,
            158,
            11,
            0.5 + math.sin(time * 10) * 0.5,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }

    // Start Button
    bool btnReady = false;
    if (scenario == 1 && step == 1 && inputBlock?.zone == 'in') btnReady = true;
    if (scenario == 2 && step == 1 && inputBlock?.zone == 'in') btnReady = true;
    if (scenario == 3 && step == 1 && inputBlock?.zone == 'in') btnReady = true;
    if (scenario == 4 && step == 1 && prediction != null) btnReady = true;
    if (scenario == 5 && step == 1 && machineDial.isNotEmpty) btnReady = true;

    Offset btnCenter = Offset(w / 2 - 85, 130);
    Color btnColor =
        btnReady
            ? Color.fromRGBO(16, 185, 129, 0.8 + math.sin(time * 10) * 0.2)
            : const Color(0xFF064e3b);
    canvas.drawCircle(btnCenter, 25, Paint()..color = btnColor);

    if (scenario == 4 && step == 1 && btnReady) {
      canvas.drawCircle(
        btnCenter,
        25,
        Paint()
          ..color = Color.fromRGBO(
            16,
            185,
            129,
            0.4 + math.sin(time * 10) * 0.4,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      );
    } else {
      canvas.drawCircle(
        btnCenter,
        25,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    TextPainter tpS = TextPainter(
      text: const TextSpan(
        text: "START",
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpS.paint(canvas, btnCenter - Offset(tpS.width / 2, tpS.height / 2));

    // Label
    TextPainter tpL = TextPainter(
      text: const TextSpan(
        text: "Scaling Machine",
        style: TextStyle(
          color: Color(0xFF334155),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpL.paint(canvas, Offset(-w / 2 + 20, -h / 2 + 25));

    canvas.restore();
  }

  void _drawBlock(Canvas canvas, DoughBlock b) {
    if (draggedItem != b && !b.visible) return; // if dragging, force draw
    canvas.save();
    canvas.translate(b.x, b.y);
    double w = b.val * 40.0;
    double h = 30.0;

    // Ghost comparison
    if (b.zone == 'mat' && inputBlock != null) {
      double ghostW = inputBlock!.val * 40.0;
      Rect ghostR = Rect.fromLTWH(
        -ghostW / 2 - (ghostW - w) / 2,
        -h / 2 - 40,
        ghostW,
        h,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(ghostR, const Radius.circular(8)),
        Paint()
          ..color = const Color(0x66f8fafc)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      TextPainter tpg = TextPainter(
        text: TextSpan(
          text: "Original Input: ${inputBlock!.val}",
          style: const TextStyle(
            color: Color(0xFFcbd5e1),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpg.paint(canvas, Offset(-(ghostW - w) / 2 - tpg.width / 2, -h / 2 - 60));

      TextPainter tpp = TextPainter(
        text: TextSpan(
          text: "Product: ${b.val}",
          style: const TextStyle(
            color: Color(0xFFf8fafc),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpp.paint(canvas, Offset(-tpp.width / 2, -h / 2 - 20));
    }

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 5), width: w, height: h),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.black.withOpacity(0.3),
    );
    // Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        const Radius.circular(8),
      ),
      Paint()..color = b.color ?? const Color(0xFFfef08a),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        const Radius.circular(8),
      ),
      Paint()
        ..color = const Color(0xFFd97706)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Texture
    Paint texP =
        Paint()
          ..color = const Color(0xFFd97706).withOpacity(0.3)
          ..strokeWidth = 1;
    for (double i = -w / 2 + 10; i < w / 2 - 5; i += 15) {
      canvas.drawLine(Offset(i, -h / 2 + 4), Offset(i - 3, h / 2 - 4), texP);
    }

    TextPainter tp = TextPainter(
      text: TextSpan(
        text: b.label,
        style: const TextStyle(
          color: Color(0xFF78350f),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Handle small fractions overflowing visually
    if (tp.width > w - 4) {
      // Draw above the block if it's too small
      tp.paint(canvas, Offset(-tp.width / 2, -h / 2 - tp.height - 4));
    } else {
      // Draw centered
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    }

    canvas.restore();
  }

  void _drawPredictionBox(Canvas canvas, double px, double py) {
    canvas.save();
    canvas.translate(px, py);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-150, -40, 300, 80),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFF1e293b).withOpacity(0.95),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-150, -40, 300, 80),
        const Radius.circular(12),
      ),
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    TextPainter tp = TextPainter(
      text: const TextSpan(
        text: "Output will be:",
        style: TextStyle(
          color: Color(0xFFf8fafc),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -25));

    Color sColor =
        prediction == 'SMALLER'
            ? const Color(0xFF3b82f6)
            : const Color(0xFF64748b);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-120, 5, 100, 30),
        const Radius.circular(6),
      ),
      Paint()..color = sColor,
    );
    TextPainter tpS = TextPainter(
      text: const TextSpan(
        text: "SMALLER",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpS.paint(canvas, Offset(-70 - tpS.width / 2, 20 - tpS.height / 2));

    Color bColor =
        prediction == 'BIGGER'
            ? const Color(0xFFeab308)
            : const Color(0xFF64748b);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(20, 5, 100, 30),
        const Radius.circular(6),
      ),
      Paint()..color = bColor,
    );
    TextPainter tpB = TextPainter(
      text: const TextSpan(
        text: "BIGGER",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpB.paint(canvas, Offset(70 - tpB.width / 2, 20 - tpB.height / 2));

    canvas.restore();
  }

  void _drawGear(Canvas canvas, Gear g) {
    canvas.save();
    canvas.translate(g.x, g.y);
    Paint p = Paint()..color = const Color(0xFF475569);

    // Draw Teeth
    Path gearP = Path();
    for (int i = 0; i < 8; i++) {
      double ang = (i / 8) * math.pi * 2 + time;
      gearP.moveTo(math.cos(ang) * 15, math.sin(ang) * 15);
      gearP.lineTo(math.cos(ang) * 25, math.sin(ang) * 25);
      gearP.arcTo(
        Rect.fromCircle(center: Offset.zero, radius: 25),
        ang,
        0.3,
        false,
      );
      gearP.lineTo(math.cos(ang + 0.3) * 15, math.sin(ang + 0.3) * 15);
    }
    canvas.drawPath(gearP, p);

    canvas.drawCircle(
      Offset.zero,
      18,
      Paint()..color = const Color(0xFFf8fafc),
    );
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: g.txt,
        style: const TextStyle(
          color: Color(0xFF0f172a),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
