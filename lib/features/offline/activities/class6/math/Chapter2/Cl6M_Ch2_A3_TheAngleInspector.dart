// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'The Angle Inspector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF6366F1),
        fontFamily: 'Roboto',
      ),
      home: const Cl6M_Ch2_A3_TheAngleInspector(),
    ),
  );
}

// --- TRANSLATIONS DICTIONARY ---
class Translations {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'resetBtn': 'Reset',

      'appTitle': 'The Angle Inspector',
      'appSubtitle': 'Class 6 Maths • CONCEPT OF ROTATION',
      'startLab': 'Start Lab',
      'zslLab': 'ZSL Virtual Lab',
      'selectScenario': 'Select Scenario',
      'learnLbl': 'Objective:',
      'stepLabel': 'STEP',
      'nextScenario': 'Next Scenario',
      'finishLab': 'Finish Lab',
      'finalDesc':
          'You have successfully learned how to compare angles by measuring their rotation!',

      'lbl_bigger': 'Angle A is BIGGER',
      'lbl_perfect_fit': 'PERFECT FIT!\nThe angles are EQUAL.',
      'lbl_s3_bigger':
          'Angle X is BIGGER.\nArm length doesn\'t matter,\nonly the turn!',
      'lbl_s3_extend': 'Extend Arms',
      'lbl_try_again': 'Try Again!',
      'lbl_correct': 'Correct!',
      'lbl_let_go': 'Let Go!',
      'lbl_low_bell': 'Low Bell',
      'lbl_med_bell': 'Medium Bell',
      'lbl_high_bell': 'High Bell',

      's1_title': '1. The Pizza Slice Swap',
      's1_obj':
          'To understand how to compare two angles by placing one directly on top of the other.',
      's1_step1_task':
          'On the right is a smaller pizza slice (Angle B). DRAG it towards the larger slice (Angle A).',
      's1_step1_out': 'Great! Now let\'s align them to compare the angles.',
      's1_step2_task':
          'OBSERVE the two slices. Notice how Angle A extends further than Angle B.',
      's1_step2_out':
          'Because the rotation of A is larger, Angle A is the bigger angle.',
      's1_hud1': 'Drag the small slice (B) to the large slice (A).',
      's1_hud2': 'Observe the difference in angles.',

      's2_title': '2. The Vault Key',
      's2_obj':
          'Understand that an angle must be an exact size to fit a corresponding shape.',
      's2_step1_task':
          'The brass key\'s angle is currently too small to fit the vault. DRAG the handle on the top arm of the key to open it wider.',
      's2_step1_out':
          'The colored arc shows the angle increasing. This is the \'turn\' or rotation.',
      's2_step2_task':
          'Now DRAG the body of the key and try to fit it into the keyhole on the wall.',
      's2_step2_out':
          'It doesn\'t fit! The key collides because the angle is incorrect.',
      's2_step3_task':
          'DRAG the handle to adjust the angle until it perfectly matches the keyhole.',
      's2_step3_out': 'The angles now match exactly.',
      's2_step4_task': 'DRAG the key into the keyhole.',
      's2_step4_out':
          'A perfect fit! The size of the angle determines if it fits the space.',
      's2_hud1': 'Drag the brass handle to open the key wider.',
      's2_hud2': 'Drag the key body to the vault keyhole.',
      's2_hud3': 'Adjust the angle until it matches the keyhole.',
      's2_hud4': 'Slide the perfectly matched key into the vault.',

      's3_title': '3. The Deceptive Arms',
      's3_obj':
          'Learn that the length of an angle\'s arms does not change the size of the angle.',
      's3_step1_task':
          'Angle Y (right) has long plastic arms. Does that make it bigger? DRAG Angle X (short arms) onto Angle Y, matching their vertices.',
      's3_step1_out':
          'Look at the rotation arc. Angle X has a wider opening, even with short arms.',
      's3_step2_task': 'TAP the \'Extend Arms\' button for Angle X.',
      's3_step2_out':
          'The arms got longer, but the colored rotation arc didn\'t change! The angle is the same.',
      's3_hud1': 'Drag Angle X to overlap Angle Y at the vertex.',
      's3_hud2': 'Tap \'Extend Arms\' to see what happens.',

      's4_title': '4. The Crane\'s Lunch',
      's4_obj':
          'Apply the skill of comparing angles to real-world objects using a measurement tool.',
      's4_step1_task':
          'DRAG the plastic \'Angle Measurer\' tool by its center vertex and place it on the corner of Crane 1\'s beak.',
      's4_step1_out': 'The tool is in position. Now we need to set its size.',
      's4_step2_task':
          'ADJUST the top arm of the Angle Measurer to perfectly match the opening of Crane 1\'s beak.',
      's4_step2_out': 'The tool now holds the exact angle of Crane 1.',
      's4_step3_task':
          'Without changing the angle, DRAG the Angle Measurer\'s center to Crane 2\'s beak.',
      's4_step3_out': 'Compare the tool\'s angle to Crane 2\'s beak opening.',
      's4_step4_task':
          'TAP on the crane that has the WIDER angle (bigger opening).',
      's4_step4_out':
          'Crane 2\'s beak has a wider angle of rotation to catch larger fish!',
      's4_hud1': 'Drag the measurer\'s vertex to Crane 1\'s beak.',
      's4_hud2': 'Drag the handle to match Crane 1\'s beak angle.',
      's4_hud3': 'Drag the locked measurer to Crane 2 to compare.',
      's4_hud4': 'Tap the crane with the wider beak angle.',

