// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'package:flutter/scheduler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab | Division of Fractions',
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
      home: const DivisionofFractions(),
    );
  }
}

// --- AUDIO ENGINE ---
class AudioEngine {
  // A small pool of players to allow overlapping sounds without crashing Android's MediaHTTPConnection
  static final AudioPlayer _player1 = AudioPlayer();
  static final AudioPlayer _player2 = AudioPlayer();
  static final AudioPlayer _player3 = AudioPlayer();
  static int _currentPlayer = 0;

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
  static const String _cutUrl =
      'audio/class7/mixkit_2575.mp3';
  static const String _splashUrl =
      'audio/class7/mixkit_2569.mp3';

  static Future<void> init() async {
    // Intentionally empty.
    // Preloading 8 network URLs simultaneously causes java.io.IOException on Android.
    // Audio will be fetched directly on demand in the play() method.
  }

  static void play(String type) async {
    try {
      String url = '';
      switch (type) {
        case 'click':
          url = _clickUrl;
          break;
        case 'success':
          url = _successUrl;
          break;
        case 'error':
          url = _errorUrl;
          break;
        case 'pop':
          url = _alertUrl;
          break;
        case 'shutter':
          url = _shutterUrl;
          break;
        case 'snap':
          url = _snapUrl;
          break;
        case 'cut':
          url = _cutUrl;
          break;
        case 'splash':
          url = _splashUrl;
          break;
      }

      if (url.isNotEmpty) {
        AudioPlayer p;
        if (_currentPlayer == 0) {
          p = _player1;
          _currentPlayer = 1;
        } else if (_currentPlayer == 1) {
          p = _player2;
          _currentPlayer = 2;
        } else {
          p = _player3;
          _currentPlayer = 0;
        }

        await p.play(AssetSource(url));
      }
    } catch (e) {
      debugPrint("Audio Play Error: $e");
    }
  }
}

// --- LOCALIZATION ---
const Map<String, Map<String, String>> translations = {
  'en': {
    'appTitle': 'The Great Fraction Bake-Off: A Visual Guide to Division',
    'appSubtitle': 'Class 7 • WORKING WITH FRACTIONS',
    'enterLab': 'Enter Lab',
    'selectScenario': 'Select Scenario',
    'objectiveLbl': 'Mission Objective:',
    'stepLabel': 'STEP',
    'summaryTitle': 'Key Learning',
    'continueBtn': 'Awesome!',
    'checkAns': 'Check Answer',
    'closeBtn': 'Close',
    'mathConnBtn': 'Math Connection',
    'langBtn': 'EN',
    'resetBtn': 'Reset',
    'doneBtn': 'Done',

    's1_title': "1. The Chocolate Bar Challenge",
    's1_obj':
        "To understand how to divide a whole number by a fraction by physically partitioning objects.",
    's1_hud1': "DRAG the '1/2' slicer tool onto the first chocolate bar.",
    's1_t1': "Observation: The chocolate bar splits into two equal pieces.",
    's1_hud2': "DRAG the '1/2' slicer tool onto the second chocolate bar.",
    's1_t2': "Observation: The second bar splits into two pieces.",
    's1_hud3': "DRAG the '1/2' slicer tool onto the final chocolate bar.",
    's1_t3': "Observation: The third bar splits into two pieces.",
    's1_hud4': "CLICK 'Check Answer' to verify.",
    's1_t4':
        "Learnt: By cutting the whole bars into halves, we can count the total pieces to understand division.",
    's1_sum':
        "You asked 'How many 1/2 pieces are in 3 whole bars?'. By cutting them up, you found there are 6 pieces. So, 3 ÷ 1/2 = 6.",

    's2_title': "2. Sharing the Pizza Slice",
    's2_obj':
        "To understand how to divide a fraction by a whole number by physically sharing a portion.",
    's2_hud1': "DRAG the 'Slice into 4' tool onto the half-pizza.",
    's2_t1':
        "Observation: The half-pizza is sliced into 4 smaller, equal pieces.",
    's2_hud2': "DRAG each small slice to one of the four empty plates.",
    's2_t2':
        "Observation: All four plates now have one small slice of pizza each.",
    's2_hud3': "CLICK 'Reveal Whole' to see the original pizza outline.",
    's2_t3':
        "Observation: A faint outline of the full pizza appears, showing the total number of slices.",
    's2_hud4': "Set the correct fraction and CLICK 'Submit'.",
    's2_t4':
        "Learnt: When you share a portion among people, visualizing the whole helps determine the final fraction.",
    's2_sum':
        "When you share half a pizza among 4 people, each person gets 1/8 of the whole pizza. Therefore, 1/2 ÷ 4 = 1/8.",

    's3_title': "3. The Potion Master's Recipe",
    's3_obj':
        "To understand how to divide a fraction by a fraction by measuring how many times a smaller fractional amount fits into a larger one.",
    's3_hud1': "DRAG the 1/8 scoop to the beaker to fill it.",
    's3_t1': "Observation: The scoop fills, and the liquid level drops.",
    's3_hud2': "DRAG the filled scoop to the empty rack.",
    's3_t2': "Observation: The filled scoop is placed on the rack.",
    's3_hud3': "Repeat filling and racking until the beaker is empty.",
    's3_t3': "Observation: The beaker is empty after multiple scoops.",
    's3_hud4': "CLICK 'Check Answer' to verify.",
    's3_t4':
        "Learnt: By measuring how many small scoops fit into the large beaker, we solve the division.",
    's3_sum':
        "You asked 'How many 1/8 scoops fit into a 3/4 full beaker?'. You found that you could fill exactly 6 scoops. So, 3/4 ÷ 1/8 = 6.",

    's4_title': "4. The Ribbon Cutting Project",
    's4_obj':
        "To solve a division problem (fraction by fraction) by applying the 'how many fit' concept.",
    's4_hud1': "DRAG the 1/4m cutting guide to the start of the ribbon.",
    's4_t1': "Observation: The guide snaps to the start of the ribbon.",
    's4_hud2':
        "CLICK 'Cut' on the guide, then drag the guide forward and repeat until out of ribbon.",
    's4_t2': "Observation: You cut 1/4 meter pieces from the 5/2 meter ribbon.",
    's4_hud3': "Enter the final count of pieces.",
    's4_t3':
        "Learnt: The basket contains the total pieces cut, revealing how many 1/4s fit into 5/2.",
    's4_sum': "The basket contains 10 pieces. 5/2 ÷ 1/4 = 10.",

    's5_title': "5. The Giant Cookie Recipe",
    's5_obj':
        "To solve a division problem involving a mixed number by applying the measuring concept.",
    's5_hud1': "DRAG the 2/3 cup measure to the sugar jar to scoop.",
    's5_t1': "Observation: The measure fills, and the jar level drops.",
    's5_hud2':
        "DRAG the filled measure to the mixing bowl. Repeat until jar has less than 2/3.",
    's5_t2':
        "Observation: You placed scoops until the remaining sugar is not enough.",
    's5_hud3': "Enter the total number of FULL cookie batches made.",
    's5_t3':
        "Learnt: The full scoops indicate whole batches, and the leftover reveals the remainder.",
    's5_sum':
        "You made 3 full cookies and had 1/3 cup left over. 2 1/3 ÷ 2/3 = 7/3 ÷ 2/3 = 3.5 (or 3 with remainder 1).",
  },
  'hi': {
    'appTitle': "द ग्रेट फ्रैक्शन बेक-ऑफ़: विभाजन के लिए दृश्य मार्गदर्शिका",
    'appSubtitle': 'कक्षा 7 • भिन्नों के साथ काम करना',
    'enterLab': 'लैब में प्रवेश करें',
    'selectScenario': 'परिदृश्य चुनें',
    'objectiveLbl': 'मिशन उद्देश्य:',
    'stepLabel': 'कदम',
    'summaryTitle': 'मुख्य सीख',
    'continueBtn': 'बहुत बढ़िया!',
    'checkAns': 'उत्तर जांचें',
    'closeBtn': 'बंद करें',
    'mathConnBtn': 'गणित कनेक्शन',
    'langBtn': 'HI',
    'resetBtn': 'रीसेट',
    'doneBtn': 'हो गया',

    's1_title': "1. चॉकलेट बार चुनौती",
    's1_obj':
        "भौतिक रूप से वस्तुओं को विभाजित करके एक पूर्ण संख्या को भिन्न से विभाजित करना समझना।",
    's1_hud1': "'1/2' स्लाइसर टूल को पहले चॉकलेट बार पर खींचें।",
    's1_t1': "अवलोकन: चॉकलेट बार दो समान टुकड़ों में विभाजित हो जाता है।",
    's1_hud2': "'1/2' स्लाइसर टूल को दूसरे चॉकलेट बार पर खींचें।",
    's1_t2': "अवलोकन: दूसरा बार दो टुकड़ों में विभाजित होता है।",
    's1_hud3': "'1/2' स्लाइसर टूल को अंतिम चॉकलेट बार पर खींचें।",
    's1_t3': "अवलोकन: तीसरा बार दो टुकड़ों में विभाजित होता है।",
    's1_hud4': "सत्यापित करने के लिए 'उत्तर जांचें' पर क्लिक करें।",
    's1_t4':
        "सीखा: पूरे बार को आधे में काटकर, हम विभाजन को समझने के लिए कुल टुकड़ों को गिन सकते हैं।",
    's1_sum':
        "आपने पूछा '3 पूरे बार में कितने 1/2 टुकड़े हैं?'। उन्हें काटकर, आपने पाया कि 6 टुकड़े हैं। इसलिए, 3 ÷ 1/2 = 6.",

    's2_title': "2. पिज़्ज़ा स्लाइस साझा करना",
    's2_obj':
        "भौतिक रूप से एक हिस्से को साझा करके एक भिन्न को पूर्ण संख्या से विभाजित करना समझना।",
    's2_hud1': "'4 में काटें' टूल को आधे पिज़्ज़ा पर खींचें।",
    's2_t1': "अवलोकन: आधा पिज़्ज़ा 4 छोटे समान टुकड़ों में कट जाता है।",
    's2_hud2': "प्रत्येक छोटे टुकड़े को खाली प्लेटों पर खींचें।",
    's2_t2': "अवलोकन: चारों प्लेटों पर एक-एक छोटा पिज़्ज़ा का टुकड़ा है।",
    's2_hud3': "मूल पिज़्ज़ा देखने के लिए 'पूरा दिखाएँ' पर क्लिक करें।",
    's2_t3':
        "अवलोकन: पूरे पिज़्ज़ा की रूपरेखा दिखाई देती है, जो कुल टुकड़ों को दर्शाती है।",
    's2_hud4': "सही भिन्न सेट करें और 'सबमिट' करें।",
    's2_t4':
        "सीखा: जब आप हिस्से को साझा करते हैं, तो पूरे की कल्पना करने से अंतिम भिन्न निर्धारित करने में मदद मिलती है।",
    's2_sum':
        "जब आप आधे पिज़्ज़ा को 4 लोगों में बांटते हैं, तो हर एक को पूरे पिज़्ज़ा का 1/8 मिलता है। इसलिए, 1/2 ÷ 4 = 1/8.",

    's3_title': "3. पोशन मास्टर की रेसिपी",
    's3_obj':
        "एक छोटे भिन्न को बड़े में कितनी बार फिट किया जा सकता है, यह मापना।",
    's3_hud1': "भरने के लिए 1/8 स्कूप को बीकर पर खींचें।",
    's3_t1': "अवलोकन: स्कूप भर जाता है, और तरल स्तर गिरता है।",
    's3_hud2': "भरे हुए 1/8 स्कूप को खाली रैक पर खींचें।",
    's3_t2': "अवलोकन: भरा हुआ स्कूप रैक पर रखा गया है।",
    's3_hud3': "बीकर खाली होने तक दोहराएं।",
    's3_t3': "अवलोकन: कई स्कूप के बाद बीकर खाली है।",
    's3_hud4': "'उत्तर जांचें' पर क्लिक करें।",
    's3_t4':
        "सीखा: यह मापकर कि कितने छोटे स्कूप बड़े बीकर में फिट होते हैं, हम विभाजन को हल करते हैं।",
    's3_sum':
        "आपने पूछा '3/4 भरे बीकर में कितने 1/8 स्कूप फिट होते हैं?'। आपने ठीक 6 स्कूप भरे। इसलिए, 3/4 ÷ 1/8 = 6.",

    's4_title': "4. रिबन काटने का प्रोजेक्ट",
    's4_obj': "विभाजन समस्या (भिन्न से भिन्न) को हल करना।",
    's4_hud1': "1/4m कटिंग गाइड को रिबन के शुरू में खींचें।",
    's4_t1': "अवलोकन: गाइड रिबन के शुरू में जुड़ जाता है।",
    's4_hud2': "रिबन खत्म होने तक 'काटें' और आगे बढ़ें।",
    's4_t2': "अवलोकन: आपने 5/2 मीटर रिबन से 1/4 मीटर के टुकड़े काटे।",
    's4_hud3': "टुकड़ों की अंतिम संख्या दर्ज करें।",
    's4_t3':
        "सीखा: टोकरी में कटे हुए कुल टुकड़े हैं, जो बताते हैं कि 5/2 में कितने 1/4 फिट होते हैं।",
    's4_sum': "टोकरी में 10 टुकड़े हैं। 5/2 ÷ 1/4 = 10.",

    's5_title': "5. विशाल कुकी रेसिपी",
    's5_obj': "मिश्रित संख्या से जुड़ी विभाजन समस्या को हल करना।",
    's5_hud1': "स्कूप करने के लिए 2/3 कप माप को चीनी के जार पर खींचें।",
    's5_t1': "अवलोकन: माप भर जाता है, जार का स्तर गिरता है।",
    's5_hud2': "माप को कटोरे में खींचें। जार में 2/3 से कम होने तक दोहराएं।",
    's5_t2': "अवलोकन: आपने स्कूप रखे जब तक कि शेष चीनी पर्याप्त नहीं है।",
    's5_hud3': "बनाए गए पूर्ण कुकी बैचों की संख्या दर्ज करें।",
    's5_t3':
        "सीखा: पूर्ण स्कूप पूर्ण बैचों को दर्शाते हैं, और बचा हुआ हिस्सा शेष को प्रकट करता है।",
    's5_sum':
        "आपने 3 पूर्ण कुकीज़ बनाईं और 1/3 कप बच गया। 2 1/3 ÷ 2/3 = 7/3 ÷ 2/3 = 3.5.",
  },
};

