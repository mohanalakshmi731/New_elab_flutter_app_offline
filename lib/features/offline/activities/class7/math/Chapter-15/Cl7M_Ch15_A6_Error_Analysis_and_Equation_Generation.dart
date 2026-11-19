// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FactoryApp());
}

class FactoryApp extends StatelessWidget {
  const FactoryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Equation Factory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      home: const FactoryHome(),
    );
  }
}

class FactoryHome extends StatefulWidget {
  const FactoryHome({Key? key}) : super(key: key);

  @override
  State<FactoryHome> createState() => _FactoryHomeState();
}

class _FactoryHomeState extends State<FactoryHome> with SingleTickerProviderStateMixin {
  bool _isSidebarOpen = true;
  String _lang = 'en';
  int _currentScenario = 0;
  int _currentStep = 0;
  bool _isDarkMode = true;

  // Camera & Interaction
  double _cameraX = 0;
  double _cameraY = -40;
  double _cameraScale = 0.85;
  bool _isPanLocked = false;

  // Audio System
  static final AudioPlayer _tickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _snapPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _urlTick = 'audio/class7/mixkit_2568.mp3';
  static const String _urlSnap = 'audio/class7/mixkit_392.mp3';
  static const String _urlSuccess = 'audio/class7/mixkit_2018.mp3';
  static const String _urlError = 'audio/class7/mixkit_955.mp3';
  static const String _urlPop = 'audio/class7/mixkit_2357.mp3';
  static const String _urlEnter = 'audio/class7/mixkit_2574.mp3';

  // Game Engine State
  late Ticker _ticker;
  double _time = 0.0;
  bool _beltMoving = false;
  String _currentEquation = "";
  List<Entity> _entities = [];
  List<DropZone> _dropZones = [];
  List<Particle> _particles = [];
  List<Timer> _timers = [];
  
  FlashOp? _flashOp;
  String? _statusIconType;
  double _statusIconLife = 0;

  Entity? _draggedEntity;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  DropZone? _hoverZone;

  bool _showShutter = true;
  double _shutterOffset = 0.0;
  bool _showActionBtn = false;
  String _actionBtnText = "";

  // Translations
  final Map<String, Map<String, dynamic>> _i18n = {
    'en': {
      'title': "The Equation Factory",
      'subtitle': "Class 7 • FINDING THE UNKNOWN",
      'enterLab': "Enter Facility",
      'selectScenario': "Select Factory Floor",
      'missionObj': "Mission Objective",
      'missionProg': "MISSION PROGRESS",
      'footer': "© ZeroScienceLab - Fall in love with math and Science",
      'btnRestart': "RESTART MACHINE",
      'btnFinish': "FINISH & VERIFY",
      'scenarios': [
        {
          'title': "1. The Faulty Adder",
          'objective': "Identify and correct an incorrect operation (addition instead of subtraction) in a one-variable equation.",
          'hudSteps': [
            "Watch the machine process the equation...",
            "System Halted. Click the glowing red arm to inspect.",
            "Replace the faulty [+] gear with the [-] gear.",
            "Machine repaired! Click Restart.",
            "Diagnostics Passed: Equation Solved!"
          ]
        },
        {
          'title': "2. The Sign Inverter Glitch",
          'objective': "Identify and correct a sign error that occurs during the distribution of a negative number.",
          'hudSteps': [
            "Watch the Distributor Laser in action...",
            "System Halted. Click the glowing red laser to inspect.",
            "Toggle the Sign Inverter switch to ON.",
            "Settings Updated! Click Restart.",
            "Diagnostics Passed: Equation Solved!"
          ]
        },
        {
          'title': "3. The Variable Transporter Error",
          'objective': "Identify and correct an error made when consolidating variable terms from both sides of an equation.",
          'hudSteps': [
            "Watch the Magnetic Crane transport the variable...",
            "System Halted. Click the glowing crane base to inspect.",
            "Rotate the operation dial to the [-] setting.",
            "Calibration fixed! Click Restart.",
            "Diagnostics Passed: Equation Solved!"
          ]
        },
        {
          'title': "4. Build-An-Equation: Lvl 1",
          'objective': "Construct a two-step equation where the solution is y = 5.",
          'hudSteps': [
            "Drag the [y] block to the start platform.",
            "Drag the [*3] block to Station 1.",
            "Drag the [+6] block to Station 2.",
            "Click Finish & Verify to submit.",
            "Build Successful! Solution is y = 5."
          ]
        },
        {
          'title': "5. Build-An-Equation: Expert",
          'objective': "Construct a multi-step equation involving brackets where the solution is x = -2.",
          'hudSteps': [
            "Drag the [x] block to the start platform.",
            "Drag the [+6] block to Station 1.",
            "Drag the [*4] block to Station 2.",
            "Drag the [-8] block to Station 3.",
            "Click Finish & Verify to submit.",
            "Build Successful! Solution is x = -2."
          ]
        }
      ]
    },
    'hi': {
      'title': "समीकरण कारखाना",
      'subtitle': "कक्षा 7 • अज्ञात का पता लगाना",
      'enterLab': "सुविधा में प्रवेश करें",
      'selectScenario': "फ़ैक्टरी फ़्लोर चुनें",
      'missionObj': "मिशन उद्देश्य",
      'missionProg': "मिशन प्रगति",
      'footer': "© ZeroScienceLab - Fall in love with math and Science",
      'btnRestart': "मशीन पुनः आरंभ करें",
      'btnFinish': "समाप्त करें और सत्यापित करें",
      'scenarios': [
        {
          'title': "1. दोषपूर्ण योजक",
          'objective': "एक चर समीकरण में गलत ऑपरेशन की पहचान करें और उसे ठीक करें।",
          'hudSteps': ["मशीन को देखें...", "सिस्टम रुका हुआ है। चमकते हाथ पर क्लिक करें।", "दोषपूर्ण [+] गियर को [-] गियर से बदलें।", "मशीन की मरम्मत! रीस्टार्ट पर क्लिक करें।", "समीकरण हल हो गया!"]
        },
        {
          'title': "2. साइन इन्वर्टर ग्लिच",
          'objective': "नकारात्मक संख्या के वितरण के दौरान होने वाली संकेत त्रुटि को पहचानें।",
          'hudSteps': ["लेजर को देखें...", "सिस्टम रुका हुआ है। चमकते लेजर पर क्लिक करें।", "स्विच को ON करें।", "रीस्टार्ट पर क्लिक करें।", "समीकरण हल हो गया!"]
        },
        {
          'title': "3. चर ट्रांसपोर्टर त्रुटि",
          'objective': "चर को एक तरफ से दूसरी तरफ ले जाते समय हुई त्रुटि को ठीक करें।",
          'hudSteps': ["क्रैन को देखें...", "चमकते क्रैन बेस पर क्लिक करें।", "डायल को [-] सेटिंग पर घुमाएं।", "रीस्टार्ट पर क्लिक करें।", "समीकरण हल हो गया!"]
        },
        {
          'title': "4. समीकरण बनाएं: स्तर 1",
          'objective': "एक दो-चरणीय समीकरण बनाएं जिसका हल y = 5 हो।",
          'hudSteps': ["[y] ब्लॉक को स्टार्ट प्लेटफॉर्म पर खींचें।", "[*3] ब्लॉक को स्टेशन 1 पर खींचें।", "[+6] ब्लॉक को स्टेशन 2 पर खींचें।", "समाप्त करें पर क्लिक करें।", "निर्माण सफल!"]
        },
        {
          'title': "5. समीकरण बनाएं: विशेषज्ञ",
          'objective': "ब्रैकेट वाले बहु-चरणीय समीकरण का निर्माण करें जहां हल x = -2 हो।",
          'hudSteps': ["[x] ब्लॉक को स्टार्ट प्लेटफॉर्म पर खींचें।", "[+6] ब्लॉक को स्टेशन 1 पर खींचें।", "[*4] ब्लॉक को स्टेशन 2 पर खींचें।", "[-8] ब्लॉक को स्टेशन 3 पर खींचें।", "समाप्त करें पर क्लिक करें।", "निर्माण सफल!"]
        }
      ]
    }
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _ticker = createTicker((elapsed) {
      if (!mounted) return;
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0;
        _updatePhysics();
      });
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
    _clearTimers();
    _tickPlayer.dispose();
    _snapPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _fxPlayer.dispose();
    super.dispose();
  }