      's5_title': '5. The Swing to the Bell (Unsolved Challenge)',
      's5_obj':
          'To discover the relationship between a starting angle and a physical result in a dynamic environment.',
      's5_step1_task':
          'Your goal is to make the swing hit the LOW bell. DRAG the swing backwards to set a starting angle and then CLICK the \'Let Go!\' button.',
      's5_step1_out': 'The swing is in motion!',
      's5_step2_task':
          'That angle was too big/small! Try again. Adjust the starting angle until you hit the LOW bell.',
      's5_step2_out':
          'A small starting angle gives enough rotation to hit the low target.',
      's5_step3_task':
          'Great! Now find the correct starting angle to hit the MEDIUM bell. Then, find the angle needed to hit the HIGH bell.',
      's5_step3_out':
          'A larger rotation angle is needed to swing higher. Bigger angle = bigger result!',
      's5_hud1': 'Drag the swing seat back, then tap \'Let Go!\'.',
      's5_hud2': 'Adjust the angle until you hit the LOW bell.',
      's5_hud3': 'Find the angles for MEDIUM and HIGH bells.',
    },
    'hi': {
      'resetBtn': 'रीसेट',

      'appTitle': 'कोण निरीक्षक',
      'appSubtitle': 'कक्षा 6 गणित • रोटेशन की अवधारणा',
      'startLab': 'लैब शुरू करें',
      'zslLab': 'ZSL वर्चुअल लैब',
      'selectScenario': 'परिदृश्य चुनें',
      'learnLbl': 'उद्देश्य:',
      'stepLabel': 'चरण',
      'nextScenario': 'अगला परिदृश्य',
      'finishLab': 'समाप्त करें',
      'finalDesc':
          'आपने रोटेशन को मापकर कोणों की तुलना करना सफलतापूर्वक सीख लिया है!',

      'lbl_bigger': 'कोण A बड़ा है',
      'lbl_perfect_fit': 'परफेक्ट फिट!\nकोण बराबर हैं।',
      'lbl_s3_bigger':
          'कोण X बड़ा है।\nबांह की लंबाई से कोई फर्क नहीं पड़ता,\nकेवल घुमाव मायने रखता है!',
      'lbl_s3_extend': 'बाहें बढ़ाएं',
      'lbl_try_again': 'पुनः प्रयास करें!',
      'lbl_correct': 'सही!',
      'lbl_let_go': 'छोड़ दो!',
      'lbl_low_bell': 'नीची घंटी',
      'lbl_med_bell': 'मध्यम घंटी',
      'lbl_high_bell': 'ऊंची घंटी',

      's1_title': '1. पिज्जा स्लाइस स्वैप',
      's1_obj':
          'यह समझने के लिए कि एक कोण को दूसरे के ठीक ऊपर रखकर दो कोणों की तुलना कैसे करें।',
      's1_step1_task':
          'दाईं ओर पिज्जा का छोटा टुकड़ा (कोण B) है। इसे बड़े टुकड़े (कोण A) की ओर खींचें।',
      's1_step1_out':
          'बहुत बढ़िया! अब कोणों की तुलना करने के लिए उन्हें संरेखित करें।',
      's1_step2_task':
          'दोनों स्लाइस का निरीक्षण करें। ध्यान दें कि कोण A, कोण B से आगे तक कैसे फैला हुआ है।',
      's1_step2_out': 'चूंकि A का घुमाव बड़ा है, इसलिए कोण A बड़ा कोण है।',
      's1_hud1': 'छोटे स्लाइस (B) को बड़े स्लाइस (A) पर खींचें।',
      's1_hud2': 'कोणों में अंतर का निरीक्षण करें।',

      's2_title': '2. वॉल्ट कुंजी',
      's2_obj':
          'समझें कि किसी आकार में फिट होने के लिए कोण का सटीक आकार होना चाहिए।',
      's2_step1_task':
          'चाबी का कोण अभी बहुत छोटा है। इसे चौड़ा करने के लिए हैंडल को खींचें।',
      's2_step1_out':
          'रंगीन चाप बढ़ता हुआ कोण दिखाता है। यह घुमाव या रोटेशन है।',
      's2_step2_task':
          'अब चाबी को खींचकर दीवार के छेद में फिट करने का प्रयास करें।',
      's2_step2_out': 'यह फिट नहीं होता! गलत कोण के कारण चाबी टकराती है।',
      's2_step3_task':
          'कोण को तब तक समायोजित करें जब तक यह छेद से पूरी तरह मेल न खाए।',
      's2_step3_out': 'कोण अब बिल्कुल मेल खाते हैं।',
      's2_step4_task': 'चाबी को छेद में खींचें।',
      's2_step4_out':
          'एकदम सही फिट! कोण का आकार निर्धारित करता है कि यह फिट होगा या नहीं।',
      's2_hud1': 'चाबी को चौड़ा करने के लिए हैंडल को खींचें।',
      's2_hud2': 'चाबी को दीवार के छेद तक खींचें।',
      's2_hud3': 'छेद से मेल खाने तक कोण समायोजित करें।',
      's2_hud4': 'सटीक चाबी को छेद में सरकाएं।',

      's3_title': '3. भ्रामक बाहें',
      's3_obj': 'जानें कि कोण की बांहों की लंबाई कोण का आकार नहीं बदलती।',
      's3_step1_task':
          'कोण Y की बाहें लंबी हैं। क्या इससे यह बड़ा हो जाता है? कोण X को कोण Y पर खींचें।',
      's3_step1_out':
          'रोटेशन चाप देखें। छोटी बाहों के बावजूद कोण X का घुमाव चौड़ा है।',
      's3_step2_task': 'कोण X के लिए \'बाहें बढ़ाएं\' बटन पर टैप करें।',
      's3_step2_out':
          'बाहें लंबी हो गईं, लेकिन रंगीन रोटेशन चाप नहीं बदला! कोण वही है।',
      's3_hud1': 'शीर्ष पर कोण Y को ओवरलैप करने के लिए कोण X खींचें।',
      's3_hud2': 'देखने के लिए \'बाहें बढ़ाएं\' पर टैप करें।',

      's4_title': '4. क्रेन का लंच',
      's4_obj':
          'मापने वाले उपकरण का उपयोग करके वास्तविक दुनिया की वस्तुओं से कोणों की तुलना करने का कौशल लागू करें।',
      's4_step1_task':
          'कोण मापने वाले उपकरण को उसके केंद्र से खींचें और क्रेन 1 की चोंच पर रखें।',
      's4_step1_out': 'उपकरण स्थिति में है। अब हमें इसका आकार सेट करना होगा।',
      's4_step2_task':
          'क्रेन 1 की चोंच से पूरी तरह मेल खाने के लिए उपकरण की बांह को समायोजित करें।',
      's4_step2_out': 'उपकरण अब क्रेन 1 का सटीक कोण रखता है।',
      's4_step3_task': 'कोण बदले बिना, उपकरण को क्रेन 2 की चोंच पर खींचें।',
      's4_step3_out': 'क्रेन 2 की चोंच से उपकरण के कोण की तुलना करें।',
      's4_step4_task': 'उस क्रेन पर टैप करें जिसका कोण चौड़ा है।',
      's4_step4_out':
          'क्रेन 2 की चोंच में बड़ी मछलियों को पकड़ने के लिए एक चौड़ा कोण है!',
      's4_hud1': 'मापने वाले के शीर्ष को क्रेन 1 की चोंच पर खींचें।',
      's4_hud2': 'चोंच के कोण से मेल खाने के लिए हैंडल खींचें।',
      's4_hud3': 'तुलना करने के लिए लॉक किए गए उपकरण को क्रेन 2 पर ले जाएं।',
      's4_hud4': 'चौड़े कोण वाले क्रेन पर टैप करें।',

      's5_title': '5. द स्विंग टू द बेल (अनसुलझी चुनौती)',
      's5_obj':
          'एक गतिशील वातावरण में प्रारंभिक कोण और भौतिक परिणाम के बीच संबंध खोजना।',
      's5_step1_task':
          'आपका लक्ष्य स्विंग को नीची घंटी पर मारना है। प्रारंभिक कोण सेट करने के लिए स्विंग को पीछे खींचें और फिर \'छोड़ दो!\' बटन पर क्लिक करें।',
      's5_step1_out': 'स्विंग गति में है!',
      's5_step2_task':
          'वह कोण बहुत बड़ा/छोटा था! पुनः प्रयास करें। नीची घंटी को सफलतापूर्वक मारने तक प्रारंभिक कोण समायोजित करें।',
      's5_step2_out':
          'एक छोटा प्रारंभिक कोण निचले लक्ष्य को हिट करने के लिए पर्याप्त रोटेशन देता है।',
      's5_step3_task':
          'बहुत बढ़िया! अब मध्यम घंटी को मारने के लिए सही प्रारंभिक कोण खोजें। फिर, ऊंची घंटी को मारने के लिए आवश्यक कोण खोजें।',
      's5_step3_out':
          'ऊंची छलांग लगाने के लिए एक बड़ा रोटेशन कोण आवश्यक है। बड़ा कोण = बड़ा परिणाम!',
      's5_hud1': 'स्विंग को पीछे खींचें, फिर \'छोड़ दो!\' पर टैप करें।',
      's5_hud2':
          'नीची घंटी को सफलतापूर्वक मारने तक प्रारंभिक कोण समायोजित करें।',
      's5_hud3': 'मध्यम और ऊंची घंटी पर प्रहार करें।',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['en']?[key] ?? key;
  }
}

// --- SIMULATION STATE ---
class SimState {
  int scenario = 1;
  int step = 0;

  double zoom = 1.0;
  double panX = 0.0;
  double panY = 0.0;

  bool isAnimating = false;
  double animProgress = 0.0;
  String? activeDragEntity;
  double dragX = 0.0;
  double dragY = 0.0;

  // Scenario 1: Pizza
  double s1PizzaBX = 250;
  double s1PizzaBY = -50;
  bool s1IsSnapped = false;
  double s1AngleA = 70;
  double s1AngleB = 40;

  // Scenario 2: Key
  double s2KeyAngle = 20;
  double s2KeyX = -300;
  double s2KeyY = 50;
  double s2SlitAngle = 50;
  bool s2IsSnapped = false;
  double s2DoorX = 200;

  // Scenario 3: Arms
  double s3AngleXX = -200;
  double s3AngleXY = 100;
  double s3AngleXLen = 120;
  double s3AngleXAngle = 75;
  double s3AngleXExtLen = 120;

  double s3AngleYX = 200;
  double s3AngleYY = 100;
  double s3AngleYLen = 250;
  double s3AngleYAngle = 45;
  bool s3IsSnapped = false;
  bool s3ArmsExtended = false;

  // Scenario 4: Cranes
  double s4ToolX = 0;
  double s4ToolY = 200;
  double s4ToolAngle = 20;
  int s4IsSnappedTo = 0;
  double s4Crane1Angle = 30;
  double s4Crane2Angle = 55;
  int s4CraneSelected = 0;

  // Scenario 5: Swing
  double s5SwingAngle = 0;
  bool s5IsSwinging = false;
  double s5MaxAngle = 0;
  bool s5HitLow = false;
  bool s5HitMed = false;
  bool s5HitHigh = false;

  void resetScenario(int sc) {
    scenario = sc;
    step = 0;
    isAnimating = false;
    animProgress = 0.0;
    activeDragEntity = null;

    panX = 0;
    panY = 0;
    zoom = 1.0;

    if (sc == 1) {
      s1PizzaBX = 250;
      s1PizzaBY = 0;
      s1IsSnapped = false;
    } else if (sc == 2) {
      s2KeyAngle = 20;
      s2KeyX = -300;
      s2KeyY = 50;
      s2IsSnapped = false;
    } else if (sc == 3) {
      s3AngleXX = -250;
      s3AngleXY = 100;
      s3IsSnapped = false;
      s3ArmsExtended = false;
      s3AngleXLen = 120;
    } else if (sc == 4) {
      s4ToolX = 0;
      s4ToolY = 220;
      s4ToolAngle = 20;
      s4IsSnappedTo = 0;
      s4CraneSelected = 0;
    } else if (sc == 5) {
      s5SwingAngle = 0;
      s5IsSwinging = false;
      s5HitLow = false;
      s5HitMed = false;
      s5HitHigh = false;
    }
  }
}

