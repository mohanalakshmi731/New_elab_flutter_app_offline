// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class CubeRootsLab extends StatefulWidget {
  const CubeRootsLab({Key? key}) : super(key: key);

  @override
  State<CubeRootsLab> createState() => _CubeRootsLabState();
}

class _CubeRootsLabState extends State<CubeRootsLab>
    with TickerProviderStateMixin {
  // Application State
  String currentLang = 'en';
  int currentNumber = 3375;
  bool showCurtain = true;
  bool isSidebarOpen = true; // Sidebar open by default

  // Math & Tree State
  List<int> primeFactors = [];
  List<TreeNode> treeNodes = [];
  List<TreeLine> treeLines = [];
  List<Basket> baskets = [];
  bool isTreeBuilt = false;
  bool isDragMode = false;
  bool showVerification = false;
  bool isPerfectCube = false;
  int incompleteCount = 0;

  final TextEditingController _customNumberController = TextEditingController();
  final TransformationController _transformationController =
      TransformationController();

  // --- ROBUST AUDIO SETUP (Copied from Decimal Decoder) ---
  // Dedicated audio players initialized with ReleaseMode.stop to keep audio cached
  static final AudioPlayer _clickPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _buildPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _dropPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _successPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _errorPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  // Network Audio Sources for guaranteed playback (using reliable Mixkit assets)
  static const String _clickUrl =
      'audio/class8/mixkit_2568.mp3'; // Pop click
  static const String _buildUrl =
      'audio/class8/mixkit_2574.mp3'; // Magic/Shutter build
  static const String _dropUrl =
      'audio/class8/mixkit_2869.mp3'; // Plop/Alert drop
  static const String _successUrl =
      'audio/class8/mixkit_2018.mp3'; // Fanfare
  static const String _errorUrl =
      'audio/class8/mixkit_955.mp3'; // Boing error

  // Localization Dictionary
  final Map<String, Map<String, String>> i18n = {
    'en': {
      'title': "Cube Roots",
      'subtitle': "Factor Tree Method",
      'build_tree': "Build Tree",
      'group_primes': "Triplets Group",
      'result': "Verify Output",
      'lab_notes': "Target Output",
      'mission_title': "Problem",
      'toast_match': "Drag HIGHLIGHTED Primes to Matching Baskets!",
      'toast_placed': "You haven't placed all factors yet.",
      'toast_perfect': "Congratulations! This is a Perfect Cube.",
      'toast_imperfect': "Correct! This is NOT a perfect cube.",
      'explore':
          "<h3>Explore</h3>\n1. Select a number.\n2. Click 'Build Tree'.\n3. Drag the colored balls into matching baskets.\n4. Click 'Verify'.",
      'mission_base': "Find the Cube Root of {n} by Prime Factorization.",
      'toast_range_error': "Enter a number between 2 and 30,000",
      'popup_perfect_title': "Perfect Cube!",
      'popup_imperfect_title': "Imperfect Cube",
      'step_2_grouping': "Step 2: Grouping Triplets",
      'imperfect_explanation':
          "Since some factors do not form identical triplets, this number is NOT a perfect cube.",
      'close': "Close",
      'reset_zoom': "Reset Zoom",
      'copyright': "© ZeroScienceLab - Fall in love with math and Science",
      'scenario_settings': "SCENARIO SETTINGS",
      'select_number': "Select Number",
      'dropdown_imperfect': "1323 (Imperfect)",
      'enter_custom_num': "Or enter custom #",
      'step_1_prime_fact': "Step 1: Prime Factorization",
      'for_prime_s': "For {p}'s",
      'class_chapter': "Class 8 • Chapter 1",
      'curtain_title': "Cube Roots",
      'curtain_subtitle': "Visual Prime Factorization",
      'start_lab': "Start Lab",
    },
    'hi': {
      'title': "घनमूल",
      'subtitle': "गुणनखंड वृक्ष विधि",
      'build_tree': "वृक्ष बनाएँ",
      'group_primes': "समूह बनाएँ",
      'result': "परिणाम जाँचें",
      'lab_notes': "लक्ष्य आउटपुट",
      'mission_title': "समस्या",
      'toast_match':
          "हाइलाइट किए गए अभाज्य संख्याओं को सही टोकरियों में खींचें!",
      'toast_placed': "आपने अभी तक सभी कारकों को नहीं रखा है।",
      'toast_perfect': "बधाई हो! यह एक पूर्ण घन है।",
      'toast_imperfect': "सही! यह एक पूर्ण घन नहीं है।",
      'explore': "<h3>अन्वेषण</h3>\nएक संख्या चुनें और वृक्ष बनाएँ।",
      'mission_base': "अभाज्य गुणनखंडन द्वारा {n} का घनमूल ज्ञात करें।",
      'toast_range_error': "2 और 30,000 के बीच की संख्या दर्ज करें",
      'popup_perfect_title': "पूर्ण घन!",
      'popup_imperfect_title': "अपूर्ण घन",
      'step_2_grouping': "चरण 2: त्रिक (Triplets) समूहन",
      'imperfect_explanation':
          "चूँकि कुछ कारक समान त्रिक (triplets) नहीं बनाते हैं, इसलिए यह संख्या पूर्ण घन नहीं है।",
      'close': "बंद करें",
      'reset_zoom': "ज़ूम रीसेट करें",
      'copyright': "© ज़ीरोसाइंसलैब - गणित और विज्ञान से प्यार करें",
      'scenario_settings': "परिदृश्य सेटिंग्स",
      'select_number': "संख्या चुनें",
      'dropdown_imperfect': "1323 (अपूर्ण)",
      'enter_custom_num': "या कस्टम नंबर दर्ज करें",
      'step_1_prime_fact': "चरण 1: अभाज्य गुणनखंडन",
      'for_prime_s': "{p} के लिए",
      'class_chapter': "कक्षा 8 • अध्याय 1",
      'curtain_title': "घनमूल",
      'curtain_subtitle': "दृश्य अभाज्य गुणनखंडन",
      'start_lab': "लैब शुरू करें",
    },
  };

  String t(String key) => i18n[currentLang]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    // Place initial selected number into the text controller
    _customNumberController.text = currentNumber.toString();

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
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _customNumberController.dispose();
    _transformationController.dispose();

    // Dispose all audio players
    _clickPlayer.dispose();
    _buildPlayer.dispose();
    _dropPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();

    super.dispose();
  }

  // --- WEB-SAFE AUDIO HELPER ---
  void _playSound(AudioPlayer player, String url) async {
    try {
      if (player.state == PlayerState.playing) {
        await player.stop();
      }
      await player.play(AssetSource(url));
    } catch (e) {
      debugPrint("Audio Playback Error: $e");
    }
  }

  // --- Zoom & Layout Logic ---
  void _zoomCanvas(double zoomDelta, {Offset? focalPoint}) {
    final Matrix4 matrix = _transformationController.value;
    final double currentScale = matrix.getMaxScaleOnAxis();

    if (currentScale < 0.2 && zoomDelta < 1.0) return;
    if (currentScale > 4.0 && zoomDelta > 1.0) return;

    focalPoint ??= Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );

    matrix.translate(focalPoint.dx, focalPoint.dy);
    matrix.scale(zoomDelta, zoomDelta, 1.0);
    matrix.translate(-focalPoint.dx, -focalPoint.dy);

    _transformationController.value = matrix;
  }

  double _getTreeCenterX(double screenWidth) {
    double visibleStartX = isSidebarOpen ? screenWidth * 0.3 : 0.0;
    double visibleWidth = isSidebarOpen ? screenWidth * 0.7 : screenWidth;
    // Reserve space for baskets (160) and left margin (40)
    double safeWidth = visibleWidth - 200;
    return visibleStartX + 40 + (safeWidth / 2);
  }

  double _getTreeSpread(double screenWidth) {
    double visibleWidth = isSidebarOpen ? screenWidth * 0.7 : screenWidth;
    double safeWidth = visibleWidth - 200;
    return safeWidth / 1.8;
  }

  // --- Math Logic ---
  bool isPrime(int num) {
    if (num < 2) return false;
    for (int i = 2; i <= sqrt(num); i++) {
      if (num % i == 0) return false;
    }
    return true;
  }

  List<int> getPrimeFactors(int n) {
    List<int> factors = [];
    int divisor = 2;
    int temp = n;
    while (temp >= 2) {
      if (temp % divisor == 0) {
        factors.add(divisor);
        temp = temp ~/ divisor;
      } else {
        divisor++;
      }
    }
    return factors;
  }

  dynamic generateBalancedTree(int n) {
    if (isPrime(n)) return [n, null, null];
    int a = -1;
    for (int i = sqrt(n).floor(); i >= 2; i--) {
      if (n % i == 0) {
        a = i;
        break;
      }
    }
    if (a == -1) return [n, null, null];
    int b = n ~/ a;
    return [n, generateBalancedTree(a), generateBalancedTree(b)];
  }

  Color getColorForPrime(int val) {
    Map<int, Color> primeColors = {
      2: Colors.redAccent,
      3: Colors.green,
      5: Colors.amber,
      7: Colors.pink,
      11: Colors.blue,
      13: Colors.indigo,
      17: Colors.purpleAccent,
    };
    if (primeColors.containsKey(val)) return primeColors[val]!;
    double hue = (val * 137.508) % 360;
    return HSVColor.fromAHSV(1.0, hue, 0.7, 0.9).toColor();
  }

  // --- Activity Logic ---
  void loadScenario(int val) {
    HapticFeedback.selectionClick();
    _playSound(_clickPlayer, _clickUrl);

    if (val < 2 || val > 30000) {
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
      _showToast(t('toast_range_error'));
      return;
    }
    setState(() {
      currentNumber = val;
      _customNumberController.text = val.toString(); // Sync text field visually
      resetScene();
      _transformationController.value = Matrix4.identity();
    });
  }

  void resetScene() {
    treeNodes.clear();
    treeLines.clear();
    baskets.clear();
    isTreeBuilt = false;
    isDragMode = false;
    showVerification = false;
    primeFactors = getPrimeFactors(currentNumber);
  }

  void buildTree() {
    HapticFeedback.heavyImpact();
    _playSound(_buildPlayer, _buildUrl);

    setState(() {
      isTreeBuilt = true;
      treeNodes.clear();
      treeLines.clear();
    });

    dynamic treeData = generateBalancedTree(currentNumber);

    double screenWidth = MediaQuery.of(context).size.width;
    double treeCenterX = _getTreeCenterX(screenWidth);
    double spread = _getTreeSpread(screenWidth);

    _buildTreeRecursive(treeData, treeCenterX, 60, spread, 0);

    baskets.clear();
    Map<int, int> factorCounts = {};
    for (int p in primeFactors) {
      factorCounts[p] = (factorCounts[p] ?? 0) + 1;
    }

    factorCounts.forEach((pVal, count) {
      int numBaskets = (count / 3).ceil();
      for (int k = 0; k < numBaskets; k++) {
        baskets.add(Basket(targetPrime: pVal, color: getColorForPrime(pVal)));
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          isDragMode = true;
        });
        _showToast(t('toast_match'));
      }
    });
  }

  void _buildTreeRecursive(
    dynamic treeData,
    double x,
    double y,
    double spread,
    int depth,
  ) {
    if (treeData == null) return;
    int value = treeData[0];
    dynamic leftData = treeData[1];
    dynamic rightData = treeData[2];
    bool isNodePrime = (leftData == null && rightData == null);

    final node = TreeNode(
      id: UniqueKey().toString(),
      value: value,
      x: x,
      y: y,
      isPrime: isNodePrime,
      color: isNodePrime ? getColorForPrime(value) : Colors.blue.shade900,
    );
    treeNodes.add(node);

    if (leftData != null && rightData != null) {
      double childY = y + 80;
      double leftX = x - spread / 2;
      double rightX = x + spread / 2;

      treeLines.add(TreeLine(startX: x, startY: y, endX: leftX, endY: childY));
      treeLines.add(TreeLine(startX: x, startY: y, endX: rightX, endY: childY));

      _buildTreeRecursive(leftData, leftX, childY, spread / 1.8, depth + 1);
      _buildTreeRecursive(rightData, rightX, childY, spread / 1.8, depth + 1);
    }
  }

  void verifyResult() {
    HapticFeedback.selectionClick();
    _playSound(_clickPlayer, _clickUrl);

    int totalPlaced = 0;
    incompleteCount = 0;

    for (var b in baskets) {
      totalPlaced += b.items.length;
      if (b.items.isNotEmpty && b.items.length < 3) {
        incompleteCount++;
      }
    }

    int totalPrimes = treeNodes.where((n) => n.isPrime).length;

    if (totalPlaced < totalPrimes) {
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
      _showToast(t('toast_placed'));
      return;
    }

    setState(() {
      showVerification = true;
      isPerfectCube = (incompleteCount == 0);
    });

    if (isPerfectCube) {
      HapticFeedback.heavyImpact();
      _playSound(_successPlayer, _successUrl);
    } else {
      HapticFeedback.vibrate();
      _playSound(_errorPlayer, _errorUrl);
    }

    _showScrollableSuccessPopup();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        backgroundColor: Colors.blueGrey.shade900,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.only(bottom: 20, left: 100, right: 100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.amber.withOpacity(0.3)),
        ),
      ),
    );
  }

  void _showScrollableSuccessPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0f172a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isPerfectCube
                  ? Colors.green.withOpacity(0.5)
                  : Colors.red.withOpacity(0.5),
              width: 2,
            ),
          ),
          title: Row(
            children: [
              Icon(
                isPerfectCube ? Icons.check_circle : Icons.cancel,
                color: isPerfectCube ? Colors.greenAccent : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Text(
                isPerfectCube
                    ? t('popup_perfect_title')
                    : t('popup_imperfect_title'),
                style: TextStyle(
                  color: isPerfectCube ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isPerfectCube ? t('toast_perfect') : t('toast_imperfect'),
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  _mathBox(t('step_2_grouping'), _buildGroupingMath()),
                  const SizedBox(height: 16),
                  if (isPerfectCube)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        "∛$currentNumber = ${_getUniqueRoots().join(' × ')} = ${pow(currentNumber, 1 / 3).round()}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        t('imperfect_explanation'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                _playSound(_clickPlayer, _clickUrl);
                Navigator.of(context).pop();
              },
              child: Text(
                t('close'),
                style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
        child: Stack(
          children: [
            // 1. Background Grid/Gradients
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [Color(0xFF172554), Color(0xFF020617)],
                    stops: [0.0, 0.7],
                  ),
                ),
              ),
            ),

            // 2. Main Canvas Layer (Responsive, Hit-Test Fixed & Zoomable behind sidebar)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Dynamically expand the virtual boundaries of the canvas content to fit deep and wide trees.
                  // This is CRITICAL for Draggable nodes to register tap events outside standard viewport sizes.
                  double maxContentHeight = constraints.maxHeight;
                  double maxContentWidth = constraints.maxWidth;

                  if (treeNodes.isNotEmpty) {
                    double maxY = treeNodes.map((n) => n.y).reduce(max);
                    double maxX = treeNodes.map((n) => n.x).reduce(max);

                    maxContentHeight = max(constraints.maxHeight, maxY + 150);
                    maxContentWidth = max(constraints.maxWidth, maxX + 150);
                  }

                  return Listener(
                    onPointerSignal: (pointerSignal) {
                      if (pointerSignal is PointerScrollEvent) {
                        final double zoomDelta =
                            pointerSignal.scrollDelta.dy > 0 ? 0.9 : 1.1;
                        _zoomCanvas(
                          zoomDelta,
                          focalPoint: pointerSignal.localPosition,
                        );
                      }
                    },
                    child: InteractiveViewer(
                      // EXTREMELY IMPORTANT: Allows internal child to be larger than the screen
                      // and properly extends hit-test boundaries for bottom nodes.
                      constrained: false,
                      transformationController: _transformationController,
                      panEnabled: true,
                      scaleEnabled: true,
                      minScale: 0.2,
                      maxScale: 4.0,
                      boundaryMargin: EdgeInsets.all(constraints.maxWidth),
                      child: SizedBox(
                        width: maxContentWidth,
                        height: maxContentHeight,
                        child: _buildCanvas(
                          constraints,
                          maxContentWidth,
                          maxContentHeight,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 3. Fixed Baskets Layer (Decoupled from InteractiveViewer so they never pan/zoom away)
            if (isDragMode)
              Positioned(
                right: 40,
                top: 40,
                bottom: 20,
                width: 120,
                child: ListView.builder(
                  itemCount: baskets.length,
                  itemBuilder: (ctx, i) {
                    return _buildBasket(baskets[i]);
                  },
                ),
              ),

            // 4. Zoom Controls Layer (Shifts left out of the way of the baskets)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 20,
              right: isDragMode ? 50 : 50,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  _zoomButton(
                    icon: Icons.filter_center_focus,
                    tooltip: t('reset_zoom'),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _playSound(_clickPlayer, _clickUrl);
                      _transformationController.value = Matrix4.identity();
                    },
                  ),
                ],
              ),
            ),

            // 5. Left Sidebar Layer (30% width, floating above canvas)
            AnimatedPositioned(
              left: isSidebarOpen ? 0 : -screenWidth * 0.3,
              top: 0,
              bottom: 0,
              width: screenWidth * 0.3,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1121).withOpacity(0.95),
                  border: Border(
                    right: BorderSide(
                      color: Colors.blue.shade900.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(5, 0),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 70,
                    left: 16,
                    right: 16,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSidebarHeader(),
                      const SizedBox(height: 20),
                      _buildSidebarControls(),
                      const SizedBox(height: 20),
                      _buildSidebarTargetOutput(),
                      const SizedBox(height: 20),
                      Text(
                        t('copyright'),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),

            // 6. Floating Menu & Back Buttons Layer (Top Left)
            Positioned(
              top: 20,
              left: 20,
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(isSidebarOpen ? Icons.menu_open : Icons.menu),
                      color: Colors.white,
                      iconSize: 30,
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _playSound(_clickPlayer, _clickUrl);
                        setState(() {
                          isSidebarOpen = !isSidebarOpen;
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: isSidebarOpen
                            ? Colors.blue.shade900.withOpacity(0.5)
                            : Colors.black.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 7. Curtain Raiser Layer
            if (showCurtain) _buildCurtainRaiser(),
          ],
        ),
      ),
    );
  }

  Widget _zoomButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade900.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  // --- Sidebar Sub-components ---
  Widget _buildSidebarHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade900.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Icon(Icons.account_tree, color: Colors.amber),
            ),
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
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    t('subtitle'),
                    style: TextStyle(
                      color: Colors.blue.shade400,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.shade900.withOpacity(0.5),
                ),
              ),
              padding: const EdgeInsets.all(2),
              child: Row(
                children: ['en', 'hi'].map((lang) {
                  bool isActive = currentLang == lang;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _playSound(_clickPlayer, _clickUrl);
                      setState(() => currentLang = lang);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.blue.shade900.withOpacity(0.5)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        lang.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? Colors.blue.shade400
                              : Colors.blueGrey.shade400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.blueGrey.shade400),
              onPressed: () {
                setState(() {
                  showCurtain = true;
                });
                loadScenario(currentNumber);
              },
              tooltip: "Reset Scene",
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSidebarControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0f172a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t('scenario_settings').toUpperCase(),
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Presets
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                dropdownColor: const Color(0xFF1e293b),
                isExpanded: true,
                value: [3375, 27000, 10648, 1323].contains(currentNumber)
                    ? currentNumber
                    : null,
                hint: Text(
                  t('select_number'),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                items: [
                  const DropdownMenuItem(
                    value: 3375,
                    child: Text("3375 (15³)"),
                  ),
                  const DropdownMenuItem(
                    value: 27000,
                    child: Text("27000 (30³)"),
                  ),
                  const DropdownMenuItem(
                    value: 10648,
                    child: Text("10648 (22³)"),
                  ),
                  DropdownMenuItem(
                    value: 1323,
                    child: Text(t('dropdown_imperfect')),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) loadScenario(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Custom Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customNumberController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: t('enter_custom_num'),
                    hintStyle: const TextStyle(color: Colors.white30),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (v) {
                    int? num = int.tryParse(v);
                    if (num != null) loadScenario(num);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.blueAccent),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _playSound(_clickPlayer, _clickUrl);
                  int? num = int.tryParse(_customNumberController.text);
                  if (num != null) loadScenario(num);
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Actions
          ElevatedButton.icon(
            icon: const Icon(Icons.account_tree),
            label: Text(t('build_tree')),
            onPressed: isTreeBuilt
                ? null
                : () {
                    buildTree();
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: Text(t('result')),
            onPressed: !isDragMode ? null : verifyResult,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarTargetOutput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.menu_book, color: Colors.amber, size: 18),
            const SizedBox(width: 8),
            Text(
              t('lab_notes'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Mission Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade900.withOpacity(0.2),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.track_changes,
                    color: Colors.blueAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    t('mission_title').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t('mission_base').replaceAll('{n}', currentNumber.toString()),
                style: const TextStyle(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Math Steps
        if (isTreeBuilt) ...[
          _mathBox(
            t('step_1_prime_fact'),
            "$currentNumber = ${primeFactors.join(' × ')}",
          ),
          const SizedBox(height: 12),
        ],
        if (showVerification) ...[
          _mathBox(t('step_2_grouping'), _buildGroupingMath()),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _mathBox(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black45,
        border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'serif',
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  String _buildGroupingMath() {
    List<String> groups = [];
    for (var b in baskets) {
      if (b.items.isNotEmpty) {
        String term = List.filled(b.items.length, b.targetPrime).join(' × ');
        if (b.items.length == 3) {
          groups.add("($term)");
        } else {
          groups.add(term);
        }
      }
    }
    return "$currentNumber = ${groups.join(' × ')}";
  }

  List<int> _getUniqueRoots() {
    List<int> roots = [];
    for (var b in baskets) {
      if (b.items.length == 3) roots.add(b.targetPrime);
    }
    return roots;
  }

  Widget _buildCanvas(
    BoxConstraints constraints,
    double maxContentWidth,
    double maxContentHeight,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Lines layer
        if (isTreeBuilt)
          Positioned.fill(
            child: CustomPaint(painter: TreePainter(lines: treeLines)),
          ),

        // Nodes Layer
        if (isTreeBuilt)
          ...treeNodes.map((node) {
            if (isDragMode && node.isPrime && !node.isPlaced) {
              return Positioned(
                left: node.x - 20,
                top: node.y - 20,
                child: Draggable<TreeNode>(
                  data: node,
                  onDragStarted: () {
                    HapticFeedback.selectionClick();
                    _playSound(_clickPlayer, _clickUrl);
                  },
                  feedback: Material(
                    color: Colors.transparent,
                    child: _buildPrimeBall(node, scale: 1.2, isHighlight: true),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _buildPrimeBall(node),
                  ),
                  child: _buildPrimeBall(node, isHighlight: true),
                ),
              );
            }
            if (node.isPlaced) return const SizedBox.shrink();

            return Positioned(
              left: node.x - (node.isPrime ? 20 : 25),
              top: node.y - (node.isPrime ? 20 : 25),
              child: node.isPrime
                  ? _buildPrimeBall(node)
                  : _buildCompositeBox(node.value),
            );
          })
        else
          // Place the selected number correctly centered on the canvas before the tree is built
          Positioned(
            left: _getTreeCenterX(constraints.maxWidth) - 25,
            top: 60 - 25, // 60 is the starting Y coordinate in buildTree
            child: _buildCompositeBox(currentNumber),
          ),
      ],
    );
  }

  Widget _buildCompositeBox(int value) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF1e3a8a).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade400, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 10),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        value.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildPrimeBall(
    TreeNode node, {
    double scale = 1.0,
    bool isHighlight = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40 * scale,
      height: 40 * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: node.color,
        border: isHighlight ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: isHighlight
            ? [BoxShadow(color: node.color, blurRadius: 15, spreadRadius: 2)]
            : [],
        gradient: RadialGradient(
          colors: [node.color.withOpacity(0.5), node.color],
          center: const Alignment(-0.3, -0.3),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        node.value.toString(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14 * scale,
        ),
      ),
    );
  }

  Widget _buildBasket(Basket basket) {
    return DragTarget<TreeNode>(
      onWillAcceptWithDetails: (details) {
        return details.data.value == basket.targetPrime &&
            basket.items.length < 3;
      },
      onAcceptWithDetails: (details) {
        HapticFeedback.heavyImpact();
        _playSound(_dropPlayer, _dropUrl);
        setState(() {
          basket.items.add(details.data);
          details.data.isPlaced = true;
        });
      },
      builder: (context, candidateData, rejectedData) {
        bool isHover = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 80,
          decoration: BoxDecoration(
            color: basket.color.withOpacity(isHover ? 0.4 : 0.1),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            border: Border.all(
              color: basket.color.withOpacity(isHover ? 1.0 : 0.5),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                t(
                  'for_prime_s',
                ).replaceAll('{p}', basket.targetPrime.toString()),
                style: TextStyle(
                  color: basket.color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  if (index < basket.items.length) {
                    return _buildPrimeBall(basket.items[index], scale: 0.7);
                  }
                  return Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: basket.color.withOpacity(0.3),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurtainRaiser() {
    return AnimatedOpacity(
      opacity: showCurtain ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      onEnd: () {
        if (!showCurtain) setState(() {});
      },
      child: Container(
        color: const Color(0xFF020617),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_tree, color: Colors.amber, size: 80),
            const SizedBox(height: 20),
            Text(
              t('class_chapter'),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 12,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t('curtain_title'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              t('curtain_subtitle'),
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                t('start_lab'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                _playSound(_clickPlayer, _clickUrl);
                setState(() => showCurtain = false);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
                shadowColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Data Models ---
class TreeNode {
  final String id;
  final int value;
  final double x;
  final double y;
  final bool isPrime;
  final Color color;
  bool isPlaced = false;

  TreeNode({
    required this.id,
    required this.value,
    required this.x,
    required this.y,
    required this.isPrime,
    required this.color,
  });
}

class TreeLine {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  TreeLine({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
  });
}

class Basket {
  final int targetPrime;
  final Color color;
  List<TreeNode> items = [];
  Basket({required this.targetPrime, required this.color});
}

// --- Custom Painter for Tree Lines ---
class TreePainter extends CustomPainter {
  final List<TreeLine> lines;

  TreePainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var line in lines) {
      final path = Path();
      path.moveTo(line.startX, line.startY);
      // Smooth curve for branches
      path.cubicTo(
        line.startX,
        line.startY + 40,
        line.endX,
        line.endY - 40,
        line.endX,
        line.endY,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) => true;
}
