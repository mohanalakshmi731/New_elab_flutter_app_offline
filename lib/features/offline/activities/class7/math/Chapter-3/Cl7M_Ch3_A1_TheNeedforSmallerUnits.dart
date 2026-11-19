// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: Colors.orangeAccent,
        fontFamily: 'Roboto',
      ),
      home: const TheNeedforSmallerUnits(),
    ),
  );
}

class TheNeedforSmallerUnits extends StatefulWidget {
  const TheNeedforSmallerUnits({super.key});

  @override
  State<TheNeedforSmallerUnits> createState() => _TheNeedforSmallerUnitsState();
}

class _TheNeedforSmallerUnitsState extends State<TheNeedforSmallerUnits>
    with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  bool _isLabEntered = false;
  int _scenarioIdx = 0;
  int _stepIdx = 0;
  int _clickCount = 0;
  String _language = 'en';

  final AudioPlayer _audioPlayer = AudioPlayer();
  final TransformationController _transformController =
      TransformationController();

  // Animation controllers for failure effects
  late AnimationController _wobbleController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _wobbleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initial zoom logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetZoom();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioPlayer.dispose();
    _wobbleController.dispose();
    _bounceController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _playSound(String type) async {
    try {
      if (type == 'success') {
        await _audioPlayer.play(
          AssetSource(
            'audio/class7/mixkit_2013.mp3',
          ),
        );
      } else if (type == 'error') {
        await _audioPlayer.play(
          AssetSource(
            'audio/class7/mixkit_2004.mp3',
          ),
        );
      } else if (type == 'click') {
        await _audioPlayer.play(
          AssetSource(
            'audio/class7/mixkit_2568.mp3',
          ),
        );
      }
    } catch (e) {
      debugPrint("Audio error: $e");
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessPopup(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.orangeAccent,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              uiTranslations['summary']![_language]!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 18,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast(uiTranslations['toastValidated']![_language]!);
            },
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.orangeAccent, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDrop(String data, String target) {
    if (_scenarioIdx == 0) {
      if (_stepIdx == 0 && data == 'ruler1' && target == 'axleBase') {
        _playSound('success');
        setState(() => _stepIdx++);
        _showToast(uiTranslations['successMsgPlaceScale']![_language]!);
      } else if (_stepIdx == 1 && data == 'wheel2' && target == 'axlePin') {
        _playSound('error');
        _wobbleController.forward(from: 0);
        _showToast(uiTranslations['errWheel2cm']![_language]!, isError: true);
        setState(() => _stepIdx++);
      } else if (_stepIdx == 2 && data == 'wheel3' && target == 'axlePin') {
        _playSound('error');
        _bounceController.forward(from: 0);
        _showToast(uiTranslations['errWheel3cm']![_language]!, isError: true);
        setState(() => _stepIdx++);
      }
    } else if (_scenarioIdx == 1) {
      if (_stepIdx == 0 && data == 'ruler2' && target == 'axleBase') {
        _playSound('success');
        setState(() => _stepIdx++);
        _showToast(uiTranslations['successMsgPlaceScalePrecise']![_language]!);
      } else if (_stepIdx == 2 && data == 'wheel2_7' && target == 'axlePin') {
        _playSound('success');
        setState(() => _stepIdx++);
        _showToast(uiTranslations['successMsgPerfectFit']![_language]!);
        _showSuccessPopup(
          scenariosData[_scenarioIdx]['conclusion']![_language],
        );
      }
    }
  }

  void _handlePinClick(int index) {
    if (_scenarioIdx == 1 && _stepIdx == 1) {
      if (index == _clickCount + 1) {
        _playSound('click');
        setState(() => _clickCount++);
        if (_clickCount == 7) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _playSound('success');
            setState(() => _stepIdx++);
            _showToast(uiTranslations['successMsgCorrectTenths']![_language]!);
          });
        }
      }
    }
  }

  void _resetLab() {
    setState(() {
      _isLabEntered = false;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _scenarioIdx = 0;
        _stepIdx = 0;
        _clickCount = 0;
        _language = 'en';
        _resetZoom();
      });
    });
  }

  void _changeLanguage() {
    setState(() {
      if (_language == 'en') {
        _language = 'hi';
      } else {
        _language = 'en';
      }
    });
    _showToast(
      "${uiTranslations['toastLang']![_language]!} ${_language.toUpperCase()}",
    );
  }

  void _zoomIn() {
    final matrix = _transformController.value.clone();
    matrix.scale(1.2);
    _transformController.value = matrix;
  }

  void _zoomOut() {
    final matrix = _transformController.value.clone();
    matrix.scale(0.8);
    _transformController.value = matrix;
  }

  void _resetZoom() {
    // Centers and scales appropriately
    final matrix = Matrix4.identity();
    matrix.scale(0.8);
    matrix.translate(-150.0, -100.0);
    _transformController.value = matrix;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidebarWidth = screenWidth * 0.35;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Row handling Sidebar & Canvas Layout
            Row(
              children: [
                // Animated Sidebar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _isSidebarOpen ? sidebarWidth : 0,
                  child: ClipRect(
                    child: OverflowBox(
                      minWidth: sidebarWidth,
                      maxWidth: sidebarWidth,
                      alignment: Alignment.centerLeft,
                      child: _buildSidebar(),
                    ),
                  ),
                ),

                // Main Canvas Area
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        color: const Color(0xFF1E293B),
                        child: InteractiveViewer(
                          transformationController: _transformController,
                          minScale: 0.2,
                          maxScale: 4.0,
                          constrained: false,
                          // Increased boundary margin to allow massive panning area
                          boundaryMargin: const EdgeInsets.all(4000),
                          child: Center(
                            child: SizedBox(
                              width: 1400,
                              height: 1000,
                              child: _buildLabCanvas(),
                            ),
                          ),
                        ),
                      ),

                      // Floating Mission Card (visible when sidebar is closed)
                      if (!_isSidebarOpen) _buildFloatingMissionCard(),

                      // Canvas Controls (Zoom In/Out/Reset)
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                onPressed: _zoomIn,
                                tooltip: "Zoom In",
                              ),
                              Container(
                                height: 1,
                                width: 30,
                                color: Colors.white24,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                ),
                                onPressed: _zoomOut,
                                tooltip: "Zoom Out",
                              ),
                              Container(
                                height: 1,
                                width: 30,
                                color: Colors.white24,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.orangeAccent,
                                ),
                                onPressed: _resetZoom,
                                tooltip: "Reset View",
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Validate / Complete button overlay
                      if (_stepIdx >=
                          (scenariosData[_scenarioIdx]['steps'] as List).length)
                        Positioned(
                          bottom: 30,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.black,
                                size: 28,
                              ),
                              label: Text(
                                uiTranslations['validateModel']![_language]!,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 10,
                                shadowColor: Colors.orangeAccent.withOpacity(
                                  0.5,
                                ),
                              ),
                              onPressed: () => _showSuccessPopup(
                                scenariosData[_scenarioIdx]['conclusion']![_language],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Fixed Menu Icon Top-Left
            Positioned(
              top: 16,
              left: 16, // Fixed position, won't slide with sidebar
              child: IconButton(
                icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                color: Colors.orangeAccent,
                iconSize: 28,
                onPressed: () {
                  HapticFeedback.lightImpact();
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

            // Curtain Screen Overlay
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: _isLabEntered ? -MediaQuery.of(context).size.height : 0,
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

  // --- WIDGET BUILDERS ---

  Widget _buildSidebar() {
    return Container(
      color: const Color(0xFF0F172A),
      height: double.infinity,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Area
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon, Title & Subheading
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.science,
                              color: Colors.orangeAccent,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  uiTranslations['headerTitle']![_language]!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  uiTranslations['subtitle']![_language]!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Language Toggle and Reset Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            Icons.language,
                            _language.toUpperCase(),
                            _changeLanguage,
                          ),
                          const SizedBox(width: 12),
                          _buildActionButton(Icons.refresh, 'Reset', _resetLab),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Current Scenario Dropdown
                      Text(
                        uiTranslations['currentScenario']![_language]!
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1E293B),
                            value: _scenarioIdx,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            onChanged: (int? newValue) {
                              if (newValue != null &&
                                  newValue != _scenarioIdx) {
                                setState(() {
                                  _scenarioIdx = newValue;
                                  _stepIdx = 0;
                                  _clickCount = 0;
                                });
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                value: 0,
                                child: Text('1. The Misfit Toy Wheel'),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Text('2. The Precision Ruler'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Area
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mission Objective
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.track_changes,
                                  color: Colors.orangeAccent,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Objective",
                                  style: TextStyle(
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              scenariosData[_scenarioIdx]['objective']![_language],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Procedure
                      const Row(
                        children: [
                          Icon(
                            Icons.format_list_numbered,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Procedure",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Steps List
                      ...List.generate(
                        (scenariosData[_scenarioIdx]['steps'] as List).length,
                        (index) {
                          bool isPast = index < _stepIdx;
                          bool isCurrent = index == _stepIdx;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isPast
                                        ? Colors.green.withOpacity(0.2)
                                        : (isCurrent
                                              ? Colors.orangeAccent
                                              : Colors.white12),
                                    border: Border.all(
                                      color: isPast
                                          ? Colors.green
                                          : (isCurrent
                                                ? Colors.orangeAccent
                                                : Colors.white24),
                                    ),
                                  ),
                                  child: Center(
                                    child: isPast
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.greenAccent,
                                          )
                                        : Text(
                                            "${index + 1}",
                                            style: TextStyle(
                                              color: isCurrent
                                                  ? Colors.black
                                                  : Colors.white54,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      scenariosData[_scenarioIdx]['steps'][index]['desc'][_language],
                                      style: TextStyle(
                                        color: isPast
                                            ? Colors.white70
                                            : (isCurrent
                                                  ? Colors.white
                                                  : Colors.white38),
                                        fontWeight: isCurrent
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 15,
                                        height: 1.4,
                                      ),
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

                const Spacer(),

                // Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    color: const Color(0xFF0F172A),
                  ),
                  child: const Text(
                    "© ZeroScienceLab - Fall in love with math and Science",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingMissionCard() {
    return Positioned(
      top: 60,
      left: 20,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.track_changes, color: Colors.orangeAccent, size: 20),
                SizedBox(width: 8),
                Text(
                  "Current Task",
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _stepIdx < (scenariosData[_scenarioIdx]['steps'] as List).length
                  ? scenariosData[_scenarioIdx]['steps'][_stepIdx]['desc'][_language]
                  : "Mission Complete! Validate your model.",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShutterScreen() {
    return Container(
      color: const Color(0xFF0F172A),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.blueGrey.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  radius: 1.2,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.2),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.straighten,
                      size: 60,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(height: 30),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      children: [
                        TextSpan(
                          text: uiTranslations['titleMain1']![_language]!,
                        ),
                        TextSpan(
                          text: uiTranslations['titleMain2']![_language]!,
                          style: const TextStyle(color: Colors.orangeAccent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    uiTranslations['subtitle']![_language]!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      _playSound('success');
                      setState(() => _isLabEntered = true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                      shadowColor: Colors.orangeAccent.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          uiTranslations['enterLab']![_language]!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.arrow_forward, color: Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CANVAS & INTERACTIVE ELEMENTS ---

  Widget _buildTooltip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2433),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildWheelTray(
    String label,
    Color rimColor,
    String data,
    double left,
    double top,
    AnimationController? anim,
  ) {
    return Positioned(
      left: left,
      top: top,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          CustomPaint(painter: BoxBackPainter(), size: const Size(120, 50)),
          Positioned(
            bottom: 8,
            child: AnimatedBuilder(
              animation: anim ?? const AlwaysStoppedAnimation(0),
              builder: (context, child) {
                double offset = 0;
                double angle = 0;
                if (anim != null && anim.isAnimating) {
                  if (data == 'wheel3') {
                    offset = math.sin(anim.value * 3.14) * -40; // bounce
                  }
                  if (data == 'wheel2') {
                    angle = math.sin(anim.value * 6 * 3.14) * 0.2; // wobble
                  }
                }
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: Transform.rotate(
                    angle: angle,
                    child: Draggable<String>(
                      data: data,
                      feedback: Material(
                        color: Colors.transparent,
                        child: IsometricWheelGraphic(
                          size: 70,
                          rimColor: rimColor,
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: IsometricWheelGraphic(
                          size: 70,
                          rimColor: rimColor,
                        ),
                      ),
                      child: IsometricWheelGraphic(
                        size: 70,
                        rimColor: rimColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // IgnorePointer prevents this layer from consuming tap/drag events
          IgnorePointer(
            child: CustomPaint(
              painter: BoxFrontPainter(),
              size: const Size(120, 50),
            ),
          ),
          Positioned(
            bottom: 12,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2230),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabCanvas() {
    return Stack(
      clipBehavior: Clip.none, // Allows background to bleed infinitely
      children: [
        // Background - Sky (Extended infinitely)
        Positioned(
          left: -4000,
          right: -4000,
          top: -4000,
          height: 4000 + 333.0, // 333 is 1/3rd of the 1000px height base
          child: Container(color: const Color(0xFF111424)),
        ),

        // Background - Wood Table (Extended infinitely)
        Positioned(
          left: -4000,
          right: -4000,
          top: 333.0,
          height: 4000 + 667.0, // Extends deeply to the bottom
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFCD99A), Color(0xFFDCA95C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Ruler Attached under Car (Placed FIRST so it renders UNDER the wheel)
        if (_stepIdx > 0)
          Positioned(
            left: 315,
            top: 520,
            child: Transform(
              transform: Matrix4.identity()
                ..scale(
                  1.0,
                  0.6,
                ), // Squashed in Y to simulate lying flat on the floor
              alignment: Alignment.topCenter,
              child: _buildRulerGraphic(_scenarioIdx == 1),
            ),
          ),

        // Isometric Car body
        Positioned(
          left: 150,
          top: 350,
          child: CustomPaint(painter: CarPainter(), size: const Size(280, 150)),
        ),

        // Tooltips
        Positioned(left: 280, top: 350, child: _buildTooltip("Toy Car")),

        if ((_scenarioIdx == 0 && _stepIdx == 0) ||
            (_scenarioIdx == 1 && _stepIdx == 0))
          Positioned(
            left: 800,
            top: 430,
            child: _buildTooltip(
              _scenarioIdx == 0 ? "Wooden Scale" : "Precision Scale",
            ),
          ),

        if (_scenarioIdx == 0 && _stepIdx >= 1)
          Positioned(left: 800, top: 220, child: _buildTooltip("2 cm Wheel")),
        if (_scenarioIdx == 0 && _stepIdx >= 2)
          Positioned(left: 1000, top: 220, child: _buildTooltip("3 cm Wheel")),

        // Trays and Wheels
        if (_scenarioIdx == 0 && _stepIdx >= 1)
          _buildWheelTray(
            "2 cm WHEELS",
            const Color(0xFFE8606B),
            'wheel2',
            800,
            280,
            _wobbleController,
          ),
        if (_scenarioIdx == 0 && _stepIdx >= 2)
          _buildWheelTray(
            "3 cm WHEELS",
            const Color(0xFF5A688C),
            'wheel3',
            1000,
            280,
            _bounceController,
          ),

        if (_scenarioIdx == 1 && _stepIdx == 2)
          _buildWheelTray(
            "2.7 cm WHEELS",
            Colors.greenAccent,
            'wheel2_7',
            800,
            280,
            null,
          ),

        // Ruler Target Base - Clear visual drop zone exactly where the ruler will snap
        if (_stepIdx == 0)
          Positioned(
            left: 330,
            top: 505,
            child: DragTarget<String>(
              onWillAccept: (data) => data == 'ruler1' || data == 'ruler2',
              builder: (context, candidateData, rejectedData) => Container(
                width: 430,
                height: 80,
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty
                      ? Colors.orangeAccent.withOpacity(0.3)
                      : Colors.black12,
                  border: Border.all(
                    color: candidateData.isNotEmpty
                        ? Colors.orangeAccent
                        : Colors.white30,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: candidateData.isEmpty
                    ? const Text(
                        "Place Ruler Here",
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              onAccept: (data) => _handleDrop(data, 'axleBase'),
            ),
          ),

        // Axle Pin Target (For Wheels) - Clear visual circular drop zone centered on the axle tip
        if ((_scenarioIdx == 0 && _stepIdx > 0) ||
            (_scenarioIdx == 1 && _stepIdx == 2))
          Positioned(
            left: 310, // Visually aligned to center over 355
            top: 465, // Visually aligned to center over 510
            child: DragTarget<String>(
              onWillAccept: (data) =>
                  data == 'wheel2' || data == 'wheel3' || data == 'wheel2_7',
              builder: (context, candidateData, rejectedData) => Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty
                      ? Colors.orangeAccent.withOpacity(0.3)
                      : Colors.black12,
                  border: Border.all(
                    color: candidateData.isNotEmpty
                        ? Colors.orangeAccent
                        : Colors.white54,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(45),
                ),
                alignment: Alignment.center,
              ),
              onAccept: (data) => _handleDrop(data, 'axlePin'),
            ),
          ),

        // SUCCESSFUL WHEEL ATTACHMENT
        // Axle tip is at global x=355, y=510. Center of wheel is half its size (35).
        if (_scenarioIdx == 1 && _stepIdx > 2)
          Positioned(
            left: 330,
            top: 455,
            child: const IsometricWheelGraphic(
              size: 80,
              rimColor: Colors.greenAccent,
            ),
          ),

        // Ruler Source Location (on the right table side)
        if ((_scenarioIdx == 0 && _stepIdx == 0) ||
            (_scenarioIdx == 1 && _stepIdx == 0))
          Positioned(
            left: 800,
            top: 480,
            child: Draggable<String>(
              data: _scenarioIdx == 0 ? 'ruler1' : 'ruler2',
              feedback: Transform(
                transform: Matrix4.identity()..scale(1.0, 0.6),
                alignment: Alignment.topCenter,
                child: _buildRulerGraphic(_scenarioIdx == 1),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: Transform(
                  transform: Matrix4.identity()..scale(1.0, 0.6),
                  alignment: Alignment.topCenter,
                  child: _buildRulerGraphic(_scenarioIdx == 1),
                ),
              ),
              child: Transform(
                transform: Matrix4.identity()..scale(1.0, 0.6),
                alignment: Alignment.topCenter,
                child: _buildRulerGraphic(_scenarioIdx == 1),
              ),
            ),
          ),

        // PINS for Scenario 2 Step 1 (Floating above attached precise ruler)
        if (_scenarioIdx == 1 && _stepIdx == 1)
          ...List.generate(7, (index) {
            bool isActive = index == _clickCount;
            bool isClicked = index < _clickCount;
            if (index > _clickCount) {
              return const SizedBox.shrink(); // Hide future pins
            }

            // Precisely aligned horizontally to sit on top of the squashed ruler
            double offsetX = 360 + (index * 26.6);
            double offsetY = 540;

            return Positioned(
              left: offsetX,
              top: offsetY,
              child: GestureDetector(
                onTap: isActive ? () => _handlePinClick(index + 1) : null,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: isActive ? 0.0 : 1.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, isActive ? -15 * (1 - value) : 0),
                      child: Container(
                        width: isActive ? 24 : 16,
                        height: isActive ? 24 : 16,
                        decoration: BoxDecoration(
                          color: isClicked ? Colors.green : Colors.blueAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: isClicked
                              ? const Icon(
                                  Icons.check,
                                  size: 10,
                                  color: Colors.white,
                                )
                              : (isActive
                                    ? Text(
                                        "${index + 1}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      )
                                    : null),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildRulerGraphic(bool isPrecision) {
    return Container(
      width: 400,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFFEE600),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 4)),
        ],
      ),
      child: CustomPaint(painter: RulerPainter(isPrecision: isPrecision)),
    );
  }
}

// --- PAINTERS & GRAPHICS FOR 3D EFFECT ---

class CarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    double dx = 30; // isometric skew horizontal
    double dy = -25; // isometric skew vertical

    // Chassis Top Face (Light Green)
    paint.color = const Color(0xFF21CC65);
    Path chassisTop = Path()
      ..moveTo(0, 80)
      ..lineTo(280, 80)
      ..lineTo(280 + dx, 80 + dy)
      ..lineTo(0 + dx, 80 + dy)
      ..close();
    canvas.drawPath(chassisTop, paint);

    // Chassis Right/Front Face (Dark Green)
    paint.color = const Color(0xFF149D4A);
    Path chassisRight = Path()
      ..moveTo(280, 80)
      ..lineTo(280 + dx, 80 + dy)
      ..lineTo(280 + dx, 130 + dy)
      ..lineTo(280, 130)
      ..close();
    canvas.drawPath(chassisRight, paint);

    // Chassis Main Side Face (Bright Green)
    paint.color = const Color(0xFF28ED78);
    canvas.drawRect(const Rect.fromLTWH(0, 80, 280, 50), paint);

    // Cabin Top Face (Dark Navy)
    paint.color = const Color(0xFF1B233A);
    Path cabinTop = Path()
      ..moveTo(20, 20)
      ..lineTo(180, 20)
      ..lineTo(180 + dx, 20 + dy)
      ..lineTo(20 + dx, 20 + dy)
      ..close();
    canvas.drawPath(cabinTop, paint);

    // Cabin Right Face (Blackish)
    paint.color = const Color(0xFF111520);
    Path cabinRight = Path()
      ..moveTo(180, 20)
      ..lineTo(180 + dx, 20 + dy)
      ..lineTo(180 + dx, 80 + dy)
      ..lineTo(180, 80)
      ..close();
    canvas.drawPath(cabinRight, paint);

    // Cabin Main Side Face (Green Frame)
    paint.color = const Color(0xFF28ED78);
    canvas.drawRect(const Rect.fromLTWH(20, 20, 160, 60), paint);

    // Cabin Window
    paint.color = const Color(0xFF181C2C);
    canvas.drawRect(const Rect.fromLTWH(30, 30, 140, 40), paint);

    // Front Wheel (drawn over body)
    paint.color = const Color(0xFF22293C);
    canvas.drawCircle(const Offset(60, 140), 40, paint);
    paint.color = const Color(0xFFCFD9EA);
    canvas.drawCircle(const Offset(60, 140), 20, paint);

    // Axle cut out (Half circle block)
    paint.color = const Color(0xFF181C2C);
    Path cutout = Path()
      ..moveTo(180, 130)
      ..arcToPoint(
        const Offset(260, 130),
        radius: const Radius.circular(40),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(cutout, paint);

    // Axle Pin (Extending outwards)
    paint.color = const Color(0xFF323946);
    paint.strokeWidth = 16;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(220, 120), const Offset(205, 160), paint);

    // Axle Pin Tip (Yellow)
    paint.color = const Color(0xFFFEE600);
    paint.strokeWidth = 16;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(205, 160), const Offset(203, 165), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BoxBackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Inside Bottom
    paint.color = const Color(0xFFF7D1A2);
    Path floor = Path()
      ..moveTo(0, 30)
      ..lineTo(size.width, 30)
      ..lineTo(size.width + 20, 10)
      ..lineTo(20, 10)
      ..close();
    canvas.drawPath(floor, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BoxFrontPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Right Side Outer Face
    paint.color = const Color(0xFFE0BB8E);
    Path rightSide = Path()
      ..moveTo(size.width, 30)
      ..lineTo(size.width + 20, 10)
      ..lineTo(size.width + 20, size.height - 10)
      ..lineTo(size.width, size.height + 10)
      ..close();
    canvas.drawPath(rightSide, paint);

    // Front Outer Face
    paint.color = const Color(0xFFFADAA9);
    canvas.drawRect(Rect.fromLTWH(0, 30, size.width, size.height - 20), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IsometricWheelGraphic extends StatelessWidget {
  final double size;
  final Color rimColor;

  const IsometricWheelGraphic({
    super.key,
    required this.size,
    required this.rimColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF22293C), // Tire
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 4)),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.45,
          height: size * 0.45,
          decoration: BoxDecoration(color: rimColor, shape: BoxShape.circle),
          child: Center(
            child: Container(
              width: size * 0.15,
              height: size * 0.15,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RulerPainter extends CustomPainter {
  final bool isPrecision;
  RulerPainter({required this.isPrecision});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    double pixelsPerCm = size.width / 15.0;

    for (int i = 0; i <= 14; i++) {
      double x = (i * pixelsPerCm) + 10;

      canvas.drawLine(Offset(x, 0), Offset(x, 15), paint);

      textPainter.text = TextSpan(
        text: "$i",
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(x, 25);
      canvas.rotate(math.pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();

      if (isPrecision && i < 14) {
        for (int j = 1; j < 10; j++) {
          double mx = x + (j * (pixelsPerCm / 10));
          double tickLen = j == 5 ? 10 : 5;
          canvas.drawLine(
            Offset(mx, 0),
            Offset(mx, tickLen),
            paint..strokeWidth = 1,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const Map<String, Map<String, String>> uiTranslations = {
  'titleMain1': {
    'en': "A Peek Beyond the Point:\n",
    'hi': "बिंदु के पार एक नज़र:\n",
  },
  'titleMain2': {
    'en': "The Need for Smaller Units",
    'hi': "छोटी इकाइयों की आवश्यकता",
  },
  'subtitle': {
    'en': "Class 7 • A PEEK BEYOND THE POINT",
    'hi': "कक्षा 7 • बिंदु के पार एक नज़र",
  },
  'enterLab': {'en': "Enter Virtual Lab", 'hi': "वर्चुअल लैब में प्रवेश करें"},
  'headerTitle': {
    'en': "A Peek Beyond the Point: The Need for Smaller Units",
    'hi': "बिंदु के पार एक नज़र: छोटी इकाइयों की आवश्यकता",
  },
  'currentScenario': {'en': "Current Scenario", 'hi': "वर्तमान परिदृश्य"},
  'summary': {'en': "Summary", 'hi': "सारांश", 'te': "సారాంశం"},
  'toastValidated': {
    'en': "Model validated and scenario completed.",
    'hi': "मॉडल मान्य किया गया और परिदृश्य पूरा हुआ।",
  },
  'validateModel': {'en': "Validate Model", 'hi': "मॉडल मान्य करें"},
  'toastLang': {'en': "Language changed to", 'hi': "भाषा बदल कर"},
  'errWheel2cm': {
    'en': "The 2cm wheel is too short! It leaves a gap and wobbles.",
    'hi': "2 सेमी का पहिया बहुत छोटा है! यह एक अंतर छोड़ता है और डगमगाता है।",
  },
  'errWheel3cm': {
    'en': "The 3cm wheel is too thick! It hits the car body.",
    'hi': "3 सेमी का पहिया बहुत मोटा है! यह कार की बॉडी से टकराता है।",
  },
  'successMsgPlaceScale': {
    'en': "Scale placed successfully!",
    'hi': "पैमाना सफलतापूर्वक रखा गया!",
  },
  'successMsgPlaceScalePrecise': {
    'en': "Precision scale placed successfully!",
    'hi': "सटीक पैमाना सफलतापूर्वक रखा गया!",
  },
  'successMsgCorrectTenths': {
    'en': "Correct! That is exactly 2.7 cm.",
    'hi': "सही! यह ठीक 2.7 सेमी है।",
  },
  'successMsgPerfectFit': {
    'en': "Perfect fit! Wheel attached successfully.",
    'hi': "बिल्कुल सही फिट! पहिया सफलतापूर्वक जुड़ गया।",
  },
};

const List<Map<String, dynamic>> scenariosData = [
  {
    'id': 0,
    'title': {'en': "1. The Misfit Toy Wheel", 'hi': "1. बेमेल खिलौना पहिया"},
    'objective': {
      'en':
          "To experience the problem of whole-unit measurement and understand the need for smaller, more precise units.",
      'hi':
          "पूर्ण-इकाई माप की समस्या का अनुभव करने और छोटी, अधिक सटीक इकाइयों की आवश्यकता को समझने के लिए।",
    },
    'steps': [
      {
        'desc': {
          'en':
              "Drag the yellow wooden ruler from the right edge and align its '0' mark under the toy car's axle.",
          'hi':
              "कार्यक्षेत्र से पीले लकड़ी के पैमाने को खींचें और इसके '0' चिह्न को खिलौना कार के धुरी के आधार के साथ संरेखित करें।",
        },
      },
      {
        'desc': {
          'en':
              "Attempt to attach the 2 cm wheel (from the box) to the axle pin.",
          'hi': "एक्सल पिन पर 2 सेमी का पहिया (बॉक्स से) लगाने का प्रयास करें।",
        },
      },
      {
        'desc': {
          'en':
              "Attempt to attach the 3 cm wheel (from the box) to the axle pin.",
          'hi': "एक्सल पिन पर 3 सेमी का पहिया (बॉक्स से) लगाने का प्रयास करें।",
        },
      },
    ],
    'conclusion': {
      'en':
          "Neither 2 cm nor 3 cm is the right size! The axle's length is between these two whole numbers. We need a better way to measure.",
      'hi':
          "न तो 2 सेमी और न ही 3 सेमी सही आकार है! धुरी की लंबाई इन दो पूर्ण संख्याओं के बीच है। हमें मापने के लिए एक बेहतर तरीके की आवश्यकता है।",
    },
  },
  {
    'id': 1,
    'title': {'en': "2. The Precision Ruler", 'hi': "2. सटीक पैमाना"},
    'objective': {
      'en':
          "To introduce and use 'tenths' as the solution for precise measurement.",
      'hi':
          "सटीक माप के समाधान के रूप में 'दसवें हिस्से' (tenths) का परिचय और उपयोग करना।",
    },
    'steps': [
      {
        'desc': {
          'en':
              "Drag the Precision Ruler and align its '0' mark under the axle pin.",
          'hi':
              "सटीक पैमाने को खींचें और इसके '0' चिह्न को एक्सल पिन के प्रारंभ के साथ संरेखित करें।",
        },
      },
      {
        'desc': {
          'en':
              "Click the floating pins sequentially to count the tenths up to the end of the axle pin.",
          'hi':
              "एक्सल पिन के अंत तक दसवें हिस्से को गिनने के लिए तैरते हुए पिनों पर क्रमिक रूप से क्लिक करें।",
        },
      },
      {
        'desc': {
          'en':
              "A new wheel labeled '2.7 cm' has appeared. Drag and attach it to the axle pin.",
          'hi':
              "'2.7 सेमी' लेबल वाला एक नया पहिया दिखाई दिया है। इसे खींचें और एक्सल पिन से जोड़ें।",
        },
      },
    ],
    'conclusion': {
      'en':
          "Success! By dividing 1 centimeter into 10 equal parts, we measured the exact length. The axle is 2 whole centimeters and 7 tenths of a centimeter long (2.7 cm).",
      'hi':
          "सफलता! 1 सेंटीमीटर को 10 समान भागों में विभाजित करके, हमने सटीक लंबाई मापी। धुरी 2 पूर्ण सेंटीमीटर और एक सेंटीमीटर का 7 दसवां हिस्सा लंबी है (2.7 सेमी)।",
    },
  },
];