  void _playSound(String name) async {
    try {
      if (name == 'tick') await _tickPlayer.play(AssetSource(_urlTick));
      else if (name == 'snap') await _snapPlayer.play(AssetSource(_urlSnap));
      else if (name == 'success') await _successPlayer.play(AssetSource(_urlSuccess));
      else if (name == 'error') await _errorPlayer.play(AssetSource(_urlError));
      else if (name == 'pop') await _fxPlayer.play(AssetSource(_urlPop));
      else if (name == 'enter') await _fxPlayer.play(AssetSource(_urlEnter));
    } catch (e) {
      // Ignore
    }
  }

  void _clearTimers() {
    for (var t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  void _schedule(int ms, VoidCallback action) {
    _timers.add(Timer(Duration(milliseconds: ms), () {
      if (mounted) {
        setState(() { action(); });
      }
    }));
  }

  void _enterLab() {
    _playSound('enter');
    setState(() {
      _shutterOffset = -MediaQuery.of(context).size.height;
    });
    _schedule(1200, () {
      _showShutter = false;
      _loadScenario(0);
      _ticker.start();
    });
  }

  void _resetLab() {
    _playSound('tick');
    setState(() {
      _lang = 'en'; // Reset language as requested
      _ticker.stop();
      _showShutter = true;
      _shutterOffset = 0.0;
      _clearTimers();
      _entities.clear();
      _dropZones.clear();
      _particles.clear();
      _currentEquation = "";
    });
  }

  void _loadScenario(int index) {
    _clearTimers();
    setState(() {
      _currentScenario = index;
      _currentStep = 0;
      _entities.clear();
      _dropZones.clear();
      _particles.clear();
      _flashOp = null;
      _statusIconType = null;
      _showActionBtn = false;
      _beltMoving = false;
      _currentEquation = "";

      if (index == 0) _setupS1();
      else if (index == 1) _setupS2();
      else if (index == 2) _setupS3();
      else if (index == 3) _setupS4();
      else if (index == 4) _setupS5();

      _cameraX = 0;
      _cameraY = MediaQuery.of(context).size.width < 800 ? -20 : -40; // Adjust camera up for visibility
      _cameraScale = 0.85;

      if (index < 3) {
        _schedule(1000, () => _triggerErrorAnim(index));
      }
    });
  }

  void _triggerErrorAnim(int sc) {
    _beltMoving = true;
    if (sc == 0) {
      _currentEquation = "4x + 6 = 10";
      var block = _entities.where((e) => e.id == 'term_block').firstOrNull;
      var arm = _entities.where((e) => e.id == 'arm').firstOrNull;

      _schedule(500, () => block?.targetX = 0);
      _schedule(1500, () => arm?.targetPistonY = 25);
      _schedule(2200, () {
        arm?.targetPistonY = -20;
        block?.targetX = 150;
        block?.color = Colors.redAccent;
      });
      _schedule(3200, () {
        _beltMoving = false;
        _currentEquation = "4x = 10 [R]- 6[/R]";
        _playSound('error');
        _showStatusIcon('error');
        if (arm != null) {
          arm.glow = true;
          arm.onClick = () { _advanceStep(); };
        }
        if (_currentStep == 0) _currentStep = 1;
      });
    } else if (sc == 1) {
      _currentEquation = "-2(3 - 4x) = 14";
      var block = _entities.where((e) => e.id == 'term_block').firstOrNull;
      var laser = _entities.where((e) => e.id == 'laser').firstOrNull;

      _schedule(500, () => block?.targetX = 0);
      _schedule(1500, () => laser?.laserActive = true);
      _schedule(2000, () => block?.val = "-6 - 4x");
      _schedule(2800, () {
        laser?.laserActive = false;
        if (block != null) {
          block.val = "-6 - 8x";
          block.w = 140;
          block.color = Colors.redAccent;
        }
        _currentEquation = "-6 [R]- 8x[/R] = 14";
      });
      _schedule(3800, () {
        _beltMoving = false;
        if (laser != null) {
          laser.glow = true;
          laser.onClick = () { _advanceStep(); };
        }
        _playSound('error');
        _showStatusIcon('error');
        if (_currentStep == 0) _currentStep = 1;
      });
    } else if (sc == 2) {
      _currentEquation = "5z + 2 = 3z - 4";
      var crane = _entities.where((e) => e.id == 'crane').firstOrNull;
      var block = _entities.where((e) => e.id == 'term_block').firstOrNull;

      _schedule(500, () => crane?.targetCartX = 200);
      _schedule(1500, () => crane?.targetDropY = 10);
      _schedule(2200, () {
        crane?.targetDropY = -30;
        block?.targetY = -15;
      });
      _schedule(2800, () {
        crane?.targetCartX = -200;
        block?.targetX = -200;
      });
      _schedule(3600, () {
        crane?.targetDropY = 10;
        if (block != null) {
          block.targetY = 25;
          block.color = Colors.redAccent;
          block.val = "+3z";
        }
        _flashOp = FlashOp(op: '+', x: -200, y: -20, life: 1.0, color: Colors.redAccent);
        _playSound('error');
        _currentEquation = "5z [R]+ 3z[/R] + 2 = -4";
      });
      _schedule(4600, () {
        _beltMoving = false;
        if (crane != null) {
          crane.targetDropY = -40;
          crane.glow = true;
          crane.onClick = () { _advanceStep(); };
        }
        _currentEquation = "8z + 2 = -4";
        _showStatusIcon('error');
        if (_currentStep == 0) _currentStep = 1;
      });
    }
  }

  void _setupS1() {
    _currentEquation = "4x + 6 = 10";
    _entities.add(Entity(id: 'arm', type: 'arm_base', x: 0, y: -20, hitR: 80, hitY: -60));
    _entities.add(Entity(id: 'term_block', type: 'block', val: '+6', x: -350, y: 25, color: Colors.blueAccent, targetX: -350, targetY: 25));
  }
  
  void _setupS2() {
    _currentEquation = "-2(3 - 4x) = 14";
    _entities.add(Entity(id: 'laser', type: 'laser', x: 0, y: 0, hitR: 80, hitY: -140));
    _entities.add(Entity(id: 'term_block', type: 'block', val: '(3 - 4x)', w: 120, x: -350, y: 25, color: Colors.blueAccent, targetX: -350, targetY: 25));
  }
  
  void _setupS3() {
    _currentEquation = "5z + 2 = 3z - 4";
    _entities.add(Entity(id: 'crane', type: 'crane', x: 0, y: 0, dropY: -40));
    _entities.add(Entity(id: 'term_block', type: 'block', val: '3z', x: 200, y: 25, color: Colors.blueAccent, targetX: 200, targetY: 25));
  }
  
  void _setupS4() {
    // Blocks added all at once like HTML
    _entities.add(Entity(type: 'toolbox', x: 0, y: 130, w: 400));
    _entities.add(Entity(id: 'b_y', type: 'block', val: 'y', x: -150, y: 130, color: Colors.blueAccent, isDraggable: true));
    _entities.add(Entity(id: 'b_m3', type: 'block', val: '*3', x: 0, y: 130, color: Colors.purpleAccent, isDraggable: true));
    _entities.add(Entity(id: 'b_a6', type: 'block', val: '+6', x: 150, y: 130, color: Colors.greenAccent, isDraggable: true));
    
    // Dropzones added all at once like HTML
    _dropZones.add(DropZone(id: 'z0', x: -250, y: 15, r: 40, label: 'START', accepts: 'y', onDrop: (e) {
      if (_currentStep == 0) { _currentEquation = "y = 5"; _advanceStep(); return true; } return false;
    }));
    _dropZones.add(DropZone(id: 'z1', x: 0, y: 15, r: 40, label: 'STATION 1', accepts: '*3', onDrop: (e) {
      if (_currentStep == 1) { _currentEquation = "3y = 15"; _advanceStep(); return true; } return false;
    }));
    _dropZones.add(DropZone(id: 'z2', x: 250, y: 15, r: 40, label: 'STATION 2', accepts: '+6', onDrop: (e) {
      if (_currentStep == 2) { _currentEquation = "3y + 6 = 21"; _advanceStep(); return true; } return false;
    }));
  }

  void _setupS5() {
    _entities.add(Entity(type: 'toolbox', x: 0, y: 130, w: 480));
    _entities.add(Entity(id: 'b_x', type: 'block', val: 'x', x: -200, y: 130, color: Colors.blueAccent, isDraggable: true));
    _entities.add(Entity(id: 'b_a6', type: 'block', val: '+6', x: -70, y: 130, color: Colors.greenAccent, isDraggable: true));
    _entities.add(Entity(id: 'b_m4', type: 'block', val: '*4', x: 60, y: 130, color: Colors.purpleAccent, isDraggable: true));
    _entities.add(Entity(id: 'b_s8', type: 'block', val: '-8', x: 190, y: 130, color: Colors.redAccent, isDraggable: true));

    _dropZones.add(DropZone(id: 'z0', x: -280, y: 15, r: 35, label: 'START', accepts: 'x', onDrop: (e) {
      if (_currentStep == 0) { _currentEquation = "x = -2"; _advanceStep(); return true; } return false;
    }));
    _dropZones.add(DropZone(id: 'z1', x: -100, y: 15, r: 35, label: 'STATION 1', accepts: '+6', onDrop: (e) {
      if (_currentStep == 1) { _currentEquation = "x + 6 = 4"; _advanceStep(); return true; } return false;
    }));
    _dropZones.add(DropZone(id: 'z2', x: 80, y: 15, r: 35, label: 'STATION 2', accepts: '*4', onDrop: (e) {
      if (_currentStep == 2) { _currentEquation = "4(x + 6) = 16"; _advanceStep(); return true; } return false;
    }));
    _dropZones.add(DropZone(id: 'z3', x: 260, y: 15, r: 35, label: 'STATION 3', accepts: '-8', onDrop: (e) {
      if (_currentStep == 3) { _currentEquation = "4(x + 6) - 8 = 8"; _advanceStep(); return true; } return false;
    }));
  }

  void _advanceStep() {
    _playSound('success');
    setState(() {
      _currentStep++;
      int sc = _currentScenario;

      if (sc == 0 && _currentStep == 2) {
        var arm = _entities.where((e) => e.id == 'arm').firstOrNull;
        if (arm != null) { arm.glow = false; arm.onClick = null; }
        _entities.add(Entity(id: 'pnl', type: 'pnl', label: 'MODULE_BAY', x: 0, y: -90));
        _entities.add(Entity(id: 'g_bad', type: 'gear', val: '+', color: Colors.redAccent, x: 0, y: -90));
        _entities.add(Entity(id: 'tb', type: 'toolbox', x: 0, y: 140, w: 200));
        _entities.add(Entity(id: 'g_good', type: 'gear', val: '-', color: Colors.blueAccent, x: 0, y: 140, isDraggable: true));
        _dropZones.add(DropZone(id: 'g_slot', x: 0, y: -90, r: 40, label: '', accepts: '-', onDrop: (e) {
          if (_currentStep == 2) {
            _entities.removeWhere((x) => x.id == 'g_bad');
            e.color = Colors.greenAccent; e.isDraggable = false;
            _dropZones.clear();
            _entities.where((x) => x.id == 'pnl').first.isFixed = true;
            _schedule(1000, () {
              _entities.removeWhere((x) => ['pnl', 'tb', 'g_good'].contains(x.id));
              _advanceStep();
            });
            return true;
          }
          return false;
        }));
      } else if (sc == 1 && _currentStep == 2) {
        var laser = _entities.where((e) => e.id == 'laser').firstOrNull;
        if (laser != null) { laser.glow = false; laser.onClick = null; }
        _entities.add(Entity(id: 'pnl', type: 'pnl', label: 'SIGN INVERTER', x: 0, y: -100));
        _entities.add(Entity(id: 'sw', type: 'switch', state: 'OFF', label: 'Negative × Negative = Positive', x: 0, y: -100, hitR: 50, glow: true, onClick: () {
          if (_currentStep == 2) {
            var sw = _entities.where((e) => e.id == 'sw').first;
            sw.state = 'ON'; sw.onClick = null; sw.glow = false;
            _playSound('pop');
            _entities.where((e) => e.id == 'pnl').first.isFixed = true;
            _schedule(1000, () {
              _entities.removeWhere((e) => ['sw', 'pnl'].contains(e.id));
              _advanceStep();
            });
          }
        }));
      } else if (sc == 2 && _currentStep == 2) {
        var crane = _entities.where((e) => e.id == 'crane').firstOrNull;
        if (crane != null) { crane.glow = false; crane.onClick = null; }
        _entities.add(Entity(id: 'pnl', type: 'pnl', label: 'POLARITY', x: 0, y: -100));
        _entities.add(Entity(id: 'dial', type: 'dial', angle: math.pi/2, x: 0, y: -100, isDraggable: true, hitR: 60));
      }

      // Consistently show action button one step before the final success text
      final hudSteps = _i18n[_lang]!['scenarios'][_currentScenario]['hudSteps'] as List;
      if (_currentStep == hudSteps.length - 2) {
        _showActionBtn = true;
        _actionBtnText = sc < 3 ? _i18n[_lang]!['btnRestart'] : _i18n[_lang]!['btnFinish'];
      }
    });
  }

  void _handleActionBtn() {
    _playSound('enter');
    setState(() {
      _showActionBtn = false;
      int sc = _currentScenario;

      if (sc < 3) {
        _entities.removeWhere((e) => ['pnl', 'g_good', 'tb', 'sw', 'dial'].contains(e.id));
        _beltMoving = true;

        if (sc == 0) {
          _entities.removeWhere((e) => e.id == 'term_block');
          _currentEquation = "4x = 10 [G]- 6[/G]";
          _schedule(1500, () { _currentEquation = "4x = 4"; });
          _schedule(2500, () { _currentEquation = "x = 1"; _finishScenario(); });
        } else if (sc == 1) {
          var laser = _entities.where((e) => e.id == 'laser').firstOrNull;
          if (laser != null) { laser.laserActive = true; laser.glowColor = Colors.greenAccent; }
          var block = _entities.where((e) => e.id == 'term_block').firstOrNull;
          _schedule(500, () { if (block != null) { block.val = '-6 - 4x'; block.color = Colors.blueAccent; } });
          _schedule(1500, () {
            if (block != null) { block.val = '-6 + 8x'; block.color = Colors.greenAccent; }
            _currentEquation = "-6 [G]+ 8x[/G] = 14";
            if (laser != null) laser.laserActive = false;
          });
          _schedule(3000, () {
            if (block != null) block.targetX = 400;
            _currentEquation = "8x = 20";
          });
          _schedule(4500, () { _currentEquation = "x = 2.5"; _finishScenario(); });
        } else if (sc == 2) {
          var crane = _entities.where((e) => e.id == 'crane').firstOrNull;
          if (crane != null) { crane.targetDropY = -40; crane.targetCartX = 200; }
          _entities.removeWhere((e) => e.id == 'term_block');
          _entities.add(Entity(id: 'term_block', type: 'block', val: '3z', x: 200, y: 25, color: Colors.blueAccent, targetX: 200, targetY: 25));
          var block = _entities.where((e) => e.id == 'term_block').firstOrNull;

          _schedule(1000, () => crane?.targetDropY = 10);
          _schedule(1600, () { crane?.targetDropY = -30; block?.targetY = -15; });
          _schedule(2200, () { crane?.targetCartX = -200; block?.targetX = -200; });
          _schedule(3000, () {
            crane?.targetDropY = 10;
            if (block != null) { block.targetY = 25; block.color = Colors.greenAccent; block.val = '-3z'; }
            _flashOp = FlashOp(op: '-', x: -200, y: -20, life: 1.0, color: Colors.greenAccent);
            _playSound('snap');
            _currentEquation = "5z [G]- 3z[/G] + 2 = -4";
          });
          _schedule(4000, () { crane?.targetDropY = -40; _currentEquation = "2z + 2 = -4"; });
          _schedule(5000, () { _currentEquation = "z = -3"; _finishScenario(); });
        }
      } else if (sc == 3) {
        _beltMoving = true;
        _currentEquation = "3y + 6 [G]- 6[/G] = 21 [G]- 6[/G]";
        _schedule(1500, () => _currentEquation = "3y = 15");
        _schedule(3000, () => _currentEquation = "(3y)/[G]3[/G] = 15/[G]3[/G]");
        _schedule(4500, () { _currentEquation = "y = 5"; _finishScenario(); });
      } else if (sc == 4) {
        _beltMoving = true;
        _currentEquation = "4(x + 6) - 8 [G]+ 8[/G] = 8 [G]+ 8[/G]";
        _schedule(1500, () => _currentEquation = "4(x + 6) = 16");
        _schedule(3000, () => _currentEquation = "4(x + 6)/[G]4[/G] = 16/[G]4[/G]");
        _schedule(4500, () => _currentEquation = "x + 6 = 4");
        _schedule(6000, () => _currentEquation = "x + 6 [G]- 6[/G] = 4 [G]- 6[/G]");
        _schedule(7500, () { _currentEquation = "x = -2"; _finishScenario(); });
      }
    });
  }

  void _finishScenario() {
    _beltMoving = false;
    _showStatusIcon('success');
    _spawnParticles(0, 0, Colors.greenAccent);
    _spawnParticles(-100, 0, Colors.greenAccent);
    _spawnParticles(100, 0, Colors.greenAccent);
    _advanceStep();
  }

  void _showStatusIcon(String type) {
    setState(() {
      _statusIconType = type;
      _statusIconLife = 1.0;
    });
    _schedule(2000, () {
      setState(() { _statusIconLife = 0; });
    });
  }

  void _spawnParticles(double x, double y, Color c) {
    for (int i = 0; i < 15; i++) {
      _particles.add(Particle(x: x, y: y, vx: (math.Random().nextDouble() - 0.5) * 8, vy: (math.Random().nextDouble() - 0.5) * 8, life: 1, c: c));
    }
  }

  void _updatePhysics() {
    for (var e in _entities) {
      if (e.targetX != null) e.x += (e.targetX! - e.x) * 0.15;
      if (e.targetY != null) e.y += (e.targetY! - e.y) * 0.15;
      if (e.targetPistonY != null) e.pistonY += (e.targetPistonY! - e.pistonY) * 0.15;
      if (e.targetCartX != null) e.cartX += (e.targetCartX! - e.cartX) * 0.15;
      if (e.targetDropY != null) e.dropY += (e.targetDropY! - e.dropY) * 0.15;
    }
    for (int i = _particles.length - 1; i >= 0; i--) {
      var p = _particles[i];
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.2;
      p.life -= 0.04;
      if (p.life <= 0) _particles.removeAt(i);
    }
    if (_flashOp != null) {
      _flashOp!.life -= 0.02;
      if (_flashOp!.life <= 0) _flashOp = null;
    }
  }

  Offset _screenToWorld(Offset localPos, BoxConstraints constraints) {
    final centerX = constraints.maxWidth / 2;
    final centerY = constraints.maxHeight / 2;
    return Offset(
      (localPos.dx - centerX - _cameraX) / _cameraScale,
      (localPos.dy - centerY - _cameraY) / _cameraScale,
    );
  }

  void _handleTapDown(TapDownDetails details, BoxConstraints constraints) {
    if (_isDragging) return;
    final w = _screenToWorld(details.localPosition, constraints);

    for (var e in _entities) {
      if (e.onClick != null) {
        bool isHit = false;
        if (e.type == 'crane') {
          double cx = e.x + e.cartX;
          if ((w.dx - cx).abs() < 100 && w.dy > -220 && w.dy < e.dropY + 50) isHit = true;
        } else if (e.type == 'laser') {
          if ((w.dx - e.x).abs() < 80 && w.dy > -200 && w.dy < 20) isHit = true;
        } else if (e.type == 'arm_base') {
          if ((w.dx - e.x).abs() < 60 && w.dy > -180 && w.dy < e.pistonY + 40) isHit = true;
        } else if (e.type == 'switch') {
           if (math.sqrt(math.pow(w.dx - e.x, 2) + math.pow(w.dy - e.y, 2)) < e.hitR) isHit = true;
        }

        if (isHit) {
          _playSound('tick');
          e.onClick!();
          return;
        }
      }
    }

    // Draggables
    for (int i = _entities.length - 1; i >= 0; i--) {
      var e = _entities[i];
      if (e.isDraggable && !e.locked) {
        double hr = math.max((e.w ?? 70) / 2, e.hitR);
        if (math.sqrt(math.pow(w.dx - e.x, 2) + math.pow(w.dy - e.y, 2)) < hr) {
          _playSound('pop');
          setState(() {
            _draggedEntity = e;
            _dragOffset = Offset(e.x - w.dx, e.y - w.dy);
            _draggedEntity!.startX = e.x;
            _draggedEntity!.startY = e.y;
            _isDragging = true;
            _entities.removeAt(i);
            _entities.add(e);
          });
          return;
        }
      }
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_isDragging && _draggedEntity != null) {
      final w = _screenToWorld(details.localPosition, constraints);
      
      if (_draggedEntity!.type == 'dial') {
        setState(() {
          _draggedEntity!.x = 0;
          _draggedEntity!.y = -100;
          double dx = w.dx - 0;
          double dy = w.dy - (-100);
          _draggedEntity!.angle = math.atan2(dy, dx) + math.pi/2;

          if (dx < -15 && _currentStep == 2) {
            _draggedEntity!.isCorrect = true;
            _draggedEntity!.angle = -math.pi/2;
            _draggedEntity!.isDraggable = false;
            _isDragging = false;
            _playSound('snap');
            _entities.where((x) => x.id == 'pnl').firstOrNull?.isFixed = true;
            _schedule(1000, () {
              _entities.removeWhere((x) => ['dial', 'pnl'].contains(x.id));
              _advanceStep();
            });
          }
        });
        return;
      }

      setState(() {
        _draggedEntity!.x = w.dx + _dragOffset.dx;
        _draggedEntity!.y = w.dy + _dragOffset.dy;
        _hoverZone = null;
        for (var z in _dropZones) {
          if (math.sqrt(math.pow(_draggedEntity!.x - z.x, 2) + math.pow(_draggedEntity!.y - z.y, 2)) < z.r) {
            _hoverZone = z;
            break;
          }
        }
      });
    } else if (!_isPanLocked) {
      setState(() {
        _cameraX += details.delta.dx;
        _cameraY += details.delta.dy;
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_isDragging || _draggedEntity == null) return;
    
    if (_draggedEntity!.type == 'dial') {
       if (!_draggedEntity!.isCorrect) {
          _playSound('error');
          setState(() { _draggedEntity!.angle = math.pi/2; });
       }
       setState(() { _isDragging = false; _draggedEntity = null; });
       return;
    }

    setState(() {
      var item = _draggedEntity!;
      var z = _hoverZone;
      if (z != null && item.val == z.accepts) {
        if (z.onDrop(item)) {
           _playSound('snap');
           _spawnParticles(z.x, z.y, Colors.greenAccent);
           item.x = z.x; item.y = z.y; item.locked = true;
        } else {
           _playSound('error');
           item.x = item.startX; item.y = item.startY;
        }
      } else {
        _playSound('error');
        item.x = item.startX; item.y = item.startY; 
      }
      _isDragging = false;
      _draggedEntity = null;
      _hoverZone = null;
    });
  }

  void _zoom(double factor) {
    setState(() {
      _cameraScale = math.max(0.15, math.min(_cameraScale * factor, 2.0));
    });
  }

  void _fitToScreen() {
    setState(() {
      _cameraX = 0;
      _cameraY = MediaQuery.of(context).size.width <= 768 ? -20 : -40;
      _cameraScale = 0.85; 
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = _i18n[_lang]!;
    final scenarios = tr['scenarios'] as List;
    final currentScenarioData = scenarios[_currentScenario];
    final hudSteps = currentScenarioData['hudSteps'] as List;
    final double sidebarWidth = MediaQuery.of(context).size.width * 0.30;
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          if (isMobile && _isSidebarOpen) {
            setState(() { _isSidebarOpen = false; });
          }
        },
        child: Stack(
          children: [
            // Structural Layout: Sidebar and Canvas strictly side-by-side (Row)
            Row(
              children: [
                // 1. Sliding Sidebar Container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _isSidebarOpen ? sidebarWidth : 0,
                  decoration: BoxDecoration(
                    color: _isDarkMode ? const Color(0xFF0F172A).withOpacity(0.98) : Colors.white.withOpacity(0.98),
                    border: Border(right: BorderSide(color: _isDarkMode ? Colors.white24 : Colors.black12, width: 1)),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(5, 0))],
                  ),
                  child: ClipRect(
                    child: SizedBox(
                      width: sidebarWidth,
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.only(top: 70, left: 20, right: 20, bottom: 20),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                Row(
                                  children: [
                                    const Icon(Icons.factory, color: Colors.indigoAccent, size: 28),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(tr['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _isDarkMode ? Colors.white : Colors.black)),
                                          Text(tr['subtitle'], style: TextStyle(fontSize: 10, color: _isDarkMode ? Colors.white70 : Colors.black54, fontFamily: 'monospace')),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.language, size: 16),
                                      label: Text(_lang.toUpperCase(), style: const TextStyle(fontSize: 12)),
                                      onPressed: () {
                                        _playSound('tick');
                                        setState(() {
                                          if (_lang == 'en') _lang = 'hi';
                                          else _lang = 'en';
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.withOpacity(0.2), foregroundColor: _isDarkMode ? Colors.white : Colors.black),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.refresh, size: 16),
                                      label: const Text('Reset', style: TextStyle(fontSize: 12)),
                                      onPressed: _resetLab,
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.2), foregroundColor: Colors.redAccent),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                
                                Text(tr['selectScenario'].toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white54 : Colors.black54)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: _isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _isDarkMode ? Colors.white24 : Colors.black12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: _currentScenario,
                                      isExpanded: true,
                                      dropdownColor: _isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                                      icon: Icon(Icons.keyboard_arrow_down, color: _isDarkMode ? Colors.white : Colors.black),
                                      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
                                      onChanged: (val) {
                                        if (val != null) _loadScenario(val);
                                      },
                                      items: List.generate(scenarios.length, (index) {
                                        return DropdownMenuItem(value: index, child: Text(scenarios[index]['title']));
                                      }),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                Text(tr['missionObj'].toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigoAccent, letterSpacing: 1)),
                                const SizedBox(height: 8),
                                Text(currentScenarioData['objective'], style: TextStyle(fontSize: 13, color: _isDarkMode ? Colors.white70 : Colors.black87, height: 1.5)),
                                
                                const SizedBox(height: 28),
                                Text(tr['missionProg'].toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigoAccent, letterSpacing: 1)),
                                const SizedBox(height: 12),
                                
                                // Visual Steps
                                ...List.generate(hudSteps.length, (index) {
                                  bool isPast = index < _currentStep;
                                  bool isCurrent = index == _currentStep;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          isPast ? Icons.check_circle : (isCurrent ? Icons.play_circle_filled : Icons.radio_button_unchecked),
                                          color: isPast ? Colors.greenAccent : (isCurrent ? Colors.amber : Colors.white24),
                                          size: 20
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            hudSteps[index],
                                            style: TextStyle(
                                              color: isPast || isCurrent ? Colors.white : Colors.white54,
                                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                              fontSize: 13,
                                            )
                                          )
                                        )
                                      ],
                                    ),
                                  );
                                }),

                                if (_showActionBtn)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24),
                                    child: ElevatedButton(
                                      onPressed: _handleActionBtn,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigoAccent,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(double.infinity, 50),
                                        textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 8,
                                      ),
                                      child: Text(_actionBtnText),
                                    ),
                                  ),
                              ]),
                            ),
                          ),
                          // Pushes the footer exactly to the bottom without breaking scroll layout
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
                                width: double.infinity,
                                decoration: BoxDecoration(border: Border(top: BorderSide(color: _isDarkMode ? Colors.white10 : Colors.black12))),
                                child: Text(
                                  tr['footer'],
                                  style: TextStyle(fontSize: 10, color: _isDarkMode ? Colors.white54 : Colors.black54, fontFamily: 'monospace'),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Responsive Canvas Area alongside Sidebar
                Expanded(
                  child: ClipRect(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onPanUpdate: (details) => _handlePanUpdate(details, constraints),
                          onPanEnd: _handlePanEnd,
                          onTapDown: (details) => _handleTapDown(details, constraints),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isDarkMode ? const [Color(0xFF0F172A), Color(0xFF1E1B4B)] : const [Color(0xFFF1F5F9), Color(0xFFCBD5E1)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // The game engine canvas
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: FactoryPainter(
                                      entities: _entities,
                                      dropZones: _dropZones,
                                      particles: _particles,
                                      flashOp: _flashOp,
                                      cameraX: _cameraX,
                                      cameraY: _cameraY,
                                      cameraScale: _cameraScale,
                                      isDarkMode: _isDarkMode,
                                      time: _time,
                                      beltMoving: _beltMoving,
                                      hoverZone: _hoverZone,
                                    ),
                                  ),
                                ),

                                // Top HUD: Equation Display centered relative to the canvas
                                Positioned(
                                  top: 20,
                                  left: 0,
                                  right: 0,
                                  child: IgnorePointer(
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF020617).withOpacity(0.85),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: _statusIconType == 'success' ? Colors.greenAccent : (_statusIconType == 'error' ? Colors.redAccent : Colors.indigo.withOpacity(0.5)),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(color: _statusIconType == 'success' ? Colors.green.withOpacity(0.5) : (_statusIconType == 'error' ? Colors.red.withOpacity(0.5) : Colors.black45), blurRadius: 20)
                                          ],
                                        ),
                                        child: _buildEquationDisplay(),
                                      ),
                                    ),
                                  ),
                                ),

                                // Zoom Tools HUD
                                Positioned(
                                  top: 90,
                                  right: 16,
                                  child: Column(
                                    children: [
                                      _buildToolBtn(Icons.zoom_in, () => _zoom(1.2)),
                                      const SizedBox(height: 8),
                                      _buildToolBtn(Icons.zoom_out, () => _zoom(1 / 1.2)),
                                      const SizedBox(height: 8),
                                      _buildToolBtn(Icons.fit_screen, _fitToScreen),
                                      const SizedBox(height: 8),
                                      _buildToolBtn(_isPanLocked ? Icons.lock : Icons.lock_open, () { setState(() { _isPanLocked = !_isPanLocked; }); }, isActive: _isPanLocked),
                                    ],
                                  ),
                                ),

                                // Large Status Notification (Check/Cross)
                                // Bottom HUD: Instruction Text
                                Positioned(
                                  bottom: 20,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      width: isMobile ? constraints.maxWidth * 0.9 : 500,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      decoration: BoxDecoration(
                                        color: _isDarkMode ? Colors.black.withOpacity(0.85) : Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: _isDarkMode ? Colors.white24 : Colors.black12),
                                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            hudSteps[_currentStep],
                                            style: TextStyle(fontSize: 16, color: _isDarkMode ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Floating Action Button on Canvas
                                if (_showActionBtn)
                                  Positioned(
                                    bottom: 120,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: ElevatedButton(
                                        onPressed: _handleActionBtn,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigoAccent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                          textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 8,
                                        ),
                                        child: Text(_actionBtnText),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Toggle Button for Sidebar (Absolute Fixed Position at screen edge)
            if (!_showShutter)
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                  color: Colors.orangeAccent,
                  iconSize: 28,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _playSound('tick');
                    setState(() {
                      _isSidebarOpen = !_isSidebarOpen;
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.orange.withOpacity(0.8)),
                    ),
                  ),
                ),
              ),

            // Shutter Intro Screen
            if (_showShutter)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 1200),
                curve: Curves.fastOutSlowIn,
                top: _shutterOffset,
                bottom: -_shutterOffset,
                left: 0,
                right: 0,
                child: Container(
                  color: const Color(0xFF020617),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            tr['title'].toUpperCase(),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 2),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tr['subtitle'],
                          style: const TextStyle(fontSize: 16, color: Colors.white70, fontFamily: 'monospace'),
                        ),
                        const SizedBox(height: 48),
                        ElevatedButton(
                          onPressed: _enterLab,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                            elevation: 12,
                          ),
                          child: Text(tr['enterLab']),
                        )
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

  Widget _buildToolBtn(IconData icon, VoidCallback onTap, {bool isActive = false}) {
    return InkWell(
      onTap: () {
        _playSound('tick');
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? Colors.indigoAccent : (_isDarkMode ? Colors.white10 : Colors.black12),
          shape: BoxShape.circle,
          border: Border.all(color: _isDarkMode ? Colors.white24 : Colors.black12),
        ),
        child: Icon(icon, color: isActive ? Colors.white : (_isDarkMode ? Colors.white : Colors.black87), size: 24),
      ),
    );
  }

  Widget _buildEquationDisplay() {
    List<TextSpan> spans = [];
    String eq = _currentEquation;
    final regex = RegExp(r'\[(R|G)\](.*?)\[/\1\]');
    int lastMatchEnd = 0;
    
    for (var match in regex.allMatches(eq)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: eq.substring(lastMatchEnd, match.start)));
      }
      Color c = match.group(1) == 'R' ? Colors.redAccent : Colors.greenAccent;
      spans.add(TextSpan(text: match.group(2), style: TextStyle(color: c)));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < eq.length) {
      spans.add(TextSpan(text: eq.substring(lastMatchEnd)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigoAccent, fontFamily: 'monospace', letterSpacing: 2),
        children: spans,
      ),
    );
  }
}

