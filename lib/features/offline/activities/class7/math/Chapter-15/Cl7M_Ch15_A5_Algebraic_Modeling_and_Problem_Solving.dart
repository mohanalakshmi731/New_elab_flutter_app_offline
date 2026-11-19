// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlgebraApp());
}

class AlgebraApp extends StatelessWidget {
  const AlgebraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algebraic Modeling',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      home: const AlgebraHome(),
    );
  }
}

class AlgebraHome extends StatefulWidget {
  const AlgebraHome({Key? key}) : super(key: key);

  @override
  State<AlgebraHome> createState() => _AlgebraHomeState();
}

class _AlgebraHomeState extends State<AlgebraHome> with SingleTickerProviderStateMixin {
  bool _isSidebarOpen = true;
  String _lang = 'en';
  int _currentScenario = 0;
  int _currentStep = 0;

  // Camera & Interaction
  double _cameraX = 0;
  double _cameraY = 0;
  double _cameraScale = 1.0;
  bool _isPanLocked = false;
  
  // Dedicated audio players initialized with ReleaseMode.stop
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Network Audio Sources
  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';
  static const String _snapUrl = 'audio/class7/mixkit_392.mp3';
  static const String _popUrl = 'audio/class7/mixkit_2357.mp3';

  // Game Physics & Entities
  List<Entity> _entities = [];
  Entity? _draggedEntity;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  String? _hoverZone;

  double _beamAngle = 0.0;
  double _targetBeamAngle = 0.0;
  double _leftWeight = 0.0;
  double _rightWeight = 0.0;
  double _boxTrueWeight = 0.0;

  // Custom Scenario States
  double _budgetFilled = 0.0;
  int _platesAdded = 0;
  int _monthClicks = 0;

  // Divider Tool
  int _currentDivisor = 0;
  bool _dividedLeft = false;
  bool _dividedRight = false;

  late Ticker _ticker;
  double _animationTime = 0.0;
  bool _showShutter = true;
  double _shutterOffset = 0.0;

