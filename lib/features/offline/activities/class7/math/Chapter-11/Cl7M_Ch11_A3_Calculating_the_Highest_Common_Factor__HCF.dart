// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class CalculatingtheHCF extends StatefulWidget {
  const CalculatingtheHCF({Key? key}) : super(key: key);

  @override
  _CalculatingtheHCFState createState() => _CalculatingtheHCFState();
}

class _CalculatingtheHCFState extends State<CalculatingtheHCF> with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  String _currentLang = 'en';
  final List<String> _langs = ['en', 'hi'];
  int _scenario = 1;
  int _step = 0;
  
  double _hudTop = 24.0;
  double _hudRight = 24.0;
  bool _showCurtain = true;
  bool _showSuccessPopup = false;
  String _hudMessage = "";
  
  Set<int> _completedScenarios = {};

  // Floating Positions for Step Panel & Popup
  double _floatingStepX = 16.0;
  double _floatingStepY = 80.0;
  double _successDx = 0.0;
  double _successDy = 0.0;

  // Zoom and Pan State
  double _zoom = 1.0;
  double _panX = 0.0;
  double _panY = 0.0;
  double _baseZoom = 1.0;
  bool _isDraggingObject = false;

  // Audio Engine setup (Network Sources)
  static final AudioPlayer _clickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static const String _clickUrl = 'audio/class7/mixkit_2568.mp3';
  static const String _successUrl = 'audio/class7/mixkit_2018.mp3';
  static const String _errorUrl = 'audio/class7/mixkit_955.mp3';
  static const String _alertUrl = 'audio/class7/mixkit_2869.mp3';
  static const String _shutterUrl = 'audio/class7/mixkit_2574.mp3';

  void _playSound(String type) async {
    try {
      switch (type) {
        case 'tick':
        case 'snap':
          await _clickPlayer.play(AssetSource(_clickUrl));
          break;
        case 'success':
          await _successPlayer.play(AssetSource(_successUrl));
          break;
        case 'error':
          await _errorPlayer.play(AssetSource(_errorUrl));
          break;
        case 'pop':
        case 'weld':
          await _fxPlayer.play(AssetSource(_alertUrl));
          break;
        case 'shutter':
          await _fxPlayer.play(AssetSource(_shutterUrl));
          break;
      }
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _updateHud() {
    int totalSteps = _getTotalSteps(_scenario);
    if (_step < totalSteps) {
      _hudMessage = t('s${_scenario}_hud${_step + 1}');
    } else {
      _hudMessage = t('scenarioCompleteMsg');
    }
  }

  void _showTemporaryHud(String text) {
    setState(() {
      _hudMessage = text;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _updateHud();
        });
      }
    });
  }

  int _getTotalSteps(int scenarioId) {
    switch (scenarioId) {
      case 1: return 4;
      case 2: return 5;
      case 3: return 4;
      case 4: return 3;
      case 5: return 3;
      default: return 0;
    }
  }

  void _advanceStep() {
    setState(() {
      _step++;
      _updateHud();
      if (_step == _getTotalSteps(_scenario)) {
        _playSound('success');
        _completedScenarios.add(_scenario);
        if (_completedScenarios.length == 5) {
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _showSuccessPopup = true;
            });
            _playSound('success');
          });
        }
      }
    });
  }

  // Common Simulation Data
  List<int> _commonList = [];
  List<int> _testedTiles = [];

  // Scenario 1 State
  final int _s1RoomW = 16;
  final int _s1RoomH = 12;
  int? _s1ActiveTile;
  int? _s1DroppedTile;
  double _dragX = 0;
  double _dragY = 0;

  // Scenario 2 State
  final List<int> _s2BagSizes = [4, 6, 7, 12];
  int? _s2ActiveBag;
  Map<String, dynamic> _s2P1 = {'target': 84, 'bag': null, 'success': false, 'count': 0, 'leftover': 0};
  Map<String, dynamic> _s2P2 = {'target': 108, 'bag': null, 'success': false, 'count': 0, 'leftover': 0};

  // Scenario 3 State
  final List<int> _s3M1 = [2, 2, 2, 2, 7];
  final List<int> _s3M2 = [2, 2, 3, 7];
  List<Map<String, dynamic>> _s3M1Spawns = [];
  List<Map<String, dynamic>> _s3M2Spawns = [];
  List<Map<String, dynamic>> _s3CenterSpawns = [];
  Map<String, dynamic>? _s3DragBlock;
  bool _s3Calculated = false;

  // Scenario 4 State
  int _s4CutLen = 1;
  bool _s4IsCut = false;
  List<int> _s4Cuts1 = [];
  List<int> _s4Cuts2 = [];
  int _s4Leftover = 0;
  List<Map<String, dynamic>> _s4History = [];
  final TextEditingController _s4AnswerCtrl = TextEditingController();

  // Scenario 5 State
  int _s5JumpSize = 1;
  int _s5FrogPos = 0;
  List<int> _s5Path = [];
  List<int> _s5History = [];
  bool _s5Hit1 = false;
  bool _s5Hit2 = false;

  late AnimationController _renderController;
  int _timeTicks = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _renderController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _renderController.addListener(() {
      setState(() {
        _timeTicks += 16;
      });
    });
  }

  @override
  void dispose() {
    _renderController.dispose();
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _s4AnswerCtrl.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _enterLab() {
    _playSound('shutter');
    setState(() {
      _showCurtain = false;
      _loadScenario(1);
    });
  }

  void _loadScenario(int id) {
    setState(() {
      _scenario = id;
      _step = 0;
      _commonList = [];
      _testedTiles = [];
      _zoom = 1.0;
      _panX = 0;
      _panY = 0;

      // Reset Scenarios
      _s1ActiveTile = null;
      _s1DroppedTile = null;

      _s2ActiveBag = null;
      _s2P1 = {'target': 84, 'bag': null, 'success': false, 'count': 0, 'leftover': 0};
      _s2P2 = {'target': 108, 'bag': null, 'success': false, 'count': 0, 'leftover': 0};

      _s3M1Spawns = [];
      _s3M2Spawns = [];
      _s3CenterSpawns = [];
      _s3DragBlock = null;
      _s3Calculated = false;

      _s4CutLen = 1;
      _s4IsCut = false;
      _s4Cuts1 = [];
      _s4Cuts2 = [];
      _s4Leftover = 0;
      _s4History = [];
      _s4AnswerCtrl.clear();

      _s5JumpSize = 1;
      _s5FrogPos = 0;
      _s5Path = [];
      _s5History = [];
      _s5Hit1 = false;
      _s5Hit2 = false;

      _updateHud();
    });
  }

  void _handleReset() {
    _playSound('error');
    setState(() {
      _showCurtain = true;
      _currentLang = 'en';
      _completedScenarios.clear();
      _showSuccessPopup = false;
      _successDx = 0.0;
      _successDy = 0.0;
    });
  }

  String t(String key) {
    return Translations.data[_currentLang]?[key] ?? Translations.data['en']?[key] ?? key;
  }

  void _s4Cut() {
    setState(() {
      _s4IsCut = true;
      _s4Cuts1 = List.filled(30 ~/ _s4CutLen, _s4CutLen);
      _s4Cuts2 = List.filled(72 ~/ _s4CutLen, _s4CutLen);
      _s4Leftover = 72 % _s4CutLen;
      _playSound('weld');

      bool ok = _s4Leftover == 0;
      if (!_s4History.any((h) => h['len'] == _s4CutLen)) {
        _s4History.insert(0, {'len': _s4CutLen, 'ok': ok});
        if (_s4History.length > 6) _s4History.removeLast();
      }

      if (_step == 0 && _s4CutLen == 5) {
        Future.delayed(const Duration(seconds: 1), _advanceStep);
      }
    });
  }

  void _s4SubmitFinal() {
    int val = int.tryParse(_s4AnswerCtrl.text) ?? 0;
    if (val == 6) {
      setState(() {
        _s4CutLen = 6;
      });
      _s4Cut();
      if (_step == 2) _advanceStep();
    } else if (val == 1 || val == 2 || val == 3) {
      _playSound('error');
      _showTemporaryHud(t('hintLarger'));
    } else {
      _playSound('error');
      setState(() {
        _s4CutLen = max(1, min(15, val));
      });
      _s4Cut();
      _showTemporaryHud(t('hintIncorrectS4'));
    }
  }

  void _s5Jump({bool isFinalCheck = false}) async {
    setState(() {
      _s5Path = [0];
      _s5FrogPos = 0;
      _s5Hit1 = false;
      _s5Hit2 = false;
    });

    void hop() {
      if (!mounted) return;
      if (_s5FrogPos >= 50 || (_s5FrogPos + _s5JumpSize > 50)) {
        setState(() {
          if (_s5Hit1 && _s5Hit2 && !_s5History.contains(_s5JumpSize)) {
            _s5History.add(_s5JumpSize);
            _s5History.sort();
          }
          if (_step == 0 && _s5JumpSize == 4) {
            _advanceStep();
          } else if (_step == 1 && [1, 2, 7, 14].contains(_s5JumpSize) && _s5Hit1 && _s5Hit2) {
            Future.delayed(const Duration(milliseconds: 1500), _advanceStep);
          } else if (isFinalCheck && (_s5JumpSize == 7 || _s5JumpSize == 14)) {
            if (_step == 2) _advanceStep();
          }
        });
        return;
      }
      setState(() {
        _s5FrogPos += _s5JumpSize;
        _s5Path.add(_s5FrogPos);
        if (_s5FrogPos == 28) {
          _s5Hit1 = true;
          _playSound('success');
        } else if (_s5FrogPos == 42) {
          _s5Hit2 = true;
          _playSound('success');
        } else {
          _playSound('snap');
        }
      });
      Future.delayed(const Duration(milliseconds: 300), hop);
    }
    hop();
  }

  void _s5SubmitFinal() {
    if (_s5JumpSize == 7 || _s5JumpSize == 14) {
      _s5Jump(isFinalCheck: true);
    } else if (_s5JumpSize == 1 || _s5JumpSize == 2) {
      _playSound('error');
      _showTemporaryHud(t('hintLongerJump'));
    } else {
      _playSound('error');
      _showTemporaryHud(t('hintIncorrectS5'));
    }
  }

  Offset _getCanvasCoord(Offset localPos, Size size) {
    return Offset(
      (localPos.dx - size.width / 2 - _panX) / _zoom,
      (localPos.dy - size.height / 2 - _panY) / _zoom,
    );
  }

  bool _hitTestBox(double x, double y, double w, double h, Offset pt) {
    return pt.dx > x && pt.dx < x + w && pt.dy > y && pt.dy < y + h;
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    Offset pt = _getCanvasCoord(details.localFocalPoint, size);
    _baseZoom = _zoom;
    _isDraggingObject = false;

    if (_scenario == 1) {
      List<int> tiles = [1, 2, 3, 4, 5, 6];
      for (int i = 0; i < tiles.length; i++) {
        double cx = 260 + 100 / 2;
        double cy = -180 + 75 + i * 55.0;
        // Expanded hit test for tiles
        if (_hitTestBox(cx - 40, cy - 40, 80, 80, pt)) {
          setState(() {
            _s1ActiveTile = tiles[i];
            _dragX = pt.dx;
            _dragY = pt.dy;
            _isDraggingObject = true;
          });
          _playSound('tick');
          return;
        }
      }
    } else if (_scenario == 2) {
      for (int i = 0; i < _s2BagSizes.length; i++) {
        double bx = -150 + i * 100.0;
        double by = 136;
        // Expanded hit test for bags to ensure easy dragging
        if (_hitTestBox(bx - 50, by - 60, 100, 120, pt)) {
          setState(() {
            _s2ActiveBag = _s2BagSizes[i];
            _dragX = pt.dx;
            _dragY = pt.dy;
            _isDraggingObject = true;
          });
          _playSound('tick');
          return;
        }
      }
    } else if (_scenario == 3) {
      // Significantly expanded hit test boxes for "Activate" buttons
      if (_step == 0 && _hitTestBox(-280, -150, 160, 100, pt)) {
        setState(() {
          _s3M1Spawns = List.generate(_s3M1.length, (i) => {
            'val': _s3M1[i], 'x': -280.0 + i * 40, 'y': -45.0,
            'startX': -280.0 + i * 40, 'startY': -45.0, 'zone': 'm1', 'source': 'm1', 'hidden': false
          });
          _isDraggingObject = true;
        });
        _playSound('pop');
        _advanceStep();
        return;
      }
      if (_step == 1 && _hitTestBox(120, -150, 160, 100, pt)) {
        setState(() {
          _s3M2Spawns = List.generate(_s3M2.length, (i) => {
            'val': _s3M2[i], 'x': 120.0 + i * 40, 'y': -45.0,
            'startX': 120.0 + i * 40, 'startY': -45.0, 'zone': 'm2', 'source': 'm2', 'hidden': false
          });
          _isDraggingObject = true;
        });
        _playSound('pop');
        _advanceStep();
        return;
      }

      List<Map<String, dynamic>> allSpawns = [..._s3M1Spawns, ..._s3M2Spawns, ..._s3CenterSpawns];
      for (var b in allSpawns) {
        // Expanded hit test for draggable blocks
        if (!b['hidden'] && _hitTestBox(b['x'] - 30, b['y'] - 30, 60, 60, pt)) {
          setState(() {
            _s3DragBlock = b;
            _isDraggingObject = true;
          });
          _playSound('tick');
          break;
        }
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    Offset pt = _getCanvasCoord(details.localFocalPoint, size);

    setState(() {
      if (_isDraggingObject) {
        if (_s1ActiveTile != null || _s2ActiveBag != null || _s3DragBlock != null) {
          _dragX = pt.dx;
          _dragY = pt.dy;
          if (_s3DragBlock != null) {
            _s3DragBlock!['x'] = pt.dx;
            _s3DragBlock!['y'] = pt.dy;
          }
        }
      } else {
        // Panning the canvas dynamically
        _panX += details.focalPointDelta.dx;
        _panY += details.focalPointDelta.dy;
        _zoom = (_baseZoom * details.scale).clamp(0.4, 4.0);
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details, Size size) {
    Offset pt = Offset(_dragX, _dragY);
    _isDraggingObject = false;

    setState(() {
      if (_s1ActiveTile != null) {
        double rw = _s1RoomW * 30.0;
        double rh = _s1RoomH * 30.0;
        double rx = -rw / 2 - 50;
        double ry = -rh / 2;

        if (_hitTestBox(rx, ry, rw, rh, pt)) {
          _s1DroppedTile = _s1ActiveTile;
          _playSound('snap');
          
          int tVal = _s1ActiveTile!;
          if (_step == 0 && tVal == 3) {
            _advanceStep();
          } else if (_step == 1 && tVal == 2) {
            if (!_commonList.contains(2)) _commonList.add(2);
            _commonList.sort();
            _advanceStep();
          } else if (_step == 2) {
            if (!_testedTiles.contains(tVal)) _testedTiles.add(tVal);
            if (_s1RoomW % tVal == 0 && _s1RoomH % tVal == 0) {
              if (!_commonList.contains(tVal)) {
                _commonList.add(tVal);
                _commonList.sort();
              }
            }
            if (_commonList.contains(1) && _commonList.contains(4)) {
              _advanceStep();
            }
          }
        } else {
          _playSound('pop');
        }
        _s1ActiveTile = null;
      }

      if (_s2ActiveBag != null) {
        bool onPile1 = _hitTestBox(-250, -40, 140, 100, pt);
        bool onPile2 = _hitTestBox(80, -40, 140, 100, pt);
        int bag = _s2ActiveBag!;

        if (onPile1) {
          _s2P1['bag'] = bag;
          _s2P1['leftover'] = 84 % bag;
          _s2P1['count'] = 84 ~/ bag;
          _s2P1['success'] = _s2P1['leftover'] == 0;
          _playSound('snap');
          if (bag == 7 && _step == 0) _advanceStep();
        } else if (onPile2) {
          _s2P2['bag'] = bag;
          _s2P2['leftover'] = 108 % bag;
          _s2P2['count'] = 108 ~/ bag;
          _s2P2['success'] = _s2P2['leftover'] == 0;
          _playSound('snap');
          if (bag == 7 && _step == 1) _advanceStep();
        } else {
          _playSound('pop');
        }

        if (_step == 2 && _s2P1['bag'] == 6 && _s2P2['bag'] == 6) {
          if (!_commonList.contains(6)) _commonList.add(6);
          _commonList.sort();
          _advanceStep();
        }
        if (_step == 3 && _s2P1['bag'] == 12 && _s2P2['bag'] == 12) {
          if (!_commonList.contains(12)) _commonList.add(12);
          _commonList.sort();
          _advanceStep();
        }
        _s2ActiveBag = null;
      }

      if (_s3DragBlock != null) {
        double distLeft = sqrt(pow(pt.dx - (-70), 2) + pow(pt.dy - 140, 2));
        double distRight = sqrt(pow(pt.dx - (70), 2) + pow(pt.dy - 140, 2));

        bool inCenter = distLeft < 120 && distRight < 120;
        bool inLeftOnly = distLeft < 120 && !inCenter;
        bool inRightOnly = distRight < 120 && !inCenter;

        if (inCenter) {
          String otherZone = _s3DragBlock!['source'] == 'm1' ? 'm2' : 'm1';
          List<Map<String, dynamic>> partnerList = otherZone == 'm1' ? _s3M1Spawns : _s3M2Spawns;
          int pIndex = partnerList.indexWhere((x) => x['val'] == _s3DragBlock!['val'] && x['zone'] != 'center' && !x['hidden']);

          if (pIndex > -1) {
            partnerList[pIndex]['zone'] = 'center';
            partnerList[pIndex]['hidden'] = true;
            _s3DragBlock!['zone'] = 'center';
            _s3CenterSpawns.add(_s3DragBlock!);

            for (int i = 0; i < _s3CenterSpawns.length; i++) {
              _s3CenterSpawns[i]['x'] = 0.0;
              _s3CenterSpawns[i]['y'] = 140.0 - 40 + i * 40;
            }
            _playSound('snap');
            if (_s3CenterSpawns.length == 3 && _step == 2) _advanceStep();
          } else {
            _s3DragBlock!['x'] = _s3DragBlock!['startX'];
            _s3DragBlock!['y'] = _s3DragBlock!['startY'];
            _playSound('error');
          }
        } else if (inLeftOnly && _s3DragBlock!['source'] == 'm1') {
          _s3DragBlock!['x'] = pt.dx;
          _s3DragBlock!['y'] = pt.dy;
          _playSound('snap');
        } else if (inRightOnly && _s3DragBlock!['source'] == 'm2') {
          _s3DragBlock!['x'] = pt.dx;
          _s3DragBlock!['y'] = pt.dy;
          _playSound('snap');
        } else {
          _s3DragBlock!['x'] = _s3DragBlock!['startX'];
          _s3DragBlock!['y'] = _s3DragBlock!['startY'];
          _playSound('pop');
        }
        _s3DragBlock = null;
      }
    });
  }

  Widget _buildSidebar() {
    double sidebarWidth = MediaQuery.of(context).size.width * 0.38; // 38% width
    int totalSteps = _getTotalSteps(_scenario);
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: _isSidebarOpen ? 0 : -sidebarWidth,
      top: 0,
      bottom: 0,
      width: sidebarWidth,
      child: GestureDetector(
       behavior: HitTestBehavior.opaque,
        onPanUpdate: (_) {},
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey[900]?.withOpacity(0.95),
            border: const Border(right: BorderSide(color: Colors.white24, width: 1)),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(5, 0))],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Spacer for Top Buttons
                const SizedBox(height: 70),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('appTitle'),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t('appSubtitle'),
                        style: const TextStyle(color: Colors.indigoAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white24, height: 1),
                
                // Language & Reset Controls Row
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _playSound('tick');
                            setState(() {
                              int nextIdx = (_langs.indexOf(_currentLang) + 1) % _langs.length;
                              _currentLang = _langs[nextIdx];
                              _updateHud();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.indigoAccent),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.language, color: Colors.white, size: 18), // Globe Icon
                                const SizedBox(width: 8),
                                Text(
                                  _currentLang.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _handleReset,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.redAccent),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.refresh, color: Colors.redAccent, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  t('resetBtnUI'),
                                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Controls & Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('selectScenario'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 8),
                      // Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _scenario,
                            isExpanded: true,
                            dropdownColor: Colors.blueGrey[800],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            onChanged: (val) {
                              if (val != null) {
                                _playSound('tick');
                                _loadScenario(val);
                              }
                            },
                            items: [
                              DropdownMenuItem(value: 1, child: Text(t('s1_title'))),
                              DropdownMenuItem(value: 2, child: Text(t('s2_title'))),
                              DropdownMenuItem(value: 3, child: Text(t('s3_title'))),
                              DropdownMenuItem(value: 4, child: Text(t('s4_title'))),
                              DropdownMenuItem(value: 5, child: Text(t('s5_title'))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Objective Panel
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[800]?.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.track_changes, color: Colors.redAccent, size: 20),
                                const SizedBox(width: 8),
                                Text(t('learnLbl'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(t('s${_scenario}_obj'), style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Steps List Text
                      ...List.generate(totalSteps, (i) {
                        bool isCompleted = i < _step;
                        bool isCurrent = i == _step;
                        
                        Color bgColor = isCompleted ? Colors.green.withOpacity(0.1) : (isCurrent ? Colors.indigo.withOpacity(0.1) : Colors.white10);
                        Color borderColor = isCompleted ? Colors.green.withOpacity(0.3) : (isCurrent ? Colors.indigoAccent : Colors.transparent);
                        Color iconColor = isCompleted ? Colors.green : (isCurrent ? Colors.indigoAccent : Colors.white38);
                        
                        String taskTxt = t('s${_scenario}_step${i+1}_task');
                        String outTxt = t('s${_scenario}_step${i+1}_out');

                        return Container(
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
                              Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCompleted ? Colors.transparent : iconColor.withOpacity(0.2),
                                ),
                                child: isCompleted 
                                  ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                                  : Center(child: Text('${i+1}', style: TextStyle(color: iconColor, fontWeight: FontWeight.bold))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "STEP ${i+1}", 
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.2)
                                    ),
                                    const SizedBox(height: 6),
                                    RichText(text: TextSpan(children: [
                                      TextSpan(text: "Action: ", style: TextStyle(fontWeight: FontWeight.bold, color: isCurrent ? Colors.indigoAccent : Colors.white70)),
                                      TextSpan(text: taskTxt, style: const TextStyle(color: Colors.white70)),
                                    ])),
                                    if (isCompleted) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.green.withOpacity(0.2))),
                                        child: RichText(text: TextSpan(children: [
                                          const TextSpan(text: "Observation: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                                          TextSpan(text: outTxt, style: const TextStyle(color: Colors.white70)),
                                        ])),
                                      )
                                    ]
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.white12)),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "© ZeroScienceLab - Fall in love with math and Science",
                    style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingStepPanel() {
    int i = _step;
    if (i >= _getTotalSteps(_scenario) || _showCurtain || _showSuccessPopup || _isSidebarOpen) {
      return const SizedBox.shrink();
    }

    String taskTxt = t('s${_scenario}_step${i+1}_task');

    return Positioned(
      left: _floatingStepX,
      top: _floatingStepY,
      child: GestureDetector(
       behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) {
          setState(() {
            _floatingStepX += d.delta.dx;
            _floatingStepY += d.delta.dy;
          });
        },
        child: Material(
          color: Colors.transparent,
          elevation: 12,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[900]?.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigoAccent, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                 Row(
                   children: [
                     const Icon(Icons.drag_indicator, color: Colors.white54, size: 18),
                     const SizedBox(width: 8),
                     Text("STEP ${i+1}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
                   ]
                 ),
                 const SizedBox(height: 12),
                 Text(taskTxt, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
              ]
            )
          )
        )
      )
    );
  }

  // Common UI logic rendered ON CANVAS stack instead of sidebar
  Widget _buildCanvasTopRightUI() {
    if (_scenario == 1 || _scenario == 2) {
      return Positioned(
        top: _hudTop,
        right: _hudRight,
        child: GestureDetector(
         behavior: HitTestBehavior.opaque,
          onTap: (){},
          onPanUpdate: (d) {
            setState(() {
              _hudTop += d.delta.dy;
              _hudRight -= d.delta.dx;
            });
          },
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[900]?.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.drag_indicator, color: Colors.white54, size: 18),
                    const SizedBox(width: 8),
                    Text(t('commonFactor') + "s", style: const TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.1)),
                  ],
                ),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                if (_commonList.isEmpty)
                  Text(t('s${_scenario}_hud1'), style: const TextStyle(color: Colors.white38, fontStyle: FontStyle.italic, fontSize: 12)),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _commonList.map((c) => _buildCanvasCommonBadge(c)).toList(),
                ),
                const SizedBox(height: 16),
                if (_scenario == 2 && _s2P1['success'] && _s2P2['success'] && _s2P1['bag'] == _s2P2['bag'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text("${t('totalBags')} ${_s2P1['count'] + _s2P2['count']}", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ElevatedButton.icon(
                  onPressed: () {
                    _playSound('pop');
                    setState(() {
                      _s1DroppedTile = null;
                      _s2P1 = {'target': 84, 'bag': null, 'success': false, 'count': 0, 'leftover': 0};
                      _s2P2 = {'target': 108, 'bag': null, 'success': false, 'count': 0, 'leftover': 0};
                    });
                  },
                  icon: const Icon(Icons.cleaning_services, size: 16),
                  label: Text(t('clearSetup'), style: const TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[800],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCanvasCommonBadge(int val) {
    bool isTarget = (_scenario == 1 && _step == 3 && val == 4);
    return InkWell(
      onTap: () {
        if (_scenario == 1 && _step == 3 && val == 4) {
          setState(() { _s1DroppedTile = 4; });
          _advanceStep();
        } else if (_scenario == 2 && _step == 4 && val == 12) {
          setState(() {
            _s2P1 = {'target': 84, 'bag': 12, 'success': true, 'count': 7, 'leftover': 0};
            _s2P2 = {'target': 108, 'bag': 12, 'success': true, 'count': 9, 'leftover': 0};
          });
          _advanceStep();
        } else {
          _playSound('pop');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.indigoAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isTarget ? Colors.amber : Colors.indigoAccent, width: isTarget ? 2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(4)),
              child: Text(val.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(width: 8),
            Text(t('commonFactor'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasBottomUI() {
    Widget? content;

    if (_scenario == 3 && _s3CenterSpawns.length == 3 && !_s3Calculated) {
      content = ElevatedButton(
        onPressed: () {
          setState(() { _s3Calculated = true; });
          _advanceStep();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(t('calculateBtn')),
      );
    } else if (_scenario == 4) {
      content = Container(
        width: 600,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueGrey[900]?.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_step < 2) ...[
              Row(
                children: [
                  Text("${t('setCutLength')} $_s4CutLen cm", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Slider(
                      value: _s4CutLen.toDouble(),
                      min: 1, max: 15, divisions: 14,
                      activeColor: Colors.indigoAccent,
                      onChanged: (val) {
                        setState(() { _s4CutLen = val.toInt(); _s4IsCut = false; });
                        _playSound('tick');
                      },
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _s4Cut,
                    icon: const Icon(Icons.content_cut, size: 16),
                    label: Text(t('cutBtn')),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _playSound('pop');
                      setState(() {
                        _s4IsCut = false; _s4Cuts1 = []; _s4Cuts2 = []; _s4Leftover = 0;
                        if (_step == 1) _advanceStep(); // User clicked Reset to experiment
                      });
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(t('resetBtnUI')),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
            if (_step == 2) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t('finalAnswerLbl'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _s4AnswerCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      decoration: InputDecoration(
                        filled: true, fillColor: Colors.black45, hintText: 'HCF',
                        hintStyle: const TextStyle(color: Colors.white38),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _s4SubmitFinal,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32)),
                    child: Text(t('submitBtn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  )
                ],
              )
            ]
          ],
        ),
      );
    } else if (_scenario == 5) {
      content = Container(
        width: 600,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueGrey[900]?.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text("${t('jumpSizeLbl')} $_s5JumpSize", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Slider(
                    value: _s5JumpSize.toDouble(),
                    min: 1, max: 15, divisions: 14,
                    activeColor: Colors.indigoAccent,
                    onChanged: (val) {
                      setState(() { _s5JumpSize = val.toInt(); });
                      _playSound('tick');
                    },
                  ),
                ),
                if (_step < 2) ...[
                  ElevatedButton.icon(
                    onPressed: _s5Jump,
                    icon: const Icon(Icons.sports_gymnastics, size: 16),
                    label: Text(t('jumpBtn')),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _playSound('pop');
                      setState(() {
                        _s5FrogPos = 0; _s5Path = []; _s5Hit1 = false; _s5Hit2 = false;
                        if (_step == 1) _advanceStep(); // Reset frog to experiment
                      });
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(t('resetBtnUI')),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  ),
                ],
                if (_step == 2) ...[
                  ElevatedButton(
                    onPressed: _s5SubmitFinal,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                    child: Text(t('finalJumpBtn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  )
                ]
              ],
            ),
          ],
        ),
      );
    }

    return Positioned(
      bottom: 80, // Above HUD
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
         behavior: HitTestBehavior.opaque,
          onTap: (){},
          onPanUpdate: (_){},
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: content ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _buildHudOverlay() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: IgnorePointer(
          child: AnimatedOpacity(
            opacity: _hudMessage.isNotEmpty && !_showCurtain && !_showSuccessPopup ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.indigoAccent.withOpacity(0.5), width: 2),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, color: Colors.indigoAccent, size: 24),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      _hudMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessPopup() {
    if (!_showSuccessPopup) return const SizedBox.shrink();
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Transform.translate(
            offset: Offset(_successDx, _successDy),
            child: GestureDetector(
             behavior: HitTestBehavior.opaque,
              onPanUpdate: (d) => setState(() {
                _successDx += d.delta.dx;
                _successDy += d.delta.dy;
              }),
              child: Material(
                color: Colors.transparent,
                elevation: 24,
                child: Container(
                  width: 320, // Compact width
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[900],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.indigoAccent, width: 2),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.greenAccent.withOpacity(0.2),
                                boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 20)]
                              ),
                              child: const Icon(Icons.flag, color: Colors.greenAccent, size: 48) // Compact icon
                            ),
                            const SizedBox(height: 16),
                            Text(t('summaryTitle'), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(t('finalDesc'), style: const TextStyle(color: Colors.greenAccent, fontSize: 14), textAlign: TextAlign.center),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                _playSound('pop');
                                _handleReset();
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: Text(t('finishLab')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                          onPressed: () {
                            _playSound('tick');
                            setState(() => _showSuccessPopup = false);
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurtain() {
    return Visibility(
      visible: _showCurtain,
      child: Container(
        color: const Color(0xFF0F172A),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.indigoAccent.withOpacity(0.1),
                  boxShadow: [BoxShadow(color: Colors.indigoAccent.withOpacity(0.2), blurRadius: 40)],
                ),
                child: const Icon(Icons.science, color: Colors.indigoAccent, size: 80),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  t('appTitle'),
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(t('appSubtitle'), style: const TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2.0), textAlign: TextAlign.center,),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _enterLab,
                icon: const Icon(Icons.play_circle_fill, size: 28),
                label: Text(t('enterLab'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 10,
                  shadowColor: Colors.indigoAccent.withOpacity(0.5),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double sidebarWidth = MediaQuery.of(context).size.width * 0.38;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Canvas Area & Dynamic Overlays (Adjusts width alongside sidebar to stop overlapping)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isSidebarOpen ? sidebarWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                      return GestureDetector(
                       behavior: HitTestBehavior.opaque,
                        onScaleStart: (d) => _handleScaleStart(d, canvasSize),
                        onScaleUpdate: (d) => _handleScaleUpdate(d, canvasSize),
                        onScaleEnd: (d) => _handleScaleEnd(d, canvasSize),
                        child: CustomPaint(
                          painter: HCFLabPainter(
                            scenario: _scenario,
                            zoom: _zoom,
                            panX: _panX,
                            panY: _panY,
                            ticks: _timeTicks,
                            dragX: _dragX,
                            dragY: _dragY,

                            // S1
                            s1RoomW: _s1RoomW, s1RoomH: _s1RoomH,
                            s1ActiveTile: _s1ActiveTile, s1DroppedTile: _s1DroppedTile,

                            // S2
                            s2BagSizes: _s2BagSizes, s2ActiveBag: _s2ActiveBag,
                            s2P1: _s2P1, s2P2: _s2P2,

                            // S3
                            s3M1Spawns: _s3M1Spawns, s3M2Spawns: _s3M2Spawns, s3CenterSpawns: _s3CenterSpawns,
                            s3DragBlock: _s3DragBlock, s3Calculated: _s3Calculated,

                            // S4
                            s4CutLen: _s4CutLen, s4IsCut: _s4IsCut, s4Cuts1: _s4Cuts1, s4Cuts2: _s4Cuts2,
                            s4Leftover: _s4Leftover, s4History: _s4History,

                            // S5
                            s5JumpSize: _s5JumpSize, s5FrogPos: _s5FrogPos, s5Path: _s5Path, s5History: _s5History,
                            s5Hit1: _s5Hit1, s5Hit2: _s5Hit2,
                            
                            lang: _currentLang,
                            t: t,
                          ),
                        ),
                      );
                    },
                  ),

                  // Floating Step Info (only when sidebar closed, bounds within canvas area)
                  _buildFloatingStepPanel(),

                  // Floating Controls on Canvas
                  _buildCanvasTopRightUI(),
                  _buildCanvasBottomUI(),

                  // Mini HUD display
                  _buildHudOverlay(),
                ]
              )
            ),

            // Sidebar
            _buildSidebar(),

            // Menu Icon (Absolute Positioned on Screen Top Left)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _playSound('pop');
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

            // Overlays Conditionally Rendered
            _buildSuccessPopup(),
            _buildCurtain(),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Custom Painter for all 5 Scenarios
// ----------------------------------------------------------------------------
class HCFLabPainter extends CustomPainter {
  final int scenario;
  final double zoom;
  final double panX;
  final double panY;
  final int ticks;
  final double dragX;
  final double dragY;
  
  final int s1RoomW, s1RoomH;
  final int? s1ActiveTile, s1DroppedTile;

  final List<int> s2BagSizes;
  final int? s2ActiveBag;
  final Map<String, dynamic> s2P1, s2P2;

  final List<Map<String, dynamic>> s3M1Spawns, s3M2Spawns, s3CenterSpawns;
  final Map<String, dynamic>? s3DragBlock;
  final bool s3Calculated;

  final int s4CutLen;
  final bool s4IsCut;
  final List<int> s4Cuts1, s4Cuts2;
  final int s4Leftover;
  final List<Map<String, dynamic>> s4History;

  final int s5JumpSize, s5FrogPos;
  final List<int> s5Path, s5History;
  final bool s5Hit1, s5Hit2;

  final String lang;
  final Function(String) t;

  HCFLabPainter({
    required this.scenario, required this.zoom, required this.panX, required this.panY, required this.ticks,
    required this.dragX, required this.dragY,
    required this.s1RoomW, required this.s1RoomH, required this.s1ActiveTile, required this.s1DroppedTile,
    required this.s2BagSizes, required this.s2ActiveBag, required this.s2P1, required this.s2P2,
    required this.s3M1Spawns, required this.s3M2Spawns, required this.s3CenterSpawns, required this.s3DragBlock, required this.s3Calculated,
    required this.s4CutLen, required this.s4IsCut, required this.s4Cuts1, required this.s4Cuts2, required this.s4Leftover, required this.s4History,
    required this.s5JumpSize, required this.s5FrogPos, required this.s5Path, required this.s5History, required this.s5Hit1, required this.s5Hit2,
    required this.lang, required this.t
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + panX, size.height / 2 + panY);
    canvas.scale(zoom);

    if (scenario == 1) _renderS1(canvas);
    else if (scenario == 2) _renderS2(canvas);
    else if (scenario == 3) _renderS3(canvas);
    else if (scenario == 4) _renderS4(canvas);
    else if (scenario == 5) _renderS5(canvas);

    canvas.restore();
  }

  void _drawRoundedRect(Canvas canvas, double x, double y, double w, double h, double r, Color fill, Color stroke, double sw) {
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    if (fill != Colors.transparent) canvas.drawRRect(rect, Paint()..color = fill..style = PaintingStyle.fill);
    if (stroke != Colors.transparent && sw > 0) canvas.drawRRect(rect, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = sw);
  }

  void _drawText(Canvas canvas, String text, double x, double y, double fontSize, Color color, [bool bold = true]) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawLine(Canvas canvas, double x1, double y1, double x2, double y2, Color color, double width) {
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), Paint()..color = color..strokeWidth = width..strokeCap = StrokeCap.round);
  }

  // ---- Scenario 1 Rendering ----
  void _renderS1(Canvas canvas) {
    double scale = 30.0;
    double rw = s1RoomW * scale, rh = s1RoomH * scale;
    double rx = -rw / 2 - 50, ry = -rh / 2;

    _drawRoundedRect(canvas, rx - 12, ry - 12, rw + 24, rh + 24, 4, const Color(0xFF64748b), const Color(0xFF0f172a), 6);
    _drawRoundedRect(canvas, rx, ry, rw, rh, 0, const Color(0xFF1e293b), const Color(0xFF0f172a), 2);

    final gridPaint = Paint()..color = const Color(0xFF334155)..strokeWidth = 2;
    for (int x = 1; x < s1RoomW; x++) canvas.drawLine(Offset(rx + x * scale, ry), Offset(rx + x * scale, ry + rh), gridPaint);
    for (int y = 1; y < s1RoomH; y++) canvas.drawLine(Offset(rx, ry + y * scale), Offset(rx + rw, ry + y * scale), gridPaint);

    _drawText(canvas, "${s1RoomW}ft", rx + rw / 2, ry - 25, 18, Colors.white);
    _drawText(canvas, "${s1RoomH}ft", rx - 35, ry + rh / 2, 18, Colors.white);

    if (s1DroppedTile != null) {
      int tVal = s1DroppedTile!;
      double ts = tVal * scale;
      int cols = s1RoomW ~/ tVal;
      int rows = s1RoomH ~/ tVal;

      for (int c = 0; c < cols; c++) {
        for (int r = 0; r < rows; r++) {
          double tx = rx + c * ts;
          double ty = ry + rh - (r + 1) * ts;
          _drawRoundedRect(canvas, tx, ty, ts, ts, 0, const Color(0xFF2dd4bf), const Color(0xFF0f766e), 2);
          if (tVal == 4) _drawText(canvas, "4", tx + ts / 2, ty + ts / 2, 24, Colors.white);
        }
      }

      int remX = s1RoomW % tVal;
      int remY = s1RoomH % tVal;
      if (remX > 0) {
        double gapX = rx + cols * ts, gapY = ry + rh - rows * ts;
        canvas.drawRect(Rect.fromLTWH(gapX, gapY, remX * scale, rows * ts), Paint()..color = Colors.redAccent.withOpacity(0.8));
        _drawText(canvas, "${remX}ft gap!", gapX + remX * scale / 2 + 30, gapY - 20, 14, Colors.redAccent);
      }
      if (remY > 0) {
        double gapY = ry + rh - rows * ts - remY * scale;
        canvas.drawRect(Rect.fromLTWH(rx, gapY, cols * ts, remY * scale), Paint()..color = Colors.redAccent.withOpacity(0.8));
      }
    }

    // Palette
    double palX = 260, palY = -180, palW = 100, palH = 380;
    _drawRoundedRect(canvas, palX, palY, palW, palH, 12, const Color(0xFF1e293b), const Color(0xFF64748b), 3);
    _drawText(canvas, "Tile Palette", palX + palW / 2, palY + 25, 14, Colors.white);

    List<int> tiles = [1, 2, 3, 4, 5, 6];
    for (int i = 0; i < tiles.length; i++) {
      double cx = palX + palW / 2;
      double cy = palY + 75 + i * 55.0;
      if (s1ActiveTile != tiles[i]) {
        _drawRoundedRect(canvas, cx - 22, cy - 22, 44, 44, 4, const Color(0xFF2dd4bf), const Color(0xFF0f766e), 2);
        _drawText(canvas, "${tiles[i]}ft", cx, cy, 16, const Color(0xFF0f172a));
      } else {
        _drawRoundedRect(canvas, cx - 22, cy - 22, 44, 44, 4, Colors.transparent, const Color(0xFF94a3b8), 2);
      }
    }

    if (s1ActiveTile != null) {
      _drawRoundedRect(canvas, dragX - 25, dragY - 25, 50, 50, 4, const Color(0xFF2dd4bf), const Color(0xFF0f766e), 3);
      _drawText(canvas, "${s1ActiveTile}ft", dragX, dragY, 18, const Color(0xFF0f172a));
    }
  }

  // ---- Scenario 2 Rendering ----
  void _drawRiceBag(Canvas canvas, double x, double y, String text, double scale) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);

    final path = Path();
    path.moveTo(-16, -24);
    path.quadraticBezierTo(-20, 0, -16, 24);
    path.lineTo(16, 24);
    path.quadraticBezierTo(20, 0, 16, -24);
    path.close();

    canvas.drawPath(path, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);

    final detailPath = Path();
    detailPath.moveTo(-16, -24);
    detailPath.quadraticBezierTo(-17, -18, -17, -16);
    detailPath.lineTo(17, -16);
    detailPath.quadraticBezierTo(17, -18, 16, -24);
    detailPath.close();
    canvas.drawPath(detailPath, Paint()..color = Colors.blue..style = PaintingStyle.fill);

    _drawText(canvas, text, 0, 0, 12, Colors.black);
    canvas.restore();
  }

  void _drawRiceStation(Canvas canvas, double x, double y, Map<String, dynamic> pData) {
    canvas.save();
    canvas.translate(x, y);

    if (pData['bag'] == null) {
      final path = Path();
      path.moveTo(-90, 60);
      path.cubicTo(-90, -10, -40, -80, 0, -80);
      path.cubicTo(40, -80, 90, -10, 90, 60);
      path.close();
      canvas.drawPath(path, Paint()..color = const Color(0xFFf8fafc));
      canvas.drawPath(path, Paint()..color = const Color(0xFF94a3b8)..style = PaintingStyle.stroke..strokeWidth = 3);
      _drawText(canvas, "${pData['target']} kg", 0, 20, 24, Colors.black);
    } else if (pData['success']) {
      double pw = 120;
      canvas.drawRect(Rect.fromLTWH(-pw/2, 60, pw, 10), Paint()..color = Colors.amber[700]!);
      canvas.drawRect(Rect.fromLTWH(-pw/2, 60, pw, 10), Paint()..color = const Color(0xFF78350f)..style = PaintingStyle.stroke..strokeWidth = 2);
      
      int count = pData['count'];
      int cols = min(4, sqrt(count).ceil());
      double spacingX = pw / cols;
      double startX = -pw/2 + spacingX/2;
      
      int itemsDrawn = 0; int row = 0;
      while (itemsDrawn < count && row < 5) {
        for(int c=0; c<cols; c++) {
          if(itemsDrawn >= count) break;
          _drawRiceBag(canvas, startX + c*spacingX, 40 - row*30.0, "${pData['bag']}kg", 0.8);
          itemsDrawn++;
        }
        row++;
      }
      _drawText(canvas, "${t('bagsFilled')} ${pData['count']}", 0, 100, 16, Colors.white);
    } else {
      final path = Path();
      path.moveTo(-60, 60);
      path.quadraticBezierTo(-20, -30, -10, -40);
      path.quadraticBezierTo(20, -30, 40, 60);
      path.close();
      canvas.drawPath(path, Paint()..color = const Color(0xFFf8fafc));
      canvas.drawPath(path, Paint()..color = const Color(0xFF94a3b8)..style = PaintingStyle.stroke..strokeWidth = 3);
      _drawText(canvas, "${pData['target']} kg", -10, 20, 20, Colors.black);

      _drawRiceBag(canvas, 45, 40, "${pData['bag']}kg", 0.7);
      _drawRiceBag(canvas, 70, 40, "${pData['bag']}kg", 0.7);

      final leftoverPath = Path();
      leftoverPath.moveTo(80, 60);
      leftoverPath.quadraticBezierTo(90, 40, 95, 35);
      leftoverPath.quadraticBezierTo(110, 40, 120, 60);
      leftoverPath.close();
      canvas.drawPath(leftoverPath, Paint()..color = Colors.red[300]!);
      canvas.drawPath(leftoverPath, Paint()..color = Colors.red[700]!..style = PaintingStyle.stroke..strokeWidth = 2);

      _drawText(canvas, "${t('leftoverTxt')} ${pData['leftover']}kg", 100, 20, 14, Colors.redAccent);
    }
    canvas.restore();
  }

  void _renderS2(Canvas canvas) {
    double convY = 160;
    
    // Conveyor matching HTML precisely
    double cWidth = 800;
    _drawRoundedRect(canvas, -400, convY, cWidth, 40, 20, const Color(0xFF334155), const Color(0xFF0f172a), 4);
    _drawRoundedRect(canvas, -395, convY + 5, cWidth - 10, 30, 15, const Color(0xFF1e293b), Colors.transparent, 0);
    for (double wx = -400 + 25; wx < -400 + cWidth - 15; wx += 35) {
      canvas.drawCircle(Offset(wx, convY + 20), 10, Paint()..color = const Color(0xFF64748b));
      canvas.drawCircle(Offset(wx, convY + 20), 10, Paint()..color = const Color(0xFF0f172a)..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawCircle(Offset(wx, convY + 20), 3, Paint()..color = const Color(0xFFcbd5e1));
    }
    _drawLine(canvas, -350, convY + 40, -350, convY + 100, const Color(0xFF475569), 8);
    _drawLine(canvas, 350, convY + 40, 350, convY + 100, const Color(0xFF475569), 8);

    for (int i = 0; i < s2BagSizes.length; i++) {
      if (s2ActiveBag != s2BagSizes[i]) {
        _drawRiceBag(canvas, -150.0 + i * 100, convY - 24, "${s2BagSizes[i]}kg", 1.2);
      }
    }

    _drawRiceStation(canvas, -200, 20, s2P1);
    _drawRiceStation(canvas, 150, 20, s2P2);

    if (s2ActiveBag != null) {
      _drawRiceBag(canvas, dragX, dragY, "${s2ActiveBag}kg", 1.2);
    }
  }

  // ---- Scenario 3 Rendering ----
  void _drawMachine(Canvas canvas, double x, double y, int number, Color color) {
    canvas.save();
    canvas.translate(x, y);
    _drawRoundedRect(canvas, -60, -100, 120, 150, 10, color, Colors.black, 3);
    _drawRoundedRect(canvas, -45, -80, 90, 30, 4, Colors.white, Colors.black, 1);
    _drawText(canvas, "MACHINE $number", 0, -65, 12, Colors.black);
    _drawRoundedRect(canvas, -40, 70, 80, 30, 6, Colors.green, Colors.black, 2);
    _drawText(canvas, "ACTIVATE", 0, 85, 12, Colors.white);
    canvas.restore();
  }

  void _drawFactorBlock(Canvas canvas, double x, double y, int val, double scale) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    Color fill = val == 2 ? Colors.greenAccent : val == 3 ? Colors.purpleAccent : val == 7 ? Colors.blueAccent : Colors.amber;
    _drawRoundedRect(canvas, -15, -15, 30, 30, 4, fill, Colors.black, 2);
    _drawText(canvas, val.toString(), 0, 0, 18, Colors.black);
    canvas.restore();
  }

  void _renderS3(Canvas canvas) {
    _drawMachine(canvas, -200, -180, 112, Colors.cyanAccent);
    _drawMachine(canvas, 200, -180, 84, Colors.pinkAccent);

    // Venn
    double vennCx = 0, vennCy = 140;
    canvas.drawCircle(Offset(vennCx - 70, vennCy), 120, Paint()..color = Colors.greenAccent.withOpacity(0.3));
    canvas.drawCircle(Offset(vennCx + 70, vennCy), 120, Paint()..color = Colors.purpleAccent.withOpacity(0.3));
    canvas.drawCircle(Offset(vennCx - 70, vennCy), 120, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawCircle(Offset(vennCx + 70, vennCy), 120, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 3);

    _drawText(canvas, "Factors of 112", vennCx - 110, vennCy - 140, 16, Colors.white);
    _drawText(canvas, "Factors of 84", vennCx + 110, vennCy - 140, 16, Colors.white);

    for (var b in [...s3M1Spawns, ...s3M2Spawns, ...s3CenterSpawns]) {
      if (!b['hidden'] && s3DragBlock != b) _drawFactorBlock(canvas, b['x'], b['y'], b['val'], 1.0);
    }

    if (s3DragBlock != null) {
      _drawFactorBlock(canvas, dragX, dragY, s3DragBlock!['val'], 1.2);
    }

    if (s3Calculated) {
      _drawRoundedRect(canvas, vennCx - 180, vennCy + 120, 360, 60, 10, const Color(0xFF1e293b), Colors.white24, 2);
      _drawFactorBlock(canvas, vennCx - 120, vennCy + 150, 2, 0.9);
      _drawText(canvas, "x", vennCx - 85, vennCy + 150, 20, Colors.white);
      _drawFactorBlock(canvas, vennCx - 50, vennCy + 150, 2, 0.9);
      _drawText(canvas, "x", vennCx - 15, vennCy + 150, 20, Colors.white);
      _drawFactorBlock(canvas, vennCx + 20, vennCy + 150, 7, 0.9);
      _drawText(canvas, "=", vennCx + 60, vennCy + 150, 20, Colors.white);
      _drawRoundedRect(canvas, vennCx + 80, vennCy + 130, 60, 40, 8, Colors.amber, Colors.black, 2);
      _drawText(canvas, "28", vennCx + 110, vennCy + 150, 24, Colors.black);
    }
  }

  // ---- Scenario 4 Rendering ----
  void _renderS4(Canvas canvas) {
    double sc = 6.2;
    _drawRoundedRect(canvas, -400, -140, 800, 280, 20, const Color(0xFF1e293b), const Color(0xFF475569), 5);
    _drawRoundedRect(canvas, -380, -100, 560, 220, 10, const Color(0xFF0f172a), const Color(0xFF475569), 3);
    
    _drawText(canvas, t('ribbon30'), -320, -75, 14, Colors.white);
    _drawText(canvas, t('ribbon72'), -320, 35, 14, Colors.white);

    _drawRoundedRect(canvas, -360, -50, 520, 50, 5, Colors.black87, const Color(0xFF334155), 2);
    _drawRoundedRect(canvas, -360, 60, 520, 50, 5, Colors.black87, const Color(0xFF334155), 2);

    // History
    _drawRoundedRect(canvas, 210, -100, 170, 220, 10, const Color(0xFF0f172a), const Color(0xFF475569), 3);
    _drawText(canvas, t('historyLbl'), 295, -75, 14, Colors.white54);
    for (int i = 0; i < s4History.length; i++) {
      Color c = s4History[i]['ok'] ? Colors.greenAccent : Colors.redAccent;
      _drawText(canvas, "${s4History[i]['len']}cm: ${s4History[i]['ok'] ? 'OK' : 'WASTE'}", 295, -45 + i * 25.0, 12, c);
    }

    double startX = -350;
    
    // 30cm Ribbon
    if (!s4IsCut) {
      _drawRoundedRect(canvas, startX, -45, 30 * sc, 40, 2, Colors.lightBlue, Colors.blue, 2);
    } else {
      double cx = startX;
      for (var c in s4Cuts1) {
        _drawRoundedRect(canvas, cx, -45, c * sc - 2, 40, 2, Colors.lightBlue, Colors.blue, 2);
        cx += c * sc;
      }
    }

    // 72cm Ribbon
    if (!s4IsCut) {
      _drawRoundedRect(canvas, startX, 65, 72 * sc, 40, 2, Colors.blueAccent, Colors.indigo, 2);
    } else {
      double cx = startX;
      for (var c in s4Cuts2) {
        _drawRoundedRect(canvas, cx, 65, c * sc - 2, 40, 2, Colors.blueAccent, Colors.indigo, 2);
        cx += c * sc;
      }
      if (s4Leftover > 0) {
        _drawRoundedRect(canvas, cx, 65, s4Leftover * sc, 40, 2, Colors.redAccent, Colors.red[900]!, 2);
        _drawText(canvas, "${s4Leftover}cm ${t('leftover')}", cx + (s4Leftover * sc) / 2, 120, 12, Colors.redAccent);
      }
    }

    // Laser
    double laserX = startX + (s4CutLen * sc);
    _drawRoundedRect(canvas, laserX - 20, -140, 40, 60, 5, Colors.white, Colors.black, 2);
    canvas.drawCircle(Offset(laserX, -80), 8, Paint()..color = Colors.red);
    if (s4IsCut) {
      _drawLine(canvas, laserX, -70, laserX, 110, Colors.redAccent.withOpacity(0.5 + 0.5 * sin(ticks / 100)), 3);
    }
  }

  // ---- Scenario 5 Rendering ----
  void _renderS5(Canvas canvas) {
    double sc = 15;
    _drawRoundedRect(canvas, -420, -150, 840, 260, 16, const Color(0xFF1e293b), Colors.lightBlueAccent, 4);

    _drawRoundedRect(canvas, 280, -130, 120, 220, 10, const Color(0xFF0f172a), const Color(0xFF64748b), 2);
    _drawText(canvas, t('commonJumps'), 340, -110, 12, Colors.white);
    for (int i = 0; i < s5History.length; i++) {
      _drawText(canvas, s5History[i].toString(), 340, -85 + i * 25.0, 16, Colors.greenAccent);
    }

    canvas.translate(0, 30);
    _drawLine(canvas, -380, 0, 380, 0, Colors.white, 4);

    for (int i = 0; i <= 50; i++) {
      double h = (i == 0 || i == 28 || i == 42 || i == 50) ? 15 : (i % 5 == 0 ? 10 : 5);
      double x = -375 + i * sc;
      _drawLine(canvas, x, -h, x, h, Colors.white, 2);
      if (i == 0 || i == 10 || i == 20 || i == 28 || i == 30 || i == 40 || i == 42 || i == 50) {
        _drawText(canvas, i.toString(), x, 25, 12, Colors.white);
      }
    }

    void drawChest(int val, bool isOpen) {
      double x = -375 + val * sc;
      _drawRoundedRect(canvas, x - 15, -40, 30, 25, 4, isOpen ? Colors.amber : Colors.indigo, Colors.white, 2);
      if(isOpen) _drawText(canvas, "✨", x, -55, 20, Colors.white);
    }
    
    drawChest(28, s5Hit1 || (s5FrogPos >= 28 && s5Path.contains(28)));
    drawChest(42, s5Hit2 || (s5FrogPos >= 42 && s5Path.contains(42)));

    final arcPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;
    for (int i = 1; i < s5Path.length; i++) {
      double x1 = -375 + s5Path[i - 1] * sc;
      double x2 = -375 + s5Path[i] * sc;
      double mx = (x1 + x2) / 2;

      final path = Path();
      path.moveTo(x1, -5);
      path.quadraticBezierTo(mx, -50, x2, -5);
      canvas.drawPath(path, arcPaint);
      _drawText(canvas, s5JumpSize.toString(), mx, -35, 14, Colors.white);
    }

    double fX = -375 + s5FrogPos * sc;
    _drawText(canvas, "🐸", fX, -15, 30, Colors.white);

    if (s5Path.length > 1 && s5FrogPos + s5JumpSize > 50 && (!s5Hit1 || !s5Hit2)) {
      _drawText(canvas, t('missed'), fX, -60, 16, Colors.redAccent);
    }
  }

  @override
  bool shouldRepaint(covariant HCFLabPainter oldDelegate) => true;
}

// ----------------------------------------------------------------------------
// Translations
// ----------------------------------------------------------------------------
class Translations {
  static const Map<String, Map<String, String>> data = {
    'en': {
      'appTitle': 'Finding Common Ground: The Greatest Common Divisor',
      'appSubtitle': 'Class 7 • FINDING COMMON GROUND',
      'enterLab': 'Enter Simulation',
      'selectScenario': 'Select Scenario',
      'learnLbl': 'Observations:',
      'commonFactor': 'Common Factor',
      'clearSetup': 'Clear Setup',
      'calculateBtn': 'CALCULATE',
      'setCutLength': 'Set Cut Length:',
      'cutBtn': 'Cut',
      'resetBtnUI': 'Reset',
      'finalAnswerLbl': 'Final Answer:',
      'submitBtn': 'Submit',
      'jumpSizeLbl': 'Jump Size:',
      'jumpBtn': 'Jump!',
      'finalJumpBtn': 'Final Jump',
      'historyLbl': 'HISTORY',
      'commonJumps': 'Common Jumps:',
      'ribbon30': '30cm Ribbon',
      'ribbon72': '72cm Ribbon',
      'leftover': 'Leftover',
      'leftoverTxt': 'Leftover:',
      'bagsFilled': 'Bags Filled:',
      'totalBags': 'Total Bags:',
      'missed': 'Missed!',
      'summaryTitle': 'Goal Reached!',
      'finalDesc': 'You have successfully explored the Highest Common Factor using real-world models!',
      'finishLab': 'Reset Lab',
      'hintLarger': 'That works, but can you find an even larger length?',
      'hintIncorrectS4': 'Incorrect. Try testing that length to see if it leaves waste.',
      'hintLongerJump': 'That works, but can you find an even longer jump?',
      'hintIncorrectS5': 'Incorrect. Try testing that size to see if it lands on exactly 28 and 42.',
      'scenarioCompleteMsg': 'Scenario completed! Try the next scenario from the sidebar.',

      's1_title': '1. The Perfect Fit Tiling',
      's1_obj': 'Find the largest possible square tile that perfectly fits a 12 ft by 16 ft room.',
      's1_step1_task': 'DRAG the 3ft tile from the palette and DROP it onto the floor.',
      's1_step1_out': 'The tiles fit perfectly along the 12ft wall but leave a 1ft gap along the 16ft wall. 3 is not a common factor.',
      's1_step2_task': 'CLICK the \'Clear Setup\' button. DRAG the 2ft tile onto the floor.',
      's1_step2_out': 'The room auto-fills perfectly with 2ft tiles. \'2\' is a common factor!',
      's1_step3_task': 'CLICK \'Clear Setup\' and test the remaining tile sizes (1, 4, 5, 6).',
      's1_step3_out': 'You found that 1ft and 4ft tiles also fit perfectly.',
      's1_step4_task': 'CLICK on the largest valid number in the Common Factors list.',
      's1_step4_out': 'Congratulations! 4ft is the largest tile that fits. This is the HCF of 12 and 16.',

      's2_title': '2. The Rice Bagging Challenge',
      's2_obj': 'Find the largest bag weight to pack 84kg and 108kg of rice equally with no leftovers.',
      's2_step1_task': 'DRAG the 7kg bag icon and DROP it onto the 84kg pile.',
      's2_step1_out': '84kg is bagged perfectly into twelve 7kg bags. 7 is a factor of 84.',
      's2_step2_task': 'DRAG the 7kg bag icon onto the 108kg pile.',
      's2_step2_out': 'There is 3kg of rice left over. 7 is not a factor of 108.',
      's2_step3_task': 'CLICK \'Clear Setup\'. Test the 6kg bag on both piles.',
      's2_step3_out': 'The 6kg bag works for both! It uses a total of 32 bags.',
      's2_step4_task': 'CLICK \'Clear Setup\'. Test the 12kg bag on both piles.',
      's2_step4_out': 'The 12kg bag also works for both! It uses only 16 bags in total.',
      's2_step5_task': 'CLICK on the bag size in the list that results in the fewest bags.',
      's2_step5_out': 'Correct! The largest common bag (12kg) uses the fewest bags. 12 is the HCF.',

      's3_title': '3. The Prime Factor Venn',
      's3_obj': 'Find the HCF of 112 and 84 by identifying their common prime factors.',
      's3_step1_task': 'CLICK the \'Activate\' button on Machine 112.',
      's3_step1_out': 'The machine outputs its prime factors: 2, 2, 2, 2, 7.',
      's3_step2_task': 'CLICK the \'Activate\' button on Machine 84.',
      's3_step2_out': 'The machine outputs its prime factors: 2, 2, 3, 7.',
      's3_step3_task': 'DRAG blocks to pair common factors in the center intersection.',
      's3_step3_out': 'You\'ve correctly paired two \'2\'s and one \'7\' in the center.',
      's3_step4_task': 'CLICK the \'Calculate\' button to multiply the common intersection.',
      's3_step4_out': '2 x 2 x 7 = 28. The HCF is 28.',

      's4_title': '4. Precision Ribbon Cutter',
      's4_obj': 'Find the largest length to cut both 30cm and 72cm ribbons into equal pieces with no waste.',
      's4_step1_task': 'Set the cut length to 5cm and CLICK the \'Cut\' button.',
      's4_step1_out': '30cm cuts perfectly, but 72cm leaves a 2cm waste piece.',
      's4_step2_task': 'CLICK \'Reset\'. Experiment with different cut lengths using the dial. Find the largest length that cuts both with zero waste.',
      's4_step2_out': 'You discovered the largest length that cuts both without waste.',
      's4_step3_task': 'Enter it into the final answer panel and CLICK \'Submit\'.',
      's4_step3_out': 'Success! 6cm is the largest piece size that can be cut from both ribbons without waste. The HCF of 30 and 72 is 6.',

      's5_title': '5. The Frog\'s Jackpot Jumps',
      's5_obj': 'Find the longest possible jump size the frog can use to land exactly on both treasure spots.',
      's5_step1_task': 'Set the jump size to 4 and CLICK the \'Jump!\' button.',
      's5_step1_out': 'The frog hits 28, but misses 42 (landing on 40, 44).',
      's5_step2_task': 'CLICK the \'Reset Frog\' button. Experiment with different jump sizes using the slider.',
      's5_step2_out': 'You found jump sizes that land on both treasures.',
      's5_step3_task': 'Set the slider to that value and CLICK the \'Final Jump\' button.',
      's5_step3_out': 'Jackpot! A jump size of 14 is the longest possible jump to get both treasures. The HCF of 28 and 42 is 14.',

      // HUD Texts
      's1_hud1': 'Drag the 3ft tile onto the grid to test it.',
      's1_hud2': 'Reset, then test the 2ft tile.',
      's1_hud3': 'Test tiles 1, 4, 5, and 6 to find all common factors.',
      's1_hud4': 'Select the highest common factor from the list.',

      's2_hud1': 'Test the 7kg bag on the 84kg pile.',
      's2_hud2': 'Now test the 7kg bag on the 108kg pile.',
      's2_hud3': 'Clear and test the 6kg bag on both piles.',
      's2_hud4': 'Clear and test the 12kg bag on both piles.',
      's2_hud5': 'Click the bag size that requires the least number of bags overall.',

      's3_hud1': 'Generate prime factors for 112.',
      's3_hud2': 'Generate prime factors for 84.',
      's3_hud3': 'Drag blocks from left/right to form matched pairs in the center.',
      's3_hud4': 'Calculate the product of the center items.',

      's4_hud1': 'Set length to 5cm and click cut.',
      's4_hud2': 'Find the largest common length.',
      's4_hud3': 'Submit your final answer.',

      's5_hud1': 'Set jump to 4 and click Jump!.',
      's5_hud2': 'Find the longest jump that hits both.',
      's5_hud3': 'Set your final jump size and submit.',
    },
    'hi': {
      'appTitle': 'समान आधार खोजना: महत्तम समापवर्तक (HCF)',
      'appSubtitle': 'कक्षा 7 • समान आधार खोजना',
      'enterLab': 'सिमुलेशन दर्ज करें',
      'selectScenario': 'परिदृश्य चुनें',
      'learnLbl': 'अवलोकन:',
      'commonFactor': 'सामान्य कारक',
      'clearSetup': 'सेटअप साफ़ करें',
      'calculateBtn': 'गणना करें',
      'setCutLength': 'कट लंबाई सेट करें:',
      'cutBtn': 'काटें',
      'resetBtnUI': 'रीसेट',
      'finalAnswerLbl': 'अंतिम उत्तर:',
      'submitBtn': 'सबमिट',
      'jumpSizeLbl': 'छलांग का आकार:',
      'jumpBtn': 'छलांग!',
      'finalJumpBtn': 'अंतिम छलांग',
      'historyLbl': 'इतिहास',
      'commonJumps': 'सामान्य छलांगें:',
      'ribbon30': '30cm रिबन',
      'ribbon72': '72cm रिबन',
      'leftover': 'बचा हुआ',
      'leftoverTxt': 'बचा हुआ:',
      'bagsFilled': 'भरे हुए बैग:',
      'totalBags': 'कुल बैग:',
      'missed': 'चूक गए!',
      'summaryTitle': 'लक्ष्य प्राप्त हुआ!',
      'finalDesc': 'आपने वास्तविक दुनिया के मॉडल का उपयोग करके उच्चतम सामान्य कारक का सफलतापूर्वक पता लगाया है!',
      'finishLab': 'लैब रीसेट करें',
      'hintLarger': 'यह काम करता है, लेकिन क्या आप इससे बड़ी लंबाई खोज सकते हैं?',
      'hintIncorrectS4': 'गलत। परीक्षण करें और देखें कि क्या यह कचरा छोड़ता है।',
      'hintLongerJump': 'यह काम करता है, लेकिन क्या आप इससे लंबी छलांग खोज सकते हैं?',
      'hintIncorrectS5': 'गलत। परीक्षण करें और देखें कि क्या यह ठीक 28 और 42 पर उतरता है।',
      'scenarioCompleteMsg': 'परिदृश्य पूरा हुआ! साइडबार से अगला परिदृश्य चुनें।',

      's1_title': '1. परफेक्ट फिट टाइलिंग',
      's1_obj': '12 फीट गुणा 16 फीट के कमरे में पूरी तरह फिट होने वाली सबसे बड़ी वर्गाकार टाइल खोजें।',
      's1_step1_task': 'पैलेट से 3 फीट की टाइल को खींचें और फर्श पर छोड़ें।',
      's1_step1_out': 'टाइलें 12 फीट की दीवार के साथ पूरी तरह फिट बैठती हैं लेकिन 16 फीट की दीवार के साथ 1 फीट का अंतर छोड़ती हैं। 3 एक सामान्य कारक नहीं है।',
      's1_step2_task': '\'क्लियर सेटअप\' बटन पर क्लिक करें। 2 फीट की टाइल को फर्श पर खींचें।',
      's1_step2_out': 'कमरा 2 फीट की टाइलों से पूरी तरह भर जाता है। \'2\' एक सामान्य कारक है!',
      's1_step3_task': '\'क्लियर सेटअप\' पर क्लिक करें और बाकी टाइल आकारों का परीक्षण करें।',
      's1_step3_out': 'आपने पाया कि 1 फीट और 4 फीट की टाइलें भी पूरी तरह फिट बैठती हैं।',
      's1_step4_task': 'सामान्य कारकों की सूची में सबसे बड़ी वैध संख्या पर क्लिक करें।',
      's1_step4_out': 'बधाई हो! 4 फीट सबसे बड़ी टाइल है जो फिट बैठती है। यह 12 और 16 का HCF है।',

      's2_title': '2. चावल बैगिंग चुनौती',
      's2_obj': 'बिना कुछ छोड़े 84 किग्रा और 108 किग्रा चावल को समान रूप से पैक करने के लिए सबसे बड़ा बैग वजन खोजें।',
      's2_step1_task': '7 किग्रा बैग आइकन को खींचें और 84 किग्रा ढेर पर छोड़ें।',
      's2_step1_out': '84 किग्रा को 7 किग्रा के बारह बैगों में पैक किया जाता है। 7, 84 का एक कारक है।',
      's2_step2_task': '7 किग्रा बैग आइकन को 108 किग्रा ढेर पर खींचें।',
      's2_step2_out': '3 किग्रा चावल बच गया है। 7, 108 का कारक नहीं है।',
      's2_step3_task': '\'क्लियर सेटअप\' पर क्लिक करें। 6 किग्रा बैग का परीक्षण करें।',
      's2_step3_out': '6 किग्रा बैग दोनों के लिए काम करता है! इसमें कुल 32 बैग लगते हैं।',
      's2_step4_task': '\'क्लियर सेटअप\' पर क्लिक करें। 12 किग्रा बैग का परीक्षण करें।',
      's2_step4_out': '12 किग्रा बैग भी काम करता है! इसमें कुल केवल 16 बैग लगते हैं।',
      's2_step5_task': 'सूची में उस बैग के आकार पर क्लिक करें जिसमें सबसे कम बैग लगते हैं।',
      's2_step5_out': 'सही! सबसे बड़े सामान्य बैग (12 किग्रा) में सबसे कम बैग लगते हैं। 12 HCF है।',

      's3_title': '3. प्राइम फैक्टर वेन',
      's3_obj': '112 और 84 के HCF को उनके सामान्य अभाज्य कारकों की पहचान करके खोजें।',
      's3_step1_task': 'मशीन 112 पर \'सक्रिय करें\' बटन पर क्लिक करें।',
      's3_step1_out': 'मशीन अपने अभाज्य कारकों का उत्पादन करती है: 2, 2, 2, 2, 7।',
      's3_step2_task': 'मशीन 84 पर \'सक्रिय करें\' बटन पर क्लिक करें।',
      's3_step2_out': 'मशीन अपने अभाज्य कारकों का उत्पादन करती है: 2, 2, 3, 7।',
      's3_step3_task': 'केंद्र में सामान्य कारकों को जोड़ने के लिए ब्लॉक खींचें।',
      's3_step3_out': 'आपने केंद्र में दो \'2\' और एक \'7\' को सही ढंग से जोड़ा है।',
      's3_step4_task': 'गुणा करने के लिए \'गणना\' बटन पर क्लिक करें।',
      's3_step4_out': '2 x 2 x 7 = 28। HCF 28 है।',

      's4_title': '4. सटीक रिबन कटर',
      's4_obj': 'बिना बर्बादी के 30 सेमी और 72 सेमी रिबन को समान टुकड़ों में काटने के लिए सबसे बड़ी लंबाई खोजें।',
      's4_step1_task': 'कटर की लंबाई 5 सेमी पर सेट करें और \'Cut\' पर क्लिक करें।',
      's4_step1_out': '30 सेमी पूरी तरह से कट जाता है, लेकिन 72 सेमी में 2 सेमी कचरा बच जाता है।',
      's4_step2_task': 'डायल का उपयोग करके विभिन्न कट लंबाई के साथ प्रयोग करें।',
      's4_step2_out': 'आपने सबसे बड़ी लंबाई की खोज की जो शून्य कचरे के साथ कटती है।',
      's4_step3_task': 'इसे अंतिम उत्तर पैनल में दर्ज करें और \'Submit\' पर क्लिक करें।',
      's4_step3_out': 'सफलता! 6 सेमी कचरे के बिना काटा जा सकता है। 30 और 72 का HCF 6 है।',

      's5_title': '5. मेंढक का जैकपॉट जंप',
      's5_obj': 'मेंढक द्वारा खजाने पर ठीक से उतरने के लिए सबसे लंबी छलांग का आकार खोजें।',
      's5_step1_task': 'छलांग का आकार 4 पर सेट करें और \'Jump!\' पर क्लिक करें।',
      's5_step1_out': 'मेंढक 28 पर उतरता है, लेकिन 42 से चूक जाता है।',
      's5_step2_task': 'स्लाइडर का उपयोग करके विभिन्न छलांग आकारों के साथ प्रयोग करें।',
      's5_step2_out': 'आपको छलांग के आकार मिले जो दोनों खजानों पर उतरते हैं।',
      's5_step3_task': 'स्लाइडर को उस मूल्य पर सेट करें और \'Final Jump\' पर क्लिक करें।',
      's5_step3_out': 'जैकपॉट! 14 छलांग का आकार दोनों खजानों को प्राप्त करने के लिए सबसे लंबी संभव छलांग है। HCF 14 है।',

      's1_hud1': '3 फीट की टाइल को ग्रिड पर खींचें।',
      's1_hud2': 'रीसेट करें, फिर 2 फीट की टाइल का परीक्षण करें।',
      's1_hud3': 'सभी सामान्य कारकों को खोजने के लिए 1, 4, 5 और 6 टाइलों का परीक्षण करें।',
      's1_hud4': 'सूची से उच्चतम सामान्य कारक चुनें।',

      's2_hud1': '84 किग्रा ढेर पर 7 किग्रा बैग का परीक्षण करें।',
      's2_hud2': 'अब 108 किग्रा ढेर पर 7 किग्रा बैग का परीक्षण करें।',
      's2_hud3': 'साफ़ करें और 6 किग्रा बैग का परीक्षण करें।',
      's2_hud4': 'साफ़ करें और 12 किग्रा बैग का परीक्षण करें।',
      's2_hud5': 'उस बैग के आकार पर क्लिक करें जिसमें कम से कम बैग की आवश्यकता होती है।',

      's3_hud1': '112 के अभाज्य कारक उत्पन्न करें।',
      's3_hud2': '84 के अभाज्य कारक उत्पन्न करें।',
      's3_hud3': 'जोड़े बनाने के लिए ब्लॉक खींचें।',
      's3_hud4': 'केंद्र वस्तुओं के उत्पाद की गणना करें।',

      's4_hud1': 'लंबाई को 5 सेमी पर सेट करें और काटें।',
      's4_hud2': 'अधिकतम सामान्य कट लंबाई खोजें।',
      's4_hud3': 'अपना अंतिम उत्तर सबमिट करें।',

      's5_hud1': 'छलांग 4 पर सेट करें।',
      's5_hud2': 'सबसे लंबी छलांग खोजें।',
      's5_hud3': 'अंतिम छलांग आकार सबमिट करें।',
    }
  };
}