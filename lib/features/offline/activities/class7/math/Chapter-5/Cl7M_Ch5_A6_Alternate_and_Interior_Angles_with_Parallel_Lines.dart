// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AlternateAnglesLab(),
    ),
  );
}

class AlternateAnglesLab extends StatefulWidget {
  const AlternateAnglesLab({super.key});

  @override
  State<AlternateAnglesLab> createState() => _AlternateAnglesLabState();
}

class _AlternateAnglesLabState extends State<AlternateAnglesLab>
    with SingleTickerProviderStateMixin {
  // Config & State
  bool isShutterOpen = true; // Controls the shutter screen
  bool isSidebarOpen = true;
  int scenario = 1;
  int step = 0;
  bool actionValidated = false;
  Set<int> completedScenarios = {};
  bool globalSuccessShown = false;
  String currentLang = 'en';

  // Audio Players
  static final AudioPlayer _clickPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _alertPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Audio URLs
  static const String _clickUrl =
      'audio/class7/mixkit_2568.mp3';
  static const String _successUrl =
      'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl =
      'audio/class7/mixkit_955.mp3';
  static const String _shutterUrl =
      'audio/class7/mixkit_2574.mp3';

  // Transforms
  double panX = 0;
  double panY = 0;
  double zoom = 1.0;
  double _baseZoom = 1.0;

  // Scenario 1
  bool s1Cloned = false;
  Offset s1WedgePos = const Offset(-105.03, -150);
  double s1WedgeRot = 0;
  bool s1WedgeDropped = false;
  bool s1WedgeAligned = false;

  // Scenario 2
  Offset s2WedgePos = const Offset(-86.6, -150);
  bool s2WedgeDropped = false;

  // Scenario 3
  double s3LTilt = -25;

  // Scenario 4
  bool s4BraceDropped = false;
  Offset s4BracePos = const Offset(350, 50);
  double s4BraceRot = 20;
  bool s4ProtDropped = false;
  Offset s4ProtPos = const Offset(350, 200);
  bool s4Checking = false;

  // Scenario 5
  bool s5PipeDropped = false;
  Offset s5PipePos = const Offset(250, -150);
  double s5PipeRot = -90;
  bool s5Checking = false;

  String activeDrag = '';
  Offset dragStartOffset = Offset.zero;

  // Themes / Colors
  final Color zslDark = const Color(0xff020617);
  final Color panelBg = const Color(0xff1e293b).withOpacity(0.9);
  final Color laserBlue = const Color(0xff3b82f6);
  final Color laserGreen = const Color(0xff22c55e);
  final Color laserRed = const Color(0xffef4444);
  final Color laserYellow = const Color(0xffeab308);
  final Color laserOrange = const Color(0xfff97316);

  // Translations Map
  final Map<String, Map<String, dynamic>> _t = {
    'en': {
      'title': "Alternate & Interior Angles",
      'subtitle': "Class 7 • PARALLEL AND INTERSECTING LINES",
      'enterLab': "Start Mission",
      'selectMission': "Select Mission",
      'objective': "Objective",
      'missionSteps': "Mission Steps",
      'missionCompleted': "Mission Completed!",
      'restartMission': "Restart Mission",
      'scen1Title': "1. The Angle Clone",
      's1Obj':
          "Visually discover and confirm that alternate interior angles are equal when lines are parallel.",
      's1h1': "CLICK the 'Clone Angle' button",
      's1t1': "Observe the parallel lines. Click the button to copy angle 'c'.",
      's1h2': "DRAG the cloned angle to 'e'",
      's1t2':
          "Move the clone to compare directly with alternate interior angle 'e'.",
      's1h3': "ROTATE the clone 180 degrees",
      's1t3': "Rotate the angle to see if it perfectly matches angle 'e'.",
      's1Sum':
          "Perfect fit! When lines are parallel, alternate interior angles are always equal.",
      'scen2Title': "2. The Straight Angle Puzzle",
      's2Obj':
          "Visually discover that consecutive interior angles add up to 180°.",
      's2h1': "DRAG the blue angle 'c' to 'f'",
      's2t1':
          "Observe interior angle 'c' (60°) and 'f' (120°). Move 'c' towards 'f'.",
      's2h2': "CONNECT the straight edges",
      's2t2':
          "Align their adjacent edges to combine the consecutive interior angles.",
      's2Sum':
          "They form a straight line! Interior angles on the same side always add up to 180°.",
      'scen3Title': "3. The Parallel Snap",
      's3Obj':
          "Understand the converse: if alternate interior angles are made equal, the lines become parallel.",
      's3h1': "DRAG the 'Rotate' handle",
      's3t1':
          "The lines are not parallel. Observe the top line's rotation handle.",
      's3h2': "ROTATE line until red matches blue (45°)",
      's3t2': "Make the alternate interior angles exactly equal.",
      's3Sum':
          "SNAP! By making alternate interior angles equal, the lines must be parallel.",
      'scen4Title': "4. The Bookshelf Builder",
      's4Obj':
          "Apply the property of alternate interior angles to build a stable bookshelf.",
      's4h1': "DRAG the unattached brace",
      's4t1': "A support brace is needed. Drag it into the empty space.",
      's4h2': "DRAG protractor and ROTATE brace",
      's4t2':
          "Use the protractor. Rotate brace to 50° to match alternate interior angle.",
      's4h3': "CLICK 'Install Brace'",
      's4t3': "Check if your perfectly aligned brace fits the shelves.",
      's4Sum':
          "Perfect fit! You used alternate interior angles to correctly align the parallel supports.",
      'scen5Title': "5. The Pipeline Planner",
      's5Obj':
          "Apply the property of supplementary interior angles to connect a pipeline.",
      's5h1': "DRAG the connector pipe",
      's5t1': "Drag the pipe from toolbox to the bottom pipeline joint.",
      's5h2': "ROTATE to set correct angle",
      's5t2':
          "Consecutive interior angles add to 180°. Top is 115°. Rotate to set 65°.",
      's5h3': "CLICK 'Weld Pipe'",
      's5t3': "Verify the alignment to weld the pipeline successfully.",
      's5Sum':
          "Perfect weld! You used supplementary interior angles (115° + 65° = 180°) to align pipes.",
      'geoMaster': "Geometry Master!",
      'geoMasterText':
          "You have successfully mastered alternate and consecutive interior angles with parallel lines!",
      'installBrace': "INSTALL BRACE",
      'weldPipe': "WELD PIPE",
    },
    'hi': {
      'title': "एकांतर और अंतः कोण",
      'subtitle': "कक्षा 7 • समांतर और प्रतिच्छेदी रेखाएं",
      'enterLab': "मिशन प्रारंभ करें",
      'selectMission': "मिशन चुनें",
      'objective': "उद्देश्य",
      'missionSteps': "मिशन के चरण",
      'missionCompleted': "मिशन पूरा हुआ!",
      'restartMission': "मिशन रीस्टार्ट",
      'scen1Title': "1. कोण क्लोन",
      's1Obj':
          "नेत्रहीन रूप से यह खोजना और पुष्टि करना कि जब रेखाएँ समानांतर होती हैं तो एकांतर अंतः कोण समान होते हैं।",
      's1h1': "'क्लोन एंगल' बटन पर क्लिक करें",
      's1t1':
          "समानांतर रेखाओं का निरीक्षण करें। कोण 'c' की प्रतिलिपि बनाने के लिए बटन पर क्लिक करें।",
      's1h2': "क्लोन किए गए कोण को 'e' पर खींचें",
      's1t2':
          "एकांतर अंतः कोण 'e' के साथ सीधे तुलना करने के लिए क्लोन को ले जाएं।",
      's1h3': "क्लोन को 180 डिग्री घुमाएं",
      's1t3':
          "यह देखने के लिए कोण को घुमाएं कि क्या यह पूरी तरह से कोण 'e' से मेल खाता है।",
      's1Sum':
          "बिल्कुल सही फिट! जब रेखाएँ समानांतर होती हैं, तो एकांतर अंतः कोण हमेशा समान होते हैं।",
      'scen2Title': "2. सरल कोण पहेली",
      's2Obj':
          "नेत्रहीन रूप से यह खोजना कि क्रमागत अंतः कोणों का योग 180° होता है।",
      's2h1': "नीले कोण 'c' को 'f' पर खींचें",
      's2t1':
          "अंतः कोण 'c' (60°) और 'f' (120°) का निरीक्षण करें। 'c' को 'f' की ओर ले जाएं।",
      's2h2': "सीधे किनारों को कनेक्ट करें",
      's2t2':
          "लगातार आंतरिक कोणों को संयोजित करने के लिए उनके आसन्न किनारों को संरेखित करें।",
      's2Sum':
          "वे एक सीधी रेखा बनाते हैं! एक ही तरफ के आंतरिक कोणों का योग हमेशा 180° होता है।",
      'scen3Title': "3. समांतर स्नैप",
      's3Obj':
          "विलोम को समझने के लिए: यदि एकांतर अंतः कोणों को समान बना दिया जाए, तो रेखाएँ समानांतर हो जाएँगी।",
      's3h1': "'रोटेट' हैंडल को खींचें",
      's3t1':
          "रेखाएँ समानांतर नहीं हैं। शीर्ष रेखा के घूर्णन हैंडल का निरीक्षण करें।",
      's3h2': "रेखा को घुमाएँ जब तक लाल नीले (45°) से मेल न खाए",
      's3t2': "एकांतर आंतरिक कोणों को बिल्कुल बराबर बनाएं।",
      's3Sum':
          "स्नैप! एकांतर अंतः कोणों को समान बनाने से, रेखाएँ समानांतर होनी चाहिए।",
      'scen4Title': "4. बुकशेल्फ़ बनाना",
      's4Obj':
          "एक स्थिर बुकशेल्फ़ बनाने के लिए एकांतर अंतः कोणों के गुण को लागू करें।",
      's4h1': "खुले ब्रेस को खींचें",
      's4t1': "एक समर्थन ब्रेस की आवश्यकता है। इसे खाली जगह में खींचें।",
      's4h2': "प्रोट्रैक्टर खींचें और ब्रेस घुमाएं",
      's4t2':
          "चांदा का प्रयोग करें। एकांतर आंतरिक कोण से मेल खाने के लिए ब्रेस को 50° तक घुमाएं।",
      's4h3': "'इंस्टॉल ब्रेस' पर क्लिक करें",
      's4t3':
          "जांचें कि क्या आपका पूरी तरह से संरेखित ब्रेस अलमारियों में फिट बैठता है।",
      's4Sum':
          "बिल्कुल सही फिट! आपने समानांतर समर्थन को सही ढंग से संरेखित करने के लिए एकांतर आंतरिक कोणों का उपयोग किया।",
      'scen5Title': "5. पाइपलाइन प्लानर",
      's5Obj':
          "पाइपलाइन को जोड़ने के लिए संपूरक अंतः कोणों के गुण को लागू करें।",
      's5h1': "कनेक्टर पाइप खींचें",
      's5t1': "पाइप को टूलबॉक्स से नीचे पाइपलाइन जोड़ तक खींचें।",
      's5h2': "सही कोण सेट करने के लिए घुमाएं",
      's5t2':
          "लगातार आंतरिक कोण 180° जोड़ते हैं। शीर्ष 115° है। 65° सेट करने के लिए घुमाएँ।",
      's5h3': "'वेल्ड पाइप' पर क्लिक करें",
      's5t3':
          "पाइपलाइन को सफलतापूर्वक वेल्ड करने के लिए संरेखण को सत्यापित करें।",
      's5Sum':
          "परफेक्ट वेल्ड! आपने पाइपों को संरेखित करने के लिए पूरक आंतरिक कोणों (115° + 65° = 180°) का उपयोग किया।",
      'geoMaster': "ज्यामिति मास्टर!",
      'geoMasterText':
          "आपने समांतर रेखाओं के साथ एकांतर और क्रमागत अंतः कोणों में महारत हासिल कर ली है!",
      'installBrace': "ब्रेस स्थापित करें",
      'weldPipe': "पाइप वेल्ड करें",
    },
  };

  String t(String key) {
    return _t[currentLang]?[key] ?? _t['en']?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
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
    super.dispose();
  }

  void _playSound(String url, AudioPlayer player) async {
    try {
      await player.stop();
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void loadScenario(int id) {
    _playSound(_shutterUrl, _alertPlayer);
    setState(() {
      scenario = id;
      step = 0;
      actionValidated = false;

      s1Cloned = false;
      s1WedgePos = const Offset(-105.03, -150);
      s1WedgeRot = 0;
      s1WedgeDropped = false;
      s1WedgeAligned = false;

      s2WedgePos = const Offset(-86.6, -150);
      s2WedgeDropped = false;

      s3LTilt = -25;

      s4BraceDropped = false;
      s4BracePos = const Offset(350, 50);
      s4BraceRot = 20;
      s4ProtDropped = false;
      s4ProtPos = const Offset(350, 200);
      s4Checking = false;

      s5PipeDropped = false;
      s5PipePos = const Offset(250, -150);
      s5PipeRot = -90;
      s5Checking = false;

      panX = 0;
      panY = 0;
      zoom = 1.0;
    });
  }

  void resetLab() {
    _playSound(_shutterUrl, _alertPlayer);
    setState(() {
      completedScenarios.clear();
      globalSuccessShown = false;
      currentLang = 'en';
      isShutterOpen = true; // Show shutter again
      loadScenario(1);
    });
  }

  void markStepComplete() {
    if (actionValidated) return;
    setState(() {
      actionValidated = true;
      _playSound(_successUrl, _successPlayer);
      HapticFeedback.heavyImpact();
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        actionValidated = false;
        step++;

        // Scenario ending logic
        if ((scenario == 1 && step >= 3) ||
            (scenario == 2 && step >= 2) ||
            (scenario == 3 && step >= 2) ||
            (scenario == 4 && step >= 3) ||
            (scenario == 5 && step >= 3)) {
          completedScenarios.add(scenario);
          if (completedScenarios.length >= 5 && !globalSuccessShown) {
            globalSuccessShown = true;
            _playSound(_successUrl, _successPlayer);
          }
        }
      });
    });
  }

  Offset screenToLogical(Offset screenPos, Size canvasSize) {
    double scale =
        math.min(canvasSize.width, canvasSize.height) / 1000.0 * zoom;
    double cx = canvasSize.width / 2 + panX;
    double cy = canvasSize.height / 2 + panY;
    return Offset((screenPos.dx - cx) / scale, (screenPos.dy - cy) / scale);
  }

  // Explicit Tap Down handler catches clicks efficiently before dragging scales
  void handleTapDown(TapDownDetails details, Size canvasSize) {
    if (actionValidated) return;
    Offset pt = screenToLogical(details.localPosition, canvasSize);

    if (scenario == 1 && step == 0 && !s1Cloned) {
      if ((pt - const Offset(-40, -95)).distance < 80) {
        setState(() => s1Cloned = true);
        _playSound(_clickUrl, _clickPlayer);
        HapticFeedback.lightImpact();
        markStepComplete();
        return;
      }
    }

    if (scenario == 4 && step == 2 && s4ProtDropped && !s4Checking) {
      Rect btnRect = Rect.fromCenter(
        center: const Offset(-350, 300),
        width: 280,
        height: 100,
      );
      if (btnRect.contains(pt)) {
        _playSound(_clickUrl, _clickPlayer);
        checkS4Alignment();
        return;
      }
    }

    if (scenario == 5 && step == 2 && s5PipeDropped && !s5Checking) {
      Rect btnRect = Rect.fromCenter(
        center: const Offset(-350, 300),
        width: 280,
        height: 100,
      );
      if (btnRect.contains(pt)) {
        _playSound(_clickUrl, _clickPlayer);
        checkS5Alignment();
        return;
      }
    }
  }

  void handleScaleStart(ScaleStartDetails details, Size canvasSize) {
    if (actionValidated) return;
    _baseZoom = zoom;
    Offset pt = screenToLogical(details.localFocalPoint, canvasSize);

    bool hitElement = false;

    if (scenario == 1) {
      if (step == 1 && s1Cloned && !s1WedgeDropped) {
        Offset center = s1WedgePos + const Offset(45, 30);
        if ((pt - center).distance < 80) {
          activeDrag = 's1_drag';
          dragStartOffset = pt - s1WedgePos;
          hitElement = true;
        }
      }
      if (step == 2 && s1WedgeDropped && !s1WedgeAligned) {
        double hRad = (27.5 + s1WedgeRot) * math.pi / 180;
        Offset handlePt =
            const Offset(105.03, 150) +
            Offset(100 * math.cos(hRad), 100 * math.sin(hRad));
        if ((pt - handlePt).distance < 60) {
          activeDrag = 's1_rot';
          hitElement = true;
        }
      }
    } else if (scenario == 2) {
      if (step <= 1 && !s2WedgeDropped) {
        Offset center = s2WedgePos + const Offset(40, 35);
        if ((pt - center).distance < 80) {
          activeDrag = 's2_drag';
          dragStartOffset = pt - s2WedgePos;
          hitElement = true;
        }
      }
    } else if (scenario == 3) {
      if (!actionValidated && s3LTilt.abs() >= 1) {
        double hRad = s3LTilt * math.pi / 180;
        Offset handlePt =
            const Offset(-150, -150) +
            Offset(600 * math.cos(hRad), 600 * math.sin(hRad));
        if ((pt - handlePt).distance < 80) {
          activeDrag = 's3_rot';
          hitElement = true;
        }
      }
    } else if (scenario == 4) {
      if (step == 0 && !s4BraceDropped) {
        Offset center = s4BracePos + const Offset(150, 0);
        if ((pt - center).distance < 180) {
          activeDrag = 's4_brace_drag';
          dragStartOffset = pt - s4BracePos;
          hitElement = true;
        }
      }
      if (step == 1 && s4BraceDropped && !s4ProtDropped) {
        if ((pt - (s4ProtPos + const Offset(0, -60))).distance < 100) {
          activeDrag = 's4_prot_drag';
          dragStartOffset = pt - s4ProtPos;
          hitElement = true;
        }
      }
      if (step == 2 && s4ProtDropped && !s4Checking) {
        double rRad = s4BraceRot * math.pi / 180;
        Offset hPt =
            const Offset(100, -100) +
            Offset(180 * math.cos(rRad), 180 * math.sin(rRad));
        if ((pt - hPt).distance < 60) {
          activeDrag = 's4_brace_rot';
          hitElement = true;
        }
      }
    } else if (scenario == 5) {
      if (step == 0 && !s5PipeDropped) {
        Offset mid =
            s5PipePos +
            Offset(
              165 * math.cos(s5PipeRot * math.pi / 180),
              165 * math.sin(s5PipeRot * math.pi / 180),
            );
        if ((pt - mid).distance < 180) {
          activeDrag = 's5_pipe_drag';
          dragStartOffset = pt - s5PipePos;
          hitElement = true;
        }
      }
      if (step >= 1 && s5PipeDropped && !s5Checking) {
        double rRad = s5PipeRot * math.pi / 180;
        Offset hPt =
            const Offset(-100, 150) +
            Offset(331 * math.cos(rRad), 331 * math.sin(rRad));
        if ((pt - hPt).distance < 70) {
          activeDrag = 's5_pipe_rot';
          hitElement = true;
        }
      }
    }

    if (!hitElement) {
      activeDrag = 'canvas';
    }
  }

  void handleScaleUpdate(ScaleUpdateDetails details, Size canvasSize) {
    if (activeDrag.isEmpty) return;

    if (activeDrag == 'canvas') {
      setState(() {
        panX += details.focalPointDelta.dx;
        panY += details.focalPointDelta.dy;
        if (details.scale != 1.0) zoom = _baseZoom * details.scale;
      });
      return;
    }

    Offset pt = screenToLogical(details.localFocalPoint, canvasSize);

    setState(() {
      switch (activeDrag) {
        case 's1_drag':
          s1WedgePos = pt - dragStartOffset;
          break;
        case 's1_rot':
          double angleDeg =
              math.atan2(pt.dy - 150, pt.dx - 105.03) * 180 / math.pi;
          double rot = angleDeg - 27.5;
          while (rot < 0) {
            rot += 360;
          }
          while (rot >= 360) {
            rot -= 360;
          }
          if ((rot - 180).abs() < 15) rot = 180;
          s1WedgeRot = rot;
          if (step == 2 && rot == 180) {
            s1WedgeAligned = true;
            activeDrag = '';
            markStepComplete();
          }
          break;
        case 's2_drag':
          s2WedgePos = pt - dragStartOffset;
          if (step == 0) {
            step = 1;
            _playSound(_clickUrl, _clickPlayer);
            HapticFeedback.selectionClick();
          }
          break;
        case 's3_rot':
          double angleDeg =
              math.atan2(pt.dy + 150, pt.dx + 150) * 180 / math.pi;
          if (angleDeg > 20) angleDeg = 20;
          if (angleDeg < -40) angleDeg = -40;
          bool isPar = false;
          if (angleDeg.abs() < 2) {
            angleDeg = 0;
            isPar = true;
          }

          if (s3LTilt != angleDeg) {
            s3LTilt = angleDeg;
            if (step == 0) {
              step = 1;
              _playSound(_clickUrl, _clickPlayer);
              HapticFeedback.selectionClick();
            }
            if (step == 1 && isPar) {
              activeDrag = '';
              markStepComplete();
            }
          }
          break;
        case 's4_brace_drag':
          s4BracePos = pt - dragStartOffset;
          break;
        case 's4_prot_drag':
          s4ProtPos = pt - dragStartOffset;
          break;
        case 's4_brace_rot':
          double angleDeg =
              math.atan2(pt.dy + 100, pt.dx - 100) * 180 / math.pi;
          if (angleDeg < 20) angleDeg = 20;
          if (angleDeg > 80) angleDeg = 80;
          // Snaps perfectly to 50 when you get close
          if ((angleDeg - 50).abs() < 4) angleDeg = 50;
          s4BraceRot = angleDeg;
          break;
        case 's5_pipe_drag':
          s5PipePos = pt - dragStartOffset;
          break;
        case 's5_pipe_rot':
          double angleDeg =
              math.atan2(pt.dy - 150, pt.dx + 100) * 180 / math.pi;
          if (angleDeg > -10) angleDeg = -10;
          if (angleDeg < -120) angleDeg = -120;
          // Snaps perfectly to -65 when you get close
          if ((angleDeg - (-65)).abs() < 4) angleDeg = -65;
          s5PipeRot = angleDeg;
          if (step == 1) {
            step = 2;
            _playSound(_clickUrl, _clickPlayer);
            HapticFeedback.selectionClick();
          }
          break;
      }
    });
  }

  void handleScaleEnd(ScaleEndDetails details) {
    if (activeDrag.isEmpty || activeDrag == 'canvas') {
      activeDrag = '';
      return;
    }

    setState(() {
      if (activeDrag == 's1_drag') {
        if ((s1WedgePos - const Offset(105.03, 150)).distance < 150) {
          s1WedgeDropped = true;
          markStepComplete();
        } else {
          s1WedgePos = const Offset(-105.03, -150);
          _playSound(_errorUrl, _errorPlayer);
        }
      } else if (activeDrag == 's2_drag') {
        if ((s2WedgePos - const Offset(86.6, 150)).distance < 150) {
          s2WedgeDropped = true;
          markStepComplete();
        } else {
          s2WedgePos = const Offset(-86.6, -150);
          _playSound(_errorUrl, _errorPlayer);
        }
      } else if (activeDrag == 's4_brace_drag') {
        if (s4BracePos.dx < 250) {
          s4BraceDropped = true;
          markStepComplete();
        } else {
          s4BracePos = const Offset(350, 50);
          _playSound(_errorUrl, _errorPlayer);
        }
      } else if (activeDrag == 's4_prot_drag') {
        if ((s4ProtPos - const Offset(100, -100)).distance < 150) {
          s4ProtDropped = true;
          markStepComplete();
        } else {
          s4ProtPos = const Offset(350, 200);
          _playSound(_errorUrl, _errorPlayer);
        }
      } else if (activeDrag == 's5_pipe_drag') {
        if ((s5PipePos - const Offset(-100, 150)).distance < 180) {
          s5PipeDropped = true;
          markStepComplete();
        } else {
          s5PipePos = const Offset(250, -150);
          _playSound(_errorUrl, _errorPlayer);
        }
      }
      activeDrag = '';
    });
  }

  void checkS4Alignment() {
    if (scenario != 4 || step != 2 || actionValidated || s4Checking) return;
    setState(() => s4Checking = true);

    // Increased tolerance for a guaranteed trigger
    if ((s4BraceRot - 50).abs() < 4) {
      setState(() => s4BraceRot = 50);
      markStepComplete();
    } else {
      _playSound(_errorUrl, _errorPlayer);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => s4Checking = false);
      });
    }
  }

  void checkS5Alignment() {
    if (scenario != 5 || step != 2 || actionValidated || s5Checking) return;
    setState(() => s5Checking = true);

    // Increased tolerance for a guaranteed trigger
    if ((s5PipeRot - (-65)).abs() < 4) {
      setState(() => s5PipeRot = -65);
      markStepComplete();
    } else {
      _playSound(_errorUrl, _errorPlayer);
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) setState(() => s5Checking = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // Sidebar adjusted to 38%
    double sidebarWidth = math.min(screenWidth * 0.38, 450.0);
    if (sidebarWidth < 300) sidebarWidth = 300;

    return Scaffold(
      backgroundColor: zslDark,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap:
            () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // Canvas Area
            Positioned.fill(
              left: isSidebarOpen ? sidebarWidth : 0,
              child: ClipRect(
                child: GestureDetector(
                  onTapDown:
                      (details) => handleTapDown(
                        details,
                        Size(
                          screenWidth - (isSidebarOpen ? sidebarWidth : 0),
                          MediaQuery.of(context).size.height,
                        ),
                      ),
                  onScaleStart:
                      (details) => handleScaleStart(
                        details,
                        Size(
                          screenWidth - (isSidebarOpen ? sidebarWidth : 0),
                          MediaQuery.of(context).size.height,
                        ),
                      ),
                  onScaleUpdate:
                      (details) => handleScaleUpdate(
                        details,
                        Size(
                          screenWidth - (isSidebarOpen ? sidebarWidth : 0),
                          MediaQuery.of(context).size.height,
                        ),
                      ),
                  onScaleEnd: handleScaleEnd,
                  child: Container(
                    color: const Color(0xff040816),
                    child: CustomPaint(
                      painter: AnglesCanvasPainter(
                        scenario: scenario,
                        step: step,
                        zoom: zoom,
                        panX: panX,
                        panY: panY,
                        s1Cloned: s1Cloned,
                        s1WedgePos: s1WedgePos,
                        s1WedgeRot: s1WedgeRot,
                        s1WedgeDropped: s1WedgeDropped,
                        s1WedgeAligned: s1WedgeAligned,
                        s2WedgePos: s2WedgePos,
                        s2WedgeDropped: s2WedgeDropped,
                        s3LTilt: s3LTilt,
                        s4BraceDropped: s4BraceDropped,
                        s4BracePos: s4BracePos,
                        s4BraceRot: s4BraceRot,
                        s4ProtDropped: s4ProtDropped,
                        s4ProtPos: s4ProtPos,
                        s4Checking: s4Checking,
                        s5PipeDropped: s5PipeDropped,
                        s5PipePos: s5PipePos,
                        s5PipeRot: s5PipeRot,
                        s5Checking: s5Checking,
                        actionValidated: actionValidated,
                        installBraceText: t('installBrace'),
                        weldPipeText: t('weldPipe'),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Floating Active Step Card (when sidebar is closed)
            if (!isSidebarOpen)
              Positioned(
                left: 16,
                top: 80,
                width: 280,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: panelBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: laserBlue.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.assistant_navigation,
                              color: laserBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${t('missionSteps')} - ${step + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getActiveStepHudText(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: _buildSidebar(),
            ),

            // Top-Left Front Control (Menu Toggle ONLY)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(
                  isSidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                  size: 28,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: panelBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed:
                    () => setState(() {
                      isSidebarOpen = !isSidebarOpen;
                      _playSound(_clickUrl, _clickPlayer);
                    }),
              ),
            ),

            // Global Success Modal
            if (globalSuccessShown)
              Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      Container(
                        width: 450,
                        padding: const EdgeInsets.all(32),
                        margin: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: panelBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: laserBlue, width: 2),
                        ),
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
                              t('geoMaster'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              t('geoMasterText'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: Text(t('restartMission')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: laserBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: resetLab,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 32,
                        top: 32,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white54,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() => globalSuccessShown = false);
                            _playSound(_clickUrl, _clickPlayer);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Shutter Curtain Overlay (Topmost)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: isShutterOpen ? 0 : -MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: _buildShutterScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShutterScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: zslDark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: laserBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: laserBlue.withOpacity(0.6), blurRadius: 40),
              ],
            ),
            child: const Icon(
              Icons.architecture,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            t('title'),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            t('subtitle'),
            style: const TextStyle(fontSize: 18, color: Colors.white54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () {
              _playSound(_successUrl, _successPlayer);
              setState(() {
                isShutterOpen = false;
              });
            },
            icon: const Icon(Icons.power_settings_new),
            label: Text(t('enterLab')),
            style: ElevatedButton.styleFrom(
              backgroundColor: laserBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 10,
              shadowColor: laserBlue.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: panelBg,
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 32,
          left: 24,
          right: 24,
          bottom: 32,
        ), // Completely scrollable from top to bottom
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Subtitle in Sidebar
            Row(
              children: [
                Icon(Icons.architecture, color: laserBlue, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('title'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        t('subtitle'),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Language Toggle & Reset Control Row
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _playSound(_clickUrl, _clickPlayer);
                      setState(() {
                        if (currentLang == 'en') {
                          currentLang = 'hi';
                        } else {
                          currentLang = 'en';
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.language,
                            color: Colors.white54,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currentLang.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.restart_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    tooltip: 'Reset',
                    onPressed: resetLab,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              t('selectMission'),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: zslDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: scenario,
                  isExpanded: true,
                  dropdownColor: zslDark,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  items: [
                    DropdownMenuItem(value: 1, child: Text(t('scen1Title'))),
                    DropdownMenuItem(value: 2, child: Text(t('scen2Title'))),
                    DropdownMenuItem(value: 3, child: Text(t('scen3Title'))),
                    DropdownMenuItem(value: 4, child: Text(t('scen4Title'))),
                    DropdownMenuItem(value: 5, child: Text(t('scen5Title'))),
                  ],
                  onChanged: (val) {
                    if (val != null) loadScenario(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Objective Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.track_changes, color: laserBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        t('objective'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getObjectiveText(scenario),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                const Icon(
                  Icons.format_list_numbered,
                  color: Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  t('missionSteps'),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ..._buildStepsList(),

            if (step >= _getStepsCount(scenario))
              Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: laserGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: laserGreen.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: laserGreen, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      t('missionCompleted'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getSummaryText(scenario),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Sidebar Footer (Inside scroll)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: const Text(
                "© ZEROSCIENCELAB | Fall in Love with Math and Science",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getActiveStepHudText() {
    List<Map<String, String>> steps = _getStepsForScenario(scenario);
    if (step < steps.length) {
      return steps[step]['hud']!;
    }
    return t('missionCompleted');
  }

  String _getObjectiveText(int scen) => t('s${scen}Obj');

  int _getStepsCount(int scen) {
    switch (scen) {
      case 1:
        return 3;
      case 2:
        return 2;
      case 3:
        return 2;
      case 4:
        return 3;
      case 5:
        return 3;
      default:
        return 0;
    }
  }

  List<Map<String, String>> _getStepsForScenario(int scen) {
    List<Map<String, String>> s = [];
    int count = _getStepsCount(scen);
    for (int i = 1; i <= count; i++) {
      s.add({"hud": t("s${scen}h$i"), "txt": t("s${scen}t$i")});
    }
    return s;
  }

  String _getSummaryText(int scen) => t('s${scen}Sum');

  List<Widget> _buildStepsList() {
    List<Map<String, String>> stepsData = _getStepsForScenario(scenario);
    List<Widget> children = [];

    for (int i = 0; i < stepsData.length; i++) {
      bool isPast = i < step;
      bool isActive = i == step;

      Color bgColor =
          isActive
              ? laserBlue.withOpacity(0.2)
              : (isPast ? Colors.white.withOpacity(0.05) : Colors.transparent);
      Color borderColor = isActive ? laserBlue : Colors.white.withOpacity(0.1);
      Color textColor =
          isPast ? Colors.white54 : (isActive ? Colors.white : Colors.white38);

      children.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isPast
                  ? Icon(Icons.check_circle, color: laserGreen, size: 28)
                  : Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive ? laserBlue : Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${i + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stepsData[i]['hud']!,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: isPast ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stepsData[i]['txt']!,
                      style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontSize: 13,
                        height: 1.4,
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
    return children;
  }
}

class AnglesCanvasPainter extends CustomPainter {
  final int scenario;
  final int step;
  final double zoom;
  final double panX;
  final double panY;
  final bool actionValidated;

  final bool s1Cloned;
  final Offset s1WedgePos;
  final double s1WedgeRot;
  final bool s1WedgeDropped;
  final bool s1WedgeAligned;

  final Offset s2WedgePos;
  final bool s2WedgeDropped;

  final double s3LTilt;

  final bool s4BraceDropped;
  final Offset s4BracePos;
  final double s4BraceRot;
  final bool s4ProtDropped;
  final Offset s4ProtPos;
  final bool s4Checking;

  final bool s5PipeDropped;
  final Offset s5PipePos;
  final double s5PipeRot;
  final bool s5Checking;

  final String installBraceText;
  final String weldPipeText;

  AnglesCanvasPainter({
    required this.scenario,
    required this.step,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.s1Cloned,
    required this.s1WedgePos,
    required this.s1WedgeRot,
    required this.s1WedgeDropped,
    required this.s1WedgeAligned,
    required this.s2WedgePos,
    required this.s2WedgeDropped,
    required this.s3LTilt,
    required this.s4BraceDropped,
    required this.s4BracePos,
    required this.s4BraceRot,
    required this.s4ProtDropped,
    required this.s4ProtPos,
    required this.s4Checking,
    required this.s5PipeDropped,
    required this.s5PipePos,
    required this.s5PipeRot,
    required this.s5Checking,
    required this.actionValidated,
    required this.installBraceText,
    required this.weldPipeText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double scale = math.min(size.width, size.height) / 1000.0 * zoom;
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(scale, scale);

    // Draw Background Grid
    Paint gridPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    for (int i = -1000; i <= 1000; i += 50) {
      canvas.drawLine(
        Offset(i.toDouble(), -1000),
        Offset(i.toDouble(), 1000),
        gridPaint,
      );
      canvas.drawLine(
        Offset(-1000, i.toDouble()),
        Offset(1000, i.toDouble()),
        gridPaint,
      );
    }

    Paint linePaint =
        Paint()
          ..color = const Color(0xff475569)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round;

    void drawText(
      String text,
      Offset pos, {
      double fontSize = 28,
      Color color = Colors.white,
      bool italic = false,
      bool bold = true,
    }) {
      TextSpan span = TextSpan(
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontFamily: 'sans-serif',
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

    void drawWedgeArc(
      Offset pos,
      double radius,
      double startAngle,
      double sweepAngle,
      Color color,
      Color strokeColor,
    ) {
      Paint fill =
          Paint()
            ..color = color
            ..style = PaintingStyle.fill;
      Paint stroke =
          Paint()
            ..color = strokeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3;
      Rect rect = Rect.fromCircle(center: pos, radius: radius);
      canvas.drawArc(
        rect,
        startAngle * math.pi / 180,
        sweepAngle * math.pi / 180,
        true,
        fill,
      );
      canvas.drawArc(
        rect,
        startAngle * math.pi / 180,
        sweepAngle * math.pi / 180,
        true,
        stroke,
      );
    }

    void drawRotateHandle(Offset pos) {
      canvas.drawCircle(
        pos,
        12,
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        pos,
        12,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (scenario == 1) {
      canvas.drawLine(
        const Offset(-1000, -150),
        const Offset(1000, -150),
        linePaint,
      );
      canvas.drawLine(
        const Offset(-1000, 150),
        const Offset(1000, 150),
        linePaint,
      );
      canvas.drawLine(
        const Offset(-245.07, -350),
        const Offset(245.07, 350),
        linePaint,
      );

      drawText("Line l", const Offset(-350, -170), fontSize: 24, italic: true);
      drawText("Line m", const Offset(-350, 130), fontSize: 24, italic: true);
      drawText("t", const Offset(180, -300), fontSize: 24, italic: true);

      _drawParallelArrows(
        canvas,
        const Offset(250, -150),
        const Color(0xff3b82f6),
      );
      _drawParallelArrows(
        canvas,
        const Offset(250, 150),
        const Color(0xff3b82f6),
      );

      canvas.save();
      canvas.translate(-105.03, -150);
      drawWedgeArc(
        Offset.zero,
        80,
        0,
        55,
        const Color(0xff3b82f6).withOpacity(0.35),
        const Color(0xff3b82f6),
      );
      drawText("c (55°)", const Offset(45, 25), fontSize: 18);
      canvas.restore();

      canvas.save();
      canvas.translate(105.03, 150);
      Paint dashedStroke =
          Paint()
            ..color = Colors.white.withOpacity(0.1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
      _drawDashedArc(
        canvas,
        Rect.fromCircle(center: Offset.zero, radius: 80),
        math.pi,
        55 * math.pi / 180,
        dashedStroke,
      );
      if (s1WedgeAligned) {
        drawText("e (55°)", const Offset(-40, -20), fontSize: 18);
      } else if (step == 1 && s1Cloned) {
        canvas.drawCircle(
          const Offset(-40, -20),
          30,
          Paint()..color = Colors.green.withOpacity(0.4),
        );
      }
      canvas.restore();

      if (s1WedgeAligned) {
        Path zPath =
            Path()
              ..moveTo(150, -150)
              ..lineTo(-105.03, -150)
              ..lineTo(105.03, 150)
              ..lineTo(-150, 150);
        canvas.drawPath(
          zPath,
          Paint()
            ..color = Colors.green
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }

      if (s1Cloned) {
        canvas.save();
        canvas.translate(
          s1WedgeDropped ? 105.03 : s1WedgePos.dx,
          s1WedgeDropped ? 150 : s1WedgePos.dy,
        );
        canvas.rotate(s1WedgeRot * math.pi / 180);
        Color wedgeColor =
            s1WedgeAligned ? const Color(0xff22c55e) : const Color(0xff3b82f6);
        drawWedgeArc(
          Offset.zero,
          80,
          0,
          55,
          wedgeColor.withOpacity(0.35),
          wedgeColor,
        );

        canvas.save();
        canvas.translate(45, 25);
        canvas.rotate(-s1WedgeRot * math.pi / 180);
        drawText("55°", Offset.zero, fontSize: 16);
        canvas.restore();

        if (s1WedgeDropped && !s1WedgeAligned) {
          Offset hPos = Offset(
            100 * math.cos(27.5 * math.pi / 180),
            100 * math.sin(27.5 * math.pi / 180),
          );
          drawRotateHandle(hPos);
        }
        canvas.restore();
      }

      if (step == 0 && !s1Cloned) {
        canvas.save();
        canvas.translate(-40, -95);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-15, -15, 30, 30),
            const Radius.circular(8),
          ),
          Paint()..color = const Color(0xff3b82f6),
        );
        canvas.drawRect(
          const Rect.fromLTWH(-6, -6, 12, 12),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        canvas.drawRect(
          const Rect.fromLTWH(-2, -2, 12, 12),
          Paint()
            ..color = const Color(0xff3b82f6)
            ..style = PaintingStyle.fill,
        );
        canvas.drawRect(
          const Rect.fromLTWH(-2, -2, 12, 12),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        canvas.restore();
      }
    } else if (scenario == 2) {
      canvas.drawLine(
        const Offset(-1000, -150),
        const Offset(1000, -150),
        linePaint,
      );
      canvas.drawLine(
        const Offset(-1000, 150),
        const Offset(1000, 150),
        linePaint,
      );
      canvas.drawLine(
        const Offset(-202.07, -350),
        const Offset(202.07, 350),
        linePaint,
      );

      drawText("Line l", const Offset(-350, -170), fontSize: 24, italic: true);
      drawText("Line m", const Offset(-350, 130), fontSize: 24, italic: true);
      drawText("t", const Offset(160, -300), fontSize: 24, italic: true);

      _drawParallelArrows(
        canvas,
        const Offset(250, -150),
        const Color(0xff3b82f6),
      );
      _drawParallelArrows(
        canvas,
        const Offset(250, 150),
        const Color(0xff3b82f6),
      );

      canvas.save();
      canvas.translate(86.6, 150);
      if (step == 1 && !s2WedgeDropped) {
        canvas.drawCircle(
          Offset.zero,
          30,
          Paint()..color = const Color(0xff3b82f6).withOpacity(0.5),
        );
      }
      drawWedgeArc(
        Offset.zero,
        80,
        -120,
        120,
        const Color(0xfff97316).withOpacity(0.35),
        const Color(0xfff97316),
      );
      drawText("f (120°)", const Offset(40, -40), fontSize: 18);

      if (s2WedgeDropped) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: 100),
          -120 * math.pi / 180,
          180 * math.pi / 180,
          true,
          Paint()..color = const Color(0xffeab308).withOpacity(0.2),
        );
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: 100),
          -120 * math.pi / 180,
          180 * math.pi / 180,
          false,
          Paint()
            ..color = const Color(0xffeab308)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(74, -80, 60, 40),
            const Radius.circular(8),
          ),
          Paint()..color = const Color(0xff1e293b),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(74, -80, 60, 40),
            const Radius.circular(8),
          ),
          Paint()
            ..color = const Color(0xffeab308)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        drawText(
          "180°",
          const Offset(104, -60),
          fontSize: 18,
          color: const Color(0xffeab308),
        );
      }
      canvas.restore();

      if (step == 1 && !s2WedgeDropped) {
        canvas.drawLine(
          const Offset(86.6 - 80, 150 - 138.56),
          const Offset(86.6 + 80, 150 + 138.56),
          Paint()
            ..color = Colors.green.withOpacity(0.5)
            ..strokeWidth = 12,
        );
      }

      canvas.save();
      canvas.translate(
        s2WedgeDropped ? 86.6 : s2WedgePos.dx,
        s2WedgeDropped ? 150 : s2WedgePos.dy,
      );
      drawWedgeArc(
        Offset.zero,
        80,
        0,
        60,
        const Color(0xff3b82f6).withOpacity(0.35),
        const Color(0xff3b82f6),
      );
      drawText("c (60°)", const Offset(45, 25), fontSize: 18);
      canvas.restore();

      if (s2WedgeDropped) {
        Path cShape =
            Path()
              ..moveTo(250, -150)
              ..lineTo(-86.6, -150)
              ..lineTo(86.6, 150)
              ..lineTo(250, 150);
        canvas.drawPath(
          cShape,
          Paint()
            ..color = const Color(0xffeab308)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    } else if (scenario == 3) {
      canvas.drawLine(
        const Offset(-350, -350),
        const Offset(350, 350),
        linePaint,
      );
      drawText("t", const Offset(250, 220), fontSize: 28, italic: true);

      bool isParallel = s3LTilt.abs() < 1;

      canvas.save();
      canvas.translate(0, 150);
      canvas.drawLine(const Offset(-1000, 0), const Offset(1000, 0), linePaint);
      drawText("Line m", const Offset(-350, 40), fontSize: 24, italic: true);
      if (isParallel) {
        _drawParallelArrows(
          canvas,
          const Offset(250, 0),
          const Color(0xff3b82f6),
        );
      }
      canvas.restore();

      canvas.save();
      canvas.translate(-150, -150);
      canvas.rotate(s3LTilt * math.pi / 180);
      canvas.translate(150, 150);

      canvas.save();
      canvas.translate(0, -150);
      if (isParallel) {
        canvas.drawLine(
          const Offset(-1000, 0),
          const Offset(1000, 0),
          linePaint,
        );
        _drawParallelArrows(
          canvas,
          const Offset(250, 0),
          const Color(0xff3b82f6),
        );
      } else {
        _drawDashedLine(
          canvas,
          const Offset(-1000, 0),
          const Offset(1000, 0),
          linePaint,
        );

        canvas.translate(450, 0);
        canvas.drawCircle(
          Offset.zero,
          20,
          Paint()
            ..color = const Color(0xffeab308)
            ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8),
        );
        canvas.drawCircle(
          Offset.zero,
          18,
          Paint()..color = const Color(0xffeab308),
        );
        canvas.drawCircle(Offset.zero, 6, Paint()..color = Colors.white);
      }
      canvas.restore();
      canvas.restore();
      drawText("Line l", const Offset(-350, -170), fontSize: 24, italic: true);

      canvas.save();
      canvas.translate(150, 150);
      Color blueCol =
          isParallel ? const Color(0xff22c55e) : const Color(0xff3b82f6);
      drawWedgeArc(
        Offset.zero,
        80,
        180,
        45,
        blueCol.withOpacity(0.35),
        blueCol,
      );
      Offset bTxt = Offset(
        80 * 0.6 * math.cos(202.5 * math.pi / 180),
        80 * 0.6 * math.sin(202.5 * math.pi / 180),
      );
      drawText("45°", bTxt, fontSize: 18);
      canvas.restore();

      canvas.save();
      canvas.translate(-150, -150);
      Color redCol =
          isParallel
              ? const Color(0xff22c55e)
              : (s3LTilt.abs() < 10
                  ? const Color(0xfff97316)
                  : const Color(0xffef4444));
      drawWedgeArc(
        Offset.zero,
        80,
        s3LTilt,
        45 - s3LTilt,
        redCol.withOpacity(0.35),
        redCol,
      );
      double midAngle = (s3LTilt + 45) / 2;
      Offset rTxt = Offset(
        80 * 0.6 * math.cos(midAngle * math.pi / 180),
        80 * 0.6 * math.sin(midAngle * math.pi / 180),
      );
      drawText("${(45 - s3LTilt).round()}°", rTxt, fontSize: 18);
      canvas.restore();
    } else if (scenario == 4) {
      Paint shelfPaint =
          Paint()
            ..color = const Color(0xff78350f)
            ..strokeWidth = 24
            ..strokeCap = StrokeCap.round;
      Paint bracePaint =
          Paint()
            ..color = const Color(0xff92400e)
            ..strokeWidth = 24
            ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        const Offset(-500, -100),
        const Offset(500, -100),
        shelfPaint,
      );
      canvas.drawLine(
        const Offset(-500, 150),
        const Offset(500, 150),
        shelfPaint,
      );
      drawText(
        "Top Shelf",
        const Offset(-450, -130),
        fontSize: 24,
        italic: true,
      );
      drawText(
        "Bottom Shelf",
        const Offset(-450, 190),
        fontSize: 24,
        italic: true,
      );

      canvas.drawLine(
        const Offset(-260, -100),
        const Offset(-50, 150),
        bracePaint,
      );
      canvas.drawCircle(
        const Offset(-260, -100),
        4,
        Paint()..color = Colors.grey.shade400,
      );
      canvas.drawCircle(
        const Offset(-50, 150),
        4,
        Paint()..color = Colors.grey.shade400,
      );

      canvas.save();
      canvas.translate(-50, 150);
      drawWedgeArc(
        Offset.zero,
        60,
        180,
        50,
        const Color(0xfff97316).withOpacity(0.35),
        const Color(0xfff97316),
      );
      drawText("50°", const Offset(-40, -15), fontSize: 16);
      canvas.restore();

      canvas.save();
      canvas.translate(
        s4BraceDropped ? 100 : s4BracePos.dx,
        s4BraceDropped ? -100 : s4BracePos.dy,
      );
      canvas.rotate(s4BraceRot * math.pi / 180);

      Paint dynBracePaint =
          Paint()
            ..color =
                actionValidated
                    ? const Color(0xff92400e)
                    : const Color(0xffef4444)
            ..strokeWidth = 24
            ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset.zero, const Offset(326, 0), dynBracePaint);

      if (actionValidated) {
        canvas.drawCircle(
          const Offset(10, 0),
          4,
          Paint()..color = Colors.grey.shade400,
        );
        canvas.drawCircle(
          const Offset(316, 0),
          4,
          Paint()..color = Colors.grey.shade400,
        );
      }

      if (s4BraceDropped && s4ProtDropped && !actionValidated) {
        drawRotateHandle(const Offset(180, 0));
      }
      canvas.restore();

      if (s4ProtDropped && !actionValidated) {
        canvas.save();
        canvas.translate(100, -100);
        drawWedgeArc(
          Offset.zero,
          60,
          0,
          s4BraceRot,
          const Color(0xff3b82f6).withOpacity(0.35),
          const Color(0xff3b82f6),
        );
        Offset mid = Offset(
          60 * 0.6 * math.cos(s4BraceRot / 2 * math.pi / 180),
          60 * 0.6 * math.sin(s4BraceRot / 2 * math.pi / 180),
        );
        drawText("${s4BraceRot.round()}°", mid, fontSize: 18);
        canvas.restore();
      }

      if (step >= 1 && !actionValidated) {
        canvas.save();
        canvas.translate(
          s4ProtDropped ? 100 : s4ProtPos.dx,
          s4ProtDropped ? -100 : s4ProtPos.dy,
        );
        canvas.scale(0.8);
        Paint pStroke =
            Paint()
              ..color = const Color(0xff3b82f6)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3;
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: 150),
          math.pi,
          math.pi,
          true,
          Paint()..color = const Color(0xff3b82f6).withOpacity(0.1),
        );
        canvas.drawLine(const Offset(-160, 0), const Offset(160, 0), pStroke);
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: 150),
          math.pi,
          math.pi,
          false,
          pStroke,
        );
        canvas.drawCircle(Offset.zero, 6, Paint()..color = Colors.red);
        drawText(
          "PROTRACTOR",
          const Offset(0, -40),
          fontSize: 16,
          color: const Color(0xff3b82f6),
        );
        canvas.restore();
      }

      if (step == 2 && s4ProtDropped && !actionValidated) {
        _drawButton(
          canvas,
          const Offset(-350, 300),
          installBraceText,
          Colors.green,
        );
      }
    } else if (scenario == 5) {
      Paint pipeBase =
          Paint()
            ..color = const Color(0xff334155)
            ..strokeWidth = 30
            ..strokeCap = StrokeCap.round;
      Paint pipeHl =
          Paint()
            ..color = const Color(0xff94a3b8)
            ..strokeWidth = 10
            ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        const Offset(-1000, -150),
        const Offset(1000, -150),
        pipeBase,
      );
      canvas.drawLine(
        const Offset(-1000, -150),
        const Offset(1000, -150),
        pipeHl,
      );
      canvas.drawLine(
        const Offset(-1000, 150),
        const Offset(1000, 150),
        pipeBase,
      );
      canvas.drawLine(
        const Offset(-1000, 150),
        const Offset(1000, 150),
        pipeHl,
      );

      drawText(
        "Top Main Pipeline",
        const Offset(-450, -180),
        fontSize: 24,
        italic: true,
      );
      drawText(
        "Bottom Main Pipeline",
        const Offset(-450, 190),
        fontSize: 24,
        italic: true,
      );

      canvas.save();
      canvas.translate(40, -150);
      canvas.drawCircle(
        Offset.zero,
        25,
        Paint()..color = const Color(0xff475569),
      );
      canvas.drawCircle(
        Offset.zero,
        10,
        Paint()..color = const Color(0xff0f172a),
      );
      drawWedgeArc(
        Offset.zero,
        80,
        0,
        115,
        const Color(0xffef4444).withOpacity(0.35),
        const Color(0xffef4444),
      );
      drawText("115°", const Offset(25, 45), fontSize: 18);
      canvas.restore();

      canvas.save();
      canvas.translate(-100, 150);
      if (step == 0 && !s5PipeDropped) {
        canvas.drawCircle(
          Offset.zero,
          35,
          Paint()..color = const Color(0xffeab308).withOpacity(0.5),
        );
      }
      canvas.drawCircle(
        Offset.zero,
        25,
        Paint()..color = const Color(0xff475569),
      );
      canvas.drawCircle(
        Offset.zero,
        10,
        Paint()..color = const Color(0xff0f172a),
      );
      canvas.restore();

      if (!s5PipeDropped) {
        canvas.save();
        canvas.translate(250, -250);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-30, -30, 200, 100),
            const Radius.circular(12),
          ),
          Paint()..color = const Color(0xff1e293b).withOpacity(0.9),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-30, -30, 200, 100),
            const Radius.circular(12),
          ),
          Paint()
            ..color = const Color(0xff475569)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        drawText(
          "TOOLBOX",
          const Offset(70, -10),
          fontSize: 14,
          color: const Color(0xff94a3b8),
        );
        drawText(
          "Pipe Segment",
          const Offset(70, 10),
          fontSize: 12,
          color: const Color(0xffcbd5e1),
        );
        canvas.restore();
      }

      canvas.save();
      canvas.translate(
        s5PipeDropped ? -100 : s5PipePos.dx,
        s5PipeDropped ? 150 : s5PipePos.dy,
      );
      canvas.rotate(s5PipeRot * math.pi / 180);
      canvas.drawLine(
        Offset.zero,
        const Offset(331, 0),
        Paint()
          ..color = const Color(0xff475569)
          ..strokeWidth = 20
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset.zero,
        const Offset(331, 0),
        Paint()
          ..color = const Color(0xffcbd5e1)
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      );

      if (s5PipeDropped && !actionValidated) {
        drawRotateHandle(const Offset(331, 0));
      }
      canvas.restore();

      if (s5PipeDropped) {
        canvas.save();
        canvas.translate(-100, 150);
        if (!actionValidated) {
          canvas.drawLine(
            Offset.zero,
            const Offset(100, 0),
            Paint()
              ..color = Colors.white.withOpacity(0.2)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
        drawWedgeArc(
          Offset.zero,
          70,
          s5PipeRot,
          s5PipeRot.abs(),
          const Color(0xff3b82f6).withOpacity(0.35),
          const Color(0xff3b82f6),
        );
        Offset mB = Offset(
          70 * 0.6 * math.cos(s5PipeRot / 2 * math.pi / 180),
          70 * 0.6 * math.sin(s5PipeRot / 2 * math.pi / 180),
        );
        drawText("${s5PipeRot.abs().round()}°", mB, fontSize: 18);
        canvas.restore();
      }

      if (step >= 2 && s5PipeDropped && !actionValidated) {
        _drawButton(
          canvas,
          const Offset(-350, 300),
          weldPipeText,
          Colors.green,
        );
      }
    }
  }

  void _drawParallelArrows(Canvas canvas, Offset pos, Color color) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(0.8);
    canvas.translate(-12, -12);

    Path p =
        Path()
          ..moveTo(21.66, 6.38)
          ..lineTo(18.39, 8.09)
          ..lineTo(19.28, 9.79)
          ..lineTo(22.55, 8.08)
          ..close()
          ..moveTo(21.66, 14.38)
          ..lineTo(18.39, 16.09)
          ..lineTo(19.28, 17.79)
          ..lineTo(22.55, 16.08)
          ..close()
          ..moveTo(2, 5)
          ..lineTo(22, 5)
          ..lineTo(22, 7)
          ..lineTo(2, 7)
          ..close()
          ..moveTo(2, 13)
          ..lineTo(22, 13)
          ..lineTo(22, 15)
          ..lineTo(2, 15)
          ..close();

    canvas.drawPath(p, Paint()..color = color);
    canvas.restore();
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 15;
    double dashSpace = 15;
    double distance = (p2 - p1).distance;
    double dx = (p2.dx - p1.dx) / distance;
    double dy = (p2.dy - p1.dy) / distance;
    double x = p1.dx;
    double y = p1.dy;
    double drawn = 0;

    while (drawn < distance) {
      double drawL = math.min(dashWidth, distance - drawn);
      canvas.drawLine(
        Offset(x, y),
        Offset(x + dx * drawL, y + dy * drawL),
        paint,
      );
      x += dx * (drawL + dashSpace);
      y += dy * (drawL + dashSpace);
      drawn += drawL + dashSpace;
    }
  }

  void _drawDashedArc(
    Canvas canvas,
    Rect rect,
    double startAngle,
    double sweepAngle,
    Paint paint,
  ) {
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  void _drawButton(Canvas canvas, Offset center, String label, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    Rect r = const Rect.fromLTWH(-95, -25, 190, 50);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(25)),
      Paint()..color = color,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(25)),
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    TextSpan span = TextSpan(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'sans-serif',
      ),
      text: label,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AnglesCanvasPainter oldDelegate) => true;
}