  final Map<String, Map<String, dynamic>> _i18n = {
    'en': {
      'title': "Algebraic Modeling: From Scales to Scenarios",
      'subtitle': "Class 7 • FINDING THE UNKNOWN",
      'enterLab': "Enter Virtual Lab",
      'selectScenario': "Select Scenario",
      'missionObj': "Mission Objective",
      'footer': "© ZeroScienceLab - Fall in love with math and Science",
      'msgTable': "TABLE",
      'msgBin': "ELIMINATOR ZONE",
      'reset': "Reset",
      'msgAddMonth': "Add 1 Month's Savings",
      'msgCheck': "Check Answer",
      'deliveryFee': "Delivery Fee (₹50)",
      'snackPlate': "Snack Plate (₹25)",
      'budget': "Budget: ₹500",
      'availSnacks': "Available for snacks: ₹",
      'totalPeople': "Total People: ",
      'remaining': "Remaining: ₹",
      'monthsPassed': "Months Passed: ",
      'jahnavi': "Jahnavi",
      'sunita': "Sunita",
      'scenarios': [
        {
          'title': "1. The Balanced Start (Solved)",
          'objective': "Find the weight of an unknown sack. Models: 6 = 2e.",
          'steps': [
            "The scale is balanced at 6 = 2e.",
            "Isolate one 'e' sack by DRAGGING the other 'e' sack to the table.",
            "The scale is unbalanced. CLICK a '2' weight to split it, then DRAG half the weight to the table.",
            "The scale balances at 3. Solved: e = 3."
          ]
        },
        {
          'title': "2. Isolate the Unknown (Solved)",
          'objective': "Find the unknown weight. Models: 4 + 2y = 16.",
          'steps': [
            "The scale is balanced at 4 + 2y = 16. DRAG the '4' weight to the table.",
            "CLICK the '16' weight to break it into pieces.",
            "DRAG a '4' weight from the right pan to the table.",
            "Equation Solved: y = 6."
          ]
        },
        {
          'title': "3. The Party Budget",
          'objective': "Models: 25p + 50 = 500.",
          'steps': [
            "DRAG the Delivery Fee icon and DROP it onto the start of the Budget Bar.",
            "DRAG one Snack Plate and DROP it onto the 'available for snacks' portion.",
            "Continue to DRAG and DROP snack plates until it is completely full.",
            "Equation Solved: p = 18!"
          ]
        },
        {
          'title': "4. A Tug of War",
          'objective': "Variables on both sides. Models: 6y + 7 = 4y + 21.",
          'steps': [
            "DRAG items to the table to simplify.",
            "Get all '?' sacks onto one side.",
            "Isolate the sacks. Use the Divider tool (✂) to solve.",
            "Challenge Complete: y = 7!"
          ]
        },
        {
          'title': "5. The Savings Race",
          'objective': "Solve: 4000 + 650m = 5050 + 500m.",
          'steps': [
            "Jahnavi starts with ₹4000. Sunita starts with ₹5050.",
            "CLICK 'Add 1 Month's Savings' to see how their money grows.",
            "Keep clicking until the jars have the exact same amount.",
            "Challenge Complete: m = 7!"
          ]
        }
      ]
    },
    'hi': {
      'title': "बीजगणितीय मॉडलिंग: तराजू से परिदृश्यों तक",
      'subtitle': "कक्षा 7 • अज्ञात का पता लगाना",
      'enterLab': "वर्चुअल लैब में प्रवेश करें",
      'selectScenario': "परिदृश्य चुनें",
      'missionObj': "मिशन का उद्देश्य",
      'footer': "© ZeroScienceLab",
      'msgTable': "मेज (TABLE)",
      'msgBin': "कचरे का डिब्बा",
      'reset': "रीसेट",
      'msgAddMonth': "1 महीने की बचत जोड़ें",
      'msgCheck': "उत्तर जांचें",
      'deliveryFee': "डिलीवरी शुल्क (₹50)",
      'snackPlate': "स्नैक प्लेट (₹25)",
      'budget': "बजट: ₹500",
      'availSnacks': "स्नैक्स के लिए उपलब्ध: ₹",
      'totalPeople': "कुल लोग: ",
      'remaining': "शेष: ₹",
      'monthsPassed': "महीने बीत गए: ",
      'jahnavi': "जाह्नवी",
      'sunita': "सुनीता",
      'scenarios': [
        {
          'title': "1. संतुलित शुरुआत",
          'objective': "एक अज्ञात बोरी का वजन ज्ञात करें। मॉडल: 6 = 2e.",
          'steps': [
            "पैमाना 6 = 2e पर संतुलित है।",
            "एक 'e' बोरी को मेज पर खींचकर अलग करें।",
            "'2' वजन को तोड़ने के लिए क्लिक करें, फिर आधा वजन मेज पर खींचें।",
            "समीकरण हल हुआ: e = 3!"
          ]
        },
        {
          'title': "2. अज्ञात को अलग करना",
          'objective': "अज्ञात वस्तु का वजन ज्ञात करें। मॉडल: 4 + 2y = 16.",
          'steps': [
            "पैमाना 4 + 2y = 16 पर संतुलित है। '4' वजन को मेज पर खींचें।",
            "'16' वजन को तोड़ने के लिए उस पर क्लिक करें।",
            "दाएं से एक '4' वजन मेज पर खींचें।",
            "समीकरण हल हुआ: y = 6!"
          ]
        },
        {
          'title': "3. पार्टी बजट",
          'objective': "मॉडल: 25p + 50 = 500.",
          'steps': [
            "Delivery Fee आइकन को खींचें और बजट बार के शुरुआत में छोड़ें।",
            "Snack Plate को खींचें और उसे बजट बार पर छोड़ें।",
            "बजट बार के पूरी तरह से भरने तक स्नैक प्लेट्स को खींचना जारी रखें।",
            "समीकरण हल हुआ: p = 18!"
          ]
        },
        {
          'title': "4. रस्साकशी",
          'objective': "मॉडल: 6y + 7 = 4y + 21.",
          'steps': [
            "संतुलन बनाए रखते हुए वस्तुओं को मेज पर खींचें।",
            "सभी '?' बोरियों को एक तरफ लाएं।",
            "बोरियों को अलग करें। डिवाइडर टूल (✂) का उपयोग करें।",
            "चुनौती पूर्ण: y = 7!"
          ]
        },
        {
          'title': "5. बचत की दौड़",
          'objective': "मॉडल: 4000 + 650m = 5050 + 500m.",
          'steps': [
            "जाह्नवी ₹4000 से शुरू होती है। सुनीता ₹5050 से शुरू होती है।",
            "'1 महीने की बचत जोड़ें' पर क्लिक करें।",
            "जब तक जार में समान राशि न हो जाए, तब तक क्लिक करते रहें।",
            "चुनौती पूर्ण: m = 7!"
          ]
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
        _animationTime = elapsed.inMilliseconds / 1000.0;
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
    _clickPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _fxPlayer.dispose();
    super.dispose();
  }

  void _playSound(String name) async {
    try {
      if (name == 'tick') await _clickPlayer.play(AssetSource(_clickUrl));
      else if (name == 'success') await _successPlayer.play(AssetSource(_successUrl));
      else if (name == 'error') await _errorPlayer.play(AssetSource(_errorUrl));
      else if (name == 'enter') await _fxPlayer.play(AssetSource(_shutterUrl));
      else if (name == 'snap') await _fxPlayer.play(AssetSource(_snapUrl));
      else if (name == 'pop') await _fxPlayer.play(AssetSource(_popUrl));
    } catch (e) {
      // Ignore audio errors gracefully
    }
  }

  void _enterLab() {
    _playSound('enter');
    setState(() {
      _shutterOffset = -MediaQuery.of(context).size.height;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _showShutter = false;
        _loadScenario(0);
        _ticker.start();
      });
    });
  }

  void _resetLab() {
    _playSound('tick');
    setState(() {
      _lang = 'en';
      _ticker.stop();
      _showShutter = true;
      _shutterOffset = 0.0;
      _currentScenario = 0;
      _currentStep = 0;
      _entities.clear();
      _budgetFilled = 0.0;
      _platesAdded = 0;
      _monthClicks = 0;
      _dividedLeft = false;
      _dividedRight = false;
      _currentDivisor = 0;
      _beamAngle = 0;
      _targetBeamAngle = 0;
      _cameraX = 0;
      _cameraY = 0;
      _cameraScale = 1.0;
    });
  }

  void _loadScenario(int index) {
    setState(() {
      _currentScenario = index;
      _currentStep = 0;
      _entities.clear();
      _dividedLeft = false;
      _dividedRight = false;
      _currentDivisor = 0;
      _beamAngle = 0;
      _targetBeamAngle = 0;
      _cameraX = 0;
      _cameraY = 0;
      _cameraScale = 1.0;
      _budgetFilled = 0;
      _platesAdded = 0;
      _monthClicks = 0;
      _setupScenarioEntities(index);
    });
  }

  void _setupScenarioEntities(int idx) {
    if (idx == 0) {
      _boxTrueWeight = 3;
      _entities.add(Entity(type: 'weight', val: 2, pan: 'left', isDraggable: false, x: 0, y: 0));
      _entities.add(Entity(type: 'weight', val: 2, pan: 'left', isDraggable: false, x: 0, y: 0));
      _entities.add(Entity(type: 'weight', val: 2, pan: 'left', isDraggable: false, x: 0, y: 0));
      _entities.add(Entity(type: 'sack', id: 'sR1', pan: 'right', isDraggable: false, x: 0, y: 0));
      _entities.add(Entity(type: 'sack', id: 'sR2', pan: 'right', isDraggable: false, x: 0, y: 0));
    } else if (idx == 1) {
      _boxTrueWeight = 6;
      _entities.add(Entity(type: 'sack', pan: 'left', isDraggable: false, x: 0, y: 0));
      _entities.add(Entity(type: 'sack', pan: 'left', isDraggable: false, x: 0, y: 0));
      _entities.add(Entity(type: 'weight', val: 4, pan: 'left', isDraggable: true, x: 0, y: 0));
      _entities.add(Entity(type: 'weight', id: 'break16', val: 16, pan: 'right', isDraggable: false, x: 0, y: 0));
    } else if (idx == 2) {
      // Party Budget
      _entities.add(Entity(type: 'icon', id: 'truck', x: -80, y: 120, pan: 'palette', isDraggable: true, val: 50, text: 'deliveryFee'));
      _entities.add(Entity(type: 'icon', id: 'plate', x: 80, y: 120, pan: 'palette', isDraggable: true, val: 25, isInfinite: true, text: 'snackPlate'));
    } else if (idx == 3) {
      _boxTrueWeight = 7;
      for (int i = 0; i < 6; i++) _entities.add(Entity(type: 'sack', pan: 'left', isDraggable: true, x: 0, y: 0));
      _entities.add(Entity(type: 'weight', val: 7, pan: 'left', isDraggable: true, x: 0, y: 0));
      for (int i = 0; i < 4; i++) _entities.add(Entity(type: 'sack', pan: 'right', isDraggable: true, x: 0, y: 0));
      _entities.add(Entity(type: 'weight', id: 'break21', val: 21, pan: 'right', isDraggable: false, x: 0, y: 0));
      _entities.add(Entity(type: 'divide_tool', x: 0, y: -180, isDraggable: true, pan: 'none'));
    } else if (idx == 4) {
      // Savings Race
      // Visuals are handled directly in painting.
    }
    _calculateWeights();
  }

  void _updatePhysics() {
    for (var ent in _entities) {
      if (ent.isHidden) continue;
      
      if (ent.isDisposing) {
        ent.x += (ent.disposeTargetX - ent.x) * 0.15;
        ent.y += (ent.disposeTargetY - ent.y) * 0.15;
        ent.scale *= 0.85;
        if (ent.scale < 0.05) {
          ent.isHidden = true;
          ent.isDisposing = false;
        }
      } else if (ent.isReturning) {
        ent.returnProgress += 0.1;
        if (ent.returnProgress >= 1.0) {
          ent.isReturning = false;
          ent.pan = ent.returnPan;
          ent.x = ent.returnTargetX;
          ent.y = ent.returnTargetY;
          _calculateWeights();
        } else {
          double t = ent.returnProgress;
          double easeT = 1 - math.pow(1 - t, 3).toDouble();
          ent.x = ent.returnStartX + (ent.returnTargetX - ent.returnStartX) * easeT;
          ent.y = ent.returnStartY + (ent.returnTargetY - ent.returnStartY) * easeT;
        }
      } else if (ent != _draggedEntity && (ent.pan == 'left' || ent.pan == 'right' || ent.pan == 'table')) {
        ent.x += (ent.panTargetX - ent.x) * 0.2;
        ent.y += (ent.panTargetY - ent.y) * 0.2;
      }
    }

    _beamAngle += (_targetBeamAngle - _beamAngle) * 0.1;
    if (_currentScenario != 2 && _currentScenario != 4) {
      _positionPanItems();
    }
  }

  void _positionPanItems() {
    double beamLength = 150;
    double pivotY = -50;
    double leftPinY = pivotY - math.sin(_beamAngle) * beamLength;
    double rightPinY = pivotY + math.sin(_beamAngle) * beamLength;
    double leftPanY = leftPinY + 140;
    double rightPanY = rightPinY + 140;

    void positionGroup(String pan, double panCenterX, double panY) {
      var items = _entities.where((e) => e.pan == pan && !e.isHidden && e != _draggedEntity).toList();
      var boxes = items.where((e) => e.type == 'sack' || e.type == 'box').toList();
      var weights = items.where((e) => e.type == 'weight' || e.type == 'cube').toList();
      
      double yOffset = panY - 20;

      for (int i = 0; i < boxes.length; i++) {
        var e = boxes[i];
        int row = i ~/ 2;
        bool isSingle = (i == boxes.length - 1 && boxes.length % 2 != 0);
        double colOffset = isSingle ? 0 : (i % 2 == 0 ? -18 : 18);
        e.panTargetX = panCenterX + colOffset;
        e.panTargetY = yOffset - (row * 35);
      }
      if (boxes.isNotEmpty) {
        yOffset -= (boxes.length / 2).ceil() * 35;
      }

      for (int i = 0; i < weights.length; i++) {
        var e = weights[i];
        int row = i ~/ 3;
        int col = i % 3;
        int itemsInThisRow = math.min(3, weights.length - row * 3);
        double colOffset = itemsInThisRow == 1 ? 0 : (itemsInThisRow == 2 ? (col == 0 ? -15 : 15) : (col - 1) * 22);
        e.panTargetX = panCenterX + colOffset;
        e.panTargetY = yOffset - (row * 24);
      }
    }

    positionGroup('left', -150, leftPanY);
    positionGroup('right', 150, rightPanY);

    var tableItems = _entities.where((e) => e.pan == 'table' && !e.isHidden && e != _draggedEntity).toList();
    for (int i = 0; i < tableItems.length; i++) {
      var e = tableItems[i];
      int row = i ~/ 8;
      int col = i % 8;
      e.panTargetX = -180 + col * 45.0;
      e.panTargetY = 230 + row * 45.0;
    }
  }

  void _calculateWeights() {
    _leftWeight = 0;
    _rightWeight = 0;
    for (var e in _entities) {
      if (e.isHidden || e.isDisposing || (e.pan == 'none' && e != _draggedEntity)) continue;
      String? p = e.pan;
      if (e == _draggedEntity && _isDragging) p = e.originalPan;
      
      double w = 0;
      if (e.type == 'sack' || e.type == 'box') w = _boxTrueWeight;
      else if (e.type == 'weight') w = e.val.toDouble();
      
      if (p == 'left') _leftWeight += w;
      if (p == 'right') _rightWeight += w;
    }

    double diff = _rightWeight - _leftWeight;
    if (_currentDivisor > 0) diff = 0;
    _targetBeamAngle = math.max(-0.25, math.min(0.25, diff * 0.05));
    _evaluateScenarioState();
  }

  bool _isBalanced() {
    return (_leftWeight - _rightWeight).abs() < 0.1;
  }

  void _evaluateScenarioState() {
    int cLeftSack = _entities.where((e) => e.pan == 'left' && e.type == 'sack' && !e.isHidden && !e.isDisposing).length;
    int cRightSack = _entities.where((e) => e.pan == 'right' && e.type == 'sack' && !e.isHidden && !e.isDisposing).length;
    int cTableSack = _entities.where((e) => e.pan == 'table' && e.type == 'sack' && !e.isHidden && !e.isDisposing).length;
    
    double wL = 0;
    _entities.where((e) => e.pan == 'left' && e.type == 'weight' && !e.isHidden && !e.isDisposing).forEach((w) => wL += w.val);
    double wR = 0;
    _entities.where((e) => e.pan == 'right' && e.type == 'weight' && !e.isHidden && !e.isDisposing).forEach((w) => wR += w.val);

    if (_currentScenario == 0) {
      if (_currentStep == 0) {
        Future.delayed(const Duration(seconds: 2), _advanceStep);
      } else if (_currentStep == 1) {
        if (cRightSack == 1 && cTableSack >= 1) _advanceStep();
      } else if (_currentStep == 2) {
        if (wL == 3 && _isBalanced()) _advanceStep();
      }
    } else if (_currentScenario == 1) {
      if (_currentStep == 0) {
        if (wL == 0) _advanceStep();
      } else if (_currentStep == 1) {
        if (!_entities.any((e) => e.id == 'break16' && !e.isHidden)) _advanceStep();
      } else if (_currentStep == 2) {
        if (wR == 12 && _isBalanced()) {
          _playSound('pop');
          setState(() {
            bool keptOne = false;
            for (var e in _entities) {
              if (e.pan == 'left' && e.type == 'sack') {
                if (!keptOne) keptOne = true;
                else { e.isDisposing = true; e.disposeTargetY = 300; e.pan = 'none'; }
              }
              if (e.pan == 'right' && e.type == 'weight' && e.val == 4) {
                e.isDisposing = true; e.disposeTargetY = 300; e.pan = 'none';
              }
            }
            _entities.add(Entity(type: 'weight', val: 6, pan: 'right', isDraggable: false, x: 150, y: 150));
            _calculateWeights();
          });
          Future.delayed(const Duration(seconds: 1), _advanceStep);
        }
      }
    } else if (_currentScenario == 2) {
      if (_currentStep == 0 && _budgetFilled >= 50) _advanceStep();
      else if (_currentStep == 1 && _platesAdded >= 1) _advanceStep();
      else if (_currentStep == 2 && _budgetFilled >= 500) _advanceStep();
    } else if (_currentScenario == 3) {
      if (_currentStep == 0 && (cLeftSack + cRightSack < 10 || wL + wR < 28) && _isBalanced()) _advanceStep();
      else if (_currentStep == 1 && ((cLeftSack > 0 && cRightSack == 0) || (cLeftSack == 0 && cRightSack > 0)) && _isBalanced()) _advanceStep();
      // Step 2 is checked manually via "Check Answer" button
    } else if (_currentScenario == 4) {
      if (_currentStep == 0) Future.delayed(const Duration(seconds: 2), _advanceStep);
      else if (_currentStep == 1 && _monthClicks > 0) _advanceStep();
    }
  }

  void _advanceStep() {
    final steps = _i18n[_lang]!['scenarios'][_currentScenario]['steps'] as List;
    if (_currentStep < steps.length - 1) {
      _playSound('success');
      setState(() {
        _currentStep++;
        if (_currentScenario == 0) {
          if (_currentStep == 1) {
            _entities.where((e) => e.pan == 'right' && e.type == 'sack').forEach((e) => e.isDraggable = true);
          } else if (_currentStep == 2) {
            _entities.where((e) => e.pan == 'left' && e.type == 'weight').forEach((e) => e.isDraggable = true);
          }
        }
      });
    }
  }

  void _checkAnswer() {
    if (!_isBalanced()) {
      _playSound('error');
      return;
    }
    int cLeftSack = _entities.where((e) => e.pan == 'left' && e.type == 'sack' && !e.isHidden && !e.isDisposing).length;
    double wL = 0; _entities.where((e) => e.pan == 'left' && e.type == 'weight' && !e.isHidden && !e.isDisposing).forEach((w) => wL += w.val);
    int cRightSack = _entities.where((e) => e.pan == 'right' && e.type == 'sack' && !e.isHidden && !e.isDisposing).length;
    double wR = 0; _entities.where((e) => e.pan == 'right' && e.type == 'weight' && !e.isHidden && !e.isDisposing).forEach((w) => wR += w.val);

    if ((cLeftSack == 1 && wL == 0 && cRightSack == 0 && wR == _boxTrueWeight) ||
        (cRightSack == 1 && wR == 0 && cLeftSack == 0 && wL == _boxTrueWeight)) {
      _playSound('success');
      _advanceStep();
    } else {
      _playSound('error');
    }
  }

  void _addSavingsMonth() {
    _playSound('pop');
    setState(() {
      _monthClicks++;
      if (_monthClicks == 7) {
        _playSound('success');
        _advanceStep();
      }
    });
  }

  Offset _screenToWorld(Offset localPos, BoxConstraints constraints) {
    final centerX = constraints.maxWidth / 2;
    final centerY = constraints.maxHeight / 2;
    return Offset(
      (localPos.dx - centerX - _cameraX) / _cameraScale,
      (localPos.dy - centerY - _cameraY) / _cameraScale,
    );
  }

  void _handleTap(TapDownDetails details, BoxConstraints constraints) {
    if (_isDragging) return;
    
    final localPos = details.localPosition;
    final worldPos = _screenToWorld(localPos, constraints);

    for (int i = _entities.length - 1; i >= 0; i--) {
      var ent = _entities[i];
      if (ent.isHidden) continue;
      
      bool hit = false;
      if (ent.type == 'weight' && (ent.x - worldPos.dx).abs() < 40 && (ent.y - worldPos.dy).abs() < 40) hit = true;
      
      if (hit && ent.val > 1) {
        if (_currentScenario == 0 && _currentStep >= 2 && ent.val == 2) {
          _playSound('pop');
          setState(() {
            ent.isHidden = true;
            ent.isDisposing = true;
            _entities.add(Entity(type: 'weight', val: 1, pan: ent.pan, isDraggable: true, x: ent.x - 15, y: ent.y));
            _entities.add(Entity(type: 'weight', val: 1, pan: ent.pan, isDraggable: true, x: ent.x + 15, y: ent.y));
            _calculateWeights();
          });
          return;
        } else if (_currentScenario == 1 && _currentStep >= 1 && ent.id == 'break16') {
          _playSound('pop');
          setState(() {
            ent.isHidden = true;
            ent.isDisposing = true;
            for (int j = 0; j < 4; j++) {
              _entities.add(Entity(type: 'weight', val: 4, pan: 'right', isDraggable: true, x: ent.x + (j - 1.5) * 10, y: ent.y + (j - 1.5) * 10));
            }
            _calculateWeights();
          });
          return;
        } else if (_currentScenario == 3 && ent.id == 'break21') {
          _playSound('pop');
          setState(() {
            ent.isHidden = true;
            ent.isDisposing = true;
            for (int j = 0; j < 3; j++) {
              _entities.add(Entity(type: 'weight', val: 7, pan: 'right', isDraggable: true, x: ent.x + (j - 1) * 20, y: ent.y));
            }
            _calculateWeights();
          });
          return;
        }
      }
    }
  }

  void _handlePanStart(DragStartDetails details, BoxConstraints constraints) {
    if (_isPanLocked) return;
    
    final localPos = details.localPosition;
    final worldPos = _screenToWorld(localPos, constraints);
    
    for (int i = _entities.length - 1; i >= 0; i--) {
      var ent = _entities[i];
      if (ent.isHidden || !ent.isDraggable) continue;
      
      bool hit = false;
      if ((ent.type == 'sack' || ent.type == 'icon') && (ent.x - worldPos.dx).abs() < 50 && (ent.y - worldPos.dy).abs() < 50) hit = true;
      else if (ent.type == 'weight' && (ent.x - worldPos.dx).abs() < 40 && (ent.y - worldPos.dy).abs() < 40) hit = true;
      else if (ent.type == 'divide_tool' && (ent.x - worldPos.dx).abs() < 45 && (ent.y - worldPos.dy).abs() < 45) hit = true;
      
      if (hit) {
        _playSound('tick');
        setState(() {
          if (ent.isInfinite) {
            var clone = Entity(
              type: ent.type, id: ent.id, pan: 'palette', isDraggable: true, x: ent.x, y: ent.y, val: ent.val, text: ent.text
            );
            _entities.add(clone);
            _draggedEntity = clone;
          } else {
            _draggedEntity = ent;
          }
          _draggedEntity!.originalPan = _draggedEntity!.pan;
          if (_draggedEntity!.pan != 'table') _draggedEntity!.pan = 'none';
          _dragOffset = Offset(_draggedEntity!.x - worldPos.dx, _draggedEntity!.y - worldPos.dy);
          _isDragging = true;
          _draggedEntity!.returnStartX = _draggedEntity!.x;
          _draggedEntity!.returnStartY = _draggedEntity!.y;
          _calculateWeights();
        });
        return;
      }
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_isDragging && _draggedEntity != null) {
      final localPos = details.localPosition;
      final worldPos = _screenToWorld(localPos, constraints);
      
      setState(() {
        _draggedEntity!.x = worldPos.dx + _dragOffset.dx;
        _draggedEntity!.y = worldPos.dy + _dragOffset.dy;
        
        _hoverZone = null;
        if (_currentScenario == 2) {
          if (worldPos.dy >= -100 && worldPos.dy <= 0 && worldPos.dx >= -220 && worldPos.dx <= 220) _hoverZone = 'bar';
        } else {
          if (_draggedEntity!.type == 'divide_tool') {
            if (worldPos.dx < 0) _hoverZone = 'left_pan'; else _hoverZone = 'right_pan';
          } else {
            if (_currentScenario == 0 && worldPos.dy >= 200) _hoverZone = 'table';
            else if (_currentScenario > 0 && worldPos.dx >= -120 && worldPos.dx <= 120 && worldPos.dy >= 200 && worldPos.dy <= 340) _hoverZone = 'bin';
          }
        }
      });
    } else {
      setState(() {
        _cameraX += details.delta.dx;
        _cameraY += details.delta.dy;
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_isDragging || _draggedEntity == null) return;
    final worldPos = Offset(_draggedEntity!.x, _draggedEntity!.y);
    
    setState(() {
      _isDragging = false;

      if (_currentScenario == 2) {
        bool droppedOnBar = worldPos.dy >= -100 && worldPos.dy <= 0 && worldPos.dx >= -220 && worldPos.dx <= 220;
        if (droppedOnBar) {
          if (_currentStep == 0 && _draggedEntity!.id != 'truck') {
            _playSound('error'); _returnEntity();
          } else if (_currentStep > 0 && _draggedEntity!.id != 'plate') {
            _playSound('error'); _returnEntity();
          } else if (_budgetFilled + _draggedEntity!.val > 500) {
            _playSound('error'); _returnEntity();
          } else {
            _playSound('snap');
            _budgetFilled += _draggedEntity!.val;
            if (_draggedEntity!.id == 'plate') _platesAdded++;
            _draggedEntity!.isHidden = true;
            if (_draggedEntity!.originalPan == 'palette' && _draggedEntity!.id == 'truck') {
              _entities.removeWhere((e) => e.id == 'truck' && !e.isInfinite);
            }
          }
        } else {
          _playSound('error'); _returnEntity();
        }
        _draggedEntity = null;
        _evaluateScenarioState();
        return;
      }

      bool droppedOnTable = worldPos.dy >= 200;
      bool droppedOnBin = worldPos.dx >= -120 && worldPos.dx <= 120 && worldPos.dy >= 200 && worldPos.dy <= 340;
      bool droppedOnLeft = worldPos.dx >= -240 && worldPos.dx <= -60 && worldPos.dy >= -50 && worldPos.dy <= 180;
      bool droppedOnRight = worldPos.dx >= 60 && worldPos.dx <= 240 && worldPos.dy >= -50 && worldPos.dy <= 180;

      if (_draggedEntity!.type == 'divide_tool') {
        if (droppedOnLeft) _attemptDivide('left');
        else if (droppedOnRight) _attemptDivide('right');
        else _returnEntity();
      } else {
        if (droppedOnTable && _currentScenario == 0) {
          _playSound('snap'); _draggedEntity!.pan = 'table';
        } else if (droppedOnBin && _currentScenario > 0) {
          _playSound('snap');
          _draggedEntity!.isDisposing = true;
          _draggedEntity!.disposeTargetX = 0;
          _draggedEntity!.disposeTargetY = 260;
          _draggedEntity!.pan = 'none';
        } else if (droppedOnLeft) {
          _playSound('snap'); _draggedEntity!.pan = 'left';
        } else if (droppedOnRight) {
          _playSound('snap'); _draggedEntity!.pan = 'right';
        } else {
          _playSound('error'); _returnEntity();
        }
      }
      
      _calculateWeights();
      _draggedEntity = null;
    });
  }

  void _returnEntity() {
    _draggedEntity!.isReturning = true;
    _draggedEntity!.returnStartX = _draggedEntity!.x;
    _draggedEntity!.returnStartY = _draggedEntity!.y;
    _draggedEntity!.returnTargetX = _draggedEntity!.returnStartX;
    _draggedEntity!.returnTargetY = _draggedEntity!.returnStartY;
    _draggedEntity!.returnPan = _draggedEntity!.originalPan;
    _draggedEntity!.returnProgress = 0;
    _draggedEntity!.pan = 'none';
  }

  void _attemptDivide(String pan) {
    int cSack = _entities.where((e) => e.pan == pan && e.type == 'sack' && !e.isHidden && !e.isDisposing).length;
    double wTotal = 0;
    _entities.where((e) => e.pan == pan && e.type == 'weight' && !e.isHidden && !e.isDisposing).forEach((w) => wTotal += w.val);
    
    if (cSack == 0 && wTotal == 0) {
      _playSound('error');
      _returnEntity();
      return;
    }

    int div = 1;
    if (_currentDivisor > 0) div = _currentDivisor;
    else if (cSack > 0) div = cSack;
    else div = _entities.where((e) => e.pan != pan && e.type == 'sack' && !e.isHidden && !e.isDisposing).length;

    if (div > 1 && (cSack % div == 0) && (wTotal % div == 0)) {
      _playSound('snap');
      _currentDivisor = div;
      
      int keepSacks = cSack ~/ div;
      var sacks = _entities.where((e) => e.pan == pan && e.type == 'sack' && !e.isHidden && !e.isDisposing).toList();
      for (int i = keepSacks; i < sacks.length; i++) {
        sacks[i].isDisposing = true; sacks[i].disposeTargetY = 300; sacks[i].pan = 'none';
      }
      
      if (wTotal > 0) {
        var weights = _entities.where((e) => e.pan == pan && e.type == 'weight' && !e.isHidden && !e.isDisposing).toList();
        for (var w in weights) { w.isDisposing = true; w.disposeTargetY = 300; w.pan = 'none'; }
        _entities.add(Entity(type: 'weight', val: (wTotal ~/ div).toInt(), pan: pan, isDraggable: true, x: pan == 'left' ? -150 : 150, y: 150));
      }
      
      if (pan == 'left') _dividedLeft = true;
      if (pan == 'right') _dividedRight = true;
      
      _draggedEntity!.returnTargetX = 0;
      _draggedEntity!.returnTargetY = -180;
      _draggedEntity!.returnPan = 'none';
      _draggedEntity!.isReturning = true;
      _draggedEntity!.returnProgress = 0;

      if (_dividedLeft && _dividedRight) {
        _currentDivisor = 0;
        Future.delayed(const Duration(milliseconds: 500), () {
          _playSound('success');
          _calculateWeights();
        });
      }
    } else {
      _playSound('error');
      _returnEntity();
    }
  }

  void _zoom(double factor) {
    setState(() {
      _cameraScale = math.max(0.2, math.min(_cameraScale * factor, 2.0));
    });
  }

  void _toggleLanguage() {
    _playSound('tick');
    setState(() {
      if (_lang == 'en') _lang = 'hi';
      else _lang = 'en';
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = _i18n[_lang]!;
    final scenarios = tr['scenarios'] as List;
    final currentScenarioData = scenarios[_currentScenario];
    final steps = currentScenarioData['steps'] as List;
    final double sidebarWidth = MediaQuery.of(context).size.width * 0.38;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        },
        child: Stack(
          children: [
            // Interactive Canvas Area (Resizes when sidebar is open)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onPanStart: (details) => _handlePanStart(details, constraints),
                    onPanUpdate: (details) => _handlePanUpdate(details, constraints),
                    onPanEnd: _handlePanEnd,
                    onTapDown: (details) => _handleTap(details, constraints),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CustomPaint(
                        painter: GamePainter(
                          entities: _entities,
                          beamAngle: _beamAngle,
                          cameraX: _cameraX,
                          cameraY: _cameraY,
                          cameraScale: _cameraScale,
                          draggedEntity: _draggedEntity,
                          hoverZone: _hoverZone,
                          currentScenario: _currentScenario,
                          lang: _lang,
                          i18n: _i18n,
                          budgetFilled: _budgetFilled,
                          monthClicks: _monthClicks,
                          platesAdded: _platesAdded,
                          animationTime: _animationTime,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Canvas HUD (Equation)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 20,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.indigo.withOpacity(0.5)),
                    ),
                    child: Text(
                      _buildEquationString(),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigoAccent),
                    ),
                  ),
                ),
              ),
            ),

            // Zoom Controls
            Positioned(
              top: 80,
              right: 16,
              child: Column(
                children: [
                  _buildToolBtn(Icons.zoom_in, () => _zoom(1.2)),
                  const SizedBox(height: 8),
                  _buildToolBtn(Icons.zoom_out, () => _zoom(1 / 1.2)),
                  const SizedBox(height: 8),
                  _buildToolBtn(Icons.fit_screen, () {
                    setState(() {
                      _cameraX = 0; _cameraY = 0; _cameraScale = 1.0;
                    });
                  }),
                ],
              ),
            ),

            // Action Overlays (Check Answer / Add Month)
            if (_currentScenario == 3 && _currentStep == 2 && !(_isSidebarOpen && MediaQuery.of(context).size.width < 800))
              Positioned(
                bottom: 80,
                left: _isSidebarOpen ? sidebarWidth : 0,
                right: 0,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _checkAnswer,
                    icon: const Icon(Icons.check_circle),
                    label: Text(tr['msgCheck'] ?? "Check Answer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ),

            if (_currentScenario == 4 && _currentStep > 0 && _currentStep < 3 && !(_isSidebarOpen && MediaQuery.of(context).size.width < 800))
              Positioned(
                bottom: 80,
                left: _isSidebarOpen ? sidebarWidth : 0,
                right: 0,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _addSavingsMonth,
                    icon: const Icon(Icons.add),
                    label: Text(tr['msgAddMonth'] ?? "Add 1 Month's Savings"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ),

            // Bottom HUD message
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 20,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      steps[_currentStep],
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),

            // Sidebar Overlay Layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.95),
                  border: const Border(right: BorderSide(color: Colors.white24, width: 1)),
                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(5, 0))],
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80, left: 16, right: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.scale, color: Colors.amber, size: 28),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tr['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                  Text(tr['subtitle'], style: const TextStyle(fontSize: 10, color: Colors.white70)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Language and Reset Buttons
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.language, size: 18),
                              label: Text(_lang.toUpperCase()),
                              onPressed: _toggleLanguage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo.withOpacity(0.4),
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh, size: 18),
                              label: Text(tr['reset']!),
                              onPressed: _resetLab,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent.withOpacity(0.4),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        Text(tr['selectScenario'].toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _currentScenario,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1E293B),
                              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
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
                        