// --- MAIN SCREEN ---
class Cl6M_Ch2_A3_TheAngleInspector extends StatefulWidget {
  const Cl6M_Ch2_A3_TheAngleInspector({super.key});

  @override
  State<Cl6M_Ch2_A3_TheAngleInspector> createState() =>
      _Cl6M_Ch2_A3_TheAngleInspectorState();
}

class _Cl6M_Ch2_A3_TheAngleInspectorState
    extends State<Cl6M_Ch2_A3_TheAngleInspector>
    with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  bool _showCurtain = true;
  bool _curtainVisible = true;
  String _lang = 'en';
  final SimState _sim = SimState();
  final GlobalKey _canvasKey = GlobalKey();

  late AnimationController _gameLoopController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Gesture state
  double _initialZoom = 1.0;
  Offset _initialPan = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _gameLoopController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 16), // ~60fps
        )..addListener(() {
          if (_sim.isAnimating) {
            _updatePhysics();
          }
          setState(() {}); // Trigger repaint
        });
    _gameLoopController.repeat();

    _sim.resetScenario(1);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gameLoopController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startLab() {
    _playSound('tick');
    setState(() {
      _curtainVisible = false;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showCurtain = false;
        });
      }
    });
  }

  void _playSound(String type) async {
    String url = '';
    switch (type) {
      case 'success':
        url = 'audio/class6/math/mixkit_2000.mp3';
        break;
      case 'error':
        url = 'audio/class6/math/mixkit_2954.mp3';
        break;
      case 'snap':
        url = 'audio/class6/math/click.mp3';
        break;
      case 'tick':
        url = 'audio/class6/math/click.mp3';
        break;
    }
    if (url.isNotEmpty) {
      try {
        // Prevent TimeoutExceptions by adding a 2 second timeout and catching any errors
        await _audioPlayer
            .play(AssetSource(url), volume: 0.5)
            .timeout(const Duration(seconds: 2));
      } catch (e) {
        debugPrint('Audio playback error ignored: $e');
      }
    }
  }

  void _updatePhysics() {
    if (_sim.scenario == 3 && _sim.isAnimating) {
      _sim.animProgress += 0.05;
      if (_sim.animProgress >= 1.0) {
        _sim.animProgress = 1.0;
        _sim.isAnimating = false;
        _sim.s3ArmsExtended = true;
        _advanceStep();
        Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
      }
    } else if (_sim.scenario == 5 && _sim.isAnimating) {
      _sim.animProgress += 0.008;
      if (_sim.animProgress >= 1.0) {
        _sim.animProgress = 1.0;
        _sim.isAnimating = false;
        _sim.s5IsSwinging = false;
        _sim.s5SwingAngle = 0;

        if (_sim.step == 0) {
          if (_sim.s5HitLow) {
            _sim.step = 2; // Hit low bell on first try, skip "try again" step
            setState(() {});
          } else {
            _advanceStep(); // Missed, go to "try again" step
          }
        } else if (_sim.step == 1) {
          if (_sim.s5HitLow) {
            _advanceStep(); // Hit on retry, move to Med/High step
          }
        } else if (_sim.step == 2) {
          if (_sim.s5HitMed && _sim.s5HitHigh) {
            _advanceStep();
            Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
          }
        }
      }
    }
  }

  void _advanceStep() {
    setState(() {
      _sim.step++;
    });
  }

  void _checkScenarioSuccess() {
    int maxSteps = _getMaxSteps(_sim.scenario);
    if (_sim.step >= maxSteps) {
      _sim.step = maxSteps;
      if (_sim.scenario == 5) {
        _playSound('success');
      }
      setState(() {});
    }
  }

  int _getMaxSteps(int scenario) {
    switch (scenario) {
      case 1:
        return 2;
      case 2:
        return 4;
      case 3:
        return 2;
      case 4:
        return 4;
      case 5:
        return 3;
      default:
        return 0;
    }
  }

  String t(String key) => Translations.get(_lang, key);

  Offset _screenToWorld(Offset localPos) {
    if (_canvasKey.currentContext == null) return Offset.zero;
    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    return Offset(
      (localPos.dx - size.width / 2 - _sim.panX) / _sim.zoom,
      (localPos.dy - size.height / 2 - _sim.panY) / _sim.zoom,
    );
  }

  bool _hitTestCircle(Offset worldPt, double cx, double cy, double r) {
    return (worldPt.dx - cx) * (worldPt.dx - cx) +
            (worldPt.dy - cy) * (worldPt.dy - cy) <=
        r * r;
  }

  bool _hitTestBox(Offset worldPt, double x, double y, double w, double h) {
    return worldPt.dx >= x &&
        worldPt.dx <= x + w &&
        worldPt.dy >= y &&
        worldPt.dy <= y + h;
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (_showCurtain) return;

    final Offset localPos = details.localFocalPoint;
    final Offset worldPt = _screenToWorld(localPos);

    _initialZoom = _sim.zoom;
    _initialPan = Offset(_sim.panX, _sim.panY);
    _initialFocalPoint = details.localFocalPoint;
    _sim.activeDragEntity = null;

    if (_sim.scenario == 1) {
      if (_sim.step == 0 && !_sim.s1IsSnapped) {
        if (_hitTestCircle(worldPt, _sim.s1PizzaBX, _sim.s1PizzaBY, 120)) {
          _sim.activeDragEntity = 's1_pizza';
          _sim.dragX = worldPt.dx;
          _sim.dragY = worldPt.dy;
          _playSound('tick');
        }
      }
    } else if (_sim.scenario == 2) {
      if (_sim.step == 0 || _sim.step == 2) {
        double armLen = 140;
        double hx =
            _sim.s2KeyX + (armLen - 20) * cos(-_sim.s2KeyAngle * pi / 180);
        double hy =
            _sim.s2KeyY + (armLen - 20) * sin(-_sim.s2KeyAngle * pi / 180);
        if (_hitTestCircle(worldPt, hx, hy, 40)) {
          _sim.activeDragEntity = 's2_handle';
          _playSound('tick');
        }
      }
      if ((_sim.step == 1 || _sim.step == 3) && !_sim.s2IsSnapped) {
        if (_hitTestBox(worldPt, _sim.s2KeyX - 20, _sim.s2KeyY - 40, 200, 80)) {
          _sim.activeDragEntity = 's2_keyBody';
          _sim.dragX = worldPt.dx;
          _sim.dragY = worldPt.dy;
          _playSound('tick');
        }
      }
    } else if (_sim.scenario == 3) {
      if (_sim.step == 0) {
        if (_hitTestCircle(worldPt, _sim.s3AngleXX, _sim.s3AngleXY, 80)) {
          _sim.activeDragEntity = 's3_angleX';
          _sim.dragX = worldPt.dx;
          _sim.dragY = worldPt.dy;
          _playSound('tick');
        }
      }
    } else if (_sim.scenario == 4) {
      if (_sim.step == 0 || _sim.step == 2) {
        if (_hitTestCircle(worldPt, _sim.s4ToolX, _sim.s4ToolY, 60)) {
          _sim.activeDragEntity = 's4_toolBody';
          _sim.dragX = worldPt.dx;
          _sim.dragY = worldPt.dy;
          _playSound('tick');
        }
      }
      if (_sim.step == 1 && _sim.s4IsSnappedTo == 1) {
        double len = 100;
        double hx = _sim.s4ToolX + len * cos(-_sim.s4ToolAngle * pi / 180);
        double hy = _sim.s4ToolY + len * sin(-_sim.s4ToolAngle * pi / 180);
        if (_hitTestCircle(worldPt, hx, hy, 40)) {
          _sim.activeDragEntity = 's4_toolHandle';
          _playSound('tick');
        }
      }
      if (_sim.step == 3) {
        if (_hitTestBox(worldPt, 20, -50, 200, 250)) {
          _sim.s4CraneSelected = 2;
          _playSound('success');
          _advanceStep();
          Future.delayed(const Duration(seconds: 1), _checkScenarioSuccess);
        } else if (_hitTestBox(worldPt, -320, -50, 200, 250)) {
          _sim.s4CraneSelected = 1;
          _playSound('error');
        }
      }
    } else if (_sim.scenario == 5) {
      if (!_sim.s5IsSwinging && !_sim.isAnimating) {
        double pivotX = 0, pivotY = -150;
        double len = 250;
        double sx = pivotX + len * cos((_sim.s5SwingAngle + 90) * pi / 180);
        double sy = pivotY + len * sin((_sim.s5SwingAngle + 90) * pi / 180);
        if (_hitTestCircle(worldPt, sx, sy, 60)) {
          _sim.activeDragEntity = 's5_seat';
          _playSound('tick');
        }
      }
    }
  }

  void _handleScaleUpdate(
    ScaleStartDetails? startDetails,
    ScaleUpdateDetails details,
  ) {
    if (_showCurtain) return;

    if (_sim.activeDragEntity != null) {
      final Offset worldPt = _screenToWorld(details.localFocalPoint);

      if (_sim.activeDragEntity == 's2_handle') {
        double angle =
            atan2(-(worldPt.dy - _sim.s2KeyY), worldPt.dx - _sim.s2KeyX) *
            180 /
            pi;
        if (angle < 0) angle += 360;
        _sim.s2KeyAngle = angle.clamp(10.0, 170.0);

        if (_sim.step == 0 && _sim.s2KeyAngle > 40) {
          _playSound('snap');
          _advanceStep();
        }
        if (_sim.step == 2 && (_sim.s2KeyAngle - _sim.s2SlitAngle).abs() < 3) {
          _sim.s2KeyAngle = _sim.s2SlitAngle;
          _playSound('snap');
          _advanceStep();
          _sim.activeDragEntity = null;
        }
      } else if (_sim.activeDragEntity == 's4_toolHandle') {
        double angle =
            atan2(-(worldPt.dy - _sim.s4ToolY), worldPt.dx - _sim.s4ToolX) *
            180 /
            pi;
        if (angle < 0) angle += 360;
        _sim.s4ToolAngle = angle.clamp(10.0, 100.0);

        if ((_sim.s4ToolAngle - _sim.s4Crane1Angle).abs() < 3) {
          _sim.s4ToolAngle = _sim.s4Crane1Angle;
          _playSound('snap');
          _advanceStep();
          _sim.activeDragEntity = null;
        }
      } else if (_sim.activeDragEntity == 's5_seat') {
        double pivotX = 0, pivotY = -150;
        double angle =
            atan2(worldPt.dy - pivotY, worldPt.dx - pivotX) * 180 / pi;
        angle = angle - 90;
        _sim.s5SwingAngle = max(-85, min(0, angle));
      } else {
        _sim.dragX = worldPt.dx;
        _sim.dragY = worldPt.dy;
      }
    } else {
      // Pan and Zoom
      _sim.zoom = (_initialZoom * details.scale).clamp(0.4, 3.0);
      _sim.panX =
          _initialPan.dx + (details.localFocalPoint.dx - _initialFocalPoint.dx);
      _sim.panY =
          _initialPan.dy + (details.localFocalPoint.dy - _initialFocalPoint.dy);
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_showCurtain) return;

    if (_sim.activeDragEntity != null) {
      if (_sim.activeDragEntity == 's1_pizza') {
        double dist = sqrt(
          pow(_sim.dragX - (-100), 2) + pow(_sim.dragY - 100, 2),
        );
        if (dist < 80) {
          _sim.s1PizzaBX = -100;
          _sim.s1PizzaBY = 100;
          _sim.s1IsSnapped = true;
          _playSound('snap');
          _advanceStep();

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && _sim.scenario == 1 && _sim.step == 1) {
              _advanceStep();
              _checkScenarioSuccess();
            }
          });
        } else {
          _sim.s1PizzaBX = _sim.dragX;
          _sim.s1PizzaBY = _sim.dragY;
        }
      } else if (_sim.activeDragEntity == 's2_keyBody') {
        _sim.s2KeyX = _sim.dragX;
        _sim.s2KeyY = _sim.dragY;
        double dist = sqrt(
          pow(_sim.s2KeyX - _sim.s2DoorX, 2) + pow(_sim.s2KeyY - 50, 2),
        );
        if (dist < 100) {
          if ((_sim.s2KeyAngle - _sim.s2SlitAngle).abs() < 3) {
            _sim.s2KeyX = _sim.s2DoorX;
            _sim.s2KeyY = 50;
            _sim.s2IsSnapped = true;
            _playSound('success');
            _advanceStep();
            Future.delayed(
              const Duration(milliseconds: 1500),
              _checkScenarioSuccess,
            );
          } else {
            _playSound('error');
            _sim.s2KeyX = -300;
            _sim.s2KeyY = 50;
            if (_sim.step == 1) _advanceStep();
          }
        }
      } else if (_sim.activeDragEntity == 's3_angleX') {
        double dist = sqrt(
          pow(_sim.dragX - _sim.s3AngleYX, 2) +
              pow(_sim.dragY - _sim.s3AngleYY, 2),
        );
        if (dist < 80) {
          _sim.s3AngleXX = _sim.s3AngleYX;
          _sim.s3AngleXY = _sim.s3AngleYY;
          _sim.s3IsSnapped = true;
          _playSound('snap');
          _advanceStep();
        } else {
          _sim.s3AngleXX = _sim.dragX;
          _sim.s3AngleXY = _sim.dragY;
        }
      } else if (_sim.activeDragEntity == 's4_toolBody') {
        _sim.s4ToolX = _sim.dragX;
        _sim.s4ToolY = _sim.dragY;
        if (_sim.step == 0) {
          double dist = sqrt(
            pow(_sim.dragX - (-195), 2) + pow(_sim.dragY - 32, 2),
          );
          if (dist < 60) {
            _sim.s4ToolX = -195;
            _sim.s4ToolY = 32;
            _sim.s4IsSnappedTo = 1;
            _playSound('snap');
            _advanceStep();
          }
        }
        if (_sim.step == 2) {
          double dist = sqrt(
            pow(_sim.dragX - 145, 2) + pow(_sim.dragY - 32, 2),
          );
          if (dist < 60) {
            _sim.s4ToolX = 145;
            _sim.s4ToolY = 32;
            _sim.s4IsSnappedTo = 2;
            _playSound('snap');
            _advanceStep();
          }
        }
      }
      _sim.activeDragEntity = null;
    }
  }

  void _triggerAction(String action) {
    if (action == 's3_extend') {
      _sim.isAnimating = true;
      _playSound('tick');
      _sim.animProgress = 0;
    } else if (action == 's5_letGo') {
      _sim.s5IsSwinging = true;
      _sim.s5MaxAngle = _sim.s5SwingAngle;
      _sim.isAnimating = true;
      _playSound('tick');
      _sim.animProgress = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    double sidebarWidth = max(300, MediaQuery.of(context).size.width * 0.3);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // CANVAS AREA
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onScaleStart: _handleScaleStart,
                onScaleUpdate: (details) => _handleScaleUpdate(null, details),
                onScaleEnd: _handleScaleEnd,
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Stack(
                    children: [
                      CustomPaint(
                        key: _canvasKey,
                        painter: LabPainter(
                          sim: _sim,
                          t: t,
                          onPlaySound: _playSound,
                        ),
                        child: Container(),
                      ),

                      // PILL-SHAPED HUD
                      if (_sim.step < _getMaxSteps(_sim.scenario))
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1E293B,
                                ).withOpacity(0.95),
                                borderRadius: BorderRadius.circular(
                                  30,
                                ), // Rounded pill style
                                border: Border.all(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withOpacity(0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF818CF8),
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    () {
                                      String text = t(
                                        's${_sim.scenario}_hud${_sim.step + 1}',
                                      );
                                      if (_sim.scenario == 5 &&
                                          _sim.step == 2) {
                                        if (_sim.s5HitMed && !_sim.s5HitHigh) {
                                          text += "\n (Medium ✓)";
                                        }
                                        if (!_sim.s5HitMed && _sim.s5HitHigh) {
                                          text += "\n (High ✓)";
                                        }
                                      }
                                      return text;
                                    }(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // ON-CANVAS BUTTONS (Extend Arms / Let Go) via LayoutBuilder for panning alignment
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double cx = constraints.maxWidth / 2 + _sim.panX;
                          double cy = constraints.maxHeight / 2 + _sim.panY;
                          return Stack(
                            children: [
                              if (_sim.scenario == 3 &&
                                  _sim.step == 1 &&
                                  _sim.s3IsSnapped)
                                Positioned(
                                  left: cx + 60 * _sim.zoom,
                                  top: cy + 220 * _sim.zoom,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _triggerAction('s3_extend'),
                                    child: Text(
                                      t('lbl_s3_extend'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              if (_sim.scenario == 5 &&
                                  !_sim.s5IsSwinging &&
                                  !_sim.isAnimating)
                                Positioned(
                                  left: cx - 70,
                                  top: cy + 190 * _sim.zoom,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () => _triggerAction('s5_letGo'),
                                    child: Text(
                                      t('lbl_let_go'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),

                      // SUCCESS OVERLAY
                      if (_sim.step >= _getMaxSteps(_sim.scenario))
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFF334155),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.greenAccent,
                                    size: 64,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _sim.scenario == 5
                                        ? t('finalDesc')
                                        : 'Goal Reached!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _sim.scenario == 5
                                          ? Colors.amber
                                          : const Color(0xFF6366F1),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () {
                                      _playSound('tick');
                                      if (_sim.scenario < 5) {
                                        setState(() {
                                          _sim.resetScenario(_sim.scenario + 1);
                                        });
                                      } else {
                                        setState(() {
                                          _sim.resetScenario(1);
                                        });
                                      }
                                    },
                                    icon: Icon(
                                      _sim.scenario == 5
                                          ? Icons.flag
                                          : Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      _sim.scenario == 5
                                          ? t('finishLab')
                                          : t('nextScenario'),
                                      style: const TextStyle(
                                        color: Colors.white,
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
                    ],
                  ),
                ),
              ),
            ),

            // FULLY SCROLLABLE SIDEBAR (Wrapped in Material to prevent Light-mode bleeding from Scaffold)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              top: 0,
              bottom: 0,
              child: Material(
                color: const Color(0xFF1E293B),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF334155)),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.change_history,
                                      color: Color(0xFF6366F1),
                                      size: 32,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t('appTitle'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          Text(
                                            t('appSubtitle'),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      icon: Row(
                                        children: [
                                          const Icon(
                                            Icons.language,
                                            color: Colors.white70,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _lang.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        _playSound('tick');
                                        setState(
                                          () => _lang = _lang == 'en'
                                              ? 'hi'
                                              : 'en',
                                        );
                                      },
                                      tooltip: 'Toggle Language',
                                    ),
                                    IconButton(
                                      icon: Row(
                                        children: [
                                          const Icon(
                                            Icons.refresh,
                                            color: Colors.redAccent,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            t('resetBtn'),
                                            style: const TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        _playSound('tick');
                                        setState(() {
                                          _sim.resetScenario(1);
                                          _showCurtain = true;
                                          _curtainVisible = true;
                                          _isSidebarOpen =
                                              true; // Optionally keeps sidebar open when curtain overlays
                                        });
                                      },
                                      tooltip: 'Reset Lab',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Main Content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t('selectScenario').toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
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
                                    border: Border.all(
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: _sim.scenario,
                                      isExpanded: true,
                                      dropdownColor: const Color(0xFF0F172A),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      items: [1, 2, 3, 4, 5].map((int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(t('s${value}_title')),
                                        );
                                      }).toList(),
                                      onChanged: (int? newValue) {
                                        if (newValue != null) {
                                          _playSound('tick');
                                          setState(() {
                                            _sim.resetScenario(newValue);
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Objective
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF334155,
                                    ).withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.track_changes,
                                            color: Colors.pinkAccent,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            t('learnLbl'),
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
                                        t('s${_sim.scenario}_obj'),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Steps
                                ...List.generate(_getMaxSteps(_sim.scenario), (
                                  index,
                                ) {
                                  bool isPast = index < _sim.step;
                                  bool isCurrent = index == _sim.step;

                                  Color bgColor = isCurrent
                                      ? const Color(0xFF6366F1).withOpacity(0.1)
                                      : (isPast
                                            ? const Color(
                                                0xFF10B981,
                                              ).withOpacity(0.1)
                                            : Colors.transparent);
                                  Color borderColor = isCurrent
                                      ? const Color(0xFF6366F1)
                                      : (isPast
                                            ? const Color(
                                                0xFF10B981,
                                              ).withOpacity(0.5)
                                            : const Color(0xFF334155));

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (isPast)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF10B981),
                                          )
                                        else
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: isCurrent
                                                  ? const Color(0xFF6366F1)
                                                  : const Color(0xFF334155),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
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
                                                '${t('stepLabel')} ${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                t(
                                                  's${_sim.scenario}_step${index + 1}_task',
                                                ),
                                                style: TextStyle(
                                                  color: isCurrent
                                                      ? Colors.white
                                                      : Colors.white70,
                                                  fontWeight: isCurrent
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                              if (isPast)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8.0,
                                                      ),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF10B981,
                                                      ).withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      t(
                                                        's${_sim.scenario}_step${index + 1}_out',
                                                      ),
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFFA7F3D0,
                                                        ),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Footer
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: const Color(0xFF0F172A),
                          child: const Text(
                            '© ZeroScienceLab - Fall in love with math and Science',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // FIXED MENU TOGGLE BUTTON (Moved outside so it doesn't slide)
            if (!_showCurtain)
              Positioned(
                left: 16,
                top: 16,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isSidebarOpen = !_isSidebarOpen;
                      });
                      _playSound('tick');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Icon(
                        _isSidebarOpen ? Icons.menu_open : Icons.menu,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),

            // CURTAIN INTRO SCREEN
            if (_showCurtain)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _curtainVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    color: const Color(0xFF0F172A),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.change_history,
                            size: 80,
                            color: Color(0xFF6366F1),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            t('zslLab'),
                            style: const TextStyle(
                              color: Color(0xFF818CF8),
                              fontSize: 16,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t('appTitle'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t('appSubtitle'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: const Color(
                                0xFF6366F1,
                              ).withOpacity(0.5),
                            ),
                            onPressed: _startLab,
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                            label: Text(
                              t('startLab'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
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
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER ---
class LabPainter extends CustomPainter {
  final SimState sim;
  final String Function(String) t;
  final void Function(String)? onPlaySound;

  LabPainter({required this.sim, required this.t, this.onPlaySound});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + sim.panX, size.height / 2 + sim.panY);
    canvas.scale(sim.zoom);

    if (sim.scenario == 1) {
      _renderS1(canvas);
    } else if (sim.scenario == 2)
      _renderS2(canvas);
    else if (sim.scenario == 3)
      _renderS3(canvas);
    else if (sim.scenario == 4)
      _renderS4(canvas);
    else if (sim.scenario == 5)
      _renderS5(canvas);

    canvas.restore();
  }

  // Generic shadow utility for rich 3D-like aesthetics
  void _drawShadow(
    Canvas canvas,
    Path path, {
    double dx = 0,
    double dy = 5,
    double blur = 10,
    Color color = Colors.black54,
  }) {
    canvas.drawPath(
      path.shift(Offset(dx, dy)),
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  void _renderS1(Canvas canvas) {
    _drawText(
      canvas,
      "Pizza A",
      -100,
      180,
      24,
      Colors.white,
      Colors.transparent,
    );
    _drawPizzaSlice(canvas, -100, 100, 240, sim.s1AngleA, false);

    if (sim.step >= 1 && sim.s1IsSnapped) {
      _drawAngleArc(
        canvas,
        -100,
        100,
        220,
        sim.s1AngleB,
        sim.s1AngleA,
        Colors.greenAccent,
        10,
      );
      _drawText(
        canvas,
        t('lbl_bigger'),
        -280,
        -30,
        20,
        Colors.greenAccent,
        const Color(0xFF0F172A),
      );
    }

    double bx = sim.s1PizzaBX;
    double by = sim.s1PizzaBY;

    if (sim.activeDragEntity == 's1_pizza') {
      bx = sim.dragX;
      by = sim.dragY;
      double dist = sqrt(pow(bx - (-100), 2) + pow(by - 100, 2));
      if (dist < 80) {
        _drawPizzaSlice(canvas, -100, 100, 200, sim.s1AngleB, true);
      }
    }

    canvas.save();
    canvas.translate(bx, by);
    _drawPizzaSlice(canvas, 0, 0, 200, sim.s1AngleB, false);
    if (!sim.s1IsSnapped) {
      _drawText(
        canvas,
        "Pizza B",
        120,
        -30,
        20,
        const Color(0xFF0F172A),
        Colors.white,
      );
    }
    canvas.restore();
  }

  void _renderS2(Canvas canvas) {
    bool isMatching = (sim.s2KeyAngle - sim.s2SlitAngle).abs() < 3;

    _drawVaultDoor(
      canvas,
      sim.s2DoorX,
      50,
      sim.s2SlitAngle,
      isMatching && sim.step >= 2,
    );

    double kx = sim.s2KeyX;
    double ky = sim.s2KeyY;
    if (sim.activeDragEntity == 's2_keyBody') {
      kx = sim.dragX;
      ky = sim.dragY;
    }

    _drawAngleArc(
      canvas,
      kx,
      ky,
      80,
      0,
      sim.s2KeyAngle,
      const Color(0xFF6366F1),
      12,
    );
    _drawBrassKey(canvas, kx, ky, sim.s2KeyAngle);

    if (sim.s2IsSnapped) {
      _drawRoundedRect(
        canvas,
        0,
        -180,
        250,
        70,
        10,
        Colors.green,
        const Color(0xFF0F172A),
        4,
      );
      _drawText(
        canvas,
        t('lbl_perfect_fit'),
        125,
        -145,
        18,
        Colors.white,
        Colors.transparent,
      );
    }
  }

  void _renderS3(Canvas canvas) {
    _drawMeccanoStrip(
      canvas,
      sim.s3AngleYX,
      sim.s3AngleYY,
      sim.s3AngleYLen,
      sim.s3AngleYAngle,
      Colors.blue,
    );
    _drawText(
      canvas,
      "Angle Y",
      sim.s3AngleYX + 120,
      sim.s3AngleYY + 40,
      20,
      Colors.white,
      Colors.transparent,
    );
    _drawAngleArc(
      canvas,
      sim.s3AngleYX,
      sim.s3AngleYY,
      60,
      0,
      sim.s3AngleYAngle,
      Colors.amber,
      8,
    );

    double xx = sim.s3AngleXX;
    double xy = sim.s3AngleXY;
    if (sim.activeDragEntity == 's3_angleX') {
      xx = sim.dragX;
      xy = sim.dragY;
    }

    double currLen = sim.s3ArmsExtended ? sim.s3AngleXExtLen : sim.s3AngleXLen;
    if (sim.isAnimating && sim.step == 1) {
      currLen = sim.s3AngleXLen + (180 * sim.animProgress);
    } else if (sim.step == 2) {
      currLen = 300;
    }

    _drawMeccanoStrip(canvas, xx, xy, currLen, sim.s3AngleXAngle, Colors.red);
    if (!sim.s3IsSnapped) {
      _drawText(
        canvas,
        "Angle X",
        xx + 60,
        xy + 40,
        20,
        Colors.redAccent,
        Colors.transparent,
      );
    }
    _drawAngleArc(
      canvas,
      xx,
      xy,
      80,
      0,
      sim.s3AngleXAngle,
      Colors.redAccent,
      10,
    );

    if (sim.s3IsSnapped && sim.step >= 1) {
      _drawAngleArc(
        canvas,
        sim.s3AngleYX,
        sim.s3AngleYY,
        80,
        sim.s3AngleYAngle,
        sim.s3AngleXAngle,
        Colors.greenAccent,
        12,
      );
      if (sim.step >= 2) {
        _drawRoundedRect(
          canvas,
          0,
          240,
          320,
          90,
          12,
          const Color(0xFFDCFCE7),
          const Color(0xFF166534),
          4,
        );
        _drawText(
          canvas,
          t('lbl_s3_bigger'),
          160,
          285,
          18,
          const Color(0xFF166534),
          Colors.transparent,
        );
      }
    }
  }

  void _renderS4(Canvas canvas) {
    Paint rippleP = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-220, 180), width: 200, height: 40),
      rippleP,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(120, 180), width: 200, height: 40),
      rippleP,
    );

    _drawCraneProfile(canvas, -220, 80, sim.s4Crane1Angle);
    _drawText(
      canvas,
      "Crane 1",
      -220,
      220,
      20,
      Colors.white,
      Colors.transparent,
    );

    _drawCraneProfile(canvas, 120, 80, sim.s4Crane2Angle);
    _drawText(
      canvas,
      "Crane 2",
      120,
      220,
      20,
      Colors.white,
      Colors.transparent,
    );

    double mx = sim.s4ToolX;
    double my = sim.s4ToolY;
    if (sim.activeDragEntity == 's4_toolBody') {
      mx = sim.dragX;
      my = sim.dragY;
    }

    bool isLocked = sim.step >= 2;
    _drawAngleMeasurer(canvas, mx, my, sim.s4ToolAngle, isLocked);

    if (sim.step == 3) {
      if (sim.s4CraneSelected == 2) {
        _drawRoundedRect(
          canvas,
          20,
          -50,
          200,
          250,
          20,
          Colors.transparent,
          Colors.greenAccent,
          8,
        );
        _drawText(
          canvas,
          t('lbl_correct'),
          120,
          -70,
          24,
          Colors.greenAccent,
          const Color(0xFF0F172A),
        );
      } else if (sim.s4CraneSelected == 1) {
        _drawRoundedRect(
          canvas,
          -320,
          -50,
          200,
          250,
          20,
          Colors.transparent,
          Colors.redAccent,
          8,
        );
        _drawText(
          canvas,
          t('lbl_try_again'),
          -220,
          -70,
          24,
          Colors.redAccent,
          const Color(0xFF0F172A),
        );
      }
    }
  }

  void _renderS5(Canvas canvas) {
    double pivotX = 0, pivotY = -150;

    bool lowHit =
        sim.s5HitLow ||
        (sim.step == 1 && sim.s5MaxAngle <= -20 && sim.s5MaxAngle > -35);
    bool medHit =
        sim.s5HitMed ||
        (sim.step == 2 && sim.s5MaxAngle <= -40 && sim.s5MaxAngle > -55);
    bool highHit = sim.s5HitHigh || (sim.step == 2 && sim.s5MaxAngle <= -60);

    double bx1 = pivotX + 270 * cos((-25 + 90) * pi / 180);
    double by1 = pivotY + 270 * sin((-25 + 90) * pi / 180);
    _drawShinyBell(canvas, bx1, by1, lowHit, t('lbl_low_bell'));

    double bx2 = pivotX + 270 * cos((-45 + 90) * pi / 180);
    double by2 = pivotY + 270 * sin((-45 + 90) * pi / 180);
    _drawShinyBell(canvas, bx2, by2, medHit, t('lbl_med_bell'));

    double bx3 = pivotX + 270 * cos((-65 + 90) * pi / 180);
    double by3 = pivotY + 270 * sin((-65 + 90) * pi / 180);
    _drawShinyBell(canvas, bx3, by3, highHit, t('lbl_high_bell'));

    double currAngle = sim.s5SwingAngle;
    if (sim.isAnimating) {
      double p = sim.animProgress;
      currAngle = sim.s5MaxAngle * cos(p * pi * 4) * (1 - p);

      if (sim.s5MaxAngle <= -20 && !sim.s5HitLow && currAngle >= -28) {
        sim.s5HitLow = true;
        onPlaySound?.call('success');
      }
      if (sim.s5MaxAngle <= -40 && !sim.s5HitMed && currAngle >= -48) {
        sim.s5HitMed = true;
        onPlaySound?.call('success');
      }
      if (sim.s5MaxAngle <= -60 && !sim.s5HitHigh && currAngle >= -68) {
        sim.s5HitHigh = true;
        onPlaySound?.call('success');
      }
    }

    _drawTreeSwing(canvas, pivotX, pivotY, currAngle);

    if (sim.step >= 1) {
      _drawRoundedRect(
        canvas,
        -420,
        -100,
        200,
        220,
        12,
        Colors.white,
        const Color(0xFF0F172A),
        4,
      );
      _drawText(
        canvas,
        "Records",
        -320,
        -60,
        20,
        const Color(0xFF0F172A),
        Colors.transparent,
      );
      _drawLine(canvas, -400, -35, -240, -35, const Color(0xFF94A3B8), 3);
      if (sim.s5HitLow) {
        _drawText(
          canvas,
          "Low: ~25° ✓",
          -320,
          0,
          18,
          Colors.green,
          Colors.transparent,
        );
      }
      if (sim.s5HitMed) {
        _drawText(
          canvas,
          "Med: ~45° ✓",
          -320,
          50,
          18,
          Colors.orange,
          Colors.transparent,
        );
      }
      if (sim.s5HitHigh) {
        _drawText(
          canvas,
          "High: ~65° ✓",
          -320,
          100,
          18,
          Colors.red,
          Colors.transparent,
        );
      }
    }
  }

  // --- DRAWING UTILS ---

  void _drawLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double width, {
    bool dashed = false,
  }) {
    Paint p = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (dashed) {
      double dx = x2 - x1;
      double dy = y2 - y1;
      double dist = sqrt(dx * dx + dy * dy);
      double dashLen = 8;
      for (double i = 0; i < dist; i += dashLen * 2) {
        canvas.drawLine(
          Offset(x1 + dx * (i / dist), y1 + dy * (i / dist)),
          Offset(
            x1 + dx * ((i + dashLen) / dist),
            y1 + dy * ((i + dashLen) / dist),
          ),
          p,
        );
      }
    } else {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), p);
    }
  }

  void _drawRoundedRect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color fill,
    Color stroke,
    double lineW,
  ) {
    RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(r),
    );
    if (fill != Colors.transparent) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = fill
          ..style = PaintingStyle.fill,
      );
    }
    if (stroke != Colors.transparent && lineW > 0) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineW,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    Color fillStyle,
    Color strokeStyle, {
    TextAlign align = TextAlign.center,
  }) {
    List<String> lines = text.split('\n');
    double startY = y - ((lines.length - 1) * fontSize * 1.2) / 2;

    for (int i = 0; i < lines.length; i++) {
      TextSpan span = TextSpan(
        style: TextStyle(
          color: fillStyle,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        text: lines[i],
      );
      TextPainter tp = TextPainter(
        text: span,
        textAlign: align,
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      if (strokeStyle != Colors.transparent) {
        TextPainter tpStroke = TextPainter(
          text: TextSpan(
            style: TextStyle(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3
                ..color = strokeStyle,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
            text: lines[i],
          ),
          textAlign: align,
          textDirection: TextDirection.ltr,
        );
        tpStroke.layout();
        tpStroke.paint(
          canvas,
          Offset(
            x - tpStroke.width / 2,
            startY + i * fontSize * 1.2 - tpStroke.height / 2,
          ),
        );
      }
      tp.paint(
        canvas,
        Offset(x - tp.width / 2, startY + i * fontSize * 1.2 - tp.height / 2),
      );
    }
  }

  void _drawAngleArc(
    Canvas canvas,
    double x,
    double y,
    double radius,
    double startAngleDeg,
    double endAngleDeg,
    Color color,
    double width,
  ) {
    Paint p1 = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width + 8
      ..strokeCap = StrokeCap.round;
    Paint p2 = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    double startRad = -startAngleDeg * pi / 180;
    double sweepRad = -(endAngleDeg - startAngleDeg) * pi / 180;

    Rect rect = Rect.fromCircle(center: Offset(x, y), radius: radius);
    canvas.drawArc(rect, startRad, sweepRad, false, p1);
    canvas.drawArc(rect, startRad, sweepRad, false, p2);
  }

  void _drawPizzaSlice(
    Canvas canvas,
    double x,
    double y,
    double radius,
    double angleDeg,
    bool isGhost,
  ) {
    canvas.save();
    canvas.translate(x, y);

    double angleRad = angleDeg * pi / 180;
    Path slicePath = Path()
      ..moveTo(0, 0)
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        0,
        -angleRad,
        false,
      )
      ..close();

    if (isGhost) {
      canvas.saveLayer(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        Paint()..color = Colors.white.withOpacity(0.4),
      );
    } else {
      _drawShadow(canvas, slicePath, dy: 6, blur: 12);
    }

    Paint cheesePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(radius, 0),
        [const Color(0xFFFEF08A), const Color(0xFFFDE047)],
        [0.0, 1.0],
      );
    canvas.drawPath(slicePath, cheesePaint);
    canvas.drawPath(
      slicePath,
      Paint()
        ..color = const Color(0xFFD97706)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Crust
    Path crustPath = Path()
      ..moveTo(radius * 0.85, 0)
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: radius * 0.85),
        0,
        -angleRad,
        false,
      )
      ..lineTo(radius * cos(-angleRad), radius * sin(-angleRad))
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        -angleRad,
        angleRad,
        false,
      )
      ..close();

    Paint crustPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset.zero,
        radius,
        [const Color(0xFFD97706), const Color(0xFFB45309)],
        [0.85, 1.0],
      );
    canvas.drawPath(crustPath, crustPaint);

    if (!isGhost) {
      Paint pepPaint = Paint()..color = const Color(0xFFDC2626);
      Paint pepStroke = Paint()
        ..color = const Color(0xFF991B1B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      void drawPep(double px, double py, double pr) {
        canvas.drawCircle(Offset(px, py), pr, pepPaint);
        canvas.drawCircle(Offset(px, py), pr, pepStroke);
      }

      drawPep(radius * 0.4, -radius * 0.15, 12);
      drawPep(radius * 0.65, -radius * 0.35, 10);
      drawPep(radius * 0.5, -radius * 0.7 * sin(angleRad / 2), 14);
    }

    // Vertex
    canvas.drawCircle(Offset.zero, 6, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset.zero,
      6,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    if (isGhost) canvas.restore();
    canvas.restore();
  }

  void _drawBrassKey(Canvas canvas, double x, double y, double angleDeg) {
    canvas.save();
    canvas.translate(x, y);

    double armLen = 140;
    double armWidth = 20;
    Color brassMain = const Color(0xFFF59E0B);
    Color brassDark = const Color(0xFFB45309);
    Color brassLight = const Color(0xFFFDE68A);

    void drawKeyArm(double len, bool hasTeeth) {
      Paint gradP = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, -armWidth / 2),
          Offset(0, armWidth / 2),
          [brassLight, brassMain, brassDark],
          [0.0, 0.5, 1.0],
        );

      Path armPath = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, -armWidth / 2, len, armWidth),
            Radius.circular(armWidth / 2),
          ),
        );

      if (hasTeeth) {
        Path teeth = Path()
          ..moveTo(len - 20, armWidth / 2)
          ..lineTo(len - 20, armWidth / 2 + 20)
          ..lineTo(len - 30, armWidth / 2 + 20)
          ..lineTo(len - 30, armWidth / 2 + 10)
          ..lineTo(len - 40, armWidth / 2 + 25)
          ..lineTo(len - 50, armWidth / 2 + 10)
          ..lineTo(len - 50, armWidth / 2)
          ..close();
        armPath.addPath(teeth, Offset.zero);
      }

      _drawShadow(canvas, armPath, dx: 0, dy: 4, blur: 8);

      canvas.drawPath(armPath, gradP);
      canvas.drawPath(
        armPath,
        Paint()
          ..color = const Color(0xFF451A03)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      Path bowPath = Path()
        ..addOval(Rect.fromCircle(center: Offset.zero, radius: 30));
      canvas.drawPath(bowPath, gradP);
      canvas.drawPath(
        bowPath,
        Paint()
          ..color = const Color(0xFF451A03)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      canvas.drawCircle(
        Offset.zero,
        15,
        Paint()..color = const Color(0xFF0F172A),
      );
    }

    drawKeyArm(armLen, true);

    canvas.save();
    canvas.rotate(-angleDeg * pi / 180);
    drawKeyArm(armLen - 20, false);

    // Interaction handle
    canvas.drawCircle(
      Offset(armLen - 20, 0),
      18,
      Paint()..color = Colors.yellow,
    );
    canvas.drawCircle(
      Offset(armLen - 20, 0),
      18,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.restore();

    canvas.drawCircle(Offset.zero, 8, Paint()..color = Colors.grey);

    canvas.restore();
  }

  void _drawVaultDoor(
    Canvas canvas,
    double x,
    double y,
    double angleDeg,
    bool isGlowing,
  ) {
    canvas.save();
    canvas.translate(x, y);

    Paint doorP = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(-150, -250),
        const Offset(150, 250),
        [const Color(0xFF94A3B8), const Color(0xFF334155)],
        [0.0, 1.0],
      );

    Path doorPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-100, -250, 300, 500),
          const Radius.circular(20),
        ),
      );
    _drawShadow(canvas, doorPath, dy: 10, blur: 20);
    canvas.drawPath(doorPath, doorP);
    canvas.drawPath(
      doorPath,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    _drawRoundedRect(
      canvas,
      -60,
      -150,
      220,
      300,
      100,
      const Color(0xFF475569),
      const Color(0xFF1E293B),
      4,
    );

    for (int i = 0; i < 6; i++) {
      double rx = 50 + 80 * cos(i * pi / 3);
      double ry = -50 + 120 * sin(i * pi / 3);
      canvas.drawCircle(
        Offset(rx, ry),
        6,
        Paint()..color = const Color(0xFFCBD5E1),
      );
    }

    double topX = 100 * cos(-angleDeg * pi / 180);
    double topY = 100 * sin(-angleDeg * pi / 180);

    Path hole = Path()
      ..moveTo(0, 0)
      ..lineTo(120, 0)
      ..lineTo(120, 25)
      ..lineTo(90, 25)
      ..lineTo(90, 40)
      ..lineTo(70, 40)
      ..lineTo(70, 25)
      ..lineTo(0, 25)
      ..lineTo(
        topX - 25 * sin(-angleDeg * pi / 180),
        topY - 25 * cos(-angleDeg * pi / 180),
      )
      ..lineTo(topX, topY)
      ..close();
    canvas.drawPath(hole, Paint()..color = const Color(0xFF0F172A));

    Paint strokeP = Paint()
      ..color = isGlowing ? Colors.greenAccent : const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isGlowing ? 6 : 4;

    if (isGlowing) {
      strokeP.maskFilter = const MaskFilter.blur(BlurStyle.solid, 10);
    }

    canvas.drawLine(Offset.zero, const Offset(120, 0), strokeP);
    canvas.drawLine(Offset.zero, Offset(topX, topY), strokeP);

    canvas.restore();
  }

  void _drawMeccanoStrip(
    Canvas canvas,
    double x,
    double y,
    double length,
    double angleDeg,
    MaterialColor color,
  ) {
    canvas.save();
    canvas.translate(x, y);

    Paint stripP = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, -15),
        const Offset(0, 15),
        [color.shade300, color.shade600, color.shade900],
        [0.0, 0.5, 1.0],
      );

    void drawArm() {
      Path armPath = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-15, -15, length + 30, 30),
            const Radius.circular(15),
          ),
        );
      _drawShadow(canvas, armPath);
      canvas.drawPath(armPath, stripP);
      canvas.drawPath(
        armPath,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      for (double hx = 20; hx <= length; hx += 25) {
        canvas.drawCircle(
          Offset(hx, 0),
          6,
          Paint()..color = const Color(0xFF0F172A),
        );
      }
    }

    drawArm();
    canvas.save();
    canvas.rotate(-angleDeg * pi / 180);
    drawArm();
    canvas.restore();

    canvas.drawCircle(Offset.zero, 10, Paint()..color = Colors.grey);
    canvas.drawCircle(Offset.zero, 4, Paint()..color = Colors.black);

    canvas.restore();
  }

  void _drawCraneProfile(Canvas canvas, double x, double y, double beakAngle) {
    canvas.save();
    canvas.translate(x, y);

    _drawLine(canvas, -10, 40, -15, 100, Colors.orange, 4);
    _drawLine(canvas, 10, 40, 5, 100, Colors.orange, 4);

    Path body = Path()
      ..moveTo(-15, 20)
      ..cubicTo(-35, 10, -25, -10, 0, -20)
      ..cubicTo(15, -30, 0, -50, 15, -60)
      ..cubicTo(25, -65, 35, -55, 30, -45)
      ..cubicTo(20, -35, 30, -10, 25, 0)
      ..cubicTo(20, 15, 5, 25, -15, 20)
      ..close();

    _drawShadow(canvas, body, dy: 6, blur: 12);
    canvas.drawPath(body, Paint()..color = Colors.white);
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    Path wing = Path()
      ..moveTo(5, -5)
      ..cubicTo(-15, 5, -20, 15, -5, 15)
      ..cubicTo(10, 15, 15, 5, 5, -5)
      ..close();
    canvas.drawPath(wing, Paint()..color = Colors.grey.shade300);
    canvas.drawPath(
      wing,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawCircle(
      const Offset(20, -52),
      2.5,
      Paint()..color = Colors.black,
    );

    double beakX = 25, beakY = -48;

    Path botBeak = Path()
      ..moveTo(beakX, beakY)
      ..lineTo(beakX + 40, beakY + 3)
      ..lineTo(beakX, beakY + 8)
      ..close();
    canvas.drawPath(botBeak, Paint()..color = Colors.yellow);
    canvas.drawPath(
      botBeak,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.save();
    canvas.translate(beakX, beakY);
    canvas.rotate(-beakAngle * pi / 180);
    Path topBeak = Path()
      ..moveTo(0, 0)
      ..lineTo(40, -3)
      ..lineTo(0, -8)
      ..close();
    canvas.drawPath(topBeak, Paint()..color = Colors.yellow);
    canvas.drawPath(
      topBeak,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();

    double fishY = beakAngle > 40 ? beakY - 15 : beakY - 30;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(beakX + 50, fishY), width: 20, height: 10),
      Paint()..color = Colors.deepOrange,
    );
    Path tail = Path()
      ..moveTo(beakX + 60, fishY)
      ..lineTo(beakX + 70, fishY - 5)
      ..lineTo(beakX + 70, fishY + 5)
      ..close();
    canvas.drawPath(tail, Paint()..color = Colors.deepOrange);

    canvas.restore();
  }

  void _drawAngleMeasurer(
    Canvas canvas,
    double x,
    double y,
    double angleDeg,
    bool isLocked,
  ) {
    canvas.save();
    canvas.translate(x, y);
    if (isLocked) {
      canvas.saveLayer(
        Rect.fromCircle(center: Offset.zero, radius: 120),
        Paint()..color = Colors.white.withOpacity(0.7),
      );
    }

    double len = 100;
    Path arcBody = Path()
      ..moveTo(0, 0)
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: 60),
        0,
        -angleDeg * pi / 180,
        false,
      )
      ..close();
    canvas.drawPath(
      arcBody,
      Paint()..color = Colors.lightBlue.withOpacity(0.3),
    );
    canvas.drawPath(
      arcBody,
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _drawRoundedRect(
      canvas,
      -10,
      -5,
      len + 20,
      10,
      5,
      Colors.lightBlue.withOpacity(0.6),
      Colors.blue,
      2,
    );
    canvas.save();
    canvas.rotate(-angleDeg * pi / 180);
    _drawRoundedRect(
      canvas,
      -10,
      -5,
      len + 20,
      10,
      5,
      Colors.lightBlue.withOpacity(0.6),
      Colors.blue,
      2,
    );
    canvas.restore();

    canvas.drawCircle(Offset.zero, 8, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset.zero,
      8,
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    if (!isLocked) {
      double hx = len * cos(-angleDeg * pi / 180);
      double hy = len * sin(-angleDeg * pi / 180);
      canvas.drawCircle(Offset(hx, hy), 12, Paint()..color = Colors.yellow);
      canvas.drawCircle(
        Offset(hx, hy),
        12,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (isLocked) canvas.restore();
    canvas.restore();
  }

  void _drawTreeSwing(
    Canvas canvas,
    double pivotX,
    double pivotY,
    double angleDeg,
  ) {
    double len = 250;
    double aRad = (angleDeg + 90) * pi / 180;
    double endX = pivotX + len * cos(aRad);
    double endY = pivotY + len * sin(aRad);

    _drawLine(
      canvas,
      pivotX - 150,
      pivotY - 20,
      pivotX + 150,
      pivotY,
      const Color(0xFF451A03),
      30,
    );
    _drawLine(
      canvas,
      pivotX - 80,
      pivotY - 15,
      pivotX - 20,
      pivotY - 60,
      const Color(0xFF451A03),
      15,
    );

    Paint leafP = Paint()..color = Colors.green.shade800;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pivotX - 50, pivotY - 70),
        width: 60,
        height: 30,
      ),
      leafP,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pivotX + 80, pivotY - 40),
        width: 80,
        height: 40,
      ),
      leafP,
    );

    _drawLine(
      canvas,
      pivotX,
      pivotY,
      pivotX,
      pivotY + len + 50,
      Colors.grey,
      3,
      dashed: true,
    );

    _drawLine(
      canvas,
      pivotX - 15,
      pivotY,
      endX - 15,
      endY,
      Colors.brown.shade300,
      4,
    );
    _drawLine(
      canvas,
      pivotX + 15,
      pivotY,
      endX + 15,
      endY,
      Colors.brown.shade300,
      4,
    );

    canvas.save();
    canvas.translate(endX, endY);
    canvas.rotate(aRad - pi / 2);
    _drawRoundedRect(
      canvas,
      -35,
      -8,
      70,
      16,
      4,
      Colors.brown,
      const Color(0xFF451A03),
      3,
    );
    canvas.restore();

    if (angleDeg < 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(pivotX, pivotY), radius: 80),
        pi / 2,
        angleDeg * pi / 180,
        false,
        Paint()
          ..color = const Color(0xFF6366F1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawShinyBell(
    Canvas canvas,
    double x,
    double y,
    bool isLit,
    String label,
  ) {
    canvas.save();
    canvas.translate(x, y);

    if (isLit) {
      canvas.drawCircle(
        Offset.zero,
        40,
        Paint()
          ..color = Colors.yellow
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );
    }

    Paint bellP = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(-20, 0),
        const Offset(20, 0),
        isLit
            ? [Colors.yellow.shade200, Colors.orange, Colors.deepOrange]
            : [
                Colors.grey.shade300,
                Colors.grey.shade500,
                Colors.grey.shade700,
              ],
        [0.0, 0.5, 1.0],
      );
    Path bellBody = Path()
      ..moveTo(-25, 20)
      ..quadraticBezierTo(-15, -30, 0, -35)
      ..quadraticBezierTo(15, -30, 25, 20)
      ..close();
    _drawShadow(canvas, bellBody, dy: 6, blur: 10);
    canvas.drawPath(bellBody, bellP);
    canvas.drawPath(
      bellBody,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.drawCircle(
      const Offset(0, 25),
      8,
      Paint()..color = isLit ? Colors.white : Colors.grey.shade700,
    );
    canvas.drawCircle(
      const Offset(0, -40),
      6,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    _drawText(canvas, label, 0, 50, 14, Colors.white, Colors.transparent);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
