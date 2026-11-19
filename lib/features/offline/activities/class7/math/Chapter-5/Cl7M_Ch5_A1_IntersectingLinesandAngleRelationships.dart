// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: unused_field, deprecated_member_use

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Angle Detective',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.amber,
        fontFamily: 'Roboto',
      ),
      home: const IntersectingLinesandAngleRelationships(),
    ),
  );
}

class IntersectingLinesandAngleRelationships extends StatefulWidget {
  const IntersectingLinesandAngleRelationships({super.key});

  @override
  State<IntersectingLinesandAngleRelationships> createState() =>
      _IntersectingLinesandAngleRelationshipsState();
}

class PieceState {
  double x;
  double y;
  double rotation;
  bool placed;
  PieceState({this.x = 0, this.y = 0, this.rotation = 0, this.placed = false});
}

class _IntersectingLinesandAngleRelationshipsState
    extends State<IntersectingLinesandAngleRelationships>
    with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  String _currentLang = 'en';
  bool _isCurtainVisible = true;

  // Viewport/Canvas Control
  final TransformationController _transformationController =
      TransformationController();
  bool _isInitialScaleSet = false;
  bool _isDraggingPiece = false;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Geometry State
  double _intersectionAngle = 45.0; // degrees
  int _currentScenario = 1;
  int _currentStep = 0;
  bool _s1PiecesReset = false;

  // Scenario States
  Map<String, PieceState> _pieces = {
    'a': PieceState(),
    'b': PieceState(),
    'c': PieceState(),
    'd': PieceState(),
  };

  // Scenario 3 state
  String? _s3ActiveTool;
  bool _s3bSolved = false;
  bool _s3cSolved = false;
  bool _s3dSolved = false;
  double _s3SliderValue = 0;

  // Scenario 4 state
  Map<String, bool> _s4Slots = {'b': false, 'c': false, 'd': false};
  PieceState _s4Drag45 = PieceState();
  PieceState _s4Drag135 = PieceState();

  // Scenario 5 state
  String? _s5ActiveInput;
  bool _s5xSolved = false;
  bool _s5ySolved = false;
  String _keypadBuffer = "";

  // Progress
  final Set<int> _completedScenarios = {};
  bool _showGlobalSuccess = false;
  bool _actionValidated = false;
  int? _dismissedSuccessPopupFor;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _playSound('chime');
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioPlayer.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _playSound(String type) async {
    String url = '';
    switch (type) {
      case 'click':
        url =
            'audio/class7/mixkit_2568.mp3';
        break;
      case 'success':
        url =
            'audio/class7/mixkit_2018.mp3';
        break;
      case 'wrong':
        url =
            'audio/class7/mixkit_2954.mp3';
        break;
      case 'toggle':
        url =
            'audio/class7/mixkit_2568.mp3';
        break;
      case 'chime':
        url =
            'audio/class7/mixkit_2019.mp3';
        break;
    }
    if (url.isNotEmpty) {
      try {
        await _audioPlayer.play(AssetSource(url));
      } catch (e) {
        debugPrint("Audio play failed: $e");
      }
    }
  }

  void _loadScenario(int id) {
    _playSound('toggle');
    setState(() {
      _currentScenario = id;
      _currentStep = 0;
      _intersectionAngle = 45.0;
      _actionValidated = false;
      _s1PiecesReset = false;
      _pieces = {
        'a': PieceState(),
        'b': PieceState(),
        'c': PieceState(),
        'd': PieceState(),
      };
      _s3ActiveTool = null;
      _s3bSolved = false;
      _s3cSolved = false;
      _s3dSolved = false;
      _s3SliderValue = 0;
      _s4Slots = {'b': false, 'c': false, 'd': false};
      _s4Drag45 = PieceState();
      _s4Drag135 = PieceState();
      _s5ActiveInput = null;
      _s5xSolved = false;
      _s5ySolved = false;
      _keypadBuffer = "";

      // Request canvas recenter
      _isInitialScaleSet = false;
      _isDraggingPiece = false;
      _dismissedSuccessPopupFor = null;
    });
  }

  void _markStepComplete({int delayMs = 1500, bool silent = false}) {
    if (_actionValidated) return;
    setState(() {
      _actionValidated = true;
    });

    if (delayMs > 0 && !silent) _playSound('success');

    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      final scenario = _getScenarioConfig(_currentScenario);
      if (_currentStep < scenario['steps'].length - 1) {
        setState(() {
          _currentStep++;
          _actionValidated = false;
        });
      } else {
        setState(() {
          _completedScenarios.add(_currentScenario);
          _actionValidated = false;
        });
        if (_completedScenarios.length == 5) {
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _showGlobalSuccess = true;
            });
            _playSound('chime');
          });
        }
      }
    });
  }

  void _toggleLanguage() {
    _playSound('click');
    setState(() {
      _currentLang = _currentLang == 'en' ? 'hi' : 'en';
    });
  }

  void _handleMasterReset() {
    _playSound('toggle');
    setState(() {
      _isCurtainVisible = true;
      _completedScenarios.clear();
      _showGlobalSuccess = false;
      _isSidebarOpen = true;
      _isInitialScaleSet = false;
      _dismissedSuccessPopupFor = null;
    });
    _playSound('chime');
  }

  String t(String key) {
    const Map<String, Map<String, String>> dict = {
      'en': {
        'appTitle': 'The Angle Detective',
        'appSubtitle': 'Class 7 • PARALLEL AND INTERSECTING LINES',
        'missionObj': 'Mission Objective:',
        'procSteps': 'Procedural Steps',
        'step': 'STEP',
        'convertUnits': 'Convert Units',
        'validateModel': 'Validate Model',
        'footer': '© ZeroScienceLab - Fall in love with math and Science',
        'btnLinearPair': 'Linear Pair',
        'btnVertOpp': 'Vertically Opposite',
        'dragSlider': 'Drag slider to solve:',
        'restart': 'Restart Lab',
        'successTitle': 'Master Detective!',
        'successMsg': 'You have successfully completed all scenarios!',
        'enterLab': 'Enter Lab',
        'reset': 'Reset',
        'continue_btn': 'Continue',

        's1_title': '1. The Straight Line Puzzle',
        's1_obj':
            'Discover that adjacent angles on a straight line add up to 180°.',
        's1_step1':
            'OBSERVE the two intersecting lines on the screen. Notice the four colored angles: Blue (∠a), Green (∠b), Yellow (∠c), and Red (∠d).',
        's1_step2':
            'CLICK and DRAG the handle on line m to rotate it. OBSERVE how the values of all four angles change simultaneously.',
        's1_step3':
            'DRAG the Blue angle piece (∠a) and the Green angle piece (∠b) towards the semi-circle guide that appears at the top of the screen.',
        's1_step4':
            'DROP the two angle pieces into the semi-circle guide to form 180°.',
        's1_step5':
            'CLICK the \'Reset Pieces\' button on the right. Now, DRAG and DROP the Green (∠b) and Yellow (∠c) angles into the guide. OBSERVE the result.',

        's2_title': '2. The Opposite\'s Attract',
        's2_obj': 'Discover that vertically opposite angles are equal.',
        's2_step1':
            'OBSERVE the same intersecting lines. This time, focus on the Blue angle (∠a) and the Yellow angle (∠c), which are opposite each other.',
        's2_step2':
            'CLICK and DRAG the handle on line m to rotate it again. OBSERVE the relationship between the numerical values of ∠a and ∠c.',
        's2_step3': 'Tap or drag Blue (a) directly on top of Yellow (c).',
        's2_step4': 'Drop the Blue angle piece onto the Yellow angle.',

        's3_title': '3. The Angle Calculator',
        's3_obj':
            'Use rules to find all unknown angles from a single known angle (130°).',
        's3_step1': 'Click the Linear Pair Tool to find Green (b).',
        's3_step2': 'Solve 130° + ? = 180° using the slider.',
        's3_step3':
            'Click the Vertically Opposite Tool to automatically find Yellow (c).',
        's3_step4': 'Use Linear Pair again to solve Red (d).',

        's4_title': '4. The Scissor Challenge',
        's4_obj': 'Apply rules to find missing angles in scissors.',
        's4_step1':
            'Drag the correct 45° or 135° pieces from the toolbox into the empty slots.',
        's4_step2': 'Fill all 3 slots correctly to complete the scissors.',

        's5_title': '5. The Gatekeeper Challenge',
        's5_obj': 'Find the values of x and y on the gate to unlock it.',
        's5_step1':
            'Tap box x and enter the vertically opposite angle to 110°.',
        's5_step2': 'Tap box y and enter the linear pair angle to 110°.',
        'scenarioComplete': 'Scenario Complete!',
        'nextScenario': 'Next Scenario',
        'autoSnap': 'Auto-Snap Pieces',
        'autoSnapSingle': 'Auto-Snap Piece',
        'resetPieces': 'Reset Pieces',
      },
      'hi': {
        'appTitle': 'द एंगल डिटेक्टिव',
        'appSubtitle': 'कक्षा 7 • समांतर और प्रतिच्छेदी रेखाएँ',
        'missionObj': 'मिशन उद्देश्य:',
        'procSteps': 'प्रक्रियात्मक कदम',
        'step': 'चरण',
        'convertUnits': 'इकाइयों को बदलें',
        'validateModel': 'मॉडल को मान्य करें',
        'footer': '© ZeroScienceLab - गणित और विज्ञान से प्यार करें',
        'btnLinearPair': 'रैखिक युग्म',
        'btnVertOpp': 'शीर्षाभिमुख',
        'dragSlider': 'हल करने के लिए स्लाइडर खींचें:',
        'restart': 'लैब को पुनरारंभ करें',
        'successTitle': 'मास्टर डिटेक्टिव!',
        'successMsg': 'आपने सभी परिदृश्यों को सफलतापूर्वक पूरा कर लिया है!',
        'enterLab': 'जांच शुरू करें',
        'reset': 'रीसेट',
        'continue_btn': 'जारी रखें',

        's1_title': '1. सीधी रेखा पहेली',
        's1_obj': 'पता लगाएं कि सीधी रेखा पर आसन्न कोण 180° तक जुड़ते हैं।',
        's1_step1':
            'स्क्रीन पर दो प्रतिच्छेदी रेखाओं का अवलोकन करें। चार रंगीन कोणों पर ध्यान दें: नीला (∠a), हरा (∠b), पीला (∠c), और लाल (∠d)।',
        's1_step2':
            'लाइन m को घुमाने के लिए हैंडल को क्लिक करें और खींचें। देखें कि चारों कोणों के मान एक साथ कैसे बदलते हैं।',
        's1_step3':
            'नीले (∠a) और हरे (∠b) टुकड़ों को शीर्ष गाइड पर स्नैप करने के लिए टैप करें या खींचें।',
        's1_step4': '180° बनाने के लिए टुकड़ों को अर्ध-चक्र में छोड़ें।',
        's1_step5':
            'दायीं ओर \'टुकड़े रीसेट करें\' बटन पर क्लिक करें। अब, हरे (∠b) और पीले (∠c) कोणों को गाइड पर टैप करें या खींचें और परिणाम देखें।',

        's2_title': '2. विपरीत का आकर्षण',
        's2_obj': 'पता लगाएं कि शीर्षाभिमुख कोण बराबर होते हैं।',
        's2_step1':
            'उन्हीं प्रतिच्छेदी रेखाओं का अवलोकन करें। इस बार, नीले कोण (∠a) और पीले कोण (∠c) पर ध्यान दें, जो एक दूसरे के विपरीत हैं।',
        's2_step2':
            'लाइन m को फिर से घुमाने के लिए हैंडल को क्लिक करें और खींचें। ∠a और ∠c के संख्यात्मक मानों के बीच संबंध देखें।',
        's2_step3':
            'नीले कोण के टुकड़े (∠a) को खींचें और इसे सीधे पीले कोण (∠c) के ऊपर रखें।',
        's2_step4': 'नीले कोण के टुकड़े को पीले कोण पर छोड़ दें।',

        's3_title': '3. एंगल कैलकुलेटर',
        's3_obj':
            'एक ज्ञात कोण (130°) से सभी अज्ञात कोणों को खोजने के लिए नियमों का उपयोग करें।',
        's3_step1': 'हरा (b) खोजने के लिए रैखिक युग्म उपकरण पर क्लिक करें।',
        's3_step2': 'स्लाइडर का उपयोग करके 130° + ? = 180° हल करें।',
        's3_step3':
            'पीला (c) स्वचालित रूप से खोजने के लिए शीर्षाभिमुख उपकरण पर क्लिक करें।',
        's3_step4':
            'लाल (d) को हल करने के लिए फिर से रैखिक युग्म का उपयोग करें।',

        's4_title': '4. कैंची चुनौती',
        's4_obj':
            'कैंची में छूटे हुए कोणों को खोजने के लिए नियमों को लागू करें।',
        's4_step1':
            'टूलबॉक्स से सही 45° या 135° टुकड़ों को खाली स्लॉट में खींचें।',
        's4_step2': 'कैंची को पूरा करने के लिए सभी 3 स्लॉट सही ढंग से भरें।',

        's5_title': '5. द्वारपाल चुनौती',
        's5_obj': 'गेट खोलने के लिए x और y के मान ज्ञात करें।',
        's5_step1': 'बॉक्स x पर टैप करें और 110° के शीर्षाभिमुख कोण दर्ज करें।',
        's5_step2': 'बॉक्स y पर टैप करें और 110° के रैखिक युग्म कोण दर्ज करें।',
        'scenarioComplete': 'परिदृश्य पूरा हुआ!',
        'nextScenario': 'अगला परिदृश्य',
        'autoSnap': 'टुकड़ों को ऑटो-स्नैप करें',
        'autoSnapSingle': 'टुकड़े को ऑटो-स्नैप करें',
        'resetPieces': 'टुकड़े रीसेट करें',
      },
    };
    return dict[_currentLang]?[key] ?? key;
  }

  Map<String, dynamic> _getScenarioConfig(int id) {
    if (id == 1) {
      return {
        'title': t('s1_title'),
        'obj': t('s1_obj'),
        'steps': [
          t('s1_step1'),
          t('s1_step2'),
          t('s1_step3'),
          t('s1_step4'),
          t('s1_step5'),
        ],
      };
    } else if (id == 2) {
      return {
        'title': t('s2_title'),
        'obj': t('s2_obj'),
        'steps': [t('s2_step1'), t('s2_step2'), t('s2_step3'), t('s2_step4')],
      };
    } else if (id == 3) {
      return {
        'title': t('s3_title'),
        'obj': t('s3_obj'),
        'steps': [t('s3_step1'), t('s3_step2'), t('s3_step3'), t('s3_step4')],
      };
    } else if (id == 4) {
      return {
        'title': t('s4_title'),
        'obj': t('s4_obj'),
        'steps': [t('s4_step1'), t('s4_step2')],
      };
    } else {
      return {
        'title': t('s5_title'),
        'obj': t('s5_obj'),
        'steps': [t('s5_step1'), t('s5_step2')],
      };
    }
  }

  void _onRotateHandlePanStart(DragStartDetails details) {
    if (_actionValidated || _currentScenario > 2) return;
    setState(() => _isDraggingPiece = true);
  }

  void _onRotateHandlePanEnd(DragEndDetails details) {
    setState(() => _isDraggingPiece = false);
  }

  void _onRotateHandlePanCancel() {
    setState(() => _isDraggingPiece = false);
  }

  void _onRotateHandlePan(DragUpdateDetails details) {
    if (_actionValidated || _currentScenario > 2) return;

    double scale = _transformationController.value.getMaxScaleOnAxis();
    double dx = details.delta.dx / scale;
    double dy = details.delta.dy / scale;

    double rad = -_intersectionAngle * pi / 180;
    double hx = 280 * cos(rad);
    double hy = 280 * sin(rad);

    double cross = hx * dy - hy * dx;
    double dTheta = cross / (280 * 280);
    double dDeg = dTheta * 180 / pi;

    double newAngle = _intersectionAngle - dDeg;

    double norm = newAngle % 180;
    if (norm < 10) norm = 10;
    if (norm > 170) norm = 170;

    setState(() {
      _intersectionAngle = norm;
    });

    if (_currentScenario == 1 && _currentStep == 1 && (norm - 45).abs() > 10) {
      _markStepComplete();
    }
    if (_currentScenario == 2 && _currentStep == 1 && (norm - 45).abs() > 10) {
      _markStepComplete();
    }
  }

  // ---- Universal Tap-to-Snap Handler for Angle Pieces ----
  void _onPieceTap(String id) {
    if (_actionValidated || _currentScenario > 2) return;

    bool snapped = false;

    setState(() {
      if (_currentScenario == 1) {
        if ((id == 'a' || id == 'b') &&
            (_currentStep == 2 || _currentStep == 3)) {
          _pieces[id]!.x = 0;
          _pieces[id]!.y = -230;
          _pieces[id]!.rotation = 0;
          _pieces[id]!.placed = true;
          snapped = true;
        } else if ((id == 'b' || id == 'c') &&
            _currentStep == 4 &&
            _s1PiecesReset) {
          _pieces[id]!.x = 0;
          _pieces[id]!.y = -230;
          _pieces[id]!.rotation = -_intersectionAngle;
          _pieces[id]!.placed = true;
          snapped = true;
        }
      } else if (_currentScenario == 2) {
        if (id == 'a' && (_currentStep == 2 || _currentStep == 3)) {
          _pieces[id]!.x = 0;
          _pieces[id]!.y = 0;
          _pieces[id]!.rotation = 180;
          _pieces[id]!.placed = true;
          snapped = true;
        }
      }
    });

    _checkCompletion(snapped);
  }

  void _onPiecePanStart(String id, DragStartDetails details) {
    if (_actionValidated || _currentScenario > 2) return;
    setState(() => _isDraggingPiece = true);
  }

  void _onPiecePanUpdate(String id, DragUpdateDetails details) {
    if (_actionValidated || _currentScenario > 2) return;

    double scale = _transformationController.value.getMaxScaleOnAxis();

    setState(() {
      _pieces[id]!.x += details.delta.dx / scale;
      _pieces[id]!.y += details.delta.dy / scale;
    });
  }

  void _onPiecePanEnd(String id, DragEndDetails details) {
    if (_actionValidated || _currentScenario > 2) return;
    setState(() => _isDraggingPiece = false);

    final p = _pieces[id]!;
    bool snapped = false;

    // Generous snap tolerance
    double distToTop = sqrt(p.x * p.x + pow(p.y - (-230), 2));
    double distToOrigin = sqrt(p.x * p.x + p.y * p.y);

    setState(() {
      if (_currentScenario == 1) {
        bool canInteract = false;
        if ((_currentStep == 2 || _currentStep == 3) &&
            (id == 'a' || id == 'b')) {
          canInteract = true;
        } else if (_currentStep == 4 &&
            _s1PiecesReset &&
            (id == 'b' || id == 'c')) {
          canInteract = true;
        }

        if (canInteract) {
          if (distToTop < 200) {
            // HUGE snap radius to make it super easy!
            p.x = 0;
            p.y = -230;
            if ((id == 'a' || id == 'b') &&
                (_currentStep == 2 || _currentStep == 3)) {
              p.rotation = 0;
            } else {
              p.rotation = -_intersectionAngle;
            }
            p.placed = true;
            snapped = true;
          } else {
            p.placed = false;
          }
        } else {
          p.x = 0;
          p.y = 0;
          p.placed = false;
          p.rotation = 0;
        }
      } else if (_currentScenario == 2) {
        bool canInteract =
            id == 'a' && (_currentStep == 2 || _currentStep == 3);
        if (canInteract) {
          if (distToOrigin < 200) {
            p.x = 0;
            p.y = 0;
            p.rotation = 180;
            p.placed = true;
            snapped = true;
          } else {
            p.placed = false;
          }
        } else {
          p.x = 0;
          p.y = 0;
          p.placed = false;
          p.rotation = 0;
        }
      }
    });

    _checkCompletion(snapped);
  }

  void _checkCompletion(bool snapped) {
    if (snapped) {
      _playSound('click');
      if (_currentScenario == 1) {
        if (_currentStep == 2) {
          if (_pieces['a']!.placed && _pieces['b']!.placed) {
            setState(() {
              _currentStep = 3;
            });
            _markStepComplete();
          } else if (_pieces['a']!.placed || _pieces['b']!.placed) {
            _markStepComplete(delayMs: 0, silent: true);
          }
        } else if (_currentStep == 3) {
          if (_pieces['a']!.placed && _pieces['b']!.placed) {
            _markStepComplete(); // advances to step 5
          }
        } else if (_currentStep == 4) {
          if (_pieces['b']!.placed && _pieces['c']!.placed) {
            _markStepComplete(); // completes scenario
          }
        }
      } else if (_currentScenario == 2) {
        if (_currentStep == 2) {
          if (_pieces['a']!.placed) {
            _markStepComplete(delayMs: 0, silent: true);
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted && _currentStep == 3) _markStepComplete(delayMs: 0);
            });
          }
        } else if (_currentStep == 3) {
          if (_pieces['a']!.placed) _markStepComplete();
        }
      }
    } else {
      _playSound('wrong');
    }
  }

  void _handleKeypadPress(String val) {
    _playSound('click');
    if (val == 'C') {
      setState(() {
        _keypadBuffer = "";
      });
    } else if (val == 'E') {
      int? num = int.tryParse(_keypadBuffer);
      if (num != null) {
        if (_s5ActiveInput == 'x' && num == 110) {
          setState(() {
            _s5xSolved = true;
            _s5ActiveInput = null;
            _keypadBuffer = "";
          });
          _markStepComplete();
        } else if (_s5ActiveInput == 'y' && num == 70) {
          setState(() {
            _s5ySolved = true;
            _s5ActiveInput = null;
            _keypadBuffer = "";
          });
          _markStepComplete();
        } else {
          _playSound('wrong');
          setState(() {
            _keypadBuffer = "";
          });
        }
      }
    } else {
      if (_keypadBuffer.length < 3) {
        setState(() {
          _keypadBuffer += val;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.35;

    int totalSteps =
        (_getScenarioConfig(_currentScenario)['steps'] as List).length;
    bool isCurrentScenarioFinished =
        _completedScenarios.contains(_currentScenario) &&
        _currentStep == totalSteps - 1;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // Layer 1: PERFECT RESPONSIVE CANVAS WITH PAN/ZOOM CAPABILITIES
            Positioned.fill(
              left: _isSidebarOpen ? sidebarWidth : 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (!_isInitialScaleSet &&
                      constraints.maxWidth > 0 &&
                      constraints.maxHeight > 0) {
                    _isInitialScaleSet = true;
                    double scaleX = constraints.maxWidth / 800;
                    double scaleY = constraints.maxHeight / 800;
                    double initialScale = min(scaleX, scaleY) * 0.95;

                    Future.microtask(() {
                      _transformationController.value =
                          Matrix4.identity()
                            ..translate(
                              (constraints.maxWidth - 800 * initialScale) / 2,
                              (constraints.maxHeight - 800 * initialScale) / 2,
                            )
                            ..scale(initialScale);
                    });
                  }

                  return InteractiveViewer(
                    maxScale: 5.0,
                    minScale: 0.2,
                    boundaryMargin: const EdgeInsets.all(1500),
                    constrained: false,
                    panEnabled: !_isDraggingPiece,
                    scaleEnabled: !_isDraggingPiece,
                    transformationController: _transformationController,
                    child: SizedBox(
                      width: 800,
                      height: 800,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: -2000,
                            right: -2000,
                            top: -2000,
                            bottom: -2000,
                            child: CustomPaint(painter: GridPainter()),
                          ),
                          _buildScenarioContent(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Layer 1.5: HUD OVERLAYS (Immune to Canvas Zoom & Pan Gestures!)
            if (!_isCurtainVisible)
              Positioned.fill(child: _buildHUDOverlays(sidebarWidth)),

            // Layer 2: Floating Mission Card
            if (!_isSidebarOpen && !_isCurtainVisible)
              Positioned(top: 66, left: 16, child: _buildFloatingMissionCard()),

            // Layer 3: Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: _buildSidebar(),
            ),

            // Layer 4: Menu Button
            if (!_isCurtainVisible)
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                  color: Colors.amberAccent,
                  iconSize: 28,
                  onPressed: () {
                    _playSound('toggle');
                    setState(() {
                      _isSidebarOpen = !_isSidebarOpen;
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.amber.withOpacity(0.8)),
                    ),
                  ),
                ),
              ),

            // Layer 5: Keypad Overlay
            if (_s5ActiveInput != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(child: _buildKeypad()),
                ),
              ),

            // Layer 6: Scenario Completion Popup
            if (isCurrentScenarioFinished &&
                !_showGlobalSuccess &&
                _dismissedSuccessPopupFor != _currentScenario)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      width: 380,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.greenAccent, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.3),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 80,
                                color: Colors.greenAccent,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t('scenarioComplete'),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (_currentScenario < 5) ...[
                                ElevatedButton.icon(
                                  onPressed:
                                      () => _loadScenario(_currentScenario + 1),
                                  icon: const Icon(Icons.arrow_forward),
                                  label: Text(t('nextScenario')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    minimumSize: const Size(
                                      double.infinity,
                                      50,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              ElevatedButton.icon(
                                onPressed: () {
                                  _playSound('click');
                                  _loadScenario(_currentScenario);
                                },
                                icon: const Icon(Icons.refresh),
                                label: Text(t('reset')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white10,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: -24,
                            top: -24,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white54,
                                size: 28,
                              ),
                              onPressed: () {
                                _playSound('click');
                                setState(
                                  () =>
                                      _dismissedSuccessPopupFor =
                                          _currentScenario,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Layer 6.5: Global Success Modal
            if (_showGlobalSuccess)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Container(
                      width: 400,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.amber, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              size: 80,
                              color: Colors.amber,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              t('successTitle'),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              t('successMsg'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _handleMasterReset,
                              icon: const Icon(Icons.refresh),
                              label: Text(t('restart')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
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

            // Layer 7: Curtain Raiser
            if (_isCurtainVisible)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF020617),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.science,
                            size: 72,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          t('appTitle'),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t('appSubtitle'),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: () {
                            _playSound('chime');
                            setState(() {
                              _isCurtainVisible = false;
                            });
                            _loadScenario(1);
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            t('enterLab'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                            shadowColor: Colors.amberAccent.withOpacity(0.5),
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

  Widget _buildHUDOverlays(double sidebarWidth) {
    return Stack(
      children: [
        // 1. Top Right: Reset Button for S1 Step 5
        if (_currentScenario == 1 && _currentStep == 4 && !_s1PiecesReset)
          Positioned(
            right: 24,
            bottom: 24,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(
                t('resetPieces'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                elevation: 10,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              onPressed: () {
                _playSound('click');
                setState(() {
                  _pieces['a'] = PieceState();
                  _pieces['b'] = PieceState();
                  _s1PiecesReset = true;
                });
              },
            ),
          ),

        // 2. Bottom Right: Auto-Snap Fallback Buttons
        Positioned(
          right: 24,
          bottom: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_currentScenario == 1 &&
                  (_currentStep == 2 || _currentStep == 3) &&
                  (!_pieces['a']!.placed || !_pieces['b']!.placed))
                ElevatedButton.icon(
                  icon: const Icon(Icons.auto_fix_high),
                  label: Text(
                    t('autoSnap'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  onPressed: () {
                    _playSound('click');
                    setState(() {
                      _pieces['a']!.x = 0;
                      _pieces['a']!.y = -230;
                      _pieces['a']!.rotation = 0;
                      _pieces['a']!.placed = true;

                      _pieces['b']!.x = 0;
                      _pieces['b']!.y = -230;
                      _pieces['b']!.rotation = 0;
                      _pieces['b']!.placed = true;
                      _currentStep = 3;
                    });
                    _checkCompletion(true);
                  },
                ),
              if (_currentScenario == 1 &&
                  _currentStep == 4 &&
                  _s1PiecesReset &&
                  (!_pieces['b']!.placed || !_pieces['c']!.placed))
                ElevatedButton.icon(
                  icon: const Icon(Icons.auto_fix_high),
                  label: Text(
                    t('autoSnap'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  onPressed: () {
                    _playSound('click');
                    setState(() {
                      _pieces['b']!.x = 0;
                      _pieces['b']!.y = -230;
                      _pieces['b']!.rotation = -_intersectionAngle;
                      _pieces['b']!.placed = true;

                      _pieces['c']!.x = 0;
                      _pieces['c']!.y = -230;
                      _pieces['c']!.rotation = -_intersectionAngle;
                      _pieces['c']!.placed = true;
                    });
                    _checkCompletion(true);
                  },
                ),
              if (_currentScenario == 2 &&
                  (_currentStep == 2 || _currentStep == 3) &&
                  !_pieces['a']!.placed)
                ElevatedButton.icon(
                  icon: const Icon(Icons.auto_fix_high),
                  label: Text(
                    t('autoSnapSingle'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  onPressed: () {
                    _playSound('click');
                    setState(() {
                      _pieces['a']!.x = 0;
                      _pieces['a']!.y = 0;
                      _pieces['a']!.rotation = 180;
                      _pieces['a']!.placed = true;
                      _currentStep = 3;
                    });
                    _checkCompletion(true);
                  },
                ),
            ],
          ),
        ),

        // 3. Top Right: Scenario 3 Tools Panel
        if (_currentScenario == 3)
          Positioned(
            top: 24,
            right: 24,
            child: Container(
              width: 260,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Angle Tools',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Divider(),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_currentStep == 0) _markStepComplete();
                      if (_currentStep == 3) {
                        setState(() {
                          _s3ActiveTool = 'lp';
                          _s3SliderValue = 0;
                        });
                      }
                    },
                    icon: const Icon(Icons.linear_scale, color: Colors.blue),
                    label: Text(t('btnLinearPair')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _currentStep == 0
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.white10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_currentStep == 2) {
                        setState(() {
                          _s3cSolved = true;
                        });
                        _markStepComplete();
                      }
                    },
                    icon: const Icon(Icons.close, color: Colors.amber),
                    label: Text(t('btnVertOpp')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _currentStep == 2
                              ? Colors.amber.withOpacity(0.3)
                              : Colors.white10,
                    ),
                  ),
                  if ((_currentStep == 1) ||
                      (_currentStep == 3 && _s3ActiveTool == 'lp')) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "130° + ${_s3SliderValue.toInt()}° = 180°",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  _s3SliderValue == 50
                                      ? Colors.green
                                      : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t('dragSlider'),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white54,
                            ),
                          ),
                          Slider(
                            value: _s3SliderValue,
                            min: 0,
                            max: 180,
                            activeColor:
                                _currentStep == 1 ? Colors.blue : Colors.red,
                            onChanged: (val) {
                              if (_actionValidated) return;
                              setState(() {
                                _s3SliderValue = val;
                              });
                              if (val.toInt() == 50) {
                                if (_currentStep == 1) {
                                  setState(() {
                                    _s3bSolved = true;
                                  });
                                  _markStepComplete();
                                } else if (_currentStep == 3) {
                                  setState(() {
                                    _s3dSolved = true;
                                  });
                                  _markStepComplete();
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingMissionCard() {
    final scenario = _getScenarioConfig(_currentScenario);
    final steps = scenario['steps'] as List<String>;
    final bool hasSteps = _currentStep < steps.length;

    bool isObservationStep =
        (_currentScenario == 1 && _currentStep == 0) ||
        (_currentScenario == 2 && _currentStep == 0);

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasSteps
                      ? '${t('step')} ${_currentStep + 1}'
                      : t('missionObj'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasSteps ? steps[_currentStep] : scenario['obj'],
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          if (hasSteps && isObservationStep) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _playSound('click');
                _markStepComplete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                t('continue_btn'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final scenario = _getScenarioConfig(_currentScenario);
    final steps = scenario['steps'] as List<String>;

    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(right: BorderSide(color: Colors.white24, width: 1)),
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 66, 16, 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.explore,
                            color: Colors.amber,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t('appTitle'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t('appSubtitle'),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.language, size: 16),
                            label: Text(
                              _currentLang.toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: _toggleLanguage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white10,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh, size: 16),
                            label: Text(
                              t('reset'),
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: _handleMasterReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.2),
                              foregroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _currentScenario,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF0F172A),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.amber,
                            ),
                            items:
                                [1, 2, 3, 4, 5].map((id) {
                                  return DropdownMenuItem(
                                    value: id,
                                    child: Text(
                                      _getScenarioConfig(id)['title'],
                                      style: const TextStyle(
                                        fontSize: 14,
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
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.menu_book,
                                  size: 18,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  t('missionObj'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              scenario['obj'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.4,
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
                            size: 18,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t('procSteps'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ...List.generate(steps.length, (index) {
                        bool isPast = index < _currentStep;
                        bool isCurrent = index == _currentStep;
                        bool isObservationStep =
                            (_currentScenario == 1 && index == 0) ||
                            (_currentScenario == 2 && index == 0);

                        Color bg =
                            isCurrent
                                ? Colors.amber.withOpacity(0.15)
                                : (isPast
                                    ? Colors.white.withOpacity(0.02)
                                    : Colors.white.withOpacity(0.05));
                        Color border =
                            isCurrent
                                ? Colors.amber
                                : (isPast ? Colors.white12 : Colors.white24);
                        Color textCol =
                            isCurrent
                                ? Colors.white
                                : (isPast ? Colors.white38 : Colors.white70);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: bg,
                            border: Border.all(color: border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isPast
                                      ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 24,
                                      )
                                      : Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              isCurrent
                                                  ? Colors.blue
                                                  : Colors.white24,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                                          '${t("step")} ${index + 1}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isCurrent
                                                    ? Colors.amber
                                                    : Colors.white54,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          steps[index],
                                          style: TextStyle(
                                            color: textCol,
                                            fontSize: 13,
                                            decoration:
                                                isPast
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (isCurrent && isObservationStep) ...[
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    _playSound('click');
                                    _markStepComplete();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black,
                                    minimumSize: const Size(
                                      double.infinity,
                                      36,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    t('continue_btn'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.white12)),
                  ),
                  child: Text(
                    t('footer'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: Colors.white60),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      width: 280,
      constraints: const BoxConstraints(
        maxHeight: 500,
      ), // Height constraint for scrolling
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter Angle $_s5ActiveInput",
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                _keypadBuffer,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ...[
                  '1',
                  '2',
                  '3',
                  '4',
                  '5',
                  '6',
                  '7',
                  '8',
                  '9',
                  'C',
                  '0',
                  'E',
                ].map((k) {
                  Color btnCol = Colors.white10;
                  Color txtCol = Colors.white;
                  if (k == 'C') {
                    btnCol = Colors.red.withOpacity(0.2);
                    txtCol = Colors.redAccent;
                  }
                  if (k == 'E') {
                    btnCol = Colors.green.withOpacity(0.2);
                    txtCol = Colors.greenAccent;
                  }

                  return InkWell(
                    onTap: () => _handleKeypadPress(k),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 70,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: btnCol,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        k == 'E' ? 'OK' : k,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: txtCol,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioContent() {
    if (_currentScenario <= 3) return _buildS1S2S3();
    if (_currentScenario == 4) return _buildS4();
    if (_currentScenario == 5) return _buildS5();
    return const SizedBox();
  }

  Widget _buildS1S2S3() {
    List<String> activePieces = ['a', 'b', 'c', 'd'];

    bool showTopGuide = (_currentScenario == 1 && _currentStep >= 2);

    double a = _currentScenario == 3 ? 130 : _intersectionAngle;
    Map<String, Map<String, dynamic>> arcData = {
      'a': {
        'start': 0.0,
        'sweep': a,
        'val': a,
        'color': const Color(0xFF3B82F6).withOpacity(0.85),
      },
      'b': {
        'start': a,
        'sweep': 180 - a,
        'val': 180 - a,
        'color':
            _currentScenario == 2
                ? Colors.grey.withOpacity(0.3)
                : const Color(0xFF10B981).withOpacity(0.85),
      },
      'c': {
        'start': 180.0,
        'sweep': a,
        'val': a,
        'color': const Color(0xFFEAB308).withOpacity(0.85),
      },
      'd': {
        'start': 180 + a,
        'sweep': 180 - a,
        'val': 180 - a,
        'color':
            _currentScenario == 2
                ? Colors.grey.withOpacity(0.3)
                : const Color(0xFFEF4444).withOpacity(0.85),
      },
    };

    return Stack(
      alignment: Alignment.center,
      children: [
        if (showTopGuide)
          Positioned(
            top: 200 - 150,
            left: 400 - 150,
            child: CustomPaint(
              size: const Size(300, 160),
              painter: GuidePainter(),
            ),
          ),

        if (_currentScenario == 1 &&
            (_currentStep == 3 || _currentStep == 4) &&
            _pieces['a']!.placed &&
            _pieces['b']!.placed)
          Positioned(
            top: 220,
            child: const Text(
              "∠a + ∠b = 180°. This is a Linear Pair!",
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),

        if (_currentScenario == 1 &&
            _currentStep == 4 &&
            _pieces['b']!.placed &&
            _pieces['c']!.placed)
          Positioned(
            top: 220,
            child: const Text(
              "∠b + ∠c = 180°. This is also a Linear Pair!",
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),

        if (_currentScenario == 2 &&
            _pieces['a']!.placed &&
            (_currentStep == 2 || _currentStep == 3))
          Positioned(
            top: 280,
            child: const Text(
              "∠a = ∠c. Vertically Opposite Angles are Equal!",
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),

        ...['a', 'b', 'c', 'd'].map((id) {
          if (!activePieces.contains(id)) return const SizedBox();
          PieceState p = _pieces[id]!;
          var data = arcData[id]!;

          String label = "${data['val'].toInt()}°";
          if (_currentScenario == 3) {
            if (id == 'a') label = '130°';
            if (id == 'b') label = _s3bSolved ? '50°' : '?';
            if (id == 'c') label = _s3cSolved ? '130°' : '?';
            if (id == 'd') label = _s3dSolved ? '50°' : '?';
          }

          bool canInteract = false;
          if (_currentScenario == 1) {
            if ((_currentStep == 2 || _currentStep == 3) &&
                (id == 'a' || id == 'b')) {
              canInteract = true;
            } else if (_currentStep == 4 &&
                _s1PiecesReset &&
                (id == 'b' || id == 'c')) {
              canInteract = true;
            }
          } else if (_currentScenario == 2) {
            if ((_currentStep == 2 || _currentStep == 3) && id == 'a') {
              canInteract = true;
            }
          }

          Widget pieceW = Transform.rotate(
            angle: p.rotation * pi / 180,
            child: IgnorePointer(
              ignoring: !canInteract,
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onTap: () => _onPieceTap(id),
                onPanStart: (det) => _onPiecePanStart(id, det),
                onPanUpdate: (det) => _onPiecePanUpdate(id, det),
                onPanEnd: (det) => _onPiecePanEnd(id, det),
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: CustomPaint(
                    painter: WedgePainter(
                      startAngle: data['start'],
                      sweepAngle: data['sweep'],
                      color: data['color'],
                      label: label,
                      canvasSize: const Size(240, 240),
                    ),
                  ),
                ),
              ),
            ),
          );

          return Positioned(
            left: 400 - 120 + p.x,
            top: 400 - 120 + p.y,
            child: pieceW,
          );
        }),

        CustomPaint(
          size: const Size(800, 800),
          painter: LinesPainter(angle: a),
        ),

        if (_currentScenario <= 2)
          Positioned(
            left: 400 + 280 * cos(-a * pi / 180) - 32,
            top: 400 + 280 * sin(-a * pi / 180) - 32,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: _onRotateHandlePanStart,
              onPanUpdate: _onRotateHandlePan,
              onPanEnd: _onRotateHandlePanEnd,
              onPanCancel: _onRotateHandlePanCancel,
              child: Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                color: Colors.black.withOpacity(0.001),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAB308),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0F172A),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEAB308).withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildS4() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Static Vertically Oriented Scissors
        CustomPaint(size: const Size(800, 800), painter: ScissorPainter()),

        // Dynamic Label fixed in bottom blade V
        const Positioned(
          top: 450, // Pushed down visually between the blades
          child: Text(
            '45°',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
            ),
          ),
        ),

        // Mathematically Mapped Placement Slots (Y is Up mapped natively)
        // Center is 400, 400.
        // Top Slot (45° yellow): Center is 90°(Up).
        if (!_s4Slots['c']!) _buildS4Slot(67.5, 45, 'c', 45),
        if (_s4Slots['c']!)
          _buildS4Placed(
            67.5,
            45,
            const Color(0xFFEAB308).withOpacity(0.9),
            '45°',
          ),

        // Left Slot (135° green): Center is 180°(Left).
        if (!_s4Slots['b']!) _buildS4Slot(112.5, 135, 'b', 135),
        if (_s4Slots['b']!)
          _buildS4Placed(
            112.5,
            135,
            const Color(0xFF10B981).withOpacity(0.9),
            '135°',
          ),

        // Right Slot (135° green): Center is 0°(Right). 360 - 67.5 = 292.5
        if (!_s4Slots['d']!) _buildS4Slot(292.5, 135, 'd', 135),
        if (_s4Slots['d']!)
          _buildS4Placed(
            292.5,
            135,
            const Color(0xFF10B981).withOpacity(0.9),
            '135°',
          ),

        // Unified Rounded Toolbox Background
        if (_currentStep <= 1)
          Positioned(
            bottom: 30,
            child: Container(
              width: 500,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 10),
                ],
              ),
              padding: const EdgeInsets.only(left: 30),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Drag Pieces:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),

        // Dispenser Sources: Geometrically mapped on top of the toolbox UI
        if (_currentStep <= 1) ...[
          // 45° Yellow Dispenser
          Positioned(
            left: 380, // Math layout: Canvas 800, center is 400.
            top: 650, // Bottom 30 + 120h = 150 from bottom = 650
            child: Listener(
              onPointerDown: (_) => setState(() => _isDraggingPiece = true),
              child: Draggable<int>(
                data: 45,
                dragAnchorStrategy: (draggable, context, position) {
                  final RenderBox renderObject =
                      context.findRenderObject()! as RenderBox;
                  final localPosition = renderObject.globalToLocal(position);
                  double scale =
                      _transformationController.value.getMaxScaleOnAxis();
                  return localPosition * scale;
                },
                onDragEnd: (details) {
                  setState(() => _isDraggingPiece = false);
                  if (!details.wasAccepted) {
                    _playSound('wrong');
                  }
                },
                feedback: Transform.scale(
                  scale: _transformationController.value.getMaxScaleOnAxis(),
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: WedgePainter(
                        startAngle: 0,
                        sweepAngle: 45,
                        color: const Color(0xFFEAB308).withOpacity(0.9),
                        label: '45°',
                        radius: 60,
                        canvasSize: const Size(120, 120),
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: WedgePainter(
                        startAngle: 0,
                        sweepAngle: 45,
                        color: const Color(0xFFEAB308).withOpacity(0.9),
                        label: '45°',
                        radius: 60,
                        canvasSize: const Size(120, 120),
                      ),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: WedgePainter(
                      startAngle: 0,
                      sweepAngle: 45,
                      color: const Color(0xFFEAB308).withOpacity(0.9),
                      label: '45°',
                      radius: 60,
                      canvasSize: const Size(120, 120),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 135° Green Dispenser
          Positioned(
            left: 520,
            top: 650,
            child: Listener(
              onPointerDown: (_) => setState(() => _isDraggingPiece = true),
              child: Draggable<int>(
                data: 135,
                dragAnchorStrategy: (draggable, context, position) {
                  final RenderBox renderObject =
                      context.findRenderObject()! as RenderBox;
                  final localPosition = renderObject.globalToLocal(position);
                  double scale =
                      _transformationController.value.getMaxScaleOnAxis();
                  return localPosition * scale;
                },
                onDragEnd: (details) {
                  setState(() => _isDraggingPiece = false);
                  if (!details.wasAccepted) {
                    _playSound('wrong');
                  }
                },
                feedback: Transform.scale(
                  scale: _transformationController.value.getMaxScaleOnAxis(),
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: WedgePainter(
                        startAngle: 45,
                        sweepAngle: 135,
                        color: const Color(0xFF10B981).withOpacity(0.9),
                        label: '135°',
                        radius: 60,
                        canvasSize: const Size(120, 120),
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: WedgePainter(
                        startAngle: 45,
                        sweepAngle: 135,
                        color: const Color(0xFF10B981).withOpacity(0.9),
                        label: '135°',
                        radius: 60,
                        canvasSize: const Size(120, 120),
                      ),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: WedgePainter(
                      startAngle: 45,
                      sweepAngle: 135,
                      color: const Color(0xFF10B981).withOpacity(0.9),
                      label: '135°',
                      radius: 60,
                      canvasSize: const Size(120, 120),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _checkS4Completion() {
    int numPlaced =
        (_s4Slots['b']! ? 1 : 0) +
        (_s4Slots['c']! ? 1 : 0) +
        (_s4Slots['d']! ? 1 : 0);
    if (numPlaced == 3) {
      if (_currentStep == 0) setState(() => _currentStep = 1);
      _markStepComplete(delayMs: 600);
    } else if (numPlaced >= 1 && _currentStep == 0) {
      _markStepComplete();
    }
  }

  Widget _buildS4Slot(
    double startAngle,
    double sweepAngle,
    String id,
    int expectedAngle,
  ) {
    return Positioned(
      left: 400 - 160,
      top: 400 - 160,
      child: DragTarget<int>(
        onWillAcceptWithDetails:
            (details) => details.data == expectedAngle && !_s4Slots[id]!,
        onAcceptWithDetails: (details) {
          _playSound('success');
          setState(() {
            _s4Slots[id] = true;
          });
          _checkS4Completion();
        },
        builder: (context, candidateData, rejectedData) {
          return CustomPaint(
            size: const Size(320, 320),
            painter: WedgePainter(
              startAngle: startAngle,
              sweepAngle: sweepAngle,
              color: candidateData.isNotEmpty ? Colors.white30 : Colors.white10,
              isSlot: true,
              radius: 80,
              canvasSize: const Size(320, 320),
            ),
          );
        },
      ),
    );
  }

  Widget _buildS4Placed(
    double startAngle,
    double sweepAngle,
    Color color,
    String label,
  ) {
    return Positioned(
      left: 400 - 160,
      top: 400 - 160,
      child: CustomPaint(
        size: const Size(320, 320),
        painter: WedgePainter(
          startAngle: startAngle,
          sweepAngle: sweepAngle,
          color: color,
          label: label,
          radius: 80,
          canvasSize: const Size(320, 320),
        ),
      ),
    );
  }

  Widget _buildS5() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Gate Painter
        CustomPaint(size: const Size(800, 800), painter: GatePainter()),

        // Input Box X (Bottom, vertically opposite)
        Positioned(
          top: 400 + 70, // Below center
          child: GestureDetector(
            onTap: () {
              if (_currentStep == 0) {
                setState(() {
                  _s5ActiveInput = 'x';
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color:
                    _s5xSolved
                        ? Colors.green
                        : const Color(0xFF1E293B), // Dark blue
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      _s5xSolved
                          ? Colors.greenAccent
                          : const Color(0xFF3B82F6), // Blue border
                  width: 3,
                ),
                boxShadow:
                    _currentStep == 0 && !_s5xSolved
                        ? const [BoxShadow(color: Colors.amber, blurRadius: 8)]
                        : const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
              ),
              child: Text(
                _s5xSolved ? '110°' : 'x',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        // Input Box Y (Right, linear pair)
        Positioned(
          left: 400 + 80, // Right of center
          top: 400 - 25, // Vertically centered
          child: GestureDetector(
            onTap: () {
              if (_currentStep == 1) {
                setState(() {
                  _s5ActiveInput = 'y';
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color:
                    _s5ySolved ? Colors.green : const Color(0xFFDC2626), // Red
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      _s5ySolved
                          ? Colors.greenAccent
                          : const Color(0xFFFCA5A5), // Light pink/red border
                  width: 3,
                ),
                boxShadow:
                    _currentStep == 1 && !_s5ySolved
                        ? const [BoxShadow(color: Colors.amber, blurRadius: 8)]
                        : const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
              ),
              child: Text(
                _s5ySolved ? '70°' : 'y',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---- Custom Painters ----

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.08)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
    const double spacing = 40.0;
    List<Offset> points = [];
    for (double x = 0; x <= size.width; x += spacing) {
      for (double y = 0; y <= size.height; y += spacing) {
        points.add(Offset(x, y));
      }
    }
    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LinesPainter extends CustomPainter {
  final double angle;
  LinesPainter({required this.angle});

  void _drawArrowhead(Canvas canvas, Offset p, double angleRad, Paint paint) {
    final path =
        Path()
          ..moveTo(p.dx, p.dy)
          ..lineTo(
            p.dx - 18 * cos(angleRad - pi / 8),
            p.dy - 18 * sin(angleRad - pi / 8),
          )
          ..lineTo(
            p.dx - 18 * cos(angleRad + pi / 8),
            p.dy - 18 * sin(angleRad + pi / 8),
          )
          ..close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    final lineLength = 320.0;

    canvas.drawLine(
      Offset(center.dx - lineLength, center.dy),
      Offset(center.dx + lineLength, center.dy),
      paint,
    );
    _drawArrowhead(canvas, Offset(center.dx + lineLength, center.dy), 0, paint);
    _drawArrowhead(
      canvas,
      Offset(center.dx - lineLength, center.dy),
      pi,
      paint,
    );

    double rad = angle * pi / 180;
    double dx = lineLength * cos(rad);
    double dy = lineLength * sin(rad);

    canvas.drawLine(
      Offset(center.dx - dx, center.dy + dy),
      Offset(center.dx + dx, center.dy - dy),
      paint,
    );
    _drawArrowhead(canvas, Offset(center.dx + dx, center.dy - dy), -rad, paint);
    _drawArrowhead(
      canvas,
      Offset(center.dx - dx, center.dy + dy),
      pi - rad,
      paint,
    );

    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.bold,
      shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
    );
    final textPainterL = TextPainter(
      text: TextSpan(text: 'l', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterL.paint(
      canvas,
      Offset(center.dx + lineLength - 10, center.dy - 40),
    );
    final textPainterM = TextPainter(
      text: TextSpan(text: 'm', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterM.paint(
      canvas,
      Offset(center.dx + dx - 10, center.dy - dy - 40),
    );

    canvas.drawCircle(center, 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant LinesPainter oldDelegate) =>
      oldDelegate.angle != angle;
}

class GuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 120);
    final paintLine =
        Paint()
          ..color = Colors.white30
          ..strokeWidth = 2;
    final paintArc =
        Paint()
          ..color = Colors.white54
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, 120), Offset(size.width, 120), paintLine);

    double dashAngle = 6 * pi / 180;
    double gapAngle = 6 * pi / 180;
    for (double a = 0; a < pi; a += dashAngle + gapAngle) {
      double sweep = min(dashAngle, pi - a);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 120),
        -pi + a,
        sweep,
        false,
        paintArc,
      );
    }

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '180° Semi-Circle Guide',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(size.width / 2 - textPainter.width / 2, 120 - 120 - 24),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WedgePainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final Color color;
  final String label;
  final double radius;
  final bool isSlot;
  final double isPlacedRotate;
  final Size canvasSize;

  WedgePainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
    this.label = '',
    this.radius = 120,
    this.isSlot = false,
    this.isPlacedRotate = 0,
    this.canvasSize = const Size(240, 240),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);

    canvas.translate(center.dx, center.dy);
    canvas.scale(1, -1);
    canvas.translate(-center.dx, -center.dy);

    double startRad = startAngle * pi / 180;
    double sweepRad = sweepAngle * pi / 180;

    Offset p1 = Offset(
      center.dx + radius * cos(startRad),
      center.dy + radius * sin(startRad),
    );
    Offset p2 = Offset(
      center.dx + radius * cos(startRad + sweepRad),
      center.dy + radius * sin(startRad + sweepRad),
    );

    double midRad = startRad + sweepRad / 2;
    double dP = radius * cos(sweepRad / 2);
    double minRadius = radius * 0.25;
    double targetMid = max(minRadius, dP * 0.55);
    double cpDist = 2 * targetMid - dP;
    Offset cp = Offset(
      center.dx + cpDist * cos(midRad),
      center.dy + cpDist * sin(midRad),
    );

    if (isSlot) {
      final paint =
          Paint()
            ..color = Colors.white.withOpacity(0.1)
            ..style = PaintingStyle.fill;
      final border =
          Paint()
            ..color = Colors.white54
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
      Path path =
          Path()
            ..moveTo(center.dx, center.dy)
            ..lineTo(p1.dx, p1.dy)
            ..quadraticBezierTo(cp.dx, cp.dy, p2.dx, p2.dy)
            ..close();
      canvas.drawPath(path, paint);
      canvas.drawPath(path, border);
    } else {
      final paint =
          Paint()
            ..color = color
            ..style = PaintingStyle.fill;
      final border =
          Paint()
            ..color = Colors.white.withOpacity(0.15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;
      Path path =
          Path()
            ..moveTo(center.dx, center.dy)
            ..lineTo(p1.dx, p1.dy)
            ..quadraticBezierTo(cp.dx, cp.dy, p2.dx, p2.dy)
            ..close();
      canvas.drawPath(path, paint);
      canvas.drawPath(path, border);

      if (label.isNotEmpty) {
        canvas.translate(center.dx, center.dy);
        canvas.scale(1, -1);
        double tx = (radius * 0.6) * cos(midRad);
        double ty = -(radius * 0.6) * sin(midRad);
        canvas.translate(tx, ty);

        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
                Shadow(
                  color: Colors.black87,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        canvas.translate(-tx, -ty);
        canvas.translate(-center.dx, -center.dy);
      }
    }
  }

  @override
  bool? hitTest(Offset position) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);

    double dx = position.dx - center.dx;
    double dy = position.dy - center.dy;
    double dist = sqrt(dx * dx + dy * dy);

    if (dist > radius + 40 || dist < 10) return false;

    double mathDy = -dy;
    double mathAngle = atan2(mathDy, dx);
    if (mathAngle < 0) mathAngle += 2 * pi;

    double startRad = (startAngle * pi / 180) % (2 * pi);
    double sweepRad = sweepAngle * pi / 180;

    double diff = (mathAngle - startRad) % (2 * pi);
    if (diff < 0) diff += 2 * pi;

    double tol = 15 * pi / 180;
    if (diff <= sweepRad + tol || diff >= 2 * pi - tol) return true;
    return false;
  }

  @override
  bool shouldRepaint(covariant WedgePainter oldDelegate) =>
      oldDelegate.startAngle != startAngle ||
      oldDelegate.sweepAngle != sweepAngle ||
      oldDelegate.label != label;
}

class ScissorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);

    final bladePaint =
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..style = PaintingStyle.fill;
    final handlePaintRed =
        Paint()
          ..color = const Color(0xFFEF4444)
          ..style = PaintingStyle.fill;
    final handleHolePaint =
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.fill;

    // Helper to draw a perfectly designed scissor half starting from the pivot point
    void drawHalf(double angleRad) {
      canvas.save();
      canvas.rotate(angleRad); // Rotate to layout along mathematical X axis!

      // Grey pointed Blade
      Path blade =
          Path()
            ..moveTo(0, -6)
            ..lineTo(300, -6)
            ..lineTo(320, 0)
            ..lineTo(300, 6)
            ..lineTo(0, 6)
            ..close();
      canvas.drawPath(blade, bladePaint);
      canvas.drawPath(
        blade,
        Paint()
          ..color = Colors.black38
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      // Thick Red Handle Loop
      Path handle =
          Path()
            ..moveTo(0, -12)
            ..lineTo(-120, -12)
            ..addArc(
              Rect.fromCircle(center: const Offset(-130, 0), radius: 35),
              -pi / 2,
              pi,
            )
            ..lineTo(0, 12)
            ..close();
      canvas.drawPath(handle, handlePaintRed);

      // Inside Finger Hole
      canvas.drawCircle(const Offset(-130, 0), 20, handleHolePaint);
      canvas.drawCircle(
        const Offset(-130, 0),
        20,
        Paint()
          ..color = const Color(0xFF991B1B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      );

      canvas.restore();
    }

    // Scissors logic mathematically aligned with Y DOWN coordinate system
    // 0 is Right, 90 is Down.
    // Half 1: Blade points Bottom-Left (112.5 deg). Handle is opposite at Top-Right (-67.5).
    drawHalf(112.5 * pi / 180);
    // Half 2: Blade points Bottom-Right (67.5 deg). Handle is opposite at Top-Left (-112.5).
    drawHalf(67.5 * pi / 180);

    // Center metallic pivot pin
    canvas.drawCircle(
      Offset.zero,
      10,
      Paint()..color = const Color(0xFF475569),
    );
    canvas.drawCircle(Offset.zero, 4, Paint()..color = Colors.black45);

    canvas.translate(-center.dx, -center.dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GatePainter extends CustomPainter {
  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 8.0;
    double dashSpace = 6.0;
    double distance = (p2 - p1).distance;
    int count = (distance / (dashWidth + dashSpace)).floor();
    double dx = (p2.dx - p1.dx) / distance;
    double dy = (p2.dy - p1.dy) / distance;
    for (int i = 0; i < count; i++) {
      Offset start = Offset(
        p1.dx + dx * (i * (dashWidth + dashSpace)),
        p1.dy + dy * (i * (dashWidth + dashSpace)),
      );
      Offset end = Offset(start.dx + dx * dashWidth, start.dy + dy * dashWidth);
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawDashedArc(
    Canvas canvas,
    Rect rect,
    double startAngle,
    double sweepAngle,
    Paint paint,
  ) {
    double dashWidth = 8.0;
    double dashSpace = 6.0;
    double radius = rect.width / 2;
    double circumference = sweepAngle * radius;
    int count = (circumference / (dashWidth + dashSpace)).floor();
    double angleStep = sweepAngle / count;
    double drawAngle = (dashWidth / circumference) * sweepAngle;
    for (int i = 0; i < count; i++) {
      canvas.drawArc(rect, startAngle + i * angleStep, drawAngle, false, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);

    // Frame Outer Shadow
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 620, height: 440),
      Paint()..color = const Color(0xFF2D1606),
    );

    // Main Wood Panel
    final wood = Paint()..color = const Color(0xFF8B4513);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 600, height: 420),
      wood,
    );

    // Outer & Inner Bevel Borders
    final frameOuter =
        Paint()
          ..color = const Color(0xFF5E2E0D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12;
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 588, height: 408),
      frameOuter,
    );

    final frameInner =
        Paint()
          ..color = const Color(0xFFD97706)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 560, height: 380),
      frameInner,
    );

    // Diagonals (X marks the spot)
    final diagonalPaint =
        Paint()
          ..color = const Color(0xFF3E1F0A)
          ..strokeWidth = 6;
    canvas.drawLine(
      const Offset(-280, -190),
      const Offset(280, 190),
      diagonalPaint,
    );
    canvas.drawLine(
      const Offset(-280, 190),
      const Offset(280, -190),
      diagonalPaint,
    );

    // Top Arc: 110 degrees mathematically derived from a 600x420 aspect ratio
    final topArcFill =
        Paint()
          ..color = const Color(0xFF5C6BC0).withOpacity(0.85)
          ..style = PaintingStyle.fill;
    final topArcStroke =
        Paint()
          ..color = const Color(0xFF42A5F5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    Path topArc =
        Path()
          ..moveTo(0, 0)
          ..arcTo(
            Rect.fromCircle(center: Offset.zero, radius: 120),
            -145 * pi / 180,
            110 * pi / 180,
            false,
          )
          ..close();

    canvas.drawPath(topArc, topArcFill);
    canvas.drawPath(topArc, topArcStroke);

    // Bottom Arc: Dashed opposite angle
    final dashPaint =
        Paint()
          ..color = const Color(0xFFFACC15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    // Dashed sides of the wedge
    _drawDashedLine(
      canvas,
      Offset.zero,
      Offset(120 * cos(35 * pi / 180), 120 * sin(35 * pi / 180)),
      dashPaint,
    );
    _drawDashedLine(
      canvas,
      Offset.zero,
      Offset(120 * cos(145 * pi / 180), 120 * sin(145 * pi / 180)),
      dashPaint,
    );
    // Dashed curve
    _drawDashedArc(
      canvas,
      Rect.fromCircle(center: Offset.zero, radius: 120),
      35 * pi / 180,
      110 * pi / 180,
      dashPaint,
    );

    // Center Pivot
    canvas.drawCircle(
      Offset.zero,
      16,
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawCircle(Offset.zero, 8, Paint()..color = const Color(0xFF475569));

    // 110° Text
    final tp = TextPainter(
      text: const TextSpan(
        text: '110°',
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -90));

    canvas.translate(-center.dx, -center.dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