                        Text(tr['missionObj'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                        const SizedBox(height: 8),
                        Text(currentScenarioData['objective'], style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.5)),
                        const SizedBox(height: 24),

                        // Steps
                        ...List.generate(steps.length, (index) {
                          bool isCurrent = index == _currentStep;
                          bool isPast = index < _currentStep;
                          if (!isCurrent && !isPast) return const SizedBox.shrink();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCurrent ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isCurrent ? Colors.indigo.withOpacity(0.5) : Colors.transparent),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(isCurrent ? Icons.gps_fixed : Icons.check_circle, color: isCurrent ? Colors.indigoAccent : Colors.green, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    steps[index],
                                    style: TextStyle(fontSize: 13, color: isCurrent ? Colors.white : Colors.white54, fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal),
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                        
                        // Mobile helper Action Buttons inside sidebar if space is tight
                        if (_isSidebarOpen && MediaQuery.of(context).size.width < 800) ...[
                           if (_currentScenario == 3 && _currentStep == 2)
                             Padding(
                               padding: const EdgeInsets.only(top: 16.0),
                               child: ElevatedButton.icon(
                                  onPressed: _checkAnswer,
                                  icon: const Icon(Icons.check_circle),
                                  label: Text(tr['msgCheck'] ?? "Check Answer"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
                               ),
                             ),
                           if (_currentScenario == 4 && _currentStep > 0 && _currentStep < 3)
                             Padding(
                               padding: const EdgeInsets.only(top: 16.0),
                               child: ElevatedButton.icon(
                                  onPressed: _addSavingsMonth,
                                  icon: const Icon(Icons.add),
                                  label: Text(tr['msgAddMonth'] ?? "Add 1 Month's Savings"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
                               ),
                             ),
                        ],

                        const SizedBox(height: 32),
                        Center(
                          child: Text(
                            tr['footer'],
                            style: const TextStyle(fontSize: 10, color: Colors.white54),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Shutter Overlay
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
                        Text(
                          tr['title'],
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.indigoAccent),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tr['subtitle'],
                          style: const TextStyle(fontSize: 20, color: Colors.white70),
                        ),
                        const SizedBox(height: 48),
                        ElevatedButton(
                          onPressed: _enterLab,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              
            // Sidebar Menu Toggle
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
          ],
        ),
      ),
    );
  }

  Widget _buildToolBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        _playSound('tick');
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  String _buildEquationString() {
    if (_currentScenario == 2) {
      if (_currentStep == 0) return "25p + 50 = 500";
      else if (_currentStep == 1 || _currentStep == 2) return "25p = 450";
      else return "p = 18";
    } else if (_currentScenario == 4) {
      if (_monthClicks == 0) return "4000 + 650m = 5050 + 500m";
      else if (_monthClicks < 7) return "4000 + 650($_monthClicks) ≠ 5050 + 500($_monthClicks)";
      else return "4000 + 650(7) = 5050 + 500(7)";
    }

    String left = _buildSideStr('left');
    String right = _buildSideStr('right');
    String eqSign = _isBalanced() || _currentDivisor > 0 ? "=" : "≠";
    
    if (_currentDivisor > 0) {
      if (_dividedLeft && !_dividedRight) { left = "($left) / $_currentDivisor"; }
      else if (!_dividedLeft && _dividedRight) { right = "($right) / $_currentDivisor"; }
    }
    return "$left $eqSign $right";
  }

  String _buildSideStr(String pan) {
    int b = _entities.where((e) => e.pan == pan && e.type == 'sack' && !e.isHidden && !e.isDisposing).length;
    double c = 0;
    _entities.where((e) => e.pan == pan && e.type == 'weight' && !e.isHidden && !e.isDisposing).forEach((w) => c += w.val);
    
    List<String> parts = [];
    String label = "e";
    if (_currentScenario == 1 || _currentScenario == 3) label = "y";

    if (_currentScenario == 0) {
      if (c > 0) parts.add("${c.toInt()}");
      if (b > 0) parts.add(b == 1 ? label : "$b$label");
    } else {
      if (b > 0) parts.add(b == 1 ? label : "$b$label");
      if (c > 0) parts.add("${c.toInt()}");
    }
    return parts.isEmpty ? "0" : parts.join(" + ");
  }
}

class Entity {
  String type; // sack, weight, icon, text, divide_tool
  String? id;
  double x;
  double y;
  int val;
  String? text;
  String pan; // left, right, table, bin, palette, none
  bool isDraggable;
  bool isInfinite;
  bool isHidden;
  bool isDisposing = false;
  double disposeTargetX = 0;
  double disposeTargetY = 0;
  double scale = 1.0;
  
  double panTargetX = 0;
  double panTargetY = 0;

  bool isReturning = false;
  double returnStartX = 0;
  double returnStartY = 0;
  double returnTargetX = 0;
  double returnTargetY = 0;
  String returnPan = 'none';
  double returnProgress = 0;
  String originalPan = 'none';

  Entity({
    required this.type,
    this.id,
    required this.x,
    required this.y,
    this.val = 1,
    this.text,
    required this.pan,
    required this.isDraggable,
    this.isInfinite = false,
    this.isHidden = false,
  });
}

class GamePainter extends CustomPainter {
  final List<Entity> entities;
  final double beamAngle;
  final double cameraX;
  final double cameraY;
  final double cameraScale;
  final Entity? draggedEntity;
  final String? hoverZone;
  final int currentScenario;
  final String lang;
  final Map<String, Map<String, dynamic>> i18n;
  
  final double budgetFilled;
  final int monthClicks;
  final int platesAdded;
  final double animationTime;

  GamePainter({
    required this.entities,
    required this.beamAngle,
    required this.cameraX,
    required this.cameraY,
    required this.cameraScale,
    this.draggedEntity,
    this.hoverZone,
    required this.currentScenario,
    required this.lang,
    required this.i18n,
    required this.budgetFilled,
    required this.monthClicks,
    required this.platesAdded,
    required this.animationTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + cameraX, size.height / 2 + cameraY);
    canvas.scale(cameraScale, cameraScale);

    if (currentScenario == 2) {
      _drawBudgetBar(canvas);
    } else if (currentScenario == 4) {
      _drawJars(canvas);
    } else {
      _drawScaleBackground(canvas);
    }
    
    var resting = entities.where((e) => e != draggedEntity && !e.isHidden).toList();
    resting.sort((a, b) => a.y.compareTo(b.y));
    for (var e in resting) _drawEntity(canvas, e);

    if (currentScenario != 2 && currentScenario != 4) {
      _drawScaleForeground(canvas);
    }

    if (draggedEntity != null && !draggedEntity!.isHidden) {
      _drawEntity(canvas, draggedEntity!);
    }

    canvas.restore();
  }

  void _drawBudgetBar(Canvas canvas) {
    final tr = i18n[lang]!;
    canvas.save();
    canvas.translate(0, -50);
    double w = 400;
    double h = 40;
    
    // Background
    canvas.drawRRect(RRect.fromLTRBR(-w/2, -h/2, w/2, h/2, const Radius.circular(20)), Paint()..color = const Color(0xFF1E293B));
    canvas.drawRRect(RRect.fromLTRBR(-w/2, -h/2, w/2, h/2, const Radius.circular(20)), Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 4);
    
    _drawText(canvas, tr['budget'] ?? "Budget: ₹500", 0, -h/2 - 15, fontSize: 20, color: Colors.white);

    double fillRatio = budgetFilled / 500.0;
    if (fillRatio > 0) {
      canvas.save();
      canvas.clipRRect(RRect.fromLTRBR(-w/2, -h/2, w/2, h/2, const Radius.circular(20)));
      canvas.drawRect(Rect.fromLTRB(-w/2, -h/2, -w/2 + w * fillRatio, h/2), Paint()..color = const Color(0xFF10B981));
      
      if (budgetFilled >= 50) {
        canvas.drawRect(Rect.fromLTRB(-w/2, -h/2, -w/2 + w * 0.1, h/2), Paint()..color = Colors.red);
      }
      
      if (budgetFilled > 50) {
        for (int i = 1; i <= platesAdded; i++) {
            double lineX = -w/2 + w * (0.1 + i * 0.05);
            canvas.drawLine(Offset(lineX, -h/2), Offset(lineX, h/2), Paint()..color = Colors.white54..strokeWidth = 2);
        }
      }
      canvas.restore();
    }

    if (hoverZone == 'bar') {
       canvas.drawRRect(RRect.fromLTRBR(-w/2, -h/2, w/2, h/2, const Radius.circular(20)), Paint()..color = const Color(0x3310B981)..style = PaintingStyle.fill);
       canvas.drawRRect(RRect.fromLTRBR(-w/2, -h/2, w/2, h/2, const Radius.circular(20)), Paint()..color = const Color(0xFF10B981)..style = PaintingStyle.stroke..strokeWidth = 3);
    }
    
    double remaining = 500 - budgetFilled;
    if (budgetFilled >= 50) {
      _drawText(canvas, "${tr['availSnacks'] ?? 'Available for snacks: ₹'}${remaining.toInt()}", 0, 40, fontSize: 18, color: Colors.white70);
      _drawText(canvas, "${tr['totalPeople'] ?? 'Total People: '}${((budgetFilled - 50)/25).toInt()}", 0, 70, fontSize: 18, color: Colors.white70);
    } else {
      _drawText(canvas, "${tr['remaining'] ?? 'Remaining: ₹'}${remaining.toInt()}", 0, 40, fontSize: 18, color: Colors.white70);
    }
    canvas.restore();
  }

  void _drawJars(Canvas canvas) {
    final tr = i18n[lang]!;
    canvas.save();
    canvas.translate(0, 100); 
    double maxVal = 9000;
    double hScale = 250 / maxVal;
    double j1Val = 4000 + monthClicks * 650;
    double j2Val = 5050 + monthClicks * 500;

    void drawJar(double x, double val, String name, Color color) {
      canvas.save();
      canvas.translate(x, 0);
      canvas.drawRRect(RRect.fromLTRBR(-40, -280, 40, 20, const Radius.circular(10)), Paint()..color = const Color(0xFF1E293B));
      canvas.drawRRect(RRect.fromLTRBR(-40, -280, 40, 20, const Radius.circular(10)), Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 4);
      
      canvas.drawRRect(RRect.fromLTRBR(-40, 20 - val*hScale, 40, 20, const Radius.circular(10)), Paint()..color = color);
      
      _drawText(canvas, name, 0, -300, fontSize: 18, color: Colors.white);
      _drawText(canvas, "₹${val.toInt()}", 0, 20 - val*hScale - 20, fontSize: 16, color: Colors.white);
      canvas.restore();
    }

    drawJar(-100, j1Val, tr['jahnavi'] ?? "Jahnavi", Colors.blue);
    drawJar(100, j2Val, tr['sunita'] ?? "Sunita", Colors.amber);

    _drawText(canvas, "${tr['monthsPassed'] ?? 'Months Passed: '}$monthClicks", 0, 60, fontSize: 20, color: Colors.white70);
    canvas.restore();
  }

  void _drawScaleBackground(Canvas canvas) {
    final tr = i18n[lang]!;
    
    canvas.save();
    canvas.translate(0, 260);

    if (currentScenario == 0 || currentScenario == 1 || currentScenario == 3) {
      if (currentScenario == 0) {
        if (hoverZone == 'table') {
          canvas.drawRRect(RRect.fromLTRBR(-260, -50, 260, 50, const Radius.circular(15)), Paint()..color = Colors.amber.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
        }
        canvas.drawRRect(RRect.fromLTRBR(-250, -40, 250, 40, const Radius.circular(10)), Paint()..color = const Color(0xFF1E293B));
        canvas.drawRRect(RRect.fromLTRBR(-250, -40, 250, 40, const Radius.circular(10)), Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 4);
        _drawText(canvas, tr['msgTable'], 0, 0, fontSize: 16, color: const Color(0xFFCBD5E1));
      } else {
        if (hoverZone == 'bin') {
          canvas.drawRRect(RRect.fromLTRBR(-130, -50, 130, 50, const Radius.circular(15)), Paint()..color = Colors.red.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
        }
        canvas.drawOval(const Rect.fromLTRB(-45, -32, 45, -8), Paint()..color = const Color(0xFF64748B));
        canvas.drawPath(Path()..moveTo(-45, -20)..lineTo(45, -20)..lineTo(35, 30)..lineTo(-35, 30)..close(), Paint()..color = const Color(0xFF475569));
        canvas.drawOval(const Rect.fromLTRB(-45, -32, 45, -8), Paint()..color = const Color(0xFF94A3B8));
        canvas.drawOval(const Rect.fromLTRB(-38, -28, 38, -12), Paint()..color = const Color(0xFF334155));
        _drawText(canvas, tr['msgBin'], 0, 50, fontSize: 12, color: const Color(0xFFCBD5E1));
      }
    }
    canvas.restore();

    canvas.save();
    canvas.drawRRect(RRect.fromLTRBR(-70, 190, 70, 200, const Radius.circular(4)), Paint()..color = const Color(0xFF334155));
    canvas.drawRRect(RRect.fromLTRBR(-90, 200, 90, 215, const Radius.circular(6)), Paint()..color = const Color(0xFF1E293B));
    canvas.drawRect(const Rect.fromLTRB(-10, -50, 10, 190), Paint()..color = const Color(0xFF475569));
    
    canvas.translate(0, -50);
    canvas.rotate(beamAngle);
    
    bool isBalanced = beamAngle.abs() < 0.02;
    Color beamColor = isBalanced ? Colors.green : Colors.red;
    
    canvas.drawRRect(RRect.fromLTRBR(-160, -6, 160, 6, const Radius.circular(6)), Paint()..color = beamColor);
    
    Path ptr = Path()..moveTo(-4, 0)..lineTo(4, 0)..lineTo(0, -35)..close();
    canvas.drawPath(ptr, Paint()..color = Colors.red);
    
    _drawPanBack(canvas, -150);
    _drawPanBack(canvas, 150);

    canvas.restore();
  }

  void _drawScaleForeground(Canvas canvas) {
    canvas.save();
    canvas.translate(0, -50);
    canvas.rotate(beamAngle);
    
    _drawPanFront(canvas, -150, 'left_pan');
    _drawPanFront(canvas, 150, 'right_pan');
    
    canvas.drawCircle(const Offset(0, 0), 12, Paint()..color = Colors.amber);
    canvas.drawCircle(const Offset(0, 0), 6, Paint()..color = Colors.amberAccent);
    
    canvas.restore();
  }

  void _drawPanBack(Canvas canvas, double offsetX) {
    canvas.save();
    canvas.translate(offsetX, 0);
    canvas.rotate(-beamAngle);
    canvas.drawLine(const Offset(0, 0), const Offset(0, 140), Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 2);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 140), width: 140, height: 36), Paint()..color = const Color(0xFF334155));
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 140), width: 130, height: 26), Paint()..color = const Color(0xFF1E293B));
    canvas.restore();
  }

  void _drawPanFront(Canvas canvas, double offsetX, String panId) {
    canvas.save();
    canvas.translate(offsetX, 0);
    canvas.rotate(-beamAngle);
    canvas.drawLine(const Offset(0, 0), const Offset(-65, 140), Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 2);
    canvas.drawLine(const Offset(0, 0), const Offset(65, 140), Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 2);
    
    if (draggedEntity?.type == 'divide_tool' && hoverZone == panId) {
      canvas.drawOval(Rect.fromCenter(center: const Offset(0, 140), width: 140, height: 36), Paint()..color = Colors.lightBlueAccent.withOpacity(0.3));
    }
    
    canvas.restore();
  }

  void _drawEntity(Canvas canvas, Entity ent) {
    canvas.save();
    canvas.translate(ent.x, ent.y);
    double s = ent.scale * 1.8;
    canvas.scale(s, s);

    String label = "e";
    if (currentScenario == 1 || currentScenario == 3) label = "y";

    if (ent.type == 'sack') {
      canvas.translate(-12, -12);
      Path sackPath = Path()..moveTo(12, 2)..cubicTo(9.24, 2, 7, 4.24, 7, 7)..cubicTo(7, 8.48, 7.63, 9.81, 8.64, 10.76)..lineTo(7, 12)..lineTo(7, 14)..lineTo(9, 14)..lineTo(9, 12.55)..cubicTo(9.61, 12.85, 10.29, 13, 11, 13)..cubicTo(11.71, 13, 12.39, 12.85, 13, 12.55)..lineTo(13, 14)..lineTo(15, 14)..lineTo(15, 12)..lineTo(13.36, 10.76)..cubicTo(14.37, 9.81, 15, 8.48, 15, 7)..cubicTo(15, 4.24, 12.76, 2, 10, 2)..close();
      canvas.drawPath(sackPath, Paint()..color = const Color(0xFF6366F1));
      _drawText(canvas, label, 11, 7, fontSize: 8, color: Colors.white);
    } else if (ent.type == 'weight') {
      canvas.translate(-12, -12);
      Path weightPath = Path()..moveTo(19, 10)..lineTo(16, 10)..lineTo(16, 7)..cubicTo(16, 5.9, 15.1, 5, 14, 5)..lineTo(10, 5)..cubicTo(8.9, 5, 8, 5.9, 8, 7)..lineTo(8, 10)..lineTo(5, 10)..cubicTo(3.9, 10, 3, 10.9, 3, 12)..lineTo(3, 19)..cubicTo(3, 20.1, 3.9, 21, 5, 21)..lineTo(19, 21)..cubicTo(20.1, 21, 21, 20.1, 21, 19)..lineTo(21, 12)..cubicTo(21, 10.9, 20.1, 10, 19, 10)..close();
      canvas.drawPath(weightPath, Paint()..color = const Color(0xFF0EA5E9));
      _drawText(canvas, ent.val.toString(), 12, 16, fontSize: 8, color: Colors.white);
    } else if (ent.type == 'divide_tool') {
      canvas.drawCircle(const Offset(0, 0), 15, Paint()..color = const Color(0xFF0F172A));
      canvas.drawCircle(const Offset(0, 0), 15, Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 2);
      _drawText(canvas, "✂", 0, 1, fontSize: 16, color: const Color(0xFF38BDF8));
    } else if (ent.type == 'icon') {
      IconData iconData = ent.id == 'truck' ? Icons.local_shipping : Icons.room_service;
      TextPainter tp = TextPainter(
          text: TextSpan(
              text: String.fromCharCode(iconData.codePoint),
              style: TextStyle(
                  fontSize: 26,
                  fontFamily: iconData.fontFamily,
                  package: iconData.fontPackage,
                  color: ent.id == 'truck' ? Colors.redAccent : Colors.greenAccent)),
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2 - 5));
      if (ent.text != null) {
        final tr = i18n[lang]!;
        String displayText = tr[ent.text!] ?? ent.text!;
        _drawText(canvas, displayText, 0, 15, fontSize: 7, color: Colors.white);
      }
    }

    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, double x, double y, {double fontSize = 14, Color color = Colors.white}) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}