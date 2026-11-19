// Imported from new-elab-app-7; Class 7 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZSLVirtualLabApp());
}

class ZSLVirtualLabApp extends StatelessWidget {
  const ZSLVirtualLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZSL Virtual Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        primaryColor: const Color(0xFFEAB308),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const EstimationRoundingLargeNumbers(),
    );
  }
}

class EstimationRoundingLargeNumbers extends StatefulWidget {
  const EstimationRoundingLargeNumbers({super.key});

  @override
  State<EstimationRoundingLargeNumbers> createState() =>
      _EstimationRoundingLargeNumbersState();
}

class _EstimationRoundingLargeNumbersState
    extends State<EstimationRoundingLargeNumbers>
    with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  bool _showCurtain = true; // Added state for the curtain screen

  // Scenario State
  int _currentScenario = 1;
  int _currentStep = 1;

  // Canvas Interaction State
  Offset _puckPos = const Offset(600, 650);
  Offset? _puck2Pos; // For scenario 2 step 2
  String _puckLabel = "76,068";
  String? _puck2Label;
  bool _isPuckVisible = true;
  bool _isPuck2Visible = false;
  bool _isPuckDragging = false;
  bool _isPuck2Dragging = false;

  // Coins for Scenario 2
  final List<_Coin> _coins = [];
  String _centerJarLabel = "";
  bool _showCenterJar = false;
  bool _showComparisonPopup = false;

  // Header Controls State
  String _currentLanguage = 'EN';
  final bool _isDarkMode = true;

  // Audio Player
  late AudioPlayer _audioPlayer;

  // Sound URLs (Mixkit Child-Friendly sounds)
  final String _soundSuccess =
      'audio/class7/mixkit_2013.mp3';
  final String _soundClink =
      'audio/class7/mixkit_392.mp3';
  final String _soundError =
      'audio/class7/mixkit_2955.mp3';

  // Fixed Canvas Size for consistency
  final double canvasWidth = 1200;
  final double canvasHeight = 800;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _audioPlayer = AudioPlayer();
    _loadScenario(1);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioPlayer.dispose();
    super.dispose();
  }

  // Translation Helper
  String _t(String en, String hi) {
    return _currentLanguage == 'EN' ? en : hi;
  }

  void _playSound(String url) async {
    try {
      await _audioPlayer.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _enterLab() {
    _playSound(_soundSuccess);
    setState(() {
      _showCurtain = false;
    });
  }

  void _resetLab() {
    _playSound(_soundClink);
    _loadScenario(1);
    setState(() {
      _isSidebarOpen = true;
      _showCurtain = true; // Show curtain again on reset
    });
  }

  void _toggleLanguage() {
    setState(() {
      _currentLanguage = _currentLanguage == 'EN' ? 'HI' : 'EN';
    });
  }

  void _loadScenario(int scenario) {
    setState(() {
      _currentScenario = scenario;
      _currentStep = 1;
      _coins.clear();
      _showCenterJar = false;
      _centerJarLabel = "";
      _showComparisonPopup = false;
      _setupStep();
    });
  }

  void _setupStep() {
    setState(() {
      if (_currentScenario == 1) {
        if (_currentStep == 1) {
          _puckPos = const Offset(600, 650);
          _puckLabel = "76,068";
          _isPuckVisible = true;
          _isPuck2Visible = false;
        } else if (_currentStep == 3) {
          _puckPos = const Offset(600, 650);
          _puckLabel = "75,000";
          _isPuckVisible = true;
        }
      } else if (_currentScenario == 2) {
        if (_currentStep == 1) {
          _puckPos = const Offset(600, 650);
          _puckLabel = "4,63,128";
          _isPuckVisible = true;
          _isPuck2Visible = false;
          _coins.clear();
          _showCenterJar = false;
        } else if (_currentStep == 2) {
          _puck2Pos = const Offset(600, 650);
          _puck2Label = "4,19,682";
          _isPuck2Visible = true;
        }
      }
    });
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
      _setupStep();
    });
  }

  void _checkDrop(Offset localPos, Offset targetPos, VoidCallback onSuccess) {
    if ((localPos - targetPos).distance < 120) {
      _playSound(_soundSuccess);
      onSuccess();
    } else {
      _playSound(_soundError);
      setState(() {
        if (_currentStep == 1 ||
            _currentStep == 3 ||
            (_currentScenario == 2 && _currentStep == 1)) {
          _puckPos = const Offset(600, 650);
        }
        if (_currentScenario == 2 && _currentStep == 2) {
          _puck2Pos = const Offset(600, 650);
        }
      });
    }
  }

  void _activateMagnetS1() async {
    _playSound(_soundClink);
    if (_currentStep == 2) {
      setState(() {
        _puckPos = const Offset(200, 400); // Snap Left
        _puckLabel = "76,000";
      });
      await Future.delayed(const Duration(seconds: 1));
      _nextStep();
    } else if (_currentStep == 4) {
      setState(() {
        _puckPos = const Offset(1000, 400); // Snap Right
        _puckLabel = "80,000";
      });
      await Future.delayed(const Duration(seconds: 1));
      _showCompletion();
    }
  }

  void _activateMagnetS2() async {
    _playSound(_soundClink);
    if (_currentStep == 1) {
      setState(() {
        _puckPos = const Offset(1000, 400);
        _puckLabel = "5,00,000";
      });
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _isPuckVisible = false;
        for (int i = 0; i < 5; i++) {
          _coins.add(
            _Coin(
              pos: Offset(
                1000 + (Random().nextDouble() * 40 - 20),
                380 - (i * 20),
              ),
              color: Colors.redAccent,
            ),
          );
        }
      });
      _playSound(_soundSuccess);
      await Future.delayed(const Duration(seconds: 1));
      _nextStep();
    } else if (_currentStep == 2) {
      setState(() {
        _puck2Pos = const Offset(200, 400);
        _puck2Label = "4,00,000";
      });
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _isPuck2Visible = false;
        for (int i = 0; i < 4; i++) {
          _coins.add(
            _Coin(
              pos: Offset(
                200 + (Random().nextDouble() * 40 - 20),
                380 - (i * 20),
              ),
              color: Colors.blueAccent,
            ),
          );
        }
      });
      _playSound(_soundSuccess);
      await Future.delayed(const Duration(seconds: 1));
      _nextStep();
    }
  }

  void _combineCoinsS2() async {
    _playSound(_soundClink);
    setState(() {
      _showCenterJar = true;
      _centerJarLabel = "0";
    });

    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      for (int i = 0; i < _coins.length; i++) {
        _coins[i].pos = Offset(
          600 + (Random().nextDouble() * 60 - 30),
          400 + (Random().nextDouble() * 40 - 20),
        );
      }
    });

    await Future.delayed(const Duration(milliseconds: 800));
    for (int i = 1; i <= 9; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() {
        _centerJarLabel = "$i,00,000";
      });
      if (i % 3 == 0) _playSound(_soundClink);
    }

    _playSound(_soundSuccess);
    await Future.delayed(const Duration(seconds: 1));
    _nextStep();
  }

  void _showCompletion() {
    setState(() {
      _showComparisonPopup = true;
    });
    _playSound(_soundSuccess);
  }

  // ---------------------------------------------------------
  // HELPERS FOR STEPS AND ACTIONS
  // ---------------------------------------------------------
  List<String> _getScenarioSteps(int scenario) {
    if (scenario == 1) {
      return [
        _t(
          "DRAG the number 76,068 onto the number line.",
          "संख्या 76,068 को संख्या रेखा पर खींचें।",
        ),
        _t(
          "CLICK the 'Activate Magnet' button.",
          "'मैग्नेट सक्रिय करें' बटन पर क्लिक करें।",
        ),
        _t(
          "DRAG the number 75,000 onto the fulcrum exactly in the middle.",
          "संख्या 75,000 को ठीक बीच में फुलक्रम पर खींचें।",
        ),
        _t(
          "CLICK the 'Activate Magnet' button.",
          "'मैग्नेट सक्रिय करें' बटन पर क्लिक करें।",
        ),
      ];
    } else {
      return [
        _t(
          "DRAG the first number, 4,63,128, onto the number line & Activate.",
          "पहली संख्या, 4,63,128 को संख्या रेखा पर खींचें और सक्रिय करें।",
        ),
        _t(
          "DRAG the second number, 4,19,682, onto the number line & Activate.",
          "दूसरी संख्या, 4,19,682 को संख्या रेखा पर खींचें और सक्रिय करें।",
        ),
        _t(
          "CLICK the 'Combine' button to pour the estimates.",
          "अनुमानों को मिलाने के लिए 'मिलाएं' बटन पर क्लिक करें।",
        ),
        _t(
          "Compare the estimated sum with the exact sum.",
          "अनुमानित योग की सटीक योग से तुलना करें।",
        ),
      ];
    }
  }

  _ActionInfo? _getCurrentAction() {
    if (_currentScenario == 1) {
      if (_currentStep == 1 && _puckPos == const Offset(350, 400)) {
        return _ActionInfo(_t("Continue", "जारी रखें"), _nextStep);
      } else if (_currentStep == 2) {
        return _ActionInfo(
          _t("Activate Magnet", "मैग्नेट सक्रिय करें"),
          _activateMagnetS1,
        );
      } else if (_currentStep == 3 && _puckPos == const Offset(600, 400)) {
        return _ActionInfo(_t("Continue", "जारी रखें"), _nextStep);
      } else if (_currentStep == 4) {
        return _ActionInfo(
          _t("Activate Magnet", "मैग्नेट सक्रिय करें"),
          _activateMagnetS1,
        );
      }
    } else {
      if (_currentStep == 1 && _puckPos == const Offset(850, 400)) {
        return _ActionInfo(
          _t("Activate Magnet", "मैग्नेट सक्रिय करें"),
          _activateMagnetS2,
        );
      } else if (_currentStep == 2 && _puck2Pos == const Offset(350, 400)) {
        return _ActionInfo(
          _t("Activate Magnet", "मैग्नेट सक्रिय करें"),
          _activateMagnetS2,
        );
      } else if (_currentStep == 3) {
        return _ActionInfo(_t("Combine", "मिलाएं"), _combineCoinsS2);
      } else if (_currentStep == 4) {
        return _ActionInfo(_t("Finish", "समाप्त करें"), _showCompletion);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final sidebarWidth = screenWidth * 0.35;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: Scaffold(
        // Explicit dark/light color for the scaffold
        backgroundColor: _isDarkMode
            ? const Color(0xFF0F172A)
            : Colors.blueGrey.shade50,
        body: Stack(
          children: [
            // 1. Background / Canvas Area
            Positioned.fill(
              child: Container(
                // Explicitly dark/light canvas container
                color: _isDarkMode
                    ? const Color(0xFF0F172A)
                    : Colors.blueGrey.shade50,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: canvasWidth,
                        height: canvasHeight,
                        child: CustomPaint(
                          painter: _GridPainter(isDarkMode: _isDarkMode),
                          child: _buildCanvasContent(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Floating Mission Card (when sidebar collapsed)
            if (!_isSidebarOpen)
              Positioned(top: 54, left: 24, child: _buildFloatingMissionCard()),

            // 3. Center Popups (Comparison Screen)
            if (_showComparisonPopup)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(child: _buildComparisonPopup()),
                ),
              ),

            // 4. Sidebar (Animated Positioned, ensuring Z-Index is front)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              width: sidebarWidth,
              child: _buildSidebar(),
            ),

            // 5. Menu Icon (Top Left, fixed position)
            Positioned(
              top: 16,
              left: 16,
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

            // 6. Curtain Intro Screen (Highest Z-Index)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: _showCurtain ? 0 : -screenHeight,
              bottom: _showCurtain ? 0 : screenHeight,
              left: 0,
              right: 0,
              child: _buildCurtainScreen(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // INTRO CURTAIN SCREEN RENDERER
  // ---------------------------------------------------------
  Widget _buildCurtainScreen() {
    final bgColor = _isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF1F5F9);
    final textColor = _isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = _isDarkMode ? Colors.grey : Colors.blueGrey.shade700;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: const Border(bottom: BorderSide(color: Colors.amber, width: 8)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _t(
                  "The Rounding Magnet:\nA Feel for Large Numbers",
                  "राउंडिंग मैग्नेट:\nबड़ी संख्याओं की समझ",
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _t(
                  "CLASS 7 • LARGE NUMBERS AROUND US",
                  "कक्षा 7 • हमारे चारों ओर की बड़ी संख्याएँ",
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _enterLab,
                icon: const Icon(Icons.play_circle_fill, size: 28),
                label: Text(
                  _t("Enter Virtual Lab", "वर्चुअल लैब में प्रवेश करें"),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                  shadowColor: Colors.amber.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // CANVAS RENDERERS
  // ---------------------------------------------------------
  Widget _buildCanvasContent() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Ground Diorama
        Positioned(
          left: 100,
          top: 200,
          right: 100,
          bottom: 100,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B), // Deep slate-800
              borderRadius: BorderRadius.circular(500),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 50,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),

        // Number Line
        Positioned(
          left: 200,
          top: 400,
          right: 200,
          child: Container(
            height: 4,
            color: Colors.blueGrey.shade700,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                11,
                (index) => Container(
                  width: 4,
                  height: 20,
                  color: Colors.blueGrey.shade300,
                ),
              ),
            ),
          ),
        ),

        // Magnets / Labels based on Scenario
        if (_currentScenario == 1) ...[
          _buildMagnet(
            const Offset(200, 400),
            _currentStep < 3 ? "76,000" : "70,000",
            Colors.blue,
          ),
          _buildMagnet(
            const Offset(1000, 400),
            _currentStep < 3 ? "77,000" : "80,000",
            Colors.red,
          ),

          if (_currentStep == 1)
            _buildDropZone(
              const Offset(350, 400),
              _t("Drop Near Here", "यहाँ के पास छोड़ें"),
            ),
          if (_currentStep == 3)
            _buildDropZone(
              const Offset(600, 400),
              _t("Place on fulcrum", "फुलक्रम पर रखें"),
            ),
        ] else ...[
          _buildMagnet(const Offset(200, 400), "4,00,000", Colors.blue),
          _buildMagnet(const Offset(1000, 400), "5,00,000", Colors.red),

          if (_currentStep == 1)
            _buildDropZone(
              const Offset(850, 400),
              _t("Drop Near Here", "यहाँ के पास छोड़ें"),
            ),
          if (_currentStep == 2)
            _buildDropZone(
              const Offset(350, 400),
              _t("Drop Near Here", "यहाँ के पास छोड़ें"),
            ),
        ],

        // Jars for Scenario 2
        if (_currentScenario == 2 && _currentStep >= 2 && !_isPuckVisible)
          _buildJar(const Offset(1000, 400)),
        if (_currentScenario == 2 && _currentStep >= 3 && !_isPuck2Visible)
          _buildJar(const Offset(200, 400)),
        if (_showCenterJar)
          _buildJar(const Offset(600, 400), size: 1.5, label: _centerJarLabel),

        // Coins
        for (var coin in _coins)
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOutCubic,
            left: coin.pos.dx - 15,
            top: coin.pos.dy - 15,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: coin.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54, width: 2),
                boxShadow: [
                  BoxShadow(color: coin.color.withOpacity(0.5), blurRadius: 10),
                ],
              ),
            ),
          ),

        // Puck 1
        if (_isPuckVisible)
          AnimatedPositioned(
            duration: _isPuckDragging
                ? Duration.zero
                : const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            left: _puckPos.dx - 50,
            top: _puckPos.dy - 50,
            child: GestureDetector(
              onPanStart: (_) => setState(() => _isPuckDragging = true),
              onPanUpdate: (details) {
                setState(() => _puckPos += details.delta);
              },
              onPanEnd: (_) {
                setState(() => _isPuckDragging = false);
                if (_currentScenario == 1 && _currentStep == 1) {
                  _checkDrop(
                    _puckPos,
                    const Offset(350, 400),
                    () => setState(() => _puckPos = const Offset(350, 400)),
                  );
                } else if (_currentScenario == 1 && _currentStep == 3) {
                  _checkDrop(
                    _puckPos,
                    const Offset(600, 400),
                    () => setState(() => _puckPos = const Offset(600, 400)),
                  );
                } else if (_currentScenario == 2 && _currentStep == 1) {
                  _checkDrop(
                    _puckPos,
                    const Offset(850, 400),
                    () => setState(() => _puckPos = const Offset(850, 400)),
                  );
                }
              },
              child: _buildPuckWidget(_puckLabel),
            ),
          ),

        // Puck 2 (Scenario 2)
        if (_currentScenario == 2 && _isPuck2Visible && _puck2Pos != null)
          AnimatedPositioned(
            duration: _isPuck2Dragging
                ? Duration.zero
                : const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            left: _puck2Pos!.dx - 50,
            top: _puck2Pos!.dy - 50,
            child: GestureDetector(
              onPanStart: (_) => setState(() => _isPuck2Dragging = true),
              onPanUpdate: (details) {
                setState(() => _puck2Pos = _puck2Pos! + details.delta);
              },
              onPanEnd: (_) {
                setState(() => _isPuck2Dragging = false);
                if (_currentStep == 2) {
                  _checkDrop(
                    _puck2Pos!,
                    const Offset(350, 400),
                    () => setState(() => _puck2Pos = const Offset(350, 400)),
                  );
                }
              },
              child: _buildPuckWidget(_puck2Label ?? ""),
            ),
          ),
      ],
    );
  }

  Widget _buildMagnet(Offset pos, String label, Color color) {
    return Positioned(
      left: pos.dx - 60,
      top: pos.dy - 60,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.monitor_weight_outlined,
                size: 60,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone(Offset pos, String label) {
    return Positioned(
      left: pos.dx - 80,
      top: pos.dy - 80,
      child: Column(
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.greenAccent,
                width: 3,
                style: BorderStyle.solid,
              ),
              color: Colors.greenAccent.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPuckWidget(String label) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const RadialGradient(colors: [Colors.yellow, Colors.orange]),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 5,
          ),
          const BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildJar(Offset pos, {double size = 1.0, String label = ""}) {
    final double width = 120 * size;
    final double height = 160 * size;
    return Positioned(
      left: pos.dx - (width / 2),
      top: pos.dy - (height / 2),
      child: Column(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              border: Border.all(color: Colors.white54, width: 2),
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // SIDEBAR RENDERER
  // ---------------------------------------------------------
  Widget _buildSidebar() {
    final bgColor = _isDarkMode
        ? const Color(0xFF0F172A).withOpacity(0.95)
        : Colors.white.withOpacity(0.95);
    final textColor = _isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = _isDarkMode ? Colors.grey : Colors.blueGrey.shade700;
    final borderColor = _isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.1);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Controls (Language, Reset)

                // Title & Dropdown
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 70,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t("The Rounding Magnet", "राउंडिंग मैग्नेट"),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        _t(
                          "Class 7 • Large Numbers",
                          "कक्षा 7 • बड़ी संख्याएँ",
                        ),
                        style: TextStyle(fontSize: 12, color: subtitleColor),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: _toggleLanguage,
                            style: TextButton.styleFrom(
                              foregroundColor: subtitleColor,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(40, 40),
                            ),
                            child: Text(
                              _currentLanguage,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // IconButton(
                          //   icon: Icon(
                          //     _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          //   ),
                          //   color: subtitleColor,
                          //   onPressed: () {
                          //     _playSound(_soundClink);
                          //     setState(() {
                          //       _isDarkMode = !_isDarkMode;
                          //     });
                          //   },
                          //   tooltip: _t("Toggle Theme", "थीम बदलें"),
                          // ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            color: subtitleColor,
                            onPressed: _resetLab,
                            tooltip: _t("Reset Lab", "लैब रीसेट करें"),
                          ),
                        ],
                      ),

                      // Scenario Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: _isDarkMode
                              ? const Color(0xFF1E293B)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _currentScenario,
                            dropdownColor: _isDarkMode
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                            iconEnabledColor: textColor,
                            items: [
                              DropdownMenuItem(
                                value: 1,
                                child: Text(
                                  _t(
                                    "1. The Chintamani Snap",
                                    "1. चिंतामणि स्नैप",
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text(
                                  _t(
                                    "2. Roxie's Estimation Sum",
                                    "2. रॉक्सी का अनुमानित योग",
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) _loadScenario(val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Steps Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t("Procedural Steps", "प्रक्रियात्मक कदम"),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildStepsList(),
                    ],
                  ),
                ),

                // Action Area
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildActionArea(),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: borderColor)),
                  color: _isDarkMode ? Colors.black26 : Colors.grey.shade200,
                ),
                child: Text(
                  _t(
                    "© ZeroScienceLab - Fall in love with math and Science",
                    "© ZeroScienceLab - Fall in love with math and Science",
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: subtitleColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStepsList() {
    List<String> steps = _getScenarioSteps(_currentScenario);

    return List.generate(steps.length, (index) {
      final stepNum = index + 1;
      final isActive = stepNum == _currentStep;
      final isCompleted = stepNum < _currentStep;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.amber.withOpacity(0.9)
              : (isCompleted
                    ? (_isDarkMode
                          ? Colors.white10
                          : Colors.black.withOpacity(0.05))
                    : (_isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.02))),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.amber : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _t("STEP $stepNum", "कदम $stepNum"),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isActive
                        ? Colors.black87
                        : (isCompleted
                              ? Colors.grey
                              : (_isDarkMode
                                    ? Colors.white70
                                    : Colors.black54)),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              steps[index],
              style: TextStyle(
                fontSize: 14,
                color: isActive
                    ? Colors.black
                    : (isCompleted
                          ? Colors.grey
                          : (_isDarkMode ? Colors.white : Colors.black87)),
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionArea() {
    final actionInfo = _getCurrentAction();
    if (actionInfo == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        onPressed: actionInfo.action,
        child: Text(
          actionInfo.label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // FLOATING CARDS & POPUPS
  // ---------------------------------------------------------
  Widget _buildFloatingMissionCard() {
    final steps = _getScenarioSteps(_currentScenario);
    final currentInstruction = steps[_currentStep - 1];
    final actionInfo = _getCurrentAction();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 250),
      child: Card(
        color: const Color(0xFF1E293B).withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.amber.withOpacity(0.5)),
        ),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _t("Current Mission", "वर्तमान मिशन"),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "${_t("Step", "कदम")} $_currentStep: $currentInstruction",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (actionInfo != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: actionInfo.action,
                    child: Text(
                      actionInfo.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonPopup() {
    return Container(
      width: 500,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() => _showComparisonPopup = false);
                  _playSound(_soundClink);
                },
              ),
            ),
            Text(
              _t("Estimation Comparison", "अनुमान की तुलना"),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      _t("YOUR ESTIMATE", "आपका अनुमान"),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentScenario == 1 ? "80,000" : "9,00,000",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 2,
                  height: 60,
                  color: Colors.grey.withOpacity(0.3),
                ),
                Column(
                  children: [
                    Text(
                      _t("EXACT ANSWER", "सटीक उत्तर"),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentScenario == 1 ? "75,000" : "8,82,810",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.thumb_up, color: Colors.greenAccent),
                  const SizedBox(width: 12),
                  Text(
                    _t("Good Estimate!", "अच्छा अनुमान!"),
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
}

class _ActionInfo {
  final String label;
  final VoidCallback action;
  _ActionInfo(this.label, this.action);
}

class _Coin {
  Offset pos;
  Color color;
  _Coin({required this.pos, required this.color});
}

// Gives the canvas an authentic architectural blueprint aesthetic
class _GridPainter extends CustomPainter {
  final bool isDarkMode;

  _GridPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode
          ? const Color(0xFF1E293B).withOpacity(0.5) // Dark slate grid lines
          : Colors.blueGrey.withOpacity(0.2) // Light grid lines
      ..strokeWidth = 1.0;

    const double spacing = 40.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