// --- MODELS ---
class SimTool {
  double x, y;
  double origX, origY;
  bool dragging;
  String type;
  bool filled;
  bool visible;
  bool snapped;

  SimTool({
    required this.x,
    required this.y,
    this.dragging = false,
    this.type = '',
    this.filled = false,
    this.visible = true,
    this.snapped = false,
  }) : origX = x,
       origY = y;
}

class ChocBar {
  int id;
  double x, y;
  int pieces;

  ChocBar({
    required this.id,
    required this.x,
    required this.y,
    required this.pieces,
  });
}

class SimEntity {
  String type; // 'plate', 'slice', 'piece'
  double x, y;
  double origX, origY;
  bool visible;
  bool dragging;
  bool filled;
  double rot;
  int plateId;
  double vx, vy;
  int frames;

  SimEntity({
    required this.type,
    required this.x,
    required this.y,
    this.visible = true,
    this.dragging = false,
    this.filled = false,
    this.rot = 0,
    this.plateId = -1,
    this.vx = 0,
    this.vy = 0,
    this.frames = 0,
  }) : origX = x,
       origY = y;
}

class SimVars {
  String pizzaState = 'half'; // 'half', 'cut', 'outline'
  bool showEquation = false;
  int beakerLevel = 6;
  int rackCount = 0;
  bool equationVisible = false;
  bool showMathConnection = false;
  int ribbonLength = 10;
  int basketCount = 0;
  int jarLevel = 7;
  int cookieCount = 0;
  double errorAlpha = 0;
}

class DivisionofFractions extends StatefulWidget {
  const DivisionofFractions({super.key});

  @override
  State<DivisionofFractions> createState() => _DivisionofFractionsState();
}

