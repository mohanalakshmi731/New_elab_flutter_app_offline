// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use, file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Pattern Quest: Explicit Rules',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        fontFamily: 'Roboto',
      ),
      home: const PatternQuestExplicitRulesForSequencesPracticeRound(),
    ),
  );
}

class PatternQuestExplicitRulesForSequencesPracticeRound
    extends StatefulWidget {
  const PatternQuestExplicitRulesForSequencesPracticeRound({super.key});

  @override
  State<PatternQuestExplicitRulesForSequencesPracticeRound> createState() =>
      _PatternQuestExplicitRulesForSequencesPracticeRoundState();
}

class _PatternQuestExplicitRulesForSequencesPracticeRoundState
    extends State<PatternQuestExplicitRulesForSequencesPracticeRound>
    with TickerProviderStateMixin {
  // Application State
  bool _isCurtainOpen = false;
  bool _isSidebarOpen = true;
  double _sidebarWidth = 300.0;
  int _currentScenario = 1;
  String _currentLang = 'en';
  bool _showFeedback = false;
  String _feedbackMsg = '';
  bool _feedbackSuccess = false;

  // Audio Players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _pagePlayer = AudioPlayer();
  final AudioPlayer _dropdownPlayer = AudioPlayer();

  Future<void> playClick() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class9/tap.mp3',
      ),
    );
  }

  Future<void> playPageOpen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class9/page_open.mp3',
      ),
    );
  }

  Future<void> playDropdown() async {
    await _dropdownPlayer.stop();
    await _dropdownPlayer.play(
      AssetSource(
        'audio/class9/dropdown.mp3',
      ),
    );
  }

  Future<void> playError() async {
    await _clickPlayer.stop();
    await _clickPlayer.play(
      AssetSource(
        'audio/class9/error_tone.mp3',
      ),
    );
  }

  Future<void> curtainScreen() async {
    await _pagePlayer.stop();
    await _pagePlayer.play(
      AssetSource(
        'audio/class9/shutter.mp3',
      ),
    );
  }

  // Controllers
  late AnimationController _gameLoopController;
  final GlobalKey _canvasKey = GlobalKey();

  // Camera State
  final CameraState _camera = CameraState(panX: 0, panY: 0, scale: 20.0);
  double _startPanX = 0;
  double _startPanY = 0;
  double _startScale = 20.0;
  Offset _startFocalPoint = Offset.zero;

  Timer? _feedbackTimer;

  // Form Controllers
  final TextEditingController _s2YController = TextEditingController();

  // Scenario 1 Data
  int? _s1SelectedA;
  int? _s1SelectedB;
  final List<int> _s1OptionsA = [2, 3, 4];
  final List<int> _s1OptionsB = [-4, -7, 5, -1];
  final int _s1ExpectedA = 3;
  final int _s1ExpectedB = -7;

  // Scenario 2 Data
  final List<int> _s2Positions = [1, 2, 3, 12, 18, 50];
  int _s2SelectedX = 1;
  final Map<int, double?> _s2PlacedY = {};

  // Scenario 3 Data
  final List<CandidateOrb> _s3Orbs = [
    CandidateOrb(332, Vector3(-7.5, 1, 5)),
    CandidateOrb(557, Vector3(-2.5, 1, 5)),
    CandidateOrb(100, Vector3(2.5, 1, 5)),
    CandidateOrb(150, Vector3(7.5, 1, 5)),
  ];
  final Map<int, String> _s3Placements = {};
  CandidateOrb? _s3SelectedOrb;

  @override
  void initState() {
    super.initState();
    playPageOpen();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // One full bob/pulse cycle (value * 2π in the painter) every 4 seconds.
    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _resetS2Data();
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _gameLoopController.dispose();
    _s2YController.dispose();
    _clickPlayer.dispose();
    _pagePlayer.dispose();
    _dropdownPlayer.dispose();
    super.dispose();
  }

  void _enterLab() {
    curtainScreen();
    setState(() {
      _isCurtainOpen = true;
    });
  }

  void _resetS2Data() {
    for (int n in _s2Positions) {
      _s2PlacedY[n] = null;
    }
  }

  void _loadScenario(int scNum) {
    setState(() {
      _currentScenario = scNum;
      _camera.panX = 0;
      _camera.panY = 0;
      _camera.scale = 20.0;
    });
  }

  void _resetScene() {
    setState(() {
      _s1SelectedA = null;
      _s1SelectedB = null;
      _resetS2Data();
      _s2YController.clear();
      _s3Placements.clear();
      _s3SelectedOrb = null;
      for (var orb in _s3Orbs) {
        orb.currentPos = Vector3(orb.basePos.x, orb.basePos.y, orb.basePos.z);
        orb.isPlaced = false;
        orb.animating = false;
      }
      _camera.panX = 0;
      _camera.panY = 0;
      _camera.scale = 20.0;
    });
  }

  void _triggerFeedback(String msg, bool success) {
    if (success) {
      playClick();
    } else {
      playError();
    }
    setState(() {
      _feedbackMsg = msg;
      _feedbackSuccess = success;
      _showFeedback = true;
    });
    // Restart the hide timer so a newer message gets its full 4 seconds.
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showFeedback = false);
    });
  }

  void _validate() {
    final t = _langMap[_currentLang]!;
    if (_currentScenario == 1) {
      bool correct =
          (_s1SelectedA == _s1ExpectedA && _s1SelectedB == _s1ExpectedB);
      _triggerFeedback(
        correct ? t['feedbackS1Success']! : t['feedbackS1Fail']!,
        correct,
      );
    } else if (_currentScenario == 2) {
      bool allCorrect = true;
      int count = 0;
      for (int n in _s2Positions) {
        if (_s2PlacedY[n] == null) {
          allCorrect = false;
        } else {
          count++;
          if (_s2PlacedY[n] != (3 * n - 7)) allCorrect = false;
        }
      }
      if (count < _s2Positions.length) allCorrect = false;
      _triggerFeedback(
        allCorrect ? t['feedbackS2Success']! : t['feedbackS2Fail']!,
        allCorrect,
      );
    } else if (_currentScenario == 3) {
      bool allCorrect = true;
      int count = 0;
      for (var orb in _s3Orbs) {
        String? placement = _s3Placements[orb.value];
        if (placement == null) {
          allCorrect = false;
        } else {
          count++;
          double n = (orb.value + 7) / 3;
          bool isMem = (n >= 1 && n == n.roundToDouble());
          String expected = isMem ? 'member' : 'notmember';
          if (placement != expected) allCorrect = false;
        }
      }
      if (count < _s3Orbs.length) allCorrect = false;
      _triggerFeedback(
        allCorrect ? t['feedbackS3Success']! : t['feedbackS3Fail']!,
        allCorrect,
      );
    }
  }

  void _constructS2Pillar() {
    double? yVal = double.tryParse(_s2YController.text);
    if (yVal != null) {
      setState(() {
        _s2PlacedY[_s2SelectedX] = yVal;
      });
    }
  }

  // --- Canvas Interactions (Smooth Pan/Zoom & Custom Tap) ---
  void _onScaleStart(ScaleStartDetails details) {
    _startPanX = _camera.panX;
    _startPanY = _camera.panY;
    _startScale = _camera.scale;
    _startFocalPoint = details.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final Size size = renderBox.size;
      Offset center = Offset(size.width / 2, size.height / 2);

      setState(() {
        double newScale = (_startScale * details.scale).clamp(10.0, 60.0);
        double scaleRatio = newScale / _startScale;

        _camera.scale = newScale;

        // Smooth zoom anchored to the focal point
        _camera.panX =
            details.localFocalPoint.dx -
            center.dx -
            (_startFocalPoint.dx - center.dx - _startPanX) * scaleRatio;
        _camera.panY =
            details.localFocalPoint.dy -
            center.dy -
            (_startFocalPoint.dy - center.dy - _startPanY) * scaleRatio;
      });
    }
  }

  void _handleCanvasClick(Offset tapPos) {
    if (_currentScenario != 3) return;

    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    // Hit test orbs where they are drawn: GameRenderer bobs idle orbs by
    // sin(time + basePos.x) * 1.5 world units, so apply the same offset.
    final double time = _gameLoopController.value * 2 * pi;
    final double hitRadius = max(45.0, 1.8 * _camera.scale);
    bool tappedOrb = false;
    for (var orb in _s3Orbs) {
      if (orb.isPlaced || orb.animating) continue;
      final Vector3 drawnPos = Vector3(
        orb.currentPos.x,
        orb.currentPos.y + sin(time + orb.basePos.x) * 1.5,
        orb.currentPos.z,
      );
      Offset projected = MathUtils.project(drawnPos, size, _camera);
      if ((projected - tapPos).distance < hitRadius) {
        // generous hit area
        playClick();
        setState(() {
          _s3SelectedOrb = orb;
        });
        tappedOrb = true;
        break;
      }
    }

    if (!tappedOrb && _s3SelectedOrb != null) {
      // Hit test portals
      Vector3 memberPortalPos = Vector3(-8, 1.5, -4);
      Vector3 nonMemberPortalPos = Vector3(8, 1.5, -4);

      Offset memProj = MathUtils.project(memberPortalPos, size, _camera);
      Offset nonMemProj = MathUtils.project(nonMemberPortalPos, size, _camera);

      if ((memProj - tapPos).distance < 80) {
        playClick();
        _placeOrb('member', memberPortalPos);
      } else if ((nonMemProj - tapPos).distance < 80) {
        playClick();
        _placeOrb('notmember', nonMemberPortalPos);
      }
    }
  }

  void _placeOrb(String type, Vector3 target) {
    final orb = _s3SelectedOrb!;
    // Clear the selection as soon as the orb is sent, so another portal tap
    // can't start a second animation loop pulling it toward a different
    // target (which left it hovering forever).
    setState(() {
      orb.animating = true;
      _s3SelectedOrb = null;
    });

    void animate() {
      if (!mounted || !orb.animating) return;
      double dx = target.x - orb.currentPos.x;
      double dy = target.y - orb.currentPos.y;
      double dz = target.z - orb.currentPos.z;
      double dist = sqrt(dx * dx + dy * dy + dz * dz);

      if (dist < 0.5) {
        setState(() {
          orb.animating = false;
          orb.isPlaced = true;
          _s3Placements[orb.value] = type;
        });
      } else {
        setState(() {
          orb.currentPos.x += dx * 0.15;
          orb.currentPos.y += dy * 0.15;
          orb.currentPos.z += dz * 0.15;
        });
        Future.delayed(const Duration(milliseconds: 16), animate);
      }
    }

    animate();
  }

  // --- UI Builders ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        playClick();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Canvas Area
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: 0,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              child: _buildCanvasArea(),
            ),

            // 2. HUD (Bottom Center of Canvas)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 24,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              right: 0,
              child: _buildBottomHUD(),
            ),

            // 3. Feedback HUD (Top Center)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              top: _showFeedback ? 24 : -100,
              left: _isSidebarOpen ? _sidebarWidth : 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _feedbackSuccess
                        ? Colors.green.shade900.withOpacity(0.9)
                        : Colors.red.shade900.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _feedbackSuccess ? Colors.green : Colors.red,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    _feedbackMsg,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // 4. Sidebar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -_sidebarWidth,
              width: _sidebarWidth,
              child: _buildSidebar(),
            ),

            // 5. Floating Menu Button
            Positioned(
              top: 16,
              child: SafeArea(
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF1E293B).withOpacity(0.8),
                  foregroundColor: const Color(0xFFEAB308),
                  elevation: 4,
                  onPressed: () {
                    playClick();
                    setState(() => _isSidebarOpen = !_isSidebarOpen);
                  },
                  child: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                ),
              ),
            ),

            // 6. Curtain Screen
            if (!_isCurtainOpen) _buildCurtainScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasArea() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF070B2E), Color(0xFF3A0D1D)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: GridPainter()),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              // Taps must be recognised here: the screen-wide onTap would
              // otherwise win the gesture arena on a stationary tap, and the
              // scale recognizer never reports it.
              onTapUp: (details) {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                _handleCanvasClick(details.localPosition);
              },
              child: CustomPaint(
                key: _canvasKey,
                painter: GameRenderer(
                  animation: _gameLoopController,
                  scenario: _currentScenario,
                  camera: _camera,
                  s1A: _s1SelectedA,
                  s1B: _s1SelectedB,
                  s2Placed: _s2PlacedY,
                  s3Orbs: _s3Orbs,
                  s3SelectedOrb: _s3SelectedOrb,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final t = _langMap[_currentLang]!;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(right: BorderSide(color: Colors.white24, width: 2)),
      ),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Details
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 60,
                            bottom: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.dashboard_customize,
                                    color: Color(0xFFEAB308),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      t['title']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(left: 34),
                                child: Text(
                                  t['subtitle']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.only(left: 34),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white12,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              playClick();
                                              setState(
                                                () => _currentLang = 'en',
                                              );
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: _currentLang == 'en'
                                                    ? const Color(0xFFEAB308)
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: Text(
                                                'EN',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _currentLang == 'en'
                                                      ? Colors.black
                                                      : Colors.white70,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              playClick();
                                              setState(
                                                () => _currentLang = 'hi',
                                              );
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: _currentLang == 'hi'
                                                    ? const Color(0xFFEAB308)
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: Text(
                                                'HI',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _currentLang == 'hi'
                                                      ? Colors.black
                                                      : Colors.white70,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        playClick();
                                        _resetScene();
                                      },
                                      tooltip: 'Reset',
                                      constraints: const BoxConstraints(
                                        minWidth: 36,
                                        minHeight: 36,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(
                          color: Colors.white10,
                          height: 1,
                          thickness: 1,
                        ),

                        // Main Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Scenario Select
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t['lblActiveScenario']!,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<int>(
                                      isExpanded: true,
                                      value: _currentScenario,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      dropdownColor: const Color(0xFF0F172A),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                          value: 1,
                                          child: Text(
                                            t['sc1Option']!,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 2,
                                          child: Text(
                                            t['sc2Option']!,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 3,
                                          child: Text(
                                            t['sc3Option']!,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        playDropdown();
                                        _loadScenario(v!);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Scenario Instruction Details
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
                                          Icons.track_changes,
                                          color: Color(0xFFEAB308),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildRichText(
                                            t['s${_currentScenario}Title']!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFFEAB308),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildRichText(
                                      t['s${_currentScenario}Desc']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: _buildRichText(
                                  t['s${_currentScenario}Steps']!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEAB308),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 8,
                                  shadowColor: const Color(
                                    0xFFEAB308,
                                  ).withOpacity(0.5),
                                ),
                                onPressed: () {
                                  playClick();
                                  _validate();
                                },
                                icon: const Icon(Icons.check_circle, size: 28),
                                label: Text(
                                  t['validateBtn']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Spacer to push Footer to bottom
                        const Spacer(),

                        // Footer
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white10),
                            ),
                            color: Color(0xFF0F172A),
                          ),
                          child: const Text(
                            "© ZEROSCIENCELAB | Fall in Love with Math and Science",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white38,
                              letterSpacing: 1.5,
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

          // Right Drag Handle (Resizer)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 15,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _sidebarWidth += details.delta.dx;
                    if (_sidebarWidth < 300) _sidebarWidth = 300;
                    if (_sidebarWidth >
                        MediaQuery.of(context).size.width * 0.6) {
                      _sidebarWidth = MediaQuery.of(context).size.width * 0.6;
                    }
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Container(
                    width: 4,
                    height: 50,
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
    );
  }

  Widget _buildBottomHUD() {
    final t = _langMap[_currentLang]!;
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildRichText(
                    t['hudS${_currentScenario}Title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFEAB308),
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildRichText(
                    t['hudS${_currentScenario}Subtitle']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_currentScenario == 1) _buildS1HUD(),
            if (_currentScenario == 2) _buildS2HUD(t),
            if (_currentScenario == 3) _buildS3HUD(t),
          ],
        ),
      ),
    );
  }

  Widget _buildS1HUD() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 12,
      children: [
        _buildDropdownWrapper(
          label: "Coefficient (a):",
          color: const Color(0xFFEAB308),
          child: DropdownButton<int>(
            value: _s1SelectedA,
            hint: const Text("?", style: TextStyle(color: Colors.white)),
            dropdownColor: const Color(0xFF1E293B),
            underline: const SizedBox(),
            items: _s1OptionsA
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(
                      v.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              playDropdown();
              setState(() => _s1SelectedA = v);
            },
          ),
        ),
        _buildDropdownWrapper(
          label: "Constant (b):",
          color: Colors.purpleAccent,
          child: DropdownButton<int>(
            value: _s1SelectedB,
            hint: const Text("?", style: TextStyle(color: Colors.white)),
            dropdownColor: const Color(0xFF1E293B),
            underline: const SizedBox(),
            items: _s1OptionsB
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(
                      v.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              playDropdown();
              setState(() => _s1SelectedB = v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildS2HUD(Map<String, String> t) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        _buildDropdownWrapper(
          label: "Position X (n):",
          color: const Color(0xFFEAB308),
          child: DropdownButton<int>(
            value: _s2SelectedX,
            dropdownColor: const Color(0xFF1E293B),
            underline: const SizedBox(),
            items: _s2Positions
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(
                      v.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              playDropdown();
              setState(() => _s2SelectedX = v!);
            },
          ),
        ),
        _buildDropdownWrapper(
          label: "Term Y (t_n):",
          color: Colors.lightBlueAccent,
          child: SizedBox(
            width: 80,
            height: 36,
            child: TextField(
              controller: _s2YController,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: "-4",
                hintStyle: TextStyle(color: Colors.white24),
              ),
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            playClick();
            _constructS2Pillar();
          },
          child: Text(
            t['btnConstruct']!,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _buildS3HUD(Map<String, String> t) {
    List<Widget> chips = [];
    _s3Placements.forEach((val, type) {
      bool isMem = type == 'member';
      chips.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isMem
                ? Colors.green.shade900.withOpacity(0.5)
                : Colors.blue.shade900.withOpacity(0.5),
            border: Border.all(color: isMem ? Colors.green : Colors.blue),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "$val: ${isMem ? 'Mem' : 'Non'}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isMem ? Colors.green.shade200 : Colors.blue.shade200,
            ),
          ),
        ),
      );
    });

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 8,
      children: [
        const Text(
          "Sorted: ",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        if (chips.isEmpty)
          const Text(
            "None sorted yet",
            style: TextStyle(
              color: Colors.white38,
              fontStyle: FontStyle.italic,
            ),
          ),
        ...chips,
      ],
    );
  }

  Widget _buildDropdownWrapper({
    required String label,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRichText(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildCurtainScreen() {
    final t = _langMap[_currentLang]!;
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF020617),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.dashboard_customize,
                color: Color(0xFFEAB308),
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                t['title']!,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFEAB308),
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                t['subtitle']!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAB308),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 20,
                  shadowColor: const Color(0xFFEAB308).withOpacity(0.6),
                ),
                onPressed: _enterLab,
                child: Text(
                  t['enterLab']!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRichText(
    String input, {
    TextStyle style = const TextStyle(color: Colors.white),
  }) {
    List<TextSpan> spans = [];
    String curr = '';
    bool isMath = false;
    bool isBold = false;

    input = input.replaceAll('<br>', '\n');

    for (int i = 0; i < input.length; i++) {
      if (input.startsWith('<b>', i)) {
        if (curr.isNotEmpty) {
          spans.add(
            TextSpan(
              text: curr,
              style: style.copyWith(
                fontWeight: isBold ? FontWeight.bold : style.fontWeight,
                fontStyle: isMath ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          );
        }
        curr = '';
        isBold = true;
        i += 2;
      } else if (input.startsWith('</b>', i)) {
        if (curr.isNotEmpty) {
          spans.add(
            TextSpan(
              text: curr,
              style: style.copyWith(
                fontWeight: FontWeight.bold,
                fontStyle: isMath ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          );
        }
        curr = '';
        isBold = false;
        i += 3;
      } else if (input[i] == '\$') {
        if (curr.isNotEmpty) {
          spans.add(
            TextSpan(
              text: curr,
              style: style.copyWith(
                fontWeight: isBold ? FontWeight.bold : style.fontWeight,
                fontStyle: isMath ? FontStyle.italic : FontStyle.normal,
                color: isMath ? Colors.cyanAccent : style.color,
              ),
            ),
          );
        }
        curr = '';
        isMath = !isMath;
      } else {
        curr += input[i];
      }
    }
    if (curr.isNotEmpty) {
      spans.add(
        TextSpan(
          text: curr,
          style: style.copyWith(
            fontWeight: isBold ? FontWeight.bold : style.fontWeight,
            fontStyle: isMath ? FontStyle.italic : FontStyle.normal,
            color: isMath ? Colors.cyanAccent : style.color,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }
}

// --- Data Models & Isometric Engine ---

class Vector3 {
  double x, y, z;
  Vector3(this.x, this.y, this.z);
}

class CameraState {
  double panX, panY, scale;
  CameraState({required this.panX, required this.panY, required this.scale});
}

class CandidateOrb {
  final int value;
  final Vector3 basePos;
  Vector3 currentPos;
  bool isPlaced = false;
  bool animating = false;
  CandidateOrb(this.value, this.basePos)
    : currentPos = Vector3(basePos.x, basePos.y, basePos.z);
}

class MathUtils {
  static Offset project(Vector3 p, Size size, CameraState cam) {
    double isoX = (p.x - p.z) * cos(pi / 6);
    double isoY = (p.x + p.z) * sin(pi / 6) - p.y;
    return Offset(
      size.width / 2 + isoX * cam.scale + cam.panX,
      size.height / 2 + isoY * cam.scale + cam.panY,
    );
  }
}

// --- Renderers ---

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;
    const double step = 40.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GameRenderer extends CustomPainter {
  final AnimationController animation;
  final int scenario;
  final CameraState camera;

  // S1 Data
  final int? s1A;
  final int? s1B;

  // S2 Data
  final Map<int, double?> s2Placed;
  final Map<int, double> posAngles = {
    1: -pi / 3,
    2: -pi / 6,
    3: 0,
    12: pi / 6,
    18: pi / 3,
    50: pi / 2,
  };

  // S3 Data
  final List<CandidateOrb> s3Orbs;
  final CandidateOrb? s3SelectedOrb;

  GameRenderer({
    required this.animation,
    required this.scenario,
    required this.camera,
    this.s1A,
    this.s1B,
    required this.s2Placed,
    required this.s3Orbs,
    this.s3SelectedOrb,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (scenario == 1) {
      _drawScenario1(canvas, size);
    } else if (scenario == 2) {
      _drawScenario2(canvas, size);
    } else if (scenario == 3) {
      _drawScenario3(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant GameRenderer oldDelegate) {
    // Because we passed `animation` to `super(repaint: animation)`,
    // the CustomPainter automatically repaints on every animation tick.
    // Returning true ensures UI state changes (clicks, drags) update seamlessly as well.
    return true;
  }

  void _drawIsoBox(
    Canvas canvas,
    Size size,
    Vector3 center,
    double w,
    double h,
    double d,
    Color color,
  ) {
    Vector3 p1 = Vector3(center.x - w / 2, center.y + h, center.z - d / 2);
    Vector3 p2 = Vector3(center.x + w / 2, center.y + h, center.z - d / 2);
    Vector3 p3 = Vector3(center.x + w / 2, center.y + h, center.z + d / 2);
    Vector3 p4 = Vector3(center.x - w / 2, center.y + h, center.z + d / 2);

    Vector3 p5 = Vector3(center.x - w / 2, center.y, center.z - d / 2);
    Vector3 p6 = Vector3(center.x + w / 2, center.y, center.z - d / 2);
    Vector3 p7 = Vector3(center.x + w / 2, center.y, center.z + d / 2);
    Vector3 p8 = Vector3(center.x - w / 2, center.y, center.z + d / 2);

    List<Offset> proj = [
      p1,
      p2,
      p3,
      p4,
      p5,
      p6,
      p7,
      p8,
    ].map((p) => MathUtils.project(p, size, camera)).toList();

    Paint topPaint = Paint()
      ..color = _lighten(color, 0.2)
      ..style = PaintingStyle.fill;
    Paint leftPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    Paint rightPaint = Paint()
      ..color = _lighten(color, -0.2)
      ..style = PaintingStyle.fill;

    // Left Face (p4, p3, p7, p8)
    Path leftPath = Path()
      ..moveTo(proj[3].dx, proj[3].dy)
      ..lineTo(proj[2].dx, proj[2].dy)
      ..lineTo(proj[6].dx, proj[6].dy)
      ..lineTo(proj[7].dx, proj[7].dy)
      ..close();
    canvas.drawPath(leftPath, leftPaint);

    // Right Face (p1, p4, p8, p5)
    Path rightPath = Path()
      ..moveTo(proj[0].dx, proj[0].dy)
      ..lineTo(proj[3].dx, proj[3].dy)
      ..lineTo(proj[7].dx, proj[7].dy)
      ..lineTo(proj[4].dx, proj[4].dy)
      ..close();
    canvas.drawPath(rightPath, rightPaint);

    // Top Face (p1, p2, p3, p4)
    Path topPath = Path()
      ..moveTo(proj[0].dx, proj[0].dy)
      ..lineTo(proj[1].dx, proj[1].dy)
      ..lineTo(proj[2].dx, proj[2].dy)
      ..lineTo(proj[3].dx, proj[3].dy)
      ..close();
    canvas.drawPath(topPath, topPaint);
  }

  void _drawIsoCylinder(
    Canvas canvas,
    Size size,
    Vector3 center,
    double r,
    double h,
    Color color,
  ) {
    Offset centerTop = MathUtils.project(
      Vector3(center.x, center.y + h, center.z),
      size,
      camera,
    );
    Offset centerBottom = MathUtils.project(center, size, camera);

    double rx = r * camera.scale;
    double ry = r * camera.scale * 0.5;

    Paint sidePaint = Paint()
      ..color = _lighten(color, -0.1)
      ..style = PaintingStyle.fill;
    Paint topPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Body
    Path bodyPath = Path()
      ..moveTo(centerTop.dx - rx, centerTop.dy)
      ..lineTo(centerBottom.dx - rx, centerBottom.dy)
      ..arcToPoint(
        Offset(centerBottom.dx + rx, centerBottom.dy),
        radius: Radius.elliptical(rx, ry),
        clockwise: false,
      )
      ..lineTo(centerTop.dx + rx, centerTop.dy)
      ..arcToPoint(
        Offset(centerTop.dx - rx, centerTop.dy),
        radius: Radius.elliptical(rx, ry),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(bodyPath, sidePaint);

    // Top
    canvas.drawOval(
      Rect.fromCenter(center: centerTop, width: rx * 2, height: ry * 2),
      topPaint,
    );
  }

  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  void _drawTextSprite(
    Canvas canvas,
    String text,
    Offset pos,
    Color color, {
    double fontSize = 20,
  }) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  void _drawScenario1(Canvas canvas, Size size) {
    // Forge Base
    _drawIsoBox(
      canvas,
      size,
      Vector3(0, 0, 0),
      16,
      2,
      12,
      const Color(0xFF1E293B),
    );

    // Screens / Displays
    _drawIsoBox(
      canvas,
      size,
      Vector3(-4, 2, 0),
      6,
      4,
      1,
      const Color(0xFF0F172A),
    );
    _drawIsoBox(
      canvas,
      size,
      Vector3(4, 2, 0),
      6,
      4,
      1,
      const Color(0xFF0F172A),
    );

    Offset aPos = MathUtils.project(Vector3(-4, 6, 0), size, camera);
    Offset bPos = MathUtils.project(Vector3(4, 6, 0), size, camera);

    _drawTextSprite(
      canvas,
      "a = ${s1A ?? '?'}",
      aPos,
      const Color(0xFFEAB308),
      fontSize: camera.scale * 1.5,
    );
    _drawTextSprite(
      canvas,
      "b = ${s1B ?? '?'}",
      bPos,
      Colors.purpleAccent,
      fontSize: camera.scale * 1.5,
    );
  }

  void _drawScenario2(Canvas canvas, Size size) {
    // Base platform
    _drawIsoCylinder(
      canvas,
      size,
      Vector3(0, 0, 0),
      18,
      1,
      const Color(0xFF1E293B),
    );

    double r = 12;
    posAngles.forEach((n, angle) {
      Vector3 pedPos = Vector3(cos(angle) * r, 1, sin(angle) * r);
      _drawIsoCylinder(canvas, size, pedPos, 2, 0.5, const Color(0xFF334155));

      Offset labelPos = MathUtils.project(
        Vector3(pedPos.x, pedPos.y + 1, pedPos.z),
        size,
        camera,
      );
      _drawTextSprite(
        canvas,
        "n = $n",
        labelPos,
        const Color(0xFFEAB308),
        fontSize: camera.scale * 0.8,
      );

      double? yVal = s2Placed[n];
      if (yVal != null) {
        double visualY = yVal * 0.15;
        double h = visualY.abs().clamp(0.1, 20.0);
        Color c = yVal < 0 ? Colors.redAccent : Colors.lightBlueAccent;
        Vector3 pillarCenter = yVal >= 0
            ? Vector3(pedPos.x, pedPos.y + 0.5, pedPos.z)
            : Vector3(pedPos.x, pedPos.y + 0.5 - h, pedPos.z);

        _drawIsoBox(
          canvas,
          size,
          pillarCenter,
          1.5,
          h,
          1.5,
          c.withOpacity(0.8),
        );
      }
    });
  }

  void _drawScenario3(Canvas canvas, Size size) {
    // Base
    _drawIsoBox(
      canvas,
      size,
      Vector3(0, -1, 0),
      24,
      0.5,
      16,
      const Color(0xFF0F172A),
    );

    // Portals
    Vector3 memPos = Vector3(-8, 1.5, -4);
    Vector3 nonMemPos = Vector3(8, 1.5, -4);

    _drawPortal(canvas, size, memPos, Colors.greenAccent, "Member");
    _drawPortal(canvas, size, nonMemPos, Colors.blueAccent, "Not Member");

    // Orbs
    double time = animation.value * 2 * pi;

    for (var orb in s3Orbs) {
      if (orb.isPlaced) continue;

      Vector3 renderPos = Vector3(
        orb.currentPos.x,
        orb.currentPos.y,
        orb.currentPos.z,
      );
      if (!orb.animating) {
        renderPos.y += sin(time + orb.basePos.x) * 1.5;
      }

      Offset screenPos = MathUtils.project(renderPos, size, camera);
      double radius = 1.2 * camera.scale;

      bool isSelected = orb == s3SelectedOrb;

      // Glow
      final glowPaint = Paint()
        ..color = isSelected
            ? Colors.yellowAccent.withOpacity(0.6)
            : Colors.yellow.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(screenPos, radius * 1.5, glowPaint);

      // Orb core
      final corePaint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.yellowAccent, Colors.orange.shade800],
        ).createShader(Rect.fromCircle(center: screenPos, radius: radius));
      canvas.drawCircle(screenPos, radius, corePaint);

      _drawTextSprite(
        canvas,
        "${orb.value}",
        Offset(screenPos.dx, screenPos.dy - radius - 10),
        Colors.white,
        fontSize: camera.scale * 0.8,
      );
    }
  }

  void _drawPortal(
    Canvas canvas,
    Size size,
    Vector3 pos,
    Color color,
    String label,
  ) {
    Offset screenPos = MathUtils.project(pos, size, camera);
    double rX = 3 * camera.scale;
    double rY = 1.5 * camera.scale;

    double time = animation.value * 2 * pi;
    double scale = 1.0 + 0.1 * sin(time * 2);

    Paint ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * scale
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5);

    canvas.drawOval(
      Rect.fromCenter(
        center: screenPos,
        width: rX * 2 * scale,
        height: rY * 2 * scale,
      ),
      ringPaint,
    );

    Paint fillPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: screenPos, width: rX * 2, height: rY * 2),
      fillPaint,
    );

    _drawTextSprite(
      canvas,
      label,
      Offset(screenPos.dx, screenPos.dy - rY - 20),
      color,
      fontSize: camera.scale,
    );
  }
}

// --- Localization Dictionary ---

const Map<String, Map<String, String>> _langMap = {
  'en': {
    'title': "Pattern Quest: Explicit Rules",
    'subtitle': "Class 9 • Predicting What Comes Next",
    'enterLab': "Enter Lab",
    's1Title': "Mission: Forge the Rule",
    's1Desc':
        "Observe the sequence: \$-4, -1, 2, 5...\$<br>Determine the explicit rule \$t_n = an + b\$.",
    's1Steps':
        "<b>Procedural Steps:</b><br><br>1. Select the correct Coefficient (\$a\$) that represents the step size.<br><br>2. Select the correct Constant (\$b\$).<br><br>3. Click <b>Validate Model</b> to forge the rule.",
    's2Title': "Mission: Sequence Construction",
    's2Desc':
        "Using your forged rule \$t_n = 3n - 7\$, construct the pillars for the required positions \$n\$.",
    's2Steps':
        "<b>Procedural Steps:</b><br><br>1. Select a position \$n\$ in the bottom HUD.<br><br>2. Calculate the term value \$t_n\$ and enter it into the \$Y\$ input.<br><br>3. Click 'Construct Pillar' to place it.<br><br>4. Construct all required pillars (1, 2, 3, 12, 18, 50).<br><br>5. Click <b>Validate Model</b> to confirm.",
    's3Title': "Mission: Membership Quest",
    's3Desc':
        "For each glowing candidate, solve \$3n - 7 = value\$ for \$n\$ and sort them.",
    's3Steps':
        "<b>Procedural Steps:</b><br><br>1. Observe the candidates (Values: 332, 557, 100, 150).<br><br>2. Solve the equation for \$n\$. If \$n\$ is a whole number (1, 2, 3...), it is a Member.<br><br>3. Click a candidate to select it, then click on the 'Member' or 'Not a Member' portal.<br><br>4. Sort all candidates.<br><br>5. Click <b>Validate Model</b>.",
    'hudS1Title': "Formula Forge",
    'hudS1Subtitle': "Set a and b for \$t_n = an + b\$",
    'hudS2Title': "Sequence Construction",
    'hudS2Subtitle': "Rule: \$t_n = 3n - 7\$",
    'hudS3Title': "Membership Sorting",
    'hudS3Subtitle': "Select a candidate to sort",
    'btnConstruct': "Construct Pillar",
    'validateBtn': "Validate Model",
    'lblActiveScenario': "Active Scenario",
    'sc1Option': "Scenario 1: Forge Rule",
    'sc2Option': "Scenario 2: Build Sequence",
    'sc3Option': "Scenario 3: Membership Test",
    'feedbackS1Success': "Perfect! You forged the correct rule: t_n = 3n - 7.",
    'feedbackS1Fail': "Incorrect. Hint: step size is +3, so a=3. What is b?",
    'feedbackS2Success': "Outstanding! You've constructed all terms correctly.",
    'feedbackS2Fail':
        "Some pillars are missing or incorrect. Hint: t_n = 3n - 7",
    'feedbackS3Success': "Brilliant! Candidates correctly sorted.",
    'feedbackS3Fail':
        "Some candidates are sorted incorrectly. Check your math.",
  },
  'hi': {
    'title': "पैटर्न खोज: स्पष्ट नियम",
    'subtitle': "कक्षा 9 • आगे क्या होगा इसकी भविष्यवाणी करना",
    'enterLab': "प्रयोगशाला में प्रवेश करें",
    's1Title': "मिशन: नियम बनाएँ",
    's1Desc':
        "अनुक्रम का निरीक्षण करें: \$-4, -1, 2, 5...\$<br>स्पष्ट नियम निर्धारित करें \$t_n = an + b\$।",
    's1Steps':
        "<b>प्रक्रियात्मक चरण:</b><br><br>1. सही गुणांक (\$a\$) चुनें जो चरण आकार का प्रतिनिधित्व करता है।<br><br>2. सही स्थिरांक (\$b\$) चुनें।<br><br>3. नियम बनाने के लिए <b>मॉडल मान्य करें</b> पर क्लिक करें।",
    's2Title': "मिशन: अनुक्रम निर्माण",
    's2Desc':
        "अपने बनाए गए नियम \$t_n = 3n - 7\$ का उपयोग करके, आवश्यक स्थितियों \$n\$ के लिए स्तंभों का निर्माण करें।",
    's2Steps':
        "<b>प्रक्रियात्मक चरण:</b><br><br>1. निचले HUD में एक स्थिति \$n\$ चुनें।<br><br>2. पद मान \$t_n\$ की गणना करें और इसे \$Y\$ इनपुट में दर्ज करें।<br><br>3. इसे रखने के लिए 'स्तंभ बनाएँ' पर क्लिक करें।<br><br>4. सभी आवश्यक स्तंभ (1, 2, 3, 12, 18, 50) बनाएँ।<br><br>5. पुष्टि करने के लिए <b>मॉडल मान्य करें</b> पर क्लिक करें।",
    's3Title': "मिशन: सदस्यता खोज",
    's3Desc':
        "प्रत्येक चमकते उम्मीदवार के लिए, \$n\$ के लिए \$3n - 7 = मान\$ हल करें और उन्हें क्रमबद्ध करें।",
    's3Steps':
        "<b>प्रक्रियात्मक चरण:</b><br><br>1. उम्मीदवारों का निरीक्षण करें (मान: 332, 557, 100, 150)।<br><br>2. \$n\$ के लिए समीकरण हल करें। यदि \$n\$ एक पूर्ण संख्या (1, 2, 3...) है, तो यह सदस्य है।<br><br>3. एक उम्मीदवार का चयन करने के लिए उस पर क्लिक करें, फिर 'सदस्य' या 'सदस्य नहीं' पोर्टल पर क्लिक करें।<br><br>4. सभी उम्मीदवारों को क्रमबद्ध करें।<br><br>5. <b>मॉडल मान्य करें</b> पर क्लिक करें।",
    'hudS1Title': "फॉर्मूला फोर्ज",
    'hudS1Subtitle': "\$t_n = an + b\$ के लिए a और b सेट करें",
    'hudS2Title': "अनुक्रम निर्माण",
    'hudS2Subtitle': "नियम: \$t_n = 3n - 7\$",
    'hudS3Title': "सदस्यता छँटाई",
    'hudS3Subtitle': "छांटने के लिए एक उम्मीदवार चुनें",
    'btnConstruct': "स्तंभ बनाएँ",
    'validateBtn': "मॉडल मान्य करें",
    'lblActiveScenario': "सक्रिय परिदृश्य",
    'sc1Option': "परिदृश्य 1: नियम बनाएँ",
    'sc2Option': "परिदृश्य 2: अनुक्रम निर्माण",
    'sc3Option': "परिदृश्य 3: सदस्यता परीक्षण",
    'feedbackS1Success': "उत्तम! आपने सही नियम बनाया है: t_n = 3n - 7।",
    'feedbackS1Fail':
        "गलत। संकेत: पदों के बीच का अंतर +3 है, इसलिए a=3। b क्या है?",
    'feedbackS2Success':
        "बहुत बढ़िया! आपने अनुक्रम में सभी पदों की सही गणना की है।",
    'feedbackS2Fail': "कुछ स्तंभ गलत हैं। याद रखें t_n = 3n - 7।",
    'feedbackS3Success': "शानदार! आपने सही ढंग से क्रमबद्ध किया है।",
    'feedbackS3Fail': "कुछ उम्मीदवारों को गलत तरीके से क्रमबद्ध किया गया है।",
  },
};
