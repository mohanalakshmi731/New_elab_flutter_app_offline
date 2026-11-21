// Imported from new-elab-app-6; Class 6 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // zslDark
        primaryColor: const Color(0xFF6366F1), // zslIndigo
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const Cl6M_Ch3_A4_RealWorldNumberApplicationsEstimation(),
    ),
  );
}

class Cl6M_Ch3_A4_RealWorldNumberApplicationsEstimation extends StatefulWidget {
  const Cl6M_Ch3_A4_RealWorldNumberApplicationsEstimation({super.key});

  @override
  State<Cl6M_Ch3_A4_RealWorldNumberApplicationsEstimation> createState() =>
      _Cl6M_Ch3_A4_RealWorldNumberApplicationsEstimationState();
}

class _Cl6M_Ch3_A4_RealWorldNumberApplicationsEstimationState
    extends State<Cl6M_Ch3_A4_RealWorldNumberApplicationsEstimation>
    with TickerProviderStateMixin {
  // --- Constants & System Setup ---
  final GlobalKey _canvasKey = GlobalKey();
  late AnimationController _gameLoop;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // --- UI State ---
  bool _showCurtain = true;
  bool _sidebarOpen = true;
  String _lang = 'en';
  double _sidebarWidth = 350;
  bool _showSuccessPopup = false;

  // --- Camera & Interaction ---
  double _zoom = 1.0;
  double _panX = 0.0;
  double _panY = 0.0;
  double _baseZoom = 1.0;
  bool _isPanning = false;
  bool _isResizing = false;

  // --- Simulation State ---
  int _scenario = 1;
  int _step = 0;
  String? _activeDragEntity;
  double _dragX = 0;
  double _dragY = 0;
  bool _animating = false;

  // Scenario 1
  List<Student> s1Students = [];
  List<int?> s1Slots = [null, null, null, null, null];
  final List<int> s1Target = [0, 1, 2, 1, 0];

  // Scenario 2
  List<StoreItem> s2Cart = [];
  double s2Spent = 0;
  double s2Budget = 100;
  final List<StoreItem> s2Items = [
    StoreItem('milk', 25, Colors.white),
    StoreItem('banana', 30, Colors.yellowAccent),
    StoreItem('apple', 40, Colors.redAccent),
    StoreItem('grape', 35, Colors.purpleAccent),
  ];
  bool s2GhostRed = false;

  // Scenario 3
  List<Offset> s3Icons = [];
  final List<Offset> s3Nodes = const [
    Offset(-200, 150),
    Offset(-100, 80),
    Offset(0, 20),
    Offset(100, -40),
    Offset(200, -100),
  ];

  // Scenario 4
  List<StoreItem> s4Stall = [];
  double s4Spent = 0;
  double s4Price = 15;
  double s4Profit = 0;
  bool s4SimActive = false;
  double s4SimProgress = 0;
  List<Customer> s4Customers = [];
  final List<StoreItem> s4Store = [
    StoreItem('table', 100, Colors.brown),
    StoreItem('rings', 50, Colors.red),
    StoreItem('prizeS', 20, Colors.purple),
    StoreItem('prizeL', 80, Colors.orange),
  ];

  // Scenario 5
  List<List<int>> s5Grid = List.generate(10, (_) => List.filled(10, 0));
  List<ParkPlacedItem> s5ItemsPlaced = [];
  int s5SpaceUsed = 0;
  final Map<String, ParkItemConfig> s5Catalog = {
    'tree': ParkItemConfig('tree', 1, 1, Colors.green),
    'bench': ParkItemConfig('bench', 2, 1, Colors.brown[700]!),
    'swing': ParkItemConfig('swing', 3, 2, Colors.blue),
    'slide': ParkItemConfig('slide', 4, 2, Colors.red),
    'fountain': ParkItemConfig('fountain', 4, 3, Colors.cyan),
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();
    _gameLoop.addListener(_updateLoop);

    _initScenarioData();
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    _audioPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _playSound(String type) {
    String url = '';
    switch (type) {
      case 'tick':
        url = 'audio/class6/math/click.mp3';
        break;
      case 'snap':
        url = 'audio/class6/math/click.mp3';
        break;
      case 'success':
        url = 'audio/class6/math/success.mp3';
        break;
      case 'error':
        url = 'audio/class6/math/mixkit_2955.mp3';
        break;
      case 'cash':
        url = 'audio/class6/math/mixkit_2000.mp3';
        break;
      case 'pop':
        url = 'audio/class6/math/click.mp3';
        break;
    }
    if (url.isNotEmpty) {
      _audioPlayer.play(AssetSource(url), volume: 0.3);
    }
  }

  void _initScenarioData() {
    s1Students = [
      Student(0, 180, Colors.red),
      Student(1, 160, Colors.blue),
      Student(2, 140, Colors.green),
      Student(3, 120, Colors.orange),
      Student(4, 100, Colors.purple),
    ];
  }

  void _loadScenario(int id) {
    setState(() {
      if (id == 1) _showCurtain = true;
      _scenario = id;
      _step = 0;
      _activeDragEntity = null;
      _animating = false;
      _showSuccessPopup = false;

      // Reset specific logic
      if (id == 1) {
        for (var s in s1Students) {
          s.slot = null;
          s.x = 0;
          s.y = 0;
        }
        s1Slots = [null, null, null, null, null];
      } else if (id == 2) {
        s2Cart.clear();
        s2Spent = 0;
        s2GhostRed = false;
      } else if (id == 3) {
        s3Icons.clear();
      } else if (id == 4) {
        s4Stall.clear();
        s4Spent = 0;
        s4Price = 15;
        s4Profit = 0;
        s4SimActive = false;
      } else if (id == 5) {
        s5Grid = List.generate(10, (_) => List.filled(10, 0));
        s5ItemsPlaced.clear();
        s5SpaceUsed = 0;
      }

      _panX = 0;
      _panY = 0;
      _zoom = 1.0;
      _playSound('pop');

      if ([2, 3, 5].contains(_scenario)) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _scenario == id && _step == 0) _advanceStep();
        });
      }
    });
  }

  void _advanceStep() {
    if (mounted) setState(() => _step++);
  }

  void _checkSuccess() {
    int maxSteps = _scenario == 1
        ? 3
        : _scenario == 2
        ? 4
        : _scenario == 3
        ? 3
        : _scenario == 4
        ? 3
        : 3;
    setState(() => _step = maxSteps);
    Future.delayed(
      const Duration(seconds: 1),
      () => setState(() => _showSuccessPopup = true),
    );
  }

  void _updateLoop() {
    if (s4SimActive) {
      setState(() {
        s4SimProgress += 0.02;
        if (Random().nextDouble() > 0.6) {
          s4Customers.add(Customer(-400, 220, 5 + Random().nextDouble() * 5));
        }

        for (int i = s4Customers.length - 1; i >= 0; i--) {
          var c = s4Customers[i];
          c.x += c.speed;
          if (!c.played &&
              (c.x - 125).abs() < 30 &&
              Random().nextDouble() > 0.4) {
            c.played = true;
            s4Profit += s4Price;
            _playSound('cash');
          }
          if (c.x > 400) s4Customers.removeAt(i);
        }

        if (s4SimProgress >= 1) {
          s4SimActive = false;
          _playSound('success');
          _advanceStep();
          Future.delayed(const Duration(seconds: 1), _checkSuccess);
        }
      });
    } else {
      if (mounted) setState(() {}); // Trigger repaint
    }
  }

  // --- Interaction Logics ---
  void _onScaleStart(ScaleStartDetails details) {
    if (_animating) return;

    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPos = box.globalToLocal(details.focalPoint);
    double worldX = (localPos.dx - box.size.width / 2 - _panX) / _zoom;
    double worldY = (localPos.dy - box.size.height / 2 - _panY) / _zoom;

    _activeDragEntity = null;
    _isPanning = false;

    if (details.pointerCount == 1) {
      if (_scenario == 1) {
        for (var st in s1Students) {
          if (worldX > st.x - 20 &&
              worldX < st.x + 20 &&
              worldY > st.y - st.h &&
              worldY < st.y) {
            if (st.slot != null) s1Slots[st.slot!] = null;
            st.slot = null;
            _activeDragEntity = 'stu_${st.id}';
            _dragX = worldX;
            _dragY = worldY;
            _playSound('tick');
            return;
          }
        }
      } else if (_scenario == 2) {
        if (_step >= 3 &&
            worldX > 125 &&
            worldX < 325 &&
            worldY > 230 &&
            worldY < 280) {
          if (s2Spent <= 100) {
            _playSound('success');
            _advanceStep();
            Future.delayed(const Duration(seconds: 1), _checkSuccess);
          } else {
            _playSound('error');
          }
          return;
        }
        for (int i = 0; i < s2Items.length; i++) {
          double ix = -250 + (i % 2) * 100;
          double iy = -30 + (i ~/ 2) * 150;
          if (worldX > ix - 30 &&
              worldX < ix + 30 &&
              worldY > iy - 30 &&
              worldY < iy + 30) {
            _activeDragEntity = 'item_${s2Items[i].id}';
            _dragX = worldX;
            _dragY = worldY;
            _playSound('tick');
            return;
          }
        }
      } else if (_scenario == 3) {
        if (_step >= 2 &&
            s3Icons.length >= 2 &&
            worldX > 150 &&
            worldX < 350 &&
            worldY > 230 &&
            worldY < 280) {
          if (s3Icons.length == 9) {
            _playSound('success');
            _advanceStep();
            Future.delayed(const Duration(seconds: 1), _checkSuccess);
          } else {
            _playSound('error');
          }
          return;
        }
        if (worldX > -340 && worldX < -280 && worldY > 120 && worldY < 180) {
          _activeDragEntity = 'icon';
          _dragX = worldX;
          _dragY = worldY;
          _playSound('tick');
          return;
        }
      } else if (_scenario == 4) {
        bool canOpen =
            s4Stall.any((i) => i.id == 'table') &&
            s4Stall.any((i) => i.id == 'rings') &&
            s4Stall.any((i) => i.id.startsWith('prize'));
        if (canOpen &&
            worldX > 180 &&
            worldX < 300 &&
            worldY > 130 &&
            worldY < 180) {
          _playSound('tick');
          setState(() {
            s4SimActive = true;
            s4Profit = 0;
            s4SimProgress = 0;
            s4Customers.clear();
          });
          return;
        }
        if (worldX > -60 && worldX < 160 && worldY > 110 && worldY < 180) {
          _activeDragEntity = 's4_slider';
          return;
        }
        for (int i = 0; i < s4Store.length; i++) {
          double iy = -100 + (i * 80);
          if (worldX > -280 &&
              worldX < -220 &&
              worldY > iy - 20 &&
              worldY < iy + 40) {
            _activeDragEntity = 'store_${s4Store[i].id}';
            _dragX = worldX;
            _dragY = worldY;
            _playSound('tick');
            return;
          }
        }
      } else if (_scenario == 5) {
        if (s5SpaceUsed > 80 &&
            _step >= 2 &&
            worldX > 200 &&
            worldX < 350 &&
            worldY > 0 &&
            worldY < 50) {
          _playSound('success');
          _advanceStep();
          Future.delayed(const Duration(seconds: 1), _checkSuccess);
          return;
        }
        int i = 0;
        s5Catalog.forEach((k, v) {
          double cy = -110 + i * 50;
          if (worldX > -360 &&
              worldX < -220 &&
              worldY > cy - 15 &&
              worldY < cy + 15) {
            _activeDragEntity = 'cat_$k';
            _dragX = worldX;
            _dragY = worldY;
            _playSound('tick');
            return;
          }
          i++;
        });
        if (_activeDragEntity != null) return;
      }
    }

    _isPanning = true;
    _baseZoom = _zoom;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_animating) return;

    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPos = box.globalToLocal(details.focalPoint);
    double worldX = (localPos.dx - box.size.width / 2 - _panX) / _zoom;
    double worldY = (localPos.dy - box.size.height / 2 - _panY) / _zoom;

    if (_activeDragEntity != null) {
      if (_activeDragEntity == 's4_slider') {
        double relX = worldX - (-50);
        double rawVal = ((relX / 200) * 10 + 10).roundToDouble();
        setState(() => s4Price = rawVal.clamp(10, 20));
      } else {
        setState(() {
          _dragX = worldX;
          _dragY = worldY;
          if (_scenario == 2 && _activeDragEntity!.startsWith('item_')) {
            String id = _activeDragEntity!.split('_')[1];
            double price = s2Items.firstWhere((i) => i.id == id).p;
            s2GhostRed =
                (worldX > 100 &&
                    worldX < 350 &&
                    worldY > -100 &&
                    worldY < 200) &&
                (s2Spent + price > 100);
          }
        });
      }
      return;
    }

    if (_isPanning) {
      setState(() {
        // Accumulate the continuous movement deltas instead of adding to the base
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
        _zoom = (_baseZoom * details.scale).clamp(0.4, 2.5);
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_animating) return;

    if (_activeDragEntity != null) {
      if (_activeDragEntity == 's4_slider') {
        if (_scenario == 4 && _step == 1 && s4Price != 15) _advanceStep();
        _playSound('tick');
      } else if (_scenario == 1 && _activeDragEntity!.startsWith('stu_')) {
        int sId = int.parse(_activeDragEntity!.split('_')[1]);
        Student st = s1Students.firstWhere((s) => s.id == sId);
        int? droppedSlot;
        for (int i = 0; i < 5; i++) {
          double sx = -160 + i * 80.0;
          double sy = 250;
          if (_dragX > sx - 40 &&
              _dragX < sx + 40 &&
              _dragY > sy - 40 &&
              _dragY < sy + 40) {
            droppedSlot = i;
          }
        }
        if (droppedSlot != null && s1Slots[droppedSlot] == null) {
          setState(() {
            st.slot = droppedSlot;
            s1Slots[droppedSlot!] = st.id;
            _playSound('snap');
            int occ = s1Slots.where((x) => x != null).length;
            if (_step == 0 && occ >= 1) _advanceStep();
            if (_step == 1 && occ >= 2) _advanceStep();
            if (occ == 5) {
              List<int> currSeq = [];
              for (int i = 0; i < 5; i++) {
                var s = s1Students.firstWhere((x) => x.slot == i);
                int n = 0;
                if (i > 0) {
                  var ls = s1Students.firstWhere((x) => x.slot == i - 1);
                  if (ls.h > s.h) n++;
                }
                if (i < 4) {
                  var rs = s1Students.firstWhere((x) => x.slot == i + 1);
                  if (rs.h > s.h) n++;
                }
                currSeq.add(n);
              }
              bool match = true;
              for (int i = 0; i < 5; i++) {
                if (currSeq[i] != s1Target[i]) match = false;
              }
              if (match) {
                _playSound('success');
                _advanceStep();
                Future.delayed(const Duration(seconds: 1), _checkSuccess);
              }
            }
          });
        } else {
          _playSound('error');
          setState(() => st.slot = null);
        }
      } else if (_scenario == 2 && _activeDragEntity!.startsWith('item_')) {
        String id = _activeDragEntity!.split('_')[1];
        double price = s2Items.firstWhere((i) => i.id == id).p;
        if (_dragX > 100 && _dragX < 350 && _dragY > -100 && _dragY < 200) {
          if (s2Spent + price <= 100) {
            setState(() {
              s2Cart.add(StoreItem(id, price, Colors.white));
              s2Spent += price;
              _playSound('snap');
              if (s2Cart.any((x) => x.id == 'milk') && _step < 2) {
                _advanceStep();
              }
              if (s2Cart.any((x) => x.id == 'banana') &&
                  s2Cart.any((x) => x.id == 'apple') &&
                  _step < 3) {
                _advanceStep();
              }
            });
          } else {
            _playSound('error');
          }
        } else {
          _playSound('error');
        }
        setState(() => s2GhostRed = false);
      } else if (_scenario == 3 && _activeDragEntity == 'icon') {
        if (_dragX > -300 && _dragX < 350 && _dragY > -200 && _dragY < 300) {
          setState(() {
            s3Icons.add(Offset(_dragX, _dragY));
            _playSound('snap');
            if (s3Icons.isNotEmpty && _step < 2) _advanceStep();
          });
        } else {
          _playSound('error');
        }
      } else if (_scenario == 4 && _activeDragEntity!.startsWith('store_')) {
        String id = _activeDragEntity!.split('_')[1];
        double price = s4Store.firstWhere((i) => i.id == id).p;
        if (_dragX > -50 && _dragX < 300 && _dragY > -150 && _dragY < 100) {
          if (s4Spent + price <= 500) {
            setState(() {
              s4Stall.add(StoreItem(id, price, Colors.white));
              s4Spent += price;
              _playSound('snap');
              bool canOpen =
                  s4Stall.any((i) => i.id == 'table') &&
                  s4Stall.any((i) => i.id == 'rings') &&
                  s4Stall.any((i) => i.id.startsWith('prize'));
              if (_step == 0 && canOpen) _advanceStep();
            });
          } else {
            _playSound('error');
          }
        } else {
          _playSound('error');
        }
      } else if (_scenario == 5 && _activeDragEntity!.startsWith('cat_')) {
        String id = _activeDragEntity!.split('_')[1];
        ParkItemConfig conf = s5Catalog[id]!;
        double gSize = 30;
        double gx = -150;
        double gy = -150;
        int col = ((_dragX - gx) / gSize).floor();
        int row = ((_dragY - gy) / gSize).floor();

        if (col >= 0 && col + conf.w <= 10 && row >= 0 && row + conf.h <= 10) {
          bool valid = true;
          for (int r = row; r < row + conf.h; r++) {
            for (int c = col; c < col + conf.w; c++) {
              if (s5Grid[r][c] == 1) valid = false;
            }
          }
          if (valid) {
            setState(() {
              for (int r = row; r < row + conf.h; r++) {
                for (int c = col; c < col + conf.w; c++) {
                  s5Grid[r][c] = 1;
                }
              }
              s5ItemsPlaced.add(ParkPlacedItem(id, row, col));
              s5SpaceUsed += (conf.w * conf.h);
              _playSound('snap');
              if (id == 'fountain' && _step < 2) _advanceStep();
            });
          } else {
            _playSound('error');
          }
        } else {
          _playSound('error');
        }
      }

      setState(() => _activeDragEntity = null);
    }
  }

  // --- Translation Dictionary ---
  String t(String key) {
    Map<String, dynamic> langDict =
        _translations[_lang] ?? _translations['en']!;
    List<String> parts = key.split('.');
    dynamic val = langDict;
    for (var p in parts) {
      if (val is Map) {
        val = val[p];
      } else {
        return key;
      }
    }
    return val?.toString() ?? key;
  }

  static const Map<String, Map<String, dynamic>> _translations = {
    'en': {
      'appTitle': 'Number Applications & Estimation',
      'appSubtitle': 'Class 6 • NUMBER PLAY',
      'enterLab': 'Enter Simulation',
      'selectScenario': 'Select Scenario',
      'stepLabel': 'STEP',
      'learnLbl': 'Objective / Learning:',
      'summaryTitle': 'Goal Reached!',
      'finishLab': 'Finish Lab',
      'nextScenario': 'Next Scenario',
      'finalDesc': 'You have successfully completed all estimation challenges!',
      's1_title': '1. The Assembly Line-Up',
      's1_obj': 'Arrange students to match target sequence [0, 1, 2, 1, 0].',
      's1_step1_task': 'Drag ANY student to an empty spot.',
      's1_step1_out': 'Bubble shows 0 (no neighbors).',
      's1_step2_task': 'Drag a second student next to the first.',
      's1_step2_out': 'Numbers update relative to height.',
      's1_step3_task': 'Arrange all to [0, 1, 2, 1, 0].',
      's1_step3_out': 'Success! Numbers represent relationships.',
      'lbl_s1_target': 'Target Sequence: [0, 1, 2, 1, 0]',
      'lbl_s1_holding': 'Holding Area',
      's1_hud1': 'Drag any student into a glowing slot.',
      's1_hud2': 'Drag another student next to them.',
      's1_hud3': 'Arrange all to match target [0, 1, 2, 1, 0].',

      's2_title': '2. Supermarket Budget',
      's2_obj': 'Estimate grocery costs within ₹100 budget.',
      's2_step1_task': 'Observe your shopping list and ₹100 budget.',
      's2_step1_out': 'Need Milk, Bananas, Apples, Grapes.',
      's2_step2_task': 'Drag Milk (₹25) into cart.',
      's2_step2_out': 'Budget updates. ₹75 left.',
      's2_step3_task': 'Drag Bananas (₹30) & Apples (₹40) to cart.',
      's2_step3_out': 'Cart total ₹95.',
      's2_step4_task': 'Try Grapes (₹35). Then click Checkout.',
      's2_step4_out': 'Estimation helps prevent overspending!',
      'lbl_s2_budget': 'Budget:',
      'lbl_s2_cart': 'Cart Total:',
      'lbl_s2_checkout': 'CHECKOUT',
      's2_hud1': 'Observe the list and budget.',
      's2_hud2': 'Drag Milk into the cart.',
      's2_hud3': 'Drag Bananas and Apples into the cart.',
      's2_hud4': 'Try Grapes, then click Checkout.',
      'lbl_s2_items': {
        'milk': 'Milk (₹25)',
        'banana': 'Bananas (₹30)',
        'apple': 'Apples (₹40)',
        'grape': 'Grapes (₹35)',
      },

      's3_title': '3. Cross-Country Hike',
      's3_obj': 'Estimate travel days on a map. 1 Icon = 3 Days.',
      's3_step1_task': 'Observe the map from Gandhinagar to Kohima.',
      's3_step1_out': '1 Icon = 3 days walking.',
      's3_step2_task': 'Drag a walking icon onto the path.',
      's3_step2_out': 'Estimated days increase by 3.',
      's3_step3_task': 'Fill the path and click Check Estimate.',
      's3_step3_out': 'Path requires 9 icons (27 days).',
      'lbl_s3_legend': '1 Icon = 3 Days',
      'lbl_s3_est': 'Estimated Days:',
      'lbl_s3_check': 'CHECK ESTIMATE',
      's3_hud1': 'Observe the map and legend.',
      's3_hud2': 'Drag an icon to the path.',
      's3_hud3': 'Fill the path and click Check.',

      's4_title': '4. School Fair Profit',
      's4_obj': 'Plan a stall within ₹500 budget and estimate profit.',
      's4_step1_task': 'Drag supplies to your stall (Table, Rings, Prizes).',
      's4_step1_out': 'Setting up inventory within budget.',
      's4_step2_task': 'Adjust Game Price slider.',
      's4_step2_out': 'Price affects customer behavior.',
      's4_step3_task': 'Click Open Stall to simulate.',
      's4_step3_out': 'Estimating costs vs revenue is key.',
      'lbl_s4_budget': 'Budget:',
      'lbl_s4_profit': 'Profit:',
      'lbl_s4_open': 'OPEN STALL',
      'lbl_s4_price': 'Game Price: ₹',
      's4_hud1': 'Buy a Table, Rings, and Prizes.',
      's4_hud2': 'Set your Game Price.',
      's4_hud3': 'Click Open Stall.',
      'lbl_s4_store': {
        'table': 'Table ₹100',
        'rings': 'Rings ₹50',
        'prizeS': 'Sm Prize ₹20',
        'prizeL': 'Lg Prize ₹80',
      },

      's5_title': '5. Dream Park Design',
      's5_obj': 'Estimate space to fit items in a 10x10 park grid (100 units).',
      's5_step1_task': 'Observe the 10x10 empty grid.',
      's5_step1_out': 'Fill without overlapping.',
      's5_step2_task': 'Drag a Fountain (12 units) onto grid.',
      's5_step2_out': 'Space used updates.',
      's5_step3_task': 'Fill park > 80 units. Click Finalize.',
      's5_step3_out': 'Estimation fits objects into constrained areas!',
      'lbl_s5_space': 'Space Used:',
      'lbl_s5_finalize': 'FINALIZE',
      's5_hud1': 'Observe the 100-unit grid.',
      's5_hud2': 'Drag a Fountain to the grid.',
      's5_hud3': 'Fill >80 units and click Finalize.',
      'lbl_s5_items': {
        'tree': 'Tree (1)',
        'bench': 'Bench (2)',
        'swing': 'Swing (6)',
        'slide': 'Slide (8)',
        'fountain': 'Fount (12)',
      },
    },
    'hi': {
      'appTitle': 'संख्या अनुप्रयोग और अनुमान',
      'appSubtitle': 'कक्षा 6 • संख्याओं के साथ खेल',
      'enterLab': 'सिमुलेशन दर्ज करें',
      'selectScenario': 'परिदृश्य चुनें',
      'stepLabel': 'चरण',
      'learnLbl': 'उद्देश्य:',
      'summaryTitle': 'लक्ष्य प्राप्त हुआ!',
      'finishLab': 'समाप्त करें',
      'nextScenario': 'अगला परिदृश्य',
      'finalDesc': 'आपने सभी अनुमान चुनौतियों को सफलतापूर्वक पूरा कर लिया है!',
      's1_title': '1. असेंबली लाइन-अप',
      's1_obj':
          'छात्रों को लक्ष्य अनुक्रम [0, 1, 2, 1, 0] से मिलाने के लिए व्यवस्थित करें।',
      's1_step1_task': 'किसी भी छात्र को खाली स्थान पर खींचें।',
      's1_step1_out': 'बबल 0 दिखाता है (कोई पड़ोसी नहीं)।',
      's1_step2_task': 'दूसरे छात्र को पहले वाले के पास खींचें।',
      's1_step2_out': 'नंबर ऊंचाई के सापेक्ष अपडेट होते हैं।',
      's1_step3_task': 'सभी को [0, 1, 2, 1, 0] पर व्यवस्थित करें।',
      's1_step3_out': 'सफलता! संख्याएँ संबंधों को दर्शाती हैं।',
      'lbl_s1_target': 'लक्ष्य: [0, 1, 2, 1, 0]',
      'lbl_s1_holding': 'होल्डिंग एरिया',
      's1_hud1': 'किसी भी छात्र को स्लॉट में खींचें।',
      's1_hud2': 'दूसरे छात्र को उनके पास खींचें।',
      's1_hud3': 'लक्ष्य से मिलाने के लिए सभी को व्यवस्थित करें।',

      's2_title': '2. सुपरमार्केट बजट',
      's2_obj': '₹100 के बजट में किराने के सामान का अनुमान लगाएं।',
      's2_step1_task': 'अपनी सूची और ₹100 बजट देखें।',
      's2_step1_out': 'दूध, केले, सेब और अंगूर चाहिए।',
      's2_step2_task': 'दूध (₹25) कार्ट में खींचें।',
      's2_step2_out': 'बजट अपडेट। ₹75 बचे हैं।',
      's2_step3_task': 'केले (₹30) और सेब (₹40) कार्ट में खींचें।',
      's2_step3_out': 'कार्ट का कुल मूल्य ₹95।',
      's2_step4_task': 'अंगूर (₹35) का प्रयास करें। फिर चेकआउट करें।',
      's2_step4_out': 'अनुमान से मदद मिलती है!',
      'lbl_s2_budget': 'बजट:',
      'lbl_s2_cart': 'कुल:',
      'lbl_s2_checkout': 'चेकआउट',
      's2_hud1': 'सूची और बजट देखें।',
      's2_hud2': 'दूध को कार्ट में खींचें।',
      's2_hud3': 'केले और सेब कार्ट में खींचें।',
      's2_hud4': 'अंगूर का प्रयास करें, फिर चेकआउट करें।',
      'lbl_s2_items': {
        'milk': 'दूध (₹25)',
        'banana': 'केले (₹30)',
        'apple': 'सेब (₹40)',
        'grape': 'अंगूर (₹35)',
      },

      's3_title': '3. क्रॉस-कंट्री हाइक',
      's3_obj': 'मानचित्र पर यात्रा के दिनों का अनुमान लगाएं। 1 आइकन = 3 दिन।',
      's3_step1_task': 'मानचित्र देखें।',
      's3_step1_out': '1 आइकन 3 दिन चलने का प्रतिनिधित्व करता है।',
      's3_step2_task': 'एक आइकन को पथ पर खींचें।',
      's3_step2_out': 'अनुमानित दिन 3 बढ़ जाते हैं।',
      's3_step3_task': 'पथ भरें और अनुमान जांचें।',
      's3_step3_out': 'पथ के लिए 9 आइकन (27 दिन) की आवश्यकता है।',
      'lbl_s3_legend': '1 आइकन = 3 दिन',
      'lbl_s3_est': 'अनुमानित दिन:',
      'lbl_s3_check': 'अनुमान जांचें',
      's3_hud1': 'मानचित्र और लेजेंड देखें।',
      's3_hud2': 'आइकन को पथ पर खींचें।',
      's3_hud3': 'पथ भरें और जांचें पर क्लिक करें।',

      's4_title': '4. स्कूल मेला लाभ',
      's4_obj':
          '₹500 के बजट में एक स्टॉल की योजना बनाएं और लाभ का अनुमान लगाएं।',
      's4_step1_task': 'सामान खींचें (टेबल, रिंग सेट, इनाम)।',
      's4_step1_out': 'स्टॉल स्थापित कर रहे हैं।',
      's4_step2_task': 'गेम मूल्य स्लाइडर समायोजित करें।',
      's4_step2_out': 'मूल्य ग्राहकों को प्रभावित करता है।',
      's4_step3_task': 'स्टॉल खोलें पर क्लिक करें।',
      's4_step3_out': 'लाभ के लिए लागत का अनुमान लगाना आवश्यक है।',
      'lbl_s4_budget': 'बजट:',
      'lbl_s4_profit': 'लाभ:',
      'lbl_s4_open': 'स्टॉल खोलें',
      'lbl_s4_price': 'गेम मूल्य: ₹',
      's4_hud1': 'टेबल, रिंग और इनाम खरीदें।',
      's4_hud2': 'गेम का मूल्य निर्धारित करें।',
      's4_hud3': 'स्टॉल खोलें पर क्लिक करें।',
      'lbl_s4_store': {
        'table': 'टेबल ₹100',
        'rings': 'रिंग्स ₹50',
        'prizeS': 'छोटा इनाम ₹20',
        'prizeL': 'बड़ा इनाम ₹80',
      },

      's5_title': '5. ड्रीम पार्क डिजाइन',
      's5_obj': '10x10 ग्रिड (100 इकाइयाँ) में वस्तुओं को फिट करें।',
      's5_step1_task': '10x10 खाली ग्रिड देखें।',
      's5_step1_out': 'बिना ओवरलैप किए पार्क भरें।',
      's5_step2_task': 'फव्वारा (12 इकाइयां) खींचें।',
      's5_step2_out': 'उपयोग किया गया स्थान अपडेट हुआ।',
      's5_step3_task': '>80 इकाइयां भरें और अंतिम रूप दें।',
      's5_step3_out': 'सीमित क्षेत्र में वस्तुओं को फिट किया!',
      'lbl_s5_space': 'उपयोग स्थान:',
      'lbl_s5_finalize': 'अंतिम रूप दें',
      's5_hud1': 'ग्रिड देखें।',
      's5_hud2': 'फव्वारे को ग्रिड पर खींचें।',
      's5_hud3': '>80 इकाइयाँ भरें और अंतिम रूप दें।',
      'lbl_s5_items': {
        'tree': 'पेड़ (1)',
        'bench': 'बेंच (2)',
        'swing': 'झूला (6)',
        'slide': 'स्लाइड (8)',
        'fountain': 'फव्वारा (12)',
      },
    },
  };

  // --- Build Methods ---
  @override
  Widget build(BuildContext context) {
    // Immersive Mode Enforcement
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: _showCurtain ? _buildCurtain() : _buildMainSimulation(),
      ),
    );
  }

  Widget _buildCurtain() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF0F172A), // Fixed dark background color
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.calculate_outlined,
                size: 100,
                color: Color(0xFF6366F1),
              ),
              const SizedBox(height: 20),
              Text(
                t('appTitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t('appSubtitle'),
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _showCurtain = false);
                  _playSound('tick');
                },
                icon: const Icon(Icons.play_circle_fill, size: 28),
                label: Text(
                  t('enterLab'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
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
    );
  }

  Widget _buildMainSimulation() {
    return Stack(
      children: [
        // Canvas Area
        AnimatedPositioned(
          duration: _isResizing
              ? Duration.zero
              : const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: _sidebarOpen ? _sidebarWidth : 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            color: const Color(0xFF0F172A),
            child: GestureDetector(
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onScaleEnd: _onScaleEnd,
              child: CustomPaint(
                key: _canvasKey,
                painter: LabPainter(
                  scenario: _scenario,
                  step: _step,
                  zoom: _zoom,
                  panX: _panX,
                  panY: _panY,
                  dragEnt: _activeDragEntity,
                  dragX: _dragX,
                  dragY: _dragY,
                  t: t,
                  // State references
                  s1Students: s1Students,
                  s1Slots: s1Slots,
                  s1Target: s1Target,
                  s2Cart: s2Cart,
                  s2Spent: s2Spent,
                  s2Items: s2Items,
                  s2GhostRed: s2GhostRed,
                  s3Nodes: s3Nodes,
                  s3Icons: s3Icons,
                  s4Stall: s4Stall,
                  s4Spent: s4Spent,
                  s4Price: s4Price,
                  s4Profit: s4Profit,
                  s4Store: s4Store,
                  s4Customers: s4Customers,
                  s4SimActive: s4SimActive,
                  s5Grid: s5Grid,
                  s5ItemsPlaced: s5ItemsPlaced,
                  s5SpaceUsed: s5SpaceUsed,
                  s5Catalog: s5Catalog,
                ),
              ),
            ),
          ),
        ),

        // Sidebar
        AnimatedPositioned(
          duration: _isResizing
              ? Duration.zero
              : const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: _sidebarOpen ? 0 : -_sidebarWidth,
          top: 0,
          bottom: 0,
          width: _sidebarWidth,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(
                right: BorderSide(color: Colors.white24, width: 1),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  right: 10, // Make room for resizer
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            60,
                            20,
                            20,
                          ), // Top padding for menu icon
                          color: const Color(0xFF0F172A),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calculate,
                                    color: Color(0xFF6366F1),
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      t('appTitle'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t('appSubtitle'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => setState(() {
                                      _lang = _lang == 'en' ? 'hi' : 'en';
                                      _playSound('tick');
                                    }),
                                    icon: const Icon(Icons.language, size: 16),
                                    label: Text(_lang == 'en' ? 'EN' : 'HI'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E293B),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _playSound('pop');
                                      _loadScenario(_scenario);
                                      _showCurtain = true;
                                    },
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('Reset'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent
                                          .withOpacity(0.1),
                                      foregroundColor: Colors.redAccent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Scrollable Content Body
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t('selectScenario'),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
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
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    value: _scenario,
                                    dropdownColor: const Color(0xFF0F172A),
                                    items: [1, 2, 3, 4, 5]
                                        .map(
                                          (i) => DropdownMenuItem(
                                            value: i,
                                            child: Text(
                                              t('s${i}_title'),
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
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.flag,
                                          color: Colors.redAccent,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          t('learnLbl'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.yellowAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      t('s${_scenario}_obj'),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              ..._buildStepUI(),
                            ],
                          ),
                        ),
                        // Footer
                        Container(
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.center,
                          color: const Color(0xFF0F172A),
                          child: const Text(
                            '© ZeroScienceLab - Fall in love with math and Science',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Resizer Handle
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 10,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: GestureDetector(
                      onPanStart: (_) => setState(() => _isResizing = true),
                      onPanUpdate: (details) {
                        setState(() {
                          _sidebarWidth += details.delta.dx;
                          _sidebarWidth = _sidebarWidth.clamp(
                            300.0,
                            MediaQuery.of(context).size.width * 0.6,
                          );
                        });
                      },
                      onPanEnd: (_) => setState(() => _isResizing = false),
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white38,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Menu Button
        Positioned(
          top: 10,
          left: 10,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: const Color(0xFF6366F1),
            child: Icon(
              _sidebarOpen ? Icons.menu_open : Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => _sidebarOpen = !_sidebarOpen);
              _playSound('tick');
            },
          ),
        ),

        // HUD
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          left: _sidebarOpen ? _sidebarWidth : 0,
          right: 0,
          bottom: 20,
          child: IgnorePointer(
            child: Center(
              child: AnimatedOpacity(
                opacity: _step < _getScenarioMaxSteps() ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF6366F1),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.lightBlueAccent,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          _step < _getScenarioMaxSteps()
                              ? t('s${_scenario}_hud${_step + 1}')
                              : '',
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
            ),
          ),
        ),

        // Success Popup
        if (_showSuccessPopup)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(30),
                width: 400,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t('summaryTitle'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _scenario == 5
                          ? t('finalDesc')
                          : 'Scenario completed successfully!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _showSuccessPopup = false;
                          if (_scenario < 5) {
                            _loadScenario(_scenario + 1);
                          } else {
                            _showCurtain = true;
                            _scenario = 1;
                            _step = 0;
                          }
                        });
                      },
                      child: Text(
                        _scenario == 5 ? 'Restart' : t('nextScenario'),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  int _getScenarioMaxSteps() {
    if (_scenario == 1) return 3;
    if (_scenario == 2) return 4;
    if (_scenario == 3) return 3;
    if (_scenario == 4) return 3;
    return 3; // sc 5
  }

  List<Widget> _buildStepUI() {
    int maxSteps = _getScenarioMaxSteps();
    List<Widget> steps = [];
    for (int i = 0; i < maxSteps; i++) {
      bool isPast = i < _step;
      bool isCurrent = i == _step;

      Color bgColor = isCurrent
          ? const Color(0xFF6366F1).withOpacity(0.2)
          : (isPast ? Colors.green.withOpacity(0.1) : Colors.black26);
      Color borderColor = isCurrent
          ? const Color(0xFF6366F1)
          : (isPast ? Colors.green : Colors.transparent);

      steps.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isPast
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : CircleAvatar(
                      radius: 12,
                      backgroundColor: isCurrent
                          ? const Color(0xFF6366F1)
                          : Colors.grey,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
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
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t('s${_scenario}_step${i + 1}_task'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isCurrent ? Colors.white : Colors.white70,
                      ),
                    ),
                    if (isPast) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          t('s${_scenario}_step${i + 1}_out'),
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
        ),
      );
    }
    return steps;
  }
}

// --- Entity Classes ---
class Student {
  int id;
  double h;
  Color c;
  int? slot;
  double x;
  double y;
  Student(this.id, this.h, this.c, {this.slot, this.x = 0, this.y = 0});
}

class StoreItem {
  String id;
  double p;
  Color c;
  StoreItem(this.id, this.p, this.c);
}

class Customer {
  double x, y, speed;
  bool played = false;
  Customer(this.x, this.y, this.speed);
}

class ParkItemConfig {
  String id;
  int w;
  int h;
  Color c;
  ParkItemConfig(this.id, this.w, this.h, this.c);
}

class ParkPlacedItem {
  String id;
  int r;
  int c;
  ParkPlacedItem(this.id, this.r, this.c);
}

// --- Custom Painter ---
class LabPainter extends CustomPainter {
  final int scenario, step;
  final double zoom, panX, panY;
  final String? dragEnt;
  final double dragX, dragY;
  final String Function(String) t;

  final List<Student> s1Students;
  final List<int?> s1Slots;
  final List<int> s1Target;

  final List<StoreItem> s2Cart;
  final double s2Spent;
  final List<StoreItem> s2Items;
  final bool s2GhostRed;

  final List<Offset> s3Nodes;
  final List<Offset> s3Icons;

  final List<StoreItem> s4Stall;
  final double s4Spent, s4Price, s4Profit;
  final List<StoreItem> s4Store;
  final List<Customer> s4Customers;
  final bool s4SimActive;

  final List<List<int>> s5Grid;
  final List<ParkPlacedItem> s5ItemsPlaced;
  final int s5SpaceUsed;
  final Map<String, ParkItemConfig> s5Catalog;

  LabPainter({
    required this.scenario,
    required this.step,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.dragEnt,
    required this.dragX,
    required this.dragY,
    required this.t,
    required this.s1Students,
    required this.s1Slots,
    required this.s1Target,
    required this.s2Cart,
    required this.s2Spent,
    required this.s2Items,
    required this.s2GhostRed,
    required this.s3Nodes,
    required this.s3Icons,
    required this.s4Stall,
    required this.s4Spent,
    required this.s4Price,
    required this.s4Profit,
    required this.s4Store,
    required this.s4Customers,
    required this.s4SimActive,
    required this.s5Grid,
    required this.s5ItemsPlaced,
    required this.s5SpaceUsed,
    required this.s5Catalog,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom);

    if (scenario == 1) {
      _drawS1(canvas);
    } else if (scenario == 2) {
      _drawS2(canvas);
    } else if (scenario == 3) {
      _drawS3(canvas);
    } else if (scenario == 4) {
      _drawS4(canvas);
    } else if (scenario == 5) {
      _drawS5(canvas);
    }
  }

  void _drawRoundedRect(
    Canvas canvas,
    Rect rect,
    double radius,
    Color color, {
    bool stroke = false,
    Color strokeColor = Colors.black,
    double strokeWidth = 2,
  }) {
    RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    if (!stroke) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    } else {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    Color color, {
    bool bold = true,
  }) {
    TextSpan span = TextSpan(
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
      text: text,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  // --- Scenarios Renderers ---
  void _drawS1(Canvas canvas) {
    // Blackboard
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-225, -250, 450, 100),
      8,
      const Color(0xFF064E3B),
    );
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-225, -250, 450, 100),
      8,
      Colors.white,
      stroke: true,
      strokeWidth: 4,
    );
    _drawText(
      canvas,
      t('lbl_s1_target'),
      const Offset(0, -200),
      22,
      Colors.white,
    );

    // Holding Area
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-400, 50, 150, 250),
      10,
      Colors.black12,
    );
    _drawText(
      canvas,
      t('lbl_s1_holding'),
      const Offset(-325, 30),
      16,
      Colors.white,
    );

    // Slots
    for (int i = 0; i < 5; i++) {
      double sx = -160 + i * 80.0;
      double sy = 250.0;
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(sx - 35, sy - 15, 70, 30),
        15,
        Colors.white24,
      );
    }

    // Students
    List<Student> drawOrder = List.from(s1Students);
    if (dragEnt != null && dragEnt!.startsWith('stu_')) {
      int id = int.parse(dragEnt!.split('_')[1]);
      Student dragged = drawOrder.firstWhere((s) => s.id == id);
      drawOrder.remove(dragged);
      drawOrder.add(dragged); // draw last
    }

    for (var s in drawOrder) {
      double x = s.x, y = s.y;
      int? bubbleVal;

      if (dragEnt != null && dragEnt == 'stu_${s.id}') {
        x = dragX;
        y = dragY;
      } else {
        if (s.slot != null) {
          x = -160 + s.slot! * 80.0;
          y = 250;
          int n = 0;
          if (s.slot! > 0) {
            var left = s1Students.firstWhere(
              (x) => x.slot == s.slot! - 1,
              orElse: () => Student(-1, 0, Colors.transparent),
            );
            if (left.h > s.h) n++;
          }
          if (s.slot! < 4) {
            var right = s1Students.firstWhere(
              (x) => x.slot == s.slot! + 1,
              orElse: () => Student(-1, 0, Colors.transparent),
            );
            if (right.h > s.h) n++;
          }
          bubbleVal = n;
        } else {
          x = -370 + (s.id % 2) * 60.0;
          y = 140 + (s.id ~/ 2) * 70.0;
        }
        s.x = x;
        s.y = y;
      }

      // Draw Body
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(x - 20, y - s.h, 40, s.h),
        10,
        s.c,
      );
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(x - 20, y - s.h, 40, s.h),
        10,
        Colors.black,
        stroke: true,
      );
      // Head
      canvas.drawCircle(
        Offset(x, y - s.h - 25),
        20,
        Paint()..color = Colors.pink[200]!,
      );
      canvas.drawCircle(
        Offset(x, y - s.h - 25),
        20,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      // Bubble
      if (bubbleVal != null) {
        _drawRoundedRect(
          canvas,
          Rect.fromLTWH(x - 25, y - s.h - 85, 50, 35),
          8,
          Colors.white,
        );
        canvas.drawLine(
          Offset(x, y - s.h - 50),
          Offset(x - 10, y - s.h - 45),
          Paint()
            ..color = Colors.black
            ..strokeWidth = 3,
        );
        _drawText(
          canvas,
          '$bubbleVal',
          Offset(x, y - s.h - 67.5),
          20,
          Colors.black,
        );
      }
    }
  }

  void _drawS2(Canvas canvas) {
    // Budget Bar
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-200, -250, 400, 40),
      20,
      Colors.white,
    );
    double fillPct = (s2Spent / 100).clamp(0.0, 1.0);
    Color fillColor = s2GhostRed
        ? Colors.red
        : (fillPct > 0.8 ? Colors.yellow : Colors.green);
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(-200, -250, fillPct * 400, 40),
      20,
      fillColor,
    );
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-200, -250, 400, 40),
      20,
      Colors.black,
      stroke: true,
      strokeWidth: 3,
    );
    _drawText(
      canvas,
      '${t('lbl_s2_budget')} ₹${s2Spent.toInt()} / ₹100',
      const Offset(0, -230),
      18,
      Colors.black,
    );

    // Shelf
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-300, -100, 200, 300),
      10,
      Colors.brown[400]!,
    );
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-300, 0, 200, 15),
      0,
      Colors.brown[800]!,
    );
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-300, 150, 200, 15),
      0,
      Colors.brown[800]!,
    );

    for (int i = 0; i < s2Items.length; i++) {
      var item = s2Items[i];
      double ix = -250 + (i % 2) * 100.0;
      double iy = -30 + (i ~/ 2) * 150.0;
      _drawStoreItem(canvas, item.id, Offset(ix, iy), 1.5);
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(ix - 30, iy + 30, 60, 20),
        4,
        Colors.white,
      );
      _drawText(
        canvas,
        '₹${item.p.toInt()}',
        Offset(ix, iy + 40),
        14,
        Colors.black,
      );
      _drawText(
        canvas,
        t('lbl_s2_items.${item.id}').split(' ')[0],
        Offset(ix, iy - 45),
        14,
        Colors.white,
      );
    }

    // Cart
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(100, -100, 250, 300),
      10,
      Colors.white10,
    );
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(100, -100, 250, 300),
      10,
      Colors.black,
      stroke: true,
      strokeWidth: 3,
    );
    _drawText(
      canvas,
      '${t('lbl_s2_cart')} ₹${s2Spent.toInt()}',
      const Offset(225, -70),
      20,
      Colors.white,
    );

    for (int i = 0; i < s2Cart.length; i++) {
      double cx = 140 + (i % 3) * 80.0;
      double cy = -10 + (i ~/ 3) * 80.0;
      _drawStoreItem(canvas, s2Cart[i].id, Offset(cx, cy), 1.2);
    }

    if (dragEnt != null && dragEnt!.startsWith('item_')) {
      _drawStoreItem(canvas, dragEnt!.split('_')[1], Offset(dragX, dragY), 1.5);
    }

    if (step >= 3) {
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(125, 230, 200, 50),
        25,
        Colors.blue,
      );
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(125, 230, 200, 50),
        25,
        Colors.black,
        stroke: true,
      );
      _drawText(
        canvas,
        t('lbl_s2_checkout'),
        const Offset(225, 255),
        18,
        Colors.white,
      );
    }
  }

  void _drawS3(Canvas canvas) {
    // Map Outline (Stylized India)
    Path p = Path()
      ..moveTo(-250, 150) // Gujarat
      ..lineTo(-180, 50) // Rajasthan
      ..lineTo(-100, -100) // Punjab
      ..lineTo(-50, -250) // Kashmir
      ..lineTo(0, -150) // Himachal
      ..lineTo(80, -100) // Nepal border
      ..lineTo(150, -120) // Sikkim
      ..lineTo(250, -150) // Arunachal
      ..lineTo(280, -100) // Nagaland
      ..lineTo(220, -20) // Mizoram
      ..lineTo(120, 0) // Bengal
      ..lineTo(80, 100) // Odisha
      ..lineTo(0, 200) // Andhra
      ..lineTo(-50, 350) // South
      ..lineTo(-120, 220) // Karnataka
      ..lineTo(-180, 180) // Maharashtra
      ..close();

    // Shadow
    canvas.drawPath(
      p.shift(const Offset(5, 5)),
      Paint()..color = Colors.black26,
    );
    // Fill
    canvas.drawPath(
      p,
      Paint()..color = const Color(0xFFE6E2D3),
    ); // Sand/Map color
    // Border
    canvas.drawPath(
      p,
      Paint()
        ..color =
            const Color(0xFF8C7B65) // Darker border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Compass
    _drawText(canvas, 'N', const Offset(-250, -150), 16, Colors.white);
    canvas.drawLine(
      const Offset(-250, -140),
      const Offset(-250, -110),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      const Offset(-255, -120),
      const Offset(-245, -120),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );

    // Path
    Paint dashPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw Dashed Line (simplified dash effect using short lines)
    for (int i = 0; i < s3Nodes.length - 1; i++) {
      Offset p1 = s3Nodes[i];
      Offset p2 = s3Nodes[i + 1];
      double dist = (p2 - p1).distance;
      int dashes = (dist / 15).floor();
      for (int j = 0; j < dashes; j++) {
        if (j % 2 == 0) {
          Offset start = p1 + (p2 - p1) * (j / dashes);
          Offset end = p1 + (p2 - p1) * ((j + 1) / dashes);
          canvas.drawLine(start, end, dashPaint);
        }
      }
    }

    // Waypoints
    for (var node in s3Nodes) {
      canvas.drawCircle(node, 6, Paint()..color = Colors.white);
      canvas.drawCircle(node, 4, Paint()..color = Colors.redAccent);
    }

    // Pin Function
    void drawPin(Offset pt, Color col, String label) {
      Path pin = Path()
        ..moveTo(pt.dx, pt.dy)
        ..quadraticBezierTo(pt.dx - 15, pt.dy - 20, pt.dx - 15, pt.dy - 35)
        ..arcToPoint(
          Offset(pt.dx + 15, pt.dy - 35),
          radius: const Radius.circular(15),
        )
        ..quadraticBezierTo(pt.dx + 15, pt.dy - 20, pt.dx, pt.dy)
        ..close();
      canvas.drawPath(
        pin.shift(const Offset(3, 3)),
        Paint()..color = Colors.black26,
      );
      canvas.drawPath(pin, Paint()..color = col);
      canvas.drawCircle(
        Offset(pt.dx, pt.dy - 35),
        6,
        Paint()..color = Colors.white,
      );

      // Label with background
      Paint bgPaint = Paint()..color = Colors.black.withOpacity(0.6);
      canvas.drawRRect(
        RRect.fromLTRBR(
          pt.dx - 55,
          pt.dy - 65,
          pt.dx + 55,
          pt.dy - 40,
          const Radius.circular(8),
        ),
        bgPaint,
      );
      _drawText(canvas, label, Offset(pt.dx, pt.dy - 52), 14, Colors.white);
    }

    drawPin(s3Nodes[0], Colors.red, "Gandhinagar");
    drawPin(s3Nodes[4], Colors.blue, "Kohima");

    // Legend
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-350, 100, 180, 80),
      12,
      Colors.white.withOpacity(0.9),
    );
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-350, 100, 180, 80),
      12,
      Colors.black12,
      stroke: true,
    );
    _drawIcon(canvas, const Offset(-320, 140), 1.5);
    _drawText(
      canvas,
      t('lbl_s3_legend'),
      const Offset(-240, 140),
      16,
      Colors.black87,
    );

    // Est Days
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(150, 150, 200, 60),
      12,
      Colors.white.withOpacity(0.9),
    );
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(150, 150, 200, 60),
      12,
      Colors.black12,
      stroke: true,
    );
    _drawText(
      canvas,
      '${t('lbl_s3_est')} ${s3Icons.length * 3}',
      const Offset(250, 180),
      18,
      Colors.black87,
    );

    for (var ic in s3Icons) {
      _drawIcon(canvas, ic, 1.2);
    }

    if (dragEnt == 'icon') _drawIcon(canvas, Offset(dragX, dragY), 1.5);

    if (step >= 2 && s3Icons.length >= 2) {
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(150, 230, 200, 50),
        25,
        Colors.blue,
      );
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(150, 230, 200, 50),
        25,
        Colors.black26,
        stroke: true,
      );
      _drawText(
        canvas,
        t('lbl_s3_check'),
        const Offset(250, 255),
        16,
        Colors.white,
      );
    }
  }

  void _drawS4(Canvas canvas) {
    // Budget
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-150, -280, 300, 40),
      20,
      Colors.white,
    );
    _drawText(
      canvas,
      '${t('lbl_s4_budget')} ₹${500 - s4Spent.toInt()} / ₹500',
      const Offset(0, -260),
      18,
      Colors.black,
    );

    // Store
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-350, -150, 200, 350),
      10,
      Colors.blueGrey[200]!,
    );
    for (int i = 0; i < s4Store.length; i++) {
      double iy = -100 + i * 80.0;
      _drawStoreItem(canvas, s4Store[i].id, Offset(-250, iy), 1.2);
      _drawText(
        canvas,
        t('lbl_s4_store.${s4Store[i].id}'),
        Offset(-250, iy + 30),
        12,
        Colors.black,
      );
    }

    // Stall
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-50, -150, 350, 250),
      10,
      Colors.green[100]!,
    );
    if (s4Stall.any((i) => i.id == 'table')) {
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(50, -20, 150, 60),
        4,
        Colors.brown,
      );
    }
    for (int i = 0; i < s4Stall.length; i++) {
      if (s4Stall[i].id != 'table') {
        double cx = 0 + (i % 4) * 50.0;
        double cy = -50 + (i ~/ 4) * 50.0;
        _drawStoreItem(canvas, s4Stall[i].id, Offset(cx, cy), 1.0);
      }
    }

    // Slider
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-60, 110, 220, 70),
      8,
      Colors.white,
    );
    _drawText(
      canvas,
      '${t('lbl_s4_price')} ${s4Price.toInt()}',
      const Offset(50, 130),
      14,
      Colors.black,
    );
    canvas.drawLine(
      const Offset(-50, 155),
      const Offset(150, 155),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 4,
    );
    double hX = -50 + ((s4Price - 10) / 10) * 200;
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(hX - 10, 145, 20, 20),
      10,
      Colors.blue,
    );

    // Open Button
    bool canOpen =
        s4Stall.any((i) => i.id == 'table') &&
        s4Stall.any((i) => i.id == 'rings') &&
        s4Stall.any((i) => i.id.startsWith('prize'));
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(180, 130, 120, 50),
      25,
      canOpen ? Colors.green : Colors.grey,
    );
    _drawText(
      canvas,
      t('lbl_s4_open'),
      const Offset(240, 155),
      14,
      Colors.white,
    );

    if (dragEnt != null && dragEnt!.startsWith('store_')) {
      _drawStoreItem(canvas, dragEnt!.split('_')[1], Offset(dragX, dragY), 1.5);
    }

    // Sim
    if (s4SimActive || step >= 3) {
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(50, -250, 200, 50),
        10,
        Colors.yellow[200]!,
      );
      _drawText(
        canvas,
        '${t('lbl_s4_profit')} ₹${s4Profit.toInt()}',
        const Offset(150, -225),
        20,
        Colors.black,
      );
    }
    if (s4SimActive) {
      for (var c in s4Customers) {
        canvas.drawCircle(Offset(c.x, 220), 15, Paint()..color = Colors.indigo);
      }
    }
  }

  void _drawS5(Canvas canvas) {
    double gSize = 30;
    double gx = -150;
    double gy = -150;
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-150, -150, 300, 300),
      0,
      Colors.green[100]!,
    );
    Paint gridPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;
    for (int i = 1; i < 10; i++) {
      canvas.drawLine(
        Offset(gx + i * gSize, gy),
        Offset(gx + i * gSize, gy + 300),
        gridPaint,
      );
      canvas.drawLine(
        Offset(gx, gy + i * gSize),
        Offset(gx + 300, gy + i * gSize),
        gridPaint,
      );
    }

    for (var item in s5ItemsPlaced) {
      var conf = s5Catalog[item.id]!;
      double ix = gx + item.c * gSize;
      double iy = gy + item.r * gSize;
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(ix, iy, conf.w * gSize, conf.h * gSize),
        4,
        conf.c,
      );
      _drawText(
        canvas,
        t('lbl_s5_items.${item.id}').split(' ')[0],
        Offset(ix + conf.w * gSize / 2, iy + conf.h * gSize / 2),
        12,
        Colors.white,
      );
    }

    // Progress
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-150, -220, 300, 30),
      15,
      Colors.white,
    );
    _drawRoundedRect(
      canvas,
      Rect.fromLTWH(-150, -220, (s5SpaceUsed / 100) * 300, 30),
      15,
      Colors.blue,
    );
    _drawText(
      canvas,
      '${t('lbl_s5_space')} $s5SpaceUsed/100',
      const Offset(0, -205),
      14,
      Colors.black,
    );

    // Catalog
    _drawRoundedRect(
      canvas,
      const Rect.fromLTWH(-380, -150, 180, 300),
      10,
      Colors.white,
    );
    int ci = 0;
    s5Catalog.forEach((k, v) {
      double cy = -110 + ci * 50.0;
      _drawRoundedRect(canvas, Rect.fromLTWH(-360, cy - 15, 30, 30), 4, v.c);
      _drawText(
        canvas,
        t('lbl_s5_items.$k'),
        Offset(-270, cy),
        14,
        Colors.black,
      );
      ci++;
    });

    if (dragEnt != null && dragEnt!.startsWith('cat_')) {
      var conf = s5Catalog[dragEnt!.split('_')[1]]!;
      int col = ((dragX - gx) / gSize).floor();
      int row = ((dragY - gy) / gSize).floor();
      bool valid =
          col >= 0 && col + conf.w <= 10 && row >= 0 && row + conf.h <= 10;
      if (valid) {
        for (int r = row; r < row + conf.h; r++) {
          for (int c = col; c < col + conf.w; c++) {
            if (s5Grid[r][c] == 1) valid = false;
          }
        }
        canvas.drawRect(
          Rect.fromLTWH(
            gx + col * gSize,
            gy + row * gSize,
            conf.w * gSize,
            conf.h * gSize,
          ),
          Paint()..color = (valid ? Colors.green : Colors.red).withOpacity(0.5),
        );
      }
      _drawRoundedRect(
        canvas,
        Rect.fromLTWH(dragX, dragY, conf.w * gSize, conf.h * gSize),
        4,
        conf.c,
      );
    }

    if (s5SpaceUsed > 80 && step >= 2) {
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(200, 0, 150, 50),
        25,
        Colors.green,
      );
      _drawText(
        canvas,
        t('lbl_s5_finalize'),
        const Offset(275, 25),
        16,
        Colors.white,
      );
    }
  }

  void _drawStoreItem(Canvas canvas, String id, Offset pos, double size) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(size);
    if (id == 'milk') {
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(-15, -25, 30, 50),
        4,
        Colors.white,
        stroke: true,
      );
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(-15, -25, 30, 50),
        4,
        Colors.white,
      );
      canvas.drawRect(
        const Rect.fromLTWH(-15, -5, 30, 20),
        Paint()..color = Colors.blue,
      );
    } else if (id == 'banana') {
      canvas.translate(-5, -5);
      Path banana1 = Path()
        ..moveTo(-10, 20)
        ..quadraticBezierTo(0, 25, 20, 10)
        ..quadraticBezierTo(25, -5, 20, -15)
        ..quadraticBezierTo(15, -5, 10, 10)
        ..quadraticBezierTo(-5, 15, -10, 20)
        ..close();
      Path banana2 = banana1.shift(const Offset(-8, 5));
      Path banana3 = banana1.shift(const Offset(-15, 10));

      Paint bp = Paint()..color = Colors.yellowAccent;
      Paint bpOutline = Paint()
        ..color = Colors.orangeAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawPath(banana3, bp);
      canvas.drawPath(banana3, bpOutline);
      canvas.drawPath(banana2, bp);
      canvas.drawPath(banana2, bpOutline);
      canvas.drawPath(banana1, bp);
      canvas.drawPath(banana1, bpOutline);

      // Stem
      canvas.drawLine(
        const Offset(20, -15),
        const Offset(25, -20),
        Paint()
          ..color = Colors.brown
          ..strokeWidth = 3,
      );
    } else if (id == 'apple') {
      // Body
      canvas.drawCircle(const Offset(-2, 0), 18, Paint()..color = Colors.red);
      canvas.drawCircle(
        const Offset(2, 0),
        18,
        Paint()..color = Colors.redAccent,
      );
      // Highlight
      canvas.drawCircle(
        const Offset(-6, -6),
        5,
        Paint()..color = Colors.white.withOpacity(0.4),
      );
      // Stem
      canvas.drawLine(
        const Offset(0, -15),
        const Offset(4, -25),
        Paint()
          ..color = Colors.brown
          ..strokeWidth = 3,
      );
      // Leaf
      Path leaf = Path()
        ..moveTo(4, -22)
        ..quadraticBezierTo(15, -25, 20, -15)
        ..quadraticBezierTo(10, -10, 4, -22);
      canvas.drawPath(leaf, Paint()..color = Colors.green);
    } else if (id == 'grape') {
      canvas.translate(0, -15);
      Paint gp = Paint()..color = Colors.purple;
      Paint gpLight = Paint()..color = Colors.purpleAccent;
      // Stem
      canvas.drawLine(
        const Offset(0, -5),
        const Offset(0, -15),
        Paint()
          ..color = Colors.brown
          ..strokeWidth = 2,
      );
      // Leaf
      Path leaf = Path()
        ..moveTo(0, -10)
        ..quadraticBezierTo(10, -20, 15, -5)
        ..quadraticBezierTo(5, 0, 0, -10);
      canvas.drawPath(leaf, Paint()..color = Colors.green);

      // Grapes (drawn top to bottom)
      List<Offset> grapes = [
        const Offset(-8, 0),
        const Offset(8, 0),
        const Offset(0, 0),
        const Offset(-12, 10),
        const Offset(12, 10),
        const Offset(-4, 10),
        const Offset(4, 10),
        const Offset(-8, 20),
        const Offset(8, 20),
        const Offset(0, 20),
        const Offset(-4, 30),
        const Offset(4, 30),
        const Offset(0, 40),
      ];
      for (var g in grapes) {
        canvas.drawCircle(
          Offset(g.dx, g.dy + 1),
          7,
          Paint()..color = Colors.black26,
        ); // Shadow
        canvas.drawCircle(g, 7, gp);
        canvas.drawCircle(g, 5, gpLight); // Inner highlight
      }
    } else if (id == 'table') {
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(-30, -10, 60, 20),
        2,
        Colors.brown,
      );
      canvas.drawLine(
        const Offset(-20, 10),
        const Offset(-20, 30),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 5,
      );
      canvas.drawLine(
        const Offset(20, 10),
        const Offset(20, 30),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 5,
      );
    } else if (id == 'rings') {
      canvas.drawOval(
        const Rect.fromLTWH(-20, -10, 40, 20),
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    } else if (id == 'prizeS') {
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(-15, -15, 30, 30),
        4,
        Colors.purple,
      );
    } else if (id == 'prizeL') {
      _drawRoundedRect(
        canvas,
        const Rect.fromLTWH(-25, -25, 50, 50),
        8,
        Colors.orange,
      );
      canvas.drawCircle(Offset.zero, 15, Paint()..color = Colors.white);
    }
    canvas.restore();
  }

  void _drawIcon(Canvas canvas, Offset pos, double scale) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);
    Paint p = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.fill;

    // Head
    canvas.drawCircle(const Offset(0, -12), 4.5, p);

    p.style = PaintingStyle.stroke;
    // Body
    canvas.drawLine(const Offset(0, -7), const Offset(0, 5), p);
    // Arms (swinging)
    canvas.drawLine(const Offset(0, -4), const Offset(-6, 2), p);
    canvas.drawLine(const Offset(0, -4), const Offset(6, 2), p);
    // Legs (walking)
    canvas.drawLine(const Offset(0, 5), const Offset(-5, 16), p);
    canvas.drawLine(const Offset(0, 5), const Offset(5, 16), p);

    // Backpack
    Paint bp = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromLTRBR(-8, -6, -2, 2, const Radius.circular(2)),
      bp,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LabPainter oldDelegate) => true;
}
