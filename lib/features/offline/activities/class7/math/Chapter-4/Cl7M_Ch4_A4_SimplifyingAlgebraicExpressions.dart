// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: unnecessary_to_list_in_spreads, deprecated_member_use

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab | Simplifying Algebraic Expressions',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        primaryColor: const Color(0xFFEAB308), // Yellow 500
        fontFamily: 'Roboto', // Closest default to Plus Jakarta Sans
      ),
      home: const SimplifyingAlgebraicExpressions(),
    ),
  );
}

// Models
class Fruit {
  final String id;
  final String type; // 'apple', 'banana', 'xFruit', 'yFruit'
  final bool isFresh;
  String? binId;
  bool isComposted;
  double x;
  double y;
  final double originalX;
  final double originalY;

  Fruit({
    required this.id,
    required this.type,
    this.isFresh = true,
    required this.x,
    required this.y,
    this.binId,
    this.isComposted = false,
  }) : originalX = x,
       originalY = y;
}

class Bin {
  final String id;
  final String labelKey;
  final List<String> accepts;
  final bool isCompost;
  int count;
  Fruit? waitingFruit;
  double x;
  double y;

  Bin({
    required this.id,
    required this.labelKey,
    required this.accepts,
    this.isCompost = false,
    this.count = 0,
    this.waitingFruit,
    required this.x,
    required this.y,
  });
}

class SimplifyingAlgebraicExpressions extends StatefulWidget {
  const SimplifyingAlgebraicExpressions({super.key});

  @override
  State<SimplifyingAlgebraicExpressions> createState() =>
      _SimplifyingAlgebraicExpressionsState();
}