class _DivisionofFractionsState extends State<DivisionofFractions>
    with SingleTickerProviderStateMixin {
  bool _isSidebarOpen = true;
  bool _showCurtain = true;
  double _curtainOffset = 0;

  String _lang = 'en';
  int _scenario = 1;
  int _step = 0;

  // Overlays
  bool _isSuccessPopupVisible = false;
  String? _overlayType; // null, 'wheel', 'input'
  String _overlayPrompt = '';
  String _overlayCorrectAnswer = '';
  int _wheelDenom = 4;
  final TextEditingController _inputController = TextEditingController();

  // Animation & Transform
  late Ticker _ticker;
  double _time = 0;
  final TransformationController _transformationController =
      TransformationController();

  // Lab State
  List<ChocBar> _bars = [];
  SimTool? _tool;
  final List<SimEntity> _entities = [];
  SimVars _vars = SimVars();
  int _pieces = 0; // for S1

  // Base canvas coordinates
  final Rect _board = const Rect.fromLTWH(
    80 - 225,
    -20 - 110,
    450,
    220,
  ); // centered x,y

  bool _isCanvasDragging = false;
  dynamic _draggedItem; // Can be SimTool or SimEntity

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
        _updatePhysics();
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
    _inputController.dispose();
    super.dispose();
  }

  void _enterLab() {
    AudioEngine.play('shutter');
    setState(() {
      _curtainOffset = -MediaQuery.of(context).size.height;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
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
      _isSuccessPopupVisible = false;
      _overlayType = null;

      _bars.clear();
      _entities.clear();
      _vars = SimVars();
      _tool = null;
      _pieces = 0;

      if (_scenario == 1) {
        _bars = [
          ChocBar(id: 1, x: -110, y: 0, pieces: 1),
          ChocBar(id: 2, x: 10, y: 0, pieces: 1),
          ChocBar(id: 3, x: 130, y: 0, pieces: 1),
        ];
        _tool = SimTool(x: 350, y: -20, type: 'slicer');
      } else if (_scenario == 2) {
        _vars.pizzaState = 'half';
        _entities.add(SimEntity(type: 'plate', x: -160, y: 120));
        _entities.add(SimEntity(type: 'plate', x: -55, y: 120));
        _entities.add(SimEntity(type: 'plate', x: 50, y: 120));
        _entities.add(SimEntity(type: 'plate', x: 155, y: 120));
        for (int i = 0; i < 4; i++) {
          double angle = math.pi / 2 + (i * math.pi / 4);
          double px = math.cos(angle + math.pi / 8) * 40;
          double py = -60 + math.sin(angle + math.pi / 8) * 40;
          _entities.add(
            SimEntity(type: 'slice', x: px, y: py, rot: angle, visible: false),
          );
        }
        _tool = SimTool(x: 180, y: -60, type: '4x');
      } else if (_scenario == 3) {
        _vars.beakerLevel = 6;
        _vars.rackCount = 0;
        _tool = SimTool(x: 0, y: 50, type: 'scoop');
      } else if (_scenario == 4) {
        _vars.ribbonLength = 10;
        _vars.basketCount = 0;
        _tool = SimTool(x: -250, y: -50, type: 'cutter');
      } else if (_scenario == 5) {
        _vars.jarLevel = 7;
        _vars.cookieCount = 0;
        _tool = SimTool(x: 0, y: 80, type: 'measure');
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resetZoom();
      });
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
    double scale = math.min(scaleX, scaleY) * 0.95;
    if (scale < 0.1) scale = 0.1;
    if (scale > 3.0) scale = 3.0;

    double dx = effectiveSidebarWidth + (availableWidth - (1200 * scale)) / 2;
    double dy = (availableHeight - (800 * scale)) / 2;

    _transformationController.value =
        Matrix4.identity()
          ..translate(dx, dy)
          ..scale(scale);
  }

  void _advanceStep() {
    AudioEngine.play('success');
    setState(() {
      _step++;
    });
  }

  void _updatePhysics() {
    if (_scenario == 4) {
      bool activePieces = false;
      for (var p in _entities) {
        if (p.type == 'piece' && p.visible) {
          activePieces = true;
          p.frames++;
          p.vy += 0.5; // gravity
          p.x += p.vx;
          p.y += p.vy;

          if (p.frames > 20) {
            p.visible = false;
            _vars.basketCount++;
            AudioEngine.play('snap');
          }
        }
      }
      if (activePieces) {
        _entities.removeWhere((e) => e.type == 'piece' && !e.visible);
      }
    }

    if (_scenario == 5) {
      if (_vars.errorAlpha > 0) {
        _vars.errorAlpha -= 0.02;
        if (_vars.errorAlpha < 0) _vars.errorAlpha = 0;
      }
    }
  }

  Offset _getCanvasPoint(Offset localPos) {
    final Matrix4 inverse = Matrix4.copy(_transformationController.value)
      ..invert();
    final Offset scenePoint = MatrixUtils.transformPoint(inverse, localPos);
    return Offset(scenePoint.dx - 600, scenePoint.dy - 400); // Center is 0,0
  }

  void _handlePointerDown(PointerDownEvent e) {
    if (_overlayType != null || _isSuccessPopupVisible) return;
    Offset worldPt = _getCanvasPoint(e.localPosition);

    // Scenario 4 Cutter button
    if (_scenario == 4 && _step < 2 && _tool != null && _tool!.visible) {
      if (_tool!.snapped &&
          worldPt.dx > _tool!.x - 20 &&
          worldPt.dx < _tool!.x + 20 &&
          worldPt.dy > _tool!.y + 25 &&
          worldPt.dy < _tool!.y + 50) {
        setState(() {
          _vars.ribbonLength--;
          double dx = 350 - _tool!.x;
          double dy = 30 - _tool!.y;
          double vx = dx / 20;
          double vy = (dy - 0.5 * 0.5 * 20 * 20) / 20;

          _entities.add(
            SimEntity(
              type: 'piece',
              x: _tool!.x,
              y: _tool!.y,
              vx: vx,
              vy: vy,
              visible: true,
            ),
          );
          AudioEngine.play('cut');

          _tool!.snapped = false;
          _tool!.x += 10;
          _tool!.y -= 30;

          if (_vars.ribbonLength == 0) {
            _tool!.visible = false;
            _advanceStep(); // Step 2
            _overlayPrompt = "Final count of pieces:";
            _overlayCorrectAnswer = "10";
            _overlayType = 'input';
            _inputController.clear();
          }
        });
        return;
      }
    }

    // Drag Tools
    if (_tool != null && _tool!.visible && !_tool!.snapped) {
      double dist = math.sqrt(
        math.pow(worldPt.dx - _tool!.x, 2) + math.pow(worldPt.dy - _tool!.y, 2),
      );
      double threshold = 80.0; // Uniform generous threshold for touch devices

      // Additional checks for active steps
      bool canDrag = false;
      if (_scenario == 1 && _step < 3) canDrag = true;
      if (_scenario == 2 && _step == 0) canDrag = true;
      if (_scenario == 3 && _step < 3) canDrag = true;
      if (_scenario == 4 && _step < 2) canDrag = true;
      if (_scenario == 5 && _step < 2) canDrag = true;

      if (canDrag && dist < threshold) {
        setState(() {
          _draggedItem = _tool;
          _tool!.dragging = true;
          _isCanvasDragging = true; // Lock canvas panning while dragging tool
          if (_scenario == 4) _tool!.snapped = false;
        });
        AudioEngine.play('click');
        return;
      }
    }

    // Drag Pizza Slices
    if (_scenario == 2 && _step == 1) {
      for (var s in _entities) {
        if (s.type == 'slice' && s.visible) {
          if (math.sqrt(
                math.pow(worldPt.dx - s.x, 2) + math.pow(worldPt.dy - s.y, 2),
              ) <
              60) {
            // Generous
            setState(() {
              _draggedItem = s;
              s.dragging = true;
              _isCanvasDragging =
                  true; // Lock canvas panning while dragging slice
            });
            AudioEngine.play('click');
            return;
          }
        }
      }
    }
  }

  void _handlePointerMove(PointerMoveEvent e) {
    if (_draggedItem != null) {
      Offset worldPt = _getCanvasPoint(e.localPosition);
      setState(() {
        _draggedItem!.x = worldPt.dx;
        _draggedItem!.y = worldPt.dy;
      });
    }
  }

  void _handlePointerUp(PointerUpEvent e) {
    if (_draggedItem != null) {
      Offset worldPt = _getCanvasPoint(e.localPosition);
      bool dropped = false;

      setState(() {
        if (_draggedItem is SimTool) {
          SimTool t = _draggedItem as SimTool;
          t.dragging = false;

          if (_scenario == 1) {
            if (_step < 3) {
              ChocBar targetBar = _bars[_step];
              double absoluteTargetX = 80 + targetBar.x;
              double absoluteTargetY = -20 + targetBar.y;

              if ((worldPt.dx - absoluteTargetX).abs() < 60 &&
                  (worldPt.dy - absoluteTargetY).abs() < 100) {
                targetBar.pieces = 2;
                _pieces += 2;
                dropped = true;
                AudioEngine.play('cut');
                t.x = t.origX;
                t.y = t.origY;
                _advanceStep();
              }
            }
          } else if (_scenario == 2) {
            if (_step == 0) {
              if (math.sqrt(
                    math.pow(worldPt.dx, 2) + math.pow(worldPt.dy - (-60), 2),
                  ) <
                  80) {
                t.visible = false;
                _vars.pizzaState = 'cut';
                for (var e in _entities) {
                  if (e.type == 'slice') e.visible = true;
                }
                dropped = true;
                AudioEngine.play('cut');
                _advanceStep();
              }
            }
          } else if (_scenario == 3) {
            if (!t.filled && _vars.beakerLevel > 0) {
              if (math.sqrt(
                    math.pow(worldPt.dx - (-150), 2) +
                        math.pow(worldPt.dy - 50, 2),
                  ) <
                  100) {
                t.filled = true;
                _vars.beakerLevel--;
                dropped = true;
                AudioEngine.play('splash');
                if (_step == 0) _advanceStep();
              }
            }
            if (t.filled) {
              if (math.sqrt(
                    math.pow(worldPt.dx - 150, 2) +
                        math.pow(worldPt.dy - 50, 2),
                  ) <
                  150) {
                t.filled = false;
                _vars.rackCount++;
                dropped = true;
                AudioEngine.play('snap');
                if (_step == 1) _advanceStep();
                if (_step == 2 && _vars.rackCount == 6) {
                  _advanceStep();
                }
              }
            }
          } else if (_scenario == 4) {
            if (_step < 2) {
              double startX = -100 + (10 - _vars.ribbonLength) * 40;
              double targetX = startX + 20;
              double targetY = -20;

              if ((worldPt.dx - targetX).abs() < 40 &&
                  (worldPt.dy - targetY).abs() < 40) {
                t.x = targetX;
                t.y = targetY;
                t.snapped = true;
                dropped = true;
                AudioEngine.play('snap');
                if (_step == 0) _advanceStep();
              } else {
                t.snapped = false;
              }
            }
          } else if (_scenario == 5) {
            if (!t.filled) {
              if (math.sqrt(
                    math.pow(worldPt.dx - (-100), 2) +
                        math.pow(worldPt.dy - 80, 2),
                  ) <
                  100) {
                if (_vars.jarLevel >= 2) {
                  t.filled = true;
                  _vars.jarLevel -= 2;
                  dropped = true;
                  AudioEngine.play('splash');
                  if (_step == 0) _advanceStep();
                } else {
                  _vars.errorAlpha = 1.0;
                  AudioEngine.play('error');
                }
              }
            }
            if (t.filled) {
              if (math.sqrt(
                    math.pow(worldPt.dx - 150, 2) +
                        math.pow(worldPt.dy - 80, 2),
                  ) <
                  100) {
                t.filled = false;
                _vars.cookieCount++;
                dropped = true;
                AudioEngine.play('snap');
                if (_step == 1 && _vars.cookieCount == 3) {
                  _advanceStep();
                  _overlayPrompt = "Total Full Batches:";
                  _overlayCorrectAnswer = "3";
                  _overlayType = 'input';
                  _inputController.clear();
                }
              }
            }
          }

          if (!dropped) {
            t.x = t.origX;
            t.y = t.origY;
            if (t.type != 'cutter') AudioEngine.play('pop');
          }
        } else if (_draggedItem is SimEntity) {
          SimEntity s = _draggedItem as SimEntity;
          s.dragging = false;

          if (_scenario == 2 && _step == 1) {
            for (int i = 0; i < 4; i++) {
              SimEntity p = _entities[i];
              if (p.type == 'plate' && !p.filled) {
                if (math.sqrt(
                      math.pow(worldPt.dx - p.x, 2) +
                          math.pow(worldPt.dy - p.y, 2),
                    ) <
                    60) {
                  s.x = p.x;
                  s.y = p.y;
                  s.plateId = i;
                  p.filled = true;
                  s.rot = math.pi / 4;
                  dropped = true;
                  AudioEngine.play('snap');
                  break;
                }
              }
            }
            if (!dropped) {
              s.x = s.origX;
              s.y = s.origY;
              AudioEngine.play('pop');
            }

            if (_entities.where((e) => e.type == 'plate' && e.filled).length ==
                4) {
              _advanceStep();
            }
          }
        }
        _draggedItem = null;
        _isCanvasDragging = false; // Restore pan functionality
      });
    }
  }

  void _triggerUniversalAction() {
    setState(() {
      if (_scenario == 1 && _step == 3) {
        AudioEngine.play('success');
        _advanceStep();
        Future.delayed(const Duration(milliseconds: 1000), _showSummary);
      } else if (_scenario == 2 && _step == 2) {
        _vars.pizzaState = 'outline';
        AudioEngine.play('success');
        _advanceStep();
        _overlayType = 'wheel';
        _wheelDenom = 4;
      } else if (_scenario == 3 && _step == 3) {
        if (!_vars.equationVisible) {
          _vars.equationVisible = true;
          AudioEngine.play('success');
        } else {
          _vars.showMathConnection = true;
          AudioEngine.play('success');
          Future.delayed(const Duration(milliseconds: 1500), _showSummary);
        }
      }
    });
  }

  void _checkWheel() {
    if (_wheelDenom == 8) {
      AudioEngine.play('success');
      setState(() {
        _overlayType = null;
        _vars.showEquation = true;
        _advanceStep();
      });
      Future.delayed(const Duration(milliseconds: 1000), _showSummary);
    } else {
      AudioEngine.play('error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Look at the total slices in the full pizza outline!"),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _checkInput() {
    String val = _inputController.text.trim();
    if (val == _overlayCorrectAnswer) {
      AudioEngine.play('success');
      setState(() {
        _overlayType = null;
        _advanceStep();
      });
      Future.delayed(const Duration(milliseconds: 1000), _showSummary);
    } else {
      AudioEngine.play('error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Try again!"),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSummary() {
    AudioEngine.play('success');
    setState(() {
      _isSuccessPopupVisible = true;
    });
  }

  Widget _buildOverlays() {
    if (_overlayType == null) return const SizedBox.shrink();

    Widget content;
    if (_overlayType == 'wheel') {
      content = Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.amber, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Fraction on one plate:",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "1",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 4,
                    height: 48,
                    color: Colors.blueGrey,
                    transform: Matrix4.rotationZ(0.2),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_drop_up,
                          color: Colors.amber,
                          size: 32,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          AudioEngine.play('click');
                          setState(
                            () => _wheelDenom = math.min(16, _wheelDenom + 1),
                          );
                        },
                      ),
                      Text(
                        "$_wheelDenom",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.amber,
                          size: 32,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          AudioEngine.play('click');
                          setState(
                            () => _wheelDenom = math.max(1, _wheelDenom - 1),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkWheel,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10b981),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      content = Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.amber, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _overlayPrompt,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _inputController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.amber, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.amber, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.amberAccent,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkInput,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10b981),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(child: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth * 0.30;
    if (sidebarWidth < 300) sidebarWidth = 300;

    // Get Scenario config
    int maxSteps = 4;
    if (_scenario == 4 || _scenario == 5) maxSteps = 3;
    List<Map<String, String>> steps = [];
    for (int i = 1; i <= maxSteps; i++) {
      steps.add({
        'hud': getString('s${_scenario}_hud$i'),
        'text': getString('s${_scenario}_t$i'),
      });
    }
    String objective = getString('s${_scenario}_obj');
    String title = getString('appTitle');
    String subtitle = getString('appSubtitle');

    // Universal Action Button Logic
    bool showUniversalBtn = false;
    String universalTxt = "";
    if (_scenario == 1 && _step == 3) {
      showUniversalBtn = true;
      universalTxt = getString('checkAns');
    }
    if (_scenario == 2 && _step == 2) {
      showUniversalBtn = true;
      universalTxt = "Reveal Whole";
    }
    if (_scenario == 3 && _step == 3) {
      showUniversalBtn = true;
      universalTxt =
          _vars.equationVisible
              ? getString('mathConnBtn')
              : getString('checkAns');
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // --- MAIN CANVAS AREA ---
            Positioned.fill(
              child: Container(
                color: const Color(0xFF0F172A), // Fully dark base color
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: _handlePointerDown,
                  onPointerMove: _handlePointerMove,
                  onPointerUp: _handlePointerUp,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    panEnabled:
                        !_isCanvasDragging, // Ensure panning disables correctly
                    scaleEnabled: !_isCanvasDragging,
                    minScale: 0.1,
                    maxScale: 4.0,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    constrained: false,
                    child: SizedBox(
                      width: 1200,
                      height: 800,
                      child: CustomPaint(
                        painter: BakeOffPainter(
                          time: _time,
                          scenario: _scenario,
                          step: _step,
                          bars: _bars,
                          tool: _tool,
                          entities: _entities,
                          vars: _vars,
                          pieces: _pieces,
                          draggedItem: _draggedItem,
                          board: _board,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Overlay (Wheel or Input)
            if (_overlayType != null) Positioned.fill(child: _buildOverlays()),

            // Bottom HUD
            if (_step < steps.length &&
                !_isSuccessPopupVisible &&
                _overlayType == null)
              Positioned(
                bottom: 24,
                left: _isSidebarOpen ? sidebarWidth : 0,
                right: 0,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showUniversalBtn)
                        ElevatedButton.icon(
                          onPressed: _triggerUniversalAction,
                          icon: const Icon(Icons.check),
                          label: Text(universalTxt),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366f1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                          ),
                        ),
                      if (showUniversalBtn) const SizedBox(height: 12),
                      Container(
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
                                steps[_step]['hud']!,
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
                    ],
                  ),
                ),
              ),

            // --- LEFT SIDEBAR (Completely scrollable from top to bottom, No SafeArea) ---
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
                      // Header Text - Adjusted padding to respect missing SafeArea
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.amberAccent,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Controls
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                onPressed: () {
                                  AudioEngine.play('pop');
                                  setState(() {
                                    if (_lang == 'en') {
                                      _lang = 'hi';
                                    } else {
                                      _lang = 'en';
                                    }
                                  });
                                },
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
                                onPressed: () {
                                  AudioEngine.play('error');
                                  setState(() {
                                    _lang = 'en';
                                    _isSidebarOpen =
                                        MediaQuery.of(context).size.width >=
                                        768;
                                    _curtainOffset = 0;
                                    _showCurtain = true;
                                  });
                                  _loadScenario(1);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Scenario Dropdown & Body
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                    objective,
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
                            ...List.generate(steps.length, (index) {
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
                                          Text(
                                            steps[index]['text']!
                                                .replaceAll('<b>', '')
                                                .replaceAll('</b>', '')
                                                .replaceAll('<br>', '\n'),
                                            style: TextStyle(
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
                            if (_isSuccessPopupVisible || _step >= steps.length)
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
                      const Divider(color: Colors.white24, height: 1),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                                    _loadScenario(1);
                                  }
                                });
                              },
                              icon: const Icon(Icons.thumb_up),
                              label: Text(
                                _scenario == 5
                                    ? getString('doneBtn')
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
                        ),
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
class BakeOffPainter extends CustomPainter {
  final double time;
  final int scenario;
  final int step;
  final List<ChocBar> bars;
  final SimTool? tool;
  final List<SimEntity> entities;
  final SimVars vars;
  final int pieces;
  final dynamic draggedItem;
  final Rect board;

  BakeOffPainter({
    required this.time,
    required this.scenario,
    required this.step,
    required this.bars,
    required this.tool,
    required this.entities,
    required this.vars,
    required this.pieces,
    this.draggedItem,
    required this.board,
  });

  @override
  void paint(Canvas canvas, Size size) {
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

    if (scenario == 1) {
      _drawChef(canvas, -300, 0);
      _drawBoard(
        canvas,
        board.left + board.width / 2,
        board.top + board.height / 2,
        board.width,
        board.height,
      );
      for (var b in bars) {
        _drawChocBar(
          canvas,
          board.left + board.width / 2 + b.x,
          board.top + board.height / 2 + b.y,
          b.pieces == 2,
          b.pieces == 2,
        );
      }
      if (pieces > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(
                board.left + board.width / 2,
                board.top + board.height + 20,
              ),
              width: 120,
              height: 40,
            ),
            const Radius.circular(8),
          ),
          Paint()..color = const Color(0xFF0F172A),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(
                board.left + board.width / 2,
                board.top + board.height + 20,
              ),
              width: 120,
              height: 40,
            ),
            const Radius.circular(8),
          ),
          Paint()
            ..color = const Color(0xFF334155)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        _drawText(
          canvas,
          "Pieces: $pieces",
          Offset(board.left + board.width / 2, board.top + board.height + 20),
          Colors.white,
          18,
        );
      }
      if (step == 4) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(board.left + board.width / 2, board.top - 140),
              width: 300,
              height: 70,
            ),
            const Radius.circular(12),
          ),
          Paint()..color = const Color(0xFF0F172A),
        );
        _drawText(
          canvas,
          "3 ÷ 1/2 = 6",
          Offset(board.left + board.width / 2, board.top - 140),
          const Color(0xFF10b981),
          36,
        );
      }
      if (tool != null && step < 3) {
        _drawSlicer(canvas, tool!.x, tool!.y, "1/2");
      }
    } else if (scenario == 2) {
      _drawChef(canvas, -300, -20);
      if (step == 4 && vars.showEquation) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: const Offset(100, -215),
              width: 250,
              height: 70,
            ),
            const Radius.circular(12),
          ),
          Paint()..color = const Color(0xFF0F172A),
        );
        _drawText(
          canvas,
          "1/2 ÷ 4 = 1/8",
          const Offset(100, -215),
          const Color(0xFF10b981),
          36,
        );
      }
      _drawPizza(canvas, 0, -60, vars.pizzaState);
      for (var p in entities.where((e) => e.type == 'plate')) {
        _drawPlate(canvas, p.x, p.y, p.filled);
      }
      for (var s in entities.where((e) => e.type == 'slice' && e.visible)) {
        bool highlighted = (step >= 3 && s.plateId == 0);
        _drawPizzaSlice(canvas, s.x, s.y, s.rot, highlighted);
      }
      if (tool != null && step == 0 && tool!.visible) {
        _drawSlicer(canvas, tool!.x, tool!.y, "4x");
      }
    } else if (scenario == 3) {
      _drawChef(canvas, -350, 0);
      _drawBeaker(canvas, -150, 50, vars.beakerLevel);
      _drawRack(canvas, 150, 50, vars.rackCount);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(90, -30),
            width: 120,
            height: 40,
          ),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFF0F172A),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(90, -30),
            width: 120,
            height: 40,
          ),
          const Radius.circular(8),
        ),
        Paint()
          ..color = const Color(0xFF334155)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _drawText(
        canvas,
        "Scoops: ${vars.rackCount}",
        const Offset(90, -30),
        Colors.white,
        16,
      );

      if (step == 3 && vars.equationVisible) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: const Offset(0, -180),
              width: 300,
              height: 80,
            ),
            const Radius.circular(12),
          ),
          Paint()..color = const Color(0xFF0F172A),
        );
        if (vars.showMathConnection) {
          _drawText(
            canvas,
            "3/4 × 8/1 = 6",
            const Offset(0, -195),
            const Color(0xFF10b981),
            32,
          );
          _drawText(
            canvas,
            "(Invert & Multiply)",
            const Offset(0, -165),
            const Color(0xFFf59e0b),
            16,
          );
        } else {
          _drawText(
            canvas,
            "3/4 ÷ 1/8 = 6",
            const Offset(0, -180),
            const Color(0xFF10b981),
            32,
          );
        }
      }
      if (tool != null && step < 3) {
        _drawScoop(canvas, tool!.x, tool!.y, tool!.filled);
      }
    } else if (scenario == 4) {
      canvas.drawRect(
        const Rect.fromLTWH(-2000, 80, 4000, 2000),
        Paint()..color = const Color(0xFF8b5a2b),
      );
      canvas.drawLine(
        const Offset(-2000, 80),
        const Offset(2000, 80),
        Paint()
          ..color = const Color(0xFF5c4033)
          ..strokeWidth = 4,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(0, -210),
            width: 440,
            height: 60,
          ),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFF0F172A),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(0, -210),
            width: 440,
            height: 60,
          ),
          const Radius.circular(8),
        ),
        Paint()
          ..color = const Color(0xFF334155)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _drawText(
        canvas,
        "Word Problem: 5/2m ribbon cut into 1/4m pieces.",
        const Offset(0, -210),
        Colors.white,
        16,
      );

      _drawChef(canvas, -380, -20);
      _drawRibbonEnv(canvas, -100, 0, vars.ribbonLength);

      for (var p in entities.where((e) => e.type == 'piece' && e.visible)) {
        canvas.drawRect(
          Rect.fromLTWH(p.x - 20, p.y - 15, 40, 30),
          Paint()..color = const Color(0xFFf43f5e),
        );
      }

      if (tool != null && tool!.visible != false && step < 2) {
        canvas.save();
        canvas.translate(tool!.x, tool!.y);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-20, -15, 40, 30),
            const Radius.circular(4),
          ),
          Paint()..color = const Color(0xFFec4899).withOpacity(0.3),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-20, -15, 40, 30),
            const Radius.circular(4),
          ),
          Paint()
            ..color = const Color(0xFFf43f5e)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
        if (tool!.snapped) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(-20, 25, 40, 25),
              const Radius.circular(4),
            ),
            Paint()..color = const Color(0xFF10b981),
          );
          _drawText(canvas, "Cut", const Offset(0, 37), Colors.white, 12);
        } else {
          _drawText(
            canvas,
            "1/4m",
            const Offset(0, -25),
            const Color(0xFFf43f5e),
            14,
          );
        }
        canvas.restore();
      }

      if (step == 3) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: const Offset(0, -95),
              width: 250,
              height: 70,
            ),
            const Radius.circular(12),
          ),
          Paint()..color = const Color(0xFF0F172A),
        );
        _drawText(
          canvas,
          "5/2 ÷ 1/4 = 10",
          const Offset(0, -95),
          const Color(0xFF10b981),
          32,
        );
      }
    } else if (scenario == 5) {
      _drawChef(canvas, -380, 0);
      _drawJar(canvas, -100, 80, vars.jarLevel);
      _drawBowl(canvas, 150, 80, vars.cookieCount);
      if (tool != null && step < 2) {
        _drawMeasureScoop(canvas, tool!.x, tool!.y, tool!.filled);
      }
      if (step == 3) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: const Offset(0, -160),
              width: 400,
              height: 70,
            ),
            const Radius.circular(12),
          ),
          Paint()..color = const Color(0xFF0F172A),
        );
        _drawText(
          canvas,
          "2 1/3 ÷ 2/3 = 3 with 1/3 left",
          const Offset(0, -160),
          const Color(0xFF10b981),
          24,
        );
      }
    }

    if (draggedItem != null) {
      if (draggedItem is SimTool) {
        SimTool t = draggedItem as SimTool;
        if (scenario == 1 && step < 3) {
          _drawSlicer(canvas, t.x, t.y, "1/2");
        } else if (scenario == 2 && step == 0)
          _drawSlicer(canvas, t.x, t.y, "4x");
        else if (scenario == 3 && step < 3)
          _drawScoop(canvas, t.x, t.y, t.filled);
        else if (scenario == 4 && step < 2) {
          canvas.save();
          canvas.translate(t.x, t.y);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(-20, -15, 40, 30),
              const Radius.circular(4),
            ),
            Paint()..color = const Color(0xFFec4899).withOpacity(0.3),
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(-20, -15, 40, 30),
              const Radius.circular(4),
            ),
            Paint()
              ..color = const Color(0xFFf43f5e)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
          _drawText(
            canvas,
            "1/4m",
            const Offset(0, -25),
            const Color(0xFFf43f5e),
            14,
          );
          canvas.restore();
        } else if (scenario == 5 && step < 2)
          _drawMeasureScoop(canvas, t.x, t.y, t.filled);
      } else if (draggedItem is SimEntity) {
        SimEntity s = draggedItem as SimEntity;
        if (s.type == 'slice') _drawPizzaSlice(canvas, s.x, s.y, s.rot, true);
      }
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    Color color,
    double fontSize,
  ) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawChef(Canvas canvas, double x, double y) {
    canvas.save();
    canvas.translate(x, y);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 110), width: 60, height: 16),
      Paint()..color = Colors.black.withOpacity(0.1),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-15, 70, 10, 30),
      Paint()..color = const Color(0xFF0f172a),
    );
    canvas.drawRect(
      const Rect.fromLTWH(5, 70, 10, 30),
      Paint()..color = const Color(0xFF0f172a),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-10, 100), width: 30, height: 16),
      Paint()..color = const Color(0xFF0f172a),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(10, 100), width: 30, height: 16),
      Paint()..color = const Color(0xFF0f172a),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-25, 20, 50, 60),
        const Radius.circular(15),
      ),
      Paint()..color = const Color(0xFFf1f5f9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-25, 20, 50, 60),
        const Radius.circular(15),
      ),
      Paint()
        ..color = const Color(0xFFe2e8f0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    Path coat =
        Path()
          ..moveTo(-10, 45)
          ..lineTo(10, 45)
          ..lineTo(-10, 65)
          ..lineTo(10, 65)
          ..close();
    canvas.drawPath(coat, Paint()..color = const Color(0xFF94a3b8));
    Path scarf =
        Path()
          ..moveTo(-15, 20)
          ..lineTo(15, 20)
          ..lineTo(0, 35)
          ..close();
    canvas.drawPath(scarf, Paint()..color = const Color(0xFFef4444));
    canvas.drawCircle(
      Offset.zero,
      22,
      Paint()..color = const Color(0xFFfde047),
    );
    canvas.drawCircle(
      const Offset(-8, 0),
      3,
      Paint()..color = const Color(0xFF451a03),
    );
    canvas.drawCircle(
      const Offset(8, 0),
      3,
      Paint()..color = const Color(0xFF451a03),
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 5), radius: 8),
      0,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFd97706)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    Paint hatP = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(0, -35), 25, hatP);
    canvas.drawCircle(const Offset(-18, -25), 18, hatP);
    canvas.drawCircle(const Offset(18, -25), 18, hatP);
    canvas.drawRect(const Rect.fromLTWH(-22, -20, 44, 15), hatP);
    canvas.drawRect(
      const Rect.fromLTWH(-22, -20, 44, 15),
      Paint()
        ..color = const Color(0xFFe2e8f0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    Paint armP =
        Paint()
          ..color = const Color(0xFFf1f5f9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-20, 30), const Offset(-40, 50), armP);
    canvas.drawLine(const Offset(20, 30), const Offset(40, 50), armP);
    canvas.drawCircle(
      const Offset(-40, 50),
      8,
      Paint()..color = const Color(0xFFfde047),
    );
    canvas.drawCircle(
      const Offset(40, 50),
      8,
      Paint()..color = const Color(0xFFfde047),
    );
    canvas.restore();
  }

  void _drawBoard(Canvas canvas, double x, double y, double w, double h) {
    canvas.save();
    canvas.translate(x, y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 5), width: w, height: h),
        const Radius.circular(20),
      ),
      Paint()..color = Colors.black.withOpacity(0.3),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        const Radius.circular(20),
      ),
      Paint()..color = const Color(0xFFfcd34d),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        const Radius.circular(20),
      ),
      Paint()
        ..color = const Color(0xFFd97706)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawCircle(
      Offset(-w / 2 - 20, 0),
      30,
      Paint()..color = const Color(0xFFfcd34d),
    );
    canvas.drawCircle(
      Offset(-w / 2 - 20, 0),
      30,
      Paint()
        ..color = const Color(0xFFd97706)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawCircle(
      Offset(-w / 2 - 30, 0),
      10,
      Paint()..color = const Color(0xFF0F172A),
    ); // Hole (simulated with bg color)
    canvas.restore();
  }

  void _drawChocBar(Canvas canvas, double x, double y, bool cut, bool glow) {
    double w = 90, h = 160;
    canvas.save();
    canvas.translate(x, y);
    if (glow) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w + 10, height: h + 10),
          const Radius.circular(8),
        ),
        Paint()
          ..color = const Color(0xFFfde047).withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    if (!cut) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFF451a03),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(6),
        ),
        Paint()
          ..color = const Color(0xFF290e01)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      Paint gridP =
          Paint()
            ..color = const Color(0xFF290e01)
            ..strokeWidth = 2;
      for (double i = -h / 2 + 40; i < h / 2; i += 40) {
        canvas.drawLine(Offset(-w / 2, i), Offset(w / 2, i), gridP);
      }
      canvas.drawLine(Offset(0, -h / 2), Offset(0, h / 2), gridP);
      Paint perfP =
          Paint()
            ..color = const Color(0xFFfcd34d).withOpacity(0.4)
            ..strokeWidth = 2;
      for (double i = -h / 2 - 10; i < h / 2 + 10; i += 10) {
        canvas.drawLine(Offset(0, i), Offset(0, i + 5), perfP);
      }
    } else {
      double gap = 12;
      // Left
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-w / 2 - gap / 2, -h / 2, w / 2, h),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFF451a03),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-w / 2 - gap / 2, -h / 2, w / 2, h),
          const Radius.circular(6),
        ),
        Paint()
          ..color = const Color(0xFF290e01)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      Paint gridP =
          Paint()
            ..color = const Color(0xFF290e01)
            ..strokeWidth = 2;
      for (double i = -h / 2 + 40; i < h / 2; i += 40) {
        canvas.drawLine(
          Offset(-w / 2 - gap / 2, i),
          Offset(-gap / 2, i),
          gridP,
        );
      }
      // Right
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(gap / 2, -h / 2, w / 2, h),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFF451a03),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(gap / 2, -h / 2, w / 2, h),
          const Radius.circular(6),
        ),
        Paint()
          ..color = const Color(0xFF290e01)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      for (double i = -h / 2 + 40; i < h / 2; i += 40) {
        canvas.drawLine(Offset(gap / 2, i), Offset(w / 2 + gap / 2, i), gridP);
      }
    }
    canvas.restore();
  }

  void _drawSlicer(Canvas canvas, double x, double y, String type) {
    canvas.save();
    canvas.translate(x, y);
    canvas.drawCircle(
      Offset.zero,
      35,
      Paint()
        ..color = const Color(0xFFfde047).withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      Offset.zero,
      30,
      Paint()..color = const Color(0xFFe2e8f0),
    );
    canvas.drawCircle(
      Offset.zero,
      30,
      Paint()
        ..color = const Color(0xFF94a3b8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    _drawText(canvas, type, Offset.zero, const Color(0xFF0f172a), 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, 30, 16, 60),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFf59e0b),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, 30, 16, 60),
        const Radius.circular(8),
      ),
      Paint()
        ..color = const Color(0xFFb45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      const Offset(0, 30),
      8,
      Paint()..color = const Color(0xFFb45309),
    );
    canvas.restore();
  }

  void _drawPizza(Canvas canvas, double x, double y, String stateVar) {
    canvas.save();
    canvas.translate(x, y);
    double r = 100;
    canvas.drawCircle(
      Offset.zero,
      r + 15,
      Paint()..color = const Color(0xFF94a3b8),
    );
    canvas.drawCircle(
      Offset.zero,
      r + 15,
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-r - 30, -15, 20, 30),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF94a3b8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(r + 10, -15, 20, 30),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF94a3b8),
    );

    if (stateVar == 'outline') {
      Paint outP =
          Paint()
            ..color = const Color(0xFF475569)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
      for (double a = 0; a < math.pi * 2; a += 0.2) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: r),
          a,
          0.1,
          false,
          outP,
        );
      }
      for (int i = 0; i < 8; i++) {
        canvas.drawLine(
          Offset.zero,
          Offset(math.cos(i * math.pi / 4) * r, math.sin(i * math.pi / 4) * r),
          outP,
        );
      }
    }
    if (stateVar == 'half') {
      Path p =
          Path()
            ..moveTo(0, 0)
            ..arcTo(
              Rect.fromCircle(center: Offset.zero, radius: r),
              math.pi / 2,
              math.pi,
              false,
            )
            ..close();
      canvas.drawPath(p, Paint()..color = const Color(0xFFd97706));
      Path p2 =
          Path()
            ..moveTo(0, 0)
            ..arcTo(
              Rect.fromCircle(center: Offset.zero, radius: r - 8),
              math.pi / 2,
              math.pi,
              false,
            )
            ..close();
      canvas.drawPath(p2, Paint()..color = const Color(0xFFfacc15));
      canvas.drawCircle(
        const Offset(-50, 0),
        8,
        Paint()..color = const Color(0xFFef4444),
      );
      canvas.drawCircle(
        const Offset(-25, -40),
        8,
        Paint()..color = const Color(0xFFef4444),
      );
      canvas.drawCircle(
        const Offset(-25, 40),
        8,
        Paint()..color = const Color(0xFFef4444),
      );
      canvas.drawLine(
        Offset.zero,
        Offset(0, -r),
        Paint()
          ..color = const Color(0xFFb45309)
          ..strokeWidth = 2,
      );
      canvas.drawLine(
        Offset.zero,
        Offset(0, r),
        Paint()
          ..color = const Color(0xFFb45309)
          ..strokeWidth = 2,
      );
      Paint perfP =
          Paint()
            ..color = const Color(0xFFfcd34d).withOpacity(0.4)
            ..strokeWidth = 2;
      for (double i = 0; i > -r; i -= 10) {
        canvas.drawLine(Offset(i, 0), Offset(i - 5, 0), perfP);
      }
      for (double i = 0; i > -r * 0.7; i -= 7) {
        canvas.drawLine(Offset(i, i), Offset(i - 3.5, i - 3.5), perfP);
      }
      for (double i = 0; i > -r * 0.7; i -= 7) {
        canvas.drawLine(Offset(i, -i), Offset(i - 3.5, -i + 3.5), perfP);
      }
    }
    canvas.restore();
  }

  void _drawPizzaSlice(
    Canvas canvas,
    double x,
    double y,
    double rot,
    bool isHighlighted,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rot);
    double r = 100;
    if (isHighlighted) {
      canvas.drawCircle(
        const Offset(-30, 0),
        50,
        Paint()
          ..color = const Color(0xFFfde047).withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    Path p =
        Path()
          ..moveTo(0, 0)
          ..arcTo(
            Rect.fromCircle(center: Offset.zero, radius: r),
            math.pi,
            math.pi / 4,
            false,
          )
          ..close();
    canvas.drawPath(p, Paint()..color = const Color(0xFFd97706));
    Path p2 =
        Path()
          ..moveTo(0, 0)
          ..arcTo(
            Rect.fromCircle(center: Offset.zero, radius: r - 8),
            math.pi,
            math.pi / 4,
            false,
          )
          ..close();
    canvas.drawPath(p2, Paint()..color = const Color(0xFFfacc15));
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFFb45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      const Offset(-45, -20),
      6,
      Paint()..color = const Color(0xFFef4444),
    );
    canvas.restore();
  }

  void _drawPlate(Canvas canvas, double x, double y, bool glow) {
    canvas.save();
    canvas.translate(x, y);
    if (glow)
      canvas.drawCircle(
        Offset.zero,
        55,
        Paint()
          ..color = const Color(0xFFfde047).withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    canvas.drawCircle(Offset.zero, 50, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset.zero,
      40,
      Paint()
        ..color = const Color(0xFFcbd5e1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.restore();
  }

  void _drawBeaker(Canvas canvas, double x, double y, int level) {
    canvas.save();
    canvas.translate(x, y);
    double w = 120, h = 180;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w / 2, -h, w, h),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.white.withOpacity(0.1),
    );
    if (level > 0) {
      double liqH = (level / 8) * (h - 20);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-w / 2 + 5, -liqH - 5, w - 10, liqH),
          const Radius.circular(5),
        ),
        Paint()..color = const Color(0xFF38bdf8).withOpacity(0.8),
      );
    }
    Paint glP =
        Paint()
          ..color = const Color(0xFFcbd5e1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w / 2, -h, w, h),
        const Radius.circular(10),
      ),
      glP,
    );
    for (int i = 1; i <= 8; i++) {
      double ty = -(i / 8) * (h - 20) - 5;
      canvas.drawLine(Offset(-w / 2, ty), Offset(-w / 2 + 15, ty), glP);
      if (i % 2 == 0) {
        String txt =
            i == 2
                ? "1/4"
                : i == 4
                ? "1/2"
                : i == 6
                ? "3/4"
                : "1";
        TextPainter tp = TextPainter(
          text: TextSpan(
            text: txt,
            style: const TextStyle(
              color: Color(0xFFcbd5e1),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
        )..layout();
        tp.paint(canvas, Offset(-w / 2 - 5 - tp.width, ty - tp.height / 2));
      }
    }
    canvas.restore();
  }

  void _drawRack(Canvas canvas, double x, double y, int count) {
    canvas.save();
    canvas.translate(x, y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-150, 0, 300, 20),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF8b5a2b),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-140, 20, 15, 40),
      Paint()..color = const Color(0xFF5c4033),
    );
    canvas.drawRect(
      const Rect.fromLTWH(125, 20, 15, 40),
      Paint()..color = const Color(0xFF5c4033),
    );
    for (int i = 0; i < 6; i++) {
      double sx = -110 + i * 44;
      canvas.drawRect(
        Rect.fromLTWH(sx - 3, -15, 6, 15),
        Paint()..color = const Color(0xFFcbd5e1),
      );
      if (count > i) _drawScoop(canvas, sx, -10, true);
    }
    canvas.restore();
  }

  void _drawScoop(Canvas canvas, double x, double y, bool filled) {
    canvas.save();
    canvas.translate(x, y);
    Path p =
        Path()
          ..moveTo(15, 0)
          ..arcToPoint(const Offset(-15, 0), radius: const Radius.circular(15))
          ..lineTo(-5, -40)
          ..lineTo(5, -40)
          ..close();
    canvas.drawPath(p, Paint()..color = const Color(0xFFe2e8f0));
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF94a3b8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (filled) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 13),
        0,
        math.pi,
        false,
        Paint()..color = const Color(0xFF38bdf8).withOpacity(0.9),
      );
    }
    _drawText(canvas, "1/8", const Offset(0, -25), const Color(0xFF0f172a), 10);
    canvas.restore();
  }

  void _drawRibbonEnv(Canvas canvas, double x, double y, int len) {
    canvas.save();
    canvas.translate(x, y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-20, -100, 450, 200),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFF334155),
    );
    Paint gridP =
        Paint()
          ..color = const Color(0xFF475569)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    for (double i = 0; i <= 450; i += 20) {
      canvas.drawLine(Offset(i - 20, -100), Offset(i - 20, 100), gridP);
    }
    for (double i = -100; i <= 100; i += 20) {
      canvas.drawLine(Offset(-20, i), Offset(430, i), gridP);
    }

    canvas.drawRect(
      const Rect.fromLTWH(-20, 70, 450, 20),
      Paint()..color = const Color(0xFFfde68a),
    );
    Paint tickP = Paint()..color = const Color(0xFFb45309);
    for (int i = 0; i <= 10; i++) {
      double px = i * 40.0;
      canvas.drawRect(Rect.fromLTWH(px, 70, 2, 10), tickP);
      if (i % 4 == 0) {
        _drawText(
          canvas,
          "${i / 4}m",
          Offset(px, 105),
          const Color(0xFFb45309),
          12,
        );
        canvas.drawRect(Rect.fromLTWH(px, 70, 2, 20), tickP);
      }
    }
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-20, -20), width: 80, height: 100),
      Paint()..color = const Color(0xFF1d4ed8),
    );
    Paint splP =
        Paint()
          ..color = const Color(0xFF1e3a8a)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
    for (double i = 10; i < 40; i += 10) {
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(-20, -20),
          width: i * 2,
          height: i * 2.4,
        ),
        splP,
      );
    }

    if (len > 0) {
      double startX = (10 - len) * 40;
      double w = len * 40;
      canvas.drawRect(
        Rect.fromLTWH(startX, -35, w, 30),
        Paint()..color = const Color(0xFF3b82f6),
      );
      canvas.drawRect(
        Rect.fromLTWH(startX, -35, w, 30),
        Paint()
          ..color = const Color(0xFF1d4ed8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      Paint perfP =
          Paint()
            ..color = Colors.white.withOpacity(0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
      for (int i = 1; i < len; i++) {
        for (double y = -35; y < -5; y += 6) {
          canvas.drawLine(
            Offset(startX + i * 40, y),
            Offset(startX + i * 40, y + 3),
            perfP,
          );
        }
      }
    }

    canvas.translate(450, 30);
    Path bPath =
        Path()
          ..moveTo(-40, 0)
          ..lineTo(40, 0)
          ..lineTo(30, 60)
          ..lineTo(-30, 60)
          ..close();
    canvas.drawPath(bPath, Paint()..color = const Color(0xFFd97706));
    canvas.drawPath(
      bPath,
      Paint()
        ..color = const Color(0xFFb45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    _drawText(
      canvas,
      "Pieces: ${vars.basketCount}",
      const Offset(0, 80),
      Colors.white,
      16,
    );
    canvas.restore();
  }

  void _drawJar(Canvas canvas, double x, double y, int level) {
    canvas.save();
    canvas.translate(x, y);
    double w = 120, h = 200;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w / 2, -h, w, h),
        const Radius.circular(15),
      ),
      Paint()..color = Colors.white.withOpacity(0.1),
    );
    if (level > 0) {
      double lh = (level / 9) * (h - 20);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-w / 2 + 5, -lh - 5, w - 10, lh),
          const Radius.circular(5),
        ),
        Paint()..color = const Color(0xFFfef08a),
      );
    }
    Paint jP =
        Paint()
          ..color = const Color(0xFFcbd5e1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w / 2, -h, w, h),
        const Radius.circular(15),
      ),
      jP,
    );
    for (int i = 1; i <= 3; i++) {
      double ty = -(i / 3) * (h - 20) - 5;
      canvas.drawLine(Offset(-w / 2, ty), Offset(-w / 2 + 15, ty), jP);
      _drawText(
        canvas,
        "${i}c",
        Offset(-w / 2 - 15, ty),
        const Color(0xFFcbd5e1),
        16,
      );
    }
    canvas.restore();
  }

  void _drawBowl(Canvas canvas, double x, double y, int count) {
    canvas.save();
    canvas.translate(x, y);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 80),
      0,
      math.pi,
      true,
      Paint()..color = const Color(0xFFcbd5e1),
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 80),
      0,
      math.pi,
      true,
      Paint()
        ..color = const Color(0xFF94a3b8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    for (int i = 0; i < count; i++) {
      canvas.drawCircle(
        Offset(-40 + i * 40, -10),
        20,
        Paint()..color = const Color(0xFFd97706),
      );
      canvas.drawCircle(
        Offset(-45 + i * 40, -15),
        3,
        Paint()..color = const Color(0xFF451a03),
      );
      canvas.drawCircle(
        Offset(-35 + i * 40, -5),
        3,
        Paint()..color = const Color(0xFF451a03),
      );
      canvas.drawCircle(
        Offset(-40 + i * 40, 0),
        3,
        Paint()..color = const Color(0xFF451a03),
      );
    }
    _drawText(
      canvas,
      "Batches: $count",
      const Offset(0, 40),
      const Color(0xFF94a3b8),
      24,
    );
    if (vars.errorAlpha > 0) {
      _drawText(
        canvas,
        "Not enough sugar!",
        const Offset(-150, -40),
        Color.fromRGBO(239, 68, 68, math.max(0, vars.errorAlpha)),
        16,
      );
    }
    canvas.restore();
  }

  void _drawMeasureScoop(Canvas canvas, double x, double y, bool filled) {
    canvas.save();
    canvas.translate(x, y);
    Path p =
        Path()
          ..moveTo(25, 0)
          ..arcToPoint(const Offset(-25, 0), radius: const Radius.circular(25))
          ..lineTo(-10, -40)
          ..lineTo(10, -40)
          ..close();
    canvas.drawPath(p, Paint()..color = const Color(0xFFf8fafc));
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF94a3b8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    if (filled)
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 22),
        0,
        math.pi,
        false,
        Paint()..color = const Color(0xFFfef08a),
      );
    _drawText(
      canvas,
      "2/3 c",
      const Offset(0, -20),
      const Color(0xFF0f172a),
      12,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BakeOffPainter oldDelegate) => true;
}
