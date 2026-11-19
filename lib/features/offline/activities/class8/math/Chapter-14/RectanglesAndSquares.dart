// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

// --- 1. INTERNATIONALIZATION (i18n) DICTIONARY ---
const Map<String, Map<String, dynamic>> I18N = {
  'en': {
    'appTitle': "RECTANGLE & SQUARE LATTICE LAB",
    'initBtn': "START MISSION",
    'headerTitle': "The Rectangle & Square Lattice Forge",
    'headerSubtitle': "Class 8 . Area",
    'hudMission': "Current Objective",
    'boardTitle': "Teacher Board",
    'objLabel': "Mission Objective",
    'conceptLabel': "Core Concepts",
    'outcomesLabel': "Analysis & Outcomes",
    'stepInfoLabel': "Current Step",
    'objDesc':
        "Build rectangles and squares on the lattice to prove the area and perimeter formulas!",
    'conceptText':
        "Area is the number of unit squares inside a shape (length × width). Perimeter is the total distance around the boundary (2 × (length + width)).",
    'outcomesText':
        "A square is just a special rectangle where length equals width, making Area = s² and Perimeter = 4s. The rules never change!",
    'msgMissionComplete': "MISSION ACCOMPLISHED",
    'finalSubtitle':
        "You proved Area = length × width and Perimeter = 2(length+width) across rectangles and squares.",
    'msgStepComplete': "Step Complete!",
    'msgNeedManipulation':
        "Drag at least one corner handle to build your rectangle before verifying.",
    'msgNeedD1':
        "Not quite. Drag the corners until the rectangle is exactly 5 units wide and 2 units tall.",
    'msgNeedD3':
        "Not quite. Drag the corners until the rectangle is exactly 5 units wide and 1 unit tall.",
    'msgNeedD4Square':
        "This must be a SQUARE — make width and height equal (4 and 4).",
    'msgNeedD4Dim':
        "Close! Make sure both width and height are exactly 4 units.",
    'msgNeedValidShape':
        "Build a valid rectangle with whole-number width and height, both at least 1 unit.",
    'msgNeedDistinctOpen':
        "Choose a NEW size, different from the 5×2, 5×1, and 4×4 rectangles you already built.",
    'msgNeedReasoning':
        "Add one sentence explaining why Area = width × height for your rectangle before verifying.",
    'msgStepOkD1':
        "Correct! 5 × 2 = 10 sq units, Perimeter = 2×(5+2) = 14 units.",
    'msgStepOkD3':
        "Correct! 5 × 1 = 5 sq units, Perimeter = 2×(5+1) = 12 units.",
    'msgStepOkD4':
        "Correct! 4 × 4 = 16 sq units (a square!), Perimeter = 4×4 = 16 units.",
    'msgStepOkOpen': "Correct! The formulas hold for your own rectangle too.",
    'widthLabel': "Width (w)",
    'heightLabel': "Height (h)",
    'areaLabel': "Area",
    'perimeterLabel': "Perimeter",
    'squareYes': "THIS IS A SQUARE!",
    'squareNo': "NOT A SQUARE (YET)",
    'targetHintD1': "Target: width = 5, height = 2",
    'targetHintD3': "Target: width = 5, height = 1",
    'targetHintD4': "Target: width = 4, height = 4 (a square)",
    'openHint': "Pick ANY new whole-number size, not 5×2, 5×1, or 4×4.",
    'reasoningPrompt':
        "In your own words: how does counting unit squares prove Area = width × height?",
    'proveItBtn': "COUNT UNIT SQUARES",
    'proofModalTitleTxt': "Why Area = length × width?",
    'proceedBtn': "PROCEED",
    'closeBtn': "CLOSE",
    'toastProofDone': "Proof complete — every unit square counted!",
    'diagonalToggleOn': "Show Diagonals",
    'diagonalToggleOff': "Hide Diagonals",
    'btnRestart': "RESTART MISSION",
    'steps': [
      {
        'title': "Step 1 of 4: Build the 5×2 Rectangle",
        'instruction':
            "Drag the two corner handles (cyan = top-left, amber = bottom-right) until the rectangle is 5 units wide and 2 units tall. Watch the live Area and Perimeter meters, then press VERIFY.",
        'validateLabel': "VERIFY AREA = 10",
      },
      {
        'title': "Step 2 of 4: Build the 5×1 Rectangle",
        'instruction':
            "Drag the corners until the rectangle is 5 units wide and 1 unit tall. Then press VERIFY.",
        'validateLabel': "VERIFY AREA = 5",
      },
      {
        'title': "Step 3 of 4: Build the 4×4 Square",
        'instruction':
            "Drag the corners until width AND height are both exactly 4 units — a special rectangle called a square. Then press VERIFY.",
        'validateLabel': "VERIFY SQUARE, AREA = 16",
      },
      {
        'title': "Step 4 of 4: Freely Build Your Own",
        'instruction':
            "Drag the corners to ANY new whole-number size (not 5×2, 5×1, or 4×4). Write one sentence explaining why Area = width×height for your rectangle, then press VERIFY.",
        'validateLabel': "VERIFY GENERAL CASE",
      },
    ],
    'guide': [
      "A rectangle is a quadrilateral whose four angles are all equal to 90°, and whose opposite sides are equal in length.",
      "A carpenter checks that a frame is a true rectangle by measuring both diagonals — in Ganita Manjari's 'Carpenter's Problem', a rectangle's diagonals are always equal in length and bisect each other.",
      "On a lattice (a grid of unit squares), a rectangle's area is simply the count of unit squares it covers — this count always equals length × width.",
      "The perimeter is the total distance around the rectangle's boundary — walk along all four sides and add them: l + w + l + w = 2×(l+w).",
      "A square is the special rectangle where length and width are equal (l = w = s). Then Area = s × s = s², and Perimeter = 4s.",
      "These two formulas hold for EVERY rectangle you can build — drag to new dimensions and re-run COUNT UNIT SQUARES to confirm the rule never breaks.",
    ],
  },
  'hi': {
    'appTitle': "आयत और वर्ग जालक प्रयोगशाला",
    'initBtn': "मिशन शुरू करें",
    'headerTitle': "आयत और वर्ग जालक प्रयोगशाला",
    'headerSubtitle': "Class 8 . Area",
    'hudMission': "वर्तमान लक्ष्य",
    'boardTitle': "शिक्षक बोर्ड",
    'objLabel': "मिशन का उद्देश्य",
    'conceptLabel': "मुख्य अवधारणाएँ",
    'outcomesLabel': "विश्लेषण और परिणाम",
    'stepInfoLabel': "वर्तमान चरण",
    'objDesc':
        "क्षेत्रफल और परिमाप के सूत्रों को सिद्ध करने के लिए जालक पर आयत और वर्ग बनाएं!",
    'conceptText':
        "क्षेत्रफल एक आकार के अंदर इकाई वर्गों की संख्या है (लंबाई × चौड़ाई)। परिमाप सीमा के चारों ओर की कुल दूरी है (2 × (लंबाई + चौड़ाई))।",
    'outcomesText':
        "एक वर्ग केवल एक विशेष आयत है जहाँ लंबाई चौड़ाई के बराबर होती है, जिससे क्षेत्रफल = s² और परिमाप = 4s हो जाता है। नियम कभी नहीं बदलते!",
    'msgMissionComplete': "मिशन पूरा हुआ",
    'finalSubtitle':
        "आपने सिद्ध किया कि क्षेत्रफल = लंबाई × चौड़ाई और परिमाप = 2×(लंबाई+चौड़ाई) हर आयत और वर्ग के लिए सत्य है।",
    'msgStepComplete': "चरण पूर्ण!",
    'msgNeedManipulation':
        "सत्यापित करने से पहले अपना आयत बनाने के लिए कम से कम एक कोने के हैंडल को खींचें।",
    'msgNeedD1':
        "अभी सही नहीं है। कोनों को तब तक खींचें जब तक आयत ठीक 5 इकाई चौड़ा और 2 इकाई ऊँचा न हो जाए।",
    'msgNeedD3':
        "अभी सही नहीं है। कोनों को तब तक खींचें जब तक आयत ठीक 5 इकाई चौड़ा और 1 इकाई ऊँचा न हो जाए।",
    'msgNeedD4Square':
        "यह एक वर्ग होना चाहिए — चौड़ाई और ऊँचाई बराबर करें (4 और 4)।",
    'msgNeedD4Dim':
        "लगभग सही! सुनिश्चित करें कि चौड़ाई और ऊँचाई दोनों ठीक 4 इकाई हों।",
    'msgNeedValidShape':
        "पूर्ण संख्या वाली चौड़ाई और ऊँचाई के साथ एक वैध आयत बनाएं, दोनों कम से कम 1 इकाई की हों।",
    'msgNeedDistinctOpen':
        "एक नया आकार चुनें, जो आपके द्वारा पहले से बनाए गए 5×2, 5×1 और 4×4 आयतों से भिन्न हो।",
    'msgNeedReasoning':
        "सत्यापित करने से पहले यह बताते हुए एक वाक्य जोड़ें कि आपके आयत के लिए क्षेत्रफल = चौड़ाई × ऊँचाई क्यों है।",
    'msgStepOkD1': "सही! 5 × 2 = 10 वर्ग इकाई, परिमाप = 2×(5+2) = 14 इकाई।",
    'msgStepOkD3': "सही! 5 × 1 = 5 वर्ग इकाई, परिमाप = 2×(5+1) = 12 इकाई।",
    'msgStepOkD4':
        "सही! 4 × 4 = 16 वर्ग इकाई (एक वर्ग!), परिमाप = 4×4 = 16 इकाई।",
    'msgStepOkOpen': "सही! सूत्र आपके अपने आयत के लिए भी सत्य है।",
    'widthLabel': "चौड़ाई (w)",
    'heightLabel': "ऊँचाई (h)",
    'areaLabel': "क्षेत्रफल",
    'perimeterLabel': "परिमाप",
    'squareYes': "यह एक वर्ग है!",
    'squareNo': "अभी वर्ग नहीं है",
    'targetHintD1': "लक्ष्य: चौड़ाई = 5, ऊँचाई = 2",
    'targetHintD3': "लक्ष्य: चौड़ाई = 5, ऊँचाई = 1",
    'targetHintD4': "लक्ष्य: चौड़ाई = 4, ऊँचाई = 4 (वर्ग)",
    'openHint': "कोई भी नया पूर्ण-संख्या आकार चुनें, 5×2, 5×1 या 4×4 नहीं।",
    'reasoningPrompt':
        "अपने शब्दों में: अपने आयत के अंदर इकाई वर्गों को गिनना यह कैसे सिद्ध करता है कि क्षेत्रफल = चौड़ाई × ऊँचाई?",
    'proveItBtn': "इकाई वर्ग गिनें",
    'proofModalTitleTxt': "क्षेत्रफल = लंबाई × चौड़ाई क्यों?",
    'proceedBtn': "आगे बढ़ें",
    'closeBtn': "बंद करें",
    'toastProofDone': "प्रमाण पूर्ण — हर इकाई वर्ग गिना गया!",
    'diagonalToggleOn': "विकर्ण दिखाएं",
    'diagonalToggleOff': "विकर्ण छुपाएं",
    'btnRestart': "मिशन पुनः आरंभ करें",
    'steps': [
      {
        'title': "चरण 1/4: 5×2 आयत बनाएं",
        'instruction':
            "दोनों कोने के हैंडल (सियान = ऊपर-बाएं, अंबर = नीचे-दाएं) तब तक खींचें जब तक आयत 5 इकाई चौड़ा और 2 इकाई ऊँचा न हो जाए। लाइव क्षेत्रफल और परिमाप मीटर देखें, फिर VERIFY दबाएं।",
        'validateLabel': "क्षेत्रफल = 10 सत्यापित करें",
      },
      {
        'title': "चरण 2/4: 5×1 आयत बनाएं",
        'instruction':
            "कोनों को तब तक खींचें जब तक आयत 5 इकाई चौड़ा और 1 इकाई ऊँचा न हो जाए। फिर VERIFY दबाएं।",
        'validateLabel': "क्षेत्रफल = 5 सत्यापित करें",
      },
      {
        'title': "चरण 3/4: 4×4 वर्ग बनाएं",
        'instruction':
            "कोनों को तब तक खींचें जब तक चौड़ाई और ऊँचाई दोनों ठीक 4 इकाई न हो जाएं — एक विशेष आयत जिसे वर्ग कहते हैं। फिर VERIFY दबाएं।",
        'validateLabel': "वर्ग सत्यापित करें, क्षेत्रफल = 16",
      },
      {
        'title': "चरण 4/4: अपना खुद का आयत बनाएं",
        'instruction':
            "कोनों को किसी भी नए पूर्ण-संख्या आकार पर खींचें (5×2, 5×1 या 4×4 नहीं)। एक वाक्य में बताएं कि आपके आयत के लिए क्षेत्रफल = चौड़ाई×ऊँचाई क्यों सत्य है, फिर VERIFY दबाएं।",
        'validateLabel': "सामान्य स्थिति सत्यापित करें",
      },
    ],
    'guide': [
      "एक आयत एक चतुर्भुज है जिसके सभी चार कोण 90° के बराबर होते हैं, और सम्मुख भुजाएँ बराबर लंबाई की होती हैं।",
      "एक बढ़ई एक फ्रेम की जांच करता है कि वह सच्चा आयत है या नहीं, दोनों विकर्णों को मापकर — गणित मंजरी की 'बढ़ई की समस्या' में, एक आयत के विकर्ण हमेशा बराबर लंबाई के होते हैं और एक दूसरे को समद्विभाजित करते हैं।",
      "एक जालक (इकाई वर्गों की ग्रिड) पर, आयत का क्षेत्रफल बस उन इकाई वर्गों की गिनती है जिन्हें वह ढकता है — यह गिनती हमेशा लंबाई × चौड़ाई के बराबर होती है।",
      "परिमाप आयत की सीमा के चारों ओर की कुल दूरी है — सभी चार भुजाओं के साथ चलें और जोड़ें: l + w + l + w = 2×(l+w)।",
      "एक वर्ग वह विशेष आयत है जहाँ लंबाई और चौड़ाई बराबर होती हैं (l = w = s)। तब क्षेत्रफल = s × s = s², और परिमाप = 4s।",
      "ये दोनों सूत्र हर आयत के लिए सत्य हैं — नए आयामों पर खींचें और यह पुष्टि करने के लिए 'इकाई वर्ग गिनें' फिर से चलाएं कि नियम कभी नहीं टूटता।",
    ],
  },
};

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RectanglesAndSquaresApp());
}

