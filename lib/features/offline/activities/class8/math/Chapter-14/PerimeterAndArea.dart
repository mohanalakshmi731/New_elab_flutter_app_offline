// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

const Map<String, Map<String, dynamic>> I18N = {
  'en': {
    'appTitle': 'PERIMETER & AREA LATTICE LAB',
    'tagline': 'Class 8 • Area',
    'initBtn': 'START MISSION',
    'headerTitle': 'The Perimeter & Area Lattice Lab',
    'headerSubtitle': 'Class 8 • Area',
    'boardTitle': 'Teacher Board',
    'objLabel': 'Mission Objective',
    'conceptLabel': 'Core Concepts',
    'objDesc':
        'Explore perimeter and area using rectangles and L-shapes on the lattice to prove they are independent measures.',
    'conceptText':
        'Perimeter is the boundary length (2(w+h)). Area is the surface enclosed (wh). Fixing one does not fix the other.',
    'outcomesText':
        'You will prove that shapes with the same area can have different perimeters, and decompose L-shapes into simple rectangles.',
    'postTitle': 'Analysis & Outcomes',
    'navTitle': 'Lab Progress',
    'btnRestart': 'RESTART MISSION',
    'msgMissionComplete': 'MISSION ACCOMPLISHED',
    'finalSubtitle':
        'You proved that perimeter and area are independent measures of a figure, and decomposed an L-shape into rectangles.',
    'msgStepComplete': 'Step Complete!',
    'msgNeedRect':
        'Not quite. Drag the two lattice corners until the rectangle\'s width and height exactly match the target above.',
    'msgNeedArea12':
        'Build a rectangle with area exactly 12 sq units before committing or verifying.',
    'msgNeedDistinctPerimeter':
        'Commit your first area-12 rectangle, then build a second, different-shaped area-12 rectangle with a different perimeter.',
    'msgNeedPerimeter18':
        'Build a rectangle with perimeter exactly 18 units before committing or verifying.',
    'msgNeedDistinctArea':
        'Commit your first perimeter-18 rectangle, then build a second, different-shaped perimeter-18 rectangle with a different area.',
    'msgNeedReasoningPA':
        'Add one sentence explaining why area and perimeter can differ, before verifying.',
    'msgNeedSplit':
        'Choose Split Horizontally or Split Vertically before verifying.',
    'msgNeedLShapeValues':
        'Check your two rectangle areas and the total perimeter — something doesn\'t match this figure yet.',
    'msgStep1Ok':
        'Correct! Area = 5 x 2 = 10 sq units, Perimeter = 2x(5+2) = 14 units.',
    'msgStep2Ok':
        'Correct! Area = 5 x 1 = 5 sq units, Perimeter = 2x(5+1) = 12 units.',
    'msgStep3Ok':
        'Correct! Area = 4 x 4 = 16 sq units, Perimeter = 2x(4+4) = 16 units — a square where the two numbers coincide.',
    'msgStep4Ok':
        'Correct! Same area (12), two different perimeters — area does not fix the perimeter.',
    'msgStep5Ok':
        'Correct! Same perimeter (18), two different areas — perimeter does not fix the area.',
    'msgStep6Ok':
        'Correct! Both decompositions give total area 18 sq units, and the boundary trace gives perimeter 22 units.',
    'commitBtn': 'COMMIT THIS RECTANGLE',
    'splitHBtn': 'SPLIT HORIZONTALLY',
    'splitVBtn': 'SPLIT VERTICALLY',
    'proceedBtn': 'PROCEED',
    'closeBtn': 'CLOSE',
    'reasoningPrompt':
        'In your own words: why can two rectangles share the same area but have different perimeters?',
    'reasoningPlaceholder': 'Type your reasoning here...',
    'steps': [
      {
        'title': 'Step 1 of 6: Build the 5 x 2 Rectangle',
        'instruction':
            'Drag the two lattice corner handles until you form a rectangle of width 5 units and height 2 units. Watch the live area and perimeter meters, then press VERIFY.',
        'hint': 'Target: width = 5 units, height = 2 units',
        'validateLabel': 'VERIFY 5x2',
      },
      {
        'title': 'Step 2 of 6: Build the 5 x 1 Rectangle',
        'instruction':
            'Reshape the rectangle to width 5 units and height 1 unit, then press VERIFY.',
        'hint': 'Target: width = 5 units, height = 1 unit',
        'validateLabel': 'VERIFY 5x1',
      },
      {
        'title': 'Step 3 of 6: Build the 4 x 4 Square',
        'instruction':
            'Reshape the rectangle into a square: width 4 units and height 4 units, then press VERIFY.',
        'hint': 'Target: width = 4 units, height = 4 units',
        'validateLabel': 'VERIFY 4x4',
      },
      {
        'title': 'Step 4 of 6: Same Area, Different Perimeter',
        'instruction':
            'Build a rectangle with area exactly 12 sq units and COMMIT it. Then reshape into a second, different rectangle — also area 12 — with a different perimeter. Explain why in one sentence, then press VERIFY.',
        'hint':
            'Target: Area = 12 sq units, twice, with two different perimeters',
        'validateLabel': 'VERIFY DIVERGENCE',
      },
      {
        'title': 'Step 5 of 6: Same Perimeter, Different Area',
        'instruction':
            'Build a rectangle with perimeter exactly 18 units and COMMIT it. Then reshape into a second, different rectangle — also perimeter 18 — with a different area, then press VERIFY.',
        'hint': 'Target: Perimeter = 18 units, twice, with two different areas',
        'validateLabel': 'VERIFY DIVERGENCE',
      },
      {
        'title': 'Step 6 of 6: Decompose the L-Shape',
        'instruction':
            'Read the boundary side lengths of the L-shaped figure. Choose a split, compute each rectangle\'s area and the figure\'s total perimeter, then press VERIFY.',
        'hint':
            'Target: Total area = sum of two rectangles; Perimeter = the outer boundary trace only',
        'validateLabel': 'VERIFY L-SHAPE',
      },
    ],
  },
  'hi': {
    'appTitle': 'परिमाप और क्षेत्रफल जालक प्रयोगशाला',
    'tagline': 'कक्षा 8 • क्षेत्रफल',
    'initBtn': 'मिशन शुरू करें',
    'headerTitle': 'परिमाप और क्षेत्रफल जालक प्रयोगशाला',
    'headerSubtitle': 'कक्षा 8 • क्षेत्रफल',
    'boardTitle': 'शिक्षक बोर्ड',
    'objLabel': 'मिशन का उद्देश्य',
    'conceptLabel': 'मूल अवधारणाएं',
    'objDesc':
        'यह साबित करने के लिए कि वे स्वतंत्र उपाय हैं, जाली पर आयत और एल-आकार का उपयोग करके परिधि और क्षेत्र का अन्वेषण करें।',
    'conceptText':
        'परिधि सीमा की लंबाई (2(w+h)) है। क्षेत्रफल संलग्न सतह (wh) है। एक को ठीक करने से दूसरा ठीक नहीं होता है।',
    'outcomesText':
        'आप साबित करेंगे कि समान क्षेत्र वाले आकृतियों में अलग-अलग परिधि हो सकती है, और एल-आकृतियों को सरल आयतों में विघटित कर सकते हैं।',
    'postTitle': 'विश्लेषण और परिणाम',
    'navTitle': 'प्रयोगशाला प्रगति',
    'btnRestart': 'मिशन पुनः आरंभ करें',
    'msgMissionComplete': 'मिशन पूरा हुआ',
    'finalSubtitle':
        'आपने सिद्ध किया कि परिमाप और क्षेत्रफल एक आकृति के दो स्वतंत्र माप हैं, और L-आकार को आयतों में विभाजित किया।',
    'msgStepComplete': 'चरण पूर्ण!',
    'msgNeedRect':
        'अभी सही नहीं है। दोनों जालक कोनों को तब तक खींचें जब तक आयत की चौड़ाई और ऊँचाई ऊपर दिए गए लक्ष्य से बिल्कुल मेल न खाए।',
    'msgNeedArea12':
        'सत्यापित करने या कमिट करने से पहले ठीक 12 वर्ग इकाई क्षेत्रफल वाला एक आयत बनाएं।',
    'msgNeedDistinctPerimeter':
        'पहले 12-क्षेत्रफल वाले आयत को कमिट करें, फिर एक भिन्न आकार का दूसरा 12-क्षेत्रफल वाला आयत बनाएं जिसका परिमाप अलग हो।',
    'msgNeedPerimeter18':
        'सत्यापित करने या कमिट करने से पहले ठीक 18 इकाई परिमाप वाला एक आयत बनाएं।',
    'msgNeedDistinctArea':
        'पहले 18-परिमाप वाले आयत को कमिट करें, फिर एक भिन्न आकार का दूसरा 18-परिमाप वाला आयत बनाएं जिसका क्षेत्रफल अलग हो।',
    'msgNeedReasoningPA':
        'सत्यापित करने से पहले यह बताते हुए एक वाक्य जोड़ें कि क्षेत्रफल और परिमाप अलग-अलग क्यों हो सकते हैं।',
    'msgNeedSplit':
        'सत्यापित करने से पहले क्षैतिज विभाजन या ऊर्ध्वाधर विभाजन चुनें।',
    'msgNeedLShapeValues':
        'अपने दोनों आयतों के क्षेत्रफल और कुल परिमाप जांचें — कुछ इस आकृति से मेल नहीं खाता।',
    'msgStep1Ok':
        'सही! क्षेत्रफल = 5 x 2 = 10 वर्ग इकाई, परिमाप = 2x(5+2) = 14 इकाई।',
    'msgStep2Ok':
        'सही! क्षेत्रफल = 5 x 1 = 5 वर्ग इकाई, परिमाप = 2x(5+1) = 12 इकाई।',
    'msgStep3Ok':
        'सही! क्षेत्रफल = 4 x 4 = 16 वर्ग इकाई, परिमाप = 2x(4+4) = 16 इकाई — एक वर्ग जहाँ दोनों संख्याएँ संयोग से बराबर हैं।',
    'msgStep4Ok':
        'सही! समान क्षेत्रफल (12), दो अलग परिमाप — क्षेत्रफल परिमाप तय नहीं करता।',
    'msgStep5Ok':
        'सही! समान परिमाप (18), दो अलग क्षेत्रफल — परिमाप क्षेत्रफल तय नहीं करता।',
    'msgStep6Ok':
        'सही! दोनों विभाजन कुल क्षेत्रफल 18 वर्ग इकाई देते हैं, और सीमा-अनुरेखण से परिमाप 22 इकाई मिलता है।',
    'commitBtn': 'यह आयत कमिट करें',
    'splitHBtn': 'क्षैतिज विभाजन',
    'splitVBtn': 'ऊर्ध्वाधर विभाजन',
    'proceedBtn': 'आगे बढ़ें',
    'closeBtn': 'बंद करें',
    'reasoningPrompt':
        'अपने शब्दों में: दो आयतों का क्षेत्रफल समान हो सकता है पर परिमाप अलग क्यों हो सकता है?',
    'reasoningPlaceholder': 'अपना तर्क यहाँ लिखें...',
    'steps': [
      {
        'title': 'चरण 1/6: 5 x 2 आयत बनाएं',
        'instruction':
            'दोनों जालक कोने हैंडल तब तक खींचें जब तक चौड़ाई 5 इकाई और ऊँचाई 2 इकाई का आयत न बन जाए। लाइव क्षेत्रफल और परिमाप मीटर देखें, फिर VERIFY दबाएं।',
        'hint': 'लक्ष्य: चौड़ाई = 5 इकाई, ऊँचाई = 2 इकाई',
        'validateLabel': '5x2 सत्यापित करें',
      },
      {
        'title': 'चरण 2/6: 5 x 1 आयत बनाएं',
        'instruction':
            'आयत को चौड़ाई 5 इकाई और ऊँचाई 1 इकाई में बदलें, फिर VERIFY दबाएं।',
        'hint': 'लक्ष्य: चौड़ाई = 5 इकाई, ऊँचाई = 1 इकाई',
        'validateLabel': '5x1 सत्यापित करें',
      },
      {
        'title': 'चरण 3/6: 4 x 4 वर्ग बनाएं',
        'instruction':
            'आयत को वर्ग में बदलें: चौड़ाई 4 इकाई और ऊँचाई 4 इकाई, फिर VERIFY दबाएं।',
        'hint': 'लक्ष्य: चौड़ाई = 4 इकाई, ऊँचाई = 4 इकाई',
        'validateLabel': '4x4 सत्यापित करें',
      },
      {
        'title': 'चरण 4/6: समान क्षेत्रफल, भिन्न परिमाप',
        'instruction':
            'ठीक 12 वर्ग इकाई क्षेत्रफल वाला आयत बनाएं और उसे COMMIT करें। फिर एक भिन्न आकार का दूसरा आयत बनाएं — क्षेत्रफल भी 12 — पर परिमाप अलग। एक वाक्य में कारण बताएं, फिर VERIFY दबाएं।',
        'hint':
            'लक्ष्य: क्षेत्रफल = 12 वर्ग इकाई, दो बार, दो अलग परिमापों के साथ',
        'validateLabel': 'भिन्नता सत्यापित करें',
      },
      {
        'title': 'चरण 5/6: समान परिमाप, भिन्न क्षेत्रफल',
        'instruction':
            'ठीक 18 इकाई परिमाप वाला आयत बनाएं और उसे COMMIT करें। फिर एक भिन्न आकार का दूसरा आयत बनाएं — परिमाप भी 18 — पर क्षेत्रफल अलग, फिर VERIFY दबाएं।',
        'hint': 'लक्ष्य: परिमाप = 18 इकाई, दो बार, दो अलग क्षेत्रफलों के साथ',
        'validateLabel': 'भिन्नता सत्यापित करें',
      },
      {
        'title': 'चरण 6/6: L-आकार को विभाजित करें',
        'instruction':
            'L-आकार की आकृति की सीमा-भुजाओं की लंबाई पढ़ें। एक विभाजन चुनें, प्रत्येक आयत का क्षेत्रफल और आकृति का कुल परिमाप निकालें, फिर VERIFY दबाएं।',
        'hint':
            'लक्ष्य: कुल क्षेत्रफल = दो आयतों का योग; परिमाप = केवल बाहरी सीमा',
        'validateLabel': 'L-आकार सत्यापित करें',
      },
    ],
  },
};

