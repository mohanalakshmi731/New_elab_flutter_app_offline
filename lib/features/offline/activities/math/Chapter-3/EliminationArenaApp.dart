// Imported from new-elab-app; Class 10 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class EliminationArenaApp extends StatefulWidget {
  const EliminationArenaApp({super.key});

  @override
  State<EliminationArenaApp> createState() => _EliminationArenaAppState();
}

class _EliminationArenaAppState extends State<EliminationArenaApp> {
  bool _introVisible = true;
  String _currentLang = 'en';
  bool _isPanelOpen = true; // Side panel defaults to open

  // Game State
  int _currentStep = 1; // 1 to 5
  late GameCase _caseData;
  String? _droppedMultiplier;
  bool _eqStriking = false;
  bool _hasError = false;

  final TextEditingController _xController = TextEditingController();
  final TextEditingController _yController = TextEditingController();
  final ScrollController _hudScrollController = ScrollController();

  // Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _fxPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  // Network Audio Sources for guaranteed playback on Android
  static const String _clickUrl = 'audio/math/click.mp3';
  static const String _successUrl = 'audio/math/success.mp3';
  static const String _errorUrl = 'audio/math/error.mp3';
  static const String _shutterUrl = 'audio/math/shutter.mp3';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _generateCase();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _xController.dispose();
    _yController.dispose();
    _hudScrollController.dispose();

    // Dispose Audio players
    _clickPlayer.dispose();
    _fxPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();