class Entity {
  String type;
  String? id;
  double x;
  double y;
  
  double pistonY;
  double? targetPistonY;
  
  double cartX;
  double? targetCartX;
  
  double dropY;
  double? targetDropY;

  double? targetX;
  double? targetY;

  double startX;
  double startY;

  double hitR;
  double hitY;
  double hitX;
  
  String val;
  Color color;
  bool isDraggable;
  bool locked;
  bool glow;
  Color? glowColor;
  bool laserActive;
  bool isFixed;
  String state;
  String label;
  double angle;
  bool isCorrect;
  double? w;

  VoidCallback? onClick;

  Entity({
    required this.type,
    this.id,
    required this.x,
    required this.y,
    this.pistonY = 0,
    this.targetPistonY,
    this.cartX = 0,
    this.targetCartX,
    this.dropY = 0,
    this.targetDropY,
    this.targetX,
    this.targetY,
    this.startX = 0,
    this.startY = 0,
    this.hitR = 50,
    this.hitY = 0,
    this.hitX = 0,
    this.val = "",
    this.color = Colors.grey,
    this.isDraggable = false,
    this.locked = false,
    this.glow = false,
    this.glowColor,
    this.laserActive = false,
    this.isFixed = false,
    this.state = "OFF",
    this.label = "",
    this.angle = 0,
    this.isCorrect = false,
    this.w,
    this.onClick,
  });
}