class PerimeterAndAreaApp extends StatefulWidget {
  const PerimeterAndAreaApp({Key? key}) : super(key: key);
  @override
  State<PerimeterAndAreaApp> createState() => _PerimeterAndAreaAppState();
}

class _PerimeterAndAreaAppState extends State<PerimeterAndAreaApp>
    with TickerProviderStateMixin {
  String _currentLang = "en";
  int _currentStep = 0;
  bool _isSidebarOpen = true;
  bool _isShutterOpen = true;
  bool _isCompleted = false;

  math.Point<int> cornerTL = const math.Point(2, 4);
  math.Point<int> cornerBR = const math.Point(5, 2);
  final int GRID_MAX = 12;

  List<Map<String, dynamic>> _committedRects = [];
  String _reasoningText = "";
  String? _splitMode;
  String _userAreaA = "";
  String _userAreaB = "";
  String _userPerimeter = "";
  bool _isPanMode = false;

  final List<math.Point<int>> LSHAPE_VERTS = const [
    math.Point(0, 0),
    math.Point(6, 0),
    math.Point(6, 2),
    math.Point(2, 2),
    math.Point(2, 5),
    math.Point(0, 5),
  ];

  String? _draggingHandle; // "tl" or "br"
  String _toastMessage = "";
  String _toastIcon = "";
  bool _showToast = false;

  final AudioPlayer _audioClick = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _audioSuccess = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _audioError = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _audioFanfare = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  late AnimationController _celebrationController;
  late Animation<double> _celebrationScale;

  bool _showReasoningModal = false;
  Offset _reasoningModalOffset = const Offset(100, 100);
  final TextEditingController _reasoningController = TextEditingController();

  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _celebrationScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );

    _resetStepState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _celebrationController.dispose();
    _reasoningController.dispose();
    _audioClick.dispose();
    _audioSuccess.dispose();
    _audioError.dispose();
    _audioFanfare.dispose();
    super.dispose();
  }

  void playSound(String type) {
    try {
      if (type == 'click')
        _audioClick.play(
          AssetSource(
            "audio/class8/mixkit_2568.mp3",
          ),
        );
      else if (type == 'success')
        _audioSuccess.play(
          AssetSource(
            "audio/class8/mixkit_2018.mp3",
          ),
        );
      else if (type == 'error')
        _audioError.play(
          AssetSource(
            "audio/class8/beep_short.ogg",
          ),
        );
      else if (type == 'fanfare')
        _audioFanfare.play(
          AssetSource(
            "audio/class8/mixkit_1436.mp3",
          ),
        );
    } catch (e) {
      debugPrint("Audio error: $e");
    }
  }

  void _showToastMsg(String msg, String iconHtml) {
    setState(() {
      _toastMessage = msg;
      _toastIcon = iconHtml;
      _showToast = true;
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showToast = false;
        });
      }
    });
  }

  void _resetStepState() {
    _committedRects.clear();
    _reasoningText = "";
    _reasoningController.clear();
    _splitMode = null;
    _userAreaA = "";
    _userAreaB = "";
    _userPerimeter = "";
    if (_currentStep == 0) {
      cornerTL = const math.Point(2, 4);
      cornerBR = const math.Point(5, 2);
    } else if (_currentStep == 1) {
      cornerTL = const math.Point(2, 4);
      cornerBR = const math.Point(5, 2);
    } else if (_currentStep == 2) {
      cornerTL = const math.Point(3, 4);
      cornerBR = const math.Point(5, 2);
    } else if (_currentStep == 3) {
      cornerTL = const math.Point(2, 4);
      cornerBR = const math.Point(4, 2);
    } else if (_currentStep == 4) {
      cornerTL = const math.Point(2, 4);
      cornerBR = const math.Point(4, 2);
    }
  }

  void _fullReset() {
    setState(() {
      _currentLang = "en";
      _currentStep = 0;
      _isCompleted = false;
      _isShutterOpen = true;
      _resetStepState();
    });
  }

  Map<String, dynamic> _currentRect() {
    int minX = math.min(cornerTL.x, cornerBR.x);
    int maxX = math.max(cornerTL.x, cornerBR.x);
    int minY = math.min(cornerTL.y, cornerBR.y);
    int maxY = math.max(cornerTL.y, cornerBR.y);
    int width = maxX - minX;
    int height = maxY - minY;
    return {
      "minX": minX,
      "maxX": maxX,
      "minY": minY,
      "maxY": maxY,
      "width": width,
      "height": height,
      "area": width * height,
      "perimeter": 2 * (width + height),
    };
  }

  void _commitRectangle() {
    final rect = _currentRect();
    setState(() {
      _committedRects.add(rect);
    });
    playSound('click');
  }

  void _validateStep() {
    playSound('click');
    final t = I18N[_currentLang]!;
    final rect = _currentRect();

    if (_currentStep == 0) {
      if (rect["width"] == 5 && rect["height"] == 2) {
        _advanceStep(t["msgStep1Ok"]);
      } else {
        _showToastMsg(t["msgNeedRect"], "❌");
        playSound('error');
      }
    } else if (_currentStep == 1) {
      if (rect["width"] == 5 && rect["height"] == 1) {
        _advanceStep(t["msgStep2Ok"]);
      } else {
        _showToastMsg(t["msgNeedRect"], "❌");
        playSound('error');
      }
    } else if (_currentStep == 2) {
      if (rect["width"] == 4 && rect["height"] == 4) {
        _advanceStep(t["msgStep3Ok"]);
      } else {
        _showToastMsg(t["msgNeedRect"], "❌");
        playSound('error');
      }
    } else if (_currentStep == 3) {
      if (_committedRects.isEmpty) {
        if (rect["area"] != 12) {
          _showToastMsg(t["msgNeedArea12"], "❌");
          playSound('error');
        } else {
          _showToastMsg(t["msgNeedDistinctPerimeter"], "❌");
          playSound('error');
        }
      } else {
        final r1 = _committedRects[0];
        if (rect["area"] != 12) {
          _showToastMsg(t["msgNeedArea12"], "❌");
          playSound('error');
        } else if (r1["perimeter"] == rect["perimeter"]) {
          _showToastMsg(t["msgNeedDistinctPerimeter"], "❌");
          playSound('error');
        } else {
          setState(() {
            _showReasoningModal = true;
          });
        }
      }
    } else if (_currentStep == 4) {
      if (_committedRects.isEmpty) {
        if (rect["perimeter"] != 18) {
          _showToastMsg(t["msgNeedPerimeter18"], "❌");
          playSound('error');
        } else {
          _showToastMsg(t["msgNeedDistinctArea"], "❌");
          playSound('error');
        }
      } else {
        final r1 = _committedRects[0];
        if (rect["perimeter"] != 18) {
          _showToastMsg(t["msgNeedPerimeter18"], "❌");
          playSound('error');
        } else if (r1["area"] == rect["area"]) {
          _showToastMsg(t["msgNeedDistinctArea"], "❌");
          playSound('error');
        } else {
          _advanceStep(t["msgStep5Ok"]);
        }
      }
    } else if (_currentStep == 5) {
      if (_splitMode == null) {
        _showToastMsg(t["msgNeedSplit"], "❌");
        playSound('error');
      } else {
        double uaA = double.tryParse(_userAreaA) ?? 0.0;
        double uaB = double.tryParse(_userAreaB) ?? 0.0;
        double up = double.tryParse(_userPerimeter) ?? 0.0;

        double expA = _splitMode == 'h' ? 12.0 : 10.0;
        double expB = _splitMode == 'h' ? 6.0 : 8.0;

        bool okA = (uaA - expA).abs() < 0.01;
        bool okB = (uaB - expB).abs() < 0.01;
        bool okTotal = (uaA + uaB - 18.0).abs() < 0.01;
        bool okPeri = (up - 22.0).abs() < 0.01;

        if (okA && okB && okTotal && okPeri) {
          _advanceStep(t["msgStep6Ok"]);
        } else {
          _showToastMsg(t["msgNeedLShapeValues"] ?? "Check your values.", "❌");
          playSound('error');
        }
      }
    }
  }

  void _submitReasoning() {
    if (_reasoningController.text.trim().isEmpty) {
      playSound('error');
      return;
    }
    setState(() {
      _showReasoningModal = false;
      _reasoningText = _reasoningController.text;
    });
    final t = I18N[_currentLang]!;
    _advanceStep(t["msgStep4Ok"]);
  }

  void _advanceStep(String msg) {
    _showToastMsg(msg, "✅");
    playSound('success');

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          if (_currentStep < 5) {
            _currentStep++;
            _resetStepState();
          } else {
            _isCompleted = true;
          }
        });
      }
    });
  }

  Offset? _activeDragPos;

  void _handlePanStart(
    DragStartDetails details,
    BoxConstraints constraints,
    String handle,
  ) {
    int currX = handle == "tl" ? cornerTL.x : cornerBR.x;
    int currY = handle == "tl" ? cornerTL.y : cornerBR.y;
    final tileSize = constraints.maxHeight / GRID_MAX;
    _activeDragPos = Offset(currX * tileSize, currY * tileSize);
  }

  void _handlePanUpdate(
    DragUpdateDetails details,
    BoxConstraints constraints,
    String handle,
  ) {
    if (_activeDragPos == null) return;

    double scale = _transformationController.value.entry(0, 0);
    Offset sceneDelta = details.delta / scale;

    _activeDragPos = Offset(
      _activeDragPos!.dx + sceneDelta.dx,
      _activeDragPos!.dy - sceneDelta.dy,
    );

    final tileSize = constraints.maxHeight / GRID_MAX;
    double rawX = _activeDragPos!.dx / tileSize;
    double rawY = _activeDragPos!.dy / tileSize;

    int snappedX = rawX.round().clamp(0, GRID_MAX);
    int snappedY = rawY.round().clamp(0, GRID_MAX);

    setState(() {
      if (handle == "tl") {
        if (snappedX != cornerBR.x && snappedY != cornerBR.y) {
          cornerTL = math.Point(snappedX, snappedY);
        }
      } else {
        if (snappedX != cornerTL.x && snappedY != cornerTL.y) {
          cornerBR = math.Point(snappedX, snappedY);
        }
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    _activeDragPos = null;
  }

  @override
  Widget build(BuildContext context) {
    final t = I18N[_currentLang]!;
    double screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = screenWidth > 800 ? 380 : screenWidth * 0.45;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: _isShutterOpen
            ? _buildShutter(t)
            : Stack(
                children: [
                  // Main Canvas Area (Beside Sidebar)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    top: 0,
                    bottom: 0,
                    right: 0,
                    left: _isSidebarOpen ? sidebarWidth : 0,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: 0.5,
                          maxScale: 4.0,
                          panEnabled: true,
                          scaleEnabled: true,
                          constrained: false,
                          boundaryMargin: EdgeInsets.all(
                            constraints.maxHeight * 0.5,
                          ),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: constraints.maxHeight,
                                height: constraints.maxHeight,
                                child: CustomPaint(
                                  painter: LatticePainter(
                                    gridMax: GRID_MAX,
                                    currentStep: _currentStep,
                                    cornerTL: cornerTL,
                                    cornerBR: cornerBR,
                                    lShapeVerts: LSHAPE_VERTS,
                                    splitMode: _splitMode,
                                  ),
                                ),
                              ),
                              if (_currentStep < 5) ...[
                                Positioned(
                                  left:
                                      (cornerTL.x *
                                          (constraints.maxHeight / GRID_MAX)) -
                                      40,
                                  top:
                                      constraints.maxHeight -
                                      (cornerTL.y *
                                          (constraints.maxHeight / GRID_MAX)) -
                                      40,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onPanStart: (d) =>
                                        _handlePanStart(d, constraints, "tl"),
                                    onPanUpdate: (d) =>
                                        _handlePanUpdate(d, constraints, "tl"),
                                    onPanEnd: _handlePanEnd,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left:
                                      (cornerBR.x *
                                          (constraints.maxHeight / GRID_MAX)) -
                                      40,
                                  top:
                                      constraints.maxHeight -
                                      (cornerBR.y *
                                          (constraints.maxHeight / GRID_MAX)) -
                                      40,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onPanStart: (d) =>
                                        _handlePanStart(d, constraints, "br"),
                                    onPanUpdate: (d) =>
                                        _handlePanUpdate(d, constraints, "br"),
                                    onPanEnd: _handlePanEnd,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Animated Sidebar
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: _isSidebarOpen ? 0 : -sidebarWidth,
                    top: 0,
                    bottom: 0,
                    width: sidebarWidth,
                    child: _buildSidebar(t),
                  ),

                  // Menu Toggle Button
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: 16,
                    top: 16,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: const Color(0xFF1E293B),
                      child: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _isSidebarOpen = !_isSidebarOpen;
                        });
                        playSound('click');
                      },
                    ),
                  ),
                  // Toast Message
                  if (_showToast)
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
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
                              color: Colors.cyan.withValues(alpha: 0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _toastIcon,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _toastMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Celebration Overlay
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _celebrationController,
                        builder: (context, child) {
                          if (_celebrationController.value == 0)
                            return const SizedBox.shrink();
                          return Container(
                            color: const Color(0xFF020617).withValues(
                              alpha: 0.7 * _celebrationController.value,
                            ),
                            child: Center(
                              child: Transform.scale(
                                scale: _celebrationScale.value,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "SUCCESS!",
                                      style: TextStyle(
                                        fontSize: 60,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.cyanAccent,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        t["msgStepComplete"],
                                        style: const TextStyle(
                                          color: Colors.cyan,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Final Screen Overlay
                  if (_isCompleted)
                    Positioned.fill(
                      child: Container(
                        color: const Color(0xFF020617).withValues(alpha: 0.95),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 80,
                                color: Colors.greenAccent,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                t["msgMissionComplete"],
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                t["finalSubtitle"],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  t["btnRestart"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: _fullReset,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Reasoning Modal
                  if (_showReasoningModal)
                    Positioned(
                      left: _reasoningModalOffset.dx,
                      top: _reasoningModalOffset.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _reasoningModalOffset += details.delta;
                          });
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: 400,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF1E293B,
                              ).withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.cyan.withValues(alpha: 0.3),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Explain",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white54,
                                      ),
                                      onPressed: () => setState(() {
                                        _showReasoningModal = false;
                                      }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  t["reasoningPrompt"],
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _reasoningController,
                                  style: const TextStyle(color: Colors.white),
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: t["reasoningPlaceholder"],
                                    hintStyle: const TextStyle(
                                      color: Colors.white30,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF0F172A),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyan,
                                    ),
                                    onPressed: _submitReasoning,
                                    child: Text(
                                      t["proceedBtn"],
                                      style: const TextStyle(
                                        color: Colors.white,
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
                ],
              ),
      ),
    );
  }

  Widget _buildShutter(Map<String, dynamic> t) {
    return Container(
      color: const Color(0xFF020617),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.straighten, size: 80, color: Colors.cyan),
            const SizedBox(height: 20),
            Text(
              t["appTitle"],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyan.shade900),
              ),
              child: Text(
                t["tagline"],
                style: const TextStyle(
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan.shade600,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                t["initBtn"],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                playSound('click');
                setState(() {
                  _isShutterOpen = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(Map<String, dynamic> t) {
    List<dynamic> stepsInfo = t["steps"];
    Map<String, dynamic> currentStepInfo = stepsInfo[_currentStep];
    final rect = _currentRect();

    return Container(
      width: 380,
      color: const Color(0xFF0F172A),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(
                top: 72,
                bottom: 16,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.blueGrey.shade800),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t["headerTitle"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          t["headerSubtitle"],
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(
                      Icons.language,
                      color: Colors.white70,
                      size: 20,
                    ),
                    label: Text(
                      _currentLang.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      playSound('click');
                      setState(() {
                        _currentLang = _currentLang == "en" ? "hi" : "en";
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.redAccent),
                    onPressed: _fullReset,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoSection(
                    "objLabel",
                    "objDesc",
                    Icons.adjust,
                    Colors.cyan,
                    t,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    "conceptLabel",
                    "conceptText",
                    Icons.lightbulb,
                    Colors.yellow,
                    t,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    "postTitle",
                    "outcomesText",
                    Icons.fact_check,
                    Colors.green,
                    t,
                  ),
                  const SizedBox(height: 16),

                  // Lab Progress Block
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Step ${_currentStep + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "STEP ${_currentStep + 1}/6",
                              style: const TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (_currentStep + 1) / 6,
                          backgroundColor: Colors.blueGrey.shade900,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.cyan,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withValues(alpha: 0.1),
                            border: const Border(
                              left: BorderSide(color: Colors.cyan, width: 4),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            currentStepInfo["instruction"],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.adjust,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                currentStepInfo["hint"],
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        if (_currentStep < 5)
                          _buildRectangleControls(rect, t)
                        else
                          _buildLShapeControls(t),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _validateStep,
                            child: Text(
                              currentStepInfo["validateLabel"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
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
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    String titleKey,
    String descKey,
    IconData icon,
    Color color,
    Map<String, dynamic> t,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 8),
            Text(
              t[titleKey].toUpperCase(),
              style: TextStyle(
                color: Colors.blueGrey.shade300,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            t[descKey],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRectangleControls(
    Map<String, dynamic> rect,
    Map<String, dynamic> t,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    "A = ${rect['area']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    t["areaLabel"] ?? "Area",
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "P = ${rect['perimeter']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    t["perimeterLabel"] ?? "Perimeter",
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_currentStep == 3 || _currentStep == 4)
          Column(
            children: [
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.cyan,
                    side: const BorderSide(color: Colors.cyan),
                  ),
                  onPressed: _commitRectangle,
                  child: Text(t["commitBtn"]),
                ),
              ),
              if (_currentStep == 3 && _committedRects.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t["reasoningPrompt"] ?? "Reasoning:",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          hintText: t["reasoningPlaceholder"],
                          hintStyle: const TextStyle(color: Colors.white30),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          _reasoningText = val;
                        },
                      ),
                    ],
                  ),
                ),
              if (_committedRects.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _committedRects
                        .map(
                          (r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              "Committed: ${r['width']}x${r['height']} (A=${r['area']}, P=${r['perimeter']})",
                              style: const TextStyle(
                                color: Colors.purpleAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildLShapeControls(Map<String, dynamic> t) {
    return Column(
      children: [
        Text(
          t["sideLengthsHint"] ?? "Hint",
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _splitMode == 'h'
                      ? Colors.cyan
                      : Colors.blueGrey.shade800,
                ),
                onPressed: () {
                  playSound('click');
                  setState(() {
                    _splitMode = 'h';
                  });
                },
                child: Text(
                  t["splitHBtn"] ?? "Horizontal",
                  style: TextStyle(
                    color: _splitMode == 'h' ? Colors.black : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _splitMode == 'v'
                      ? Colors.cyan
                      : Colors.blueGrey.shade800,
                ),
                onPressed: () {
                  playSound('click');
                  setState(() {
                    _splitMode = 'v';
                  });
                },
                child: Text(
                  t["splitVBtn"] ?? "Vertical",
                  style: TextStyle(
                    color: _splitMode == 'v' ? Colors.black : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                t["rectALabel"] ?? "Rect A Area:",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF0F172A),
                  isDense: true,
                ),
                onChanged: (v) {
                  _userAreaA = v;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                t["rectBLabel"] ?? "Rect B Area:",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF0F172A),
                  isDense: true,
                ),
                onChanged: (v) {
                  _userAreaB = v;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                t["perimeterInputLabel"] ?? "Total Perimeter:",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF0F172A),
                  isDense: true,
                ),
                onChanged: (v) {
                  _userPerimeter = v;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LatticePainter extends CustomPainter {
  final int gridMax;
  final int currentStep;
  final math.Point<int> cornerTL;
  final math.Point<int> cornerBR;
  final List<math.Point<int>> lShapeVerts;
  final String? splitMode;

  LatticePainter({
    required this.gridMax,
    required this.currentStep,
    required this.cornerTL,
    required this.cornerBR,
    required this.lShapeVerts,
    this.splitMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double tileSize = size.height / gridMax;
    final paintGrid = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1;

    // Draw Grid Lines
    for (int i = 0; i <= gridMax; i++) {
      double pos = i * tileSize;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), paintGrid);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), paintGrid);
    }

    // Convert logic coords to canvas coords (Y is inverted in typical graph vs canvas)
    Offset toCanvas(int x, int y) {
      return Offset(x * tileSize, size.height - (y * tileSize));
    }

    if (currentStep < 5) {
      // Draw Rectangle
      int minX = math.min(cornerTL.x, cornerBR.x);
      int maxX = math.max(cornerTL.x, cornerBR.x);
      int minY = math.min(cornerTL.y, cornerBR.y);
      int maxY = math.max(cornerTL.y, cornerBR.y);

      final tlCanvas = toCanvas(minX, maxY);
      final brCanvas = toCanvas(maxX, minY);
      final rect = Rect.fromPoints(tlCanvas, brCanvas);

      // Fill
      canvas.drawRect(rect, Paint()..color = const Color(0x4D8B5CF6));
      // Border
      canvas.drawRect(
        rect,
        Paint()
          ..color = const Color(0xFFFBBF24)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      // Handles
      final paintHandle = Paint()..color = Colors.cyan;
      canvas.drawCircle(toCanvas(cornerTL.x, cornerTL.y), 10, paintHandle);
      canvas.drawCircle(toCanvas(cornerBR.x, cornerBR.y), 10, paintHandle);

      // Labels for sides
      final textPainter = TextPainter(textDirection: TextDirection.ltr);

      void drawLabel(String text, Offset pos) {
        textPainter.text = TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            backgroundColor: Colors.black54,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          pos - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }

      drawLabel(
        "${maxX - minX}",
        Offset(tlCanvas.dx + (brCanvas.dx - tlCanvas.dx) / 2, tlCanvas.dy - 15),
      );
      drawLabel(
        "${maxY - minY}",
        Offset(brCanvas.dx + 15, tlCanvas.dy + (brCanvas.dy - tlCanvas.dy) / 2),
      );
    } else {
      // Draw L-Shape
      Path path = Path();
      path.moveTo(
        toCanvas(lShapeVerts[0].x, lShapeVerts[0].y).dx,
        toCanvas(lShapeVerts[0].x, lShapeVerts[0].y).dy,
      );
      for (int i = 1; i < lShapeVerts.length; i++) {
        path.lineTo(
          toCanvas(lShapeVerts[i].x, lShapeVerts[i].y).dx,
          toCanvas(lShapeVerts[i].x, lShapeVerts[i].y).dy,
        );
      }
      path.close();

      canvas.drawPath(path, Paint()..color = const Color(0x4D8B5CF6));
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFFBBF24)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      // Split mode logic
      if (splitMode == "h") {
        int xSplit = lShapeVerts[3].x;
        int ySplit = lShapeVerts[2].y;
        canvas.drawLine(
          toCanvas(0, ySplit),
          toCanvas(xSplit, ySplit),
          Paint()
            ..color = Colors.cyan
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
      } else if (splitMode == "v") {
        int xSplit = lShapeVerts[3].x;
        int ySplit = lShapeVerts[2].y;
        canvas.drawLine(
          toCanvas(xSplit, 0),
          toCanvas(xSplit, ySplit),
          Paint()
            ..color = Colors.cyan
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
      }

      // L-shape labels
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      void drawLabel(String text, Offset pos) {
        textPainter.text = TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            backgroundColor: Colors.black54,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          pos - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }

      for (int i = 0; i < lShapeVerts.length; i++) {
        var p1 = lShapeVerts[i];
        var p2 = lShapeVerts[(i + 1) % lShapeVerts.length];

        var cp1 = toCanvas(p1.x, p1.y);
        var cp2 = toCanvas(p2.x, p2.y);
        var mid = Offset((cp1.dx + cp2.dx) / 2, (cp1.dy + cp2.dy) / 2);

        int length = (p1.x == p2.x) ? (p1.y - p2.y).abs() : (p1.x - p2.x).abs();

        Offset offset = Offset.zero;
        if (p1.x == p2.x) {
          offset = p1.x < 3 ? const Offset(-15, 0) : const Offset(15, 0);
        } else {
          offset = p1.y < 3 ? const Offset(0, 15) : const Offset(0, -15);
        }
        drawLabel("$length", mid + offset);
      }

      // Draw dots
      final paintDot = Paint()..color = Colors.yellow;
      for (var p in lShapeVerts) {
        canvas.drawCircle(toCanvas(p.x, p.y), 6, paintDot);
      }
    }
  }

  @override
  bool shouldRepaint(LatticePainter oldDelegate) {
    return oldDelegate.currentStep != currentStep ||
        oldDelegate.cornerTL != cornerTL ||
        oldDelegate.cornerBR != cornerBR ||
        oldDelegate.splitMode != splitMode;
  }
}