    super.dispose();
  }

  void _playSound(String type) async {
    if (type == 'click') HapticFeedback.selectionClick();
    if (type == 'success') HapticFeedback.heavyImpact();
    if (type == 'error') HapticFeedback.vibrate();

    try {
      if (type == 'click') {
        await _clickPlayer.stop();
        await _clickPlayer.play(AssetSource(_clickUrl));
      } else if (type == 'success') {
        await _successPlayer.stop();
        await _successPlayer.play(AssetSource(_successUrl));
      } else if (type == 'error') {
        await _errorPlayer.stop();
        await _errorPlayer.play(AssetSource(_errorUrl));
      } else if (type == 'shutter') {
        await _fxPlayer.stop();
        await _fxPlayer.play(AssetSource(_shutterUrl));
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _generateCase() {
    final rand = Random();
    int solX = rand.nextInt(8) + 1;
    int solY = rand.nextInt(8) + 1;
    int k = rand.nextInt(3) + 2;
    int b1 = rand.nextInt(3) + 1;
    int b2 = b1 * k + (rand.nextInt(2) + 1);
    int c1 = solX + b1 * solY;
    int c2 = k * solX + b2 * solY;

    setState(() {
      _caseData = GameCase(
        solX: solX,
        solY: solY,
        a1: 1,
        b1: b1,
        c1: -c1,
        a2: k,
        b2: b2,
        c2: -c2,
        eq1: 'x + ${b1}y = $c1',
        eq2: '${k}x + ${b2}y = $c2',
        multiplier: 'x $k',
        pool: ['x 2', 'x 3', 'x 4', 'x 5']..shuffle(),
        finalEq1: '${k}x + ${b1 * k}y = ${c1 * k}',
        finalEq2: '${k}x + ${b2}y = $c2',
        elimRes: '${(b1 * k - b2).abs()}y = ${(c1 * k - c2).abs()}',
      );
      _currentStep = 1;
      _droppedMultiplier = null;
      _eqStriking = false;
      _hasError = false;
      _xController.clear();
      _yController.clear();
    });
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _checkInput() {
    int? inX = int.tryParse(_xController.text);
    int? inY = int.tryParse(_yController.text);

    if (inX == _caseData.solX && inY == _caseData.solY) {
      _playSound('success');
      setState(() {
        _hasError = false;
        _nextStep();
      });
    } else {
      _playSound('error');
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Main Content (Graphs + UI)
            _buildMainShell(),

            // Curtain Raiser Overlay
            if (_introVisible) _buildIntroScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroScreen() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF0F172A),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              Text(
                I18n.get(_currentLang, 'app_title'),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Text(
                  I18n.get(_currentLang, 'tagline'),
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  _playSound('shutter');
                  setState(() {
                    _introVisible = false;
                  });
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: Text(
                  I18n.get(_currentLang, 'init_btn'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 10,
                  shadowColor: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainShell() {
    final sw = MediaQuery.of(context).size.width;
    final panelWidth = sw * 0.40; // 40% side panel

    return Stack(
      children: [
        // Graph Canvas with InteractiveViewer for Zooming and Panning
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 0,
          bottom: 0,
          right: 0,
          left: _isPanelOpen ? panelWidth : 0,
          child: ClipRect(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.1,
              maxScale: 10.0,
              child: CustomPaint(
                painter: GraphPainter(
                  caseData: _caseData,
                  showIntersection: _currentStep == 5,
                ),
              ),
            ),
          ),
        ),

        // 40% Side Panel (Left Aligned)
        if (!_introVisible)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isPanelOpen ? 0 : -panelWidth,
            top: 0,
            bottom: 0,
            width: panelWidth,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.95),
                border: Border(
                  right: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 20,
                    offset: Offset(5, 0),
                  ),
                ],
              ),
              child: _buildSidePanelContent(),
            ),
          ),

        // Floating Mission Card (Visible when Panel is Closed)
        if (!_isPanelOpen && !_introVisible)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              width: 300,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 32,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.track_changes,
                          color: Colors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          I18n.get(_currentLang, 'active_mission'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Body with Scrollbar
                  Flexible(
                    child: Scrollbar(
                      controller: _hudScrollController,
                      thumbVisibility: true,
                      radius: const Radius.circular(8),
                      thickness: 6,
                      child: SingleChildScrollView(
                        controller: _hudScrollController,
                        padding: const EdgeInsets.all(16),
                        child: _buildCurrentPhase(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Floating Menu Button (Top Left)
        if (!_introVisible)
          Positioned(
            top: 16,
            left: 16,
            child: _buildFloatingIconBtn(
              icon: _isPanelOpen ? Icons.close : Icons.menu,
              onTap: () {
                _playSound('click');
                setState(() {
                  _isPanelOpen = !_isPanelOpen;
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStepHint(String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        border: const Border(
          left: BorderSide(color: Colors.blueAccent, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Colors.blueAccent,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Refactored Progress Bar UI
  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: Colors.black26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (index) {
          int stepNum = index + 1;
          bool isActive = _currentStep == stepNum;
          bool isPast = _currentStep > stepNum;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.orange
                        : (isPast ? Colors.orange.shade800 : Colors.black45),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? Colors.white
                          : (isPast ? Colors.orange : Colors.white24),
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: isActive
                        ? [const BoxShadow(color: Colors.orange, blurRadius: 8)]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: isPast
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : Text(
                          '$stepNum',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
                if (stepNum < 5)
                  Expanded(
                    child: Container(
                      height: 3,
                      color: isPast ? Colors.orange : Colors.white10,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // A helper method to just show the actively running step in the floating card
  Widget _buildCurrentPhase() {
    switch (_currentStep) {
      case 1:
        return _buildPhase1();
      case 2:
        return _buildPhase2();
      case 3:
        return _buildPhase3();
      case 4:
        return _buildPhase4();
      case 5:
        return _buildPhase5();
      default:
        return const SizedBox.shrink();
    }
  }

  // Refactored Sidebar to pin Footer at the bottom
  Widget _buildSidePanelContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main Expanded Area (Scrolls)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header & Controls
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 70,
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ), // top 70 clears the menu button
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Colors.orange, Colors.red],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.shield,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          I18n.get(
                                            _currentLang,
                                            'header_title',
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          I18n.get(
                                            _currentLang,
                                            'header_subtitle',
                                          ),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.orange.shade300,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Language Switcher
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: Row(
                                      children: [
                                        _buildLangBtn('EN', 'en'),
                                        _buildLangBtn('HI', 'hi'),
                                      ],
                                    ),
                                  ),
                                  // Restart Control
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _playSound('click');
                                      setState(() {
                                        _introVisible = true;
                                      });
                                      _generateCase();
                                    },
                                    icon: const Icon(Icons.refresh, size: 14),
                                    label: Text(
                                      I18n.get(_currentLang, 'restart_btn'),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white10,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Beautiful Level Nodes Progress Bar
                        _buildProgressBar(),

                        // Phase Contents
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 40,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_currentStep >= 1) _buildPhase1(),
                              const SizedBox(height: 16),
                              if (_currentStep >= 2) _buildPhase2(),
                              const SizedBox(height: 16),
                              if (_currentStep >= 3) _buildPhase3(),
                              const SizedBox(height: 16),
                              if (_currentStep >= 4) _buildPhase4(),
                              const SizedBox(height: 16),
                              if (_currentStep >= 5) _buildPhase5(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pinned Footer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF020617),
                      border: Border(top: BorderSide(color: Color(0xFF334155))),
                    ),
                    child: const Text(
                      "© ZEROSCIENCELAB | Fall in Love with Math and Science",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingIconBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLangBtn(String label, String code) {
    bool isActive = _currentLang == code;
    return GestureDetector(
      onTap: () {
        _playSound('click');
        setState(() => _currentLang = code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildPhase1() {
    bool isDone = _currentStep > 1;
    return Opacity(
      opacity: isDone ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              I18n.get(_currentLang, 'phase_1_title'),
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            if (!isDone) _buildStepHint(I18n.get(_currentLang, 'hint_p1')),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                I18n.get(_currentLang, 'phase_1_desc'),
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            _buildEqCard(
              "${I18n.get(_currentLang, 'force_1')}${_caseData.eq1}",
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildEqCard(
              "${I18n.get(_currentLang, 'force_2')}${_caseData.eq2}",
              Colors.blue,
            ),
            const SizedBox(height: 16),
            if (!isDone)
              ElevatedButton(
                onPressed: () {
                  _playSound('click');
                  _nextStep();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: Text(
                  I18n.get(_currentLang, 'btn_start_p1'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhase2() {
    bool isDone = _currentStep > 2;
    return Opacity(
      opacity: isDone ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              I18n.get(_currentLang, 'phase_2_title'),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            if (!isDone) _buildStepHint(I18n.get(_currentLang, 'hint_p2')),
            Text(
              I18n.get(_currentLang, 'phase_2_desc'),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (!isDone)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _caseData.pool.map((m) {
                  return Draggable<String>(
                    data: m,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _buildTermChip(m, true),
                    ),
                    childWhenDragging: _buildTermChip(m, false, opacity: 0.3),
                    child: _buildTermChip(m, false),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            DragTarget<String>(
              onWillAcceptWithDetails: (data) => !isDone,
              onAcceptWithDetails: (details) {
                if (details.data == _caseData.multiplier) {
                  _playSound('success');
                  setState(() {
                    _droppedMultiplier = details.data;
                  });
                  Future.delayed(const Duration(milliseconds: 600), _nextStep);
                } else {
                  _playSound('error');
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: candidateData.isNotEmpty
                          ? Colors.blue
                          : (_droppedMultiplier != null
                                ? Colors.green
                                : Colors.transparent),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${I18n.get(_currentLang, 'target')}${_caseData.eq1}",
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _droppedMultiplier != null
                                ? Colors.green
                                : Colors.white30,
                            style: _droppedMultiplier != null
                                ? BorderStyle.solid
                                : BorderStyle.none,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: _droppedMultiplier != null
                              ? Colors.green.withOpacity(0.2)
                              : Colors.black26,
                        ),
                        child: Text(
                          _droppedMultiplier ??
                              I18n.get(_currentLang, 'drop_multiplier'),
                          style: TextStyle(
                            color: _droppedMultiplier != null
                                ? Colors.greenAccent
                                : Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhase3() {
    bool isDone = _currentStep > 3;
    return Opacity(
      opacity: isDone ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              I18n.get(_currentLang, 'phase_3_title'),
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            if (!isDone) _buildStepHint(I18n.get(_currentLang, 'hint_p3')),
            Text(
              I18n.get(_currentLang, 'phase_3_desc'),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            if (!_eqStriking)
              Draggable<String>(
                data: 'eq1',
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildEqCard(
                    _caseData.finalEq1,
                    Colors.orange,
                    width: 250,
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.2,
                  child: _buildEqCard(_caseData.finalEq1, Colors.orange),
                ),
                child: _buildEqCard(_caseData.finalEq1, Colors.orange),
              ),

            if (!_eqStriking)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  I18n.get(_currentLang, 'vs'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
              ),

            if (!_eqStriking)
              DragTarget<String>(
                onWillAcceptWithDetails: (data) => data.data == 'eq1',
                onAcceptWithDetails: (_) {
                  _playSound('success');
                  setState(() {
                    _eqStriking = true;
                  });
                  Future.delayed(const Duration(seconds: 1), _nextStep);
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: candidateData.isNotEmpty
                            ? Colors.red
                            : Colors.blue.withOpacity(0.5),
                        width: 2,
                        style: candidateData.isNotEmpty
                            ? BorderStyle.solid
                            : BorderStyle.none,
                      ),
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        candidateData.isNotEmpty
                            ? I18n.get(_currentLang, 'release_strike')
                            : _caseData.finalEq2,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 16,
                          color: candidateData.isNotEmpty
                              ? Colors.redAccent
                              : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),

            if (_eqStriking)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  "${I18n.get(_currentLang, 'strike_outcome')}${_caseData.elimRes}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhase4() {
    bool isDone = _currentStep > 4;
    return Opacity(
      opacity: isDone ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              I18n.get(_currentLang, 'phase_4_title'),
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            if (!isDone) _buildStepHint(I18n.get(_currentLang, 'hint_p4')),
            Text(
              I18n.get(_currentLang, 'phase_4_desc'),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "x =",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Courier',
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _xController,
                    enabled: !isDone,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black26,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.orange),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                const Text(
                  "y =",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Courier',
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _yController,
                    enabled: !isDone,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black26,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_hasError)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  I18n.get(_currentLang, 'msg_incorrect')
                      .replaceAll('%X%', _caseData.solX.toString())
                      .replaceAll('%Y%', _caseData.solY.toString()),
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            if (!isDone)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: _checkInput,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: Text(
                    I18n.get(_currentLang, 'btn_submit_coords'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhase5() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            I18n.get(_currentLang, 'phase_5_title'),
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        I18n.get(_currentLang, 'force_alpha'),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        "${_caseData.solX}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        I18n.get(_currentLang, 'force_beta'),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        "${_caseData.solY}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _playSound('click');
              _generateCase();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              minimumSize: const Size(double.infinity, 40),
            ),
            child: Text(
              I18n.get(_currentLang, 'btn_next_matchup'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEqCard(String text, MaterialColor color, {double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Courier',
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTermChip(String text, bool isDragging, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDragging ? Colors.blue : const Color(0xFF1E293B),
          border: Border.all(
            color: isDragging ? Colors.white : Colors.blue.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isDragging
              ? [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 10)]
              : [],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Custom Painter for 2D Graph Representation
// ----------------------------------------------------
class GraphPainter extends CustomPainter {
  final GameCase caseData;
  final bool showIntersection;

  GraphPainter({required this.caseData, required this.showIntersection});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background filling a massive area so panning doesn't reveal edges
    canvas.drawRect(
      const Rect.fromLTWH(-10000, -10000, 20000, 20000),
      Paint()..color = const Color(0xFF020617),
    );

    double cx = size.width / 2;
    double cy = size.height / 2;
    double scale = 25.0; // pixels per unit

    // Extensive Grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (double i = cx; i < 10000; i += scale) {
      canvas.drawLine(Offset(i, -10000), Offset(i, 10000), gridPaint);
    }
    for (double i = cx; i > -10000; i -= scale) {
      canvas.drawLine(Offset(i, -10000), Offset(i, 10000), gridPaint);
    }
    for (double i = cy; i < 10000; i += scale) {
      canvas.drawLine(Offset(-10000, i), Offset(10000, i), gridPaint);
    }
    for (double i = cy; i > -10000; i -= scale) {
      canvas.drawLine(Offset(-10000, i), Offset(10000, i), gridPaint);
    }

    // Axes extending very far out
    final axisPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(cx, -10000), Offset(cx, 10000), axisPaint);
    canvas.drawLine(Offset(-10000, cy), Offset(10000, cy), axisPaint);

    // Draw Coordinates along the Axes
    final textStyle = const TextStyle(
      color: Colors.white54,
      fontSize: 10,
      fontFamily: 'Courier',
    );

    // Origin
    TextPainter tpO = TextPainter(
      text: TextSpan(text: '0', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tpO.paint(canvas, Offset(cx + 6, cy + 6));

    // X-axis coordinates
    for (int x = -100; x <= 100; x++) {
      if (x == 0) continue;
      TextPainter tpX = TextPainter(
        text: TextSpan(text: x.toString(), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tpX.paint(canvas, Offset(cx + x * scale - tpX.width / 2, cy + 6));
    }

    // Y-axis coordinates
    for (int y = -100; y <= 100; y++) {
      if (y == 0) continue;
      TextPainter tpY = TextPainter(
        text: TextSpan(text: y.toString(), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      // 'y' mathematically goes up, visually cy - y * scale goes up
      tpY.paint(canvas, Offset(cx + 6, cy - y * scale - tpY.height / 2));
    }

    // Draw Equation Lines
    // Eq: a*x + b*y + c = 0 => y = (-c - a*x) / b
    void drawEqLine(int a, int b, int c, Color color) {
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      // Find y across a very wide X range to ensure the line is infinitely long when panning
      double x1 = -500;
      double y1 = (-c - a * x1) / b;
      double px1 = cx + x1 * scale;
      double py1 = cy - y1 * scale;

      double x2 = 500;
      double y2 = (-c - a * x2) / b;
      double px2 = cx + x2 * scale;
      double py2 = cy - y2 * scale;

      canvas.drawLine(Offset(px1, py1), Offset(px2, py2), linePaint);
    }

    drawEqLine(caseData.a1, caseData.b1, caseData.c1, Colors.orange);
    drawEqLine(caseData.a2, caseData.b2, caseData.c2, Colors.blue);

    if (showIntersection) {
      double ix = cx + caseData.solX * scale;
      double iy = cy - caseData.solY * scale;

      // Pulse ring
      canvas.drawCircle(
        Offset(ix, iy),
        15,
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(Offset(ix, iy), 6, Paint()..color = Colors.white);

      // Label
      TextPainter tp = TextPainter(
        text: TextSpan(
          text: '(${caseData.solX}, ${caseData.solY})',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            backgroundColor: Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(ix + 10, iy - 20));
    }
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.caseData != caseData ||
        oldDelegate.showIntersection != showIntersection;
  }
}

// ----------------------------------------------------
// Models & Data
// ----------------------------------------------------
class GameCase {
  final int solX;
  final int solY;
  final int a1, b1, c1;
  final int a2, b2, c2;
  final String eq1;
  final String eq2;
  final String multiplier;
  final List<String> pool;
  final String finalEq1;
  final String finalEq2;
  final String elimRes;

  GameCase({
    required this.solX,
    required this.solY,
    required this.a1,
    required this.b1,
    required this.c1,
    required this.a2,
    required this.b2,
    required this.c2,
    required this.eq1,
    required this.eq2,
    required this.multiplier,
    required this.pool,
    required this.finalEq1,
    required this.finalEq2,
    required this.elimRes,
  });
}

class I18n {
  static const Map<String, Map<String, String>> dict = {
    'en': {
      'app_title': 'THE ELIMINATION ARENA',
      'tagline': 'ALGEBRAIC COMBAT SIMULATOR',
      'init_btn': 'ENTER ARENA',
      'header_title': 'The Elimination Arena',
      'header_subtitle': 'CLASS 10 • LINEAR EQUATIONS',
      'restart_btn': 'RESTART',
      'hint_p1':
          'Hint: Compare the x-coefficients of Force 1 and Force 2. Find the number to multiply Force 1 so both match.',
      'hint_p2':
          'Hint: Drag the multiplier that scales Force 1 to match Force 2\'s x-coefficient.',
      'hint_p3':
          'Hint: Since the x-coefficients are now identical, subtracting the equations will eliminate x entirely.',
      'hint_p4':
          'Hint: Solve the remaining equation to find y. Then plug y back into the original Force 1 equation to find x.',
      'active_mission': 'ACTIVE MISSION',
      'phase_1_title': 'PHASE 1: THE MATCHUP',
      'phase_1_desc': 'Scale Force 1 to match Force 2 coefficients.',
      'force_1': 'Force 1: ',
      'force_2': 'Force 2: ',
      'btn_start_p1': 'Identify Target & Start',
      'phase_2_title': 'PHASE 2: POWER UP',
      'phase_2_desc': 'Drag the correct multiplier to the targeted Force.',
      'target': 'Target: ',
      'drop_multiplier': 'Drop Multiplier Here',
      'phase_3_title': 'PHASE 3: THE STRIKE',
      'phase_3_desc': 'Drag Eq 1 onto Eq 2 to subtract & eliminate.',
      'vs': 'VS',
      'release_strike': 'RELEASE TO STRIKE',
      'strike_outcome': 'Strike Outcome:\n',
      'phase_4_title': 'PHASE 4: IDENTIFY SOLUTION',
      'phase_4_desc': 'Enter intersection coordinates (x, y).',
      'msg_incorrect': 'Incorrect. The scanner expected x = %X%, y = %Y%.',
      'btn_submit_coords': 'Submit Coordinates',
      'phase_5_title': 'BATTLE WON',
      'force_alpha': 'Force Alpha (x)',
      'force_beta': 'Force Beta (y)',
      'btn_next_matchup': 'Challenge Next Matchup',
    },
    'hi': {
      'app_title': 'विलोपन अखाड़ा',
      'tagline': 'बीजगणितीय युद्ध सिम्युलेटर',
      'init_btn': 'अखाड़े में प्रवेश करें',
      'header_title': 'विलोपन अखाड़ा',
      'header_subtitle': 'कक्षा 10 • रैखिक समीकरण युग्म',
      'restart_btn': 'पुनः प्रारंभ',
      'hint_p1':
          'संकेत: Force 1 और Force 2 के x-गुणांकों की तुलना करें। वह संख्या खोजें जिससे Force 1 को गुणा करने पर दोनों समान हो जाएं।',
      'hint_p2':
          'संकेत: उस गुणक को खींचें जो Force 1 को Force 2 के x-गुणांक से मिलाने के लिए स्केल करता है।',
      'hint_p3':
          'संकेत: चूँकि x-गुणांक अब समान हैं, समीकरणों को घटाने से x पूरी तरह समाप्त हो जाएगा।',
      'hint_p4':
          'संकेत: y ज्ञात करने के लिए बचे हुए समीकरण को हल करें। फिर x ज्ञात करने के लिए y का मान मूल Force 1 समीकरण में रखें।',
      'active_mission': 'सक्रिय मिशन',
      'phase_1_title': 'चरण 1: मुकाबला',
      'phase_1_desc':
          'Force 2 के गुणांकों से मेल खाने के लिए Force 1 को स्केल करें।',
      'force_1': 'बल 1: ',
      'force_2': 'बल 2: ',
      'btn_start_p1': 'लक्ष्य पहचानें और शुरू करें',
      'phase_2_title': 'चरण 2: शक्ति बढ़ाएं',
      'phase_2_desc': 'लक्षित बल पर सही गुणक खींचें।',
      'target': 'लक्ष्य: ',
      'drop_multiplier': 'गुणक यहाँ छोड़ें',
      'phase_3_title': 'चरण 3: प्रहार',
      'phase_3_desc': 'घटाने और समाप्त करने के लिए Eq 1 को Eq 2 पर खींचें।',
      'vs': 'बनाम',
      'release_strike': 'प्रहार करने के लिए छोड़ें',
      'strike_outcome': 'प्रहार परिणाम:\n',
      'phase_4_title': 'चरण 4: समाधान पहचानें',
      'phase_4_desc': 'प्रतिच्छेदन निर्देशांक (x, y) दर्ज करें।',
      'msg_incorrect': 'गलत। स्कैनर को x = %X%, y = %Y% की अपेक्षा थी।',
      'btn_submit_coords': 'निर्देशांक जमा करें',
      'phase_5_title': 'युद्ध जीत लिया',
      'force_alpha': 'बल अल्फा (x)',
      'force_beta': 'बल बीटा (y)',
      'btn_next_matchup': 'अगले मुकाबले को चुनौती दें',
    },
  };

  static String get(String lang, String key) {
    return dict[lang]?[key] ?? dict['en']![key]!;
  }
}