class RectanglesAndSquaresApp extends StatelessWidget {
  const RectanglesAndSquaresApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rectangles & Squares',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF06B6D4),
          secondary: Color(0xFF8B5CF6),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Outfit', color: Color(0xFFF8FAFC)),
        ),
      ),
      home: const RectanglesAndSquaresActivity(),
    );
  }
}

class RectanglesAndSquaresActivity extends StatefulWidget {
  const RectanglesAndSquaresActivity({super.key});
  @override
  State<RectanglesAndSquaresActivity> createState() =>
      _RectanglesAndSquaresActivityState();
}

class _RectanglesAndSquaresActivityState
    extends State<RectanglesAndSquaresActivity>
    with TickerProviderStateMixin {
  String _currentLang = 'en';
  bool _isSidebarOpen = true;
  bool _isShutterOpen = true;
  bool _isCompleted = false;

  int _currentStep = 0;
  bool _diagonalsVisible = false;

  Offset _tl = const Offset(-2, 2);
  Offset _br = const Offset(1, -1);
  int _manipulatedCornerCount = 0;
  bool _modelBuilt = false;
  String _reasoningText = "";

  late TransformationController _transformationController;
  late AnimationController _proofAnimationController;

  static const double gridSize = 2000.0;
  static const double unitSize = 100.0;
  static const double origin = 1000.0;
  static const int latticeMin = -6;
  static const int latticeMax = 6;
  static const double sidebarWidth = 350.0;

  Offset _modalPosition = const Offset(150, 100);
  String? _toastMessage;
  bool _isToastError = false;
  bool _isProofModalVisible = false;
  bool _isSuccessOverlayVisible = false;
  bool _proofGuidedAdvance = false;

  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _introPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class8/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class8/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class8/mixkit_955.mp3';
  static const String _introUrl = 'audio/class8/mixkit_2574.mp3';

  final List<Map<String, Offset>> _initialDims = [
    {'tl': const Offset(-2, 2), 'br': const Offset(1, -1)},
    {'tl': const Offset(-1, 2), 'br': const Offset(1, -1)},
    {'tl': const Offset(-2, 1), 'br': const Offset(2, -2)},
    {'tl': const Offset(-1, 1), 'br': const Offset(1, -1)},
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _transformationController = TransformationController();
    _resetZoom();
    _proofAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _loadStep(0);
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity()
      ..translate(-gridSize / 2 + 500, -gridSize / 2 + 300)
      ..scale(0.85);
  }

  void _resetApp() {
    _playSound('click');
    setState(() {
      _isShutterOpen = true;
      _currentLang = 'en';
      _currentStep = 0;
      _isCompleted = false;
      _isSidebarOpen = true;
      _toastMessage = null;
      _isProofModalVisible = false;
      _isSuccessOverlayVisible = false;
      _modalPosition = const Offset(150, 100);
      _resetZoom();
      _loadStep(0);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _transformationController.dispose();
    _proofAnimationController.dispose();
    super.dispose();
  }

  void _playSound(String type) {
    try {
      if (type == 'click') _clickPlayer.play(AssetSource(_clickUrl));
      else if (type == 'success') _successPlayer.play(AssetSource(_successUrl));
      else if (type == 'error') _errorPlayer.play(AssetSource(_errorUrl));
      else if (type == 'intro') _introPlayer.play(AssetSource(_introUrl));
    } catch (e) {
      debugPrint("Audio error: $e");
    }
  }

  void _loadStep(int stepIndex) {
    setState(() {
      _currentStep = stepIndex;
      _manipulatedCornerCount = 0;
      _modelBuilt = false;
      _diagonalsVisible = false;
      _reasoningText = "";
      _tl = _initialDims[stepIndex]['tl']!;
      _br = _initialDims[stepIndex]['br']!;
      _proofAnimationController.reset();
    });
  }

  Map<String, dynamic> _computeDims() {
    int w = (_br.dx - _tl.dx).abs().round();
    int h = (_br.dy - _tl.dy).abs().round();
    return {
      'width': w,
      'height': h,
      'area': w * h,
      'perimeter': 2 * (w + h),
      'isSquare': (w == h) && (w > 0),
    };
  }

  void _showToast(String message, bool isError) {
    setState(() {
      _toastMessage = message;
      _isToastError = isError;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _toastMessage == message)
        setState(() => _toastMessage = null);
    });
  }

  void _validateStep() {
    final t = I18N[_currentLang]!;
    final dims = _computeDims();
    int w = dims['width'];
    int h = dims['height'];
    bool isCorrect = false;
    String failMsg = t['msgNeedManipulation'];

    if (_manipulatedCornerCount == 0 || !_modelBuilt)
      failMsg = t['msgNeedManipulation'];
    else if (_currentStep == 0) {
      isCorrect = w == 5 && h == 2;
      failMsg = t['msgNeedD1'];
    } else if (_currentStep == 1) {
      isCorrect = w == 5 && h == 1;
      failMsg = t['msgNeedD3'];
    } else if (_currentStep == 2) {
      isCorrect = w == 4 && h == 4;
      failMsg = w == h ? t['msgNeedD4Dim'] : t['msgNeedD4Square'];
    } else if (_currentStep == 3) {
      if (w < 1 || h < 1)
        failMsg = t['msgNeedValidShape'];
      else if ((w == 5 && h == 2) || (w == 5 && h == 1) || (w == 4 && h == 4))
        failMsg = t['msgNeedDistinctOpen'];
      else if (_reasoningText.trim().length < 8)
        failMsg = t['msgNeedReasoning'];
      else
        isCorrect = true;
    }

    if (isCorrect) {
      _playSound('success');
      _showToast(t['msgStepOkOpen'], false);
      setState(() => _isSuccessOverlayVisible = true);
      Future.delayed(
        const Duration(milliseconds: 1300),
        () => setState(() => _isSuccessOverlayVisible = false),
      );
      if (_currentStep < 3)
        Future.delayed(const Duration(milliseconds: 1600), () {
          _proofAnimationController.reset();
          _runProof(true);
        });
      else
        Future.delayed(const Duration(milliseconds: 1600), () {
          _showToast(t['msgMissionComplete'], false);
          setState(() => _isCompleted = true);
        });
    } else {
      _playSound('error');
      _showToast(failMsg, true);
    }
  }

  void _runProof(bool guidedAdvance) {
    if (_proofAnimationController.isAnimating ||
        _proofAnimationController.isCompleted)
      return;
    _playSound('click');
    _proofAnimationController.duration = Duration(
      milliseconds: (_computeDims()['area'] * 45) + 450,
    );
    _proofAnimationController.forward();
    _proofAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _showToast(I18N[_currentLang]!['toastProofDone'], false);
        Future.delayed(
          const Duration(milliseconds: 500),
          () => setState(() {
            _isProofModalVisible = true;
            _proofGuidedAdvance = guidedAdvance;
          }),
        );
      }
    });
  }

  void _handleCornerDragUpdate(String handle, DragUpdateDetails details) {
    if (_proofAnimationController.isAnimating) return;
    setState(() {
      if (handle == 'tl') {
        _tl = Offset(
          (_tl.dx + details.delta.dx / unitSize).clamp(
            latticeMin.toDouble(),
            latticeMax.toDouble(),
          ),
          (_tl.dy - details.delta.dy / unitSize).clamp(
            latticeMin.toDouble(),
            latticeMax.toDouble(),
          ),
        );
      } else {
        _br = Offset(
          (_br.dx + details.delta.dx / unitSize).clamp(
            latticeMin.toDouble(),
            latticeMax.toDouble(),
          ),
          (_br.dy - details.delta.dy / unitSize).clamp(
            latticeMin.toDouble(),
            latticeMax.toDouble(),
          ),
        );
      }
    });
  }

  void _handleCornerDragEnd(String handle) {
    if (_proofAnimationController.isAnimating) return;
    setState(() {
      _tl = Offset(_tl.dx.roundToDouble(), _tl.dy.roundToDouble());
      _br = Offset(_br.dx.roundToDouble(), _br.dy.roundToDouble());
      _manipulatedCornerCount++;
      _modelBuilt = true;
    });
  }

  Widget _buildInteractiveHandle(String type, Offset gridPos, Color color) {
    return Positioned(
      left: origin + gridPos.dx * unitSize - 30,
      top: origin - gridPos.dy * unitSize - 30,
      child: GestureDetector(
        onPanUpdate: (d) => _handleCornerDragUpdate(type, d),
        onPanEnd: (d) => _handleCornerDragEnd(type),
        child: Container(
          width: 60,
          height: 60,
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(Map<String, dynamic> t) {
    return Container(
      width: sidebarWidth, // Enforce fixed inner width
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.98),
        border: const Border(right: BorderSide(color: Color(0xFF334155))),
      ),
      child: SingleChildScrollView(
        // Entire sidebar scrolls vertically
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1E293B).withOpacity(0.7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.school,
                        color: Color(0xFF06B6D4),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t['headerTitle'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t['headerSubtitle'],
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Language Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Row(
                          children: ['en', 'hi'].map((lang) {
                            bool isActive = _currentLang == lang;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentLang = lang;
                                });
                                _playSound('click');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF06B6D4)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  lang.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.white
                                        : Colors.white54,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const Spacer(),
                      // Reset Button
                      ElevatedButton.icon(
                        onPressed: _resetApp,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text(
                          'RESET',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Sections
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSidebarSection(
                    t['objLabel'],
                    t['objDesc'],
                    const Color(0xFF06B6D4),
                    Icons.rocket,
                  ),
                  const SizedBox(height: 16),
                  _buildSidebarSection(
                    t['conceptLabel'],
                    t['conceptText'],
                    const Color(0xFF8B5CF6),
                    Icons.lightbulb,
                  ),
                  const SizedBox(height: 16),
                  _buildSidebarSection(
                    t['outcomesLabel'],
                    t['outcomesText'],
                    const Color(0xFF10B981),
                    Icons.analytics,
                  ),
                  const SizedBox(height: 24),

                  // Current Step Card
                  Text(
                    t['stepInfoLabel'].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFA78BFA),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020617), // Very dark contrast box
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                t['steps'][_currentStep]['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              'STEP ${_currentStep + 1}/4',
                              style: const TextStyle(
                                color: Color(0xFF06B6D4),
                                fontSize: 11,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Progress Bar
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: (_currentStep + 1) / 4,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF06B6D4),
                                    Color(0xFF60A5FA),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Instruction Box (High Contrast)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E293B),
                            border: Border(
                              left: BorderSide(
                                color: Color(0xFF06B6D4),
                                width: 4,
                              ),
                            ),
                          ),
                          child: Text(
                            t['steps'][_currentStep]['instruction'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        _buildControlPanel(t),

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _validateStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0891B2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              t['steps'][_currentStep]['validateLabel'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer Info
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 16),
              color: const Color(0xFF020617),
              child: const Text(
                "© ZeroScienceLab\nFall in love with math and Science",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarSection(
    String title,
    String desc,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Text(
            desc,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFCBD5E1),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel(Map<String, dynamic> t) {
    final dims = _computeDims();

    String hint = "";
    Color hintColor = Colors.amber;
    if (_currentStep == 0)
      hint = t['targetHintD1'];
    else if (_currentStep == 1)
      hint = t['targetHintD3'];
    else if (_currentStep == 2)
      hint = t['targetHintD4'];
    else {
      hint = t['openHint'];
      hintColor = Colors.cyanAccent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.track_changes, color: hintColor, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                hint,
                style: TextStyle(
                  color: hintColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildReadoutRow(
          t['widthLabel'],
          "${dims['width']} units",
          Colors.cyanAccent,
        ),
        _buildReadoutRow(
          t['heightLabel'],
          "${dims['height']} units",
          Colors.amberAccent,
        ),
        _buildReadoutRow(
          t['areaLabel'],
          "${dims['area']} sq units",
          Colors.purpleAccent,
          bgColor: Colors.deepPurple.withOpacity(0.2),
        ),
        _buildReadoutRow(
          t['perimeterLabel'],
          "${dims['perimeter']} units",
          Colors.greenAccent,
        ),

        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(8),
            color: dims['isSquare']
                ? Colors.green.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Text(
            dims['isSquare'] ? t['squareYes'] : t['squareNo'],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dims['isSquare'] ? Colors.greenAccent : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),

        // Math Equation Text
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "Area = w × h = ${dims['width']} × ${dims['height']} = ${dims['area']}\nPerimeter = 2(w+h) = 2(${dims['width']}+${dims['height']}) = ${dims['perimeter']}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _diagonalsVisible = !_diagonalsVisible;
            });
            _playSound('click');
          },
          icon: Icon(
            _diagonalsVisible ? Icons.close : Icons.visibility,
            size: 16,
          ),
          label: Text(
            _diagonalsVisible ? t['diagonalToggleOff'] : t['diagonalToggleOn'],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white24),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),

        if (_currentStep == 3) ...[
          const SizedBox(height: 16),
          Text(
            t['reasoningPrompt'],
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            style: const TextStyle(fontSize: 14, color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF020617),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _reasoningText = val;
              });
            },
          ),
        ],

        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _validateStep(),
          icon: const Icon(Icons.grid_on, size: 16),
          label: Text(t['proveItBtn']),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white24),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildReadoutRow(
    String label,
    String value,
    Color valueColor, {
    Color? bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor ?? const Color(0xFF0F172A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = I18N[_currentLang]!;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: _isShutterOpen
            ? _buildShutter(t)
            : Stack(
                children: [
                  Row(
                    children: [
                  // 1. Animated Sidebar (Side-by-side layout instead of Overlay)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: _isSidebarOpen ? sidebarWidth : 0,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics:
                          const NeverScrollableScrollPhysics(), // Blocks horizontal scrolling
                      child: _buildSidebar(t),
                    ),
                  ),

                  // 2. Interactive Canvas Area
                  Expanded(
                    child: Stack(
                      children: [
                        // Zoomable / Pannable Background
                        Positioned.fill(
                          child: InteractiveViewer(
                            transformationController: _transformationController,
                            constrained:
                                false, // REQUIRED for the huge canvas to not shrink to screen
                            boundaryMargin: const EdgeInsets.all(gridSize / 2),
                            minScale: 0.1,
                            maxScale: 3.0,
                            panEnabled: !_proofAnimationController.isAnimating,
                            scaleEnabled:
                                !_proofAnimationController.isAnimating,
                            child: Stack(
                              children: [
                                // Grid and Shapes Painter
                                Container(
                                  width: gridSize,
                                  height: gridSize,
                                  color: const Color(0xFF020617),
                                  child: CustomPaint(
                                    painter: LatticePainter(
                                      tl: _tl,
                                      br: _br,
                                      diagonalsVisible: _diagonalsVisible,
                                      proofProgress:
                                          _proofAnimationController.value,
                                      dims: _computeDims(),
                                    ),
                                  ),
                                ),
                                // Interactive Overlay Handles (These catch local drags)
                                _buildInteractiveHandle(
                                  'tl',
                                  _tl,
                                  const Color(0xFF06B6D4),
                                ),
                                _buildInteractiveHandle(
                                  'br',
                                  _br,
                                  const Color(0xFFFBBF24),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 3. Floating Menu Toggle
                        Positioned(
                          top: 16,
                          left: 16,
                          child: IconButton(
                            icon: Icon(
                              _isSidebarOpen ? Icons.menu_open : Icons.menu,
                            ),
                            color: Colors.orangeAccent,
                            iconSize: 28,
                            onPressed: () {
                              _playSound('click');
                              setState(() {
                                _isSidebarOpen = !_isSidebarOpen;
                              });
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.orange.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 4. Floating Toast
                        if (_toastMessage != null)
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 24),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1E293B,
                                ).withOpacity(0.95),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: _isToastError
                                      ? Colors.red
                                      : Colors.green,
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isToastError
                                        ? Icons.error
                                        : Icons.check_circle,
                                    color: _isToastError
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _toastMessage!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // 5. Success Celebration Overlay
                        if (_isSuccessOverlayVisible)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black87,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "SUCCESS!",
                                      style: TextStyle(
                                        fontSize: 72,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.cyanAccent,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(color: Colors.cyan),
                                      ),
                                      child: Text(
                                        t['msgStepComplete'],
                                        style: const TextStyle(
                                          fontSize: 28,
                                          color: Colors.cyan,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // 6. Draggable Proof Modal
                        if (_isProofModalVisible)
                          Positioned(
                            left: _modalPosition.dx,
                            top: _modalPosition.dy,
                            child: Material(
                              color: Colors.transparent,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    _modalPosition += details.delta;
                                  });
                                },
                                child: Container(
                                  width: 320,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.cyan.withOpacity(0.5),
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 16,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Draggable Header Bar
                                      Container(
                                        padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 8,
                                          top: 12,
                                          bottom: 12,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF0F172A),
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(14),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                t['proofModalTitleTxt'],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.white70,
                                              ),
                                              onPressed: () {
                                                _playSound('click');
                                                setState(() {
                                                  _isProofModalVisible = false;
                                                  _proofAnimationController
                                                      .reset();
                                                });
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    // Modal Body
                                    Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t['guide'][2],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            t['guide'][3],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.black38,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Area = ${_computeDims()['width']} × ${_computeDims()['height']} = ${_computeDims()['area']}\nPerimeter = 2(${_computeDims()['width']}+${_computeDims()['height']}) = ${_computeDims()['perimeter']}",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 16,
                                                  color: Colors.cyanAccent,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            t['guide'][4],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                _playSound('click');
                                                setState(() {
                                                  _isProofModalVisible = false;
                                                  _proofAnimationController
                                                      .reset();
                                                  if (_proofGuidedAdvance &&
                                                      _currentStep < 3) {
                                                    _loadStep(_currentStep + 1);
                                                  }
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF06B6D4,
                                                ),
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12,
                                                    ),
                                              ),
                                              child: Text(
                                                _proofGuidedAdvance
                                                    ? t['proceedBtn']
                                                    : t['closeBtn'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                          ),
                        ),

                        // 7. Final Completion Screen
                        if (_isCompleted)
                          Positioned.fill(
                            child: Container(
                              color: const Color(0xFF020617).withOpacity(0.95),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.emoji_events,
                                      size: 100,
                                      color: Colors.greenAccent,
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      t['msgMissionComplete'],
                                      style: const TextStyle(
                                        fontSize: 56,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      t['finalSubtitle'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    ElevatedButton.icon(
                                      onPressed: _resetApp,
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      label: Text(t['btnRestart']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                          vertical: 20,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ], // inner Stack children
                    ), // inner Stack
                  ), // Expanded
                ], // Row children
              ), // Row
            ], // Stack children
          ), // Stack
        ), // Scaffold
    ); // GestureDetector
  }

  Widget _buildShutter(Map<String, dynamic> t) {
    return Container(
      color: const Color(0xFF020617),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.crop_square,
                  size: 100,
                  color: Color(0xFF06B6D4),
                ),
                const SizedBox(height: 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    t['appTitle'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                  ),
                  child: const Text(
                    "CLASS 8 • AREA",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    _playSound('intro');
                    setState(() {
                      _isShutterOpen = false;
                    });
                  },
                  icon: const Icon(
                    Icons.play_arrow,
                    size: 32,
                    color: Colors.white,
                  ),
                  label: Text(t['initBtn']),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    backgroundColor: const Color(0xFF0891B2),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LatticePainter extends CustomPainter {
  final Offset tl;
  final Offset br;
  final bool diagonalsVisible;
  final double proofProgress; // 0.0 to 1.0
  final Map<String, dynamic> dims;

  LatticePainter({
    required this.tl,
    required this.br,
    required this.diagonalsVisible,
    required this.proofProgress,
    required this.dims,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double origin = size.width / 2; // Center of the CustomPaint
    final double unit = 100.0;

    Offset gridToScreen(double gx, double gy) {
      return Offset(origin + gx * unit, origin - gy * unit);
    }

    // Draw grid lines
    final Paint gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.6)
      ..strokeWidth = 1.0;

    for (int i = -6; i <= 6; i++) {
      canvas.drawLine(
        gridToScreen(i.toDouble(), -6),
        gridToScreen(i.toDouble(), 6),
        gridPaint,
      );
      canvas.drawLine(
        gridToScreen(-6, i.toDouble()),
        gridToScreen(6, i.toDouble()),
        gridPaint,
      );
    }

    // Draw dots at integer intersections
    final Paint dotPaint = Paint()..color = const Color(0xFF64748B);
    for (int x = -6; x <= 6; x++) {
      for (int y = -6; y <= 6; y++) {
        canvas.drawCircle(
          gridToScreen(x.toDouble(), y.toDouble()),
          3,
          dotPaint,
        );
      }
    }

    // Calculate actual bounds of rectangle
    double minX = min(tl.dx, br.dx);
    double maxX = max(tl.dx, br.dx);
    double minY = min(tl.dy, br.dy);
    double maxY = max(tl.dy, br.dy);

    Offset sTL = gridToScreen(minX, maxY);
    Offset sTR = gridToScreen(maxX, maxY);
    Offset sBR = gridToScreen(maxX, minY);
    Offset sBL = gridToScreen(minX, minY);

    // Draw Fill
    final Paint fillPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withOpacity(0.14)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromPoints(sTL, sBR), fillPaint);

    // Draw Edges
    final Paint edgePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromPoints(sTL, sBR), edgePaint);

    // Draw Diagonals
    if (diagonalsVisible) {
      final Paint diagPaint = Paint()
        ..color = Colors.white54
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(sTL, sBR, diagPaint);
      canvas.drawLine(sTR, sBL, diagPaint);
    }

    // Draw Proof Squares (Animation)
    if (proofProgress > 0) {
      int totalCells = dims['area'];
      double cellDuration = 1.0 / totalCells;

      final Paint proofPaint = Paint()
        ..color = const Color(0xFF06B6D4).withOpacity(0.7)
        ..style = PaintingStyle.fill;

      int cellIndex = 0;
      for (int iy = 0; iy < dims['height']; iy++) {
        for (int ix = 0; ix < dims['width']; ix++) {
          double startProgress = cellIndex * cellDuration * 0.8;
          double endProgress = startProgress + 0.2;

          double cellScale = 0.0;
          if (proofProgress > startProgress) {
            if (proofProgress > endProgress) {
              cellScale = 1.0;
            } else {
              cellScale = (proofProgress - startProgress) / 0.2;
              cellScale = sin(cellScale * pi / 2);
            }
          }

          if (cellScale > 0) {
            Offset cellCenter = gridToScreen(minX + ix + 0.5, minY + iy + 0.5);
            double paddedUnit = unit * 0.82;
            Rect cellRect = Rect.fromCenter(
              center: cellCenter,
              width: paddedUnit * cellScale,
              height: paddedUnit * cellScale,
            );
            canvas.drawRect(cellRect, proofPaint);
          }
          cellIndex++;
        }
      }
    }

    _drawText(
      canvas,
      "w = ${dims['width']}",
      gridToScreen((minX + maxX) / 2, minY - 0.5),
    );
    _drawText(
      canvas,
      "h = ${dims['height']}",
      gridToScreen(maxX + 0.5, (minY + maxY) / 2),
    );
    _drawText(
      canvas,
      "A = ${dims['area']}",
      gridToScreen((minX + maxX) / 2, (minY + maxY) / 2),
      isVertex: true,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    bool isVertex = false,
  }) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
      backgroundColor: isVertex
          ? const Color(0xFF8B5CF6).withOpacity(0.9)
          : const Color(0xFF0F172A).withOpacity(0.9),
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final Paint bgBorderPaint = Paint()
      ..color = isVertex ? Colors.transparent : Colors.amber.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    Rect bgRect = Rect.fromLTWH(
      position.dx - textPainter.width / 2 - 6,
      position.dy - textPainter.height / 2 - 4,
      textPainter.width + 12,
      textPainter.height + 8,
    );
    canvas.drawRect(bgRect, Paint()..color = textStyle.backgroundColor!);
    if (!isVertex) canvas.drawRect(bgRect, bgBorderPaint);

    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(LatticePainter oldDelegate) {
    return tl != oldDelegate.tl ||
        br != oldDelegate.br ||
        diagonalsVisible != oldDelegate.diagonalsVisible ||
        proofProgress != oldDelegate.proofProgress;
  }
}