class DropZone {
  String id;
  double x, y, r;
  String label;
  String accepts;
  bool Function(Entity) onDrop;

  DropZone({required this.id, required this.x, required this.y, required this.r, required this.label, required this.accepts, required this.onDrop});
}

class Particle {
  double x, y, vx, vy, life;
  Color c;
  Particle({required this.x, required this.y, required this.vx, required this.vy, required this.life, required this.c});
}

class FlashOp {
  String op;
  double x, y, life;
  Color color;
  FlashOp({required this.op, required this.x, required this.y, required this.life, required this.color});
}

class FactoryPainter extends CustomPainter {
  final List<Entity> entities;
  final List<DropZone> dropZones;
  final List<Particle> particles;
  final FlashOp? flashOp;
  final double cameraX;
  final double cameraY;
  final double cameraScale;
  final bool isDarkMode;
  final double time;
  final bool beltMoving;
  final DropZone? hoverZone;

  FactoryPainter({
    required this.entities,
    required this.dropZones,
    required this.particles,
    this.flashOp,
    required this.cameraX,
    required this.cameraY,
    required this.cameraScale,
    required this.isDarkMode,
    required this.time,
    required this.beltMoving,
    this.hoverZone,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Use naturally centered layout within the Expanded component constraints
    canvas.translate(size.width / 2 + cameraX, size.height / 2 + cameraY);
    canvas.scale(cameraScale, cameraScale);

    _drawFactoryBase(canvas);

    for (var z in dropZones) {
      _drawZone(canvas, z);
    }

    var sortedEntities = List<Entity>.from(entities)..sort((a, b) {
       int weightA = a.type == 'toolbox' ? 0 : 1;
       int weightB = b.type == 'toolbox' ? 0 : 1;
       if (a.y == b.y) return weightA.compareTo(weightB);
       return a.y.compareTo(b.y);
    });

    for (var e in sortedEntities) {
      _drawEntity(canvas, e);
    }

    if (flashOp != null && flashOp!.life > 0) {
      canvas.save();
      canvas.translate(flashOp!.x, flashOp!.y);
      double s = 1 + (1 - flashOp!.life) * 0.5;
      canvas.scale(s, s);
      final tp = TextPainter(
        text: TextSpan(text: flashOp!.op, style: TextStyle(color: flashOp!.color.withOpacity(flashOp!.life), fontSize: 140, fontWeight: FontWeight.bold, fontFamily: 'monospace', shadows: [Shadow(color: flashOp!.color.withOpacity(flashOp!.life), blurRadius: 40)])),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width/2, -tp.height/2));
      canvas.restore();
    }

    for (var p in particles) {
      canvas.drawCircle(Offset(p.x, p.y), 4, Paint()..color = p.c.withOpacity(math.max(0, p.life)));
    }

    canvas.restore();
  }

