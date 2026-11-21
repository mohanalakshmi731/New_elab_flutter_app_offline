// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: use_super_parameters, camel_case_types, library_private_types_in_public_api, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab | Angles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // zslDark
        primaryColor: const Color(0xFF6366F1), // zslIndigo
        fontFamily: 'Roboto',
      ),
      home: const Cl6M_Ch2_A6_AnglesinRealWorldContexts(),
    ),
  );
}

class Cl6M_Ch2_A6_AnglesinRealWorldContexts extends StatefulWidget {
  const Cl6M_Ch2_A6_AnglesinRealWorldContexts({Key? key}) : super(key: key);

  @override
  State<Cl6M_Ch2_A6_AnglesinRealWorldContexts> createState() =>
      _Cl6M_Ch2_A6_AnglesinRealWorldContextsState();
}

class _Cl6M_Ch2_A6_AnglesinRealWorldContextsState
    extends State<Cl6M_Ch2_A6_AnglesinRealWorldContexts>
    with TickerProviderStateMixin {
  // === SYSTEM & UI STATE ===
  bool _isCurtainUp = false;
  bool _isSidebarOpen = true;
  String _lang = 'en';
  final double _sidebarWidth = 350.0;
  final GlobalKey _canvasKey = GlobalKey();

  // === AUDIO ===
  final AudioPlayer _audioPlayer = AudioPlayer();

  // === GAME LOOP & ANIMATION ===
  late AnimationController _tickerController;

  // === CAMERA & GESTURES ===
  double _panX = 0;
  double _panY = 0;
  double _zoom = 1.0;

  double _startPanX = 0;
  double _startPanY = 0;
  double _startZoom = 1.0;

  // === SIMULATION STATE ===
  int _scenario = 1;
  int _step = 0;

  String? _activeDragEntity;
  bool _isAnimating = false;

  // S1 (Clock)
  double _s1MinuteAngle = 90; // degrees (Starts at 6 o'clock instead of 12)

  // S2 (Swing)
  double _s2SwingAngle = 90; // degrees
  String _s2State = 'idle'; // idle, drag, swinging

  // S3 (Door)
  double _s3DoorAngle = 0; // degrees
  double _s3AnimY = 0.0;

  // S4 (Solar)
  double _s4PanelAngle = 90; // degrees

  // S5 (Ramps)
  double _s5J1y = -100;
  double _s5J2y = -50;
  bool _s5BallActive = false;
  double _s5BallProgress = 0.0;
  int _s5BallSegment = 0;

  // === TRANSLATIONS ===
  final Map<String, Map<String, String>> _i18n = {
    'en': {
      'shutterTitle': "Angles in Real-World Contexts",
      'appSubtitle': "Class 6 • LINES AND ANGLES",
      'enterLab': "Enter Simulation",
      'selectScenario': "Select Scenario",
      'objective': "Objective:",
      'observation': "Observation:",
      'stepLabel': "STEP",
      'doneBtn': "Done",
      'resetBtn': "Reset Lab",
      'finishLab': "Finish Lab",
      'nextScenario': "Next Scenario",
      'summaryTitle': "Goal Reached!",
      'finalDesc':
          "You have successfully explored angles in real-world contexts!",
      'stepComplete':
          "Great job! You have successfully completed this scenario.",
      'lbl_push': "Push",
      'lbl_test': "Test Path",
      's1_title': "1. The Clockmaker's Apprentice",
      's1_obj':
          "Help the clockmaker by setting the clock hands to form specific types of angles.",
      's1_task1': "DRAG the minute hand to the '12'.",
      's1_out1': "Right Angle! A perfect 90° angle.",
      's1_task2': "DRAG the minute hand to the '2'.",
      's1_out2': "Acute Angle! Less than 90°.",
      's1_task3': "DRAG the minute hand to the '8'.",
      's1_out3': "Obtuse Angle! Greater than 90°.",
      's1_task4': "DRAG the minute hand to the '9'.",
      's1_out4': "Straight Angle! A 180° straight line.",
      's1_hud1': "Drag the minute hand to the '12'.",
      's1_hud2': "Drag the minute hand to the '2'.",
      's1_hud3': "Drag the minute hand to the '8'.",
      's1_hud4': "Drag the minute hand to the '9'.",

      's2_title': "2. The Perfect Swing",
      's2_obj':
          "Help Vidya start her swing at the correct angle to grab floating balloons.",
      's2_task1':
          "DRAG the swing backward to set the angle to 40° and CLICK 'Push'.",
      's2_out1': "Great! A small acute angle was perfect.",
      's2_task2': "DRAG the swing to a larger angle (80°) and CLICK 'Push'.",
      's2_out2': "Excellent! A larger acute angle gives more height.",
      's2_task3':
          "DRAG the swing to 110° to reach the highest balloon and CLICK 'Push'.",
      's2_out3': "Amazing! An obtuse angle gives max height.",
      's2_hud1': "Drag swing to 40° and click Push.",
      's2_hud2': "Drag swing to 80° and click Push.",
      's2_hud3': "Drag swing to 110° and click Push.",

      's3_title': "3. The Furniture Mover",
      's3_obj':
          "Open the door to the correct angle to allow furniture to pass through.",
      's3_task1': "A narrow chair. DRAG the doorknob to open the door to ~45°.",
      's3_out1': "Perfect! A small acute angle.",
      's3_task2': "A square box. DRAG the doorknob to open the door to 90°.",
      's3_out2': "Exactly right! A 90° right angle.",
      's3_task3': "A wide sofa. DRAG the doorknob to open the door to ~150°.",
      's3_out3': "Great job! A large obtuse angle.",
      's3_hud1': "Open door to 45°.",
      's3_hud2': "Open door to 90°.",
      's3_hud3': "Open door to 150°.",

      's4_title': "4. The Solar Panel Engineer",
      's4_obj':
          "Adjust the angle of a solar panel to collect maximum solar energy.",
      's4_task1': "Morning. DRAG the lever to TILT the panel east.",
      's4_out1': "Optimal! You used an acute angle.",
      's4_task2': "Noon. Re-adjust the panel for overhead sun.",
      's4_out2': "Optimal! You adjusted the panel to be flat (180°).",
      's4_task3': "Late afternoon. Adjust the panel for the western sun.",
      's4_out3': "Optimal! You used an obtuse angle.",
      's4_hud1': "Tilt panel to face morning sun.",
      's4_hud2': "Tilt panel flat for noon sun.",
      's4_hud3': "Tilt panel to face afternoon sun.",

      's5_title': "5. Ramp Racers",
      's5_obj': "Adjust three ramps to guide a marble into a target cup.",
      's5_task1':
          "DRAG the joint of the first ramp to set angle. CLICK 'Test Path'.",
      's5_out1': "Good test! The slope determines speed.",
      's5_task2':
          "ADJUST remaining joints to create a path to cup. CLICK 'Test Path'.",
      's5_out2': "Challenge complete! Ramp engineer!",
      's5_hud1': "Drag first joint and Test.",
      's5_hud2': "Adjust joints and Test.",
    },
    'hi': {
      'shutterTitle': "वास्तविक दुनिया में कोण",
      'appSubtitle': "कक्षा 6 • रेखाएँ और कोण",
      'enterLab': "सिमुलेशन दर्ज करें",
      'selectScenario': "परिदृश्य चुनें",
      'objective': "लक्ष्य:",
      'observation': "अवलोकन:",
      'stepLabel': "चरण",
      'doneBtn': "पूर्ण",
      'resetBtn': "रीसेट करें",
      'finishLab': "समाप्त करें",
      'nextScenario': "अगला परिदृश्य",
      'summaryTitle': "लक्ष्य प्राप्त हुआ!",
      'finalDesc':
          "आपने वास्तविक दुनिया के संदर्भों में कोणों का सफलतापूर्वक पता लगाया है!",
      'stepComplete': "बहुत बढ़िया! आपने यह परिदृश्य पूरा कर लिया है।",
      'lbl_push': "धक्का दें",
      'lbl_test': "पथ का परीक्षण करें",
      's1_title': "1. घड़ीसाज़ का प्रशिक्षु",
      's1_obj':
          "विशिष्ट प्रकार के कोण बनाने के लिए घड़ी की सूइयों को सेट करें।",
      's1_task1': "मिनट की सुई को '12' पर खींचें।",
      's1_out1': "समकोण! 90° का पूर्ण कोण।",
      's1_task2': "मिनट की सुई को '2' पर खींचें।",
      's1_out2': "न्यून कोण! 90° से कम।",
      's1_task3': "मिनट की सुई को '8' पर खींचें।",
      's1_out3': "अधिक कोण! 90° से अधिक।",
      's1_task4': "मिनट की सुई को '9' पर खींचें।",
      's1_out4': "ऋजु कोण! 180° की सीधी रेखा।",
      's1_hud1': "सुई को '12' पर खींचें।",
      's1_hud2': "सुई को '2' पर खींचें।",
      's1_hud3': "सुई को '8' पर खींचें।",
      's1_hud4': "सुई को '9' पर खींचें।",

      's2_title': "2. परफेक्ट स्विंग",
      's2_obj':
          "तैरते हुए गुब्बारों को पकड़ने के लिए सही कोण पर झूला शुरू करें।",
      's2_task1':
          "झूले को 40° पर सेट करने के लिए खींचें और 'धक्का दें' पर क्लिक करें।",
      's2_out1': "बहुत बढ़िया! न्यून कोण।",
      's2_task2': "झूले को 80° पर खींचें और 'धक्का दें' पर क्लिक करें।",
      's2_out2': "उत्कृष्ट! बड़ा न्यून कोण अधिक ऊंचाई देता है।",
      's2_task3': "झूले को 110° तक खींचें और 'धक्का दें' पर क्लिक करें।",
      's2_out3': "अद्भुत! अधिक कोण बहुत अधिक ऊंचाई देता है।",
      's2_hud1': "झूले को 40° तक खींचें।",
      's2_hud2': "झूले को 80° तक खींचें।",
      's2_hud3': "झूले को 110° तक खींचें।",

      's3_title': "3. फर्नीचर मूवर",
      's3_obj': "फर्नीचर के लिए दरवाजे को सही कोण पर खोलें।",
      's3_task1': "दरवाजे को ~45° तक खोलने के लिए नॉब को खींचें।",
      's3_out1': "बिल्कुल सही! न्यून कोण।",
      's3_task2': "दरवाजे को 90° के कोण पर खोलें।",
      's3_out2': "बिल्कुल सही! 90° समकोण।",
      's3_task3': "दरवाजे को ~150° तक खोलें।",
      's3_out3': "बहुत बढ़िया! अधिक कोण।",
      's3_hud1': "दरवाजे को 45° तक खोलें।",
      's3_hud2': "दरवाजे को 90° तक खोलें।",
      's3_hud3': "दरवाजे को 150° तक खोलें।",

      's4_title': "4. सोलर पैनल इंजीनियर",
      's4_obj': "अधिकतम सौर ऊर्जा के लिए दिन भर सोलर पैनल को समायोजित करें।",
      's4_task1': "पूर्व में सूर्य का सामना करने के लिए पैनल को झुकाएं।",
      's4_out1': "इष्टतम! न्यून कोण का उपयोग किया।",
      's4_task2': "अधिकतम शक्ति के लिए पैनल को फिर से समायोजित करें।",
      's4_out2': "इष्टतम! समतल (180°)।",
      's4_task3': "पश्चिमी सूरज को पकड़ने के लिए पैनल को समायोजित करें।",
      's4_out3': "इष्टतम! अधिक कोण।",
      's4_hud1': "सुबह के सूरज का सामना करने के लिए झुकाएं।",
      's4_hud2': "दोपहर के सूरज के लिए समतल झुकाएं।",
      's4_hud3': "शाम के सूरज का सामना करने के लिए झुकाएं।",

      's5_title': "5. रैंप रेसर्स",
      's5_obj':
          "संगमरमर को लक्ष्य कप में मार्गदर्शन करने के लिए रैंप के कोणों को समायोजित करें।",
      's5_task1': "पहले रैंप के जोड़ को खींचें। 'परीक्षण' पर क्लिक करें।",
      's5_out1': "अच्छा परीक्षण! ढलान गति निर्धारित करती है।",
      's5_task2':
          "लक्ष्य कप में मार्गदर्शन के लिए सभी जोड़ों को समायोजित करें।",
      's5_out2': "चुनौती पूर्ण!",
      's5_hud1': "पहले रैंप जोड़ को खींचें और परीक्षण करें।",
      's5_hud2':
          "गेंद को कप में निर्देशित करने के लिए जोड़ों को समायोजित करें।",
    },
  };

  String t(String key) => _i18n[_lang]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _tickerController.addListener(_gameLoopTick);
    _tickerController.repeat();

    _fitCanvas();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _tickerController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSound(String type) async {
    try {
      String url = '';
      if (type == 'success') {
        url = 'audio/class6/math/mixkit_2013.mp3';
      } else if (type == 'snap') {
        url = 'audio/class6/math/click.mp3';
      } else if (type == 'error') {
        url = 'audio/class6/math/error.mp3';
      }

      if (url.isNotEmpty) {
        await _audioPlayer.play(AssetSource(url));
      }
    } catch (e) {
      // Audio errors ignored gracefully
    }
  }

  void _gameLoopTick() {
    if (_isAnimating) {
      setState(() {
        if (_scenario == 2 && _s2State == 'swinging') {
          // handled in animation trigger below
        }
      });
    }
    // Repaint triggered by AnimationController natively within CustomPaint via listenable
  }

  void _fitCanvas() {
    setState(() {
      _zoom = 1.0;
      _panX = 0;
      _panY = 0;
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;
      _isAnimating = false;
      _activeDragEntity = null;
      _fitCanvas();

      if (id == 1) {
        _s1MinuteAngle = 90;
      } // changed from -90 to 90
      else if (id == 2) {
        _s2SwingAngle = 90;
        _s2State = 'idle';
      } else if (id == 3) {
        _s3DoorAngle = 0;
        _s3AnimY = 0;
      } else if (id == 4) {
        _s4PanelAngle = 90;
      } else if (id == 5) {
        _s5J1y = -100;
        _s5J2y = -50;
        _s5BallActive = false;
      }
    });
  }

  Map<String, dynamic> _getScenarioConfig(int id) {
    int numSteps = (id == 5) ? 2 : ((id == 1) ? 4 : 3);
    List<Map<String, String>> steps = [];
    for (int i = 1; i <= numSteps; i++) {
      steps.add({
        'hud': t('s${id}_hud$i'),
        'task': t('s${id}_task$i'),
        'outcome': t('s${id}_out$i'),
      });
    }
    return {'title': t('s${id}_title'), 'obj': t('s${id}_obj'), 'steps': steps};
  }

  // === GESTURE HANDLING & CAMERA MAPPING ===

  Offset _getWorldPoint(Offset screenPoint) {
    if (_canvasKey.currentContext == null) return Offset.zero;
    final box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final size = box.size;

    double worldX = (screenPoint.dx - size.width / 2 - _panX) / _zoom;
    double worldY = (screenPoint.dy - size.height / 2 - _panY) / _zoom;
    return Offset(worldX, worldY);
  }

  bool _hitTestCircle(double cx, double cy, double r, Offset pt) {
    return sqrt(pow(pt.dx - cx, 2) + pow(pt.dy - cy, 2)) <= r;
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx >= x && pt.dx <= x + w && pt.dy >= y && pt.dy <= y + h;
  }

  void _onScaleStart(ScaleStartDetails details) {
    Offset pt = _getWorldPoint(details.localFocalPoint);

    setState(() {
      if (!_isAnimating) {
        bool hitEntity = false;

        if (_scenario == 1) {
          double minRad = _s1MinuteAngle * pi / 180;
          if (_hitTestCircle(
            cos(minRad) * 140,
            sin(minRad) * 140,
            40 / _zoom,
            pt,
          )) {
            _activeDragEntity = 'minute';
            _playSound('snap');
            hitEntity = true;
          }
        } else if (_scenario == 2) {
          double ropeLen = 250;
          double seatX = -100 + cos(_s2SwingAngle * pi / 180) * ropeLen;
          double seatY = -150 + sin(_s2SwingAngle * pi / 180) * ropeLen;
          if (_hitTestCircle(seatX, seatY, 50 / _zoom, pt) &&
              _s2State == 'idle') {
            _activeDragEntity = 'swing';
            _s2State = 'drag';
            _playSound('snap');
            hitEntity = true;
          }
          if (_hitTestBox(370, 220, 120, 50, pt)) {
            _triggerAction('s2_push');
            hitEntity = true;
          }
        } else if (_scenario == 3) {
          double doorRad = -_s3DoorAngle * pi / 180;
          double knobX = -50 + cos(doorRad) * 180;
          double knobY = 100 + sin(doorRad) * 180;
          if (_hitTestCircle(knobX, knobY, 40 / _zoom, pt)) {
            _activeDragEntity = 'door';
            _playSound('snap');
            hitEntity = true;
          }
        } else if (_scenario == 4) {
          double lx = cos(-_s4PanelAngle * pi / 180) * 90;
          double ly = -40 + sin(-_s4PanelAngle * pi / 180) * 90;
          if (_hitTestCircle(lx, ly, 40 / _zoom, pt)) {
            _activeDragEntity = 'panel';
            _playSound('snap');
            hitEntity = true;
          }
        } else if (_scenario == 5) {
          if (_hitTestCircle(-100, _s5J1y, 40 / _zoom, pt)) {
            _activeDragEntity = 'j1';
            _playSound('snap');
            hitEntity = true;
          } else if (_hitTestCircle(100, _s5J2y, 40 / _zoom, pt)) {
            _activeDragEntity = 'j2';
            _playSound('snap');
            hitEntity = true;
          } else if (_hitTestBox(-50, 220, 140, 50, pt)) {
            _triggerAction('s5_test');
            hitEntity = true;
          }
        }

        if (!hitEntity) {
          _startPanX = details.localFocalPoint.dx - _panX;
          _startPanY = details.localFocalPoint.dy - _panY;
          _startZoom = _zoom;
        }
      }
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    Offset pt = _getWorldPoint(details.localFocalPoint);

    setState(() {
      if (_activeDragEntity != null) {
        if (_scenario == 1 && _activeDragEntity == 'minute') {
          double ang = atan2(pt.dy, pt.dx) * 180 / pi;
          _s1MinuteAngle = (ang / 30).round() * 30.0;
        } else if (_scenario == 2 && _activeDragEntity == 'swing') {
          double ang = atan2(pt.dy - (-150), pt.dx - (-100)) * 180 / pi;
          if (ang > 90) ang = 90;
          if (ang < -20) ang = -20;
          _s2SwingAngle = ang;
        } else if (_scenario == 3 && _activeDragEntity == 'door') {
          double ang = atan2(pt.dy - 100, pt.dx - (-50)) * 180 / pi;
          if (ang > 0) ang -= 360;
          if (ang > 0) ang = 0;
          if (ang < -180) ang = -180;
          _s3DoorAngle = -ang;
        } else if (_scenario == 4 && _activeDragEntity == 'panel') {
          double ang = atan2(pt.dy - (-40), pt.dx) * 180 / pi;
          if (ang > 0) ang -= 360;
          if (ang > -10) ang = -10;
          if (ang < -170) ang = -170;
          _s4PanelAngle = -ang;
        } else if (_scenario == 5) {
          if (_activeDragEntity == 'j1') {
            _s5J1y = pt.dy.clamp(-200.0, 200.0);
          } else if (_activeDragEntity == 'j2') {
            _s5J2y = pt.dy.clamp(-200.0, 200.0);
          }
        }
      } else {
        // Handle canvas panning and zooming seamlessly
        _panX = details.localFocalPoint.dx - _startPanX;
        _panY = details.localFocalPoint.dy - _startPanY;
        _zoom = (_startZoom * details.scale).clamp(0.4, 2.5);
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_activeDragEntity == null) return;

    setState(() {
      if (_scenario == 1) {
        double min = _s1MinuteAngle * pi / 180;
        double start = min < 0 ? min : 0.0;
        double end = min > 0 ? min : 0.0;
        if (end - start > pi) {
          start = end;
          end = (min < 0 ? min : 0) + pi * 2;
        }
        int diffDeg = ((end - start).abs() * 180 / pi).round();
        if (diffDeg > 180) diffDeg = 360 - diffDeg;

        List<int> targetMap = [90, 30, 150, 180];
        if (_step < 4 && diffDeg == targetMap[_step]) {
          _playSound('success');
          _step++;
        } else {
          _playSound('error');
        }
      } else if (_scenario == 2) {
        _s2State = 'idle';
        _playSound('snap');
      } else if (_scenario == 3) {
        List<double> targetMap = [45, 90, 150];
        if (_step < 3 && (_s3DoorAngle - targetMap[_step]).abs() < 10) {
          _s3DoorAngle = targetMap[_step];
          _runAnimation(
            1000,
            (p) {
              setState(() => _s3AnimY = p * 300);
            },
            onEnd: () {
              setState(() {
                _s3AnimY = 0;
                _step++;
                _playSound('success');
              });
            },
          );
        } else {
          _playSound('error');
        }
      } else if (_scenario == 4) {
        List<double> targetMap = [30, 90, 150];
        if (_step < 3 && (_s4PanelAngle - targetMap[_step]).abs() < 15) {
          _playSound('success');
          _runAnimation(
            1500,
            (p) {},
            onEnd: () {
              setState(() => _step++);
            },
          );
        } else {
          _playSound('error');
        }
      } else if (_scenario == 5) {
        _playSound('snap');
      }

      _activeDragEntity = null;
    });
  }

  void _triggerAction(String action) {
    if (action == 's2_push' && _s2State == 'idle') {
      double read = (_s2SwingAngle - 90).abs();
      if ((_step == 0 && (read - 40).abs() < 5) ||
          (_step == 1 && (read - 80).abs() < 5) ||
          (_step == 2 && (read - 110).abs() < 5)) {
        _playSound('snap');
        _s2State = 'swinging';
        double startAngle = _s2SwingAngle;

        _runAnimation(
          2000,
          (p) {
            setState(() {
              double diff = startAngle - 90;
              _s2SwingAngle = 90 + diff * cos(p * pi);
            });
          },
          onEnd: () {
            setState(() {
              _s2State = 'idle';
              _step++;
              _playSound('success');
            });
          },
        );
      } else {
        _playSound('error');
      }
    } else if (action == 's5_test' && !_s5BallActive) {
      bool valid = _s5J1y >= -150 && _s5J2y >= _s5J1y && 150 >= _s5J2y;
      _s5BallActive = true;
      _s5BallSegment = 0;
      _s5BallProgress = 0;
      _playSound('snap');

      _runAnimation(
        1500,
        (p) {
          setState(() {
            double totalP = p * 3;
            _s5BallSegment = totalP.floor().clamp(0, 2);
            _s5BallProgress = totalP - _s5BallSegment;
          });
        },
        onEnd: () {
          setState(() {
            _s5BallActive = false;
            if (valid) {
              _playSound('success');
              if (_step == 0) {
                _step++;
              } else if (_step == 1) {
                _step++;
              }
            } else {
              _playSound('error');
            }
          });
        },
      );
    }
  }

  void _runAnimation(int ms, Function(double) onUpdate, {Function()? onEnd}) {
    _isAnimating = true;
    final int start = DateTime.now().millisecondsSinceEpoch;

    void loop() {
      if (!mounted || !_isAnimating) return;
      int elapsed = DateTime.now().millisecondsSinceEpoch - start;
      double p = (elapsed / ms).clamp(0.0, 1.0);
      onUpdate(p);
      if (p < 1.0) {
        Future.delayed(const Duration(milliseconds: 16), loop);
      } else {
        _isAnimating = false;
        if (onEnd != null) onEnd();
      }
    }

    loop();
  }

  // === WIDGET BUILDERS ===

  @override
  Widget build(BuildContext context) {
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
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              right: 0,
              child: GestureDetector(
                // ADDED: onTapDown perfectly captures quick taps before parent onTap overrides it.
                onTapDown: (details) {
                  Offset pt = _getWorldPoint(details.localPosition);
                  setState(() {
                    if (!_isAnimating) {
                      if (_scenario == 2 &&
                          _hitTestBox(370, 220, 120, 50, pt)) {
                        _triggerAction('s2_push');
                      } else if (_scenario == 5 &&
                          _hitTestBox(-50, 220, 140, 50, pt)) {
                        _triggerAction('s5_test');
                      }
                    }
                  });
                },
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
                child: Container(
                  key: _canvasKey,
                  color: const Color(0xFF0F172A),
                  child: CustomPaint(
                    painter: CanvasPainter(
                      state: this,
                      ticker: _tickerController, // forces repaint
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),

            // CANVAS HUD
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 30,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              right: 0,
              child: _buildHUD(),
            ),

            // SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -_sidebarWidth,
              width: _sidebarWidth,
              child: _buildSidebar(),
            ),

            // FLOATING MENU BTN
            Positioned(
              top: 16,
              left: 16, // Moved to Left Top
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF1E293B).withOpacity(0.8),
                onPressed: () {
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                  _playSound('snap');
                },
                child: Icon(
                  _isSidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),

            // CURTAIN SCREEN OVERLAY
            if (!_isCurtainUp) _buildCurtain(),

            // SUCCESS OVERLAY
            if (_isCurtainUp &&
                _step >= ((_scenario == 5) ? 2 : ((_scenario == 1) ? 4 : 3)))
              _buildSuccessOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurtain() {
    return Container(
      color: const Color(0xFF0F172A),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.architecture,
                size: 80,
                color: Color(0xFF6366F1),
              ),
              const SizedBox(height: 24),
              Text(
                t('shutterTitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                t('appSubtitle'),
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                icon: const Icon(
                  Icons.play_circle_fill,
                  size: 28,
                  color: Colors.white,
                ),
                label: Text(
                  t('enterLab'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isCurtainUp = true;
                  });
                  _playSound('snap');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    var config = _getScenarioConfig(_scenario);
    List<Map<String, String>> steps = config['steps'];

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        border: const Border(right: BorderSide(color: Colors.white10)),
      ),
      // ScrollView wraps the whole sidebar to make header + content entirely scrollable
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(
                16,
                64,
                16,
                16,
              ), // Extra top padding added to clear the floating Menu button safely
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.architecture,
                        color: Color(0xFF6366F1),
                        size: 36,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('shutterTitle'),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t('appSubtitle'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.05),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        icon: const Icon(
                          Icons.language,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: Text(
                          _lang.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _lang = _lang == 'en' ? 'hi' : 'en';
                          });
                          _playSound('snap');
                        },
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        icon: const Icon(
                          Icons.refresh,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                        label: Text(
                          t('resetBtn'),
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isCurtainUp = false;
                            _loadScenario(1);
                          });
                          _playSound('error');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('selectScenario').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _scenario,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E293B),
                        items: [1, 2, 3, 4, 5]
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  t('s${e}_title'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) _loadScenario(v);
                          _playSound('snap');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.my_location,
                              color: Colors.pinkAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t('objective'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          config['obj'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  ...List.generate(steps.length, (i) {
                    bool isActive = i == _step;
                    bool isPast = i < _step;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF6366F1).withOpacity(0.15)
                            : (isPast
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.white.withOpacity(0.02)),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF6366F1)
                              : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isPast
                                  ? Colors.green
                                  : (isActive
                                        ? const Color(0xFF6366F1)
                                        : Colors.white24),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isPast
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${t('stepLabel')} ${i + 1}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  steps[i]['task']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isActive
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (isPast) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "${t('observation')} ${steps[i]['outcome']}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                  // Footer moved inside ScrollView
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: const Text(
                      "© ZeroScienceLab - Fall in love with math and Science",
                      style: TextStyle(fontSize: 10, color: Colors.white54),
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

  Widget _buildHUD() {
    var config = _getScenarioConfig(_scenario);
    List<Map<String, String>> steps = config['steps'];

    if (_step >= steps.length) return const SizedBox.shrink();

    return IgnorePointer(
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: const Border(
              top: BorderSide(color: Color(0xFF6366F1), width: 3),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF6366F1),
                size: 28,
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  steps[_step]['hud']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    bool isFinal = _scenario == 5;
    return Container(
      color: Colors.black.withOpacity(0.7),
      alignment: Alignment.center,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.greenAccent, blurRadius: 20),
                ],
              ),
              child: const Icon(Icons.flag, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 14),
            Text(
              t('summaryTitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isFinal ? t('finalDesc') : t('stepComplete'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.greenAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFinal
                    ? Colors.orange
                    : const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                isFinal ? t('resetBtn') : t('nextScenario'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                _playSound('snap');
                if (isFinal) {
                  setState(() {
                    _isCurtainUp = false;
                    _loadScenario(1);
                  });
                } else {
                  _loadScenario(_scenario + 1);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// === CANVAS RENDERER ===

class CanvasPainter extends CustomPainter {
  final _Cl6M_Ch2_A6_AnglesinRealWorldContextsState state;
  final Animation<double> ticker;

  CanvasPainter({required this.state, required this.ticker})
    : super(repaint: ticker);

  void _drawLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Color color,
    double width, {
    bool dashed = false,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    if (!dashed) {
      canvas.drawLine(p1, p2, paint);
    } else {
      double dashWidth = 8, dashSpace = 8;
      double distance = (p2 - p1).distance;
      double dx = (p2.dx - p1.dx) / distance;
      double dy = (p2.dy - p1.dy) / distance;
      double curr = 0;
      while (curr < distance) {
        canvas.drawLine(
          Offset(p1.dx + dx * curr, p1.dy + dy * curr),
          Offset(
            p1.dx + dx * (curr + dashWidth),
            p1.dy + dy * (curr + dashWidth),
          ),
          paint,
        );
        curr += dashWidth + dashSpace;
      }
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    double size,
    Color color, {
    bool bold = true,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(
      size.width / 2 + state._panX,
      size.height / 2 + state._panY,
    );
    canvas.scale(state._zoom, state._zoom);

    if (state._scenario == 1) {
      _renderS1(canvas);
    } else if (state._scenario == 2) {
      _renderS2(canvas);
    } else if (state._scenario == 3) {
      _renderS3(canvas);
    } else if (state._scenario == 4) {
      _renderS4(canvas);
    } else if (state._scenario == 5) {
      _renderS5(canvas);
    }

    canvas.restore();
  }

  void _renderS1(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(-2000, -2000, 2000, 2000),
      Paint()..color = const Color(0xFF1E293B),
    );

    // Clock face
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-200, -200, 200, 200),
        const Radius.circular(200),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-190, -190, 190, 190),
        const Radius.circular(190),
      ),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    for (int i = 1; i <= 12; i++) {
      double ang = (i * 30 - 90) * pi / 180;
      _drawText(
        canvas,
        '$i',
        Offset(cos(ang) * 150, sin(ang) * 150),
        24,
        const Color(0xFF0F172A),
      );
    }

    // Hour Hand (3 oclock = 0 rad mathematically)
    _drawLine(canvas, Offset.zero, const Offset(100, 0), Colors.redAccent, 12);

    // Minute Hand
    double minRad = state._s1MinuteAngle * pi / 180;

    // Angle Arc
    double start = minRad < 0 ? minRad : 0.0;
    double end = minRad > 0 ? minRad : 0.0;
    if (end - start > pi) {
      start = end;
      end = (minRad < 0 ? minRad : 0) + pi * 2;
    }
    int diffDeg = ((end - start).abs() * 180 / pi).round();
    if (diffDeg > 180) diffDeg = 360 - diffDeg;

    Color arcColor = const Color(0xFF6366F1).withOpacity(0.4);
    if ((diffDeg == 90 && state._step == 0) ||
        (diffDeg == 30 && state._step == 1) ||
        (diffDeg == 150 && state._step == 2) ||
        (diffDeg == 180 && state._step == 3)) {
      arcColor = Colors.green.withOpacity(0.6);
    }

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 60),
      start,
      end - start,
      true,
      Paint()..color = arcColor,
    );

    // Minute hand draw
    _drawLine(
      canvas,
      Offset.zero,
      Offset(cos(minRad) * 140, sin(minRad) * 140),
      const Color(0xFF0F172A),
      8,
    );
    canvas.drawCircle(
      Offset.zero,
      10,
      Paint()..color = const Color(0xFF0F172A),
    );

    // Info
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-100, 240, 100, 300),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.white,
    );
    _drawText(
      canvas,
      'Angle: $diffDeg°',
      const Offset(0, 270),
      24,
      const Color(0xFF0F172A),
    );

    if (state._activeDragEntity == 'minute') {
      canvas.drawCircle(
        Offset.zero,
        220,
        Paint()
          ..color = const Color(0xFF6366F1).withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 40,
      );
    }
  }

  void _renderS2(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(-2000, -2000, 2000, 200),
      Paint()..color = const Color(0xFFBAE6FD),
    ); // Sky
    canvas.drawRect(
      const Rect.fromLTRB(-2000, 200, 2000, 2000),
      Paint()..color = const Color(0xFFBBF7D0),
    ); // Grass
    _drawLine(
      canvas,
      const Offset(-2000, 200),
      const Offset(2000, 200),
      const Color(0xFF4ADE80),
      4,
    );

    double px = -100, py = -150;
    _drawLine(
      canvas,
      Offset(px - 150, 200),
      Offset(px, py),
      const Color(0xFF94A3B8),
      12,
    );
    _drawLine(
      canvas,
      Offset(px + 150, 200),
      Offset(px, py),
      const Color(0xFF64748B),
      12,
    );
    _drawLine(
      canvas,
      Offset(px - 200, py),
      Offset(px + 200, py),
      const Color(0xFF475569),
      16,
    );

    // Protractor
    canvas.drawArc(
      Rect.fromCircle(center: Offset(px, py), radius: 100),
      pi / 2,
      pi,
      true,
      Paint()..color = Colors.black12,
    );
    for (int i = 0; i <= 90; i += 10) {
      double ang = pi / 2 + i * pi / 180;
      _drawLine(
        canvas,
        Offset(px + cos(ang) * 85, py + sin(ang) * 85),
        Offset(px + cos(ang) * 100, py + sin(ang) * 100),
        const Color(0xFF0F172A),
        2,
      );
      if (i % 30 == 0) {
        _drawText(
          canvas,
          '$i°',
          Offset(px + cos(ang) * 115, py + sin(ang) * 115),
          12,
          const Color(0xFF0F172A),
        );
      }
    }

    // Balloons
    List<Map<String, dynamic>> balloons = [
      {'a': 40.0, 'c': Colors.red},
      {'a': 80.0, 'c': Colors.blue},
      {'a': 110.0, 'c': Colors.amber},
    ];
    for (int i = 0; i < balloons.length; i++) {
      double bA = balloons[i]['a'];
      Color c = balloons[i]['c'];
      double tx = px + cos(pi / 2 - bA * pi / 180) * 250;
      double ty = py + sin(pi / 2 - bA * pi / 180) * 250;

      canvas.drawOval(
        Rect.fromCenter(center: Offset(tx, ty), width: 40, height: 50),
        Paint()..color = c,
      );
      _drawLine(
        canvas,
        Offset(tx, ty + 25),
        Offset(tx, ty + 60),
        Colors.black,
        1,
      );

      if (state._step == i) {
        canvas.drawCircle(
          Offset(tx, ty),
          35,
          Paint()
            ..color = c
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
      }
    }

    // Swing
    double dispAngle = state._s2SwingAngle;
    double seatX = px + cos(dispAngle * pi / 180) * 250;
    double seatY = py + sin(dispAngle * pi / 180) * 250;

    _drawLine(
      canvas,
      Offset(px, py),
      Offset(seatX, seatY),
      const Color(0xFF0F172A),
      4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(seatX, seatY), width: 50, height: 10),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.brown,
    );
    // Vidya
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(seatX, seatY - 20),
          width: 20,
          height: 35,
        ),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.pinkAccent,
    );
    canvas.drawCircle(
      Offset(seatX, seatY - 45),
      15,
      Paint()..color = Colors.amberAccent,
    );

    // UI Readout
    double readAng = (state._s2SwingAngle - 90).abs();
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(200, 220, 350, 270),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.white,
    );
    _drawText(
      canvas,
      '${readAng.round()}°',
      const Offset(275, 245),
      24,
      const Color(0xFF0F172A),
    );

    bool valid =
        state._s2State == 'idle' &&
        ((state._step == 0 && (readAng - 40).abs() < 5) ||
            (state._step == 1 && (readAng - 80).abs() < 5) ||
            (state._step == 2 && (readAng - 110).abs() < 5));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(370, 220, 490, 270),
        const Radius.circular(25),
      ),
      Paint()..color = valid ? Colors.green : Colors.grey,
    );
    _drawText(
      canvas,
      state.t('lbl_push'),
      const Offset(430, 245),
      18,
      const Color(0xFF0F172A),
    );
  }

  void _renderS3(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(-2000, -2000, 2000, 2000),
      Paint()..color = const Color(0xFF1E293B),
    );

    double hx = -50, hy = 100;
    _drawLine(
      canvas,
      Offset(-500, hy),
      Offset(hx, hy),
      const Color(0xFF475569),
      20,
    );
    _drawLine(
      canvas,
      Offset(hx + 200, hy),
      Offset(500, hy),
      const Color(0xFF475569),
      20,
    );

    double doorAngRad = -state._s3DoorAngle * pi / 180;
    double dEndX = hx + cos(doorAngRad) * 200;
    double dEndY = hy + sin(doorAngRad) * 200;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(hx, hy), radius: 200),
      -pi,
      pi,
      true,
      Paint()..color = Colors.black12,
    );

    _drawLine(
      canvas,
      Offset(hx, hy),
      Offset(dEndX, dEndY),
      Colors.brown[700]!,
      12,
    );

    double knobX = hx + cos(doorAngRad) * 180;
    double knobY = hy + sin(doorAngRad) * 180;
    canvas.drawCircle(Offset(knobX, knobY), 8, Paint()..color = Colors.amber);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(hx - 40, hy + 30, hx + 40, hy + 60),
        const Radius.circular(6),
      ),
      Paint()..color = Colors.white,
    );
    _drawText(
      canvas,
      '${state._s3DoorAngle.round()}°',
      Offset(hx, hy + 45),
      16,
      Colors.black,
    );

    double furnW = 0;
    Color fCol = Colors.transparent;
    String label = '';
    if (state._step == 0) {
      furnW = 60;
      fCol = Colors.blue;
      label = 'Chair';
    }
    if (state._step == 1) {
      furnW = 120;
      fCol = Colors.orange;
      label = 'Box';
    }
    if (state._step == 2) {
      furnW = 180;
      fCol = Colors.green;
      label = 'Sofa';
    }

    if (furnW > 0) {
      double fy = 250 - state._s3AnimY;
      double fx = hx + furnW / 2 + 10;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(fx, fy), width: furnW, height: 60),
          const Radius.circular(8),
        ),
        Paint()..color = fCol,
      );
      _drawText(canvas, label, Offset(fx, fy), 16, Colors.white);
    }
  }

  void _renderS4(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(-2000, -2000, 2000, 200),
      Paint()..color = const Color(0xFFBAE6FD),
    ); // Sky
    canvas.drawRect(
      const Rect.fromLTRB(-2000, 200, 2000, 2000),
      Paint()..color = const Color(0xFFBBF7D0),
    ); // Grass
    _drawLine(
      canvas,
      const Offset(-2000, 200),
      const Offset(2000, 200),
      const Color(0xFF4ADE80),
      4,
    );

    canvas.drawRect(
      const Rect.fromLTRB(-100, 50, 100, 200),
      Paint()..color = Colors.white,
    );
    Path roof = Path()
      ..moveTo(-120, 50)
      ..lineTo(0, -30)
      ..lineTo(120, 50)
      ..close();
    canvas.drawPath(roof, Paint()..color = Colors.red);

    List<Map<String, dynamic>> suns = [
      {'x': -300.0, 'y': 0.0, 'a': 30.0},
      {'x': 0.0, 'y': -250.0, 'a': 90.0},
      {'x': 300.0, 'y': 0.0, 'a': 150.0},
    ];
    var sun = suns[state._step < 3 ? state._step : 2];

    canvas.save();
    canvas.translate(sun['x'], sun['y']);
    canvas.drawCircle(Offset.zero, 40, Paint()..color = Colors.amber);
    for (int i = 0; i < 8; i++) {
      double a = i * pi / 4;
      _drawLine(
        canvas,
        Offset(cos(a) * 50, sin(a) * 50),
        Offset(cos(a) * 70, sin(a) * 70),
        Colors.amber,
        6,
      );
    }
    canvas.restore();

    double px = 0, py = -40;
    _drawLine(
      canvas,
      Offset(px, py),
      const Offset(0, 20),
      const Color(0xFF475569),
      8,
    );

    canvas.save();
    canvas.translate(px, py);
    canvas.rotate(-state._s4PanelAngle * pi / 180);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-60, -5, 60, 5),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.blue[900]!,
    );
    for (double x = -50; x <= 50; x += 25) {
      _drawLine(canvas, Offset(x, -5), Offset(x, 5), Colors.blue[300]!, 1);
    }
    canvas.restore();

    canvas.drawArc(
      Rect.fromCircle(center: Offset(px, py), radius: 80),
      -pi,
      pi,
      true,
      Paint()..color = Colors.white54,
    );
    double lx = px + cos(-state._s4PanelAngle * pi / 180) * 90;
    double ly = py + sin(-state._s4PanelAngle * pi / 180) * 90;
    canvas.drawCircle(Offset(lx, ly), 12, Paint()..color = Colors.redAccent);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(250, 100, 410, 190),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.white,
    );
    _drawText(canvas, 'POWER', const Offset(330, 120), 16, Colors.black);

    double diff = (state._s4PanelAngle - sun['a']).abs();
    double power = max(0.0, 100.0 - diff * 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(270, 140, 390, 160),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.grey[300]!,
    );
    Color pCol = power > 80
        ? Colors.green
        : (power > 40 ? Colors.amber : Colors.red);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(270, 140, 270 + 120 * (power / 100), 160),
        const Radius.circular(10),
      ),
      Paint()..color = pCol,
    );
  }

  void _renderS5(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(-2000, -2000, 2000, 2000),
      Paint()..color = const Color(0xFF451A03),
    );

    List<Offset> pts = [
      const Offset(-300, -150),
      Offset(-100, state._s5J1y),
      Offset(100, state._s5J2y),
      const Offset(300, 150),
    ];

    for (int i = 0; i < 3; i++) {
      _drawLine(
        canvas,
        pts[i],
        Offset(pts[i].dx, 300),
        const Color(0xFFA1A1AA),
        20,
        dashed: true,
      );
    }
    _drawLine(
      canvas,
      pts[3],
      Offset(pts[3].dx, 300),
      const Color(0xFFA1A1AA),
      20,
      dashed: true,
    );

    for (int i = 0; i < 3; i++) {
      _drawLine(canvas, pts[i], pts[i + 1], Colors.blue[600]!, 16);
      _drawLine(canvas, pts[i], pts[i + 1], Colors.blue[300]!, 8);
    }

    for (int i = 1; i <= 2; i++) {
      canvas.drawCircle(
        pts[i],
        16,
        Paint()
          ..color = state._activeDragEntity == 'j$i'
              ? Colors.amber
              : Colors.redAccent,
      );
      double ang =
          atan2(pts[i].dy - pts[i - 1].dy, pts[i].dx - pts[i - 1].dx) *
          180 /
          pi;
      _drawText(
        canvas,
        '${ang.round()}°',
        Offset(pts[i - 1].dx + 40, pts[i - 1].dy - 20),
        16,
        Colors.white,
      );
    }
    double ang3 =
        atan2(pts[3].dy - pts[2].dy, pts[3].dx - pts[2].dx) * 180 / pi;
    _drawText(
      canvas,
      '${ang3.round()}°',
      Offset(pts[2].dx + 40, pts[2].dy - 20),
      16,
      Colors.white,
    );

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTRB(270, 140, 330, 190),
        bottomLeft: const Radius.circular(10),
        bottomRight: const Radius.circular(10),
      ),
      Paint()..color = Colors.white,
    );

    if (state._s5BallActive) {
      Offset p0 = pts[state._s5BallSegment];
      Offset p1 = pts[state._s5BallSegment + 1];
      double bx = p0.dx + (p1.dx - p0.dx) * state._s5BallProgress;
      double by = p0.dy + (p1.dy - p0.dy) * state._s5BallProgress;
      canvas.drawCircle(
        Offset(bx, by - 12),
        12,
        Paint()..color = Colors.greenAccent,
      );
    } else {
      canvas.drawCircle(
        Offset(pts[0].dx, pts[0].dy - 12),
        12,
        Paint()..color = Colors.greenAccent,
      );
    }

    Color btnCol = state._s5BallActive ? Colors.grey : Colors.green;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-50, 220, 90, 270),
        const Radius.circular(25),
      ),
      Paint()..color = btnCol,
    );
    _drawText(
      canvas,
      state.t('lbl_test'),
      const Offset(20, 245),
      18,
      Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