class _SimplifyingAlgebraicExpressionsState
    extends State<SimplifyingAlgebraicExpressions>
    with SingleTickerProviderStateMixin {
  // State Variables
  bool _isSidebarOpen = true;
  bool _showCurtain = true;
  bool _showSummary = false;
  bool _isFirstLoad = true;
  bool _labelsVisible = true;
  bool _panEnabled = true;

  String _lang = 'en';
  int _scenario = 1;
  int _step = 0;

  final List<Fruit> _fruits = [];
  final List<Bin> _bins = [];

  final AudioPlayer _player = AudioPlayer();
  final TransformationController _transformController =
      TransformationController();

  // Animation for curtain
  late AnimationController _curtainAnimController;
  late Animation<Offset> _curtainOffset;

  // Localization Dictionary (Telugu removed)
  final Map<String, Map<String, String>> i18n = {
    'en': {
      'title': 'Simplifying Algebraic Expressions: The Fruit Sorter Challenge',
      'subtitle': 'Class 7 • EXPRESSIONS USING LETTER-NUMBERS',
      'enterLab': 'Enter Lab',
      'currentExp': 'Current Expression',
      'actionInfo': 'Action Info',
      'interactObj': 'Interact with the objects.',
      'selectScen': 'Select Scenario',
      'scen1': '1. The Fruit Basket Mix-up',
      'scen2': '2. Fresh vs. Rotten',
      'theory': 'Theory',
      'procSteps': 'Procedural Steps',
      'step': 'Step',
      'startSort': 'Start Sorting',
      'startComp': 'Start Composting',
      'nextStep': 'Next Step',
      'validating': 'Complete task...',
      'valModel': 'Validate Model',
      'scenSum': 'Scenario Summary',
      'compScen': 'Complete Scenario',
      'modelVal': 'MODEL VALIDATED',
      'scenComp': 'Scenario Completed successfully',
      'binA': 'Bin-A',
      'binB': 'Bin-B',
      'binX': 'Bin-X',
      'binY': 'Bin-Y',
      'compBin': 'Compost Bin',
      'applesText': 'Apples: ',
      'bananasText': 'Bananas: ',
      'xfruitsText': 'X-Fruits: ',
      'yfruitsText': 'Y-Fruits: ',
      'xFruitsStr': 'X-FRUITS',
      'yFruitsStr': 'Y-FRUITS',
      'cancelOut': '+ & - cancel to 0',
      'footer': '© ZEROSCIENCELAB | Fall in Love with Math and Science',

      // Scenario 1 Data
      's1_obj':
          'To understand the basic concept of combining positive like terms by physically sorting different types of fruit.',
      's1_sum':
          "By physically moving identical fruits into their respective bins, we demonstrated that 'like terms' (terms with the same variable, like 2a and 4a) can be added together. The apples (a) combined to make 6a, and the bananas (b) remained 3b.",
      's1_d1':
          "Observe the expression 2a + 3b + 4a at the top of the screen. Notice the conveyor tray below, which has brought a mix of apples (a) and bananas (b). CLICK the 'Start Sorting' button to start the sorting.",
      's1_ht1': "Observe & Start",
      's1_hd1': "Check the expression and click 'Start Sorting'.",
      's1_d2':
          "DRAG all the apples (a) from the tray and DROP them into the bin labeled 'a'.",
      's1_ht2': "Sort All Apples",
      's1_hd2': "Drag every Red Apple into Bin-A.",
      's1_d3':
          "DRAG all the bananas (b) from the tray and DROP them into the bin labeled 'b'.",
      's1_ht3': "Sort All Bananas",
      's1_hd3': "Drag every Yellow Banana into Bin-B.",
      's1_d4':
          "Observe the final result. The tray is now empty, and the bins show the total count for each fruit.",
      's1_ht4': "Scenario Complete!",
      's1_hd4': "Click Validate Model to see the summary.",

      // Scenario 2 Data
      's2_obj':
          'To understand how to combine positive and negative like terms by cancelling out opposite pairs.',
      's2_sum':
          "By pairing fresh fruits (positive terms) with rotten fruits (negative terms) in the compost bin, we saw how opposites cancel each other out to zero. The remaining fruits represent the simplified expression.",
      's2_d1':
          "Fresh fruits have a green + (positive). Rotten fruits have a red - (negative). Observe the setup and CLICK 'Start Composting'.",
      's2_ht1': "Observe the Fruits",
      's2_hd1': "Green (+) is positive, Red (-) is negative. Click Start.",
      's2_d2':
          "DRAG ONE fresh X-Fruit (+) and ONE rotten X-Fruit (-) to the Compost Bin to cancel them out.",
      's2_ht2': "Compost One 'X' Pair",
      's2_hd2': "Drag one (+) X-Fruit and one (-) X-Fruit to Compost.",
      's2_d3':
          "Continue composting the X-Fruits. DRAG and DROP the remaining pairs of fresh and rotten X-Fruits into the Compost Bin until no more pairs can be made.",
      's2_ht3': "Compost All 'X' Pairs",
      's2_hd3': "Keep matching (+) and (-) X-Fruits to zero them out.",
      's2_d4':
          "DRAG and DROP pairs of fresh and rotten Y-Fruits into the Compost Bin.",
      's2_ht4': "Compost All 'Y' Pairs",
      's2_hd4': "Match (+) Y-Fruits with (-) Y-Fruits in the Compost Bin.",
      's2_d5':
          "DRAG the remaining fruits on the platform to their correct sorting bins.",
      's2_ht5': "Sort the Remaining Fruits",
      's2_hd5': "Drag leftover X-Fruits to Bin X and Y-Fruits to Bin Y.",
      's2_d6': "Observe the final simplified expression.",
      's2_ht6': "Scenario Complete!",
      's2_hd6': "Click Validate Model to see the summary.",

      // HUD Callouts
      'hudCancelTitle': "Cancelled Out!",
      'hudCancelDesc': "A positive and negative fruit combined to make zero.",
      'hudInvalidTitle': "Invalid Pair!",
      'hudInvalidDesc':
          "Match ONE fresh (+) and ONE rotten (-) of the SAME fruit type.",
      'hudSortTitle': "Sorted!",
      'hudSortDesc': "Fruit placed in the correct bin.",
      'hudWrongTitle': "Wrong Bin!",
      'hudWrongDesc': "Like terms only! Match the fruit type.",
    },
    'hi': {
      'title': 'बीजीय व्यंजकों का सरलीकरण: फल छांटने की चुनौती',
      'subtitle': 'कक्षा 7 • अक्षर-संख्याओं का उपयोग करके व्यंजक',
      'enterLab': 'लैब में प्रवेश करें',
      'currentExp': 'वर्तमान व्यंजक',
      'actionInfo': 'कार्य जानकारी',
      'interactObj': 'वस्तुओं के साथ इंटरैक्ट करें।',
      'selectScen': 'परिदृश्य चुनें',
      'scen1': '1. फलों की टोकरी का मिश्रण',
      'scen2': '2. ताज़ा बनाम सड़ा हुआ',
      'theory': 'सिद्धांत',
      'procSteps': 'प्रक्रिया के चरण',
      'step': 'चरण',
      'startSort': 'छांटना शुरू करें',
      'startComp': 'खाद बनाना शुरू करें',
      'nextStep': 'अगला कदम',
      'validating': 'कार्य पूरा करें...',
      'valModel': 'मॉडल मान्य करें',
      'scenSum': 'परिदृश्य का सारांश',
      'compScen': 'परिदृश्य पूरा करें',
      'modelVal': 'मॉडल मान्य',
      'scenComp': 'परिदृश्य सफलतापूर्वक पूरा हुआ',
      'binA': 'बिन-A',
      'binB': 'बिन-B',
      'binX': 'बिन-X',
      'binY': 'बिन-Y',
      'compBin': 'खाद बिन',
      'applesText': 'सेब: ',
      'bananasText': 'केले: ',
      'xfruitsText': 'X-फल: ',
      'yfruitsText': 'Y-फल: ',
      'xFruitsStr': 'X-फल',
      'yFruitsStr': 'Y-फल',
      'cancelOut': '+ और - शून्य हो जाते हैं',
      'footer': '© ZEROSCIENCELAB | Fall in Love with Math and Science',

      's1_obj':
          'विभिन्न प्रकार के फलों को भौतिक रूप से छांटकर समान धनात्मक पदों को जोड़ने की मूल अवधारणा को समझना।',
      's1_sum':
          "समान फलों को उनके संबंधित डिब्बे में ले जाकर, हमने प्रदर्शित किया कि 'समान पदों' को एक साथ जोड़ा जा सकता है। सेब (a) मिलकर 6a बन गए, और केले (b) 3b ही रहे।",
      's1_d1':
          "स्क्रीन के शीर्ष पर व्यंजक 2a + 3b + 4a देखें। नीचे कन्वेयर ट्रे पर ध्यान दें, जिसमें सेब (a) और केले (b) का मिश्रण है। छंटाई शुरू करने के लिए 'छांटना शुरू करें' बटन पर क्लिक करें।",
      's1_ht1': "देखें और शुरू करें",
      's1_hd1': "व्यंजक जांचें और 'छांटना शुरू करें' पर क्लिक करें।",
      's1_d2':
          "ट्रे से सभी सेब (a) खींचें और उन्हें 'a' लेबल वाले डिब्बे में छोड़ दें।",
      's1_ht2': "सभी सेब छांटें",
      's1_hd2': "हर लाल सेब को बिन-A में खींचें।",
      's1_d3':
          "ट्रे से सभी केले (b) खींचें और उन्हें 'b' लेबल वाले डिब्बे में छोड़ दें।",
      's1_ht3': "सभी केले छांटें",
      's1_hd3': "हर पीले केले को बिन-B में खींचें।",
      's1_d4':
          "अंतिम परिणाम देखें। ट्रे अब खाली है, और डिब्बे प्रत्येक फल की कुल संख्या दिखाते हैं।",
      's1_ht4': "परिदृश्य पूरा हुआ!",
      's1_hd4': "सारांश देखने के लिए 'मॉडल मान्य करें' पर क्लिक करें।",

      's2_obj':
          'विपरीत जोड़ियों को रद्द करके धनात्मक और ऋणात्मक समान पदों को जोड़ना समझना।',
      's2_sum':
          "खाद बिन में ताजे फलों (धनात्मक पदों) को सड़े हुए फलों (ऋणात्मक पदों) के साथ जोड़कर, हमने देखा कि कैसे विपरीत एक-दूसरे को शून्य कर देते हैं। शेष फल सरलीकृत व्यंजक का प्रतिनिधित्व পরবর্তियों करते हैं।",
      's2_d1':
          "ताजे फलों में हरा + (धनात्मक) होता है। सड़े हुए फलों में लाल - (ऋणात्मक) होता है। सेटअप देखें और 'खाद बनाना शुरू करें' पर क्लिक करें।",
      's2_ht1': "फलों को देखें",
      's2_hd1':
          "हरा (+) धनात्मक है, लाल (-) ऋणात्मक है। शुरू करें पर क्लिक करें।",
      's2_d2':
          "एक ताज़ा X-फल (+) और एक सड़ा हुआ X-फल (-) खींचकर खाद बिन में डालें ताकि वे रद्द हो जाएं।",
      's2_ht2': "एक 'X' जोड़ी की खाद बनाएं",
      's2_hd2': "एक (+) X-फल और एक (-) X-फल खाद में खींचें।",
      's2_d3':
          "X-फलों की खाद बनाना जारी रखें। शेष ताजे और सड़े हुए X-फलों के जोड़े खाद बिन में खींचें और छोड़ें।",
      's2_ht3': "सभी 'X' जोड़ों की खाद बनाएं",
      's2_hd3': "शून्य करने के लिए (+) और (-) X-फलों का मिलान करते रहें।",
      's2_d4': "ताजे और सड़े हुए Y-फलों के जोड़े खींचकर खाद बिन में डालें।",
      's2_ht4': "सभी 'Y' जोड़ों की खाद बनाएं",
      's2_hd4': "खाद बिन में (+) Y-फलों का (-) Y-फलों से मिलान करें।",
      's2_d5':
          "प्लेटफ़ॉर्म पर बचे हुए फलों को उनके सही छंटाई डिब्बे में खींचें।",
      's2_ht5': "शेष फलों को छांटें",
      's2_hd5': "बचे हुए X-फलों को बिन X में और Y-फलों को बिन Y में खींचें।",
      's2_d6': "अंतिम सरलीकृत व्यंजक देखें।",
      's2_ht6': "परिदृश्य पूरा हुआ!",
      's2_hd6': "सारांश देखने के लिए मॉडल मान्य करें पर क्लिक करें।",

      'hudCancelTitle': "रद्द हो गया!",
      'hudCancelDesc': "एक धनात्मक और एक ऋणात्मक फल मिलकर शून्य हो गए।",
      'hudInvalidTitle': "अमान्य जोड़ी!",
      'hudInvalidDesc':
          "एक ही प्रकार के फल का एक ताज़ा (+) और एक सड़ा हुआ (-) मिलाएं।",
      'hudSortTitle': "छांटा गया!",
      'hudSortDesc': "फल सही डिब्बे में रखा गया।",
      'hudWrongTitle': "गलत बिन!",
      'hudWrongDesc': "केवल समान पद! फल के प्रकार का मिलान करें।",
    },
  };

  String getString(String key) => i18n[_lang]![key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _curtainAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _curtainOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.0),
    ).animate(
      CurvedAnimation(
        parent: _curtainAnimController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _loadScenario(1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _recenterCamera();
        }
      });
    }
  }

  void _recenterCamera() {
    final size = MediaQuery.of(context).size;
    double sidebarWidth = size.width * 0.3;
    if (sidebarWidth < 300) sidebarWidth = 300;
    if (sidebarWidth > 450) sidebarWidth = 450;
    final viewerWidth = size.width - (_isSidebarOpen ? sidebarWidth : 0);

    double scaleX = viewerWidth / 2400;
    double scaleY = size.height / 1400;
    double scale = min(scaleX, scaleY) * 0.95;

    double dx = (viewerWidth - 2400 * scale) / 2;
    double dy = (size.height - 1400 * scale) / 2;

    _transformController.value =
        Matrix4.identity()
          ..translate(dx, dy)
          ..scale(scale);
  }

  // Method to handle scroll-wheel zooming centered around the mouse pointer
  void _zoomAtPoint(double factor, Offset focalPoint) {
    final currentMatrix = _transformController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    double targetScale = currentScale * factor;

    if (targetScale < 0.1) targetScale = 0.1;
    if (targetScale > 4.0) targetScale = 4.0;

    final actualFactor = targetScale / currentScale;

    final dx = currentMatrix.getTranslation().x;
    final dy = currentMatrix.getTranslation().y;

    final newDx = focalPoint.dx - (focalPoint.dx - dx) * actualFactor;
    final newDy = focalPoint.dy - (focalPoint.dy - dy) * actualFactor;

    _transformController.value =
        Matrix4.identity()
          ..translate(newDx, newDy)
          ..scale(targetScale);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _player.dispose();
    _transformController.dispose();
    _curtainAnimController.dispose();
    super.dispose();
  }

  // --- Game Flow Methods ---

  void _playSound(String type) async {
    String url = '';
    switch (type) {
      case 'success':
        url =
            'audio/class7/mixkit_2000.mp3';
        break;
      case 'plink':
        url =
            'audio/class7/mixkit_2568.mp3';
        break;
      case 'error':
        url =
            'audio/class7/mixkit_955.mp3';
        break;
      case 'curtain':
        url =
            'audio/class7/mixkit_2574.mp3';
        break;
    }
    if (url.isNotEmpty) {
      try {
        await _player.play(AssetSource(url));
      } catch (e) {
        debugPrint("Audio Error: $e");
      }
    }
  }

  void _showFeedbackMessage(
    String title,
    String desc, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    setState(() {});
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _updateHudToStepData();
        });
      }
    });
  }

  void _updateHudToStepData() {
    if (_step <= _maxSteps(_scenario)) {
    } else {}
  }

  int _maxSteps(int scenario) => scenario == 1 ? 4 : 6;

  bool _isStepAction(int stepIndex) {
    if (_scenario == 1) return stepIndex == 1 || stepIndex == 2;
    if (_scenario == 2) return stepIndex >= 1 && stepIndex <= 4;
    return false;
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;
      _fruits.clear();
      _bins.clear();
      _updateHudToStepData();

      if (id == 1) {
        _bins.add(
          Bin(id: 'binA', labelKey: 'binA', accepts: ['apple'], x: 300, y: 150),
        );
        _bins.add(
          Bin(
            id: 'binB',
            labelKey: 'binB',
            accepts: ['banana'],
            x: 1800,
            y: 150,
          ),
        );

        // Spawn Apple Column
        for (int i = 0; i < 2; i++) {
          _fruits.add(
            Fruit(id: 'a1_$i', type: 'apple', x: 800, y: 700 + i * 150),
          );
        }
        // Spawn Banana Column
        for (int i = 0; i < 3; i++) {
          _fruits.add(
            Fruit(id: 'b_$i', type: 'banana', x: 1100, y: 650 + i * 150),
          );
        }
        // Spawn Apple Column 2
        for (int i = 0; i < 4; i++) {
          _fruits.add(
            Fruit(id: 'a2_$i', type: 'apple', x: 1400, y: 550 + i * 150),
          );
        }
      } else {
        _bins.add(
          Bin(
            id: 'binX',
            labelKey: 'binX',
            accepts: ['xFruit'],
            x: 200,
            y: 150,
          ),
        );
        _bins.add(
          Bin(
            id: 'comp',
            labelKey: 'compBin',
            accepts: ['xFruit', 'yFruit'],
            isCompost: true,
            x: 1050,
            y: 150,
          ),
        );
        _bins.add(
          Bin(
            id: 'binY',
            labelKey: 'binY',
            accepts: ['yFruit'],
            x: 1900,
            y: 150,
          ),
        );

        for (int i = 0; i < 5; i++) {
          _fruits.add(
            Fruit(
              id: 'xf_$i',
              type: 'xFruit',
              isFresh: true,
              x: 600,
              y: 500 + i * 120,
            ),
          );
        }
        for (int i = 0; i < 2; i++) {
          _fruits.add(
            Fruit(
              id: 'yr_$i',
              type: 'yFruit',
              isFresh: false,
              x: 900,
              y: 700 + i * 120,
            ),
          );
        }
        for (int i = 0; i < 3; i++) {
          _fruits.add(
            Fruit(
              id: 'xr_$i',
              type: 'xFruit',
              isFresh: false,
              x: 1200,
              y: 600 + i * 120,
            ),
          );
        }
        for (int i = 0; i < 4; i++) {
          _fruits.add(
            Fruit(
              id: 'yf_$i',
              type: 'yFruit',
              isFresh: true,
              x: 1500,
              y: 550 + i * 120,
            ),
          );
        }
      }
    });
  }

  bool _isStepConditionMet() {
    if (_scenario == 1) {
      if (_step == 0) return true;
      if (_step == 1) {
        return _fruits
            .where((f) => f.type == 'apple')
            .every((f) => f.binId == 'binA');
      }
      if (_step == 2) {
        return _fruits
            .where((f) => f.type == 'banana')
            .every((f) => f.binId == 'binB');
      }
      if (_step == 3) return true;
    } else {
      if (_step == 0) return true;
      if (_step == 1) {
        return _fruits
                .where((f) => f.type == 'xFruit' && f.isComposted)
                .length >=
            2;
      }
      if (_step == 2) {
        return _fruits
            .where((f) => f.type == 'xFruit' && !f.isFresh)
            .every((f) => f.isComposted);
      }
      if (_step == 3) {
        return _fruits
            .where((f) => f.type == 'yFruit' && !f.isFresh)
            .every((f) => f.isComposted);
      }
      if (_step == 4) {
        return _fruits
                .where((f) => f.type == 'xFruit' && !f.isComposted)
                .every((f) => f.binId == 'binX') &&
            _fruits
                .where((f) => f.type == 'yFruit' && !f.isComposted)
                .every((f) => f.binId == 'binY');
      }
      if (_step == 5) return true;
    }
    return false;
  }

  void _handleDrop(Fruit f, Bin b) {
    if (b.isCompost) {
      if (b.waitingFruit != null) {
        if (b.waitingFruit!.type == f.type &&
            b.waitingFruit!.isFresh != f.isFresh) {
          _playSound('success');
          HapticFeedback.heavyImpact();
          _showFeedbackMessage(
            'hudCancelTitle',
            'hudCancelDesc',
            isSuccess: true,
          );
          setState(() {
            f.isComposted = true;
            b.waitingFruit!.isComposted = true;
            b.waitingFruit = null;
          });
          _checkAutoAdvance();
        } else {
          _playSound('error');
          HapticFeedback.vibrate();
          _showFeedbackMessage(
            'hudInvalidTitle',
            'hudInvalidDesc',
            isError: true,
          );
        }
      } else {
        _playSound('plink');
        setState(() {
          b.waitingFruit = f;
          f.x = b.x + 70;
          f.y = b.y + 160;
          f.binId = b.id;
        });
      }
    } else {
      if (b.accepts.contains(f.type)) {
        _playSound('plink');
        _showFeedbackMessage('hudSortTitle', 'hudSortDesc', isSuccess: true);
        setState(() {
          f.binId = b.id;
          b.count++;
          f.x = b.x + 40 + ((b.count - 1) % 3) * 55;
          f.y = b.y + 150 + ((b.count - 1) ~/ 3) * 55;
        });
        _checkAutoAdvance();
      } else {
        _playSound('error');
        HapticFeedback.vibrate();
        _showFeedbackMessage('hudWrongTitle', 'hudWrongDesc', isError: true);
        setState(() {
          f.x = f.originalX;
          f.y = f.originalY;
          f.binId = null;
        });
      }
    }
  }

  void _checkAutoAdvance() {
    if (_isStepAction(_step) && _isStepConditionMet()) {
      _playSound('success');
    }
  }

  void _advanceStep() {
    if (_isStepConditionMet()) {
      _playSound('plink');
      if (_step == _maxSteps(_scenario) - 1) {
        setState(() {
          _showSummary = true;
          _step++;
        });
      } else {
        setState(() {
          _step++;
          _updateHudToStepData();
        });
      }
    } else {
      _playSound('error');
      HapticFeedback.vibrate();
    }
  }

  void _enterLab() {
    _playSound('curtain');
    _curtainAnimController.forward().then((_) {
      setState(() => _showCurtain = false);
    });
  }

  void _resetActivity() {
    _playSound('curtain'); // Play curtain sound effect
    _curtainAnimController.value =
        0.0; // Instantly reset curtain animation position to cover the screen
    setState(() {
      _showCurtain = true;
      _showSummary = false;
      _isSidebarOpen = true;
      _scenario = 1;
      _step = 0;
      _labelsVisible = true;
      _panEnabled = true;
      _loadScenario(1);
      _recenterCamera();
    });
  }

  // --- UI Builders ---

  Widget _buildGlassPanel({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double borderRadius = 16,
    Color borderColor = const Color(0xFF334155),
    double opacity = 0.95,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    // Determines if the button should visually appear disabled while still catching clicks
    bool isDisabled = _isStepAction(_step) && !_isStepConditionMet();

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          if (isDisabled) {
            _playSound('error');
            HapticFeedback.vibrate();
          } else {
            _advanceStep();
          }
        },
        icon: Icon(
          _step >= _maxSteps(_scenario) - 1
              ? Icons.check_circle
              : (_isStepAction(_step)
                  ? Icons.hourglass_empty
                  : Icons.play_arrow),
          size: 20,
        ),
        label: Text(
          _step >= _maxSteps(_scenario) - 1
              ? getString('valModel')
              : (_step == 0
                  ? getString(_scenario == 1 ? 'startSort' : 'startComp')
                  : (_isStepAction(_step)
                      ? getString('validating')
                      : getString('nextStep'))),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDisabled ? const Color(0xFF334155) : const Color(0xFFEAB308),
          foregroundColor:
              isDisabled ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isDisabled ? 0 : 8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.3;
    if (sidebarWidth < 300) sidebarWidth = 300; // minimum width
    if (sidebarWidth > 450) sidebarWidth = 450; // max width

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          _playSound('plink');
        },
        child: Stack(
          children: [
            // 1. Interactive Canvas with Listener for Mouse Scroll Wheel and Infinite Boundary Margin
            Positioned.fill(
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: Listener(
                  onPointerSignal: (pointerSignal) {
                    if (pointerSignal is PointerScrollEvent) {
                      // Detect scroll wheel up/down for zooming
                      final double scaleChange =
                          pointerSignal.scrollDelta.dy < 0 ? 1.1 : (1 / 1.1);
                      _zoomAtPoint(scaleChange, pointerSignal.localPosition);
                    }
                  },
                  onPointerUp: (e) {
                    // Re-enable pan when interactions complete
                    setState(() => _panEnabled = true);
                  },
                  child: InteractiveViewer(
                    transformationController: _transformController,
                    panEnabled: _panEnabled,
                    scaleEnabled: true,
                    // boundaryMargin is set to a large finite number to allow unrestricted panning
                    boundaryMargin: const EdgeInsets.all(5000),
                    clipBehavior: Clip.none,
                    minScale: 0.1,
                    maxScale: 4.0,
                    constrained: false,
                    child: SizedBox(
                      width: 2400,
                      height: 1400,
                      child: Stack(
                        children: [
                          // Background Diorama Grid/Board simulation
                          Positioned(
                            left: 0,
                            top: 0,
                            right: 0,
                            bottom: 0,
                            child: CustomPaint(painter: GridPainter()),
                          ),
                          // Tray Background
                          Positioned(
                            left: 500,
                            top: 450,
                            width: 1400,
                            height: 700,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF273549),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 30,
                                    offset: Offset(0, 15),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white12,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          // Bins
                          ..._bins.map((b) => _buildBinWidget(b)).toList(),
                          // Fruits
                          ..._fruits
                              .where((f) => !f.isComposted)
                              .map((f) => _buildFruitWidget(f))
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Top Floating Expression
            Positioned(
              top: 16,
              left:
                  _isSidebarOpen
                      ? sidebarWidth + (screenWidth - sidebarWidth) / 2 - 120
                      : screenWidth / 2 - 120,
              child: _buildGlassPanel(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      getString('currentExp').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _scenario == 1
                          ? (_step >= 3 ? '6a + 3b' : '2a + 3b + 4a')
                          : (_step >= 5 ? '2x + 2y' : '5x - 2y - 3x + 4y'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEAB308),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Mission Floating Card (When Sidebar Collapsed)
            if (!_isSidebarOpen)
              Positioned(
                top: 66,
                left: 16,
                width: 280,
                child: _buildGlassPanel(
                  borderColor: const Color(0xFFEAB308),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.assistant_photo,
                            color: Color(0xFFEAB308),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Mission • ${getString('step')} ${_step < _maxSteps(_scenario) ? _step + 1 : _maxSteps(_scenario)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        getString(
                          's${_scenario}_d${_step < _maxSteps(_scenario) ? _step + 1 : _maxSteps(_scenario)}',
                        ),
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildActionButton(),
                    ],
                  ),
                ),
              ),

            // 4. Sidebar (Sliding from Left)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: _buildSidebar(),
            ),

            // 5. Menu Icon toggle (Top Left)
            Positioned(
              top: 16,
              left: 16,
              child: _buildGlassPanel(
                borderRadius: 12,
                padding: EdgeInsets.zero,
                borderColor: const Color(0xFFEAB308).withOpacity(0.5),
                child: IconButton(
                  icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                  color: const Color(0xFFEAB308),
                  iconSize: 28,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _playSound('plink');
                    setState(() {
                      _isSidebarOpen = !_isSidebarOpen;
                    });
                  },
                ),
              ),
            ),

            // 6. Summary Modal Overlay
            if (_showSummary) _buildSummaryModal(),

            // 7. Curtain Raiser
            if (_showCurtain)
              SlideTransition(
                position: _curtainOffset,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFF0F172A),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.science_outlined,
                          color: Color(0xFFEAB308),
                          size: 80,
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            getString('title'),
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          getString('subtitle'),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFFCBD5E1),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 34),
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEAB308).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              _enterLab();
                              _playSound('curtain');
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEAB308),
                              foregroundColor: const Color(0xFF0F172A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              getString('enterLab'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  Widget _buildSidebar() {
    return Material(
      elevation: 24,
      color: const Color(0xFF0F172A), // Alt bg panel
      child: Container(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Color(0xFF334155), width: 1)),
        ),
        child: CustomScrollView(
          slivers: [
            // Header (leaves space for the floating menu icon)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 66),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF334155), width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(
                            Icons.science,
                            color: Color(0xFFEAB308),
                            size: 38,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            getString('title'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getString('subtitle'),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Language Translation Button
                        TextButton.icon(
                          onPressed: () {
                            _playSound('plink');
                            setState(() {
                              _lang = _lang == 'en' ? 'hi' : 'en';
                            });
                          },
                          icon: const Icon(
                            Icons.language,
                            color: Color(0xFFEAB308),
                            size: 18,
                          ),
                          label: Text(
                            _lang == 'en' ? 'EN' : 'HI',
                            style: const TextStyle(
                              color: Color(0xFFEAB308),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Reset Icon Button
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Color(0xFFEAB308),
                            size: 20,
                          ),
                          tooltip: 'Reset Activity',
                          onPressed: _resetActivity,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scenario Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _scenario,
                          dropdownColor: const Color(0xFF1E293B),
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF94A3B8),
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 1,
                              child: Text(getString('scen1')),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text(getString('scen2')),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null && v != _scenario) {
                              _playSound('plink');
                              _loadScenario(v);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Theory Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.menu_book,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                getString('theory'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            getString('s${_scenario}_obj'),
                            style: const TextStyle(
                              color: Color(0xFFF8FAFC),
                              height: 1.5,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(
                          Icons.format_list_numbered,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          getString('procSteps'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_maxSteps(_scenario), (index) {
                      bool isPast = index < _step;
                      bool isCurrent = index == _step;

                      Color bgColor =
                          isCurrent
                              ? const Color(0xFFEAB308)
                              : (isPast
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF1E293B));
                      Color textColor =
                          isCurrent
                              ? const Color(0xFF0F172A)
                              : (isPast
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8));
                      Color titleColor =
                          isCurrent
                              ? const Color(0xFF0F172A)
                              : (isPast
                                  ? const Color(0xFF64748B)
                                  : Colors.white);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isCurrent
                                    ? const Color(0xFFFACC15)
                                    : const Color(0xFF334155),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${getString('step')} ${index + 1}",
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              getString('s${_scenario}_d${index + 1}'),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 13,
                                height: 1.4,
                                decoration:
                                    isPast ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    _buildActionButton(),
                  ],
                ),
              ),
            ),

            // Footer
            SliverFillRemaining(
              hasScrollBody: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    border: Border(top: BorderSide(color: Color(0xFF334155))),
                  ),
                  child: Text(
                    getString('footer'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      letterSpacing: 0.5,
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

  Widget _buildBinWidget(Bin b) {
    return Positioned(
      left: b.x,
      top: b.y,
      child: DragTarget<Fruit>(
        onWillAccept: (f) {
          if (f == null) return false;
          return true; // We accept all to show wrong drop feedback
        },
        onAccept: (f) => _handleDrop(f, b),
        builder: (context, candidateData, rejectedData) {
          bool isHovered = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: b.isCompost ? 260 : 220,
            height: b.isCompost ? 260 : 280,
            decoration: BoxDecoration(
              color:
                  isHovered
                      ? (b.isCompost
                          ? Colors.green.withOpacity(0.2)
                          : Colors.white12)
                      : const Color(0x0AFFFFFF),
              border: Border.all(
                color:
                    b.isCompost
                        ? (isHovered
                            ? Colors.greenAccent
                            : Colors.green.shade800)
                        : (isHovered
                            ? Colors.white70
                            : const Color(0xFF334155)),
                width: isHovered ? 4 : 2,
              ),
              borderRadius: BorderRadius.circular(
                b.isCompost ? 130 : 24,
              ), // Circle for compost
              boxShadow:
                  isHovered
                      ? [
                        BoxShadow(
                          color:
                              b.isCompost
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.white24,
                          blurRadius: 20,
                        ),
                      ]
                      : [],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (!b.isCompost && _labelsVisible)
                  Positioned(
                    bottom: -45,
                    left: 0,
                    right: 0,
                    child: _buildGlassPanel(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      borderColor: const Color(0xFFEAB308),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Builder(
                            builder: (context) {
                              String variable = '';
                              String displayFruitName = '';
                              if (b.accepts.first == 'apple') {
                                variable = 'a';
                                displayFruitName = 'Apple';
                              } else if (b.accepts.first == 'banana') {
                                variable = 'b';
                                displayFruitName = 'Banana';
                              } else if (b.accepts.first == 'xFruit') {
                                variable = 'x';
                                displayFruitName = 'X-Fruit';
                              } else if (b.accepts.first == 'yFruit') {
                                variable = 'y';
                                displayFruitName = 'Y-Fruit';
                              }

                              return Text(
                                "${getString(b.labelKey)} $displayFruitName:${b.count}$variable",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                if (b.isCompost && _labelsVisible)
                  Positioned(
                    bottom: -55,
                    left: -20,
                    right: -20,
                    child: _buildGlassPanel(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      borderColor: Colors.green,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            getString(b.labelKey),
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              getString('cancelOut'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Waiting fruit in compost display
                if (b.isCompost && b.waitingFruit != null)
                  Align(
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: 0.5,
                      child: _getFruitIcon(b.waitingFruit!),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFruitWidget(Fruit f) {
    Widget icon = _getFruitIcon(f);
    return Positioned(
      left: f.x,
      top: f.y,
      child: GestureDetector(
        onPanDown: (_) {
          _playSound(
            'plink',
          ); // Adding touch/click sound here for immediate touch feedback
          setState(() => _panEnabled = false);
        },
        onPanEnd: (_) {
          // Re-enable pan when drag finishes
          setState(() => _panEnabled = true);
        },
        onPanCancel: () {
          // Re-enable pan if drag is canceled
          setState(() => _panEnabled = true);
        },
        child: Draggable<Fruit>(
          data: f,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          maxSimultaneousDrags: f.isComposted ? 0 : 1,
          feedback: Material(
            color: Colors.transparent,
            child: Transform.scale(
              scale: _transformController.value.getMaxScaleOnAxis(),
              child: icon,
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: icon),
          onDragStarted: () {
            HapticFeedback.selectionClick();
            if (f.binId != null) {
              Bin? oldBin;
              try {
                oldBin = _bins.firstWhere((b) => b.id == f.binId);
              } catch (_) {}
              if (oldBin != null) {
                setState(() {
                  if (oldBin!.isCompost && oldBin.waitingFruit == f) {
                    oldBin.waitingFruit = null;
                  } else {
                    oldBin.count--;
                  }
                  f.binId = null;
                });
              }
            }
          },
          onDragEnd: (details) {
            setState(() => _panEnabled = true);
            if (!details.wasAccepted) {
              // Snap back logic
              setState(() {
                f.x = f.originalX;
                f.y = f.originalY;
              });
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_labelsVisible && _scenario == 2)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    f.isFresh ? '+' : '-',
                    style: TextStyle(
                      color: f.isFresh ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              icon,
            ],
          ),
        ),
      ),
    );
  }

  Widget _getFruitIcon(Fruit f) {
    String emoji = '';
    double size = 70;

    if (f.type == 'apple') {
      emoji = '🍎';
    } else if (f.type == 'banana') {
      emoji = '🍌';
      size = 80;
    } else if (f.type == 'xFruit') {
      emoji = '🍉'; // Watermelon
    } else if (f.type == 'yFruit') {
      emoji = '🍇'; // Grapes
    }

    Widget fruitWidget = Text(
      emoji,
      style: TextStyle(
        fontSize: size,
        shadows: const [
          Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 10)),
        ],
      ),
    );

    if (!f.isFresh) {
      // Apply grayscale filter for rotten fruits
      fruitWidget = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.33,
          0.33,
          0.33,
          0,
          0,
          0.33,
          0.33,
          0.33,
          0,
          0,
          0.33,
          0.33,
          0.33,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: fruitWidget,
      );
    }

    return SizedBox(width: 90, height: 90, child: Center(child: fruitWidget));
  }

  Widget _buildSummaryModal() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF0F172A).withOpacity(0.8),
        child: Center(
          child: _buildGlassPanel(
            borderColor: const Color(0xFFEAB308),
            padding: const EdgeInsets.all(32),
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                      onPressed: () {
                        _playSound('plink');
                        setState(() => _showSummary = false);
                      },
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAB308).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFEAB308).withOpacity(0.5),
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFFEAB308),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    getString('scenSum'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Text(
                      _scenario == 1
                          ? "2a + 3b + 4a = 6a + 3b"
                          : "5x - 2y - 3x + 4y = 2x + 2y",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFEAB308),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    getString('s${_scenario}_sum'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        _playSound('success');
                        setState(() {
                          _showSummary = false;
                          _loadScenario(_scenario == 1 ? 2 : 1);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEAB308),
                        foregroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        getString('compScen'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Background Custom Painter to simulate the wood grid floor
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF1E293B)
          ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final linePaint =
        Paint()
          ..color = const Color(0xFF334155).withOpacity(0.5)
          ..strokeWidth = 2.0;

    for (double i = 0; i <= size.width; i += 100) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    for (double i = 0; i <= size.height; i += 100) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