  void _drawFactoryBase(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTRB(-600, -300, 600, -120), Paint()..color = isDarkMode ? const Color(0x990F172A) : const Color(0x99CBD5E1));
    canvas.drawRect(const Rect.fromLTRB(-600, -120, 600, -115), Paint()..color = isDarkMode ? const Color(0xFF334155) : const Color(0xFF94A3B8));

    canvas.save();
    canvas.translate(0, 40);

    canvas.drawRRect(RRect.fromLTRBR(-410, 20, 410, 100, const Radius.circular(15)), Paint()..color = const Color(0x66000000));
    canvas.drawRRect(RRect.fromLTRBR(-420, -10, 420, 70, const Radius.circular(12)), Paint()..shader = LinearGradient(colors: isDarkMode ? [const Color(0xFF334155), const Color(0xFF0F172A)] : [const Color(0xFF94A3B8), const Color(0xFF475569)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(const Rect.fromLTRB(0, -10, 0, 70)));
    canvas.drawRRect(RRect.fromLTRBR(-400, 0, 400, 50, const Radius.circular(4)), Paint()..color = const Color(0xFF020617));

    for (double x = -380; x <= 380; x += 40) {
      canvas.drawRRect(RRect.fromLTRBR(x - 5, 0, x + 5, 50, const Radius.circular(3)), Paint()..color = isDarkMode ? const Color(0xFF475569) : const Color(0xFF64748B));
      canvas.drawRect(Rect.fromLTRB(x - 2, 0, x + 1, 50), Paint()..color = const Color(0x1AFFFFFF));
    }

    double offset = beltMoving ? (time * 60) % 80 : 0;
    for (double x = -400 + offset; x < 400; x += 80) {
      if (x < 400) {
        canvas.drawRect(Rect.fromLTRB(x, 0, math.min(x + 40, 400), 50), Paint()..color = const Color(0x14FFFFFF));
      }
    }

    canvas.drawRect(const Rect.fromLTRB(-420, 50, 420, 65), Paint()..color = isDarkMode ? const Color(0xFF1E293B) : const Color(0xFF64748B));
    for (double x = -420; x < 420; x += 40) {
      Path p = Path()..moveTo(x, 50)..lineTo(x + 20, 50)..lineTo(x + 10, 65)..lineTo(x - 10, 65)..close();
      canvas.drawPath(p, Paint()..color = const Color(0xFFF59E0B));
    }

    canvas.drawRect(const Rect.fromLTRB(-350, 65, -320, 215), Paint()..color = isDarkMode ? const Color(0xFF1E293B) : const Color(0xFF475569));
    canvas.drawRect(const Rect.fromLTRB(320, 65, 350, 215), Paint()..color = isDarkMode ? const Color(0xFF1E293B) : const Color(0xFF475569));
    canvas.drawRect(const Rect.fromLTRB(-350, 65, -340, 215), Paint()..color = const Color(0x80000000));
    canvas.drawRect(const Rect.fromLTRB(320, 65, 330, 215), Paint()..color = const Color(0x80000000));

    canvas.restore();
  }

  void _drawZone(Canvas canvas, DropZone z) {
    canvas.save();
    canvas.translate(z.x, z.y);
    
    Path circle = Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: z.r));
    Paint p = Paint()..color = hoverZone == z ? Colors.greenAccent : (isDarkMode ? Colors.white24 : Colors.black26)..style = PaintingStyle.stroke..strokeWidth = 3;
    
    const double dashLen = 8;
    const double gapLen = 8;
    for (var metric in circle.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        canvas.drawPath(metric.extractPath(dist, dist + dashLen), p);
        dist += dashLen + gapLen;
      }
    }

    if (z.label.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(text: z.label, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      double pillW = tp.width + 24;
      double pillH = 22;
      double pillY = z.r + 14;

      canvas.drawRRect(RRect.fromLTRBR(-pillW/2, pillY, pillW/2, pillY + pillH, Radius.circular(pillH/2)), Paint()..color = isDarkMode ? const Color(0xFF0F172A) : Colors.white);
      canvas.drawRRect(RRect.fromLTRBR(-pillW/2, pillY, pillW/2, pillY + pillH, Radius.circular(pillH/2)), Paint()..color = Colors.indigoAccent..style = PaintingStyle.stroke..strokeWidth = 2);
      
      tp.paint(canvas, Offset(-tp.width/2, pillY + (pillH - tp.height)/2));
    }
    
    canvas.restore();
  }

  void _drawEntity(Canvas canvas, Entity e) {
    canvas.save();
    canvas.translate(e.x, e.y);

    if (e.glow) {
      canvas.drawCircle(Offset(e.hitX, e.hitY), e.hitR, Paint()..color = (e.glowColor ?? Colors.redAccent).withOpacity(0.3 + math.sin(time*8)*0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
    }

    if (e.type == 'arm_base') {
      canvas.drawRect(const Rect.fromLTRB(-60, -180, 60, -160), Paint()..color = const Color(0xFF1E293B));
      canvas.drawRRect(RRect.fromLTRBR(-25, -160, 25, -40, const Radius.circular(10)), Paint()..shader = const LinearGradient(colors: [Color(0xFF475569), Color(0xFF1E293B)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(const Rect.fromLTRB(-25, -160, 25, -40)));
      canvas.drawCircle(const Offset(-25, -100), 10, Paint()..color = const Color(0xFF94A3B8));
      canvas.drawCircle(const Offset(25, -100), 10, Paint()..color = const Color(0xFF94A3B8));
      
      canvas.drawRect(Rect.fromLTRB(-10, -50, 10, e.pistonY), Paint()..color = const Color(0xFFCBD5E1));
      canvas.drawRRect(RRect.fromLTRBR(-30, e.pistonY - 10, 30, e.pistonY + 20, const Radius.circular(5)), Paint()..color = const Color(0xFF334155));
      canvas.drawRect(Rect.fromLTRB(-25, e.pistonY - 5, 25, e.pistonY), Paint()..color = const Color(0xFFF59E0B));
    } 
    else if (e.type == 'gear') {
      double rOut = 28, rIn = 20;
      Path p = Path();
      for (int i=0; i<16; i++) {
        double a = i * math.pi / 8;
        double r = i % 2 == 0 ? rOut : rIn;
        if (i==0) p.moveTo(math.cos(a)*r, math.sin(a)*r); else p.lineTo(math.cos(a)*r, math.sin(a)*r);
      }
      p.close();
      canvas.drawPath(p, Paint()..color = e.color);
      canvas.drawCircle(Offset.zero, rIn - 2, Paint()..color = const Color(0x26FFFFFF));
      canvas.drawCircle(Offset.zero, 14, Paint()..color = const Color(0xFF0F172A));
      
      final tp = TextPainter(text: TextSpan(text: e.val, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace')), textDirection: TextDirection.ltr);
      tp.layout(); tp.paint(canvas, Offset(-tp.width/2, -tp.height/2));
    }
    else if (e.type == 'pnl') {
      canvas.drawRRect(RRect.fromLTRBR(-80, -70, 80, 70, const Radius.circular(8)), Paint()..color = const Color(0xFF020617));
      Color bCol = e.isFixed ? Colors.greenAccent : Colors.redAccent;
      canvas.drawRRect(RRect.fromLTRBR(-80, -70, 80, 70, const Radius.circular(8)), Paint()..color = bCol..style = PaintingStyle.stroke..strokeWidth = 3);
      
      canvas.drawPath(Path()..moveTo(-60, -50)..lineTo(-40, -30)..lineTo(-40, 50), Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 4);
      canvas.drawPath(Path()..moveTo(60, -50)..lineTo(40, -30)..lineTo(40, 50), Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 4);

      final tp = TextPainter(text: TextSpan(text: e.label, style: const TextStyle(color: Color(0xFF334155), fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr);
      tp.layout(); tp.paint(canvas, Offset(-tp.width/2, -50));
    }
    else if (e.type == 'laser') {
      canvas.drawRect(const Rect.fromLTRB(-100, -180, 100, -160), Paint()..color = const Color(0xFF1E293B));
      canvas.drawRRect(RRect.fromLTRBR(-40, -160, 40, -110, const Radius.circular(10)), Paint()..color = const Color(0xFF1E40AF));
      canvas.drawRRect(RRect.fromLTRBR(-30, -160, 30, -120, const Radius.circular(5)), Paint()..color = const Color(0xFF3B82F6));
      canvas.drawRect(const Rect.fromLTRB(-20, -120, 20, -105), Paint()..color = const Color(0xFF020617));
      canvas.drawCircle(const Offset(0, -112), 5, Paint()..color = e.laserActive ? (e.glowColor ?? Colors.redAccent) : const Color(0xFF3B82F6));

      if (e.laserActive) {
        Path b = Path()..moveTo(-10, -110)..lineTo(-80, 40)..lineTo(80, 40)..lineTo(10, -110)..close();
        canvas.drawPath(b, Paint()..color = (e.glowColor ?? Colors.redAccent).withOpacity(0.4 + math.sin(time*15)*0.2));
      }
    }
    else if (e.type == 'crane') {
      canvas.drawRect(const Rect.fromLTRB(-450, -200, 450, -180), Paint()..color = const Color(0xFFB45309));
      canvas.drawRect(const Rect.fromLTRB(-450, -180, 450, -165), Paint()..color = const Color(0xFF1E293B));
      
      canvas.save();
      canvas.translate(e.cartX, 0);
      canvas.drawRRect(RRect.fromLTRBR(-30, -190, 30, -165, const Radius.circular(4)), Paint()..color = const Color(0xFF475569));
      canvas.drawLine(const Offset(0, -180), Offset(0, e.dropY - 20), Paint()..color = const Color(0xFF475569)..strokeWidth = 4);
      canvas.drawRRect(RRect.fromLTRBR(-40, e.dropY - 30, 40, e.dropY, const Radius.circular(6)), Paint()..color = const Color(0xFF475569));
      canvas.drawRect(Rect.fromLTRB(-35, e.dropY, -15, e.dropY + 15), Paint()..color = Colors.redAccent);
      canvas.drawRect(Rect.fromLTRB(15, e.dropY, 35, e.dropY + 15), Paint()..color = Colors.redAccent);
      canvas.drawRect(Rect.fromLTRB(-15, e.dropY, 15, e.dropY + 15), Paint()..color = const Color(0xFFE2E8F0));
      canvas.restore();
    }
    else if (e.type == 'switch') {
      canvas.drawRRect(RRect.fromLTRBR(-50, -30, 50, 30, const Radius.circular(15)), Paint()..color = const Color(0xFF1E293B));
      canvas.drawRRect(RRect.fromLTRBR(-45, -25, 45, 25, const Radius.circular(10)), Paint()..color = const Color(0xFF020617));
      
      bool isOn = e.state == 'ON';
      canvas.drawRRect(RRect.fromLTRBR(isOn ? 5 : -45, -25, isOn ? 45 : -5, 25, const Radius.circular(10)), Paint()..color = isOn ? Colors.greenAccent : Colors.redAccent);
      
      final tp = TextPainter(text: TextSpan(text: isOn ? "ON" : "OFF", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace')), textDirection: TextDirection.ltr);
      tp.layout(); tp.paint(canvas, Offset(isOn ? 25 - tp.width/2 : -25 - tp.width/2, -tp.height/2));
      
      final tpDesc = TextPainter(text: TextSpan(text: e.label, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 10)), textDirection: TextDirection.ltr);
      tpDesc.layout(); tpDesc.paint(canvas, Offset(-tpDesc.width/2, 45));
    }
    else if (e.type == 'dial') {
      canvas.drawCircle(Offset.zero, 55, Paint()..color = const Color(0xFF1E293B));
      canvas.drawCircle(Offset.zero, 45, Paint()..color = const Color(0xFF0F172A));
      
      final tpP = TextPainter(text: const TextSpan(text: "+", style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace')), textDirection: TextDirection.ltr);
      tpP.layout(); tpP.paint(canvas, Offset(28 - tpP.width/2, -tpP.height/2));
      final tpM = TextPainter(text: const TextSpan(text: "-", style: TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace')), textDirection: TextDirection.ltr);
      tpM.layout(); tpM.paint(canvas, Offset(-28 - tpM.width/2, -tpM.height/2));

      canvas.save();
      canvas.rotate(e.angle);
      Path p = Path()..moveTo(-6, 10)..lineTo(6, 10)..lineTo(0, -35)..close();
      canvas.drawPath(p, Paint()..color = e.isCorrect ? Colors.greenAccent : Colors.redAccent);
      canvas.drawCircle(Offset.zero, 10, Paint()..color = const Color(0xFFCBD5E1));
      canvas.restore();
    }
    else if (e.type == 'block') {
      double bw = e.w ?? 70;
      canvas.drawRRect(RRect.fromLTRBR(-bw/2, -25, bw/2, 25, const Radius.circular(8)), Paint()..color = e.color);
      canvas.drawRRect(RRect.fromLTRBAndCorners(-bw/2, -25, bw/2, 0, topLeft: const Radius.circular(8), topRight: const Radius.circular(8)), Paint()..color = const Color(0x33FFFFFF));
      canvas.drawRRect(RRect.fromLTRBAndCorners(-bw/2, 0, bw/2, 25, bottomLeft: const Radius.circular(8), bottomRight: const Radius.circular(8)), Paint()..color = const Color(0x33000000));
      canvas.drawRRect(RRect.fromLTRBR(-bw/2, -25, bw/2, 25, const Radius.circular(8)), Paint()..color = const Color(0x4DFFFFFF)..style = PaintingStyle.stroke..strokeWidth = 2);

      final tp = TextPainter(text: TextSpan(text: e.val, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace', shadows: [Shadow(color: Colors.black54, blurRadius: 4)])), textDirection: TextDirection.ltr);
      tp.layout(); tp.paint(canvas, Offset(-tp.width/2, -tp.height/2));
    }
    else if (e.type == 'toolbox') {
      double tw = e.w ?? 380;
      canvas.drawRRect(RRect.fromLTRBR(-tw/2, -40, tw/2, 40, const Radius.circular(15)), Paint()..color = isDarkMode ? const Color(0xFF334155) : const Color(0xFF94A3B8));
      canvas.drawRRect(RRect.fromLTRBR(-tw/2+10, -30, tw/2-10, 30, const Radius.circular(8)), Paint()..color = isDarkMode ? const Color(0xFF020617) : const Color(0xFF475569));
      canvas.drawRRect(RRect.fromLTRBAndCorners(-tw/2, 20, tw/2, 40, bottomLeft: const Radius.circular(15), bottomRight: const Radius.circular(15)), Paint()..color = isDarkMode ? const Color(0xFF1E293B) : const Color(0xFF64748B));
      
      final tp = TextPainter(text: const TextSpan(text: "ASSEMBLY TRAY", style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace')), textDirection: TextDirection.ltr);
      tp.layout(); tp.paint(canvas, Offset(-tp.width/2, -25 - tp.height/2));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FactoryPainter oldDelegate) => true;
}